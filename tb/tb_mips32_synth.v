`timescale 1ns / 1ps

module tb_mips32_pipeline;

    reg clk;
    reg rst;

    wire [31:0] debug_pc;
    wire [31:0] debug_alu_result;
    wire [31:0] debug_writeback_data;

    integer pass_count;
    integer fail_count;
    integer stall_count;
    integer i;

    mips32_pipeline DUT (
        .clk(clk),
        .rst(rst),
        .debug_pc(debug_pc),
        .debug_alu_result(debug_alu_result),
        .debug_writeback_data(debug_writeback_data)
    );

    always #5 clk = ~clk;


    // ============================================================
    // CHECK REGISTER
    // ============================================================

    task check_register;
        input [4:0] reg_num;
        input [31:0] expected;
        input [160*8-1:0] test_name;

        begin
            if (DUT.REG_FILE.registers_flat[reg_num*32 +: 32] === expected) begin
                $display("PASS: %0s", test_name);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: %0s | Expected=%h Actual=%h",
                         test_name,
                         expected,
                         DUT.REG_FILE.registers_flat[reg_num*32 +: 32]);
                fail_count = fail_count + 1;
            end
        end
    endtask


    // ============================================================
    // CHECK MEMORY
    // ============================================================

    task check_memory;
        input [7:0] address;
        input [31:0] expected;
        input [160*8-1:0] test_name;

        begin
            if (DUT.DMEM.memory_flat[address*32 +: 32] === expected) begin
                $display("PASS: %0s", test_name);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: %0s | Expected=%h Actual=%h",
                         test_name,
                         expected,
                         DUT.DMEM.memory_flat[address*32 +: 32]);
                fail_count = fail_count + 1;
            end
        end
    endtask


    // ============================================================
    // PREPARE TEST
    // ============================================================

    task prepare_test;
        begin
            rst = 1'b1;

            #1;

            for (i = 0; i < 256; i = i + 1) begin
            end

            repeat (2) @(posedge clk);

            #1 rst = 1'b0;
        end
    endtask


    // ============================================================
    // COUNT LOAD-USE STALLS
    // ============================================================

    always @(posedge clk) begin
        if (!rst && DUT.pc_stall)
            stall_count = stall_count + 1;
    end


    // ============================================================
    // MAIN
    // ============================================================

    initial begin

        clk = 0;
        rst = 1;

        pass_count = 0;
        fail_count = 0;
        stall_count = 0;


        // ========================================================
        // FINAL INTEGRATION TEST
        // ========================================================

        $display("");
        $display("====================================================");
        $display("       MIPS32 FINAL INTEGRATION TEST");
        $display("====================================================");


        prepare_test();


        // --------------------------------------------------------
        // PROGRAM
        // --------------------------------------------------------
        //
        // 0:  ADDI t0, zero, 10
        // 1:  ADDI t1, zero, 20
        //
        // 2:  ADD  t2, t0, t1
        //     Tests forwarding.
        //
        // 3:  SW   t2, 0(zero)
        //     Tests store-data forwarding.
        //
        // 4:  LW   t3, 0(zero)
        //
        // 5:  ADD  t4, t3, t2
        //     Immediate load-use dependency.
        //     Requires one stall.
        //
        // 6:  ADDI t5, t4, 5
        //     Forwarding from previous result.
        //
        // 7:  BEQ  t5, t4, 2
        //     NOT taken because t5 != t4.
        //
        // 8:  ADDI t6, zero, 100
        //     Must execute.
        //
        // 9:  ADDI t7, zero, 200
        //
        // 10: BNE  t6, t7, 2
        //     Taken.
        //
        // 11: ADDI s0, zero, 111
        //     Must be flushed.
        //
        // 12: ADDI s1, zero, 222
        //     Must be flushed.
        //
        // 13: ADDI s2, zero, 77
        //     Branch target.
        //
        // 14: J 18
        //
        // 15: ADDI s3, zero, 333
        //     Must be flushed.
        //
        // 16: ADDI s4, zero, 444
        //     Must be flushed.
        //
        // 17: ADDI s5, zero, 555
        //     Must be flushed.
        //
        // 18: ADDI s6, zero, 999
        //     Jump target.
        //
        // --------------------------------------------------------


        // ADDI t0, zero, 10

        // ADDI t1, zero, 20

        // ADD t2, t0, t1

        // SW t2, 0(zero)

        // LW t3, 0(zero)

        // ADD t4, t3, t2

        // ADDI t5, t4, 5

        // BEQ t5, t4, 2

        // ADDI t6, zero, 100

        // ADDI t7, zero, 200

        // BNE t6, t7, 2

        // ADDI s0, zero, 111

        // ADDI s1, zero, 222

        // ADDI s2, zero, 77

        // J 18

        // ADDI s3, zero, 333

        // ADDI s4, zero, 444

        // ADDI s5, zero, 555

        // ADDI s6, zero, 999


        // Allow complete program to execute.
        repeat (45) @(posedge clk);

        #2;


        // ========================================================
        // CHECK RESULTS
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("ARITHMETIC / FORWARDING");
        $display("--------------------------------------------");

        check_register(
            5'd8,
            32'd10,
            "F1: t0 = 10"
        );

        check_register(
            5'd9,
            32'd20,
            "F1: t1 = 20"
        );

        check_register(
            5'd10,
            32'd30,
            "F1: t2 = t0 + t1 = 30"
        );


        // ========================================================
        // MEMORY
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("MEMORY");
        $display("--------------------------------------------");

        check_memory(
            8'd0,
            32'd30,
            "F2: memory[0] = 30"
        );

        check_register(
            5'd11,
            32'd30,
            "F2: t3 loaded = 30"
        );


        // ========================================================
        // LOAD-USE + FORWARDING
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("LOAD-USE HAZARD + FORWARDING");
        $display("--------------------------------------------");

        check_register(
            5'd12,
            32'd60,
            "F3: t4 = t3 + t2 = 60"
        );

        check_register(
            5'd13,
            32'd65,
            "F3: t5 = t4 + 5 = 65"
        );

        if (stall_count == 1) begin
            $display("PASS: F3: exactly one load-use stall");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: F3: expected 1 stall, actual=%0d",
                     stall_count);
            fail_count = fail_count + 1;
        end


        // ========================================================
        // NOT-TAKEN BRANCH
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("BRANCH NOT TAKEN");
        $display("--------------------------------------------");

        check_register(
            5'd14,
            32'd100,
            "F4: t6 = 100"
        );

        check_register(
            5'd15,
            32'd200,
            "F4: t7 = 200"
        );


        // ========================================================
        // TAKEN BNE + FLUSH
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("BNE TAKEN + PIPELINE FLUSH");
        $display("--------------------------------------------");

        check_register(
            5'd18,
            32'd77,
            "F5: s2 branch target = 77"
        );

        check_register(
            5'd16,
            32'd0,
            "F5: s0 flushed"
        );

        check_register(
            5'd17,
            32'd0,
            "F5: s1 flushed"
        );


        // ========================================================
        // JUMP + FLUSH
        // ========================================================

        $display("");
        $display("--------------------------------------------");
        $display("JUMP + PIPELINE FLUSH");
        $display("--------------------------------------------");

        check_register(
            5'd19,
            32'd0,
            "F6: s3 jump-flushed"
        );

        check_register(
            5'd20,
            32'd0,
            "F6: s4 jump-flushed"
        );

        check_register(
            5'd21,
            32'd0,
            "F6: s5 jump-flushed"
        );

        check_register(
            5'd22,
            32'd999,
            "F6: s6 jump target = 999"
        );


        // ========================================================
        // FINAL SUMMARY
        // ========================================================

        $display("");
        $display("====================================================");
        $display("       FINAL INTEGRATION TEST SUMMARY");
        $display("====================================================");

        $display("TOTAL PASS : %0d", pass_count);
        $display("TOTAL FAIL : %0d", fail_count);
        $display("STALL COUNT: %0d", stall_count);

        $display("");

        if (fail_count == 0)
            $display("FINAL RESULT: ALL INTEGRATION TESTS PASSED");
        else
            $display("FINAL RESULT: INTEGRATION TEST FAILED");

        $display("====================================================");

        $finish;

    end

endmodule