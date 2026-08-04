//==============================================================================
// Project      : RISCV64 Processor
// Module       : Multiplier
// File         : multiplier.sv
//
// Description  :
//   Performs RV64M multiplication operations.
//
//   Supported Instructions:
//     - MUL
//     - MULH
//     - MULHSU
//     - MULHU
//
//------------------------------------------------------------------------------
// Author       : Siddhartha Chinta
// Organization : Personal Learning Project
//
// Target ISA   : RV64IM
// Language     : SystemVerilog
// Version      : 2.0
//==============================================================================

`timescale 1ns/1ps

module multiplier
    import riscv_pkg::*;
    import riscv_alu_pkg::*;
(

    //--------------------------------------------------------------------------
    // Operands
    //--------------------------------------------------------------------------

    input  xlen_t   operand_a_i,
    input  xlen_t   operand_b_i,

    //--------------------------------------------------------------------------
    // Multiply Operation
    //--------------------------------------------------------------------------

    input  alu_op_t mul_op_i,

    //--------------------------------------------------------------------------
    // Output
    //--------------------------------------------------------------------------

    output xlen_t   result_o

);

    //==========================================================================
    // Internal Signals
    //==========================================================================

    logic signed [127:0] signed_product;
    logic signed [127:0] mixed_product;
    logic        [127:0] unsigned_product;

    xlen_t result;

    //==========================================================================
    // Combinational Multiplier
    //==========================================================================

    always_comb begin

        //--------------------------------------------------------------
        // Default Values
        //--------------------------------------------------------------

        result           = '0;
        signed_product   = '0;
        mixed_product    = '0;
        unsigned_product = '0;

        //--------------------------------------------------------------
        // Compute Products
        //--------------------------------------------------------------

        signed_product =
            $signed(operand_a_i) * $signed(operand_b_i);

        mixed_product =
            $signed(operand_a_i) *
            $signed({1'b0, operand_b_i});

        unsigned_product =
            operand_a_i * operand_b_i;

        //--------------------------------------------------------------
        // Select Required Result
        //--------------------------------------------------------------

        unique case (mul_op_i)

            //----------------------------------------------------------
            // MUL
            // Lower 64 bits of Signed × Signed Product
            //----------------------------------------------------------

            ALU_MUL:
                result = signed_product[63:0];

            //----------------------------------------------------------
            // MULH
            // Upper 64 bits of Signed × Signed Product
            //----------------------------------------------------------

            ALU_MULH:
                result = signed_product[127:64];

            //----------------------------------------------------------
            // MULHSU
            // Upper 64 bits of Signed × Unsigned Product
            //----------------------------------------------------------

            ALU_MULHSU:
                result = mixed_product[127:64];

            //----------------------------------------------------------
            // MULHU
            // Upper 64 bits of Unsigned × Unsigned Product
            //----------------------------------------------------------

            ALU_MULHU:
                result = unsigned_product[127:64];

            //----------------------------------------------------------
            // Default
            //----------------------------------------------------------

            default:
                result = '0;

        endcase

    end

    //==========================================================================
    // Output Logic
    //==========================================================================

    assign result_o = result;

endmodule : multiplier
