
read_hdl -sv /home/chip3/RISCV_64IM/RISCV64_v3.0/rtl/include/riscv_pkg.sv
read_hdl -sv /home/chip3/RISCV_64IM/RISCV64_v3.0/rtl/include/riscv_opcode_pkg.sv
read_hdl -sv /home/chip3/RISCV_64IM/RISCV64_v3.0/rtl/include/riscv_funct_pkg.sv
read_hdl -sv /home/chip3/RISCV_64IM/RISCV64_v3.0/rtl/include/riscv_alu_pkg.sv
read_hdl -sv /home/chip3/RISCV_64IM/RISCV64_v3.0/rtl/include/riscv_muldiv_pkg.sv

read_hdl -sv [glob /home/chip3/RISCV_64IM/RISCV64_v3.0/rtl/core/*.sv]

read_libs {/home/chip3/FIFO_DESIGN/LIBS/lib/max/slow.lib  /home/chip3/FIFO_DESIGN/LIBS/lib/max/pdkIO.lib  /home/chip3/FIFO_DESIGN/LIBS/lib/min/fast.lib}

 read_physical -lefs {/home/chip3/FIFO_DESIGN/LIBS/lef/gsclib045.fixed2.lef /home/chip3/FIFO_DESIGN/LIBS/lef/pads.lef /home/chip3/FIFO_DESIGN/LIBS/lef/pdkIO.lef }
 elaborate riscv64_core
 gui_show
 read_sdc /home/chip3/RISCV_64IM/RISCV64_v3.0/synth/rctop.sdc
  syn_generic
 syn_map
 syn_opt

