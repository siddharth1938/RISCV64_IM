# RISC-V RV64I Subset + RV64M Multiply/Divide — Single-Cycle Processor

A modular 64-bit RISC-V processor core written in SystemVerilog, developed as a personal RTL/VLSI learning project.

Version 3.0 extends the earlier RV64I single-cycle design with a dedicated RV64M execution path for multiplication and division operations. Integer multiplication is implemented in a dedicated multiplier, while the divider is currently a synthesis-compatible placeholder for future multi-cycle implementation.

The repository also includes:

- Modular SystemVerilog RTL
- Per-module simulation testbenches
- Verilator simulation flow
- Cadence Xcelium simulation flow
- Waveform generation for RTL debugging
- A synthesis script and timing constraint file
- A simple end-to-end SoC wrapper

> **Current scope:** This is an RV64I subset processor with partial RV64M support, not a complete RV64IM implementation. `MUL`, `MULH`, `MULHSU`, and `MULHU` are implemented. `DIV`, `DIVU`, `REM`, and `REMU` are currently placeholder operations.

---

## Project Information

| Item | Details |
|---|---|
| Architecture | RISC-V |
| Data Width | 64-bit |
| Instruction Width | 32-bit |
| Current ISA Scope | RV64I subset + partial RV64M |
| Microarchitecture | Single-cycle |
| HDL | SystemVerilog |
| Simulation | Verilator / Cadence Xcelium |
| Synthesis | RTL synthesis flow provided |
| Version | 3.0 |
| Author | Siddhartha Chinta |

---

## Project Goals

This project is intended to build practical RTL design experience by implementing a RISC-V processor from instruction decoding through datapath integration, simulation, verification, and synthesis preparation.

### Main goals

- Understand the RV64 instruction format and datapath
- Build modular SystemVerilog RTL rather than a monolithic CPU module
- Implement arithmetic, logical, branch, load/store, and jump operations
- Add a dedicated multiply/divide execution path
- Develop reusable unit-level testbenches
- Practice Verilator and Cadence Xcelium simulation flows
- Debug the design using waveforms
- Prepare the design for synthesis and future microarchitectural extensions

---

## Architecture Overview

The processor uses a classic **single-cycle datapath**. An instruction is fetched, decoded, executed, optionally accesses data memory, writes back its result, and determines the next PC within one clock cycle.

### High-level datapath

```text
                  +----------------------+
                  |      Instruction     |
                  |       Memory         |
                  +----------+-----------+
                             |
                             v
+------+              +-------------+
|  PC  |------------->|   Decoder   |
+--+---+              +------+------+ 
   |                         |
   |                         +-------------------+
   |                                             |
   v                                             v
 PC + 4                                     Immediate
   |                                         Generator
   |                                             |
   |                         +-------------------+
   |                         |
   |                         v
   |                  +-------------+
   |                  |  Register   |
   +----------------->|    File     |
                      +------+------+ 
                             |
                    rs1 / rs2 data
                             |
                             v
                      +-------------+
                      |   Execute   |
                      | ALU / M /   |
                      | Branch/JALR |
                      +------+------+ 
                             |
              +--------------+--------------+
              |                             |
              v                             v
       +-------------+                +-------------+
       | Data Memory |                |  PC Control |
       +------+------+                +------+------+
              |                              |
              v                              v
       Memory Read Data                 PC MUX / Next PC
              |                              |
              +------------+-----------------+
                           |
                           v
                     +-----------+
                     |  WB MUX   |
                     +-----+-----+
                           |
                           v
                      Register File
```

### Core datapath flow

```text
fetch
  -> decode
  -> immediate generation / register read / control
  -> execute
       ├── ALU
       ├── multiplier
       ├── divider
       ├── branch comparator
       ├── branch target generation
       └── JALR target generation
  -> data memory
  -> write-back
  -> PC control / PC mux
  -> fetch
```

### SoC-level integration

```text
                   +--------------------------------------+
                   |                soc_top                |
                   |                                      |
        clk/rst -->|  +---------+       +-------------+   |
                   |  |  fetch  |------>| riscv64_core|   |
                   |  +----+----+       +------+------+-+ |
                   |       ^                   |          |
                   |       | next_pc           |          |
                   |       |                   v          |
                   |       |             +-----------+    |
                   |       +-------------| data_mem  |    |
                   |                     +-----------+    |
                   +--------------------------------------+
```

---

## Repository Structure

```text
RISCV64_v3.0/
├── README.md
├── .gitignore
│
├── programs/
│   └── program.hex
│
├── rtl/
│   ├── include/
│   │   ├── riscv_pkg.sv
│   │   ├── riscv_opcode_pkg.sv
│   │   ├── riscv_funct_pkg.sv
│   │   ├── riscv_alu_pkg.sv
│   │   ├── riscv_muldiv_pkg.sv
│   │   └── riscv_defines.svh
│   │
│   ├── core/
│   │   ├── pc.sv
│   │   ├── instr_mem.sv
│   │   ├── fetch.sv
│   │   ├── decoder.sv
│   │   ├── imm_gen.sv
│   │   ├── regfile.sv
│   │   ├── alu.sv
│   │   ├── alu_mux.sv
│   │   ├── control_unit.sv
│   │   ├── branch_comparator.sv
│   │   ├── branch_target_gen.sv
│   │   ├── jalr_target_gen.sv
│   │   ├── execute_stage.sv
│   │   ├── multiplier.sv
│   │   ├── divider.sv
│   │   ├── data_mem.sv
│   │   ├── wb_mux.sv
│   │   ├── pc_control.sv
│   │   ├── pc_mux.sv
│   │   └── riscv64_core.sv
│   │
│   └── top/
│       └── soc_top.sv
│
├── tb/
│   ├── tb_pc.sv
│   ├── tb_instr_mem.sv
│   ├── tb_fetch.sv
│   ├── tb_decoder.sv
│   ├── tb_imm_gen.sv
│   ├── tb_regfile.sv
│   ├── tb_alu.sv
│   ├── tb_alu_mux.sv
│   ├── tb_control_unit.sv
│   ├── tb_branch_comparator.sv
│   ├── tb_branch_target_gen.sv
│   ├── tb_jalr_target_gen.sv
│   ├── tb_execute_stage.sv
│   ├── tb_multiplier.sv
│   ├── tb_divider.sv
│   ├── tb_data_mem.sv
│   ├── tb_wb_mux.sv
│   ├── tb_pc_control.sv
│   ├── tb_pc_mux.sv
│   └── tb_soc_top.sv
│
├── sim/
│   ├── runsim
│   ├── Makefile
│   ├── Makefile.xrun
│   ├── Flist.rtl
│   ├── Flist.tb
│   └── waves.tcl
│
├── synth/
│   ├── rum.tcl
│   └── rctop.sdc
│
├── waves/
└── reports/
```

---

## RTL Module Reference

| Module | Responsibility |
|---|---|
| `pc` | Program counter with reset-vector initialization, sequential `PC+4`, and redirect support |
| `instr_mem` | Behavioral instruction ROM loaded from `programs/program.hex` using `$readmemh` |
| `fetch` | Integrates PC and instruction memory |
| `decoder` | Extracts opcode, `rd`, `rs1`, `rs2`, `funct3`, and `funct7` |
| `imm_gen` | Generates I/S/B/U/J-format immediates |
| `regfile` | 32 × 64-bit register file with two read ports and one write port |
| `alu` | RV64I arithmetic and logical operations |
| `alu_mux` | Selects register or immediate as ALU operand B |
| `control_unit` | Generates datapath control signals from decoded instruction fields |
| `branch_comparator` | Evaluates BEQ/BNE/BLT/BGE/BLTU/BGEU conditions |
| `branch_target_gen` | Generates `PC + immediate` branch target |
| `jalr_target_gen` | Generates `(rs1 + immediate) & ~1` JALR target |
| `execute_stage` | Integrates ALU, multiplier, divider, branch comparison, and target generation |
| `multiplier` | Implements MUL/MULH/MULHSU/MULHU operations |
| `divider` | Current synthesis-compatible placeholder for DIV/DIVU/REM/REMU |
| `data_mem` | Behavioral 64-bit data memory with synchronous writes and combinational reads |
| `wb_mux` | Selects ALU result, memory data, or PC+4 for register write-back |
| `pc_control` | Determines whether the PC is sequentially updated or redirected |
| `pc_mux` | Selects PC+4, branch/JAL target, or JALR target |
| `riscv64_core` | Integrates the complete single-cycle datapath |
| `soc_top` | Minimal SoC wrapper connecting fetch, core, and data memory |

---

## Global Parameters

Defined in `rtl/include/riscv_pkg.sv`:

| Parameter | Value | Description |
|---|---:|---|
| `XLEN` | 64 | Register and datapath width |
| `ILEN` | 32 | Instruction width |
| `IMEM_DEPTH` | 256 | Instruction memory depth |
| `DMEM_DEPTH` | 256 | Data memory depth |
| `RESET_VECTOR` | `64'h8000_0000` | Initial PC after reset |

The instruction memory is therefore:

```text
256 × 32-bit words
```

and the data memory is:

```text
256 × 64-bit words
```

---

## Instruction Support

### RV64I operations implemented in the control/datapath

#### R-type

```text
ADD
SUB
SLL
SLT
SLTU
XOR
SRL
SRA
OR
AND
```

#### I-type arithmetic

```text
ADDI
SLLI
SLTI
SLTIU
XORI
SRLI
SRAI
ORI
ANDI
```

#### Branches

```text
BEQ
BNE
BLT
BGE
BLTU
BGEU
```

#### Jumps

```text
JAL
JALR
```

### Load/store

The current data path supports generic 64-bit memory accesses.

```text
LOAD  -> 64-bit read
STORE -> 64-bit write
```

Full width-specific RV64I memory operations are not yet implemented:

```text
LB   LH   LW   LD
LBU  LHU  LWU
SB   SH   SW   SD
```

The load/store `funct3` values are defined in the package, but the control and memory datapath currently do not implement byte/halfword/word enables and sign/zero extension.

### RV64M

#### Implemented

```text
MUL
MULH
MULHSU
MULHU
```

These operations are handled by `multiplier.sv`.

#### Placeholder

```text
DIV
DIVU
REM
REMU
```

These operations are decoded and routed to `divider.sv`, but `divider.sv` currently returns a placeholder value. The planned implementation is a proper multi-cycle/iterative divider.

### Not yet implemented

```text
LUI
AUIPC
MISC-MEM
SYSTEM / CSR
Exceptions
Debug mode
Compressed instructions (RV64C)
```

---

## Execute Stage

The execute stage is intentionally grouped as a future microarchitectural boundary.

```text
                         +----------------+
rs1 -------------------->|                |
rs2 -------------------->|   ALU MUX      |
imm -------------------->|                |
                         +-------+--------+
                                 |
                                 v
                         +---------------+
                         |      ALU      |
                         +---------------+

rs1/rs2 -----------------> Branch Comparator
PC/imm ------------------> Branch Target Generator
rs1/imm -----------------> JALR Target Generator

rs1/rs2/ALU operand ------> Multiplier
rs1/rs2/ALU operand ------> Divider
```

This organization is intended to make the current single-cycle execute logic easier to evolve into a future pipelined EX stage.

---

## Write-Back

The write-back path has three sources:

```text
00 -> ALU result
01 -> Data memory read data
10 -> PC + 4
```

The `wb_sel[1:0]` signal selects the value written to the destination register.

---

## Program Loading

`instr_mem.sv` loads the instruction image using:

```systemverilog
$readmemh("../programs/program.hex", mem);
```

The supplied program contains RV64I/RV64M-oriented arithmetic and logical operations and ends with an unconditional jump.

The current `tb_soc_top` performs an end-to-end processor simulation with internal state reporting. It is primarily intended for functional observation and waveform debug rather than a complete architectural scoreboard.

To use another program:

1. Assemble the program into 32-bit instruction words.
2. Write one hexadecimal instruction per line.
3. Replace `programs/program.hex`.
4. Run `tb_soc_top`.

Example format:

```text
00a00093
01400113
002081b3
...
```

---

## Simulation Environment

Two simulator flows are provided:

- **Verilator**
- **Cadence Xcelium (`xrun`)**

The `runsim` script selects the simulator and testbench.

### Quick start

```bash
cd sim
```

Run with the default simulator:

```bash
./runsim tb_alu
```

Explicit Verilator:

```bash
./runsim verilator tb_alu
```

Explicit Xcelium:

```bash
./runsim xrun tb_alu
```

Run the full SoC testbench:

```bash
./runsim verilator tb_soc_top
```

or:

```bash
./runsim xrun tb_soc_top
```

### Available testbenches

There are 20 testbenches covering the major RTL blocks:

```text
tb_pc
tb_instr_mem
tb_fetch
tb_decoder
tb_imm_gen
tb_regfile
tb_alu
tb_alu_mux
tb_control_unit
tb_branch_comparator
tb_branch_target_gen
tb_jalr_target_gen
tb_execute_stage
tb_multiplier
tb_divider
tb_data_mem
tb_wb_mux
tb_pc_control
tb_pc_mux
tb_soc_top
```

Most unit-level testbenches use explicit expected-value checks and `$fatal` on mismatches. The simpler fetch, decoder, immediate-generator, instruction-memory, PC, and SoC tests rely more heavily on printed results and waveform inspection.

---

## Verilator Makefile Targets

```bash
cd sim
```

Build a testbench:

```bash
make -f Makefile build TOP=tb_alu
```

Run:

```bash
make -f Makefile run TOP=tb_alu
```

Open waveform:

```bash
make -f Makefile wave TOP=tb_alu
```

Clean:

```bash
make -f Makefile clean
```

---

## Xcelium Makefile Targets

```bash
cd sim
```

Build:

```bash
make -f Makefile.xrun build TOP=tb_alu
```

Waveform:

```bash
make -f Makefile.xrun wave TOP=tb_alu
```

Clean:

```bash
make -f Makefile.xrun clean
```

The exact Xcelium commands depend on the Cadence installation and environment.

---

## Waveform Debug

The testbenches generate VCD waveforms under:

```text
waves/
```

Verilator waveforms can be opened using:

```bash
gtkwave ../waves/tb_alu.vcd
```

Xcelium uses the Cadence waveform flow and `simvision`.

Generated waveforms, build directories, logs, and reports are excluded from Git using `.gitignore`.

---

## Synthesis

A synthesis flow is provided under:

```text
synth/
├── rum.tcl
└── rctop.sdc
```

The synthesis script:

1. Reads the SystemVerilog packages.
2. Reads the RTL core files.
3. Loads technology libraries.
4. Reads physical LEF files.
5. Elaborates `riscv64_core`.
6. Reads the SDC timing constraints.
7. Runs generic synthesis.
8. Runs technology mapping.
9. Runs synthesis optimization.

The supplied SDC defines a:

```text
10 ns clock period
5 ns high time
```

corresponding to a nominal:

```text
100 MHz
```

clock target.

### Important environment note

`synth/rum.tcl` currently contains absolute paths to the author's local RTL and technology-library installation, for example:

```text
/home/chip3/RISCV_64IM/RISCV64_v3.0/...
```

These paths must be changed for another environment before running synthesis.

The synthesis script currently elaborates:

```text
riscv64_core
```

rather than the complete `soc_top`, so the synthesis flow is currently focused on the processor core.

---

## Current Status

### Implemented

- Single-cycle 64-bit RISC-V datapath
- RV64I arithmetic/logical subset
- Branch instructions
- JAL/JALR
- 32 × 64-bit register file
- Behavioral instruction memory
- Behavioral data memory
- Dedicated multiplier
- MUL/MULH/MULHSU/MULHU
- Modular execute stage
- Verilator simulation flow
- Cadence Xcelium simulation flow
- Unit-level testbench suite
- Initial synthesis flow and timing constraints

### Partial

- RV64M division/remainder operations
- Load/store width handling
- Full RV64I instruction coverage
- End-to-end architectural checking

### Not yet implemented

- Multi-cycle divider
- LUI/AUIPC
- Full load/store byte enables and sign/zero extension
- Illegal instruction detection
- Exception/interrupt handling
- CSR subsystem
- Debug mode
- Caches
- Pipeline
- Hazard detection
- Forwarding
- Stall/flush logic
- Branch prediction
- AXI/AHB interface
- RV64C

---

## Roadmap

### Phase 1 — Complete ISA coverage

- Implement LUI
- Implement AUIPC
- Implement full RV64I load/store widths
- Add byte enables
- Add sign/zero extension
- Add illegal-instruction detection

### Phase 2 — Complete RV64M

- Replace the divider placeholder
- Implement iterative multi-cycle division
- Implement DIV/DIVU/REM/REMU corner cases
- Add stronger multiplier/divider verification

### Phase 3 — Verification

- Convert remaining visual-inspection testbenches into self-checking tests
- Add an architectural scoreboard
- Add instruction-level directed tests
- Add randomized arithmetic tests
- Add corner-case tests for branches, shifts, multiplication, and division
- Add end-to-end memory-signature checking

### Phase 4 — Microarchitecture

- Convert the single-cycle design into a 5-stage pipeline:
  - IF
  - ID
  - EX
  - MEM
  - WB
- Add pipeline registers
- Add forwarding
- Add hazard detection
- Add stalls
- Add branch flushes

### Phase 5 — SoC / ASIC-oriented integration

- Add CSR and exception support
- Add debug support
- Add instruction/data caches
- Add AXI/AHB interface
- Improve synthesis constraints
- Add timing, area, and power reporting
- Prepare for FPGA and ASIC implementation

---

## Known Limitations

### 1. Divider is a placeholder

`divider.sv` is intentionally not a functional divider yet. It exists so that the RV64M datapath can be structurally integrated and synthesized while the proper multi-cycle divider is developed.

### 2. Load/store width is not decoded

The current memory interface operates on 64-bit values and does not provide byte enables or width-specific sign/zero extension.

### 3. Instruction coverage is incomplete

LUI, AUIPC, MISC-MEM, SYSTEM/CSR, exceptions, and compressed instructions are not implemented.

### 4. End-to-end verification is incomplete

`tb_soc_top` provides cycle-by-cycle processor state visibility and waveform generation, but it does not yet compare the final architectural state against a reference model or memory signature.

### 5. Synthesis scripts are environment-specific

The supplied synthesis Tcl contains absolute paths to local RTL and technology libraries and must be adapted before use on another machine.

---

## Design Philosophy

The project intentionally favors **modularity and incremental architectural growth**.

The current single-cycle implementation provides a simple baseline from which more advanced microarchitectural features can be introduced without redesigning the entire RTL hierarchy.

In particular:

```text
RV64I subset
      |
      v
RV64I + M
      |
      v
Verification improvement
      |
      v
5-stage pipeline
      |
      v
Hazards + forwarding
      |
      v
Caches / CSR / exceptions
      |
      v
SoC integration
```

---

## License

No license file is currently included in this repository.

If the repository is intended for public reuse or external contributions, add an appropriate license such as MIT or Apache-2.0.

---

## Author

**Siddhartha Chinta**

RISC-V / RTL / SystemVerilog learning and development project.
