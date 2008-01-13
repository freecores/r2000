radix hex

add wave -noupdate -divider {System}
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/clk
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/rst

add wave -noupdate -divider {I-Cache}
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/wStall
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/wPC
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/ID_PCplus4
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/ID_inst

add wave -noupdate -divider {CPU Code Memory Interface}
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/mem_code_addr_o
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/mem_code_inst_i
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/mem_code_hit_i
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/UUT/CPU/ID_inst

add wave -noupdate -divider {FLASH Memory}

add wave -noupdate -divider {SRAM Memory}
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/MemDataAddr
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/MemData
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/SRAM_WRn
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/SRAM_RDn
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/SRAM_OEn
add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/SRAM_CEn
#add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/SRAM_Bhel
#add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/SRAM_Blel
#add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/SRAM_Bheh
#add wave sim:/tb_r2000_cpu_soc_SRAMFLASH/SRAM_Bleh

update
WaveRestoreZoom {0 ps} {147554 ps}
                                   