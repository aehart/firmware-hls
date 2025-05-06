# 240 MHz
#create_clock -period 4.166 -name clk -waveform {0.000 2.080} [get_ports clk]

# 360 MHz
create_clock -period 2.777 -name clk -waveform {0.000 2.080} [get_ports clk]
