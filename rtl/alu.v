
module alu (
    input  wire [31:0] operand_a,
    input  wire [31:0] operand_b,
    input  wire [3:0]  alu_control,

    output reg  [31:0] result,
    output wire        zero
);

    always @(*) begin

        case (alu_control)

            // AND
            4'b0000: result = operand_a & operand_b;

            // OR
            4'b0001: result = operand_a | operand_b;

            // ADD
            4'b0010: result = operand_a + operand_b;

            // XOR
            4'b0011: result = operand_a ^ operand_b;

            // SUB
            4'b0110: result = operand_a - operand_b;

            // SLT (signed comparison)
            4'b0111: begin
                if ($signed(operand_a) < $signed(operand_b))
                    result = 32'd1;
                else
                    result = 32'd0;
            end

            // Invalid operation
            default: result = 32'b0;

        endcase

    end

    // Asserted when the result is zero
    assign zero = (result == 32'b0);

endmodule
