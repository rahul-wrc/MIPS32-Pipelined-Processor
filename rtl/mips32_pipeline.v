module mips32_pipeline (
    input wire clk,
    input wire rst,

    output wire [31:0] debug_pc,
    output wire [31:0] debug_alu_result,
    output wire [31:0] debug_writeback_data
);

    // =====================================================
    // 1. IF STAGE - INSTRUCTION FETCH
    // =====================================================

    wire [31:0] pc;
    wire [31:0] pc_plus4;
    wire [31:0] instruction;

    wire pc_stall;
    wire redirect;
    wire [31:0] redirect_addr;

    assign debug_pc = pc;

    program_counter PC (
        .clk(clk),
        .rst(rst),
        .stall(pc_stall),
        .redirect(redirect),
        .redirect_addr(redirect_addr),
        .pc(pc)
    );

    pc_adder PC_ADD (
        .pc(pc),
        .pc_plus4(pc_plus4)
    );

    instruction_memory IMEM (
        .address(pc),
        .instruction(instruction)
    );


    // =====================================================
    // 2. IF/ID PIPELINE REGISTER
    // =====================================================

    wire [31:0] if_id_pc_plus4;
    wire [31:0] if_id_instruction;
    wire if_id_valid;

    wire if_id_stall;
    wire if_id_flush;

    if_id IF_ID (
        .clk(clk),
        .rst(rst),
        .stall(if_id_stall),
        .flush(if_id_flush),
        .pc_plus4_in(pc_plus4),
        .instruction_in(instruction),
        .pc_plus4_out(if_id_pc_plus4),
        .instruction_out(if_id_instruction),
        .valid_out(if_id_valid)
    );


    // =====================================================
    // 3. ID STAGE - INSTRUCTION DECODE
    // =====================================================

    wire reg_dst;
    wire alu_src;
    wire mem_to_reg;
    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire branch_eq;
    wire branch_ne;
    wire jump;
    wire [1:0] alu_op;

    control_unit CONTROL (
        .instruction(if_id_instruction),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch_eq(branch_eq),
        .branch_ne(branch_ne),
        .jump(jump),
        .alu_op(alu_op)
    );

    wire [4:0] rs_id;
    wire [4:0] rt_id;
    wire [4:0] rd_id;
    wire [5:0] funct_id;
    wire [25:0] jump_index_id;

    assign rs_id = if_id_instruction[25:21];
    assign rt_id = if_id_instruction[20:16];
    assign rd_id = if_id_instruction[15:11];
    assign funct_id = if_id_instruction[5:0];
    assign jump_index_id = if_id_instruction[25:0];

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    wire [31:0] writeback_data;
    wire [4:0] writeback_dest;
    wire writeback_reg_write;

    register_file REG_FILE (
        .clk(clk),
        .rst(rst),
        .read_reg1(rs_id),
        .read_data1(read_data1),
        .read_reg2(rt_id),
        .read_data2(read_data2),
        .reg_write(writeback_reg_write),
        .write_reg(writeback_dest),
        .write_data(writeback_data)
    );

    wire [31:0] immediate_id;

    sign_extend SIGN_EXTEND (
        .immediate(if_id_instruction[15:0]),
        .extended(immediate_id)
    );


    // =====================================================
    // 4. HAZARD DETECTION
    // =====================================================

    wire id_ex_mem_read_out;
    wire [4:0] id_ex_rt_out;
    wire id_ex_valid_out;

    wire if_id_uses_rs;
    wire if_id_uses_rt;

    // Determine which source registers the ID instruction uses.
    // R-type, SW, BEQ and BNE use both rs and rt.
    // ADDI and LW use rs only.
    assign if_id_uses_rs =
        (if_id_instruction[31:26] == 6'b000000) ||
        (if_id_instruction[31:26] == 6'b001000) ||
        (if_id_instruction[31:26] == 6'b100011) ||
        (if_id_instruction[31:26] == 6'b101011) ||
        (if_id_instruction[31:26] == 6'b000100) ||
        (if_id_instruction[31:26] == 6'b000101);

    assign if_id_uses_rt =
        (if_id_instruction[31:26] == 6'b000000) ||
        (if_id_instruction[31:26] == 6'b101011) ||
        (if_id_instruction[31:26] == 6'b000100) ||
        (if_id_instruction[31:26] == 6'b000101);

    wire id_ex_flush;

    hazard_detection_unit HAZARD (
        .id_ex_mem_read(id_ex_mem_read_out),
        .id_ex_rt(id_ex_rt_out),
        .if_id_rs(rs_id),
        .if_id_rt(rt_id),
        .if_id_uses_rs(if_id_valid && if_id_uses_rs),
        .if_id_uses_rt(if_id_valid && if_id_uses_rt),
        .pc_stall(pc_stall),
        .if_id_stall(if_id_stall),
        .id_ex_flush(id_ex_flush)
    );


    // =====================================================
    // 5. ID/EX PIPELINE REGISTER
    // =====================================================

    wire [31:0] id_ex_pc_plus4_out;
    wire [31:0] id_ex_read_data1_out;
    wire [31:0] id_ex_read_data2_out;
    wire [31:0] id_ex_immediate_out;

    wire [4:0] id_ex_rs_out;
    wire [4:0] id_ex_rd_out;
    wire [5:0] id_ex_funct_out;
    wire [25:0] id_ex_jump_index_out;

    wire id_ex_reg_dst_out;
    wire id_ex_alu_src_out;
    wire id_ex_mem_to_reg_out;
    wire id_ex_reg_write_out;
    wire id_ex_mem_write_out;
    wire id_ex_branch_eq_out;
    wire id_ex_branch_ne_out;
    wire id_ex_jump_out;
    wire [1:0] id_ex_alu_op_out;

    id_ex ID_EX (
        .clk(clk),
        .rst(rst),
        .flush(id_ex_flush | redirect),

        .pc_plus4_in(if_id_pc_plus4),
        .read_data1_in(read_data1),
        .read_data2_in(read_data2),
        .immediate_in(immediate_id),

        .rs_in(rs_id),
        .rt_in(rt_id),
        .rd_in(rd_id),
        .funct_in(funct_id),
        .jump_index_in(jump_index_id),

        .reg_dst_in(reg_dst),
        .alu_src_in(alu_src),
        .mem_to_reg_in(mem_to_reg),
        .reg_write_in(reg_write),
        .mem_read_in(mem_read),
        .mem_write_in(mem_write),
        .branch_eq_in(branch_eq),
        .branch_ne_in(branch_ne),
        .jump_in(jump),
        .alu_op_in(alu_op),

        .valid_in(if_id_valid),

        .pc_plus4_out(id_ex_pc_plus4_out),
        .read_data1_out(id_ex_read_data1_out),
        .read_data2_out(id_ex_read_data2_out),
        .immediate_out(id_ex_immediate_out),

        .rs_out(id_ex_rs_out),
        .rt_out(id_ex_rt_out),
        .rd_out(id_ex_rd_out),
        .funct_out(id_ex_funct_out),
        .jump_index_out(id_ex_jump_index_out),

        .reg_dst_out(id_ex_reg_dst_out),
        .alu_src_out(id_ex_alu_src_out),
        .mem_to_reg_out(id_ex_mem_to_reg_out),
        .reg_write_out(id_ex_reg_write_out),
        .mem_read_out(id_ex_mem_read_out),
        .mem_write_out(id_ex_mem_write_out),
        .branch_eq_out(id_ex_branch_eq_out),
        .branch_ne_out(id_ex_branch_ne_out),
        .jump_out(id_ex_jump_out),
        .alu_op_out(id_ex_alu_op_out),

        .valid_out(id_ex_valid_out)
    );


    // =====================================================
    // 6. EX STAGE - FORWARDING
    // =====================================================

    wire [1:0] forward_a;
    wire [1:0] forward_b;

    wire [31:0] exmem_alu_result_out;
    wire [31:0] memwb_alu_result_out;
    wire [31:0] memwb_memory_data_out;

    wire [4:0] exmem_dest_reg_out;
    wire [4:0] memwb_dest_reg_out;

    wire exmem_reg_write_out;
    wire exmem_mem_to_reg_out;
    wire memwb_reg_write_out;
    wire memwb_mem_to_reg_out;
    // Declared here (before first use in the forwarding unit)
    wire exmem_valid_out;
    wire memwb_valid_out;

    forwarding_unit FORWARDING (
        .ex_rs(id_ex_rs_out),
        .ex_rt(id_ex_rt_out),

        .exmem_reg_write(exmem_valid_out && exmem_reg_write_out),
        .exmem_mem_to_reg(exmem_mem_to_reg_out),
        .exmem_dest_reg(exmem_dest_reg_out),

        .memwb_reg_write(memwb_valid_out && memwb_reg_write_out),
        .memwb_dest_reg(memwb_dest_reg_out),

        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    wire [31:0] forwarded_a;
    wire [31:0] forwarded_b;

    assign forwarded_a =
        (forward_a == 2'b10) ? exmem_alu_result_out :
        (forward_a == 2'b01) ? writeback_data :
                               id_ex_read_data1_out;

    assign forwarded_b =
        (forward_b == 2'b10) ? exmem_alu_result_out :
        (forward_b == 2'b01) ? writeback_data :
                               id_ex_read_data2_out;


    // =====================================================
    // 7. EX STAGE - ALU
    // =====================================================

    wire [4:0] ex_destination;

    destination_register DEST_REG (
        .rt(id_ex_rt_out),
        .rd(id_ex_rd_out),
        .reg_dst(id_ex_reg_dst_out),
        .destination(ex_destination)
    );

    wire [31:0] alu_operand_b;

    alu_input_mux ALU_MUX (
        .register_data(forwarded_b),
        .immediate(id_ex_immediate_out),
        .alu_src(id_ex_alu_src_out),
        .alu_operand(alu_operand_b)
    );

    wire [3:0] alu_control_signal;

    alu_control ALU_CONTROL (
        .alu_op(id_ex_alu_op_out),
        .funct(id_ex_funct_out),
        .alu_control(alu_control_signal)
    );

    wire [31:0] alu_result;
    wire alu_zero;

    alu ALU (
        .operand_a(forwarded_a),
        .operand_b(alu_operand_b),
        .alu_control(alu_control_signal),
        .result(alu_result),
        .zero(alu_zero)
    );

    assign debug_alu_result = alu_result;


    // =====================================================
    // 8. BRANCH AND JUMP
    // =====================================================

    branch_jump_unit BRANCH_JUMP (
        .pc_plus4(id_ex_pc_plus4_out),
        .immediate(id_ex_immediate_out),
        .jump_index(id_ex_jump_index_out),

        .branch_eq(id_ex_valid_out && id_ex_branch_eq_out),
        .branch_ne(id_ex_valid_out && id_ex_branch_ne_out),
        .jump(id_ex_valid_out && id_ex_jump_out),

        .zero(alu_zero),

        .redirect(redirect),
        .redirect_addr(redirect_addr)
    );

    assign if_id_flush = redirect;


    // =====================================================
    // 9. EX/MEM PIPELINE REGISTER
    // =====================================================

    wire [31:0] exmem_store_data_out;
    wire exmem_mem_read_out;
    wire exmem_mem_write_out;

    ex_mem EX_MEM (
        .clk(clk),
        .rst(rst),
        .flush(1'b0),

        .alu_result_in(alu_result),
        .store_data_in(forwarded_b),
        .dest_reg_in(ex_destination),

        .reg_write_in(id_ex_valid_out && id_ex_reg_write_out),
        .mem_read_in(id_ex_valid_out && id_ex_mem_read_out),
        .mem_write_in(id_ex_valid_out && id_ex_mem_write_out),
        .mem_to_reg_in(id_ex_mem_to_reg_out),

        .valid_in(id_ex_valid_out),

        .alu_result_out(exmem_alu_result_out),
        .store_data_out(exmem_store_data_out),
        .dest_reg_out(exmem_dest_reg_out),

        .reg_write_out(exmem_reg_write_out),
        .mem_read_out(exmem_mem_read_out),
        .mem_write_out(exmem_mem_write_out),
        .mem_to_reg_out(exmem_mem_to_reg_out),

        .valid_out(exmem_valid_out)
    );


    // =====================================================
    // 10. MEM STAGE - DATA MEMORY
    // =====================================================

    wire [31:0] memory_read_data;

    data_memory DMEM (
        .clk(clk),
        .rst(rst),
        .mem_read(exmem_valid_out && exmem_mem_read_out),
        .mem_write(exmem_valid_out && exmem_mem_write_out),
        .address(exmem_alu_result_out),
        .write_data(exmem_store_data_out),
        .read_data(memory_read_data)
    );


    // =====================================================
    // 11. MEM/WB PIPELINE REGISTER
    // =====================================================

    mem_wb MEM_WB (
        .clk(clk),
        .rst(rst),

        .alu_result_in(exmem_alu_result_out),
        .memory_data_in(memory_read_data),
        .dest_reg_in(exmem_dest_reg_out),

        .reg_write_in(exmem_valid_out && exmem_reg_write_out),
        .mem_to_reg_in(exmem_mem_to_reg_out),

        .valid_in(exmem_valid_out),

        .alu_result_out(memwb_alu_result_out),
        .memory_data_out(memwb_memory_data_out),
        .dest_reg_out(memwb_dest_reg_out),

        .reg_write_out(memwb_reg_write_out),
        .mem_to_reg_out(memwb_mem_to_reg_out),

        .valid_out(memwb_valid_out)
    );


    // =====================================================
    // 12. WB STAGE - WRITE BACK
    // =====================================================

    writeback_mux WRITEBACK (
        .alu_result(memwb_alu_result_out),
        .memory_data(memwb_memory_data_out),
        .mem_to_reg(memwb_mem_to_reg_out),
        .writeback_data(writeback_data)
    );

    assign writeback_dest = memwb_dest_reg_out;
    assign writeback_reg_write =
        memwb_valid_out && memwb_reg_write_out;

    assign debug_writeback_data = writeback_data;

endmodule