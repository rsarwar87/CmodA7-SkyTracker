----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/29/2020 12:09:47 PM
-- Design Name: 
-- Module Name: ClockDomainSync - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ClockDomainSync is
  Port ( 
     
	 clk_50 : in STD_LOGIC := '0';
     clk_150 : in STD_LOGIC := '0';
     
     pec_data : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     pec_encoder : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     iic_pec_encoder : in STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
     pec_data_synced : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     pec_encoder_synced : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     iic_pec_encoder_synced : out STD_LOGIC_VECTOR (11 downto 0) := (others => '0');
           
     ra_step_count 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     ra_status     		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     ra_cmdcontrol 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
     ra_cmdtick           : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     ra_cmdduration 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     ra_backlash_tick 	 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
     ra_backlash_duration : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     ra_counter_load 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     ra_counter_max 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     ra_trackctrl 			 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    
     de_step_count 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     de_status     		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     de_cmdcontrol 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
     de_cmdtick           : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     de_cmdduration 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     de_backlash_tick 	 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
     de_backlash_duration : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     de_counter_load 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     de_counter_max 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     de_trackctrl 			 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     
     fc_step_count 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     fc_status     		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     fc_cmdcontrol 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
     fc_cmdtick           : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     fc_cmdduration 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     fc_backlash_tick 	 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
     fc_backlash_duration : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     fc_counter_load 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     fc_counter_max 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     fc_trackctrl 			 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    
     is_tmc_buf              : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     is_tmc_sync              : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    
     fc_step_count_sync 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     fc_status_sync     		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     fc_cmdcontrol_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
     fc_cmdtick_sync           : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     fc_cmdduration_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     fc_backlash_tick_sync 	 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
     fc_backlash_duration_sync : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     fc_counter_load_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     fc_counter_max_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     fc_trackctrl_sync 			 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    
     ra_step_count_sync 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     ra_status_sync     		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     ra_cmdcontrol_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
     ra_cmdtick_sync           : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     ra_cmdduration_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     ra_backlash_tick_sync 	 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
     ra_backlash_duration_sync : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     ra_counter_load_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     ra_counter_max_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     ra_trackctrl_sync 			 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    
     de_step_count_sync 		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     de_status_sync     		 : in STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
     de_cmdcontrol_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
     de_cmdtick_sync           : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     de_cmdduration_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
     de_backlash_tick_sync 	 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
     de_backlash_duration_sync : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     de_counter_load_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     de_counter_max_sync 		 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
     de_trackctrl_sync 			 : out STD_LOGIC_VECTOR (31 downto 0) := (others => '0')
  );
end ClockDomainSync;

architecture Behavioral of ClockDomainSync is
subtype T_MISC_SYNC_DEPTH    is integer range 2 to 16;
    component sync_Vector is
	generic (
		MASTER_BITS   : positive            := 8;                       -- number of bit to be synchronized
		SLAVE_BITS    : natural             := 0;
		INIT          : std_logic_vector    := x"00000000";             --
		SYNC_DEPTH    : T_MISC_SYNC_DEPTH   := 2    -- generate SYNC_DEPTH many stages, at least 2
	);
	port (
		Clock1        : in  std_logic;                                                  -- <Clock>  input clock
		Clock2        : in  std_logic;                                                  -- <Clock>  output clock
		Input         : in  std_logic_vector((MASTER_BITS + SLAVE_BITS) - 1 downto 0);  -- @Clock1:  input vector
		Output        : out std_logic_vector((MASTER_BITS + SLAVE_BITS) - 1 downto 0);  -- @Clock2:  output vector
		Busy          : out  std_logic;                                                 -- @Clock1:  busy bit
		Changed       : out  std_logic                                                  -- @Clock2:  changed bit
	);
    end component;
signal tmp :std_logic;
begin
    SyncBusToClock_pecdata : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_50 ,                                                  -- <Clock>  input clock
		Clock2        => clk_150,                                                 -- <Clock>  output clock
		Input         => pec_data_synced,   -- @Clock1:  input vector
		Output        => pec_data,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );

    SyncBusToClock_pec_encoder : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => pec_encoder,   -- @Clock1:  input vector
		Output        => pec_encoder_synced ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );

    SyncBusToClock_iic_pec_encoder : sync_Vector 
      generic map (
        MASTER_BITS => 12, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => iic_pec_encoder,   -- @Clock1:  input vector
		Output        => iic_pec_encoder_synced ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
    SyncBusToClock_istmc2226 : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150 ,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => is_tmc_buf,   -- @Clock1:  input vector
		Output        => is_tmc_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );

    SyncBusToClock_de_step_count : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_50,                                                  -- <Clock>  input clock
		Clock2        => clk_150,                                                 -- <Clock>  output clock
		Input         => de_step_count_sync,   -- @Clock1:  input vector
		Output        => de_step_count ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
      SyncBusToClock_fc_step_count : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_50,                                                  -- <Clock>  input clock
		Clock2        => clk_150,                                                 -- <Clock>  output clock
		Input         => fc_step_count_sync,   -- @Clock1:  input vector
		Output        => fc_step_count ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
    SyncBusToClock_de_status : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_50,                                                  -- <Clock>  input clock
		Clock2        => clk_150,                                                 -- <Clock>  output clock
		Input         => de_status_sync,   -- @Clock1:  input vector
		Output        => de_status ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
    SyncBusToClock_fc_status : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_50,                                                  -- <Clock>  input clock
		Clock2        => clk_150,                                                 -- <Clock>  output clock
		Input         => fc_status_sync,   -- @Clock1:  input vector
		Output        => fc_status ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_ra_step_count : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_50,                                                  -- <Clock>  input clock
		Clock2        => clk_150,                                                 -- <Clock>  output clock
		Input         => ra_step_count_sync,   -- @Clock1:  input vector
		Output        => ra_step_count ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_ra_status : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_50,                                                  -- <Clock>  input clock
		Clock2        => clk_150,                                                 -- <Clock>  output clock
		Input         => ra_status_sync,   -- @Clock1:  input vector
		Output        => ra_status ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );

    
     SyncBusToClock_de_cmdcontrol : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => de_cmdcontrol,   -- @Clock1:  input vector
		Output        => de_cmdcontrol_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_de_cmdtick_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => de_cmdtick,   -- @Clock1:  input vector
		Output        => de_cmdtick_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_de_cmdduration : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => de_cmdduration,   -- @Clock1:  input vector
		Output        => de_cmdduration_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_de_backlash_tick : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => de_backlash_tick,   -- @Clock1:  input vector
		Output        => de_backlash_tick_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_de_backlash_duration_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => de_backlash_duration,   -- @Clock1:  input vector
		Output        => de_backlash_duration_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_de_counter_load_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => de_counter_load,   -- @Clock1:  input vector
		Output        => de_counter_load_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_de_trackctrl_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => de_trackctrl,   -- @Clock1:  input vector
		Output        => de_trackctrl_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_de_counter_max_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => de_counter_max,   -- @Clock1:  input vector
		Output        => de_counter_max_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );


     SyncBusToClock_ra_cmdcontrol : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => ra_cmdcontrol,   -- @Clock1:  input vector
		Output        => ra_cmdcontrol_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_ra_cmdtick_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => ra_cmdtick,   -- @Clock1:  input vector
		Output        => ra_cmdtick_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_ra_cmdduration : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => ra_cmdduration,   -- @Clock1:  input vector
		Output        => ra_cmdduration_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_ra_backlash_tick : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => ra_backlash_tick,   -- @Clock1:  input vector
		Output        => ra_backlash_tick_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_ra_backlash_duration_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => ra_backlash_duration,   -- @Clock1:  input vector
		Output        => ra_backlash_duration_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_ra_counter_load_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => ra_counter_load,   -- @Clock1:  input vector
		Output        => ra_counter_load_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_ra_trackctrl_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => ra_trackctrl,   -- @Clock1:  input vector
		Output        => ra_trackctrl_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_ra_counter_max_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => ra_counter_max,   -- @Clock1:  input vector
		Output        => ra_counter_max_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
      
      SyncBusToClock_fc_cmdcontrol : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => fc_cmdcontrol,   -- @Clock1:  input vector
		Output        => fc_cmdcontrol_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_fc_cmdtick_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => fc_cmdtick,   -- @Clock1:  input vector
		Output        => fc_cmdtick_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_fc_cmdduration : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => fc_cmdduration,   -- @Clock1:  input vector
		Output        => fc_cmdduration_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_fc_backlash_tick : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => fc_backlash_tick,   -- @Clock1:  input vector
		Output        => fc_backlash_tick_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_fc_backlash_duration_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => fc_backlash_duration,   -- @Clock1:  input vector
		Output        => fc_backlash_duration_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_fc_counter_load_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => fc_counter_load,   -- @Clock1:  input vector
		Output        => fc_counter_load_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_fc_trackctrl_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => fc_trackctrl,   -- @Clock1:  input vector
		Output        => fc_trackctrl_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
     SyncBusToClock_fc_counter_max_sync : sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clk_150,                                                  -- <Clock>  input clock
		Clock2        => clk_50,                                                 -- <Clock>  output clock
		Input         => fc_counter_max,   -- @Clock1:  input vector
		Output        => fc_counter_max_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );

end Behavioral;
