create_clock -name clk -period 10.00 -waveform {0.0 5.0} [get_ports clk_i]
set_input_delay 1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk_i]]
#set_output_delay 1.0 -clock clk [all_outputs]
