 -- Quartus Prime VHDL Template
-- Single port RAM with single read/write address 

library ieee;
use ieee.std_logic_1164.all;

entity SKY_TOP is
    port 
    (
        -------- CLOCKS --------------------
        clock_50, clock_100, clock_150, reset_n		: in 	std_logic;
        
        pi_camera_trigger_in  : in std_logic;
        pi_camera_trigger_out : out std_logic;
        pi_pwm_led_in         : in std_logic;
        pi_pwm_led_out        : out std_logic;
			
		  led_out_hw      : out std_logic;
        led_status		: out	std_logic_vector(7 downto 0);
		  adc_dbus		   : in	std_logic_vector(11 downto 0);
		  adc_channel		: out	std_logic_vector(2 downto 0);
        
        led_polar   		: out STD_LOGIC;
        camera_triggers : out STD_LOGIC_VECTOR (1 downto 0);
        
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
        ------- Pi-SPI 			--------------------
        PI_SCLK 		: in	std_logic;
        PI_SS_N			: in	std_logic_vector(1 downto 0);
        PI_MOSI			: in	std_logic;
        PI_MISO			: out	std_logic
    );
end SKY_TOP;

architecture rtl of SKY_TOP is
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

    constant ADDR_WIDTH : Positive range 8 to 64 := 8;
	 constant DATA_WIDTH : Positive range 8 to 64 := 32;
	 constant AUTO_INC_ADDRESS : STD_LOGIC := '0';
    
	 signal sts_byte_enable                           : std_logic_vector(3 downto 0);                     -- byte_enable
    signal sts_irq                                   : std_logic                     := 'X';             -- irq
    signal sts_acknowledge                           : std_logic                     := 'X';             -- acknowledge
    signal sts_address                               : std_logic_vector(4 downto 0);                    -- address
    signal sts_bus_enable                            : std_logic;                                        -- bus_enable
    signal sts_rw                                    : std_logic_vector(0 downto 0);                                        -- rw
    signal sts_write_data                            : std_logic_vector(31 downto 0);                    -- write_data
    signal sts_read_data                             : std_logic_vector(31 downto 0) := (others => 'X'); -- read_data
               
    signal ctrl_byte_enable                          : std_logic_vector(3 downto 0);                     -- byte_enable
    signal ctrl_irq                                  : std_logic                     := 'X';             -- irq
    signal ctrl_acknowledge                          : std_logic                     := 'X';             -- acknowledge
    signal ctrl_address                              : std_logic_vector(4 downto 0);                    -- address
    signal ctrl_bus_enable                           : std_logic;                                        -- bus_enable
    signal ctrl_rw                                   : std_logic_vector(0 downto 0);                                        -- rw
    signal ctrl_write_data                           : std_logic_vector(31 downto 0);                    -- write_data
    signal ctrl_read_data                            : std_logic_vector(31 downto 0) := (others => 'X');  -- read_data
    

    signal spi_ctrl_address                              : std_logic_vector(4 downto 0);                    -- address
    signal spi_ctrl_rw                                   : std_logic_vector(0 downto 0);                                        -- rw
    signal spi_ctrl_write_data                           : std_logic_vector(31 downto 0);                    -- write_data
    signal spi_ctrl_read_data                            : std_logic_vector(31 downto 0) := (others => 'X');  -- read_data
    signal spi_sts_read_data                             : std_logic_vector(31 downto 0) := (others => 'X'); -- read_data
    
    signal spi_delayed_clk : std_logic := '0';  
    
    signal led_level : std_logic_vector(4 downto 0) := (others => '0');
    
    
    signal wb_strobe :  STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal spi_wb_strobe :  STD_LOGIC_VECTOR(1 downto 0) := "00";
	 signal wb_cycle :  STD_LOGIC;
	 signal wb_write :  STD_LOGIC;
	 signal wb_address :  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
	 signal wb_data_i1 :  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	 signal wb_data_i0 :  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	 signal wb_data_o :  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	 signal wb_ack, spi_wb_ack :  STD_LOGIC_VECTOR(0 downto 0);
    
	 signal led_level_sync : std_logic_vector(4 downto 0);
begin
    
   
SKYTRACKER : block
    component sky_tracker is
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
    end component sky_tracker;

    signal ip_addr, ip_led_status, ip_led_status_sync: STD_LOGIC_VECTOR (7 downto 0);
    
    
begin
    
    pi_camera_trigger_out <= pi_camera_trigger_in;
    pi_pwm_led_out        <= pi_pwm_led_in;

	  U_SKYTRACKER :  component sky_tracker	
		port map (
		     clk_50  => clock_50,
           rstn_50 => reset_n,
		     clk_150  => clock_150,
           rstn_150 => reset_n,
			  
           ra_mode => ra_mode,
           ra_enable_n => ra_enable_n,
           ra_sleep_n => ra_sleep_n,
           ra_rst_n => ra_rst_n,
           ra_step => ra_step,
           ra_direction => ra_direction,
           ra_fault_n => ra_fault_n,
		   
		       de_mode => de_mode,
           de_enable_n => de_enable_n,
           de_sleep_n => de_sleep_n,
           de_rst_n => de_rst_n,
           de_step => de_step,
           de_direction => de_direction,
           de_fault_n => de_fault_n,
		   
		     fc_mode => fc_mode,
           fc_enable_n => fc_enable_n,
           fc_sleep_n => fc_sleep_n,
           fc_rst_n => fc_rst_n,
           fc_step => fc_step,
           fc_direction => fc_direction,
           fc_fault_n => fc_fault_n,
           
		     led_pwm => led_polar,
		     camera_trigger => camera_triggers,
		     ip_addr => ip_addr,
		     led_status => ip_led_status,
		   
           adc_address(2 downto 0) => adc_channel,
           adc_dbus(11 downto 0) => adc_dbus,

   		     sts_acknowledge                           => sts_acknowledge,                           --                            sts.acknowledge
           
            sts_irq                                   => sts_irq,                                   --                               .irq
            sts_address                               => sts_address,                               --                               .address
            sts_bus_enable                            => sts_bus_enable,                            --                               .bus_enable
            sts_byte_enable                           => sts_byte_enable,                           --                               .byte_enable
            sts_rw                                    => sts_rw(0),                                    --                               .rw
            sts_write_data                            => sts_write_data,                            --                               .write_data
            sts_read_data                             => sts_read_data,                             --                               .read_data
            ctrl_acknowledge                          => ctrl_acknowledge,                          --                           ctrl.acknowledge
            ctrl_irq                                  => ctrl_irq,                                  --                               .irq
            ctrl_address                              => ctrl_address,                              --                               .address
            ctrl_bus_enable                           => ctrl_bus_enable,                           --                               .bus_enable
            ctrl_byte_enable                          => ctrl_byte_enable,                          --                               .byte_enable
            ctrl_rw                                   => ctrl_rw(0),                                   --                               .rw
            ctrl_write_data                           => ctrl_write_data,                           --                               .write_data
            ctrl_read_data                            => ctrl_read_data --,  
	 );
	 SyncBusToClock_led_status : sync_Vector 
      generic map (
        MASTER_BITS => 8, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clock_50,                                                  -- <Clock>  input clock
		Clock2        => clock_150,                                                 -- <Clock>  output clock
		Input         => ip_led_status,   -- @Clock1:  input vector
		Output        => ip_led_status_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
		
	               -- acknowledge
	 sts_address <= ctrl_address;
     sts_bus_enable  <= wb_address(5) and (spi_wb_strobe(0) or spi_wb_strobe(1));              -- bus_enable
     sts_byte_enable <= "1111";             -- byte_enable
     sts_rw          <= ctrl_rw;               -- rw
     sts_write_data  <= spi_ctrl_write_data;             -- write_data
     wb_data_i0      <= spi_sts_read_data when wb_address(5) = '1' else spi_ctrl_read_data;                -- read_data
    
     spi_ctrl_address     <= wb_address(4 downto 0);             -- address
     ctrl_bus_enable  <= not wb_address(5) and (spi_wb_strobe(0) or spi_wb_strobe(1));           -- bus_enable
     ctrl_byte_enable <= "1111";           -- byte_enable
     spi_ctrl_rw(0)          <= not wb_write;           -- rw
     spi_ctrl_write_data  <= wb_data_o;           -- write_data
     wb_data_i1       <= spi_ctrl_read_data ;              --; -- read_data
     
     spi_wb_ack(0)          <= ctrl_acknowledge or sts_acknowledge; 
      
	  SyncBusToClock_wb_ack : sync_Vector 
      generic map (
        MASTER_BITS => 1, SYNC_DEPTH => 2
      )
      port map(
        Clock1        => clock_150,                                                  -- <Clock>  input clock
		Clock2        => spi_delayed_clk,                                                 -- <Clock>  output clock
		Input         => spi_wb_ack,   -- @Clock1:  input vector
		Output        => wb_ack ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
      
      SyncBusToClock_sts_address : sync_Vector 
      generic map (
        MASTER_BITS => 5, SYNC_DEPTH => 2
      )
      port map(
        Clock1        => spi_delayed_clk ,                                                  -- <Clock>  input clock
		Clock2        => clock_150,                                                 -- <Clock>  output clock
		Input         => spi_ctrl_address,   -- @Clock1:  input vector
		Output        => ctrl_address,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
      SyncBusToClock_wb_strobe : sync_Vector 
      generic map (
        MASTER_BITS => 2, SYNC_DEPTH => 2
      )
      port map(
        Clock1        => spi_delayed_clk ,                                                  -- <Clock>  input clock
		    Clock2        => clock_150,                                                 -- <Clock>  output clock
		    Input         => wb_strobe,   -- @Clock1:  input vector
		    Output        => spi_wb_strobe,  -- @Clock2:  output vector
		    Busy          => open,                                                -- @Clock1:  busy bit
		    Changed       => open                                                -- @Clock2:  changed bit
      );
      SyncBusToClock_ctrl_rw : sync_Vector 
      generic map (
        MASTER_BITS => 1, SYNC_DEPTH => 2
      )
      port map(
        Clock1        => spi_delayed_clk ,                                                  -- <Clock>  input clock
		Clock2        => clock_150,                                                 -- <Clock>  output clock
		Input         => spi_ctrl_rw,   -- @Clock1:  input vector
		Output        => ctrl_rw ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
      SyncBusToClock_write_data: sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 2
      )
      port map(
        Clock1        => spi_delayed_clk ,                                                  -- <Clock>  input clock
		Clock2        => clock_150,                                                 -- <Clock>  output clock
		Input         => spi_ctrl_write_data,   -- @Clock1:  input vector
		Output        => ctrl_write_data ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
      SyncBusToClock_read0_data: sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 2
      )
      port map(
        Clock1        => clock_150 ,                                                  -- <Clock>  input clock
		Clock2        => spi_delayed_clk,                                                 -- <Clock>  output clock
		Input         => sts_read_data,   -- @Clock1:  input vector
		Output        => spi_sts_read_data ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
      SyncBusToClock_read1_data: sync_Vector 
      generic map (
        MASTER_BITS => 32, SYNC_DEPTH => 2
      )
      port map(
        Clock1        => clock_150 ,                                                  -- <Clock>  input clock
		Clock2        => spi_delayed_clk,                                                 -- <Clock>  output clock
		Input         => ctrl_read_data,   -- @Clock1:  input vector
		Output        => spi_ctrl_read_data ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
      


      
	process(clock_150, reset_n)
		
    begin
        if (reset_n = '0') then
            led_status <= (others => '1');
            led_out_hw <= '1';
        elsif (rising_edge(clock_150)) then
          if ip_addr = "00000000" then
            led_status <= (others => led_level_sync(2));
            led_out_hw <= '1';
          elsif (ip_addr = "11111111") then
            led_status <= (others => '0');
            led_out_hw <= '0';
          -- device status 
          -- elsif bla bla
			 elsif (ip_led_status_sync = "00000000") then
				led_status <= ip_addr;
				led_out_hw <= '1';
          else 
            led_status <= ip_led_status_sync;
          end if;
        end if;
    end process;
end block SKYTRACKER;
    
SPI_INTERFACE : block
    component spislave is
	 Generic (
				  ADDR_WIDTH : Positive range 8 to 64 := 8;
				  DATA_WIDTH : Positive range 8 to 64 := 8;
				  HOLDOFF : Positive range 1 to 16 := 8;
				  AUTO_INC_ADDRESS : STD_LOGIC := '1'
				  );
    Port ( sys_clk : in  STD_LOGIC;
			  
			  spi_clk : in STD_LOGIC;
			  spi_ce : in STD_LOGIC_VECTOR(1 downto 0);
			  spi_mosi : in STD_LOGIC;
			  spi_miso : out STD_LOGIC;
			  spi_delayed_clk : out STD_LOGIC;
			  
			  wb_strobe : out STD_LOGIC_VECTOR(1 downto 0);
			  wb_cycle : out STD_LOGIC;
			  wb_write : out STD_LOGIC;
			  wb_address : out STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
			  wb_data_i1 : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
			  wb_data_i0 : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
			  wb_data_o : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
			  wb_ack : in STD_LOGIC
			  );
   end component spislave;
   
begin
    u_spislave : component spislave 
	 Generic map (
				  ADDR_WIDTH => ADDR_WIDTH,
				  DATA_WIDTH => DATA_WIDTH,
				  HOLDOFF => 8,
				  AUTO_INC_ADDRESS => AUTO_INC_ADDRESS
		)
      Port map ( 
           sys_clk => clock_150,
			  
			  spi_clk => PI_SCLK,
			  spi_ce  => PI_SS_N,
			  spi_mosi=> PI_MOSI,
			  spi_miso=> PI_MISO,
			  spi_delayed_clk => spi_delayed_clk,
			  
			  wb_cycle => wb_cycle,
			  wb_strobe => wb_strobe,
			  wb_write => wb_write,
			  wb_address => wb_address,
			  wb_data_i1 => wb_data_i1,
			  wb_data_i0 => wb_data_i0,
			  wb_data_o => wb_data_o,
			  wb_ack => wb_ack(0)
			  );
   
end block SPI_INTERFACE;
    
MMCM_block : block
    signal counter_50 : integer  := 0;
    signal counter_100 : integer  := 0;
    signal counter_150 : integer  := 0;

    signal led_level0_b, led_level0_sync : std_logic_vector(0 downto 0);
    signal led_level1_b, led_level1_sync : std_logic_vector(0 downto 0);
    signal led_level2_b, led_level2_sync : std_logic_vector(0 downto 0);
    signal led_level3_b, led_level3_sync : std_logic_vector(0 downto 0);
    signal led_level4_b, led_level4_sync : std_logic_vector(0 downto 0);
begin

   process(clock_50, reset_n)
		
    begin
        if (reset_n = '0') then
            led_level(1) <= '1';
            counter_50 <= 0;
        elsif (rising_edge(clock_50)) then
            if(counter_50 = 29999999) then
                led_level(1) <= not led_level(1);
                counter_50 <= 0;
	    else
	        counter_50 <= counter_50 + 1;
            end if;
        end if;
    end process;	
    
	 
    process(clock_100, reset_n)
		
    begin
        if (reset_n = '0') then
            led_level(2) <= '1';
            counter_100 <= 0;
        elsif (rising_edge(clock_100)) then
            if(counter_100 = 29999999) then
                led_level(2) <= not led_level(2);
                counter_100 <= 0;
	    else
	        counter_100 <= counter_100 + 1;
            end if;
        end if;
    end process;	
	 
    process(clock_150, reset_n)
		
    begin
        if (reset_n = '0') then
            led_level(4) <= '1';
            counter_150 <= 0;
        elsif (rising_edge(clock_150)) then
            if(counter_150 = 29999999) then
                led_level(4) <= not led_level(4);
                counter_150 <= 0;
	    else
	        counter_150 <= counter_150 + 1;
            end if;
        end if;
    end process;	
	 
	  
	  SyncBusToClock_level_1 : sync_Vector 
      generic map (
        MASTER_BITS => 1, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clock_50,                                                  -- <Clock>  input clock
		Clock2        => clock_150,                                                 -- <Clock>  output clock
		Input         => led_level1_b,   -- @Clock1:  input vector
		Output        => led_level1_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
		
	  SyncBusToClock_level_2 : sync_Vector 
      generic map (
        MASTER_BITS => 1, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clock_100,                                                  -- <Clock>  input clock
		Clock2        => clock_150,                                                 -- <Clock>  output clock
		Input         => led_level2_b,   -- @Clock1:  input vector
		Output        => led_level2_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );

	  SyncBusToClock_level_4 : sync_Vector 
      generic map (
        MASTER_BITS => 1, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clock_150,                                                  -- <Clock>  input clock
		Clock2        => clock_150,                                                 -- <Clock>  output clock
		Input         => led_level4_b,   -- @Clock1:  input vector
		Output        => led_level4_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
      led_level3_b(0) <= led_level(3);
      led_level1_b(0) <= led_level(1);
      led_level0_b(0) <= led_level(0);
      led_level2_b(0) <= led_level(2);
      led_level4_b(0) <= led_level(4);
      led_level_sync(0) <= led_level0_sync(0);
      led_level_sync(1) <= led_level1_sync(0);
      led_level_sync(2) <= led_level2_sync(0);
      led_level_sync(3) <= led_level3_sync(0);
      led_level_sync(4) <= led_level4_sync(0);
end block MMCM_block;
	 
end rtl;
