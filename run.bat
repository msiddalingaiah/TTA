ghdl -a --ieee=synopsys ProgramMemory.vhd
ghdl -a --ieee=synopsys Core.vhd
ghdl -a --ieee=synopsys CoreTest.vhd
ghdl -e --ieee=synopsys CoreTest
ghdl -r --ieee=synopsys CoreTest --vcd=coretest.vcd

rem vcd format does not show enumerated types (e.g. state)
ghdl -r --ieee=synopsys CoreTest --wave=coretest.ghw
