ghdl -a --ieee=synopsys ProgramMemory.vhd
ghdl -a --ieee=synopsys Core.vhd
ghdl -a --ieee=synopsys CoreTest.vhd
ghdl -e --ieee=synopsys CoreTest
ghdl -r --ieee=synopsys CoreTest --vcd=test.vcd
