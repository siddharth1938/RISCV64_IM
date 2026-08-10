//==============================================================================
// Project      : RISCV64 Processor
// Module       : Divider
// File         : divider.sv
//
// Description  :
//   Placeholder Divider for Version 3.0.
//
//   NOTE:
//   This module is intentionally implemented as a placeholder to allow
//   synthesis of the complete RV64IM processor. A proper multi-cycle
//   iterative divider will replace this implementation in a future version.
//
//------------------------------------------------------------------------------
// Author       : Siddhartha Chinta
// Organization : Personal Learning Project
//
// Target ISA   : RV64IM
// Language     : SystemVerilog
// Version      : 3.0
//==============================================================================

`timescale 1ns/1ps

module divider
    import riscv_pkg::*;
    import riscv_alu_pkg::*;
(

    //--------------------------------------------------------------------------
    // Operands
    //--------------------------------------------------------------------------

    input  xlen_t   operand_a_i,
    input  xlen_t   operand_b_i,

    //--------------------------------------------------------------------------
    // Divide Operation
    //--------------------------------------------------------------------------

    input  alu_op_t div_op_i,

    //--------------------------------------------------------------------------
    // Output
    //--------------------------------------------------------------------------

    output xlen_t   result_o

);

    //==========================================================================
    // Internal Result
    //==========================================================================

    xlen_t result;

    //==========================================================================
    // Placeholder Divider
    //==========================================================================

    always_comb begin

        result = '0;

        unique case (div_op_i)

            //--------------------------------------------------------------
            // Placeholder for RV64M Divide Operations
            //--------------------------------------------------------------

            ALU_DIV,
            ALU_DIVU,
            ALU_REM,
            ALU_REMU:
                result = '0;

            //--------------------------------------------------------------
            // Default
            //--------------------------------------------------------------

            default:
                result = '0;

        endcase

    end

    //==========================================================================
    // Output Logic
    //==========================================================================

    assign result_o = result;

endmodule : divider
