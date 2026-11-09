module destination_register (
    input wire [4:0] rt,
    input wire [4:0] rd,
    input wire reg_dst,
    output wire [4:0] destination
);

    assign destination = reg_dst ? rd : rt;

endmodule