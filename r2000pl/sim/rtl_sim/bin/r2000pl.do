# ----------- #
# The library #
# ----------- #
vlib work

# -------- #
# The Core #
# -------- #
# The PCs
vlog ../../../rtl/verilog/r2000/r2000_pc.v				+incdir+../../../rtl/verilog/r2000

# The muxs
vlog ../../../rtl/verilog/r2000/r2000_mux2.v			+incdir+../../../rtl/verilog/r2000
vlog ../../../rtl/verilog/r2000/r2000_mux3.v			+incdir+../../../rtl/verilog/r2000
vlog ../../../rtl/verilog/r2000/r2000_mux4.v			+incdir+../../../rtl/verilog/r2000
vlog ../../../rtl/verilog/r2000/r2000_mux5.v			+incdir+../../../rtl/verilog/r2000
vlog ../../../rtl/verilog/r2000/r2000_mux7.v			+incdir+../../../rtl/verilog/r2000

# The pipeline regsiters
vlog ../../../rtl/verilog/r2000/r2000_pipe.v			+incdir+../../../rtl/verilog/r2000

# The pipeline controller
vlog ../../../rtl/verilog/r2000/r2000_pipe_ctrl.v		+incdir+../../../rtl/verilog/r2000

# The Compare unit
vlog ../../../rtl/verilog/r2000/r2000_comparator.v		+incdir+../../../rtl/verilog/r2000

# The Branch decode
vlog ../../../rtl/verilog/r2000/r2000_bradecoder.v		+incdir+../../../rtl/verilog/r2000

# The register file
vlog ../../../rtl/verilog/r2000/r2000_regfile.v			+incdir+../../../rtl/verilog/r2000

# The Alu
vlog ../../../rtl/verilog/r2000/r2000_aluctrl.v			+incdir+../../../rtl/verilog/r2000
vlog ../../../rtl/verilog/r2000/r2000_alu.v				+incdir+../../../rtl/verilog/r2000

# The Barrel Shifter
vlog ../../../rtl/verilog/r2000/r2000_shifter.v			+incdir+../../../rtl/verilog/r2000

# The Multiplier unit
vlog ../../../rtl/verilog/r2000/r2000_multiplier.v		+incdir+../../../rtl/verilog/r2000

# The Divisor unit
vlog ../../../rtl/verilog/r2000/r2000_divisor.v			+incdir+../../../rtl/verilog/r2000

# The Multiplier/Diviser module
vlog ../../../rtl/verilog/r2000/r2000_multdiv.v			+incdir+../../../rtl/verilog/r2000

# The instruction decoder
vlog ../../../rtl/verilog/r2000/r2000_decoder.v			+incdir+../../../rtl/verilog/r2000

# The memory interface
vlog ../../../rtl/verilog/r2000/r2000_membus.v			+incdir+../../../rtl/verilog/r2000

# The forward unit
vlog ../../../rtl/verilog/r2000/r2000_forward.v			+incdir+../../../rtl/verilog/r2000

# The processor core
vlog ../../../rtl/verilog/r2000/r2000_cpu_pipe.v		+incdir+../../../rtl/verilog/r2000

# The co-processor 0
vlog ../../../rtl/verilog/r2000/r2000_cp0.v				+incdir+../../../rtl/verilog/r2000

# The memory i-cache & d-cache
vlog ../../../rtl/verilog/r2000/r2000_i-cache.v			+incdir+../../../rtl/verilog/r2000
vlog ../../../rtl/verilog/r2000/r2000_d-cache.v			+incdir+../../../rtl/verilog/r2000

# The top of the processor
vlog ../../../rtl/verilog/r2000/r2000_cpu.v				+incdir+../../../rtl/verilog/r2000

# WISHBONE Conmax IP Core
vlog ../../../rtl/verilog/conmax/wb_conmax_top.v		+incdir+../../../rtl/verilog/conmax
vlog ../../../rtl/verilog/conmax/wb_conmax_master_if.v	+incdir+../../../rtl/verilog/conmax
vlog ../../../rtl/verilog/conmax/wb_conmax_slave_if.v	+incdir+../../../rtl/verilog/conmax
vlog ../../../rtl/verilog/conmax/wb_conmax_rf.v			+incdir+../../../rtl/verilog/conmax
vlog ../../../rtl/verilog/conmax/wb_conmax_arb.v		+incdir+../../../rtl/verilog/conmax
vlog ../../../rtl/verilog/conmax/wb_conmax_msel.v		+incdir+../../../rtl/verilog/conmax
vlog ../../../rtl/verilog/conmax/wb_conmax_pri_enc.v	+incdir+../../../rtl/verilog/conmax
vlog ../../../rtl/verilog/conmax/wb_conmax_pri_dec.v	+incdir+../../../rtl/verilog/conmax

# The Wishbone compatible Sram controler
vlog ../../../rtl/verilog/mem/asram_core.v				+incdir+../../../rtl/verilog/r2000

# The top of the soc
vlog ../../../rtl/verilog/r2000_soc.v					+incdir+../../../rtl/verilog/r2000

# The memories
vlog ../../../bench/verilog/SRAM.v						+incdir+../../../rtl/verilog/r2000
vlog ../../../bench/verilog/idt71v416s10.v				+incdir+../../../rtl/verilog/r2000

# --------------------------------- #
# The TestBench of the soc processor
# --------------------------------- #
vlog ../../../bench/verilog/tb_r2000_soc.v				+incdir+../../../rtl/verilog/r2000

# -------- #
# Simulate #
# -------- #
# the soc processor
vsim -t 1ps tb_r2000_soc

do {r2000pl_d-cache.udo}

# The viewer
view wave
#add wave *
view signals

#Run the simulation
run -all
