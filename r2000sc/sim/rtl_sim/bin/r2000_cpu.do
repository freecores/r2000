# ----------- #
# The library #
# ----------- #
vlib work

# -------- #
# The Core #
# -------- #
# The muxs
vlog ../../../rtl/verilog/r2000_mux2.v				+incdir+../../../rtl/verilog
vlog ../../../rtl/verilog/r2000_mux3.v				+incdir+../../../rtl/verilog
vlog ../../../rtl/verilog/r2000_mux4.v				+incdir+../../../rtl/verilog
vlog ../../../rtl/verilog/r2000_mux7.v				+incdir+../../../rtl/verilog

# The PC unit
vlog ../../../rtl/verilog/r2000_pc.v				+incdir+../../../rtl/verilog

# The Branch decode
vlog ../../../rtl/verilog/r2000_bradecoder.v		+incdir+../../../rtl/verilog


# The register file
vlog ../../../rtl/verilog/r2000_regfile.v			+incdir+../../../rtl/verilog

# The Alu
vlog ../../../rtl/verilog/r2000_aluctrl.v			+incdir+../../../rtl/verilog
vlog ../../../rtl/verilog/r2000_alu.v				+incdir+../../../rtl/verilog

# The Barrel Shifter
vlog ../../../rtl/verilog/r2000_shifter.v			+incdir+../../../rtl/verilog
#vlog tb_Barrel.v									+incdir+../../../rtl/verilog

# The Multiplier
vlog ../../../rtl/verilog/r2000_multiplier.v		+incdir+../../../rtl/verilog

# The Divisor
vlog ../../../rtl/verilog/r2000_divisor.v			+incdir+../../../rtl/verilog
#vlog ../../../rtl/verilog/r2000_divisor-prim.v		+incdir+../../../rtl/verilog

# The Multiplier/Diviser
vlog ../../../rtl/verilog/r2000_multdiv.v			+incdir+../../../rtl/verilog

# The Control
vlog ../../../rtl/verilog/r2000_decoder.v			+incdir+../../../rtl/verilog

# The memory interface
vlog ../../../rtl/verilog/r2000_membus.v			+incdir+../../../rtl/verilog

# The processor
vlog ../../../rtl/verilog/r2000_cpu_sc.v			+incdir+../../../rtl/verilog

# The memorys
vlog ../../../bench/verilog/FLASH.v					+incdir+../../../rtl/verilog
vlog ../../../bench/verilog/SRAM.v					+incdir+../../../rtl/verilog

# ----------------------------- #
# The TestBench of the processor
# ----------------------------- #
vlog ../../../bench/verilog/tb_r2000_cpu.v			+incdir+../../../rtl/verilog

# -------- #
# Simulate #
# -------- #
# the Divisor
#vsim -t 1ps tb_Divisor

# the Multiplier/Divisor
#vsim -t 1ps tb_MultDiv

# the processor
vsim -t 1ps tb_r2000_cpu

do {r2000_Cpu.udo}

# The viewer
view wave
#add wave *
view signals

#Run the simulation
run -all
