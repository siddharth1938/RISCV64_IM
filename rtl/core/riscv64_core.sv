//==============================================================================
// Project      : RISCV64 Processor
// Module       : Top Level Processor
// File         : riscv64_top.sv
//
// Description  :
//   Top-level integration of the RV64I single-cycle processor.
//
//   fetch (pc_i+imem) -> decoder -> {imm_gen, regfile, control_unit}
//        -> execute_stage -> data_mem -> wb_mux -> regfile write-back
//        -> pc_control + pc_mux -> fetch (PC redirect)
//
//   pc_plus4 is computed inline here rather than via a dedicated module:
//   pc_i.sv already computes pc_q+4 internally for its own next-state logic,
//   but that value is never exposed externally, and since pc_control
//   always drives load_pc_o = 1 (the mux is always in charge - pc_i.sv's
//   internal fallback path never fires), the rest of the datapath
//   (pc_mux's sequential case, wb_mux's JAL/JALR return address) still
//   needs its own pc_plus4 value. A single assign covers that with no
//   need for a separate module.
//
//------------------------------------------------------------------------------
// Author       : Siddhartha Chinta
// Organization : Personal Learning Project
//
// Target ISA   : RV64I
// Language     : SystemVerilog
//==============================================================================

`timescale 1ns/1ps

module riscv64_core
    import riscv_pkg::*;
    import riscv_opcode_pkg::*;
    import riscv_funct_pkg::*;
    import riscv_alu_pkg::*;
    import riscv_muldiv_pkg::*;
(
    input logic clk_i,
    input logic rst_ni,
    
    //==========================================================
    // Instruction Interface
    //==========================================================
    input  xlen_t  pc_i,
    input  instr_t instruction_i,

    output logic   load_pc_o,
    output xlen_t  next_pc_o,

    //==========================================================
    // Data Memory Interface
    //==========================================================
    input  xlen_t  mem_data_i,

    output xlen_t  mem_addr_o,
    output xlen_t  mem_write_data_o,
    output logic   mem_read_o,
    output logic   mem_write_o
);

    //==========================================================================
    // Program Counter / Fetch Signals
    //==========================================================================

    xlen_t  pc_plus4;


    //==========================================================================
    // Decoder Outputs
    //==========================================================================

    opcode_t   opcode;
    reg_addr_t rs1_addr;
    reg_addr_t rs2_addr;
    reg_addr_t rd_addr;
    funct3_t   funct3;
    funct7_t   funct7;

    //==========================================================================
    // Immediate Generator
    //==========================================================================

    xlen_t immediate;

    //==========================================================================
    // Register File
    //==========================================================================

    xlen_t rs1_data;
    xlen_t rs2_data;
    xlen_t write_back_data;

    //==========================================================================
    // Control Signals
    //==========================================================================

    alu_op_t    alu_op;
    logic       reg_write;
    logic       alu_src;
    logic       mem_read;
    logic       mem_write;
    logic [1:0] wb_sel;
    logic       branch;
    logic       jump;
    logic       jalr;

    //==========================================================================
    // Execute Stage
    //==========================================================================

    xlen_t alu_result;
    xlen_t branch_target;
    xlen_t jalr_target;
    logic  branch_taken;

    
    //==========================================================================
    // PC Redirect
    //==========================================================================

    logic [1:0] pc_sel;



    //==========================================================================
    // PC Plus-4  (computed inline - see header note)
    //==========================================================================

    assign pc_plus4 = pc_i + xlen_t'(64'd4);

    //==========================================================================
    // Instruction Decoder
    //==========================================================================

    decoder u_decoder (

        .instr_i  (instruction_i),

        .opcode_o (opcode),
        .rd_o     (rd_addr),
        .rs1_o    (rs1_addr),
        .rs2_o    (rs2_addr),
        .funct3_o (funct3),
        .funct7_o (funct7)

    );

    //==========================================================================
    // Immediate Generator
    //==========================================================================

    imm_gen u_imm_gen (

        .instr_i (instruction_i),
        .imm_o   (immediate)

    );

    //==========================================================================
    // Control Unit
    //==========================================================================

    control_unit u_control_unit (

        .opcode_i    (opcode),
        .funct3_i    (funct3),
        .funct7_i    (funct7),

        .alu_op_o    (alu_op),
        .reg_write_o (reg_write),
        .alu_src_o   (alu_src),

        .mem_read_o  (mem_read),
        .mem_write_o (mem_write),

        .wb_sel_o    (wb_sel),

        .branch_o    (branch),
        .jump_o      (jump),
        .jalr_o      (jalr)

    );

    //==========================================================================
    // Register File
    //==========================================================================

    regfile u_regfile (

        .clk_i      (clk_i),

        .rs1_addr_i (rs1_addr),
        .rs1_data_o (rs1_data),

        .rs2_addr_i (rs2_addr),
        .rs2_data_o (rs2_data),

        .rd_addr_i  (rd_addr),
        .rd_data_i  (write_back_data),
        .rd_we_i    (reg_write)

    );

    //==========================================================================
    // Execute Stage (ALU + Branch Compare + Branch/JALR Target Math)
    //==========================================================================

    execute_stage u_execute_stage (

        .rs1_data_i      (rs1_data),
        .rs2_data_i      (rs2_data),
        .imm_i           (immediate),
        .pc_i            (pc_i),

        .alu_src_i       (alu_src),
        .alu_op_i        (alu_op),
        .funct3_i        (funct3),

        .alu_result_o    (alu_result),
        .branch_taken_o  (branch_taken),
        .branch_target_o (branch_target),
        .jalr_target_o   (jalr_target)

    );



    //==========================================================================
    // Write-Back Mux
    //==========================================================================

    wb_mux u_wb_mux (

        .alu_result_i (alu_result),
        .mem_data_i   (mem_data_i),
        .pc_plus4_i   (pc_plus4),

        .wb_sel_i     (wb_sel),

        .write_data_o (write_back_data)

    );

    //==========================================================================
    // PC Control Unit
    //==========================================================================

    pc_control u_pc_control (

        .branch_i       (branch),
        .jump_i         (jump),
        .jalr_i         (jalr),
        .branch_taken_i (branch_taken),

        .load_pc_o      (load_pc_o),
        .pc_sel_o       (pc_sel)

    );

    //==========================================================================
    // Next PC Mux
    //==========================================================================

    pc_mux u_pc_mux (

        .pc_plus4_i      (pc_plus4),
        .branch_target_i (branch_target),
        .jump_target_i   (branch_target), // JAL target uses the same PC+imm math
        .jalr_target_i   (jalr_target),

        .pc_sel_i        (pc_sel),

        .next_pc_o       (next_pc_o)

    );
    //==========================================================================
    // External Data Memory Interface
    //==========================================================================

    assign mem_addr_o       = alu_result;
    assign mem_write_data_o = rs2_data;
    assign mem_read_o       = mem_read;
    assign mem_write_o      = mem_write;
endmodule : riscv64_core
