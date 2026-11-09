module alu_input_mux (
    input wire [31:0] register_data,
    input wire [31:0] immediate,
    input wire alu_src,
    output wire [31:0] alu_operand
);

    assign alu_operand = alu_src ? immediate : register_data;

endmodule
