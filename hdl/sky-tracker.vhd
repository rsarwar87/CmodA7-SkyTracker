
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity sky_tracker is
    Port ( 
		   clk_50                    : in STD_LOGIC := '0';
           rstn_50                   : in STD_LOGIC := '1';
           clk_150                   : in STD_LOGIC := '0';
           rstn_150                  : in STD_LOGIC := '1';
			 
           ra_mode                   : out STD_LOGIC_VECTOR (2 downto 0); -- tmc2226: bit 0 is low power pin (always high)
           ra_enable_n               : out STD_LOGIC;                 -- tmc2226 and drv8825 has same function  
           ra_sleep_n                : out STD_LOGIC;                  -- tmc2226 pin is external CLK (always low)
           ra_rst_n                  : out STD_LOGIC;                    -- tmc2226 pin is standby pin (always low)
           ra_step                   : out STD_LOGIC;                     -- tmc2226 and drv8825 has same function 
           ra_direction              : out STD_LOGIC;                -- tmc2226 and drv8825 has same function
           ra_fault_n                : in STD_LOGIC;                   -- NOT CONNECTED
		  
		   de_mode                   : out STD_LOGIC_VECTOR (2 downto 0); -- tmc2226: bit 0 is low power pin (always high)    
           de_enable_n               : out STD_LOGIC;                 -- tmc2226 and drv8825 has same function            
           de_sleep_n                : out STD_LOGIC;                  -- tmc2226 pin is external CLK (always low)         
           de_rst_n                  : out STD_LOGIC;                    -- tmc2226 pin is standby pin (always low)          
           de_step                   : out STD_LOGIC;                     -- tmc2226 and drv8825 has same function            
           de_direction              : out STD_LOGIC;                -- tmc2226 and drv8825 has same function            
           de_fault_n                : in STD_LOGIC;                   -- NOT CONNECTED                                    
          
           fc_mode                   : out STD_LOGIC_VECTOR (2 downto 0); -- tmc2226: bit 0 is low power pin (always high)    
           fc_enable_n               : out STD_LOGIC;                 -- tmc2226 and drv8825 has same function            
           fc_sleep_n                : out STD_LOGIC;                  -- tmc2226 pin is external CLK (always low)         
           fc_rst_n                  : out STD_LOGIC;                    -- tmc2226 pin is standby pin (always low)          
           fc_step                   : out STD_LOGIC;                     -- tmc2226 and drv8825 has same function            
           fc_direction              : out STD_LOGIC;                -- tmc2226 and drv8825 has same function            
           fc_fault_n                : in STD_LOGIC;                   -- NOT CONNECTED                                    
           
           
           iic_encoder_status        : in std_logic_vector(3 downto 0);
           iic_encoder_position      : in std_logic_vector(11 downto 0);
           
		   led_pwm                   : out std_logic_vector(1 downto 0);
			      
		   camera_trigger            : out STD_LOGIC_VECTOR (1 downto 0);
		   ip_addr                   : out STD_LOGIC_VECTOR (7 downto 0);
		   led_status                : out STD_LOGIC_VECTOR (7 downto 0);

           adc_address               : out std_logic_vector (6 downto 0);
           adc_dbus                  : in std_logic_vector (15 downto 0);

			      
		   sts_acknowledge           : out  std_logic                     := 'X';             -- acknowledge
           sts_irq                   : out  std_logic                     := 'X';             -- irq
           sts_address               : in   std_logic_vector(4 downto 0);                    -- address
           sts_bus_enable            : in   std_logic;                                        -- bus_enable
           sts_byte_enable           : in   std_logic_vector(3 downto 0);                     -- byte_enable
           sts_rw                    : in   std_logic;                                        -- rw
           sts_write_data            : in   std_logic_vector(31 downto 0);                    -- write_data
           sts_read_data             : out  std_logic_vector(31 downto 0) := (others => 'X'); -- read_data
     
		   ctrl_acknowledge          : out  std_logic                     := 'X';             -- acknowledge
           ctrl_irq                  : out  std_logic                     := 'X';             -- irq
           ctrl_address              : in   std_logic_vector(4 downto 0);                    -- address
           ctrl_bus_enable           : in   std_logic;                                        -- bus_enable
           ctrl_byte_enable          : in   std_logic_vector(3 downto 0);                     -- byte_enable
           ctrl_rw                   : in   std_logic;                                        -- rw
           ctrl_write_data           : in   std_logic_vector(31 downto 0);                    -- write_data
           ctrl_read_data            : out  std_logic_vector(31 downto 0) := (others => 'X') --; -- read_data

        );
end sky_tracker;

architecture Behavioral of sky_tracker is

component blk_mem_gen_0 IS
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END component;

ATTRIBUTE MARK_DEBUG : string;
signal ra_step_count 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal ra_status     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal ra_cmdcontrol 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal ra_cmdtick            : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal ra_cmdduration 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal ra_backlash_tick 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal ra_backlash_duration  : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_counter_load 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_counter_max 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_trackctrl 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal de_step_count 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal de_status     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal de_cmdcontrol 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal de_cmdtick            : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal de_cmdduration 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal de_backlash_tick 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal de_backlash_duration  : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_counter_load 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_counter_max 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_trackctrl 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');


signal fc_step_count 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal fc_status     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal fc_cmdcontrol 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal fc_cmdtick            : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal fc_cmdduration 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal fc_backlash_tick 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal fc_backlash_duration  : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_counter_load 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_counter_max 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_trackctrl 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal ra_step_count_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal ra_status_sync     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal ra_cmdcontrol_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal ra_cmdtick_sync           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal ra_cmdduration_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal ra_backlash_tick_sync 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal ra_backlash_duration_sync : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_counter_load_sync 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_counter_max_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal ra_trackctrl_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal de_step_count_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal de_status_sync     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal de_cmdcontrol_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal de_cmdtick_sync           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal de_cmdduration_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal de_backlash_tick_sync 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal de_backlash_duration_sync : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_counter_load_sync 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_counter_max_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal de_trackctrl_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal fc_step_count_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal fc_status_sync     		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal fc_cmdcontrol_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- steps, go, stop, direction
signal fc_cmdtick_sync           : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal fc_cmdduration_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');    -- speed of command
signal fc_backlash_tick_sync 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');  -- speed of backlash
signal fc_backlash_duration_sync : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_counter_load_sync 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_counter_max_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal fc_trackctrl_sync 		 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal pec_calib, pec_data_synced, pec_data 	 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- duration of backlash
signal encoder_position                          : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal encoder_position_mux, iic_encoder_position_synced, encoder_position_synced     : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');

signal is_tmc_buf, is_tmc_sync, ip_addr_buf, led_brightness, camera_trig : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal led_count                                                         : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal  led_count2                                                         : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
signal led_out, led_out2, bram_update, bram_update_delayed                         : STD_LOGIC := '0';

ATTRIBUTE MARK_DEBUG of pec_calib, pec_data_synced, iic_encoder_status, iic_encoder_position_synced: SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of encoder_position_mux, encoder_position_synced, iic_encoder_position: SIGNAL IS "TRUE";
ATTRIBUTE MARK_DEBUG of sts_address, sts_read_data, sts_bus_enable, ctrl_rw: SIGNAL IS "TRUE";
begin

  camera_trigger <= camera_trig(1 downto 0);
  ip_addr <= ip_addr_buf(7 downto 0);
  led_pwm(0) <= led_out;
  led_pwm(1) <= led_out2;


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
		process (clk_50, rstn_50) 
	begin
		if (rstn_50 = '0') then
			led_out2 <= '0';
			led_count2 <= (others => '0');
		elsif (rising_edge(clk_50)) then
			led_count2 <= std_logic_vector(unsigned(led_count2) + 1);
			led_out2 <= led_out2;
			if (led_count2 = "0000000000000000") then
				led_out2 <= '1';
			end if;
			if (led_count2 = led_brightness(31 downto 16)) then
				led_out2 <= '0';
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
					      sts_read_data <= ra_step_count;
					      sts_ack <= '1';
						end if;
					end loop;
				when "0011" => 
					for byte_index in 0 to (32/8-1) loop
						if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= de_step_count;
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
					      sts_read_data <= ra_status;
					      sts_ack <= '1';
						end if;
					end loop;
				when "0110" => 
					for byte_index in 0 to (32/8-1) loop
						if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= de_status;
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
					      sts_read_data <= pec_data;
					      sts_ack <= '1';
						end if;
					end loop;
				when "1010" => 
					for byte_index in 0 to (32/8-1) loop
						if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data <= encoder_position;
					      sts_ack <= '1';
						end if;
					end loop;
				when "1011" => 
					for byte_index in 0 to (32/8-1) loop
						if (ctrl_byte_enable(byte_index) = '1') then
					      sts_read_data(19 downto 16) <= iic_encoder_status;
					      sts_read_data(11 downto 0) <= iic_encoder_position;
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
			bram_update <= '0';
			bram_update_delayed <= '0';
		elsif (rising_edge(clk_150)) then
			--ctrl_read_data <= ctrl_read_data;
			ctrl_acknowledge <= ctrl_ack;
			ctrl_ack <= '0';
			if (ctrl_bus_enable = '1') then
			bram_update <= '0';
			bram_update_delayed <= bram_update;
			case ctrl_address(4 downto 0) is
				when "00000" =>
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
				when "00001" => 
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
				when "00100" => 
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
				when "00111" => 
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
				when "01010" => 
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
				when "01101" => 
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
				when "10000" => 
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
				when "10011" => 
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
				when "10110" => 
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
						      ctrl_read_data(byte_index*8+7 downto byte_index*8) <= pec_calib(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					else
                        bram_update <= '1';
						for byte_index in 0 to (32/8-1) loop
							if (ctrl_byte_enable(byte_index) = '1') then
								pec_calib(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
							end if;
						end loop;
					end if;
					ctrl_ack <= '1';
				 when "11100" => 
                    if ctrl_rw = '1' then
                        for byte_index in 0 to (32/8-1) loop
                             if (ctrl_byte_enable(byte_index) = '1') then
                                ctrl_read_data(byte_index*8+7 downto byte_index*8) <= is_tmc_buf(byte_index*8+7 downto byte_index*8);
                             end if;
                        end loop;
                    else
                       for byte_index in 0 to (32/8-1) loop
                            if (ctrl_byte_enable(byte_index) = '1') then
                                  is_tmc_buf(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
                            end if;
                       end loop;
                    end if;
                    ctrl_ack <= '1';
				 when "11101" => 
                    if ctrl_rw = '1' then
                        for byte_index in 0 to (32/8-1) loop
                            if (ctrl_byte_enable(byte_index) = '1') then
                                ctrl_read_data(byte_index*8+7 downto byte_index*8) <= encoder_position(byte_index*8+7 downto byte_index*8);
                            end if;
                        end loop;
                    else
                        for byte_index in 0 to (32/8-1) loop
                            if (ctrl_byte_enable(byte_index) = '1') then
                               encoder_position(byte_index*8+7 downto byte_index*8) <= ctrl_write_data(byte_index*8+7 downto byte_index*8);
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
           
     pec_data               => pec_data,
     pec_encoder            => encoder_position,
     pec_data_synced        => pec_data_synced,
     pec_encoder_synced     => encoder_position_synced, 
     iic_pec_encoder_synced => iic_encoder_position_synced(11 downto 0),
     iic_pec_encoder        => iic_encoder_position,
     
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
    
     ra_step_count_sync         => ra_step_count_sync    ,
     ra_status_sync             => ra_status_sync        ,
     ra_cmdcontrol_sync         => ra_cmdcontrol_sync    ,
     ra_cmdtick_sync            => ra_cmdtick_sync       ,
     ra_cmdduration_sync        => ra_cmdduration_sync   ,
     ra_backlash_tick_sync 	    => ra_backlash_tick_sync,
     ra_backlash_duration_sync  => ra_backlash_duration_sync,
     ra_counter_load_sync 		=> ra_counter_load_sync,
     ra_counter_max_sync 		=> ra_counter_max_sync,
     ra_trackctrl_sync 			=> ra_trackctrl_sync,
    
     fc_step_count              => fc_step_count         ,   
     fc_status                  => fc_status             ,
     fc_cmdcontrol              => fc_cmdcontrol         , 
     fc_cmdtick                 => fc_cmdtick            , 
     fc_cmdduration             => fc_cmdduration        , 
     fc_backlash_tick           => fc_backlash_tick      ,   
     fc_backlash_duration       => fc_backlash_duration  ,       
     fc_counter_load            => fc_counter_load       ,  
     fc_counter_max             => fc_counter_max        , 
     fc_trackctrl               => fc_trackctrl          ,   
    
     is_tmc_buf                 => is_tmc_buf,
     is_tmc_sync                => is_tmc_sync,     
    
     fc_step_count_sync         => fc_step_count_sync    ,
     fc_status_sync             => fc_status_sync        ,
     fc_cmdcontrol_sync         => fc_cmdcontrol_sync    ,
     fc_cmdtick_sync            => fc_cmdtick_sync       ,
     fc_cmdduration_sync        => fc_cmdduration_sync   ,
     fc_backlash_tick_sync 	    => fc_backlash_tick_sync,
     fc_backlash_duration_sync  => fc_backlash_duration_sync,
     fc_counter_load_sync 		=> fc_counter_load_sync,
     fc_counter_max_sync 		=> fc_counter_max_sync,
     fc_trackctrl_sync 			=> fc_trackctrl_sync,
    
     de_step_count_sync         => de_step_count_sync     ,
     de_status_sync             => de_status_sync         ,
     de_cmdcontrol_sync         => de_cmdcontrol_sync     ,
     de_cmdtick_sync            => de_cmdtick_sync        ,
     de_cmdduration_sync        => de_cmdduration_sync    ,
     de_backlash_tick_sync 	    => de_backlash_tick_sync   ,
     de_backlash_duration_sync  => de_backlash_duration_sync   ,
     de_counter_load_sync 		=> de_counter_load_sync,
     de_counter_max_sync 		=> de_counter_max_sync,
     de_trackctrl_sync 			=> de_trackctrl_sync
  );

DRV_RA :  entity work.drv8825	
	generic map ( REVERSE_DIRECTION => false )
	port map (
		clk_50                        => clk_50,
		ctrl_trackctrl_pec            => pec_data_synced(15 downto 0),
		ctrl_backlash_duration        => ra_backlash_duration_sync,
		ctrl_backlash_tick            => ra_backlash_tick_sync,
		ctrl_cmdcontrol               => ra_cmdcontrol_sync,
		ctrl_cmdduration              => ra_cmdduration_sync,
		ctrl_cmdtick                  => ra_cmdtick_sync,
		ctrl_counter_load             => ra_counter_load_sync,
		ctrl_counter_max              => ra_counter_max_sync,
		ctrl_status                   => ra_status_sync,
		ctrl_step_count(31 downto 0)  => ra_step_count_sync(31 downto 0),
		ctrl_trackctrl(31 downto 0)   => ra_trackctrl_sync(31 downto 0),
		is_tmc2226                    => is_tmc_sync(1),
		drv8825_direction             => ra_direction_b,
		drv8825_enable_n              => ra_enable_n,
		drv8825_fault_n               => ra_fault_n,
		drv8825_mode(2 downto 0)      => ra_mode(2 downto 0),
		drv8825_rst_n                 => ra_rst_n,
		drv8825_sleep_n               => ra_sleep_n,
		drv8825_step                  => ra_step,
		rstn_50                       => rstn_50

	);
	
	DRV_DE :  entity work.drv8825	
	generic map ( REVERSE_DIRECTION => true )
	port map (
		clk_50                        => clk_50,
		ctrl_backlash_duration        => de_backlash_duration_sync,
		ctrl_backlash_tick            => de_backlash_tick_sync,
		ctrl_cmdcontrol               => de_cmdcontrol_sync,
		ctrl_cmdduration              => de_cmdduration_sync,
		ctrl_cmdtick                  => de_cmdtick_sync,
		ctrl_counter_load             => de_counter_load_sync,
		ctrl_counter_max              => de_counter_max_sync,
		ctrl_status                   => de_status_sync,
		ctrl_step_count(31 downto 0)  => de_step_count_sync(31 downto 0),
		ctrl_trackctrl(31 downto 0)   => de_trackctrl_sync(31 downto 0),
		is_tmc2226                    => is_tmc_sync(0),
		drv8825_direction             => de_direction_b,
		drv8825_enable_n              => de_enable_n,
		drv8825_fault_n               => de_fault_n,
		drv8825_mode(2 downto 0)      => de_mode(2 downto 0),
		drv8825_rst_n                 => de_rst_n,
		drv8825_sleep_n               => de_sleep_n,
		drv8825_step                  => de_step,
		rstn_50                       => rstn_50

	);
	
	DRV_FC :  entity work.drv8825	
	generic map ( REVERSE_DIRECTION => false )
	port map (
		clk_50                        => clk_50,
		ctrl_backlash_duration        => fc_backlash_duration_sync,
		ctrl_backlash_tick            => fc_backlash_tick_sync,
		ctrl_cmdcontrol               => fc_cmdcontrol_sync,
		ctrl_cmdduration              => fc_cmdduration_sync,
		ctrl_cmdtick                  => fc_cmdtick_sync,
		ctrl_counter_load             => fc_counter_load_sync,
		ctrl_counter_max              => fc_counter_max_sync,
		ctrl_status                   => fc_status_sync,
		ctrl_step_count(31 downto 0)  => fc_step_count_sync(31 downto 0),
		ctrl_trackctrl(31 downto 0)   => fc_trackctrl_sync(31 downto 0),
		is_tmc2226                    => is_tmc_sync(2),
		drv8825_direction             => fc_direction_b,
		drv8825_enable_n              => fc_enable_n,
		drv8825_fault_n               => fc_fault_n,
		drv8825_mode(2 downto 0)      => fc_mode(2 downto 0),
		drv8825_rst_n                 => fc_rst_n,
		drv8825_sleep_n               => fc_sleep_n,
		drv8825_step                  => fc_step,
		rstn_50                       => rstn_50

	);
end block drv_ips;


  PEC0 : blk_mem_gen_0 
  PORT MAP (
    clka   => clk_150,
    wea(0) => bram_update_delayed,
    addra  => pec_calib(31 DOWNTO 20),
    dina   => pec_calib(15 DOWNTO 0),
    clkb   => clk_50,
    enb    => '1',
    addrb  => encoder_position_mux(11 downto 0),
    doutb  => pec_data_synced(15 downto 0)
  );
  
  process(clk_50) begin
  if rising_edge(clk_50) then
        if encoder_position_synced(12) = '0' then
            encoder_position_mux(11 downto 0) <= encoder_position_synced(11 downto 0);
        else
            encoder_position_mux(11 downto 0) <= iic_encoder_position_synced(11 downto 0);
        end if;
  end if;
  end process;

end Behavioral;
