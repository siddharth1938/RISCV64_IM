//==============================================================================
// Project      : RISCV64 Processor
// Package      : RV64I Function Definitions
// File         : riscv_funct_pkg.sv
//
// Description  :
//   Common funct3 and funct7 definitions for the RV64I Base Integer ISA.
//
//------------------------------------------------------------------------------
// Author       : Siddhartha Chinta
// Organization : Personal Learning Project
//
// Target ISA   : RV64IM
// Language     : SystemVerilog
//
// Created      : July 2026
// Version      : 2.0
//==============================================================================

`timescale 1ns/1ps

package riscv_funct_pkg;

    import riscv_pkg::*;

    //==========================================================================
    // OP / OP-IMM Instructions
    //==========================================================================

    localparam funct3_t F3_ADD_SUB = 3'b000;
    localparam funct3_t F3_SLL      = 3'b001;
    localparam funct3_t F3_SLT      = 3'b010;
    localparam funct3_t F3_SLTU     = 3'b011;
    localparam funct3_t F3_XOR      = 3'b100;
    localparam funct3_t F3_SRL_SRA  = 3'b101;
    localparam funct3_t F3_OR       = 3'b110;
    localparam funct3_t F3_AND      = 3'b111;

    //==========================================================================
    // Branch Instructions
    //==========================================================================

    localparam funct3_t F3_BEQ      = 3'b000;
    localparam funct3_t F3_BNE      = 3'b001;
    localparam funct3_t F3_BLT      = 3'b100;
    localparam funct3_t F3_BGE      = 3'b101;
    localparam funct3_t F3_BLTU     = 3'b110;
    localparam funct3_t F3_BGEU     = 3'b111;

    //==========================================================================
    // Load / Store Size Definitions
    //==========================================================================

    localparam funct3_t F3_BYTE     = 3'b000;
    localparam funct3_t F3_HALF     = 3'b001;
    localparam funct3_t F3_WORD     = 3'b010;
    localparam funct3_t F3_DWORD    = 3'b011;

    localparam funct3_t F3_BYTE_U   = 3'b100;
    localparam funct3_t F3_HALF_U   = 3'b101;
    localparam funct3_t F3_WORD_U   = 3'b110;

    //==========================================================================
    // RV64I funct7 Definitions
    //==========================================================================

    localparam funct7_t F7_ADD      = 7'b0000000;
    localparam funct7_t F7_SUB      = 7'b0100000;

endpackage : riscv_funct_pkg
