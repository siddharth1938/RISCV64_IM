//==============================================================================
// Project      : RISCV64 Processor
// Module       : Control Unit
// File         : control_unit.sv
//
// Description  :
//   Generates processor control signals from the decoded instruction fields.
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

module control_unit

    import riscv_pkg::*;
    import riscv_opcode_pkg::*;
    import riscv_funct_pkg::*;
    import riscv_alu_pkg::*;
    import riscv_muldiv_pkg::*;

(

    //--------------------------------------------------------------------------
    // Decoded Instruction Fields
    //--------------------------------------------------------------------------

    input opcode_t opcode_i,
    input funct3_t funct3_i,
    input funct7_t funct7_i,

    //--------------------------------------------------------------------------
    // Control Outputs
    //--------------------------------------------------------------------------

    output alu_op_t    alu_op_o,
    output logic       reg_write_o,
    output logic       alu_src_o,

    output logic       mem_read_o,
    output logic       mem_write_o,

    output logic [1:0] wb_sel_o,

    output logic       branch_o,
    output logic       jump_o,
    output logic       jalr_o

);

    //==========================================================================
    // Control Logic
    //==========================================================================

    always_comb begin

        //----------------------------------------------------------------------
        // Default Outputs
        //----------------------------------------------------------------------

        alu_op_o     = ALU_ADD;

        reg_write_o  = 1'b0;
        alu_src_o    = 1'b0;

        mem_read_o   = 1'b0;
        mem_write_o  = 1'b0;

        wb_sel_o     = 2'b00;

        branch_o     = 1'b0;
        jump_o       = 1'b0;
        jalr_o       = 1'b0;

        //----------------------------------------------------------------------
        // Main Opcode Decode
        //----------------------------------------------------------------------

        unique case (opcode_i)

            //------------------------------------------------------------------
            // R-Type Instructions
            //------------------------------------------------------------------

            OPCODE_OP: begin

                reg_write_o = 1'b1;
                alu_src_o   = 1'b0;
                wb_sel_o    = 2'b00;

                unique case (funct7_i)
                    //----------------------------------------------------------
                    // RV64I Arithmetic Instructions
                    //----------------------------------------------------------

                    F7_ADD: begin

                        unique case (funct3_i)

                            F3_ADD_SUB : alu_op_o = ALU_ADD;
                            F3_SLL     : alu_op_o = ALU_SLL;
                            F3_SLT     : alu_op_o = ALU_SLT;
                            F3_SLTU    : alu_op_o = ALU_SLTU;
                            F3_XOR     : alu_op_o = ALU_XOR;
                            F3_SRL_SRA : alu_op_o = ALU_SRL;
                            F3_OR      : alu_op_o = ALU_OR;
                            F3_AND     : alu_op_o = ALU_AND;

                            default    : alu_op_o = ALU_ADD;

                        endcase

                    end

                    //----------------------------------------------------------
                    // RV64I SUB / SRA Instructions
                    //----------------------------------------------------------

                    F7_SUB: begin

                        unique case (funct3_i)

                            F3_ADD_SUB : alu_op_o = ALU_SUB;
                            F3_SRL_SRA : alu_op_o = ALU_SRA;

                            default    : alu_op_o = ALU_ADD;

                        endcase

                    end

                    //----------------------------------------------------------
                    // RV64M Multiply / Divide Instructions
                    //----------------------------------------------------------

                    F7_M: begin

                        unique case (funct3_i)

                            F3_MUL    : alu_op_o = ALU_MUL;
                            F3_MULH   : alu_op_o = ALU_MULH;
                            F3_MULHSU : alu_op_o = ALU_MULHSU;
                            F3_MULHU  : alu_op_o = ALU_MULHU;

                            F3_DIV    : alu_op_o = ALU_DIV;
                            F3_DIVU   : alu_op_o = ALU_DIVU;
                            F3_REM    : alu_op_o = ALU_REM;
                            F3_REMU   : alu_op_o = ALU_REMU;

                            default   : alu_op_o = ALU_ADD;

                        endcase

                    end

                    //----------------------------------------------------------
                    // Unsupported funct7
                    //----------------------------------------------------------

                    default: begin

                        alu_op_o = ALU_ADD;

                    end

                endcase

            end

            //------------------------------------------------------------------
            // I-Type Arithmetic Instructions
            //------------------------------------------------------------------

            OPCODE_OP_IMM: begin

                reg_write_o = 1'b1;
                alu_src_o   = 1'b1;
                wb_sel_o    = 2'b00;

                unique case (funct3_i)
                    F3_ADD_SUB:
                        alu_op_o = ALU_ADD;

                    F3_SLL:
                        alu_op_o = ALU_SLL;

                    F3_SLT:
                        alu_op_o = ALU_SLT;

                    F3_SLTU:
                        alu_op_o = ALU_SLTU;

                    F3_XOR:
                        alu_op_o = ALU_XOR;

                    F3_SRL_SRA:
                        alu_op_o = (funct7_i == F7_SUB) ? ALU_SRA : ALU_SRL;

                    F3_OR:
                        alu_op_o = ALU_OR;

                    F3_AND:
                        alu_op_o = ALU_AND;

                    default:
                        alu_op_o = ALU_ADD;

                endcase

            end

            //------------------------------------------------------------------
            // LOAD Instructions
            //------------------------------------------------------------------

            OPCODE_LOAD: begin

                reg_write_o = 1'b1;
                alu_src_o   = 1'b1;

                mem_read_o  = 1'b1;

                wb_sel_o    = 2'b01;

                alu_op_o    = ALU_ADD;

            end

            //------------------------------------------------------------------
            // STORE Instructions
            //------------------------------------------------------------------

            OPCODE_STORE: begin

                reg_write_o = 1'b0;
                alu_src_o   = 1'b1;

                mem_write_o = 1'b1;

                alu_op_o    = ALU_ADD;

            end

            //------------------------------------------------------------------
            // BRANCH Instructions
            //------------------------------------------------------------------

            OPCODE_BRANCH: begin

                reg_write_o = 1'b0;
                alu_src_o   = 1'b0;

                branch_o    = 1'b1;

                alu_op_o    = ALU_SUB;

            end

            //------------------------------------------------------------------
            // JAL Instruction
            //------------------------------------------------------------------

            OPCODE_JAL: begin

                reg_write_o = 1'b1;
                wb_sel_o    = 2'b10;

                jump_o      = 1'b1;

                alu_op_o    = ALU_ADD;

            end

            //------------------------------------------------------------------
            // JALR Instruction
            //------------------------------------------------------------------

            OPCODE_JALR: begin

                reg_write_o = 1'b1;
                alu_src_o   = 1'b1;

                wb_sel_o    = 2'b10;

                jalr_o      = 1'b1;

                alu_op_o    = ALU_ADD;

            end

            //------------------------------------------------------------------
            // Default
            //------------------------------------------------------------------

            default: begin

                // Defaults already assigned above.

            end

        endcase

    end

endmodule : control_unit
