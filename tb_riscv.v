`timescale 1ns / 1ps

module tb_riscv();

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire [31:0] debug_pc;
    wire [31:0] debug_result;

    // Instantiate the System on Chip
    riscv_top uut (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_result(debug_result)
    );

    // Clock generation (100MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;

        // Hold reset for 2 clock cycles
        #20;
        reset = 0;

        // Run for 150ns to cover the entire test program
        #150;
        
        $display("Simulation Finished.");
        $stop;
    end

    // Monitor changes
    initial begin
        $monitor("Time: %0t | PC: %h | Result: %h", $time, debug_pc, debug_result);
    end

endmodule