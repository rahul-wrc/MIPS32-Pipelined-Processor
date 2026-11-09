# Starting constraints for SKY130 HD. Loosen/tighten CLK_PERIOD after the first STA run.
set clk_period 15.0
create_clock -name clk -period $clk_period [get_ports clk]
set_clock_uncertainty 0.25 [get_clocks clk]

set io_delay [expr {$clk_period * 0.2}]
set_input_delay  $io_delay -clock clk [get_ports rst]
set_output_delay $io_delay -clock clk [get_ports {debug_pc[*] debug_alu_result[*] debug_writeback_data[*]}]
