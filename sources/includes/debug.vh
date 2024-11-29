`define assert(signal, value) \
    if (signal !== value) begin \
        $display("ASSERTION FAILED in %m: signal (%0d) != value (%0d)", signal, value); \
        $finish; \
    end