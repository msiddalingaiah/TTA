ghdl -a --ieee=synopsys ProgramMemory.vhd
ghdl -a --ieee=synopsys ProgramMemoryTest.vhd
ghdl -e --ieee=synopsys ProgramMemoryTest
ghdl -r --ieee=synopsys ProgramMemoryTest --vcd=test.vcd
