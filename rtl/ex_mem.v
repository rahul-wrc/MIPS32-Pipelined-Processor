
module ex_mem (
    input wire clk,
    input wire rst,
    input wire flush,

    // Data inputs
    input wire [31:0] alu_result_in,
    input wire [31:0] store_data_in,
    input wire [4:0]  dest_reg_in,

    // Control inputs
    input wire reg_write_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_to_reg_in,

    input wire valid_in,

    // Data outputs
    output reg [31:0] alu_result_out,
    output reg [31:0] store_data_out,
    output reg [4:0]  dest_reg_out,

    // Control outputs
    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,

    output reg valid_out
);

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            alu_result_out <= 32'b0;
            store_data_out <= 32'b0;
            dest_reg_out   <= 5'b0;

            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;

            valid_out      <= 1'b0;

        end

        else if (flush) begin

            alu_result_out <= 32'b0;
            store_data_out <= 32'b0;
            dest_reg_out   <= 5'b0;

            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;

            valid_out      <= 1'b0;

        end

        else begin

            alu_result_out <= alu_result_in;
            store_data_out <= store_data_in;
            dest_reg_out   <= dest_reg_in;

            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;

            valid_out      <= valid_in;

        end

    end

endmodule
