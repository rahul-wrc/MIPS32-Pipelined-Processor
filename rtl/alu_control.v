
module alu_control (
    input  wire [1:0] alu_op,
    input  wire [5:0] funct,

    output reg  [3:0] alu_control
);

    always @(*) begin

        case (alu_op)

            // ADD: ADDI, LW, SW
            2'b00: begin
                alu_control = 4'b0010;
            end

            // SUB: BEQ, BNE
            2'b01: begin
                alu_control = 4'b0110;
            end

            // R-type instructions
            2'b10: begin

                case (funct)

                    6'b100000: alu_control = 4'b0010; // ADD
                    6'b100010: alu_control = 4'b0110; // SUB
                    6'b100100: alu_control = 4'b0000; // AND
                    6'b100101: alu_control = 4'b0001; // OR
                    6'b100110: alu_control = 4'b0011; // XOR
                    6'b101010: alu_control = 4'b0111; // SLT

                    default: alu_control = 4'b1111;

                endcase

            end

            default: begin
                alu_control = 4'b1111;
            end

        endcase

    end

endmodule
