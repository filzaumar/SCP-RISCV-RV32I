module riscv_top(
    input clk,
    input reset,
    output [31:0] debug_pc,     // 
    output [31:0] debug_result 
);
    wire [31:0] current_instr;
    wire [31:0] current_pc;

    assign debug_pc = current_pc;

    // Instantiate Instruction Memory
    instruction_memory imem (
        .addr(current_pc),
        .instr(current_instr)
    );

    // Instantiate Processor
    riscv_processor cpu (
        .clk(clk),
        .reset(reset),
        .instr(current_instr),
        .pc_out(current_pc),    // Connection made here
        .final_result(debug_result)
    );
endmodule