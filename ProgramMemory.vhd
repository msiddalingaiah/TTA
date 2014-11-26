
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
-- Entity: ProgramMemory
-- Date: 2014-10-09
-- Author: Madhu
--
-- Description: 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
-- Avoid using ieee.std_logic_arith.all
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ProgramMemory is
	generic  (
		DATA_WIDTH : integer := 16;
        ADDRESS_WIDTH : integer := 3;
		DEPTH : natural := 1024
	);
	port  (
		reset : in std_logic;
		clock : in std_logic;
        address : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        read_enable : in std_logic;
        write_enable : in std_logic;
        busy : out std_logic
	);
end ProgramMemory;

architecture arch of ProgramMemory is

type MemoryType is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal store : MemoryType;
signal program_counter : std_logic_vector(DATA_WIDTH-1 downto 0);
signal jump_register : std_logic_vector(DATA_WIDTH-1 downto 0);
signal write_counter : std_logic_vector(DATA_WIDTH-1 downto 0);
signal local_address : std_logic_vector(ADDRESS_WIDTH-1 downto 0);

begin

local_address <= address(local_address'length-1 downto 0);

statemachine: block
	type state_type is (IDLE, RUNNING, DONE);
	signal state : state_type := IDLE;
begin
	process(clock, reset)
	begin
		if reset = '1' then
			state <= IDLE;
            program_counter <= (others => '0');
            jump_register <= (others => '0');
            write_counter <= (others => '0');
            data_out <= (others => '0');
            busy <= '0';
		elsif rising_edge(clock) then
			case state is
				when IDLE =>
					state <= RUNNING;
				when RUNNING =>
				    if read_enable = '1' then
                        case to_integer(unsigned(local_address)) is
                            -- NOP
                            when 0 =>
                            -- Read instruction
                            when 1 =>
                                data_out <= store(to_integer(unsigned(program_counter)));
                                program_counter <= program_counter + 1;
                            -- Read program counter
                            when 2 =>
                                data_out <= program_counter;
                            -- Read write counter
                            when 3 =>
                                data_out <= write_counter;
                            -- Read jump register
                            when 4 =>
                                data_out <= jump_register;
                            when others =>
                            
                        end case;
				    elsif write_enable = '1' then
                        case to_integer(unsigned(local_address)) is
                            -- NOP
                            when 0 =>
                            -- Write instruction
                            when 1 =>
                                store(to_integer(unsigned(write_counter))) <= data_in;
                                write_counter <= write_counter + 1;
                            -- Write program counter
                            when 2 =>
                                program_counter <= data_in;
                            -- Write write counter
                            when 3 =>
                                write_counter <= data_in;
                            -- Write write counter
                            when 4 =>
                                jump_register <= data_in;
                            -- Jump if zero
                            when 5 =>
                                if ieee.std_logic_unsigned."=" (data_in, x"0000") then
                                    program_counter <= jump_register;
                                end if;
                            -- Jump if non-zero
                            when 6 =>
                                if ieee.std_logic_unsigned."/=" (data_in, x"0000") then
                                    program_counter <= jump_register;
                                end if;
                            when others =>
                            
                        end case;
				    end if;
				when DONE =>
					state <= IDLE;
				when others =>
					state <= IDLE;
			end case;
		end if;
	end process;
end block;

end arch;
