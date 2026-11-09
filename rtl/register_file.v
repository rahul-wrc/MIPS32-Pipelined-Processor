// 32 x 32 register file, synthesizable (no inferred memory).
// Behaviour identical to the verified version:
//   - async active-high reset clears all registers
//   - x0 is hard-wired to zero (no flops are built for it)
//   - asynchronous reads with write-through bypass
// Each register is an explicit flop bank so Yosys maps it directly to
// SKY130 flip-flops (async-reset memories are not reliably inferred).
module register_file (
    input  wire        clk,
    input  wire        rst,

    // Read port 1
    input  wire [4:0]  read_reg1,
    output wire [31:0] read_data1,

    // Read port 2
    input  wire [4:0]  read_reg2,
    output wire [31:0] read_data2,

    // Write port
    input  wire        reg_write,
    input  wire [4:0]  write_reg,
    input  wire [31:0] write_data
);

    // Flattened view of all registers: register n = registers_flat[n*32 +: 32]
    wire [1023:0] registers_flat;

    assign registers_flat[31:0] = 32'b0;           // x0 = 0

    genvar g;
    generate
        for (g = 1; g < 32; g = g + 1) begin : REG
            reg [31:0] q;

            always @(posedge clk or posedge rst) begin
                if (rst)
                    q <= 32'b0;
                else if (reg_write && (write_reg == g[4:0]))
                    q <= write_data;
            end

            assign registers_flat[g*32 +: 32] = q;
        end
    endgenerate

    // Asynchronous read with write-through bypass
    assign read_data1 =
        (read_reg1 == 5'd0) ? 32'b0 :
        (reg_write && (write_reg == read_reg1)) ?
        write_data : registers_flat[read_reg1*32 +: 32];

    assign read_data2 =
        (read_reg2 == 5'd0) ? 32'b0 :
        (reg_write && (write_reg == read_reg2)) ?
        write_data : registers_flat[read_reg2*32 +: 32];

endmodule
