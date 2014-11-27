
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
-- Entity: CoreTest
-- Date: 2014-11-26
-- Author: Madhu
--
-- Description: 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
-- Avoid using ieee.std_logic_arith.all
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity CoreTest is
end CoreTest;

architecture arch of CoreTest is
    component Core
        port (
            reset : in std_logic;
            clock : in std_logic;
            load_en : in std_logic;
            pm_data_in : in std_logic_vector ( 16 - 1 downto 0 )
        );
    end component;

    signal reset : std_logic := '0';
    signal clock : std_logic := '0';
    signal load_en : std_logic := '0';
    signal pm_data_in : std_logic_vector ( 16 - 1 downto 0 );
    signal runSimulation : std_logic := '1';
begin

c : Core
port map(
    reset      => reset,
    clock      => clock,
    load_en    => load_en,
    pm_data_in => pm_data_in
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
        pm_data_in <= (others => '0');
        load_en <= '0';
        wait for 2 ns;
        reset <= '1';
        wait for 6 ns;
        reset <= '0';
    end doReset;

    procedure write_inst(dIn : std_logic_vector(16-1 downto 0)) is
    begin
        pm_data_in <= dIn;
        load_en <= '1';
        wait until rising_edge(clock);
        load_en <= '0';
    end write_inst;
begin
    doReset;
    write_inst(x"0001");
    write_inst(x"0002");
    write_inst(x"0003");
    write_inst(x"1a01");
    write_inst(x"0005");
    write_inst(x"0006");
    write_inst(x"0007");
    wait for 200 ns;
    runSimulation <= '0';
end process stimulus;

end arch;
