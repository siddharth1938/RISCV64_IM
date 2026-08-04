//==============================================================================
// Project      : RISCV64 Processor
// Module       : Testbench - Multiplier
// File         : tb_multiplier.sv
//
// Description  :
//   Testbench for verifying the RV64M Multiplier.
//
//==============================================================================

`timescale 1ns/1ps

module tb_multiplier;

    import riscv_pkg::*;
    import riscv_alu_pkg::*;

    //--------------------------------------------------------------------------
    // DUT Signals
    //--------------------------------------------------------------------------

    xlen_t   operand_a_i;
    xlen_t   operand_b_i;
    alu_op_t mul_op_i;

    xlen_t   result_o;

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------

    multiplier dut (

        .operand_a_i (operand_a_i),
        .operand_b_i (operand_b_i),
        .mul_op_i    (mul_op_i),

        .result_o    (result_o)

    );

    //--------------------------------------------------------------------------
    // Waveform
    //--------------------------------------------------------------------------

    initial begin
        $dumpfile("../waves/tb_multiplier.vcd");
        $dumpvars(0, tb_multiplier);
    end

    //--------------------------------------------------------------------------
    // Test Sequence
    //--------------------------------------------------------------------------

    initial begin

        $display("");
        $display("========================================================");
        $display("             RV64M MULTIPLIER TESTBENCH");
        $display("========================================================");

        //--------------------------------------------------------------
        // MUL
        //--------------------------------------------------------------

        operand_a_i = 25;
        operand_b_i = 5;
        mul_op_i    = ALU_MUL;

        #10;

        if (result_o != 125)
            $fatal(1,"MUL FAILED");

        //--------------------------------------------------------------
        // MULH
        //--------------------------------------------------------------

        operand_a_i = -2;
        operand_b_i = 3;
        mul_op_i    = ALU_MULH;

        #10;

        if (result_o != 64'hFFFFFFFFFFFFFFFF)
            $fatal(1,"MULH FAILED");

        //--------------------------------------------------------------
        // MULHSU
        //--------------------------------------------------------------

        operand_a_i = -2;
        operand_b_i = 3;
        mul_op_i    = ALU_MULHSU;

        #10;

        if (result_o != 64'hFFFFFFFFFFFFFFFF)
            $fatal(1,"MULHSU FAILED");

        //--------------------------------------------------------------
        // MULHU
        //--------------------------------------------------------------

        operand_a_i = 64'hFFFFFFFFFFFFFFFF;
        operand_b_i = 2;
        mul_op_i    = ALU_MULHU;

        #10;

        if (result_o != 64'h0000000000000001)
            $fatal(1,"MULHU FAILED");

        //--------------------------------------------------------------
        // PASS
        //--------------------------------------------------------------

        $display("");
        $display("========================================================");
        $display("     RV64M MULTIPLIER TEST PASSED SUCCESSFULLY");
        $display("========================================================");

        $finish;

    end

endmodule : tb_multiplier
