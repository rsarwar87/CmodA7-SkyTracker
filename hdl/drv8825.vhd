----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/12/2020 05:22:56 PM
-- Design Name: 
-- Module Name: drv8825 - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity drv8825 is
	 generic ( REVERSE_DIRECTION : boolean := true; ALWAYS_ENABLE : boolean := true );
    Port ( clk_50 : in STD_LOGIC;
           rstn_50 : in STD_LOGIC;
           drv8825_mode : out STD_LOGIC_VECTOR (2 downto 0);    -- tmc2226: bit 0 is low power pin (always high)        
           drv8825_enable_n : out STD_LOGIC;                    -- tmc2226 and drv8825 has same function                
           drv8825_sleep_n : out STD_LOGIC;                     -- tmc2226 pin is external CLK (always low)             
           drv8825_rst_n : out STD_LOGIC;                       -- tmc2226 pin is standby pin (always low)              
           drv8825_step : out STD_LOGIC;                        -- tmc2226 and drv8825 has same function                
           drv8825_direction : out STD_LOGIC;                   -- tmc2226 and drv8825 has same function                
           drv8825_fault_n : in STD_LOGIC;                      -- NOT CONNECTED                                        
           is_tmc2226   : in std_logic;
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
end drv8825;

architecture Behavioral of drv8825 is
    ATTRIBUTE MARK_DEBUG : string;
    
    
    signal current_direction_buf : std_logic_vector(3 downto 0) := "0000";
    type speed_buffer is array (0 to 3) of integer range 0 to 2**30-1;
    signal current_speed_buf : speed_buffer := (others => 0);
    signal current_mode_buf : std_logic_vector(2 downto 0) := "000";
    signal current_mode_out : std_logic_vector(2 downto 0) := "000";
    signal current_mode_back : std_logic_vector(2 downto 0) := "000";
    signal drv8825_direction_buf : STD_LOGIC := '0';                   -- tmc2226 and drv8825 has same function                
    
    signal max_counter2: std_logic_vector (29 downto 0) := (others => '0');
    
    signal ctr_backlash_tick_buf : integer range 0 to 2**30-1 := 1;
    signal ctr_backlash_duration_buf : unsigned (29 downto 0) := (others => '0');
    TYPE state_machine_backlash IS (seek, processing, done, disabled);  -- Define the states
    signal state_backlash : state_machine_backlash := seek;
    
    signal drv8825_direction_out, stepping_clk, cnt_enable : std_logic := '0';
    signal current_stepper_counter : std_logic_vector(29 downto 0) := (others => '0');
    
    TYPE state_machine_motor IS (idle, tracking, command, park);  -- Define the states
    signal state_motor : state_machine_motor := idle;
    TYPE state_change_trigger_machine IS (normal, direction, direction_speed, speed);  -- Define the states
    signal state_change_trigger : state_change_trigger_machine := normal;
    
    ATTRIBUTE MARK_DEBUG of current_mode_out, current_speed_buf: SIGNAL IS "TRUE";
    ATTRIBUTE MARK_DEBUG of stepping_clk, state_change_trigger, state_motor, current_stepper_counter, cnt_enable: SIGNAL IS "TRUE";
    ATTRIBUTE MARK_DEBUG of state_backlash, ctr_backlash_tick_buf, ctr_backlash_duration_buf: SIGNAL IS "TRUE";
    
    signal max_counter : std_logic_vector (30 downto 0) := (others => '1');
	signal delta_counter : unsigned (6 downto 0) := "0000001";
	signal tmc_mode_buf : std_logic_vector(1 downto 0) := "00";
begin
    
    
    
    
	 delta_counter_proc : process (clk_50, rstn_50)
    begin
        if (rstn_50 = '0') then
            delta_counter <= "0000001";
            tmc_mode_buf <= "00";
        elsif(rising_edge(clk_50)) then
            ctrl_step_count(31 downto 30) <= "00";
            ctrl_step_count(29 downto 0) <= current_stepper_counter;
            case current_mode_out is
                when "000" =>
					if is_tmc2226 = '1' then
						--delta_counter <= "1000000"; --64; 1/1 full sptep
						-- not selectable through cfg pins
						delta_counter <= "0000001"; -- 1; 1/64
						tmc_mode_buf(0) <= '0';
						tmc_mode_buf(1) <= '1'; --MS2
					else
						delta_counter <= "0100000";
					end if;
				when "001" =>
					if is_tmc2226 = '1' then
						--delta_counter <= "0100000"; -- 32; 1/2
						-- not selectable through cfg pins
						delta_counter <= "0000001"; -- 1; 1/64
						tmc_mode_buf(0) <= '0';
						tmc_mode_buf(1) <= '1'; --MS2
					else
						delta_counter <= "0010000";
					end if;
				when "010" =>
					if is_tmc2226 = '1' then
						--delta_counter <= "0010000"; -- 16; 1/4
						-- not selectable through cfg pins
						delta_counter <= "0000001"; -- 1; 1/64
						tmc_mode_buf(0) <= '0';
						tmc_mode_buf(1) <= '1'; --MS2
					else
						delta_counter <= "0001000";
					end if;
				when "011" =>
					if is_tmc2226 = '1' then
						delta_counter <= "0001000"; -- 8; 1/8
						tmc_mode_buf(0) <= '0';
						tmc_mode_buf(1) <= '0'; --MS2
					else
						delta_counter <= "0000100";
					end if;
				when "100" =>
					if is_tmc2226 = '1' then
						delta_counter <= "0000100"; -- 4 ; 1/16
						tmc_mode_buf(0) <= '1';
						tmc_mode_buf(1) <= '1'; --MS2
					else
						delta_counter <= "0000010";
					end if;
				when "101" =>
					if is_tmc2226 = '1' then
						delta_counter <= "0000010"; -- 2; 1/32
						tmc_mode_buf(0) <= '1';
						tmc_mode_buf(1) <= '0'; --MS2
					else
						delta_counter <= "0000001";
					end if;
				when others =>
					if is_tmc2226 = '1' then
						delta_counter <= "0000001"; -- 1; 1/64
						tmc_mode_buf(0) <= '0';
						tmc_mode_buf(1) <= '1'; --MS2
					else
						delta_counter <= "0000001";
					end if;
		      end case;
        end if;
    end process; 
    trigger_changes : process (clk_50, rstn_50)
    begin
        if (rstn_50 = '0') then
            state_change_trigger <= normal;
        elsif(rising_edge(clk_50)) then
            state_change_trigger <= normal;
            if (current_direction_buf(1) /= current_direction_buf(0) and current_speed_buf(1) /= current_speed_buf(0)) then
                state_change_trigger <= direction_speed;
            elsif (current_direction_buf(1) /= current_direction_buf(0)) then
                state_change_trigger <= direction;
            elsif (current_speed_buf(1) /= current_speed_buf(0)) then
                state_change_trigger <= speed ;
            end if;
        end if;
    end process; 
        
	 drv8825_direction_buf <= not drv8825_direction_out when REVERSE_DIRECTION = true else drv8825_direction_out;
	 drv8825_direction <= not drv8825_direction_buf when is_tmc2226 = '1' else drv8825_direction_buf;
    registered_output : process(clk_50, rstn_50) begin
        if (rstn_50 = '0') then
            drv8825_enable_n<='1';
            drv8825_sleep_n<= '0';
            drv8825_rst_n  <= '0';
            drv8825_direction_out <= '0';
            drv8825_mode <= (others => '0');
            drv8825_step <= '0';
            ctrl_status <= (others => '0');
        elsif (rising_edge(clk_50)) then
            if (ALWAYS_ENABLE = false) then
                drv8825_enable_n<='1';
                drv8825_sleep_n<= '0';
                drv8825_rst_n  <= '0';
                if (is_tmc2226 = '1') then
                    drv8825_sleep_n<= '0';  -- TMC2226 CLK
                    drv8825_rst_n  <= '1';  -- TMC2226 standby
                else
                    drv8825_sleep_n<= '0';
                    drv8825_rst_n  <= '0';
                end if;
            else
                drv8825_enable_n<='0';
                if (is_tmc2226 = '1') then
                    drv8825_sleep_n<= '0';  -- TMC2226 CLK
                    drv8825_rst_n  <= '0';  -- TMC2226 standby
                else
                    drv8825_sleep_n<= '1';
                    drv8825_rst_n  <= '1';
                end if;
            end if;
            drv8825_direction_out <= '0';
            drv8825_step <= '0';
            drv8825_mode <= "000";
            ctrl_status <= (others => '0');
            ctrl_status(16) <= is_tmc2226;
			      ctrl_status(11 downto 5) <= std_logic_vector(delta_counter);
            ctrl_status(3) <= drv8825_fault_n;          
            ctrl_status(2 downto 0) <= "000";
            if  state_backlash = disabled then 
                ctrl_status(4) <= '0';
            else 
                ctrl_status(4) <= '1';
            end if;
            
            if is_tmc2226 = '1' then
			  drv8825_mode(1 downto 0) <= tmc_mode_buf;
			  drv8825_mode(2) <= '1';
			else
			  drv8825_mode <= current_mode_out;
			end if;
            
            case state_motor is
                when tracking =>
                    drv8825_direction_out <= current_direction_buf(0);
                    drv8825_step <= stepping_clk;
                    drv8825_enable_n<='0';
                    if is_tmc2226 = '1' then
					  drv8825_rst_n <= '0';
					else
					  drv8825_sleep_n<= '1';
					  drv8825_rst_n  <= '1';  
					end if;
                    ctrl_status(1) <= '0';
                    ctrl_status(0) <= '1';
                    ctrl_status(2) <= '0';
                when command => 
                    drv8825_direction_out <= current_direction_buf(0);
                    drv8825_step <= stepping_clk;
                    drv8825_enable_n<='0';
                    if is_tmc2226 = '1' then
					  drv8825_rst_n <= '0';
					else
					  drv8825_sleep_n<= '1';
					  drv8825_rst_n  <= '1';  
					end if;
                    ctrl_status(2) <= '0';
                    ctrl_status(1) <= '1';
                    --ctrl_status(0) <= '0';
                when park =>
                    drv8825_direction_out <= current_direction_buf(0);
                    drv8825_step <= stepping_clk;
                    drv8825_enable_n<='0';
                    if is_tmc2226 = '1' then
					  drv8825_rst_n <= '0';
					else
					  drv8825_sleep_n<= '1';
					  drv8825_rst_n  <= '1';  
					end if;
                    ctrl_status(2) <= '1';
                    ctrl_status(1) <= '1';
                    --ctrl_status(0) <= '0';
                when others => 
                    drv8825_direction_out <= '0';
                    drv8825_step <= '0';
                    ctrl_status(0) <= '0';
                    ctrl_status(2) <= '0';
                    ctrl_status(1) <= '0';
            end case;
        end if;
    end process; 
--------------------------------------------------------------------------------------------
-- clock divider
--------------------------------------------------------------------------------------------
clock_block: block
    signal ctr_backlash_cnt : unsigned (29 downto 0) := (others => '0');
    
     signal counter_buf :integer range 0 to 2**30-1 := 1;
     signal count :integer range 0 to 2**30-1 := 1;
     
     ATTRIBUTE MARK_DEBUG of counter_buf, count, ctr_backlash_cnt: SIGNAL IS "TRUE";
begin
    
    clock_generatory : process (clk_50, rstn_50)
    begin
        if (rstn_50 = '0') then
            stepping_clk <= '0';
            count <= 0;
        elsif (rising_edge (clk_50) ) then
            stepping_clk <= stepping_clk;
            count <= count + 1;
            if (state_change_trigger = speed or state_change_trigger = speed OR state_change_trigger = direction_speed) then
                count <= 0;
                stepping_clk <= '0';
            elsif (count = counter_buf/2) then
                stepping_clk <= not stepping_clk;
                count <= count + 1;
            elsif (count > counter_buf - 1) then
                count <= 0;
                stepping_clk <= not stepping_clk;
            end if;
        end if;
    end process;
    
    backslash: process (clk_50, rstn_50)
    begin
        if (rstn_50 = '0') then
            ctr_backlash_cnt <= (others => '0');
            state_backlash   <= seek;
            counter_buf <= 1;
        elsif (rising_edge(clk_50)) then
            counter_buf <= current_speed_buf(1);
            current_mode_out <= current_mode_buf;
            ctr_backlash_cnt <= ctr_backlash_cnt;
            case (state_backlash) is
                when seek =>
                    ctr_backlash_cnt <= (others => '0');
                    if (state_change_trigger = direction OR state_change_trigger = direction_speed) then
                        state_backlash <= processing;
                        counter_buf <= ctr_backlash_tick_buf;
                        current_mode_out <= current_mode_back;
                    end if; 
                    if (ctr_backlash_duration_buf = 0) then
                        state_backlash <= disabled;
                    end if;
                when processing =>
                    ctr_backlash_cnt <= ctr_backlash_cnt + 1; 
                    counter_buf <= ctr_backlash_tick_buf;
                    current_mode_out <= current_mode_back;
                    if (ctr_backlash_cnt = ctr_backlash_duration_buf) then
                        state_backlash <= done;
                    end if;
                
                when done =>
                    state_backlash <= seek;
                    ctr_backlash_cnt <= (others => '0');
                when disabled => 
                    if (not (ctr_backlash_duration_buf = 0)) then
                        state_backlash <= seek;
                    end if;
                when others =>
                    state_backlash <= seek;
             end case;
        end if;
    end process;
    
    
 end block clock_block;

command_block: block
    signal ctr_cmdtick_in : integer range 0 to 2**30-1 := 1;
    signal ctr_cmdduration_in : std_logic_vector(29 downto 0) := (others => '0');
    signal ctr_cmd_direction_in  : std_logic := '0';
    signal ctr_cmd_in : std_logic := '0';
    signal ctr_cmdcancel_in : std_logic := '0';
    signal ctr_cmdcancelnow_in : std_logic := '0';
    signal ctr_goto_in : std_logic := '0';
    signal ctr_park_in : std_logic := '0';
    signal ctr_cmdmode_in : std_logic_vector(2 downto 0) := "000";
    
    signal ctr_backlash_tick_in  : integer range 0 to 2**30-1 := 1;
    signal ctr_backlash_duration_in  : unsigned (29 downto 0) := (others => '0');
    
    signal ctr_track_enabled_in : std_logic := '0';
    signal ctr_track_direction_in : std_logic := '0';
    signal ctr_tracktick_in : integer range 0 to 2**30-1 := 1;
    signal ctr_trackmode_in : std_logic_vector(2 downto 0) := "000";
    
    --signal stepper_counter_int : integer range 0 to 2**31-1 := 1;
    signal target_counter_int : std_logic_vector(29 downto 0) := (others => '0');
    
    
    signal ctr_cmd_buf, ctr_park_buf : std_logic := '0';
    signal use_acceleration : std_logic := '0';
    signal done_acceleration : std_logic := '0';
    
    
    signal issue_direction, issue_stop : std_logic := '1';
    signal issue_speed     : integer range 0 to 2**30-1;
    signal issue_mode : std_logic_vector(2 downto 0) := "000";
    signal state_motor_buf : state_machine_motor := idle;
    
    signal acceleration_counter  : integer range 0 to 12500000 := 12500000;
    signal current_speed_buffer  : std_logic_vector (31 downto 0) := (others => '1');
    signal current_scaled_buffer  : std_logic_vector (31 downto 0) := (others => '1');
    signal init_count, cutoff_count  : std_logic_vector (29 downto 0) := (others => '0');
    signal current_scaled_buffer2     : integer range 0 to 2**30-1;
    constant aceel_steps : integer := 7;
    signal divider : integer range 0 to 7 := aceel_steps;
    type array_30 is array (0 to 7) of std_logic_vector (29 downto 0);
    type array_i30 is array (0 to 7) of integer range 0 to 2**30-1;
    type array_i32 is array (0 to 7) of integer range -2**30-1 to 2**30-1;
    signal decceleration_map, acceleration_map : array_30 := (others => (others => '0'));
    signal decceleration_map_buf : array_i32 := (others => 0);
    signal speedmap_map : array_i30 := (others => 1100000);
    constant total_accel_count : integer := 12500000;
    signal cuttoff_special : std_logic := '0';
    
    signal cutoff_signed : integer := 0;
    
    
    ATTRIBUTE MARK_DEBUG of divider, use_acceleration, done_acceleration, acceleration_counter, acceleration_map, decceleration_map: SIGNAL IS "TRUE";
    ATTRIBUTE MARK_DEBUG of ctr_cmd_in, ctr_cmdcancel_in, ctr_goto_in, ctr_park_in, cuttoff_special, ctr_cmdtick_in, ctr_cmdduration_in: SIGNAL IS "TRUE";
    ATTRIBUTE MARK_DEBUG of ctr_track_enabled_in, ctr_track_direction_in, ctr_tracktick_in, target_counter_int: SIGNAL IS "TRUE";
    
begin
    current_speed_buffer <= std_logic_vector(to_unsigned(issue_speed, current_speed_buffer'length));
    accel_control : process (clk_50, rstn_50)
    
    begin
        if (rstn_50 = '0') then
            current_mode_buf <= "000";
            current_speed_buf <= (others => 147483647);
            current_direction_buf <= (others => '0');
            acceleration_counter <= total_accel_count;
            current_scaled_buffer <= (others => '1');
            --current_speed_buffer <=  (others => '1');
            decceleration_map <= (others => (others => '0'));
            acceleration_map <= (others => (others => '0'));
            done_acceleration <= '0';
            divider <= aceel_steps;
            speedmap_map <= (others => 100000);
            decceleration_map_buf <= (others => 0);
        elsif (rising_edge(clk_50)) then
            current_direction_buf(3 downto 1) <= current_direction_buf(2 downto 0);
            current_speed_buf(1 to 3) <= current_speed_buf(0 to 2);
            current_mode_buf <= issue_mode;
            current_direction_buf(0) <= issue_direction;
            --current_scaled_buffer <= current_scaled_buffer;
            --current_speed_buffer <= std_logic_vector(to_unsigned(issue_speed, current_speed_buffer'length));
            current_scaled_buffer(31 downto 8) <= current_speed_buffer(23 downto 0);
            divider <= divider;
            done_acceleration <= done_acceleration;
            decceleration_map <= decceleration_map;
            acceleration_map <= acceleration_map;
            speedmap_map <= speedmap_map;
            acceleration_map(0) <= init_count;
            decceleration_map_buf <= decceleration_map_buf;

            if (state_motor = park or state_motor = command) then  
                if (use_acceleration = '1') then
                    --current_speed_buf(0) <= issue_speed;
                    acceleration_counter <= acceleration_counter - 1;
                    current_speed_buf(0) <= speedmap_map(divider);
                    done_acceleration <= done_acceleration or issue_stop;
                    --current_scaled_buffer(31 downto 0+divider) <= current_speed_buffer(31-divider downto 0);
                    speedmap_map(0) <= issue_speed;
                    speedmap_map(1) <= to_integer(unsigned(current_scaled_buffer(31 downto 7))) 
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 6)));
                    speedmap_map(2) <= to_integer(unsigned(current_scaled_buffer(31 downto 6)))  
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 5)))
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 4)));
                    speedmap_map(3) <= to_integer(unsigned(current_scaled_buffer(31 downto 5)))
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 4)))
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 3)))
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 2)));
                    speedmap_map(4) <= to_integer(unsigned(current_scaled_buffer(31 downto 4)))
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 3))) 
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 2)))
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 1)));
                    speedmap_map(5) <= to_integer(unsigned(current_scaled_buffer(31 downto 3)))
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 2)))
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 1)));
                    speedmap_map(6) <= to_integer(unsigned(current_scaled_buffer(31 downto 2)))
                                        + to_integer(unsigned(current_scaled_buffer(31 downto 1)));
                    speedmap_map(7) <= to_integer(unsigned(current_scaled_buffer(31 downto 1)));
                    for I in 1 to aceel_steps loop
                        --speedmap_map(I) <= to_integer(unsigned(current_scaled_buffer(31 downto 8-I)));
                        if (issue_direction = '1') then
                            if cuttoff_special = '0' then 
                                decceleration_map_buf(I) <= to_integer(unsigned(target_counter_int) - unsigned(acceleration_map(I)) - unsigned(cutoff_count));
                            else
                                decceleration_map_buf(I) <= to_integer(unsigned(target_counter_int) - unsigned(acceleration_map(I)) + unsigned(cutoff_count));
                            end if;
                        else
                            decceleration_map_buf(I) <= to_integer(unsigned(target_counter_int) + unsigned(acceleration_map(I)) + unsigned(cutoff_count));
                        end if;
                        if decceleration_map_buf(I) < 0 then
                            decceleration_map(I) <= std_logic_vector(to_unsigned(decceleration_map_buf(I) + to_integer(unsigned(max_counter2)), 30));
                        elsif decceleration_map_buf(I) >  to_integer(unsigned(max_counter2)) then
                            decceleration_map(I) <= std_logic_vector(to_unsigned(decceleration_map_buf(I) - to_integer(unsigned(max_counter2)), 30));
                        else
                            decceleration_map(I) <= std_logic_vector(to_unsigned(decceleration_map_buf(I), 30));
                        end if;
                    end loop;
                    if (done_acceleration = '0' and acceleration_counter = 0) then
                        acceleration_counter <= total_accel_count;
                        if issue_direction = '1' then
                           if (unsigned(current_stepper_counter) < unsigned(acceleration_map(0))) then
                            acceleration_map(divider) <= std_logic_vector((unsigned(max_counter2) + unsigned(current_stepper_counter) - unsigned(acceleration_map(0))) ); -- current - init                                
                           else
                            acceleration_map(divider) <= std_logic_vector(unsigned(current_stepper_counter) - unsigned(acceleration_map(0))); -- current - init
                           end if;
                        else
                           if unsigned(acceleration_map(0)) < unsigned(current_stepper_counter) then
                            acceleration_map(divider) <= std_logic_vector(unsigned(acceleration_map(0)) - unsigned(current_stepper_counter) + unsigned(max_counter2));
                           elsif unsigned(acceleration_map(0)) < unsigned(current_stepper_counter) then
                            acceleration_map(divider) <= std_logic_vector(unsigned(acceleration_map(0)) - unsigned(current_stepper_counter) - unsigned(max_counter2));
                           else
                            acceleration_map(divider) <= std_logic_vector(unsigned(acceleration_map(0)) - unsigned(current_stepper_counter) );
                           end if;
                        end if;
                        divider <= divider - 1;
                        if (divider = 1) then
                            done_acceleration <= '1';
                        end if;
                    end if;
                    if (done_acceleration = '1') then
                        for I in 1 to aceel_steps loop
                        if (decceleration_map(I) = current_stepper_counter) then
                            divider <= I;
                        end if;
                        end loop;
                    end if;
                    
                else
                    current_speed_buf(0) <= issue_speed;
                end if;
            else
                current_speed_buf(0) <= issue_speed;
                acceleration_counter <= total_accel_count;
                divider <= aceel_steps;
                done_acceleration <= '0';
                decceleration_map <= (others => (others => '0'));
                acceleration_map <= (others => (others => '0'));
                speedmap_map <= (others => 100000);
                decceleration_map_buf <= (others => 0);
            end if;
            
        end if;
    end process;
    
    issue_command: process (clk_50, rstn_50)
    begin
        if (rstn_50 = '0') then
            state_motor <= idle;
            state_motor_buf <= idle;
            issue_mode <= "000";
            issue_speed <= 147483647;
            issue_direction <= '0';
            --stepper_counter_int  <= 0;
            target_counter_int  <= (others=> '0');
            ctr_cmd_buf <= '0';
            ctr_park_buf <= '0';
            init_count <= (others => '0');
            cutoff_count <= (others => '0');
            issue_stop <= '0';
            cuttoff_special <= '0';
            cutoff_signed <= 0;
        elsif (rising_edge(clk_50)) then
            --stepper_counter_int <= to_integer(unsigned(current_stepper_counter));
            target_counter_int <= target_counter_int;
            state_motor <= state_motor_buf;
            state_motor_buf <= state_motor_buf;
            ctr_cmd_buf <= ctr_cmd_in;
            ctr_park_buf <= ctr_park_in;
            issue_direction <= issue_direction;
            issue_mode <= issue_mode;
            init_count <= init_count;
            issue_speed <= issue_speed;
            issue_stop <= '0';
            if (cutoff_signed < 0) then
                cutoff_count <= std_logic_vector(to_unsigned(cutoff_signed + to_integer(unsigned(max_counter2)), cutoff_count'length));
            elsif (cutoff_signed > to_integer(unsigned(max_counter2))) then
                cutoff_count <= std_logic_vector(to_unsigned(cutoff_signed - to_integer(unsigned(max_counter2)), cutoff_count'length));
            else
                cutoff_count <= std_logic_vector(to_unsigned(cutoff_signed, cutoff_count'length));
            end if;
            cuttoff_special <= cuttoff_special;
            
--            if  ( max_counter(30) = '0' and (unsigned(target_counter_int) > unsigned(max_counter(29 downto 0)))) then
--                if (state_motor_buf = command and state_motor_buf = park) then
--                    if issue_direction = '1' then
--                        target_counter_int <= std_logic_vector(unsigned(target_counter_int) - unsigned(max_counter(29 downto 0)));
--                    else
--                        target_counter_int <=std_logic_vector(unsigned(max_counter(29 downto 0)) - unsigned(target_counter_int));
--                    end if;
--                end if;
--            end if;
            
            case (state_motor_buf) is
                when command => 
                    if (ctr_cmdcancel_in = '1') then 
                        if ((ctr_cmdcancelnow_in = '1' or use_acceleration = '0') and stepping_clk = '1') then
                            state_motor_buf <= idle;
                        else
                            if (issue_stop = '0') then
                                if (issue_direction = '1') then
                                --cutoff_count <=  std_logic_vector( (unsigned(current_stepper_counter) - unsigned(target_counter_int) + unsigned(acceleration_map(1)) + unsigned(max_counter2) ) mod unsigned(max_counter2));
                                if unsigned(target_counter_int) > unsigned(current_stepper_counter) then
                                    cutoff_signed <=  to_integer( unsigned(target_counter_int) - unsigned(current_stepper_counter) - unsigned(acceleration_map(1)));
                                    cuttoff_special <= '0';
                                else
                                    cutoff_signed <=  to_integer( (unsigned(current_stepper_counter) - unsigned(target_counter_int) + unsigned(acceleration_map(1)) ) );
                                    cuttoff_special <= '1';
                                end if;
                                else
                                if unsigned(target_counter_int) > unsigned(current_stepper_counter) then
                                    cutoff_signed <=  to_integer( unsigned(max_counter2) - unsigned(target_counter_int) + unsigned(current_stepper_counter) - unsigned(acceleration_map(1)));
                                    cuttoff_special <= '1';
                                else
                                    cutoff_signed <=  to_integer( (unsigned(current_stepper_counter) - unsigned(target_counter_int) - unsigned(acceleration_map(1)) ) );
                                    cuttoff_special <= '0';
                                end if;
                                end if;
                            end if;
                            issue_stop <= '1';
                            if (divider = 7) then
                                state_motor_buf <= idle;
                            end if;
                        end if;
                    elsif (target_counter_int = current_stepper_counter and stepping_clk = '0') then
                         state_motor_buf <= idle;
                    end if;
                when park =>
                    if (ctr_cmdcancel_in = '1') then 
                        if (ctr_cmdcancelnow_in = '1' or use_acceleration = '0') then
                            state_motor_buf <= idle;
                        else
                            if (issue_stop = '0') then
                                if (issue_direction = '1') then
                                --cutoff_count <=  std_logic_vector( (unsigned(current_stepper_counter) - unsigned(target_counter_int) + unsigned(acceleration_map(1)) + unsigned(max_counter2) ) mod unsigned(max_counter2));
                                if unsigned(target_counter_int) > unsigned(current_stepper_counter) then
                                    cutoff_signed <=  to_integer( unsigned(target_counter_int) - unsigned(current_stepper_counter) - unsigned(acceleration_map(1)));
                                    cuttoff_special <= '0';
                                else
                                    cutoff_signed <=  to_integer( (unsigned(current_stepper_counter) - unsigned(target_counter_int) + unsigned(acceleration_map(1)) ) );
                                    cuttoff_special <= '1';
                                end if;
                                else
                                if unsigned(target_counter_int) > unsigned(current_stepper_counter) then
                                    cutoff_signed <=  to_integer( unsigned(max_counter2) - unsigned(target_counter_int) + unsigned(current_stepper_counter) - unsigned(acceleration_map(1)));
                                    cuttoff_special <= '1';
                                else
                                    cutoff_signed <=  to_integer( (unsigned(current_stepper_counter) - unsigned(target_counter_int) - unsigned(acceleration_map(1)) ) );
                                    cuttoff_special <= '0';
                                end if;
                                end if;
                            end if;
                            issue_stop <= '1';
                            if (divider = 7) then
                                state_motor_buf <= idle;
                            end if;
                        end if;
                    elsif (target_counter_int = current_stepper_counter and stepping_clk = '0') then
                         state_motor_buf <= idle;
                    end if;
                when others =>
                    if (ctr_cmd_buf = '0' and ctr_cmd_in = '1') then
                        state_motor_buf <= command;
                        issue_direction <= ctr_cmd_direction_in;
                        issue_mode <= ctr_cmdmode_in;
                        if (ctr_goto_in = '1') then
                           target_counter_int <= ctr_cmdduration_in;
                        else
                            if (ctr_cmd_direction_in = '1') then
                                if (unsigned(current_stepper_counter) + unsigned(ctr_cmdduration_in) > unsigned(max_counter2)) then
                                    target_counter_int <= std_logic_vector( (unsigned(current_stepper_counter) + unsigned(ctr_cmdduration_in)) - unsigned(max_counter2)  );
                                else
                                    target_counter_int <= std_logic_vector( (unsigned(current_stepper_counter) + unsigned(ctr_cmdduration_in)) );
                                end if;
                            else
                                if (unsigned(current_stepper_counter)  > unsigned(ctr_cmdduration_in)) then
                                    target_counter_int <= std_logic_vector( (unsigned(current_stepper_counter) - unsigned(ctr_cmdduration_in)) );
                                else
                                    target_counter_int <= std_logic_vector( (unsigned(current_stepper_counter) - unsigned(ctr_cmdduration_in)) + unsigned(max_counter2) );
                                end if;
                            end if;
                        end if;
                        init_count <= current_stepper_counter;
                        issue_speed <= ctr_cmdtick_in;
                        cutoff_count <= (others => '0');
                    elsif (ctr_park_buf = '0' and ctr_park_in = '1') then
                        state_motor_buf <= park;
                        issue_direction <= ctr_cmd_direction_in;
                        issue_speed <= ctr_cmdtick_in;
                        issue_mode <= ctr_cmdmode_in;
                        target_counter_int <= (others => '0');
                        cutoff_count <= (others => '0');
                    elsif (ctr_track_enabled_in = '1') then
                        state_motor_buf <= tracking;
                        issue_direction <= ctr_track_direction_in;
                        issue_speed <= ctr_tracktick_in;
                        issue_mode <= ctr_trackmode_in;
                    else 
                        state_motor_buf <= idle;
                    end if; 
                    --cuttoff_special <= '0';
                    cutoff_signed <= 0;
            end case;
         
        
        end if;
    end process;
    

    settings: process(clk_50, rstn_50)
    begin
        if (rstn_50 = '0') then
        
            ctr_cmd_direction_in  <= '1';
            ctr_cmd_in <= '0';
            ctr_goto_in  <= '0';
            ctr_cmdtick_in <= 1;
            ctr_cmdcancel_in <= '0';
            ctr_park_in <= '0';
            use_acceleration <= '0';
            ctr_cmdcancelnow_in <= '0';
            
            ctr_backlash_duration_buf <= (others => '0');
            ctr_backlash_duration_in <= (others => '0');
            ctr_backlash_tick_in <= 1;
            ctr_backlash_tick_buf <= 1;
            current_mode_back <= (others => '0');
            
            ctr_tracktick_in <= 1;
            ctr_track_direction_in <=  '0';
            ctr_track_enabled_in <= '0';
            ctr_cmdduration_in <= (others => '0');
        elsif (rising_edge(clk_50)) then
            ctr_cmd_direction_in  <= ctr_cmd_direction_in;
            ctr_cmd_in <=  ctr_cmd_in;
            ctr_goto_in  <=  ctr_goto_in;
            ctr_cmdtick_in  <= ctr_cmdtick_in  ;
            ctr_cmdcancel_in <= '0';
            ctr_park_in <= ctr_park_in;
            ctr_cmdcancelnow_in  <= ctr_cmdcancelnow_in;
            
            ctr_tracktick_in <= ctr_tracktick_in ;
            ctr_track_direction_in <= ctr_track_direction_in;
            ctr_track_enabled_in <= ctr_track_enabled_in;
            
            ctr_backlash_tick_in<= ctr_backlash_tick_in;
            ctr_backlash_duration_in <= ctr_backlash_duration_in;
            ctr_backlash_duration_buf <= ctr_backlash_duration_buf;
            ctr_backlash_tick_buf <= ctr_backlash_tick_buf;
            ctr_cmdduration_in <= ctr_cmdduration_in;
            current_mode_back <= current_mode_back;
            if (state_motor /= command) then
                ctr_cmdtick_in <= to_integer(unsigned(ctrl_cmdtick(30 downto 0)));
                ctr_cmd_direction_in  <= ctrl_cmdcontrol(2);
                ctr_cmd_in <= ctrl_cmdcontrol(0);
                ctr_goto_in  <=  ctrl_cmdcontrol(1);
                ctr_park_in <= ctrl_cmdcontrol(3);
                ctr_cmdmode_in <= ctrl_cmdcontrol(6 downto 4);
                ctr_cmdduration_in(29 downto 0) <= ctrl_cmdduration(29 downto 0);
                
                
                use_acceleration <= '0';
                if (ctrl_cmdduration(29 downto 14) /= x"00000" and ctrl_cmdtick(30 downto 15) = x"00000") then 
                    use_acceleration <= '1' and ctrl_cmdcontrol(7);
                end if;
                
                ctr_tracktick_in <= to_integer(unsigned(ctrl_trackctrl(31 downto 5)));
                ctr_track_enabled_in <= ctrl_trackctrl(0);
                ctr_track_direction_in <= ctrl_trackctrl(1);
                ctr_trackmode_in <= ctrl_trackctrl(4 downto 2);
                --ctr_track_enabled_buf <= ctr_track_enabled_in;
                --ctr_track_direction_buf <= ctr_track_direction_in;
                ctr_cmdcancel_in <= '0';
            elsif state_motor = command or state_motor = park then
                ctr_cmdcancel_in <= ctrl_cmdcontrol(31);
                ctr_cmdcancelnow_in <= ctrl_cmdcontrol(30);
            end if;
            if (state_backlash /= processing) then
                ctr_backlash_tick_in <= to_integer(unsigned(ctrl_backlash_tick(31 downto 3)));
                ctr_backlash_tick_buf <= ctr_backlash_tick_in;
                ctr_backlash_duration_in <= (unsigned(ctrl_backlash_duration(29 downto 0)));
                ctr_backlash_duration_buf <= ctr_backlash_duration_in;
                current_mode_back <= ctrl_backlash_tick(2 downto 0);
            end if;
        end if;
    end process;

end block command_block;


--------------------------------------------------------------------------------------------
-- step counter
--------------------------------------------------------------------------------------------
stepper_count : block
    signal counter_clk : std_logic := '0';
    signal load_count  : std_logic := '0';
    signal load_counter, load_counter_buf: std_logic_vector (29 downto 0) := (others => '0');
    
    
    TYPE load_counter_state IS (normal, buf0, buf3, buf1, buf2, buf4);  -- Define the states
    signal state_counter : load_counter_state := normal;
    constant current_stepper_max : std_logic_vector(29 downto 0) := (others => '1');
    signal mask_counter_max : std_logic_vector(31 downto 0) := (others => '1');
begin        

   loadcounter : process (clk_50, rstn_50)
    variable pulse_load : std_logic := '0';
   begin
    if (rstn_50 = '0') then
        state_counter <= normal;
        cnt_enable <= '0';
        counter_clk <= '0';
        
        max_counter <= (others => '1');
        load_count <= '0';
        load_counter <= (others => '0');
        pulse_load := '0';
    elsif (rising_edge(clk_50)) then
        state_counter <= state_counter;
        cnt_enable <= '0';
        counter_clk <= '0';
        load_count <= '0';
        load_counter <= load_counter;
        max_counter <= max_counter;
        mask_counter_max <= ctrl_counter_max;
        mask_counter_max(30) <= '0';
        
        case state_counter is
            when normal =>
                if ((state_motor /= idle) and (state_backlash /= processing)) then
                    cnt_enable <= '1';
                else
                    cnt_enable <= '0';
                end if;
                counter_clk <= stepping_clk;
                if (max_counter(30) = '0' and current_stepper_counter = max_counter(29 downto 0) and stepping_clk = '0') then
                    state_counter <= buf0;
                    load_counter <= (others => '0');
                    load_counter(1) <= '1';
                elsif (max_counter(30) = '0' and current_stepper_counter = current_stepper_max and stepping_clk = '0') then
                    state_counter <= buf0;
                    load_counter <= max_counter(29 downto 0) - x"2";
                elsif ((state_motor /= park) and (state_motor /= command) and stepping_clk = '0') then
                    if (ctrl_counter_load(31) = '1' and pulse_load = '0') then
                        state_counter <= buf0;
                        load_counter_buf <= ctrl_counter_load(29 downto 0);
                        load_counter <= ctrl_counter_load(29 downto 0);
                    elsif (mask_counter_max(31) = '1') then
                        max_counter(30 downto  0) <= mask_counter_max(30 downto 0) + '1';
                        max_counter2 <= mask_counter_max(29 downto 0);
                    end if;
                    pulse_load := ctrl_counter_load(31);
                end if;
             when buf0 =>
                counter_clk <= not counter_clk;
                state_counter <= buf1;
                cnt_enable <= '1';
                load_count <= '1';
             when buf1 =>
                counter_clk <= not counter_clk;
                state_counter <= buf2;
                cnt_enable <= '1';
                load_count <= '1';
             when buf2 =>
                counter_clk <= not counter_clk;
                state_counter <= buf3;
                cnt_enable <= '1';
                load_count <= '1';
             when buf3 =>
                counter_clk <= not counter_clk;
                state_counter <= buf4;
                cnt_enable <= '1';
                load_count <= '1';
             when buf4 =>
                counter_clk <= not counter_clk;
                state_counter <= normal;
                cnt_enable <= '1';
                load_count <= '1';
        end case;
    end if;
   end process;

	
	process (counter_clk)
	begin
	if (rising_edge(counter_clk)) then
		if (cnt_enable = '1') then
			if (load_count = '1') then
				current_stepper_counter <= load_counter;
			elsif (current_direction_buf(0) = '1') then
				current_stepper_counter <= std_logic_vector(unsigned(current_stepper_counter) + delta_counter);
			else
				current_stepper_counter <= std_logic_vector(unsigned(current_stepper_counter) - delta_counter);
			end if;
		end if;
	end if;
	end process;
end block stepper_count;
end Behavioral;
