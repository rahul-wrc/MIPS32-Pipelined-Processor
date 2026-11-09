
module control_unit (
    input  wire [31:0] instruction,

    output reg         reg_dst,
    output reg         alu_src,
    output reg         mem_to_reg,
    output reg         reg_write,
    output reg         mem_read,
    output reg         mem_write,
    output reg         branch_eq,
    output reg         branch_ne,
    output reg         jump,
    output reg  [1:0]  alu_op
);

    wire [5:0] opcode;
    wire [5:0] funct;

    assign opcode = instruction[31:26];
    assign funct  = instruction[5:0];

    always @(*) begin

        // Safe default values
        reg_dst    = 1'b0;
        alu_src    = 1'b0;
        mem_to_reg = 1'b0;
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch_eq  = 1'b0;
        branch_ne  = 1'b0;
        jump       = 1'b0;
        alu_op     = 2'b00;

        case (opcode)

            // R-type instructions
            6'b000000: begin
                case (funct)

                    6'b100000, // ADD
                    6'b100010, // SUB
                    6'b100100, // AND
                    6'b100101, // OR
                    6'b100110, // XOR
                    6'b101010: begin // SLT

                        reg_dst   = 1'b1;
                        reg_write = 1'b1;
                        alu_op    = 2'b10;

                    end

                    default: begin
                        // Unsupported R-type instruction
                    end

                endcase
            end

            // ADDI
            6'b001000: begin
                alu_src   = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b00;
            end

            // LW
            6'b100011: begin
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_op     = 2'b00;
            end

            // SW
            6'b101011: begin
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_op    = 2'b00;
            end

            // BEQ
            6'b000100: begin
                branch_eq = 1'b1;
                alu_op    = 2'b01;
            end

            // BNE
            6'b000101: begin
                branch_ne = 1'b1;
                alu_op    = 2'b01;
            end

            // J
            6'b000010: begin
                jump = 1'b1;
            end

            default: begin
                // Unsupported instruction: no operation
            end

        endcase

    end

endmodule
