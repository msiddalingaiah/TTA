
--------------------------------------------------------------------------------
-- Copyright 2014 Madhu Siddalingaiah
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Entity: ControlUnit
-- Date: 2014-10-31
-- Author: Madhu
--
-- Description: 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
-- Avoid using ieee.std_logic_arith.all
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ControlUnit is
    generic  (
        DATA_WIDTH : integer := 16;
        PM_DEPTH : natural := 16
    );
    port  (
        reset : in std_logic;
        clock : in std_logic;
        load_enable : in std_logic;
        run_enable : in std_logic;
        pm_data_in : in std_logic_vector ( 16 - 1 downto 0 );
        halt_flag : out std_logic
    );
end ControlUnit;

-- f ddddddd ssssssss
-- 1 module  module
-- 0 module  immediate
-- module 0 - prefix

architecture arch of ControlUnit is
    component ProgramMemory
        generic (
            DATA_WIDTH : integer;
            ADDRESS_WIDTH : integer;
            DEPTH : natural
        );
        port (
            reset : in std_logic;
            clock : in std_logic;
            data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            pc_in : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
            pc_out : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
            memory_write : in std_logic;
            pc_write : in std_logic
        );
    end component;

    component ArithmeticUnit
        generic (
            DATA_WIDTH : integer;
            ADDRESS_WIDTH : integer;
            DEPTH : natural
        );
        port (
            reset : in std_logic;
            clock : in std_logic;
            address : in std_logic_vector ( ADDRESS_WIDTH - 1 downto 0 );
            data_in : in std_logic_vector ( DATA_WIDTH - 1 downto 0 );
            data_out : out std_logic_vector ( DATA_WIDTH - 1 downto 0 );
            read_enable : in std_logic;
            write_enable : in std_logic;
            busy : out std_logic
        );
    end component;

    constant SUBSYSTEM_WIDTH : integer := 3;

    constant DEST_BASE : integer := 8;
    constant UNIT_WIDTH : integer := 4;
    constant IMM_BIT : integer := DEST_BASE+3;
    constant SHORT_IMM_BIT : integer := DEST_BASE-1;
    constant SHORT_IMM_WIDTH : integer := SHORT_IMM_BIT-1;

    constant UNIT_PM : integer := 1;
    constant UNIT_ARITH : integer := 2;
    constant NUM_UNITS : integer := 16;

    type DataBusArray is array (NUM_UNITS-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type AddrBusArray is array (NUM_UNITS-1 downto 0) of std_logic_vector(SUBSYSTEM_WIDTH-1 downto 0);

    signal data_in, data_out : DataBusArray;
    signal address : AddrBusArray;
    signal read_enable, write_enable, busy : std_logic_vector(0 to NUM_UNITS-1);

    signal instruction, code_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal l_reset, l_clock, code_read_enable : std_logic;
begin

au : ArithmeticUnit
generic map(
    DATA_WIDTH    => DATA_WIDTH,
    ADDRESS_WIDTH => SUBSYSTEM_WIDTH,
    DEPTH         => 32
)
port map(
    reset         => l_reset,
    clock         => l_clock,
    address       => address(UNIT_ARITH),
    data_in       => data_in(UNIT_ARITH),
    data_out      => data_out(UNIT_ARITH),
    read_enable   => read_enable(UNIT_ARITH),
    write_enable  => write_enable(UNIT_ARITH),
    busy          => busy(UNIT_ARITH)
);

statemachine: block
	type state_type is (LOAD, PREFETCH, EXEC, HALT);
    signal state : state_type := LOAD;
    signal dest_sub_system, src_sub_system : std_logic_vector( SUBSYSTEM_WIDTH - 1 downto 0 );
    signal short_immediate : std_logic_vector( SHORT_IMM_WIDTH - 1 downto 0 );
    signal imm_flag, long_imm_flag : std_logic;
begin
    l_reset <= reset;
    l_clock <= clock;
    imm_flag <= instruction(IMM_BIT);
    long_imm_flag <= instruction(SHORT_IMM_BIT);
    short_immediate <= instruction(SHORT_IMM_WIDTH - 1 downto 0);
    dest_sub_system <= instruction(IMM_BIT - 1 downto DEST_BASE);
    src_sub_system <= instruction(SUBSYSTEM_WIDTH - 1 downto 0);
    
	process(clock, reset)
        variable dest_unit, src_unit : integer;
	begin
		if reset = '1' then
			state <= LOAD;
			halt_flag <= '0';
            code_read_enable <= '0';
            read_enable <= (others => '0');
            write_enable <= (others => '0');
		elsif rising_edge(clock) then
            read_enable <= (others => '0');
            write_enable <= (others => '0');
			case state is
				when LOAD =>
				    if load_enable = '0' and run_enable = '1' then
    					state <= PREFETCH;
					elsif load_enable = '1' then
                        address(UNIT_PM) <= std_logic_vector(to_unsigned(1, address(UNIT_PM)'length));
                        data_in(UNIT_PM) <= pm_data_in;
                        write_enable(UNIT_PM) <= '1';
					end if;
                when PREFETCH =>
                    state <= EXEC;
                    code_read_enable <= '1';
				when EXEC =>
                    if to_integer(unsigned(instruction(DATA_WIDTH - 1 downto 0))) = 1 then
                        state <= HALT;
                    else
                        state <= EXEC;
                        src_unit  := to_integer(unsigned(instruction(DEST_BASE - 1 downto UNIT_WIDTH)));
                        dest_unit := to_integer(unsigned(instruction(DATA_WIDTH - 1 downto IMM_BIT+1)));
                        address(dest_unit) <= dest_sub_system;
                        if imm_flag = '1' then
                            if long_imm_flag = '0' then
                                data_in(dest_unit) <= std_logic_vector(resize(signed(short_immediate), data_in(dest_unit)'length));
                            else
                                address(UNIT_PM) <= std_logic_vector(to_unsigned(1, address(UNIT_PM)'length));
                                read_enable(UNIT_PM) <= '1';
                                data_in(dest_unit) <= data_out(UNIT_PM);
                            end if;
                        else
                            address(src_unit) <= src_sub_system;
                            read_enable(src_unit) <= '1';
                            data_in(dest_unit) <= data_out(src_unit);
                        end if;
                        write_enable(dest_unit) <= '1';
                    end if;
				when HALT =>
                    halt_flag <= '1';
				when others =>
					state <= HALT;
			end case;
		end if;
	end process;
end block;

end arch;
