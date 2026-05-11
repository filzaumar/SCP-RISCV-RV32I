///////////////////////////////////////////////////////
//////              Data memory.v                  ////
////// ram block for storing data in simulation     ////
///////////////////////////////////////////////////////

module data_memory(
    input clk,
    input [31:0] addr,
    output [31:0] read_data
);
    reg [31:0] memory [63:0]; // 64 words of memory (32x64)
    
    initial begin
        memory[0] = 32'h11223344;
        memory[1] = 32'h55667788;
        memory[2] = 32'h99AABBCC;
    end

    // Use bits [7:2] for word alignment in a small 64-word array
    assign read_data = memory[addr[7:2]];
endmodule
