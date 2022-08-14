
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
-- Entity: ProgramMemoryTest
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

entity ProgramMemoryTest is
    generic  (
        DATA_WIDTH : integer := 16;
        ADDRESS_WIDTH : integer := 16;
        DEPTH : natural := 1024
    );
end ProgramMemoryTest;

architecture arch of ProgramMemoryTest is
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

    signal reset : std_logic := '0';
    signal clock : std_logic := '0';
    signal data_in : std_logic_vector (DATA_WIDTH - 1 downto 0 );
    signal pc_in : std_logic_vector (ADDRESS_WIDTH - 1 downto 0 );
    signal data_out : std_logic_vector (DATA_WIDTH - 1 downto 0 );
    signal pc_out : std_logic_vector (ADDRESS_WIDTH - 1 downto 0 );
    signal memory_write : std_logic;
    signal pc_write : std_logic;
    signal runSimulation : std_logic := '1';
begin

dut : ProgramMemory
generic map(
    DATA_WIDTH      => DATA_WIDTH,
    ADDRESS_WIDTH   => ADDRESS_WIDTH,
    DEPTH => DEPTH
)
port map(
    reset      => reset,
    clock      => clock,
    data_in    => data_in,
    pc_in      => pc_in,
    data_out   => data_out,
    pc_out     => pc_out,
    memory_write => memory_write,
    pc_write   => pc_write
);

process begin
    wait for 5 ns;
    clock <= not clock;
    if runSimulation = '0' then
        wait;
    end if;
end process;

stimulus : process
    procedure doReset is begin
        pc_in <= (others => '0');
        data_in <= (others => '0');
        pc_write <= '0';
        memory_write <= '0';
        wait for 2 ns;
        reset <= '1';
        wait for 6 ns;
        reset <= '0';
    end doReset;

    procedure write_inst(dIn : std_logic_vector(DATA_WIDTH-1 downto 0)) is
    begin
        data_in <= dIn;
        memory_write <= '1';
        wait until rising_edge(clock);
        memory_write <= '0';
    end write_inst;
begin
    doReset;
    wait until rising_edge(clock);
    write_inst(x"000a");
    write_inst(x"000b");
    write_inst(x"000c");
    write_inst(x"000d");

    pc_in <= (others => '0');
    pc_write <= '1';
    wait until rising_edge(clock);
    pc_write <= '0';

    wait until rising_edge(clock);
    wait until rising_edge(clock);
    wait until rising_edge(clock);
    wait until rising_edge(clock);
    wait until rising_edge(clock);

    runSimulation <= '0';
    wait;
end process stimulus;

end arch;
