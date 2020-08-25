
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity sky_tracker is
    Port ( 
		   clk_50 : in STD_LOGIC := '0';
           rstn_50 : in STD_LOGIC := '1';
           clk_150 : in STD_LOGIC := '0';
           rstn_150 : in STD_LOGIC := '1';
			  
           ra_mode : out STD_LOGIC_VECTOR (2 downto 0);
           ra_enable_n : out STD_LOGIC;
           ra_sleep_n : out STD_LOGIC;
           ra_rst_n : out STD_LOGIC;
           ra_step : out STD_LOGIC;
           ra_direction : out STD_LOGIC;
           ra_fault_n : in STD_LOGIC;
		   
		       de_mode : out STD_LOGIC_VECTOR (2 downto 0);
           de_enable_n : out STD_LOGIC;
           de_sleep_n : out STD_LOGIC;
           de_rst_n : out STD_LOGIC;
           de_step : out STD_LOGIC;
           de_direction : out STD_LOGIC;
           de_fault_n : in STD_LOGIC;
           
           fc_mode : out STD_LOGIC_VECTOR (2 downto 0);
           fc_enable_n : out STD_LOGIC;
           fc_sleep_n : out STD_LOGIC;
           fc_rst_n : out STD_LOGIC;
           fc_step : out STD_LOGIC;
           fc_direction : out STD_LOGIC;
           fc_fault_n : in STD_LOGIC;
           
		       led_pwm : out STD_LOGIC;
			      
		       camera_trigger : out STD_LOGIC_VECTOR (1 downto 0);
		       ip_addr : out STD_LOGIC_VECTOR (7 downto 0);
		       led_status : out STD_LOGIC_VECTOR (7 downto 0);

           adc_address : out std_logic_vector (6 downto 0);
           adc_dbus : in std_logic_vector (15 downto 0);

			      
		       sts_acknowledge                           : out    std_logic                     := 'X';             -- acknowledge
           sts_irq                                   : out    std_logic                     := 'X';             -- irq
           sts_address                               : in   std_logic_vector(4 downto 0);                    -- address
           sts_bus_enable                            : in    std_logic;                                        -- bus_enable
           sts_byte_enable                           : in    std_logic_vector(3 downto 0);                     -- byte_enable
           sts_rw                                    : in    std_logic;                                        -- rw
           sts_write_data                            : in    std_logic_vector(31 downto 0);                    -- write_data
           sts_read_data                             : out   std_logic_vector(31 downto 0) := (others => 'X'); -- read_data
           
		       ctrl_acknowledge                          : out    std_logic                     := 'X';             -- acknowledge
           ctrl_irq                                  : out    std_logic                     := 'X';             -- irq
           ctrl_address                              : in   std_logic_vector(4 downto 0);                    -- address
           ctrl_bus_enable                           : in   std_logic;                                        -- bus_enable
           ctrl_byte_enable                          : in   std_logic_vector(3 downto 0);                     -- byte_enable
           ctrl_rw                                   : in   std_logic;                                        -- rw
           ctrl_write_data                           : in   std_logic_vector(31 downto 0);                    -- write_data
           ctrl_read_data                            : out    std_logic_vector(31 downto 0) := (others => 'X') --; -- read_data

        );
end sky_tracker;

architecture Behavioral of sky_tracker is
ATTRIBUTE MARK_DEBUG : string;
signal ra_step_count 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal ra_status     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal ra_cmdcontrol 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal ra_cmdtick           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal ra_cmdduration 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal ra_backlash_tick 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal ra_backlash_duration : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_counter_load 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_counter_max 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_trackctrl 			 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal de_step_count 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal de_status     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal de_cmdcontrol 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal de_cmdtick           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal de_cmdduration 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal de_backlash_tick 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal de_backlash_duration : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_counter_load 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_counter_max 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_trackctrl 			 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');


signal fc_step_count 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal fc_status     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal fc_cmdcontrol 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal fc_cmdtick           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal fc_cmdduration 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal fc_backlash_tick 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal fc_backlash_duration : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_counter_load 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_counter_max 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_trackctrl 			 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal ra_step_count_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal ra_status_sync     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal ra_cmdcontrol_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal ra_cmdtick_sync           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal ra_cmdduration_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal ra_backlash_tick_sync 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal ra_backlash_duration_sync : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_counter_load_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_counter_max_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_trackctrl_sync 			 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal de_step_count_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal de_status_sync     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal de_cmdcontrol_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal de_cmdtick_sync           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal de_cmdduration_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal de_backlash_tick_sync 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal de_backlash_duration_sync : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_counter_load_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_counter_max_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_trackctrl_sync 			 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal fc_step_count_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal fc_status_sync     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal fc_cmdcontrol_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal fc_cmdtick_sync           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal fc_cmdduration_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal fc_backlash_tick_sync 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal fc_backlash_duration_sync : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_counter_load_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_counter_max_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_trackctrl_sync 			 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal adc_channel 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal adc_data 			 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal ip_addr_buf, led_brightness, camera_trig : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal led_count : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal led_out : STD_LOGIC := '0';

ATTRIBUTE MARK_DEBUG of ctrl_acknowledge, ctrl_address, ctrl_bus_enable, ctrl_read_data: SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of de_cmdduration_sync, de_counter_max_sync, de_counter_load_sync, de_trackctrl_sync: SIGNAL IS "TRUE";
begin

  camera_trigger <= camera_trig(1 downto 0);
  ip_addr <= ip_addr_buf(7 downto 0);
  led_pwm <= led_out;

  adc_address <= adc_channel(6 downto 0);
  adc_data(15 downto 0) <= adc_dbus;

bus_imp : block
signal sts_ack, ctrl_ack : std_logic := '0';
begin
	process (clk_50, rstn_50) 
	begin
		if (rstn_50 = '0') then
			led_out <= '0';
			led_count <= (others => '0');
		elsif (rising_edge(clk_50)) then
			led_count <= std_logic_vector(unsigned(led_count) + 1);
			led_out <= led_out;
			if (led_count = "00000000") then
				led_out <= '1';
			end if;
			if (led_count = led_brightness(7 downto 0)) then
				led_out <= '0';
			end if;
		end if;
	end process;
	
	ctrl_irq <= '0';
	sts_irq <= '0';

	process (clk_150, rstn_150) 
	begin
		if (rstn_150 = '0') then
			sts_read_data <= (others => '0');
			sts_acknowledge <= '0';
			sts_ack <= '0';
		elsif (rising_edge(clk_150)) then
			--sts_read_data <= sts_read_data;
			sts_acknowledge <= sts_ack;
			sts_ack <= '0';
			if (sts_bus_enable = '1' and ctrl_rw = '1') then
			case sts_address(3 downto 0) is
				when "0000" =>
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= x"0110FFFF";
					      sts_ack <= '1';
							end if;
						end loop;
				when "0001" => 
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= x"FFFF1001";
					      sts_ack <= '1';
							end if;
						end loop;
				when "0010" =>
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= de_step_count;
					      sts_ack <= '1';
							end if;
						end loop;
				when "0011" => 
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= ra_step_count;
					      sts_ack <= '1';
							end if;
						end loop;
				when "0100" =>
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= fc_step_count;
					      sts_ack <= '1';
							end if;
						end loop;
				when "0101" =>
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= de_status;
					      sts_ack <= '1';
							end if;
						end loop;
				when "0110" => 
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= ra_status;
					      sts_ack <= '1';
							end if;
						end loop;
				when "0111" => 
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= fc_status;
					      sts_ack <= '1';
							end if;
						end loop;
				when "1000" => 
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= x"00000042";
					      sts_ack <= '1';
							end if;
						end loop;
				when "1001" => 
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= adc_data;
					      sts_ack <= '1';
							end if;
						end loop;
				when others =>
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= (others => '0');
					      sts_ack <= '1';
							end if;
						end loop;
			end case;
			end if;
		end if;
	end process;
	
	process (clk_150, rstn_150) 
	begin
		if (rstn_150 = '0') then
			ctrl_read_data <= (others => '0');
			ctrl_acknowledge <= '0';
			ctrl_ack <= '0';
		elsif (rising_edge(clk_150)) then
			--ctrl_read_data <= ctrl_read_data;
			ctrl_acknowledge <= ctrl_ack;
			ctrl_ack <= '0';
			if (ctrl_bus_enable = '1') then
			case ctrl_address(4 downto 0) is
				when "00000" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= de_counter_load(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								de_counter_load(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "00001" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= ra_counter_load(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								ra_counter_load(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "00010" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= fc_counter_load(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								fc_counter_load(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "00011" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= de_counter_max(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								de_counter_max(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "00100" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= ra_counter_max(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								ra_counter_max(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "00101" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= fc_counter_max(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								fc_counter_max(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "00110" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= de_cmdcontrol(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								de_cmdcontrol(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "00111" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= ra_cmdcontrol(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								ra_cmdcontrol(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "01000" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= fc_cmdcontrol(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								fc_cmdcontrol(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "01001" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= de_cmdduration(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								de_cmdduration(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "01010" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= ra_cmdduration(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								ra_cmdduration(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					
					ctrl_ack <= '1';
				when "01011" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= fc_cmdduration(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								fc_cmdduration(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "01100" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= de_trackctrl(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								de_trackctrl(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "01101" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= ra_trackctrl(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								ra_trackctrl(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "01110" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= fc_trackctrl(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								fc_trackctrl(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "01111" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= de_cmdtick(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								de_cmdtick(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "10000" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= ra_cmdtick(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								ra_cmdtick(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "10001" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= fc_cmdtick(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								fc_cmdtick(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "10010" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= de_backlash_tick(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								de_backlash_tick(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "10011" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= ra_backlash_tick(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								ra_backlash_tick(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "10100" =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= fc_backlash_tick(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								fc_backlash_tick(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "10101" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= de_backlash_duration(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								de_backlash_duration(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "10110" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= ra_backlash_duration(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								ra_backlash_duration(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "10111" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= fc_backlash_duration(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								fc_backlash_duration(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "11000" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= ip_addr_buf(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								ip_addr_buf(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "11001" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= led_brightness(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								led_brightness(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "11010" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= camera_trig(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								camera_trig(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				when "11011" => 
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= adc_channel(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								adc_channel(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
					
				when others =>
					if ctrl_rw = '1' then
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
						    ctrl_read_data(byte_index*8+7 downto byte_index*8) <= (others => '0');
							end if;
						end loop;
          end if;
					ctrl_ack <= '1';
			end case;
			end if;
		end if;
	end process;

end block bus_imp;


drv_ips : block
	signal ra_direction_b, de_direction_b, fc_direction_b : std_logic := '0';
begin
	process (clk_50, rstn_50)
	begin
		if (rstn_50 = '0') then
			led_status <= (others => '0');
			ra_direction <= ra_direction_b;
			de_direction <= de_direction_b;
			fc_direction <= fc_direction_b;
		elsif (rising_edge(clk_50)) then
			ra_direction <= ra_direction_b;
			de_direction <= de_direction_b;
			fc_direction <= fc_direction_b;
			led_status(0) <= ra_status(0) or ra_status(1) or ra_status(2);
			led_status(4) <= de_status(0) or de_status(1) or de_status(2);
			if ((ra_status(0)  or ra_status(1) or ra_status(2)) = '0') then
				led_status(3 downto 1) <= (others => '0');
			else
				led_status(1) <= ra_direction_b;
				led_status(2) <= ra_status(0) and (not (ra_status(2) or ra_status(1)));
				led_status(3) <= ra_step_count(8); 
			end if;
			if ((de_status(0) or de_status(1) or de_status(2)) = '0') then
				led_status(7 downto 5) <= (others => '0');
			else
				led_status(5) <= de_direction_b;
				led_status(6) <= de_status(0) and (not (de_status(1) or de_status(2)));
				led_status(7) <= de_step_count(8); 
			end if;
		end if;
	end process;
	
	UClockDomainSync: entity work.ClockDomainSync 
    Port map ( 
     
	 clk_50  => clk_50  ,
     clk_150 => clk_150,
           
           
     ra_step_count        => ra_step_count        ,                  
     ra_status            => ra_status            ,  
     ra_cmdcontrol        => ra_cmdcontrol        ,      
     ra_cmdtick           => ra_cmdtick           ,   
     ra_cmdduration       => ra_cmdduration       ,       
     ra_backlash_tick     => ra_backlash_tick     ,         
     ra_backlash_duration => ra_backlash_duration ,             
     ra_counter_load      => ra_counter_load      ,        
     ra_counter_max       => ra_counter_max       ,       
     ra_trackctrl         => ra_trackctrl         ,     
    
     de_step_count         => de_step_count         ,   
     de_status             => de_status             ,
     de_cmdcontrol         => de_cmdcontrol         , 
     de_cmdtick            => de_cmdtick            , 
     de_cmdduration        => de_cmdduration        , 
     de_backlash_tick      => de_backlash_tick      ,   
     de_backlash_duration  => de_backlash_duration  ,       
     de_counter_load       => de_counter_load       ,  
     de_counter_max        => de_counter_max        , 
     de_trackctrl          => de_trackctrl          ,        
    
     ra_step_count_sync  => ra_step_count_sync    ,
     ra_status_sync      => ra_status_sync        ,
     ra_cmdcontrol_sync  => ra_cmdcontrol_sync    ,
     ra_cmdtick_sync     => ra_cmdtick_sync       ,
     ra_cmdduration_sync => ra_cmdduration_sync   ,
     ra_backlash_tick_sync 	   => ra_backlash_tick_sync,
     ra_backlash_duration_sync => ra_backlash_duration_sync,
     ra_counter_load_sync 		=> ra_counter_load_sync,
     ra_counter_max_sync 		=> ra_counter_max_sync,
     ra_trackctrl_sync 			=> ra_trackctrl_sync,
    
     fc_step_count         => fc_step_count         ,   
     fc_status             => fc_status             ,
     fc_cmdcontrol         => fc_cmdcontrol         , 
     fc_cmdtick            => fc_cmdtick            , 
     fc_cmdduration        => fc_cmdduration        , 
     fc_backlash_tick      => fc_backlash_tick      ,   
     fc_backlash_duration  => fc_backlash_duration  ,       
     fc_counter_load       => fc_counter_load       ,  
     fc_counter_max        => fc_counter_max        , 
     fc_trackctrl          => fc_trackctrl          ,        
    
     fc_step_count_sync  => fc_step_count_sync    ,
     fc_status_sync      => fc_status_sync        ,
     fc_cmdcontrol_sync  => fc_cmdcontrol_sync    ,
     fc_cmdtick_sync     => fc_cmdtick_sync       ,
     fc_cmdduration_sync => fc_cmdduration_sync   ,
     fc_backlash_tick_sync 	   => fc_backlash_tick_sync,
     fc_backlash_duration_sync => fc_backlash_duration_sync,
     fc_counter_load_sync 		=> fc_counter_load_sync,
     fc_counter_max_sync 		=> fc_counter_max_sync,
     fc_trackctrl_sync 			=> fc_trackctrl_sync,
    
     de_step_count_sync  => de_step_count_sync     ,
     de_status_sync      => de_status_sync         ,
     de_cmdcontrol_sync  => de_cmdcontrol_sync     ,
     de_cmdtick_sync     => de_cmdtick_sync        ,
     de_cmdduration_sync => de_cmdduration_sync    ,
     de_backlash_tick_sync 	   => de_backlash_tick_sync   ,
     de_backlash_duration_sync => de_backlash_duration_sync   ,
     de_counter_load_sync 		=> de_counter_load_sync,
     de_counter_max_sync 		=> de_counter_max_sync,
     de_trackctrl_sync 			=> de_trackctrl_sync
  );

DRV_RA :  entity work.drv8825	
	generic map ( REVERSE_DIRECTION => false )
	port map (
		clk_50 => clk_50,
		ctrl_backlash_duration => ra_backlash_duration_sync,
		ctrl_backlash_tick => ra_backlash_tick_sync,
		ctrl_cmdcontrol => ra_cmdcontrol_sync,
		ctrl_cmdduration => ra_cmdduration_sync,
		ctrl_cmdtick => ra_cmdtick_sync,
		ctrl_counter_load => ra_counter_load_sync,
		ctrl_counter_max => ra_counter_max_sync,
		ctrl_status => ra_status_sync,
		ctrl_step_count(31 downto 0) => ra_step_count_sync(31 downto 0),
		ctrl_trackctrl(31 downto 0) => ra_trackctrl_sync(31 downto 0),
		drv8825_direction => ra_direction_b,
		drv8825_enable_n => ra_enable_n,
		drv8825_fault_n => ra_fault_n,
		drv8825_mode(2 downto 0) => ra_mode(2 downto 0),
		drv8825_rst_n => ra_rst_n,
		drv8825_sleep_n => ra_sleep_n,
		drv8825_step => ra_step,
		rstn_50 => rstn_50

	);
	
	DRV_DE :  entity work.drv8825	
	generic map ( REVERSE_DIRECTION => true )
	port map (
		clk_50 => clk_50,
		ctrl_backlash_duration => de_backlash_duration_sync,
		ctrl_backlash_tick => de_backlash_tick_sync,
		ctrl_cmdcontrol => de_cmdcontrol_sync,
		ctrl_cmdduration => de_cmdduration_sync,
		ctrl_cmdtick => de_cmdtick_sync,
		ctrl_counter_load => de_counter_load_sync,
		ctrl_counter_max => de_counter_max_sync,
		ctrl_status => de_status_sync,
		ctrl_step_count(31 downto 0) => de_step_count_sync(31 downto 0),
		ctrl_trackctrl(31 downto 0) => de_trackctrl_sync(31 downto 0),
		drv8825_direction => de_direction_b,
		drv8825_enable_n => de_enable_n,
		drv8825_fault_n => de_fault_n,
		drv8825_mode(2 downto 0) => de_mode(2 downto 0),
		drv8825_rst_n => de_rst_n,
		drv8825_sleep_n => de_sleep_n,
		drv8825_step => de_step,
		rstn_50 => rstn_50

	);
	
	DRV_FC :  entity work.drv8825	
	generic map ( REVERSE_DIRECTION => false )
	port map (
		clk_50 => clk_50,
		ctrl_backlash_duration => fc_backlash_duration_sync,
		ctrl_backlash_tick => fc_backlash_tick_sync,
		ctrl_cmdcontrol => fc_cmdcontrol_sync,
		ctrl_cmdduration => fc_cmdduration_sync,
		ctrl_cmdtick => fc_cmdtick_sync,
		ctrl_counter_load => fc_counter_load_sync,
		ctrl_counter_max => fc_counter_max_sync,
		ctrl_status => fc_status_sync,
		ctrl_step_count(31 downto 0) => fc_step_count_sync(31 downto 0),
		ctrl_trackctrl(31 downto 0) => de_trackctrl_sync(31 downto 0),
		drv8825_direction => fc_direction_b,
		drv8825_enable_n => fc_enable_n,
		drv8825_fault_n => fc_fault_n,
		drv8825_mode(2 downto 0) => fc_mode(2 downto 0),
		drv8825_rst_n => fc_rst_n,
		drv8825_sleep_n => fc_sleep_n,
		drv8825_step => fc_step,
		rstn_50 => rstn_50

	);
end block drv_ips;

end Behavioral;
