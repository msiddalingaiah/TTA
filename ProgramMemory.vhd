
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
        ADDRESS_WIDTH : integer := 16;
		DEPTH : natural := 8192
	);
	port  (
		reset : in std_logic;
		clock : in std_logic;
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        pc_in : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        pc_out : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        memory_write : in std_logic;
        pc_write : in std_logic
	);
end ProgramMemory;

architecture arch of ProgramMemory is

type MemoryType is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal store : MemoryType;
-- Initialization to '0' avoids NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
signal program_counter : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

top: block
begin
    -- Asynchronous assignments
    pc_out <= program_counter;
    data_out <= store(to_integer(unsigned(program_counter)));
    
	process(clock, reset)
	begin
		if reset = '1' then
            program_counter <= (others => '0');
		elsif rising_edge(clock) then
            if pc_write = '1' then
                program_counter <= pc_in;
            else
                program_counter <= program_counter + 1;
            end if;
            if memory_write = '1' then
                store(to_integer(unsigned(program_counter))) <= data_in;
            end if;
        end if;
	end process;
end block;

end arch;
