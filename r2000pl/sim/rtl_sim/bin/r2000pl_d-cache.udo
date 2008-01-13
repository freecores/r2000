radix hex

add wave -noupdate -divider {System}
add wave sim:/tb_r2000_soc/clk
add wave sim:/tb_r2000_soc/rst

add wave -noupdate -divider {PC}
add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/IF_stall
add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/wPC
add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/ID_PCplus4
add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/ID_inst

add wave -noupdate -divider {CPU Code Memory Interface}
add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_code_addr_o
add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_code_inst_i
add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_code_hit_i
add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/ID_inst

add wave -noupdate -divider {CPU I-Cache}
add wave sim:/tb_r2000_soc/UUT/CPU/ICACHE/cpu_enable_i
add wave sim:/tb_r2000_soc/UUT/CPU/ICACHE/cpu_ready_o
add wave sim:/tb_r2000_soc/UUT/CPU/ICACHE/cpu_addr_i
add wave sim:/tb_r2000_soc/UUT/CPU/ICACHE/cpu_data_o
add wave sim:/tb_r2000_soc/UUT/CPU/ICACHE/cache_data
add wave sim:/tb_r2000_soc/UUT/CPU/wMem_code_hit

#add wave -noupdate -divider {CPU Data Memory Interface}
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_data_addr_o
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_data_data_i
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_data_data_o
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_data_hit_i
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_data_wr_o
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_data_rd_o
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_data_en_o
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_data_width_o

add wave -noupdate -divider {CPU D-Cache}
add wave sim:/tb_r2000_soc/UUT/CPU/DCACHE/cpu_enable_i
add wave sim:/tb_r2000_soc/UUT/CPU/DCACHE/cpu_write_i
add wave sim:/tb_r2000_soc/UUT/CPU/DCACHE/cpu_ready_o
add wave sim:/tb_r2000_soc/UUT/CPU/DCACHE/cpu_addr_i
add wave sim:/tb_r2000_soc/UUT/CPU/DCACHE/cpu_data_i
add wave sim:/tb_r2000_soc/UUT/CPU/DCACHE/cpu_data_o
add wave sim:/tb_r2000_soc/UUT/CPU/DCACHE/cpu_width_i
add wave sim:/tb_r2000_soc/UUT/CPU/DCACHE/cache_data
add wave sim:/tb_r2000_soc/UUT/CPU/wMem_data_hit


add wave -noupdate -divider {CPU RegFile}
add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/unit_regfile/rf_reg

#add wave -noupdate -divider {SRAM Memory}
#add wave sim:/tb_r2000_soc/MemDataAddr
#add wave sim:/tb_r2000_soc/MemData
#add wave sim:/tb_r2000_soc/SRAM_WRn
#add wave sim:/tb_r2000_soc/SRAM_RDn
#add wave sim:/tb_r2000_soc/SRAM_OEn
#add wave sim:/tb_r2000_soc/SRAM_CEn
#add wave sim:/tb_r2000_soc/SRAM_Bhel
#add wave sim:/tb_r2000_soc/SRAM_Blel
#add wave sim:/tb_r2000_soc/SRAM_Bheh
#add wave sim:/tb_r2000_soc/SRAM_Bleh

add wave -noupdate -divider {CPU PIPELINE}
add wave -radix hex sim:/tb_r2000_soc/UUT/CPU/COREPIPE/ID_inst
add wave -radix hex sim:/tb_r2000_soc/UUT/CPU/COREPIPE/EX_inst
add wave -radix hex sim:/tb_r2000_soc/UUT/CPU/COREPIPE/MEM_inst
add wave -radix hex sim:/tb_r2000_soc/UUT/CPU/COREPIPE/WB_inst

add wave -noupdate -divider {CP0}
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/unit_cp0/*

#add wave -noupdate -divider {DEBUG}
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mem_data_hit_i
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/wStop
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/wStall
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/EX_halt
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/MEM_halt
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/WB_halt

#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/unit_mem_to_reg/*

#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/ID_mux_rd_index_out
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/EX_rd_index
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/MEM_rd_index
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/WB_rd_index
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/ID_ctl_reg_write
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/EX_ctl_reg_write
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/MEM_ctl_reg_write
#add wave sim:/tb_r2000_soc/UUT/CPU/COREPIPE/WB_ctl_reg_write
#
#add wave -radix ascii sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mux_reg_w/*
#add wave -radix ascii sim:/tb_r2000_soc/UUT/CPU/COREPIPE/mux_reg_datain/*

update
WaveRestoreZoom {0 ps} {147554 ps}
                                   