radix hex

add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/clk
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/rst


add wave -noupdate -divider {Forward}
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/ID_reg_rt
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/ID_reg_rs
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/EX_result_operation
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/MEM_result_operation

add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/ID_reg_rt_forward

add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/ID_reg_rs_forward

add wave -noupdate -divider {RegisterFile}
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/unit_regfile/rf_reg

#add wave -noupdate -divider {MultDiv}
#add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/unit_multdiv/hi_reg
#add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/unit_multdiv/lo_reg
#add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/EX_multdiv_ready
#add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/multdiv_interlock

add wave -noupdate -divider {Code Memory}
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/mem_code_addr_o
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/mem_code_inst_i
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/ID_inst

add wave -noupdate -divider {Data Memory}
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/mem_data_addr_o                                   
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/mem_data_data_i
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/mem_data_data_o
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/mem_data_wr_o
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/mem_data_rd_o

update
WaveRestoreZoom {0 ps} {147554 ps}
                                   