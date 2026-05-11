//////////////////////////////////////////////////////////
//                      ALU unit                       ///
// take 32 bit inputs, do and or xor  sub shift with   ///
//immediate or reg value --> output                    ///
//////////////////////////////////////////////////////////

module alu(
    input [31:0] a,
    input [31:0] b,
    input [2:0] funct3,
    input sub_bit, // instr[30] : 1. add/sub  2. to distinguish SRLI from SRAI (funct7 bit 10), lower 5 bit is shamt
    output reg [31:0] result
);
    always @(*) begin
        case(funct3)
            3'b000: result = sub_bit ? (a - b) : (a + b); // ADD / SUB
            3'b001: result = a << b[4:0];                // SLL / SLLI
            3'b010: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT
            3'b011: result = (a < b) ? 32'b1 : 32'b0;    // SLTU
            3'b100: result = a ^ b;                      // XOR / XORI
            3'b101: result = sub_bit ? ($signed(a) >>> b[4:0]) : (a >> b[4:0]); // SRL/SRA
            3'b110: result = a | b;                      // OR / ORI
            3'b111: result = a & b;                      // AND / ANDI
            default: result = 32'b0;
        endcase
    end
endmodule