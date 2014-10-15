
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
        ADDRESS_WIDTH : integer := 4;
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
            address : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
            data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
            read_enable : in std_logic;
            write_enable : in std_logic;
            busy : out std_logic
        );
    end component;

    signal reset : std_logic := '0';
    signal clock : std_logic := '0';
    signal address : std_logic_vector (ADDRESS_WIDTH - 1 downto 0 );
    signal data_in : std_logic_vector (DATA_WIDTH - 1 downto 0 );
    signal data_out : std_logic_vector (DATA_WIDTH - 1 downto 0 );
    signal read_enable : std_logic;
    signal write_enable : std_logic;
    signal busy : std_logic;
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
    address  => address,
    data_in  => data_in,
    data_out    => data_out,
    read_enable => read_enable,
    write_enable => write_enable,
    busy => busy
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
        address <= (others => '0');
        data_in <= (others => '0');
        read_enable <= '0';
        write_enable <= '0';
        wait for 2 ns;
        reset <= '1';
        wait for 6 ns;
        reset <= '0';
    end doReset;

    procedure write_inst(dIn : std_logic_vector(DATA_WIDTH-1 downto 0)) is
    begin
        data_in <= dIn;
        address <= x"0";
        write_enable <= '1';
        wait until rising_edge(clock);
        write_enable <= '0';
    end write_inst;

    procedure read_inst is
    begin
        address <= x"0";
        read_enable <= '1';
        wait until rising_edge(clock);
        read_enable <= '0';
    end read_inst;
begin
    doReset;
    wait until rising_edge(clock);
    write_inst(x"000a");
    write_inst(x"000b");
    write_inst(x"000c");
    write_inst(x"000d");
    read_inst;
    read_inst;
    read_inst;
    read_inst;
    read_inst;
    runSimulation <= '0';
    wait;
end process stimulus;

end arch;
