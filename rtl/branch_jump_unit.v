module branch_jump_unit (
    input wire [31:0] pc_plus4,
    input wire [31:0] immediate,
    input wire [25:0] jump_index,

    input wire branch_eq,
    input wire branch_ne,
    input wire jump,

    input wire zero,

    output wire redirect,
    output reg [31:0] redirect_addr
);

    wire branch_taken;

    assign branch_taken =
        (branch_eq && zero) ||
        (branch_ne && !zero);

    assign redirect = branch_taken || jump;

    always @(*) begin

        if (jump) begin
            redirect_addr = {
                pc_plus4[31:28],
                jump_index,
                2'b00
            };
        end

        else if (branch_taken) begin
            redirect_addr = pc_plus4 + (immediate << 2);
        end

        else begin
            redirect_addr = pc_plus4;
        end

    end

endmodule