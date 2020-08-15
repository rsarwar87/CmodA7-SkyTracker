 -- Quartus Prime VHDL Template
-- Single port RAM with single read/write address 

library ieee;
use ieee.std_logic_1164.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity SKY_TOP is
    port 
    (
        -------- CLOCKS --------------------
        FPGA_CLK0_12		: in 	std_logic;
        VP_IN, VN_IN		: in 	std_logic;
        VA_P, VA_N  		: in 	std_logic_vector(1 downto 0);
        
        pi_camera_trigger_in  : in std_logic;
        pi_camera_trigger_out : out std_logic;
        pi_pwm_led_in         : in std_logic;
        pi_pwm_led_out        : out std_logic;
       
        ------- INPUT/OUTPUT --------------------
        KEY			: in	std_logic_vector(1 downto 0);
        S_LED		: out	std_logic_vector(7 downto 0);
        LED_RBG 	: out	std_logic_vector(2 downto 0);
        LED     	: out	std_logic_vector(1 downto 0);
        
        led_polar   : out STD_LOGIC;
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
        
        ------- Pi-SPI 			--------------------
        PI_SCLK 		: in	std_logic;
        PI_SS_N			: in	std_logic_vector(1 downto 0);
        PI_MOSI			: in	std_logic;
        PI_MISO			: out	std_logic
    );
end SKY_TOP;

architecture rtl of SKY_TOP is
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
    
    signal spi_delayed_clk, clock_12, clock_50, rstn_50, rstn_12 : std_logic := '0';  
    signal clock_100, rstn_100 : std_logic := '0';
    signal clock_125, rstn_125 : std_logic := '0';
    signal clock_150, rstn_150 : std_logic := '0';
    
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
    
    signal daddr_in : STD_LOGIC_VECTOR(7 downto 0) := X"14";
    signal alm_int: STD_LOGIC_VECTOR(7 downto 0);
    signal enable:  STD_LOGIC;
    signal di_in : STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
    signal dwe_in:  STD_LOGIC := '0';
     
    signal  busy_out:  STD_LOGIC;
    signal  channel_out : STD_LOGIC_VECTOR(4 downto 0);
    signal  do_out : STD_LOGIC_VECTOR(15 downto 0);
    signal  aux_channel_n, aux_channel_p : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal  drdy_out:  STD_LOGIC;
    signal  eos_out:  STD_LOGIC;
    signal  alarm_out:  STD_LOGIC;
begin
    rstn_50 <= rstn_12;
    rstn_100 <= rstn_12;
    rstn_125 <= rstn_12;
    rstn_150 <= rstn_12;

    aux_channel_n (4) <= VA_N(0);
    aux_channel_P (4) <= VA_P(0);
    aux_channel_n (12) <= VA_N(1);
    aux_channel_P (12) <= VA_P(1);
    XADC_inst : XADC
   generic map (
      -- INIT_40 - INIT_42: XADC configuration registers
      INIT_40 => X"0000",
      INIT_41 => X"21AF",
      INIT_42 => X"0200",
      -- INIT_48 - INIT_4F: Sequence Registers
      INIT_48 => X"0800",
      INIT_49 => X"1010",
      INIT_4A => X"0000",
      INIT_4B => X"0000",
      INIT_4C => X"0000",
      INIT_4D => X"0000",
      INIT_4F => X"0000",
      INIT_4E => X"0000",                 -- Sequence register 6
      -- INIT_50 - INIT_58, INIT5C: Alarm Limit Registers
      INIT_50 => X"B5ED",
      INIT_51 => X"57E4",
      INIT_52 => X"A147",
      INIT_53 => X"CA33",
      INIT_54 => X"A93A",
      INIT_55 => X"52C6",
      INIT_56 => X"9555",
      INIT_57 => X"AE4E",
      INIT_58 => X"9999",
      INIT_5C => X"1111",
      -- Simulation attributes: Set for proper simulation behavior
      SIM_DEVICE => "7SERIES",            -- Select target device (values)
      SIM_MONITOR_FILE => "design.txt"  -- Analog simulation data file name
   )
   port map (
      -- ALARMS: 8-bit (each) output: ALM, OT
      ALM => alm_int,                   -- 8-bit output: Output alarm for temp, Vccint, Vccaux and Vccbram
      OT => open,                     -- 1-bit output: Over-Temperature alarm
      -- Dynamic Reconfiguration Port (DRP): 16-bit (each) output: Dynamic Reconfiguration Ports
      DO => do_out,                     -- 16-bit output: DRP output data bus
      DRDY => drdy_out,                 -- 1-bit output: DRP data ready
      -- STATUS: 1-bit (each) output: XADC status ports
      BUSY => busy_out,                 -- 1-bit output: ADC busy output
      CHANNEL => channel_out,           -- 5-bit output: Channel selection outputs
      EOC => enable,                   -- 1-bit output: End of Conversion
      EOS => eos_out,                   -- 1-bit output: End of Sequence
      JTAGBUSY => open,         -- 1-bit output: JTAG DRP transaction in progress output
      JTAGLOCKED => open,     -- 1-bit output: JTAG requested DRP port lock
      JTAGMODIFIED => open, -- 1-bit output: JTAG Write to the DRP has occurred
      MUXADDR => open,           -- 5-bit output: External MUX channel decode
      -- Auxiliary Analog-Input Pairs: 16-bit (each) input: VAUXP[15:0], VAUXN[15:0]
      VAUXN => aux_channel_n,               -- 16-bit input: N-side auxiliary analog input
      VAUXP => aux_channel_p,               -- 16-bit input: P-side auxiliary analog input
      -- CONTROL and CLOCK: 1-bit (each) input: Reset, conversion start and clock inputs
      CONVST => '0',             -- 1-bit input: Convert start input
      CONVSTCLK => '0',       -- 1-bit input: Convert start input
      RESET => '0',               -- 1-bit input: Active-high reset
      -- Dedicated Analog Input Pair: 1-bit (each) input: VP/VN
      VN => VN_IN,                     -- 1-bit input: N-side analog input
      VP => VP_IN,                     -- 1-bit input: P-side analog input
      -- Dynamic Reconfiguration Port (DRP): 7-bit (each) input: Dynamic Reconfiguration Ports
      DADDR => daddr_in(6 downto 0),               -- 7-bit input: DRP address bus
      DCLK => clock_100,                 -- 1-bit input: DRP clock
      DEN => enable,                   -- 1-bit input: DRP enable signal
      DI => di_in,                     -- 16-bit input: DRP input data bus
      DWE => dwe_in                    -- 1-bit input: DRP write enable
   );
   

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
		   led_pwm : out STD_LOGIC;
			  
		   camera_trigger : out STD_LOGIC_VECTOR (1 downto 0);
		   ip_addr : out STD_LOGIC_VECTOR (7 downto 0);
		   led_status : out STD_LOGIC_VECTOR (7 downto 0);
			  
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
    signal ip_addr, led_status, led_status_sync: STD_LOGIC_VECTOR (7 downto 0);
    signal led_out : std_logic;
    signal led_level0_b, led_level0_sync : std_logic_vector(0 downto 0);
    signal led_level1_b, led_level1_sync : std_logic_vector(0 downto 0);
    signal led_level2_b, led_level2_sync : std_logic_vector(0 downto 0);
    signal led_level3_b, led_level3_sync : std_logic_vector(0 downto 0);
    signal led_level4_b, led_level4_sync : std_logic_vector(0 downto 0);
    signal led_level_sync : std_logic_vector(4 downto 0);
    
begin
    
    pi_camera_trigger_out <= pi_camera_trigger_in;
    pi_pwm_led_out        <= pi_pwm_led_in;

	 U_SKYTRACKER :  component sky_tracker	
		port map (
		   clk_50  => clock_50,
           rstn_50 => rstn_50,
		   clk_150  => clock_150,
           rstn_150 => rstn_150,
			  
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
		   
		   led_pwm => led_out,
		   camera_trigger => camera_triggers,
		   ip_addr => ip_addr,
		   led_status => led_status,
		   
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
		Input         => led_status,   -- @Clock1:  input vector
		Output        => led_status_sync ,  -- @Clock2:  output vector
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
      


	  SyncBusToClock_level_0 : sync_Vector 
      generic map (
        MASTER_BITS => 1, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clock_12,                                                  -- <Clock>  input clock
		Clock2        => clock_150,                                                 -- <Clock>  output clock
		Input         => led_level0_b,   -- @Clock1:  input vector
		Output        => led_level0_sync ,  -- @Clock2:  output vector
		Busy          => open,                                                -- @Clock1:  busy bit
		Changed       => open                                                -- @Clock2:  changed bit
      );
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
	  SyncBusToClock_level_3 : sync_Vector 
      generic map (
        MASTER_BITS => 1, SYNC_DEPTH => 3
      )
      port map(
        Clock1        => clock_125,                                                  -- <Clock>  input clock
		Clock2        => clock_150,                                                 -- <Clock>  output clock
		Input         => led_level3_b,   -- @Clock1:  input vector
		Output        => led_level3_sync ,  -- @Clock2:  output vector
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
      
	process(clock_150, rstn_150)
		
    begin
        if (rstn_150 = '0') then
            S_LED <= (others => '1');
        elsif (rising_edge(clock_150)) then
          if ip_addr = "00000000" then
            S_LED(7 downto 5) <= "111";
            S_LED(4 downto 0) <= led_level_sync;
          elsif (ip_addr = "11111111") then
            S_LED <= (others => led_level_sync(2));
          -- device status 
          -- elsif bla bla
			 elsif (led_status_sync = "00000000") then
				S_LED <= ip_addr;
          else 
            S_LED <= led_status_sync;
          end if;
        end if;
    end process;
end block SKYTRACKER;
    
SPI_INTERFACE : block
    component spislave is
	 Generic (
				  ADDR_WIDTH : Positive range 8 to 64 := 8;
				  DATA_WIDTH : Positive range 8 to 64 := 8;
				  HOLDOFF : Positive range 0 to 16 := 8;
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
    signal mmcm_lock, mmcm_psdone,mmcm_rst, t_rst : std_logic := '0';
    signal fd_clock, fd_clock_buf : std_logic := '0';
    signal clock_50_buf : std_logic := '0';
    signal clock_100_buf : std_logic := '0';
    signal clock_125_buf : std_logic := '0';
    signal clock_150_buf : std_logic := '0';
    
    
    signal counter_50 : integer  := 0;
    signal counter_100 : integer  := 0;
    signal counter_125 : integer  := 0;
    signal counter_150 : integer  := 0;
    signal counter_12 : integer  := 0;
    
    component clk_wiz_0 is
    port (
      -- Clock out ports
      clk_out1 : out STD_LOGIC;
      clk_out2 : out STD_LOGIC;
      clk_out3 : out STD_LOGIC;
      clk_out4 : out STD_LOGIC;
      -- Status and control signals
      resetn  : in STD_LOGIC;
      locked  : out STD_LOGIC;
     -- Clock in ports
      clk_in1 : in STD_LOGIC
     );
     end component clk_wiz_0;
begin


   MMCME2_ADV_inst : MMCME2_ADV
   generic map (
      BANDWIDTH => "OPTIMIZED",      -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F => 50.0,        -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE => 0.0,         -- Phase offset in degrees of CLKFB (-360.000-360.000).
      -- CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      CLKIN1_PERIOD => 0.0,
      CLKIN2_PERIOD => 0.0,
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
      CLKOUT1_DIVIDE => 6,
      CLKOUT2_DIVIDE => 5,
      CLKOUT3_DIVIDE => 4,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      CLKOUT6_DIVIDE => 1,
      CLKOUT0_DIVIDE_F => 12.0,       -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLKOUT6_PHASE => 0.0,
      CLKOUT4_CASCADE => FALSE,      -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      COMPENSATION => "ZHOLD",       -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
      DIVCLK_DIVIDE => 1,            -- Master division value (1-106)
      -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
      REF_JITTER1 => 0.0,
      REF_JITTER2 => 0.0,
      STARTUP_WAIT => FALSE,         -- Delays DONE until MMCM is locked (FALSE, TRUE)
      -- Spread Spectrum: Spread Spectrum Attributes
      SS_EN => "FALSE",              -- Enables spread spectrum (FALSE, TRUE)
      SS_MODE => "CENTER_HIGH",      -- CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
      SS_MOD_PERIOD => 10000,        -- Spread spectrum modulation period (ns) (VALUES)
      -- USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
      CLKFBOUT_USE_FINE_PS => FALSE,
      CLKOUT0_USE_FINE_PS => FALSE,
      CLKOUT1_USE_FINE_PS => FALSE,
      CLKOUT2_USE_FINE_PS => FALSE,
      CLKOUT3_USE_FINE_PS => FALSE,
      CLKOUT4_USE_FINE_PS => FALSE,
      CLKOUT5_USE_FINE_PS => FALSE,
      CLKOUT6_USE_FINE_PS => FALSE
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => clock_50_buf,           -- 1-bit output: CLKOUT0
      CLKOUT0B => open,         -- 1-bit output: Inverted CLKOUT0
      CLKOUT1 => clock_100_buf,           -- 1-bit output: CLKOUT1
      CLKOUT1B => open,         -- 1-bit output: Inverted CLKOUT1
      CLKOUT2 => clock_125_buf,           -- 1-bit output: CLKOUT2
      CLKOUT2B => open,         -- 1-bit output: Inverted CLKOUT2
      CLKOUT3 => clock_150_buf,           -- 1-bit output: CLKOUT3
      CLKOUT3B => open,         -- 1-bit output: Inverted CLKOUT3
      CLKOUT4 => open,           -- 1-bit output: CLKOUT4
      CLKOUT5 => open,           -- 1-bit output: CLKOUT5
      CLKOUT6 => open,           -- 1-bit output: CLKOUT6
      -- DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
      DO => open,                     -- 16-bit output: DRP data
      DRDY => open,                 -- 1-bit output: DRP ready
      -- Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
      PSDONE => mmcm_psdone,             -- 1-bit output: Phase shift done
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => fd_clock_buf,         -- 1-bit output: Feedback clock
      CLKFBOUTB => open,       -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      CLKFBSTOPPED => open, -- 1-bit output: Feedback clock stopped
      CLKINSTOPPED => open, -- 1-bit output: Input clock stopped
      LOCKED => mmcm_lock,             -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock inputs
      CLKIN1 => clock_12,             -- 1-bit input: Primary clock
      CLKIN2 => '0',             -- 1-bit input: Secondary clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      CLKINSEL => '1',         -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
      PWRDWN => '0',             -- 1-bit input: Power-down
      RST => mmcm_rst,                   -- 1-bit input: Reset
      -- DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
      DADDR => "0000000",               -- 7-bit input: DRP address
      DCLK => '0',                 -- 1-bit input: DRP clock
      DEN => '0',                   -- 1-bit input: DRP enable
      DI => X"0000",                     -- 16-bit input: DRP data
      DWE => '0',                   -- 1-bit input: DRP write enable
      -- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
      PSCLK => '0',               -- 1-bit input: Phase shift clock
      PSEN => '0',                 -- 1-bit input: Phase shift enable
      PSINCDEC => '0',         -- 1-bit input: Phase shift increment/decrement
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => fd_clock            -- 1-bit input: Feedback clock
   );


    mmcm_bufg_feedback : BUFG port map (I => fd_clock_buf ,  O => fd_clock);
    mmcm_bufg_50 : BUFG port map (I => clock_50_buf ,  O => clock_50);
    mmcm_bufg_100 : BUFG port map (I => clock_100_buf ,  O => clock_100);
    mmcm_bufg_125 : BUFG port map (I => clock_125_buf ,  O => clock_125);
    mmcm_bufg_150 : BUFG port map (I => clock_150_buf ,  O => clock_150); 
   -- End of MMCME2_BASE_inst instantiation
   
   
   mmcm_rst <= '0';
   t_rst <= not KEY(0);
   trst : BUFG port map (I => t_rst ,  O => rstn_12); 
   clock12 : BUFG port map (I => FPGA_CLK0_12 ,  O => clock_12); 
--   u_clk_wiz_0 : component clk_wiz_0 
--    port map (
--      -- Clock out ports
--      clk_out1 => clock_50,
--      clk_out2 => clock_100,
--      clk_out3 => clock_125,
--      clk_out4 => clock_150,
--      -- Status and control signals
--      resetn  => rstn_12,
--      locked  => mmcm_lock,
--     -- Clock in ports
--      clk_in1 => clock_12
--     );
   process(clock_50, rstn_50)
		
    begin
        if (rstn_50 = '0') then
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
    process(clock_12, rstn_12)
		
    begin
        if (rstn_12 = '0') then
            led_level(0) <= '1';
            counter_12 <= 0;
        elsif (rising_edge(clock_12)) then
            if(counter_12 = 29999999) then
                led_level(0) <= not led_level(0);
                counter_12 <= 0;
	    else
	        counter_12 <= counter_12 + 1;
            end if;
        end if;
    end process;	
    process(clock_100, rstn_100)
		
    begin
        if (rstn_100 = '0') then
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
    process(clock_125, rstn_125)
		
    begin
        if (rstn_125 = '0') then
            led_level(3) <= '1';
            counter_125 <= 0;
        elsif (rising_edge(clock_125)) then
            if(counter_125 = 29999999) then
                led_level(3) <= not led_level(3);
                counter_125 <= 0;
	    else
	        counter_125 <= counter_125 + 1;
            end if;
        end if;
    end process;	
    process(clock_150, rstn_150)
		
    begin
        if (rstn_150 = '0') then
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
    LED(0) <= led_level(1);
    LED(1) <= led_level(4);
    LED_RBG(0) <= led_level(3);
    LED_RBG(1) <= led_level(2);
    LED_RBG(2) <= led_level(0);
end block MMCM_block;
	 
end rtl;
