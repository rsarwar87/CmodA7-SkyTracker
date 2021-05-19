library  ieee;

use  ieee.std_logic_1164.all;

ENTITY DE0_TOP is

	port
	(
		CLOCK_50 		: in 		std_logic;
		LED		 		: out		std_logic_vector(7 downto 0) := (others => '0');
		KEY		 		: in		std_logic_vector(1 downto 0);
		SW			 		: in		std_logic_vector(3 downto 0);
	
		--- SDRAM -------------------
		
		DRAM_CAS_N		: out std_logic;
		DRAM_CKE			: out std_logic;
		DRAM_CS_N		: out std_logic;
		DRAM_CLK			: out  std_logic;
		DRAM_RAS_N		: out std_logic;
		DRAM_WE_N		: out  std_logic;
		DRAM_DQM			: out	std_logic_vector(1 downto 0);
		DRAM_BA			: out	std_logic_vector(1 downto 0);
		DRAM_DQ			: inout	std_logic_vector(15 downto 0);
		DRAM_ADDR		: out	std_logic_vector(12 downto 0);

		---  EPCS -------------------
		EPCS_NCSO		: out std_logic;
		EPCS_ASDO		: out std_logic;
		EPCS_DCLK		: out std_logic;
		EPCS_DATA0		: in  std_logic;


		--- Accelerometer and EEPROM -------------------
		G_SENSOR_CS_N	: out std_logic;
		G_SENSOR_INT	: in std_logic;
		I2C_SCLK			: out std_logic;
		I2C_SDAT			: inout std_logic;

		--- ADC -------------------
		ADC_CS_N			: out std_logic;
		ADC_SADDR		: out std_logic;
		ADC_SCLK			: out std_logic;
		ADC_SDAT			: in  std_logic;

		--- 2x13 GPIO Header -------------------
		GPIO_2			: inout	std_logic_vector(12 downto 0);
		GPIO_2_IN		: in		std_logic_vector(2 downto 0);

		--- GPIO_0, GPIO_0 connect to GPIO Default -------------------
		GPIO_0			: inout	std_logic_vector(33 downto 0);
		GPIO_0_IN		: in		std_logic_vector(1 downto 0);

		--- GPIO_1, GPIO_1 connect to GPIO Default -------------------
		GPIO_1			: inout	std_logic_vector(33 downto 0);
		GPIO_1_IN		: in		std_logic_vector(1 downto 0)

	);
end DE0_TOP;

architecture arch of DE0_TOP is
	component debounce IS
	  GENERIC(
		 clk_freq    : INTEGER := 50_000_000;  --system clock frequency in Hz
		 stable_time : INTEGER := 10);         --time button must remain stable in ms
	  PORT(
		 clk     : IN  STD_LOGIC;  --input clock
		 reset_n : IN  STD_LOGIC;  --asynchronous active low reset
		 button  : IN  STD_LOGIC;  --input signal to be debounced
		 result  : OUT STD_LOGIC); --debounced signal
	END component debounce;
	component alt_pll IS
		PORT
		(
			areset		: IN STD_LOGIC  := '0';
			inclk0		: IN STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC ;  -- 100 MHz
			c1		: OUT STD_LOGIC ;	 -- 150 MHz
			c2		: OUT STD_LOGIC ;  -- 40 MHz
			c3		: OUT STD_LOGIC ;  -- 2 MHz
			locked		: OUT STD_LOGIC 
		);
	END component alt_pll;
	component ADC_READ IS
	PORT	(
				clk				:	IN		STD_LOGIC;
				reset_n			:	IN		STD_LOGIC;
				
				Channel			:	IN		STD_LOGIC_VECTOR(2 DOWNTO 0);
				Data				:	OUT	STD_LOGIC_VECTOR(11 DOWNTO 0);
				Start				:	IN		STD_LOGIC;
				Done				:	OUT	STD_LOGIC;
				
				oDIN				:	OUT	STD_LOGIC;
				oCS_n				:	OUT	STD_LOGIC;
				oSCLK				:	OUT	STD_LOGIC;
				iDOUT				:	IN		STD_LOGIC
			);

	END component ADC_READ;
	
	component IOBUFFER IS
	PORT
	(
		datain		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		oe				: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		dataio		: INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		dataout		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
	END component IOBUFFER;
	
	
	component io_buffers is
    port 
    (
        -------- CLOCKS --------------------
        GPIO_0			: inout	std_logic_vector(33 downto 0);
		  GPIO_1			: inout	std_logic_vector(33 downto 0);
		  GPIO_2			: inout	std_logic_vector(12 downto 0);
		  GPIO_1_IN		: in  	std_logic_vector(2 downto 0);

		  CLOCKS 		: in  	std_logic_vector(5 downto 0);
        
        pi_camera_trigger_in  : out std_logic;
        pi_camera_trigger_out : in std_logic;
        pi_pwm_led_in         : out std_logic;
        pi_pwm_led_out        : in std_logic;
			
        led_polar   		: in STD_LOGIC;
        camera_triggers : in STD_LOGIC_VECTOR (1 downto 0);
        
        ra_mode 		: in  STD_LOGIC_VECTOR (2 downto 0);
        ra_enable_n 	: in  STD_LOGIC;
        ra_sleep_n 	: in  STD_LOGIC;
        ra_rst_n 		: in  STD_LOGIC;
        ra_step 		: in  STD_LOGIC;
        ra_direction : in  STD_LOGIC;
        ra_fault_n 	: out STD_LOGIC;
		
		  de_mode 		: in  STD_LOGIC_VECTOR (2 downto 0);
        de_enable_n 	: in  STD_LOGIC;
        de_sleep_n 	: in  STD_LOGIC;
        de_rst_n 		: in  STD_LOGIC;
        de_step 		: in  STD_LOGIC;
        de_direction : in  STD_LOGIC;
        de_fault_n 	: out STD_LOGIC;
        
		  fc_mode 		: in  STD_LOGIC_VECTOR (2 downto 0);
        fc_enable_n 	: in  STD_LOGIC;
        fc_sleep_n 	: in  STD_LOGIC;
        fc_rst_n 		: in  STD_LOGIC;
        fc_step 		: in  STD_LOGIC;
        fc_direction : in  STD_LOGIC;
        fc_fault_n 	: out STD_LOGIC;
        ------- Pi-SPI 			--------------------
        PI_SCLK 			: out	std_logic;
        PI_SS_N			: out	std_logic_vector(1 downto 0);
        PI_MOSI			: out	std_logic;
        PI_MISO			: in 	std_logic
    );
	end component io_buffers;

	component SKY_TOP is
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
	end component SKY_TOP;
	
	signal sw_debounced : std_logic_vector(3 downto 0) := (others => '0');
	signal key_debounced : std_logic_vector(1 downto 0) := (others => '0');
	
	signal clk_100, clk_150, clk_40, clk_2, reset_n, pll_locked : std_logic := '0';
	signal CLOCKS 		: std_logic_vector(5 downto 0);
	
	signal adc_channel : std_logic_vector(2 downto 0) := (others => '0');
	signal adc_data : std_logic_vector(11 downto 0) := (others => '0');
	signal adc_start, adc_done : std_logic := '0';
	
	
    signal pi_camera_trigger_in  : std_logic;
    signal pi_camera_trigger_out : std_logic;
    signal pi_pwm_led_in         : std_logic;
    signal pi_pwm_led_out        : std_logic;
			
    signal led_polar   		: STD_LOGIC;
    signal camera_triggers : STD_LOGIC_VECTOR (1 downto 0);
        
    signal ra_mode 		: STD_LOGIC_VECTOR (2 downto 0);
    signal ra_enable_n 	: STD_LOGIC;
    signal ra_sleep_n 	: STD_LOGIC;
    signal ra_rst_n 		: STD_LOGIC;
    signal ra_step 		: STD_LOGIC;
    signal ra_direction : STD_LOGIC;
    signal ra_fault_n 	: STD_LOGIC;
		
    signal de_mode 		: STD_LOGIC_VECTOR (2 downto 0);
    signal de_enable_n 	: STD_LOGIC;
    signal de_sleep_n 	: STD_LOGIC;
    signal de_rst_n 		: STD_LOGIC;
    signal de_step 		: STD_LOGIC;
    signal de_direction : STD_LOGIC;
    signal de_fault_n 	: STD_LOGIC;
        
    signal fc_mode 		: STD_LOGIC_VECTOR (2 downto 0);
    signal fc_enable_n 	: STD_LOGIC;
    signal fc_sleep_n 	: STD_LOGIC;
    signal fc_rst_n 		: STD_LOGIC;
    signal fc_step 		: STD_LOGIC;
    signal fc_direction : STD_LOGIC;
    signal fc_fault_n 	: STD_LOGIC;
        ------- Pi-SPI 			--------------------
    signal PI_SCLK 			: std_logic;
    signal PI_SS_N			: std_logic_vector(1 downto 0);
    signal PI_MOSI			: std_logic;
    signal PI_MISO			: std_logic;
begin
	pll : alt_pll 
		PORT map
		(
			areset	=> '0',
			inclk0	=> CLOCK_50,
			c0			=> clk_100,  -- 100 MHz
			c1			=> clk_150,	 -- 150 MHz
			c2			=> clk_40,  -- 40 MHz
			c3			=> clk_2,  -- 2 MHz
			locked	=> pll_locked
		);
	CLOCKS(0) <= pll_locked;
	CLOCKS(1) <= clk_2;
	CLOCKS(2) <= clk_40;
	CLOCKS(3) <= clk_150;
	CLOCKS(4) <= clk_100;
	CLOCKS(5) <= CLOCK_50;
	
	
	key_gen : for I in 0 to 1 generate
		debounce_key : debounce
		port map (
			clk => CLOCK_50,
			reset_n => '1',
			button => KEY(I),
			result => key_debounced(I)
		);
	end generate key_gen;
	reset_n <= key_debounced(0);
    
	sw_gen : for I in 0 to 3 generate
		debounce_sw : debounce
		port map (
			clk => CLOCK_50,
			reset_n => '1',
			button => SW(I),
			result => sw_debounced(I)
		);
	end generate  sw_gen;
	
	adc : ADC_READ 
	PORT MAP	(
				clk				=> clk_2,
				reset_n			=> reset_n,
				
				Channel			=> adc_channel,
				Data				=> adc_data,
				Start				=> adc_start,
				Done				=> adc_done,
				
				oDIN				=> ADC_SADDR,
				oCS_n				=> ADC_CS_N,
				oSCLK				=> ADC_SCLK,
				iDOUT				=> ADC_SDAT
			);

	
	adc_channel <= sw_debounced(2 downto 0);
	--LED(4 downto 0) <= adc_data(8 downto 4);
	--LED(7) <= adc_done;
	--LED(6) <= reset_n;
	--LED(5) <= pll_locked;
	adc_start <= key_debounced(1);
	
	 SKY_TOP_uint :SKY_TOP
    port map
    (
        -------- CLOCKS --------------------
        clock_50			=> CLOCK_50,
		  clock_100			=> clk_100,
		  clock_150			=> clk_150,
		  reset_n			=> '1',
        
        pi_camera_trigger_in  => pi_camera_trigger_in,
        pi_camera_trigger_out => pi_camera_trigger_out,
        pi_pwm_led_in         => pi_pwm_led_in,
        pi_pwm_led_out        => pi_pwm_led_out,
			
		  led_out_hw      => open,
        led_status		=> LED,-- open,
		  adc_dbus		   => "000000000000",
		  adc_channel		=> open,
        
        led_polar   		=> led_polar,
        camera_triggers => camera_triggers,
        
        ra_mode 		=> ra_mode,
        ra_enable_n 	=> ra_enable_n ,
        ra_sleep_n 	=> ra_sleep_n ,
        ra_rst_n 		=> ra_rst_n ,
        ra_step 		=> ra_step ,
        ra_direction => ra_direction,
        ra_fault_n 	=> ra_fault_n,
		
		  de_mode 		=> de_mode,
        de_enable_n 	=> de_enable_n,
        de_sleep_n 	=> de_sleep_n,
        de_rst_n 		=> de_rst_n,
        de_step 		=> de_step,
        de_direction => de_direction,
        de_fault_n 	=> de_fault_n,
        
		  fc_mode 		=> fc_mode,
        fc_enable_n 	=> fc_enable_n,
        fc_sleep_n 	=> fc_sleep_n,
        fc_rst_n 		=> fc_rst_n,
        fc_step 		=> fc_step,
        fc_direction => fc_direction,
        fc_fault_n 	=> fc_fault_n,
        ------- Pi-SPI 			--------------------
        PI_SCLK 	=> PI_SCLK,
        PI_SS_N	=> PI_SS_N,
        PI_MOSI	=> PI_MOSI,
        PI_MISO	=> PI_MISO
    );
	 
	 io_buffers_u : io_buffers
    port map
    (
        -------- CLOCKS --------------------
        GPIO_0			=> GPIO_0,
		  GPIO_1			=> GPIO_1,
		  GPIO_1_IN		=> GPIO_2_IN,
		  GPIO_2       => GPIO_2,
		  
		  CLOCKS       => CLOCKS,

        pi_camera_trigger_in  => pi_camera_trigger_in,
        pi_camera_trigger_out => pi_camera_trigger_out,
        pi_pwm_led_in         => pi_pwm_led_in,
        pi_pwm_led_out        => pi_pwm_led_out,
        
        led_polar   		=> led_polar,
        camera_triggers => camera_triggers,
        
        ra_mode 		=> ra_mode,
        ra_enable_n 	=> ra_enable_n ,
        ra_sleep_n 	=> ra_sleep_n ,
        ra_rst_n 		=> ra_rst_n ,
        ra_step 		=> ra_step ,
        ra_direction => ra_direction,
        ra_fault_n 	=> ra_fault_n,
		
		  de_mode 		=> de_mode,
        de_enable_n 	=> de_enable_n,
        de_sleep_n 	=> de_sleep_n,
        de_rst_n 		=> de_rst_n,
        de_step 		=> de_step,
        de_direction => de_direction,
        de_fault_n 	=> de_fault_n,
        
		  fc_mode 		=> fc_mode,
        fc_enable_n 	=> fc_enable_n,
        fc_sleep_n 	=> fc_sleep_n,
        fc_rst_n 		=> fc_rst_n,
        fc_step 		=> fc_step,
        fc_direction => fc_direction,
        fc_fault_n 	=> fc_fault_n,
        ------- Pi-SPI 			--------------------
        PI_SCLK 	=> PI_SCLK,
        PI_SS_N	=> PI_SS_N,
        PI_MOSI	=> PI_MOSI,
        PI_MISO	=> PI_MISO
    );
end arch;
