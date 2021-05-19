----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/13/2020 09:06:07 AM
-- Design Name: 
-- Module Name: tb_drv8825 - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_drv8825 is
--  Port ( );
end tb_drv8825;

architecture Behavioral of tb_drv8825 is
component drv8825 is
    Port ( clk_50 : in STD_LOGIC;
           rstn_50 : in STD_LOGIC;
           drv8825_mode : out STD_LOGIC_VECTOR (2 downto 0);
           drv8825_enable_n : out STD_LOGIC;
           drv8825_sleep_n : out STD_LOGIC;
           drv8825_rst_n : out STD_LOGIC;
           drv8825_step : out STD_LOGIC;
           drv8825_direction : out STD_LOGIC;
           drv8825_fault_n : in STD_LOGIC;
           ctrl_step_count : out STD_LOGIC_VECTOR (31 downto 0);
           ctrl_status : out STD_LOGIC_VECTOR (31 downto 0);
           ctrl_cmdcontrol : in STD_LOGIC_VECTOR (31 downto 0); -- steps, go, stop, direction
           ctrl_cmdtick : in STD_LOGIC_VECTOR (31 downto 0);    -- speed of command
           ctrl_cmdduration : in STD_LOGIC_VECTOR (31 downto 0);    -- speed of command
           ctrl_backlash_tick : in STD_LOGIC_VECTOR (31 downto 0);  -- speed of backlash
           ctrl_backlash_duration : in STD_LOGIC_VECTOR (31 downto 0); -- duration of backlash
           ctrl_counter_load : in STD_LOGIC_VECTOR (31 downto 0); -- duration of backlash
           ctrl_counter_max : in STD_LOGIC_VECTOR (31 downto 0); -- duration of backlash
           ctrl_trackctrl : in STD_LOGIC_VECTOR (31 downto 0)    -- speed, start, direction
          );
end component;

signal clk_50                   : STD_LOGIC;
signal rstn_50                  : STD_LOGIC;
signal drv8825_mode             :  STD_LOGIC_VECTOR (2 downto 0);
signal drv8825_enable_n         :  STD_LOGIC;
signal drv8825_sleep_n          :  STD_LOGIC;
signal drv8825_rst_n            :  STD_LOGIC;
signal drv8825_step             :  STD_LOGIC;
signal drv8825_direction        :  STD_LOGIC;
signal drv8825_fault_n          : STD_LOGIC;
signal ctrl_step_count, ctrl_cmdduration          :  STD_LOGIC_VECTOR (31 downto 0);
signal ctrl_status              :  STD_LOGIC_VECTOR (31 downto 0);
signal ctrl_cmdcontrol          : STD_LOGIC_VECTOR (31 downto 0); -- steps, go, stop, direction
signal ctrl_cmdtick             : STD_LOGIC_VECTOR (31 downto 0);    -- speed of command
signal ctrl_backlash_tick       : STD_LOGIC_VECTOR (31 downto 0);  -- speed of backlash
signal ctrl_backlash_duration   : STD_LOGIC_VECTOR (31 downto 0); -- duration of backlash
signal ctrl_counter_load        :  STD_LOGIC_VECTOR (31 downto 0); -- duration of backlash
signal ctrl_counter_max         :  STD_LOGIC_VECTOR (31 downto 0); -- duration of backlash
signal ctrl_trackctrl           : STD_LOGIC_VECTOR (31 downto 0);    -- speed, start, direction

constant CLK_PERIOD : time := 20 ns;



begin

    stim_proc: process
     begin        
          rstn_50 <= '0';
          drv8825_fault_n <= '1';  
          ctrl_cmdcontrol       <= (others => '0');
          ctrl_cmdtick       <= (others => '0');
          ctrl_backlash_tick       <= (others => '0'); 
          ctrl_backlash_duration       <= (others => '0');
          ctrl_trackctrl       <= x"00000000"; 
          ctrl_counter_load    <= x"00000000";
          ctrl_counter_max     <= x"00000000";
          ctrl_cmdduration     <= x"00000000";
          wait for CLK_PERIOD*150;
           rstn_50 <='1';                    --then apply reset for 2 clock cycles.
          
          wait for CLK_PERIOD*1000;
          ctrl_trackctrl         <= x"0000FFFF";   --then apply reset for 2 clock cycles.
          ctrl_backlash_tick     <= x"00000FFF"; 
          ctrl_backlash_duration <= x"00000FFF";
          ctrl_counter_load    <= x"8000FFFF";
          ctrl_counter_max     <= x"800FFFFF";
          ctrl_cmdduration     <= x"00000000";
          wait for CLK_PERIOD*10000;
          ctrl_counter_load    <= x"0000FFFF";
          wait for CLK_PERIOD*10000;
          ctrl_trackctrl       <= x"0000FFF1"; 
          ctrl_counter_load    <= x"8000FFFF";
          ctrl_cmdduration     <= x"00000000";
          wait for CLK_PERIOD*10000;
          ctrl_counter_load    <= x"0000FFFF";
          ctrl_cmdtick <= x"000000FF";
          ctrl_cmdcontrol(0)       <= '1'; -- ctr_cmd_in
          ctrl_cmdcontrol(1)       <= '0'; -- ctr_goto_in
          ctrl_cmdcontrol(2)       <= '1'; -- ctr_cmd_direction_in
          ctrl_cmdcontrol(3)       <= '0'; -- ctr_cmd_park
          ctrl_cmdcontrol(6 downto 4) <= "100"; -- ctr_cmdmode_in
          ctrl_cmdcontrol(10 downto 7) <= "0000"; -- ctr_cmdmode_in
          ctrl_cmdduration          <= x"0000000F";
          wait for CLK_PERIOD*10;
          ctrl_counter_load    <= x"800FFFF0";
          ctrl_cmdcontrol(0)       <= '0';
          wait for CLK_PERIOD*50000;
          ctrl_counter_load    <= x"0000FFFF";
          ctrl_cmdtick <= x"000000FF";
          ctrl_cmdcontrol(0)       <= '1'; -- ctr_cmd_in
          ctrl_cmdcontrol(1)       <= '1'; -- ctr_goto_in
          ctrl_cmdcontrol(2)       <= '1'; -- ctr_cmd_direction_in
          ctrl_cmdcontrol(3)       <= '0'; -- ctr_cmd_park
          ctrl_cmdcontrol(6 downto 4) <= "101"; -- ctr_cmdmode_in
          ctrl_cmdcontrol(30 downto 7) <= (others=>'0'); -- ctr_cmdduration_in
          ctrl_cmdduration          <= x"0000000F";
          wait for CLK_PERIOD*10000;         
          ctrl_counter_max     <= x"8000000F";
          ctrl_counter_load    <= x"80000000";
          ctrl_cmdcontrol(31)       <= '1';
          wait for CLK_PERIOD*100000;          
          ctrl_trackctrl       <= x"0000FFFF"; 
          ctrl_counter_load    <= x"00000000";
          wait for CLK_PERIOD*105000;
          ctrl_trackctrl       <= x"00000000"; 
          ctrl_counter_max     <= x"800FFFFF";
          ctrl_counter_load    <= x"80000512";
          wait for CLK_PERIOD*5000;
          ctrl_counter_load    <= x"0000FFFF";
          ctrl_cmdcontrol(0)       <= '0'; -- ctr_cmd_in
          wait for CLK_PERIOD*10000;
          ctrl_cmdtick <= x"000000FF"; -- spped / period
          ctrl_cmdcontrol(0)       <= '1'; -- ctr_cmd_in
          ctrl_cmdcontrol(1)       <= '0'; -- ctr_goto_in
          ctrl_cmdcontrol(2)       <= '0'; -- ctr_cmd_direction_in
          ctrl_cmdcontrol(3)       <= '0'; -- ctr_cmd_park
          ctrl_cmdcontrol(6 downto 4) <= "011"; -- ctr_cmdmode_in
          ctrl_cmdcontrol(7)       <= '1'; -- ctr_cmd_park
          ctrl_cmdcontrol(30 downto 8) <= (others=>'0'); -- ctr_cmdduration_in
          ctrl_cmdcontrol(31)      <= '0';
          ctrl_cmdduration          <= x"FFFFFFFF";
          wait for CLK_PERIOD*400000;
          ctrl_cmdcontrol(31)      <= '1';
          ctrl_cmdcontrol(30)      <= '0';
          wait for CLK_PERIOD*500000000;
    end process;

       -- Clock process definitions( clock with 50% duty cycle is generated here.
       Clk_process :process
       begin
            clk_50 <= '0';
            --adcin <= std_logic_vector(unsigned(adcin) + 1);
            wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
            clk_50 <= '1';
            wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
       end process;

 U0 : drv8825
    PORT MAP (
      clk_50 => clk_50,
      rstn_50 => rstn_50,
      drv8825_mode => drv8825_mode,
      drv8825_enable_n => drv8825_enable_n,
      drv8825_sleep_n => drv8825_sleep_n,
      drv8825_rst_n => drv8825_rst_n,
      drv8825_step => drv8825_step,
      drv8825_direction => drv8825_direction,
      drv8825_fault_n => drv8825_fault_n,
      ctrl_step_count => ctrl_step_count,
      ctrl_status => ctrl_status,
      ctrl_cmdcontrol => ctrl_cmdcontrol,
      ctrl_cmdtick => ctrl_cmdtick,
      ctrl_backlash_tick => ctrl_backlash_tick,
      ctrl_backlash_duration => ctrl_backlash_duration,
      ctrl_counter_load => ctrl_counter_load,
      ctrl_counter_max => ctrl_counter_max,
      ctrl_cmdduration => ctrl_cmdduration,
      ctrl_trackctrl => ctrl_trackctrl
    );
--U0: entity work.system_drv8825_dc_0_drv8825
--port map (
--    clk_50 => clk_50,
--    ctrl_backlash_duration(31 downto 30) => B"00",
--    ctrl_backlash_duration(29 downto 0) => ctrl_backlash_duration(29 downto 0),
--    ctrl_backlash_tick(31 downto 0) => ctrl_backlash_tick(31 downto 0),
--    ctrl_cmdcontrol(31 downto 30) => ctrl_cmdcontrol(31 downto 30),
--    ctrl_cmdcontrol(29 downto 8) => B"0000000000000000000000",
--    ctrl_cmdcontrol(7 downto 0) => ctrl_cmdcontrol(7 downto 0),
--    ctrl_cmdduration(31 downto 30) => B"00",
--    ctrl_cmdduration(29 downto 0) => ctrl_cmdduration(29 downto 0),
--    ctrl_cmdtick(31) => '0',
--    ctrl_cmdtick(30 downto 0) => ctrl_cmdtick(30 downto 0),
--    ctrl_counter_load(31) => ctrl_counter_load(31),
--    ctrl_counter_load(30) => '0',
--    ctrl_counter_load(29 downto 0) => ctrl_counter_load(29 downto 0),
--    ctrl_counter_max(31) => ctrl_counter_max(31),
--    ctrl_counter_max(30) => '0',
--    ctrl_counter_max(29 downto 0) => ctrl_counter_max(29 downto 0),
--    ctrl_status(31 downto 3) => ctrl_status(31 downto 3),
--    ctrl_status(2 downto 0) => ctrl_status(2 downto 0),
--    ctrl_step_count(31 downto 0) => ctrl_step_count(31 downto 0),
--    ctrl_trackctrl(31 downto 0) => ctrl_trackctrl(31 downto 0),
--    drv8825_direction => drv8825_direction,
--    drv8825_enable_n => drv8825_enable_n,
--    drv8825_fault_n => '0',
--    drv8825_mode(2 downto 0) => drv8825_mode(2 downto 0),
--    drv8825_rst_n => drv8825_rst_n,
--    drv8825_sleep_n => drv8825_sleep_n,
--    drv8825_step => drv8825_step,
--    rstn_50 => rstn_50

--);

end Behavioral;
