`include "header.vh"

// naming pattern:
//   - data bus: xxx2xxx
//   - address bus: xxx2xxx_addr
//   - write enable: xxx2xxx_we

// clk:
//   - clk_100mhz: to divider, bus and VGA
//   - Clk_CPU: to CPU, counter, and 8digit 7-segment

// Computer system | single cycle processor test environment
module test_soc(
    input wire clk_100mhz,
    input wire RSTN, // 复位信号，低电平有效
    input wire [3:0] BTN_y, // buttons
    input wire [15:0] SW, // switches

    // to VGA
    output wire [3:0] Red,
    output wire [3:0] Green,
    output wire [3:0] Blue,
    output wire HSYNC,
    output wire VSYNC,

    // to LED
    output wire [15:0] led_out,

    // to 7-seg
    output wire [7:0] segment,
    output wire [7:0] AN

    // output LED_PEN,
    // output SEG_PEN,
    // output led_clk,
    // output led_clrn,
    // output led_sout,
    // output seg_clk,
    // output seg_clrn,
    // output seg_sout
);
    // inputs
    wire rst;
    wire [15:0] SW_OK;
    wire [3:0] BTN_OK;

    // preprocess signals
    SAnti_jitter U9(
        // anti-jittered signals
        .clk(clk_100mhz), // 主板时钟
        .Key_y(BTN_y), // input
        .SW(SW), // input
        .BTN_OK(BTN_OK),  // output
        .SW_OK(SW_OK), // output

        // negate RSTN
        .RSTN(RSTN), 
        .rst(rst),

        // unused
        .readn(1'b0)
    );

    wire Clk_CPU;
    wire [31:0] clk_div;
    clk_div U8(
        .clk(clk_100mhz), // 主板时钟
        .rst(rst), // 复位信号
        .SW2(SW_OK[2]),
        .SW8(SW_OK[8]),
        .STEP(SW_OK[10]),

        // output
        .Clk_CPU(Clk_CPU),
        .clkdiv(clk_div) // clk_div[0] 50Mhz, clk_div[1] 25Mhz, clk_div[2] 12.5Mhz, ...
    );

    // connection between CPU and bus
    wire [31:0] bus2cpu;
    wire [31:0] cpu2bus;
    wire [31:0] cpu2bus_addr;
    wire cpu2bus_we;
    // connection between CPU and ROM
    wire [31:0] PC;
    wire [31:0] inst;

    SCPU U1(
        .clk(Clk_CPU),
        .rst(rst),

        // connection between CPU and bus
        .Data_in(bus2cpu),
        .Data_out(cpu2bus),
        .Addr_out(cpu2bus_addr),
        .MemRW(cpu2bus_we),
        .MIO_ready(1'b0), // unused

        // connection between CPU and ROM
        .PC_out(PC),
        .inst_in(inst)
    );

    ROM_inst U2(
        .clka(~clk_100mhz), // TODO 存储器时钟，与CPU反向

        .addra(PC[11:2]), // ROM地址PC指针，来自CPU
        .douta(inst) // ROM输出作为指令输入CPU
    );

    // connection between RAM and bus
    wire [31:0] ram2bus, bus2ram;
    wire [9:0] bus2ram_addr;
    wire bus2ram_we;
    RAM U3 (
        .clka(~clk_100mhz), // 存储器时钟，与CPU反向
        .wea(bus2ram_we), // 存储器读写，来自MIO_BUS
        .addra(bus2ram_addr), // 地址线，来自MIO_BUS
        .dina(bus2ram), // 输入数据线，来自MIO_BUS
        .douta(ram2bus) // 输出数据线，来自MIO_BUS
    );

    // TODO this takes too much responsibilities
    // master: CPU
    // slave: RAM, counter, peripheral
    wire [31:0] bus2peripheral;
    MIO_BUS U4(
        .clk(clk_100mhz), // 主板时钟
        .rst(rst), // 复位，按钮BTN3

        .BTN(BTN_OK[3:0]), // 4位原始按钮输入
        .SW(SW_OK[15:0]), // 16位原始开关输入

        // connections to CPU
        .Cpu_data2bus(cpu2bus), // CPU输出数据总线: to ram, to peripheral
        .mem_w(cpu2bus_we), // 存储器读写操作，来自CPU
        .addr_bus(cpu2bus_addr), // 地址总线，来自CPU
        .Cpu_data4bus(bus2cpu), // CPU写入数据总线，连接到CPU

        // connections to RAM
        .ram_data_out(ram2bus), // 来自RAM数据输出
        .ram_data_in(bus2ram), // RAM写入数据总线，连接到RAM
        .ram_addr(bus2ram_addr), // RAM访问地址，连接到RAM
        .data_ram_we(bus2ram_we), // RAM读写控制，连接到RAM

        // connections to counter
        .counter_out(counter2bus), // 当前通道计数输出，来自计数器外设
        .counter0_out(counter0_out), // 通道0计数结束输出，来自计数器外设
        .counter1_out(counter1_out), // 通道1计数结束输出，来自计数器外设
        .counter2_out(counter2_out), // 通道2计数结束输出，来自计数器外设
        .counter_we(bus2counter_we), // 记数器写信号，连接到U10

        // connections to peripheral
        .Peripheral_in(bus2peripheral), // 外部设备写数据总线，连接所有写设备
        .GPIOf0000000_we(bus2led_we), // 设备一LED写信号
        .GPIOe0000000_we(bus2segmux_we), // 设备二7段写信号，连接到U5

        .led_out(led_out[15:0]) // **来自**LED设备的输入（回读）
    );

    wire bus2counter_we;
    wire counter0_out, counter1_out, counter2_out;
    wire [31:0] counter2bus;
    wire [1:0] counter_channel;
    Counter_x U10(
        // input
        .clk(~Clk_CPU),
        .rst(rst),
        .clk0(clk_div[6]),
        .clk1(clk_div[9]),
        .clk2(clk_div[11]),
        .counter_we(bus2counter_we),
        .counter_ch(counter_channel),
        .counter_val(bus2peripheral),
        
        // output
        .counter0_OUT(counter0_out),
        .counter1_OUT(counter1_out),
        .counter2_OUT(counter2_out),
        .counter_out(counter2bus)
    );

    // grabbing data for driving Segment display
    wire bus2segmux_we; // 7段显示写信号
    // declare output
    wire [7:0] blink_out, point_out;
    wire [31:0] disp_num; // 闪烁信号
    Multi_8CH32 U5(
        .clk(~Clk_CPU), 
        .rst(rst),
        .EN(bus2segmux_we), //来自U4

        // selection
        .Test(SW_OK[7:5]), //来自U9

        // concated point and blink control
        .point_in({clk_div,clk_div}), // for display decimal point
        .LES(64'b0), // for LED blink

        // data input
        .Data0(bus2peripheral), // cpu2bus
        .data1({2'b00,PC[31:2]}), // PC sliced from 3rd bit
        .data2(inst), // rom to CPU instruction
        .data3(counter2bus), // counter to bus
        .data4(cpu2bus_addr), // 
        .data5(cpu2bus), // 
        .data6(bus2cpu), // 
        .data7(PC), // 

        // output
        .point_out(point_out), //输出到U6
        .LE_out(blink_out), // 输出到U6
        .Disp_num(disp_num) //输出到U6
    );

    // Segment display
    SSeg7_Dev_0 U6 (
        .scan(clk_div[18:16]),// input wire [2 : 0] scan
        .disp_num(disp_num),  // input wire [31 : 0] disp_num
        .point(point_out),    // input wire [7 : 0] point
        .les(blink_out),      // input wire [7 : 0] les
        
        // output
        .AN(AN),              // output wire [7 : 0] AN, which 
        .segment(segment)     // output wire [7 : 0] segment
    );

    // right now it only connects LED
    wire bus2led_we;
    SPIO U7(
        .clk(~Clk_CPU),
        .rst(rst),
        .EN(bus2led_we),
        .Start(clk_div[20]),
        .P_Data(bus2peripheral),

        // outputs
        .counter_set(counter_channel),
        .LED_out(led_out)
    );

    VGA U11(
        .clk_100m(clk_100mhz),
        .clk_25m(clk_div[1]),
        .rst(rst),
        
        // states of CPU
        .pc(PC),
        .inst(inst),
        .alu_res(32'b0), // not used

        // states of memory
        .mem_wen(cpu2bus_we),
        .dmem_addr(cpu2bus_addr),
        .dmem_i_data(bus2ram),
        .dmem_o_data(ram2bus),

        // outputs
        .hs(HSYNC),
        .vs(VSYNC),
        .vga_r(Red),
        .vga_g(Green),
        .vga_b(Blue)
    );

endmodule
