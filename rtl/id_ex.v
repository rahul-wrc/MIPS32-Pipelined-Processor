
module id_ex (
    input wire clk,
    input wire rst,
    input wire flush,

    // Data inputs
    input wire [31:0] pc_plus4_in,
    input wire [31:0] read_data1_in,
    input wire [31:0] read_data2_in,
    input wire [31:0] immediate_in,

    // Instruction fields
    input wire [4:0] rs_in,
    input wire [4:0] rt_in,
    input wire [4:0] rd_in,
    input wire [5:0] funct_in,
    input wire [25:0] jump_index_in,

    // Control inputs
    input wire reg_dst_in,
    input wire alu_src_in,
    input wire mem_to_reg_in,
    input wire reg_write_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire branch_eq_in,
    input wire branch_ne_in,
    input wire jump_in,
    input wire [1:0] alu_op_in,

    input wire valid_in,

    // Data outputs
    output reg [31:0] pc_plus4_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] immediate_out,

    // Instruction field outputs
    output reg [4:0] rs_out,
    output reg [4:0] rt_out,
    output reg [4:0] rd_out,
    output reg [5:0] funct_out,
    output reg [25:0] jump_index_out,

    // Control outputs
    output reg reg_dst_out,
    output reg alu_src_out,
    output reg mem_to_reg_out,
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg branch_eq_out,
    output reg branch_ne_out,
    output reg jump_out,
    output reg [1:0] alu_op_out,

    output reg valid_out
);

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            pc_plus4_out    <= 32'b0;
            read_data1_out  <= 32'b0;
            read_data2_out  <= 32'b0;
            immediate_out   <= 32'b0;

            rs_out          <= 5'b0;
            rt_out          <= 5'b0;
            rd_out          <= 5'b0;
            funct_out       <= 6'b0;
            jump_index_out  <= 26'b0;

            reg_dst_out     <= 1'b0;
            alu_src_out     <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            branch_eq_out   <= 1'b0;
            branch_ne_out   <= 1'b0;
            jump_out        <= 1'b0;
            alu_op_out      <= 2'b0;

            valid_out       <= 1'b0;

        end

        // Flush inserts a bubble into the pipeline
        else if (flush) begin

            pc_plus4_out    <= 32'b0;
            read_data1_out  <= 32'b0;
            read_data2_out  <= 32'b0;
            immediate_out   <= 32'b0;

            rs_out          <= 5'b0;
            rt_out          <= 5'b0;
            rd_out          <= 5'b0;
            funct_out       <= 6'b0;
            jump_index_out  <= 26'b0;

            reg_dst_out     <= 1'b0;
            alu_src_out     <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            branch_eq_out   <= 1'b0;
            branch_ne_out   <= 1'b0;
            jump_out        <= 1'b0;
            alu_op_out      <= 2'b0;

            valid_out       <= 1'b0;

        end

        else begin

            pc_plus4_out    <= pc_plus4_in;
            read_data1_out  <= read_data1_in;
            read_data2_out  <= read_data2_in;
            immediate_out   <= immediate_in;

            rs_out          <= rs_in;
            rt_out          <= rt_in;
            rd_out          <= rd_in;
            funct_out       <= funct_in;
            jump_index_out  <= jump_index_in;

            reg_dst_out     <= reg_dst_in;
            alu_src_out     <= alu_src_in;
            mem_to_reg_out  <= mem_to_reg_in;
            reg_write_out   <= reg_write_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            branch_eq_out   <= branch_eq_in;
            branch_ne_out   <= branch_ne_in;
            jump_out        <= jump_in;
            alu_op_out      <= alu_op_in;

            valid_out       <= valid_in;

        end

    end

endmodule
