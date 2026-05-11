module riscv_processor(
    input clk,
    input reset,
    input [31:0] instr,
    output [31:0] final_result,
    output [31:0] pc_out
);
    // Instruction decode
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];

    // Control signals
    wire is_rtype  = (opcode == 7'b0110011);
    wire is_load   = (opcode == 7'b0000011);
    wire is_arith  = (opcode == 7'b0010011);
    wire is_jalr   = (opcode == 7'b1100111);
    wire is_branch = (opcode == 7'b1100011);

    // I-type sign-extended immediate (used by I-type: ALU and JALR)
    wire [31:0] imm_ext = {{20{instr[31]}}, instr[31:20]};

    // SB-type branch immediate — different bit layout to I-type!
    // imm[12]=instr[31], imm[11]=instr[7],
    // imm[10:5]=instr[30:25], imm[4:1]=instr[11:8], imm[0]=0
    wire [31:0] br_imm = {{20{instr[31]}},
                           instr[7],
                           instr[30:25],
                           instr[11:8],
                           1'b0};

    // ALU source B: register for R-type, immediate for everything else
    wire [31:0] src_b_data;
    wire [31:0] alu_input_b = is_rtype ? src_b_data : imm_ext;

    // Register write: R-type, I-arith, load, jalr all write rd
    // Branches do NOT write a register
    wire reg_write_en = is_rtype | is_arith | is_load | is_jalr;

    wire [31:0] alu_result;
    wire [31:0] src_a_data;
    wire [31:0] mem_read_data;

    // Load data sign/zero extension
    reg [31:0] processed_load_data;
    always @(*) begin
        case(funct3)
            3'b000: processed_load_data = {{24{mem_read_data[7]}},  mem_read_data[7:0]};  // lb
            3'b001: processed_load_data = {{16{mem_read_data[15]}}, mem_read_data[15:0]}; // lh
            3'b010: processed_load_data = mem_read_data;                                  // lw
            3'b100: processed_load_data = {24'b0, mem_read_data[7:0]};                    // lbu
            3'b101: processed_load_data = {16'b0, mem_read_data[15:0]};                   // lhu
            default: processed_load_data = mem_read_data;
        endcase
    end

    // Branch condition
    reg take_branch;
    always @(*) begin
        case(funct3)
            3'b000: take_branch = (src_a_data == src_b_data);                              // beq
            3'b001: take_branch = (src_a_data != src_b_data);                              // bne
            3'b100: take_branch = ($signed(src_a_data) <  $signed(src_b_data));            // blt
            3'b101: take_branch = ($signed(src_a_data) >= $signed(src_b_data));            // bge
            3'b110: take_branch = (src_a_data <  src_b_data);                              // bltu ← ADDED
            3'b111: take_branch = (src_a_data >= src_b_data);                              // bgeu ← ADDED
            default: take_branch = 1'b0;
        endcase
    end

    // PC logic
    reg  [31:0] pc_reg;
    wire [31:0] pc_plus_4  = pc_reg + 4;
    wire [31:0] pc_target  = pc_reg + br_imm;  // ← FIX: was imm_ext

    wire [31:0] pc_next = is_jalr                    ? {alu_result[31:1], 1'b0} :
                          (is_branch & take_branch)  ? pc_target               :
                                                       pc_plus_4;

    always @(posedge clk) begin
        if (reset) pc_reg <= 32'h0;
        else       pc_reg <= pc_next;
    end

    // Result written to rd
    assign final_result = is_jalr ? pc_plus_4          :
                          is_load ? processed_load_data :
                                    alu_result;
    
    // Assign pc_out to pc for checking in tb
    assign pc_out = pc_reg;

    register_file reg_unit (
        .clk(clk),
        .reg_write(reg_write_en),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .write_data(final_result),
        .read_data1(src_a_data),
        .read_data2(src_b_data)
    );

    alu alu_unit (
        .a(src_a_data),
        .b(alu_input_b),
        .funct3(funct3),
        .sub_bit(instr[30]),
        .result(alu_result)
    );

    data_memory mem_unit (
        .clk(clk),
        .addr(alu_result),
        .read_data(mem_read_data)
    );

endmodule