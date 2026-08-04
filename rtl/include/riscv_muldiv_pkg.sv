//==============================================================================
// Project      : RISCV64 Processor
// Package      : RV64M Multiply / Divide Definitions
// File         : riscv_muldiv_pkg.sv
//
// Description  :
//   Common funct3 and funct7 definitions for the RV64M Multiply/Divide
//   Extension.
//
// Author       : Siddhartha Chinta
// Organization : Personal Learning Project
//
// Target ISA   : RV64IM
// Language     : SystemVerilog
//
// Version      : 2.0
//==============================================================================

`timescale 1ns/1ps

package riscv_muldiv_pkg;

    import riscv_pkg::*;

    //==========================================================================
    // RV64M funct7
    //==========================================================================
    //
    // All RV64M instructions use:
    //      opcode = OPCODE_OP (0110011)
    //      funct7 = 0000001
    //
    //==========================================================================

    localparam funct7_t F7_M = 7'b0000001;

    //==========================================================================
    // RV64M Multiplication Instructions
    //==========================================================================

    localparam funct3_t F3_MUL      = 3'b000;
    localparam funct3_t F3_MULH     = 3'b001;
    localparam funct3_t F3_MULHSU   = 3'b010;
    localparam funct3_t F3_MULHU    = 3'b011;

    //==========================================================================
    // RV64M Division Instructions
    //==========================================================================

    localparam funct3_t F3_DIV      = 3'b100;
    localparam funct3_t F3_DIVU     = 3'b101;
    localparam funct3_t F3_REM      = 3'b110;
    localparam funct3_t F3_REMU     = 3'b111;

endpackage : riscv_muldiv_pkg
