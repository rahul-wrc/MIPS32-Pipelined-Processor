
module if_id (
    input  wire        clk,
    input  wire        rst,

    input  wire        stall,
    input  wire        flush,

    input  wire [31:0] pc_plus4_in,
    input  wire [31:0] instruction_in,

    output reg  [31:0] pc_plus4_out,
    output reg  [31:0] instruction_out,
    output reg         valid_out
);

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            pc_plus4_out   <= 32'b0;
            instruction_out <= 32'b0;
            valid_out       <= 1'b0;
        end

        // Flush has priority over stall
        else if (flush) begin
            pc_plus4_out   <= 32'b0;
            instruction_out <= 32'b0;
            valid_out       <= 1'b0;
        end

        // Hold current values during a stall
        else if (stall) begin
            pc_plus4_out   <= pc_plus4_out;
            instruction_out <= instruction_out;
            valid_out       <= valid_out;
        end

        // Capture new instruction
        else begin
            pc_plus4_out   <= pc_plus4_in;
            instruction_out <= instruction_in;
            valid_out       <= 1'b1;
        end

    end

endmodule
