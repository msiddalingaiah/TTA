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
-- Entity: ArithmeticUnit
-- Date: 2014-12-02
-- Author: user
--
-- Description: 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
-- Avoid using ieee.std_logic_arith.all
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ArithmeticUnit is
    generic  (
        DATA_WIDTH : integer := 16;
        ADDRESS_WIDTH : integer := 3;
        DEPTH : natural := 32
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
end ArithmeticUnit;

architecture arch of ArithmeticUnit is

type StackType is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal stack : StackType;
signal s0 : std_logic_vector(DATA_WIDTH-1 downto 0);
signal sp : std_logic_vector(10-1 downto 0);
-- sp minus 1, avoids sp predecriment delay
signal spm1 : std_logic_vector(10-1 downto 0);

begin

data_out <= s0;

statemachine: block
	type state_type is (IDLE, RUNNING, DONE);
	signal state : state_type := IDLE;
begin
	process(clock, reset)
	begin
        if reset = '1' then
            state <= IDLE;
            sp <= (others => '0');
            spm1 <= (others => '1');
            s0 <= (others => '0');
        elsif rising_edge(clock) then
            case state is
                when IDLE =>
                    state <= RUNNING;
                when RUNNING =>
                    if read_enable = '1' then
                        case to_integer(unsigned(address)) is
                            -- pop
                            when 0 =>
                                s0 <= stack(to_integer(unsigned(spm1)));
                                sp <= sp - 1;
                                spm1 <= spm1 - 1;
                            when others =>

                        end case;
                    elsif write_enable = '1' then
                        case to_integer(unsigned(address)) is
                            -- push
                            when 0 =>
                                s0 <= data_in;
                                stack(to_integer(unsigned(sp))) <= s0;
                                sp <= sp + 1;
                                spm1 <= spm1 + 1;
                            -- operation
                            when 1 =>
                                case to_integer(unsigned(data_in)) is
                                    -- add
                                    when 0 =>
                                        s0 <= stack(to_integer(unsigned(spm1))) + s0;
                                        sp <= sp - 1;
                                        spm1 <= spm1 - 1;
                                    -- subtract
                                    when 1 =>
                                        s0 <= stack(to_integer(unsigned(spm1))) - s0;
                                        sp <= sp - 1;
                                        spm1 <= spm1 - 1;
                                    when others =>
        
                                end case;
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
