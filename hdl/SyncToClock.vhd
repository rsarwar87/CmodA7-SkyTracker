-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- =============================================================================
-- Authors:         Steffen Koehler
--                  Patrick Lehmann
--
-- Entity:          Synchronizes a signal vector across clock-domain boundaries
--
-- Description:
-- -------------------------------------
-- This module synchronizes a vector of bits from clock-domain ``Clock1`` to
-- clock-domain ``Clock2``. The clock-domain boundary crossing is done by a
-- change comparator, a T-FF, two synchronizer D-FFs and a reconstructive
-- XOR indicating a value change on the input. This changed signal is used
-- to capture the input for the new output. A busy flag is additionally
-- calculated for the input clock domain.
--
-- Constraints:
--   This module uses sub modules which need to be constrained. Please
--   attend to the notes of the instantiated sub modules.
--
-- License:
-- =============================================================================
-- Copyright 2007-2015 Technische Universitaet Dresden - Germany
--                     Chair of VLSI-Design, Diagnostics and Architecture
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- =============================================================================
library IEEE;
use     IEEE.STD_LOGIC_1164.all;
use     IEEE.NUMERIC_STD.all;


package sync is
	subtype T_MISC_SYNC_DEPTH    is integer range 2 to 16;

	component sync_Bits is
		generic (
			BITS          : positive            := 1;                     -- number of bit to be synchronized
			INIT          : std_logic_vector    := x"00000000";           -- initialization bits
			SYNC_DEPTH    : T_MISC_SYNC_DEPTH   := T_MISC_SYNC_DEPTH'low  -- generate SYNC_DEPTH many stages, at least 2
		);
		port (
			Clock         : in  std_logic;                                -- <Clock>  output clock domain
			Input         : in  std_logic_vector(BITS - 1 downto 0);      -- @async:  input bits
			Output        : out std_logic_vector(BITS - 1 downto 0)       -- @Clock:  output bits
		);
	end component;

	function descend(vec : std_logic_vector) return std_logic_vector;
	 function resize(vec : bit_vector; length : natural; fill : bit := '0')
    return bit_vector;
    function resize(vec : std_logic_vector; length : natural; fill : std_logic := '0')
    return std_logic_vector;
    function imin(arg1 : integer; arg2 : integer) return integer;		-- Calculates: min(arg1, arg2) for integers
end package;
package body sync is
	function imin(arg1 : integer; arg2 : integer) return integer is
	begin
		if arg1 < arg2 then return arg1; end if;
		return arg2;
	end function;
 function descend(vec : std_logic_vector)	return std_logic_vector is
		variable  res : std_logic_vector(vec'high downto vec'low);
	begin
		res := vec;
		return  res;
	end function;
	
		function resize(vec : bit_vector; length : natural; fill : bit := '0') return bit_vector is
    constant  high2b : natural := vec'low+length-1;
		constant  highcp : natural := imin(vec'high, high2b);
    variable  res_up : bit_vector(vec'low to high2b);
    variable  res_dn : bit_vector(high2b downto vec'low);
	begin
    if vec'ascending then
      res_up := (others => fill);
      res_up(vec'low to highcp) := vec(vec'low to highcp);
      return  res_up;
    else
      res_dn := (others => fill);
      res_dn(highcp downto vec'low) := vec(highcp downto vec'low);
      return  res_dn;
		end if;
	end function;

	function resize(vec : std_logic_vector; length : natural; fill : std_logic := '0') return std_logic_vector is
    constant  high2b : natural := vec'low+length-1;
		constant  highcp : natural := imin(vec'high, high2b);
    variable  res_up : std_logic_vector(vec'low to high2b);
    variable  res_dn : std_logic_vector(high2b downto vec'low);
	begin
    if vec'ascending then
      res_up := (others => fill);
      res_up(vec'low to highcp) := vec(vec'low to highcp);
      return  res_up;
    else
      res_dn := (others => fill);
      res_dn(highcp downto vec'low) := vec(highcp downto vec'low);
      return  res_dn;
		end if;
	end function;
end package body;
library IEEE;
use     IEEE.STD_LOGIC_1164.all;
use     IEEE.NUMERIC_STD.all;
use     work.sync.all;
entity sync_Bits is
  generic (
    BITS          : positive            := 1;                       -- number of bit to be synchronized
    INIT          : std_logic_vector    := x"00000000";             -- initialization bits
    SYNC_DEPTH    : T_MISC_SYNC_DEPTH   := T_MISC_SYNC_DEPTH'low    -- generate SYNC_DEPTH many stages, at least 2
  );
  port (
    Clock         : in  std_logic;                                  -- <Clock>  output clock domain
    Input         : in  std_logic_vector(BITS - 1 downto 0);        -- @async:  input bits
    Output        : out std_logic_vector(BITS - 1 downto 0)         -- @Clock:  output bits
  );
end entity;


architecture rtl of sync_Bits is
  constant INIT_I    : std_logic_vector    := resize(descend(INIT), BITS);
    attribute ASYNC_REG              : string;
    attribute SHREG_EXTRACT          : string;

  begin
    gen : for i in 0 to BITS - 1 generate
      signal Data_async              : std_logic;
      signal Data_meta              : std_logic                                    := INIT_I(i);
      signal Data_sync              : std_logic_vector(SYNC_DEPTH - 1 downto 1)    := (others => INIT_I(i));

      -- Mark register DataSync_async's input as asynchronous and ignore timings (TIG)
      attribute ASYNC_REG      of Data_meta  : signal is "TRUE";

      -- Prevent XST from translating two FFs into SRL plus FF
      attribute SHREG_EXTRACT of Data_meta  : signal is "NO";
      attribute SHREG_EXTRACT of Data_sync  : signal is "NO";

    begin
      Data_async      <= Input(i);

      process(Clock)
      begin
        if rising_edge(Clock) then
          Data_meta    <= Data_async;
          Data_sync    <= Data_sync(Data_sync'high - 1 downto 1) & Data_meta;
        end if;
      end process;

      Output(i)  <= Data_sync(Data_sync'high);
    end generate;
end architecture;

library IEEE;
use     IEEE.STD_LOGIC_1164.all;
use     IEEE.NUMERIC_STD.all;
use     work.sync.all;
entity sync_Vector is
	generic (
		MASTER_BITS   : positive            := 8;                       -- number of bit to be synchronized
		SLAVE_BITS    : natural             := 0;
		INIT          : std_logic_vector    := x"00000000";             --
		SYNC_DEPTH    : T_MISC_SYNC_DEPTH   := T_MISC_SYNC_DEPTH'low    -- generate SYNC_DEPTH many stages, at least 2
	);
	port (
		Clock1        : in  std_logic;                                                  -- <Clock>  input clock
		Clock2        : in  std_logic;                                                  -- <Clock>  output clock
		Input         : in  std_logic_vector((MASTER_BITS + SLAVE_BITS) - 1 downto 0);  -- @Clock1:  input vector
		Output        : out std_logic_vector((MASTER_BITS + SLAVE_BITS) - 1 downto 0);  -- @Clock2:  output vector
		Busy          : out  std_logic;                                                 -- @Clock1:  busy bit
		Changed       : out  std_logic                                                  -- @Clock2:  changed bit
	);
end entity;


architecture rtl of sync_Vector is
    component sync_Bits is
      generic (
        BITS          : positive            := 1;                       -- number of bit to be synchronized
        INIT          : std_logic_vector    := x"00000000";             -- initialization bits
        SYNC_DEPTH    : T_MISC_SYNC_DEPTH   := T_MISC_SYNC_DEPTH'low    -- generate SYNC_DEPTH many stages, at least 2
      );
      port (
        Clock         : in  std_logic;                                  -- <Clock>  output clock domain
        Input         : in  std_logic_vector(BITS - 1 downto 0);        -- @async:  input bits
        Output        : out std_logic_vector(BITS - 1 downto 0)         -- @Clock:  output bits
      );
    end component;

	attribute SHREG_EXTRACT        : string;

	constant INIT_I                : std_logic_vector := descend(INIT)((MASTER_BITS + SLAVE_BITS) - 1 downto 0);

	signal D0                      : std_logic_vector((MASTER_BITS + SLAVE_BITS) - 1 downto 0)    := INIT_I;
	signal T1                      : std_logic                                                    := '0';
	signal D2                      : std_logic                                                    := '0';
	signal D3                      : std_logic                                                    := '0';
	signal D4                      : std_logic_vector((MASTER_BITS + SLAVE_BITS) - 1 downto 0)    := INIT_I;

	signal Changed_Clk1            : std_logic;
	signal Changed_Clk2            : std_logic;
	signal Busy_i                  : std_logic;

	-- Prevent XST from translating two FFs into SRL plus FF
	attribute SHREG_EXTRACT of D0  : signal is "NO";
	attribute SHREG_EXTRACT of T1  : signal is "NO";
	attribute SHREG_EXTRACT of D2  : signal is "NO";
	attribute SHREG_EXTRACT of D3  : signal is "NO";
	attribute SHREG_EXTRACT of D4  : signal is "NO";

	signal syncClk1_In    : std_logic;
	signal syncClk1_Out   : std_logic;
	signal syncClk2_In    : std_logic;
	signal syncClk2_Out   : std_logic;

begin
	-- input D-FF @Clock1 -> changed detection
	process(Clock1)
	begin
		if rising_edge(Clock1) then
			if (Busy_i = '0') then
				D0  <= Input;                  -- delay input vector for change detection; gated by busy flag
				T1  <= T1 xor Changed_Clk1;    -- toggle T1 if input vector has changed
			end if;
		end if;
	end process;

	-- D-FF for level change detection (both edges)
	process(Clock2)
	begin
		if rising_edge(Clock2) then
			D2 <= syncClk2_Out;
			D3 <= Changed_Clk2;

			if (Changed_Clk2 = '1') then
				D4 <= D0;
			end if;
		end if;
	end process;

	-- assign syncClk*_In signals
	syncClk2_In   <= T1;
	syncClk1_In   <= D2;

	Changed_Clk1  <='0' when (D0(MASTER_BITS - 1 downto 0) = Input(MASTER_BITS - 1 downto 0)) else '1'; -- input change detection
	Changed_Clk2  <= syncClk2_Out xor D2;                                                               -- level change detection; restore strobe signal from flag
	Busy_i        <= T1 xor syncClk1_Out;                                                               -- calculate busy signal

	-- output signals
	Output        <= D4;
	Busy          <= Busy_i;
	Changed       <= D3;

	syncClk2 : sync_Bits
		generic map (
			BITS        => 1,           -- number of bit to be synchronized
			SYNC_DEPTH  => SYNC_DEPTH
		)
		port map (
			Clock     => Clock2,        -- <Clock>  output clock domain
			Input(0)  => syncClk2_In,   -- @async:  input bits
			Output(0) => syncClk2_Out   -- @Clock:  output bits
		);

	syncClk1 : sync_Bits
		generic map (
			BITS        => 1,           -- number of bit to be synchronized
			SYNC_DEPTH  => SYNC_DEPTH
		)
		port map (
			Clock     => Clock1,        -- <Clock>  output clock domain
			Input(0)  => syncClk1_In,   -- @async:  input bits
			Output(0) => syncClk1_Out   -- @Clock:  output bits
		);
end architecture;