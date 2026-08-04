//==============================================================================
// Project      : RISCV64 Processor
// Module       : Execute Stage Testbench
// File         : tb_execute_stage.sv
//
// Description  :
//   Self-checking testbench for execute_stage.
//==============================================================================

`timescale 1ns/1ps

module tb_execute_stage;

    import riscv_pkg::*;
    import riscv_alu_pkg::*;

    //==========================================================================
    // Testbench Signals
    //==========================================================================

    xlen_t   rs1_data_i;
    xlen_t   rs2_data_i;
    xlen_t   imm_i;
    xlen_t   pc_i;

    logic    alu_src_i;
    alu_op_t alu_op_i;
    funct3_t funct3_i;

    xlen_t   alu_result_o;
    logic    branch_taken_o;
    xlen_t   branch_target_o;
    xlen_t   jalr_target_o;

    //==========================================================================
    // DUT
    //==========================================================================

    execute_stage dut (

        .rs1_data_i      (rs1_data_i),
        .rs2_data_i      (rs2_data_i),
        .imm_i           (imm_i),
        .pc_i            (pc_i),

        .alu_src_i       (alu_src_i),
        .alu_op_i        (alu_op_i),
        .funct3_i        (funct3_i),

        .alu_result_o    (alu_result_o),
        .branch_taken_o  (branch_taken_o),
        .branch_target_o (branch_target_o),
        .jalr_target_o   (jalr_target_o)

    );

    //==========================================================================
    // Test Task
    //==========================================================================

    task automatic run_test(

        input string   test_name,

        input xlen_t   rs1,
        input xlen_t   rs2,
        input xlen_t   imm,
        input xlen_t   pc,

        input logic    alu_src,
        input alu_op_t alu_op,
        input funct3_t funct3,

        input xlen_t   exp_alu,
        input logic    exp_branch,
        input xlen_t   exp_branch_target,
        input xlen_t   exp_jalr_target

    );

    begin

        rs1_data_i = rs1;
        rs2_data_i = rs2;
        imm_i      = imm;
        pc_i       = pc;

        alu_src_i  = alu_src;
        alu_op_i   = alu_op;
        funct3_i   = funct3;

        #1;

        if ((alu_result_o    !== exp_alu)           ||
            (branch_taken_o  !== exp_branch)        ||
            (branch_target_o !== exp_branch_target) ||
            (jalr_target_o   !== exp_jalr_target)) begin

            $display("");
            $display("====================================================");
            $display("TEST FAILED : %s", test_name);
            $display("----------------------------------------------------");

            $display("Expected ALU Result      : %h", exp_alu);
            $display("Received ALU Result      : %h", alu_result_o);

            $display("Expected Branch Taken    : %b", exp_branch);
            $display("Received Branch Taken    : %b", branch_taken_o);

            $display("Expected Branch Target   : %h", exp_branch_target);
            $display("Received Branch Target   : %h", branch_target_o);

            $display("Expected JALR Target     : %h", exp_jalr_target);
            $display("Received JALR Target     : %h", jalr_target_o);

            $display("====================================================");

            $finish;

        end
        else begin

            $display("PASS : %s", test_name);

        end

    end

    endtask

    //==========================================================================
    // Test Sequence
    //==========================================================================

    initial begin

        $dumpfile("../waves/tb_execute_stage.vcd");
        $dumpvars(0, tb_execute_stage);
        //----------------------------------------------------------------------
        // Test 1 : Register + Register ADD
        //----------------------------------------------------------------------

        run_test(

            "ADD Register",

            64'd20,
            64'd10,
            64'd4,
            64'h80000000,

            1'b0,
            ALU_ADD,
            3'b000,

            64'd30,
            1'b0,
            64'h80000004,
            64'd24

        );

        //----------------------------------------------------------------------
        // Test 2 : Register + Immediate ADDI
        //----------------------------------------------------------------------

        run_test(

            "ADDI",

            64'd100,
            64'd999,
            64'd20,
            64'h80000100,

            1'b1,
            ALU_ADD,
            3'b000,

            64'd120,
            1'b0,
            64'h80000114,
            64'd120

        );

        //----------------------------------------------------------------------
        // Test 3 : BEQ Taken
        //----------------------------------------------------------------------

        run_test(

            "BEQ Taken",

            64'd55,
            64'd55,
            64'd16,
            64'h80001000,

            1'b0,
            ALU_SUB,
            3'b000,

            64'd0,
            1'b1,
            64'h80001010,
            64'd70

        );

        //----------------------------------------------------------------------
        // Test 4 : BLT Signed
        //----------------------------------------------------------------------

        run_test(

            "BLT Signed",

            -64'sd5,
             64'sd3,
             64'd8,
             64'h80002000,

             1'b0,
             ALU_ADD,
             3'b100,

             -64'sd2,
             1'b1,
             64'h80002008,
             64'h0000000000000002

        );

        //----------------------------------------------------------------------
        // Test 5 : JALR Alignment
        //----------------------------------------------------------------------

        run_test(

            "JALR Alignment",

            64'h80000005,
            64'd0,
            64'd8,
            64'h80003000,

            1'b1,
            ALU_ADD,
            3'b001,

            64'h8000000D,
            1'b1,
            64'h80003008,
            64'h8000000C

        );
        //----------------------------------------------------------------------
        // Test 6 : MUL
        //----------------------------------------------------------------------

        run_test(

            "MUL",

            64'd24,
            64'd5,
            64'd0,
            64'h80004000,

            1'b0,
            ALU_MUL,
            3'b000,

            64'd120,
            1'b0,
            64'h80004000,
            64'd24

        );

        //----------------------------------------------------------------------
        // Test 7 : MULH
        //----------------------------------------------------------------------

        run_test(

            "MULH",

            -64'sd2,
             64'd3,
             64'd0,
             64'h80005000,

             1'b0,
             ALU_MULH,
             3'b000,

             64'hFFFFFFFFFFFFFFFF,
             1'b0,
             64'h80005000,
             64'hFFFFFFFFFFFFFFFE

        );

        //----------------------------------------------------------------------
        // Test 8 : DIV
        //----------------------------------------------------------------------

        run_test(

            "DIV",

            64'd20,
            64'd5,
            64'd0,
            64'h80006000,

            1'b0,
            ALU_DIV,
            3'b000,

            64'd4,
            1'b0,
            64'h80006000,
            64'd20

        );

        //----------------------------------------------------------------------
        // Test 9 : REM
        //----------------------------------------------------------------------

        run_test(

            "REM",

            64'd22,
            64'd5,
            64'd0,
            64'h80007000,

            1'b0,
            ALU_REM,
            3'b000,

            64'd2,
            1'b0,
            64'h80007000,
            64'd22

        );

        //----------------------------------------------------------------------
        // PASS
        //----------------------------------------------------------------------

        $display("");
        $display("====================================================");
        $display(" ALL EXECUTE STAGE TESTS PASSED");
        $display("====================================================");
        $display("");

        #10;
        $finish;

    end

endmodule : tb_execute_stage
