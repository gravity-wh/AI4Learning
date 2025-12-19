# ============================================================================
# File: timing.xdc
# Description: Timing Constraints for ARM Cortex-A9 Core on Zynq-7000
# Course: 05_ARM_Cortex_A9 - AI4ICLearning
# ============================================================================

# ============================================================================
# 时钟约束
# ============================================================================

# 主时钟 100 MHz
create_clock -period 10.000 -name clk [get_ports clk]

# 时钟不确定性
set_clock_uncertainty -setup 0.3 [get_clocks clk]
set_clock_uncertainty -hold 0.1 [get_clocks clk]

# ============================================================================
# 复位约束
# ============================================================================

# 异步复位作为假路径
set_false_path -from [get_ports rst_n]

# ============================================================================
# 输入延迟约束
# ============================================================================

# 指令存储器接口
set_input_delay -clock clk -max 3.0 [get_ports imem_rdata[*]]
set_input_delay -clock clk -min 0.5 [get_ports imem_rdata[*]]
set_input_delay -clock clk -max 3.0 [get_ports imem_valid]
set_input_delay -clock clk -min 0.5 [get_ports imem_valid]

# 数据存储器接口
set_input_delay -clock clk -max 3.0 [get_ports dmem_rdata[*]]
set_input_delay -clock clk -min 0.5 [get_ports dmem_rdata[*]]
set_input_delay -clock clk -max 3.0 [get_ports dmem_valid]
set_input_delay -clock clk -min 0.5 [get_ports dmem_valid]

# ============================================================================
# 输出延迟约束
# ============================================================================

# 指令存储器接口
set_output_delay -clock clk -max 2.0 [get_ports imem_req]
set_output_delay -clock clk -min 0.5 [get_ports imem_req]
set_output_delay -clock clk -max 2.0 [get_ports imem_addr[*]]
set_output_delay -clock clk -min 0.5 [get_ports imem_addr[*]]

# 数据存储器接口
set_output_delay -clock clk -max 2.0 [get_ports dmem_req]
set_output_delay -clock clk -min 0.5 [get_ports dmem_req]
set_output_delay -clock clk -max 2.0 [get_ports dmem_we]
set_output_delay -clock clk -min 0.5 [get_ports dmem_we]
set_output_delay -clock clk -max 2.0 [get_ports dmem_addr[*]]
set_output_delay -clock clk -min 0.5 [get_ports dmem_addr[*]]
set_output_delay -clock clk -max 2.0 [get_ports dmem_wdata[*]]
set_output_delay -clock clk -min 0.5 [get_ports dmem_wdata[*]]
set_output_delay -clock clk -max 2.0 [get_ports dmem_byte_en[*]]
set_output_delay -clock clk -min 0.5 [get_ports dmem_byte_en[*]]

# ============================================================================
# 多周期路径约束
# ============================================================================

# 乘法器多周期路径 (如果实现)
# set_multicycle_path -setup 2 -from [get_cells */u_mul/*] -to [get_cells */ex_mem_*]
# set_multicycle_path -hold 1 -from [get_cells */u_mul/*] -to [get_cells */ex_mem_*]

# ============================================================================
# 物理约束 (可选)
# ============================================================================

# 将关键模块放置在特定区域以优化时序
# create_pblock pblock_exu
# add_cells_to_pblock [get_pblocks pblock_exu] [get_cells -hierarchical u_exu]
# resize_pblock [get_pblocks pblock_exu] -add {SLICE_X0Y0:SLICE_X20Y20}

# ============================================================================
# 时序例外
# ============================================================================

# CDC (跨时钟域) 路径 - 如果使用多个时钟
# set_false_path -from [get_clocks clk_a] -to [get_clocks clk_b]

# ============================================================================
# 调试约束
# ============================================================================

# 保留调试信号
# set_property MARK_DEBUG true [get_nets {u_dut/pc[*]}]
# set_property MARK_DEBUG true [get_nets {u_dut/if_id_instr[*]}]
