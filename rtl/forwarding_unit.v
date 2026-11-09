module forwarding_unit (
    input wire [4:0] ex_rs,
    input wire [4:0] ex_rt,

    input wire exmem_reg_write,
    input wire exmem_mem_to_reg,
    input wire [4:0] exmem_dest_reg,

    input wire memwb_reg_write,
    input wire [4:0] memwb_dest_reg,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    always @(*) begin

        // Default: use register values from ID/EX
        forward_a = 2'b00;
        forward_b = 2'b00;

        // Forward operand A
        if (exmem_reg_write &&
            !exmem_mem_to_reg &&
            (exmem_dest_reg != 5'd0) &&
            (exmem_dest_reg == ex_rs))
            forward_a = 2'b10;

        else if (memwb_reg_write &&
                 (memwb_dest_reg != 5'd0) &&
                 (memwb_dest_reg == ex_rs))
            forward_a = 2'b01;


        // Forward operand B
        if (exmem_reg_write &&
            !exmem_mem_to_reg &&
            (exmem_dest_reg != 5'd0) &&
            (exmem_dest_reg == ex_rt))
            forward_b = 2'b10;

        else if (memwb_reg_write &&
                 (memwb_dest_reg != 5'd0) &&
                 (memwb_dest_reg == ex_rt))
            forward_b = 2'b01;

    end

endmodule