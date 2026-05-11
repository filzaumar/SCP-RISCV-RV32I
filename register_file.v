///////////////////////////////////////////////////
//                    Register file
// stores data, initialized with dummy values for testing
/////////////////////////////////////////////////////

module register_file(
    input clk,
    input reg_write,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] rf [31:0];

    // Initialize x0 to 0 and others for simulation check
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) rf[i] = i; // x1=1, x2=2, etc.
        rf[0] = 32'h0; 
    end

    assign read_data1 = rf[rs1];
    assign read_data2 = rf[rs2]; 
    
    always @(posedge clk) begin
        if (reg_write && rd != 0) begin
            rf[rd] <= write_data;
        end
    end
endmodule