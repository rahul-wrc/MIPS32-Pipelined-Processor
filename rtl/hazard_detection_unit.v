module hazard_detection_unit (
    input wire id_ex_mem_read,
    input wire [4:0] id_ex_rt,

    input wire [4:0] if_id_rs,
    input wire [4:0] if_id_rt,

    input wire if_id_uses_rs,
    input wire if_id_uses_rt,

    output reg pc_stall,
    output reg if_id_stall,
    output reg id_ex_flush
);

    always @(*) begin

        // Default: normal pipeline operation
        pc_stall   = 1'b0;
        if_id_stall = 1'b0;
        id_ex_flush = 1'b0;

        // Detect load-use hazard
        if (id_ex_mem_read &&
            (id_ex_rt != 5'd0) &&
            ((if_id_uses_rs && (id_ex_rt == if_id_rs)) ||
             (if_id_uses_rt && (id_ex_rt == if_id_rt)))) begin

            pc_stall    = 1'b1;
            if_id_stall = 1'b1;
            id_ex_flush = 1'b1;

        end

    end

endmodule