// Word-addressed data memory, synthesizable (flop based, no inferred RAM).
// Behaviour identical to the verified version (default ADDR_BITS = 8):
//   - 2^ADDR_BITS words x 32 bits, async reset clears every word
//   - word-aligned accesses only (address[1:0] == 0)
//   - synchronous write, asynchronous read (0 when mem_read is low)
//
// AREA NOTE: 256 words = 8192 flops + a 256:1 read mux (roughly 0.3-0.4 mm2
// in SKY130 HD). If your programs only touch the low addresses, set
// ADDR_BITS = 6 (64 words) to shrink this ~4x. Addresses then wrap.
module data_memory #(
    parameter ADDR_BITS = 8
) (
    input  wire        clk,
    input  wire        rst,

    input  wire        mem_read,
    input  wire        mem_write,

    input  wire [31:0] address,
    input  wire [31:0] write_data,

    output wire [31:0] read_data
);

    localparam DEPTH = (1 << ADDR_BITS);

    // Flattened view: word n = memory_flat[n*32 +: 32]
    wire [DEPTH*32-1:0] memory_flat;

    wire                 word_aligned = (address[1:0] == 2'b00);
    wire [ADDR_BITS-1:0] word_index   = address[ADDR_BITS+1:2];

    genvar w;
    generate
        for (w = 0; w < DEPTH; w = w + 1) begin : WORD
            reg [31:0] q;

            always @(posedge clk or posedge rst) begin
                if (rst)
                    q <= 32'b0;
                else if (mem_write && word_aligned && (word_index == w))
                    q <= write_data;
            end

            assign memory_flat[w*32 +: 32] = q;
        end
    endgenerate

    // Asynchronous read
    assign read_data =
        (mem_read && word_aligned)
        ? memory_flat[word_index*32 +: 32]
        : 32'b0;

endmodule
