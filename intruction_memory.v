module instruction_memory(
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] rom [0:31]; //  instructions 

    initial begin
        // Use a hex file to load your program
        $readmemh("program.hex", rom); 
    end

    // Instruction address is PC >> 2 to convert byte address to word index
    assign instr = rom[addr[31:2]]; 
endmodule