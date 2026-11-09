
module program_counter (
    input  wire        clk,
    input  wire        rst,
    input  wire        stall,
    input  wire        redirect,
    input  wire [31:0] redirect_addr,

    output reg  [31:0] pc
);

    always @(posedge clk or posedge rst) begin

        if (rst) begin
            pc <= 32'h00000000;
        end

        // Branch or jump has priority over stall
        else if (redirect) begin
            pc <= redirect_addr;
        end

        // Hold PC during pipeline stall
        else if (stall) begin
            pc <= pc;
        end

        // Normal execution
        else begin
            pc <= pc + 32'd4;
        end

    end

endmodule
