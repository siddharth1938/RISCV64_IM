//==============================================================================
// Project      : RISCV64 Processor
// Package      : ALU Operation Definitions
// File         : riscv_alu_pkg.sv
//
// Description  :
//   Defines internal ALU and Execute operation encodings used by the
//   Control Unit and Execute Stage.
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

package riscv_alu_pkg;

    //==========================================================================
    // Execute Operation Encoding
    //==========================================================================

    typedef enum logic [4:0]
    {
        //--------------------------------------------------------------------------
        // RV64I Arithmetic / Logical Operations
        //--------------------------------------------------------------------------

        ALU_ADD     = 5'd0,
        ALU_SUB     = 5'd1,

        ALU_SLL     = 5'd2,
        ALU_SLT     = 5'd3,
        ALU_SLTU    = 5'd4,

        ALU_XOR     = 5'd5,
        ALU_SRL     = 5'd6,
        ALU_SRA     = 5'd7,

        ALU_OR      = 5'd8,
        ALU_AND     = 5'd9,

        //--------------------------------------------------------------------------
        // RV64M Multiplication Operations
        //--------------------------------------------------------------------------

        ALU_MUL     = 5'd10,
        ALU_MULH    = 5'd11,
        ALU_MULHSU  = 5'd12,
        ALU_MULHU   = 5'd13,

        //--------------------------------------------------------------------------
        // RV64M Division Operations
        //--------------------------------------------------------------------------

        ALU_DIV     = 5'd14,
        ALU_DIVU    = 5'd15,
        ALU_REM     = 5'd16,
        ALU_REMU    = 5'd17

    } alu_op_t;

endpackage : riscv_alu_pkg
