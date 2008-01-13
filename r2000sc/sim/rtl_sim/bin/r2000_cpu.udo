radix hex

add wave sim:/tb_r2000_cpu/clk
add wave sim:/tb_r2000_cpu/rst

add wave sim:/tb_r2000_cpu/UUT/mem_code_addr_o
add wave sim:/tb_r2000_cpu/UUT/mem_code_inst_i
#add wave sim:/tb_r2000_cpu/UUT/inst_opcode   
add wave sim:/tb_r2000_cpu/UUT/rs_index
add wave sim:/tb_r2000_cpu/UUT/rt_index
add wave sim:/tb_r2000_cpu/UUT/rd_index                                
add wave sim:/tb_r2000_cpu/UUT/shamt
add wave sim:/tb_r2000_cpu/UUT/funct


add wave sim:/tb_r2000_cpu/UUT/unit_regfile/rf_reg


add wave sim:/tb_r2000_cpu/UUT/unit_multdiv/hi_reg
add wave sim:/tb_r2000_cpu/UUT/unit_multdiv/lo_reg
add wave sim:/tb_r2000_cpu/UUT/multdiv_interlock

add wave sim:/tb_r2000_cpu/MemDataCs
add wave sim:/tb_r2000_cpu/UUT/mem_data_addr_o                                   
add wave sim:/tb_r2000_cpu/UUT/mem_data_data_io
add wave sim:/tb_r2000_cpu/UUT/mem_data_wr_o
add wave sim:/tb_r2000_cpu/UUT/mem_data_rd_o
                                   