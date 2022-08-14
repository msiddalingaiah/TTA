
ghdl -a --ieee=synopsys ProgramMemory.vhd
ghdl -a --ieee=synopsys ProgramMemoryTest.vhd
ghdl -a --ieee=synopsys ArithmeticUnit.vhd
ghdl -a --ieee=synopsys ControlUnit.vhd
ghdl -a --ieee=synopsys ControlUnitTest.vhd
ghdl -e --ieee=synopsys ControlUnitTest

ghdl -r --ieee=synopsys ProgramMemoryTest --wave=programmemory.ghw
rem gtkwave programmemory.ghw

rem ghdl -r --ieee=synopsys ControlUnitTest --wave=controlunit.ghw
rem gtkwave controlunit.ghw
