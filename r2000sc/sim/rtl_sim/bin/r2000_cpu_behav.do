# ----------- #
# The library #
# ----------- #
vlib work

# -------- #
# The Core #
# -------- #
# The processor
vlog ../src/r2000_cpu_behavioral.v	+incdir+../inc

# ----------------------------- #
# The TestBench of the processor
# ----------------------------- #
vlog tb_r2000_cpu_behav.v			+incdir+../inc

# -------- #
# Simulate #
# -------- #
vsim tb_r2000_cpu_behav -pli watch_variable.dll

do {r2000_cpu_behav.udo}

# The viewer
view wave
#add wave *
view signals

#Run the simulation
run -all
