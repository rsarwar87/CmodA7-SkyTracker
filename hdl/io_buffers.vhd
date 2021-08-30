
library ieee;
use ieee.std_logic_1164.all;

entity io_buffers is
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
end io_buffers;

architecture rtl of io_buffers is
	constant IS_IN  : std_logic := '0';
	constant IS_OUT : std_logic := '1';
	
	COMPONENT IOBUFFER IS
	PORT
	(
		datain		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		oe				: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		dataio		: INOUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		dataout		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
	END COMPONENT IOBUFFER;
begin
	
	clock0 : IOBUFFER
	port map (
		datain(0) 	=> CLOCKS(0), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_2(0),
		dataout(0)  => open
	);
	clock1 : IOBUFFER
	port map (
		datain(0) 	=> CLOCKS(1), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_2(1),
		dataout(0)  => open
	);
	clock2 : IOBUFFER
	port map (
		datain(0) 	=> CLOCKS(2), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_2(2),
		dataout(0)  => open
	);
	clock3 : IOBUFFER
	port map (
		datain(0) 	=> CLOCKS(3), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_2(3),
		dataout(0)  => open
	);
	clock4 : IOBUFFER
	port map (
		datain(0) 	=> CLOCKS(4), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_2(4),
		dataout(0)  => open
	);
	clock5 : IOBUFFER
	port map (
		datain(0) 	=> CLOCKS(5), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_2(5),
		dataout(0)  => open
	);
	--=========================================  spi
	spi_clk : IOBUFFER
	port map (
		datain(0) 	=> '0', 
		oe(0) 		=> IS_IN,
		dataio(0)	=> GPIO_1(3),
		dataout(0)  => PI_SCLK
	);
	spi_ss_1 : IOBUFFER
	port map (
		datain(0) 	=> '0', 
		oe(0) 		=> IS_IN,
		dataio(0)	=> GPIO_1(1),
		dataout(0)  => PI_SS_N(1)
	);
	spi_ss_0 : IOBUFFER
	port map (
		datain(0) 	=> '0', 
		oe(0) 		=> IS_IN,
		dataio(0)	=> GPIO_1(0),
		dataout(0)  => PI_SS_N(0)
	);
	spi_mosi : IOBUFFER
	port map (
		datain(0) 	=> '0', 
		oe(0) 		=> IS_IN,
		dataio(0)	=> GPIO_1(7),
		dataout(0)  => PI_MOSI
	);
	spi_miso : IOBUFFER
	port map (
		datain(0) 	=> PI_MISO, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_1(5),
		dataout(0)  => open
	);
	-- ============================================= pi camera trigger
	pi_trig_in : IOBUFFER
	port map (
		datain(0) 	=> '0', 
		oe(0) 		=> IS_IN,
		dataio(0)	=> GPIO_1(26),
		dataout(0)  => pi_camera_trigger_in
	);
	pi_trig_out : IOBUFFER
	port map (
		datain(0) 	=> pi_camera_trigger_out, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_1(27),
		dataout(0)  => open
	);
	-- =============================================== pi pwm
	pi_led_in : IOBUFFER
	port map (
		datain(0) 	=> '0', 
		oe(0) 		=> IS_IN,
		dataio(0)	=> GPIO_1(24),
		dataout(0)  => pi_pwm_led_in
	);
	pi_led_out : IOBUFFER
	port map (
		datain(0) 	=> pi_pwm_led_out, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_1(33),
		
		
		
		dataout(0)  => open
	);
	-- ==================================== fpga polar led/camera trigger
	fpga_polar : IOBUFFER
	port map (
		datain(0) 	=> led_polar, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_1(32),
		dataout(0)  => open
	);
	fpga_ctrig0 : IOBUFFER
	port map (
		datain(0) 	=> camera_triggers(0), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_1(25),
		dataout(0)  => open
	);
--	fpga_ctrig1 : IOBUFFER
--	port map (
--		datain(0) 	=> camera_triggers(1), 
--		oe(0) 		=> IS_OUT,
--		dataio(0)	=> GPIO_1(24),
--		dataout(0)  => open
--	);
	
	--==========================================================================
	ra_enable_n_t : IOBUFFER
	port map (
		datain(0) 	=> ra_enable_n, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(0),
		dataout(0)  => open
	);
	ra_mode2 : IOBUFFER
	port map (
		datain(0) 	=> ra_mode(0), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(1),
		dataout(0)  => open
	);
	ra_mode1 : IOBUFFER
	port map (
		datain(0) 	=> ra_mode(1), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(3),
		dataout(0)  => open
	);
	ra_mode0 : IOBUFFER
	port map (
		datain(0) 	=> ra_mode(2), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(5),
		dataout(0)  => open
	);
	ra_sleep_n_t : IOBUFFER
	port map (
		datain(0) 	=> ra_sleep_n, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(7),
		dataout(0)  => open
	);
	ra_rst_n_t : IOBUFFER
	port map (
		datain(0) 	=> ra_rst_n, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(9),
		dataout(0)  => open
	);
	ra_dir : IOBUFFER
	port map (
		datain(0) 	=> ra_direction, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(13),
		dataout(0)  => open
	);
	ra_step_t : IOBUFFER
	port map (
		datain(0) 	=> ra_step, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(11),
		dataout(0)  => open
	);
	ra_fault_t : IOBUFFER
	port map (
		datain(0) 	=> '0', 
		oe(0) 		=> IS_IN,
		dataio(0)	=> GPIO_0(15),
		dataout(0)  => ra_fault_n
	);
	
	
	de_en_n : IOBUFFER
	port map (
		datain(0) 	=> de_enable_n, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(19),
		dataout(0)  => open
	);
	de_mode2 : IOBUFFER
	port map (
		datain(0) 	=> de_mode(0), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(21),
		dataout(0)  => open
	);
	de_mode1 : IOBUFFER
	port map (
		datain(0) 	=> de_mode(1), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(23),
		dataout(0)  => open
	);
	de_mode0 : IOBUFFER
	port map (
		datain(0) 	=> de_mode(2), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(25),
		dataout(0)  => open
	);
	de_slp_n : IOBUFFER
	port map (
		datain(0) 	=> de_sleep_n, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(27),
		dataout(0)  => open
	);
	de_rstn : IOBUFFER
	port map (
		datain(0) 	=> de_rst_n, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(29),
		dataout(0)  => open
	);
	de_dir : IOBUFFER
	port map (
		datain(0) 	=> de_direction, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(33),
		dataout(0)  => open
	);
	de_step_t : IOBUFFER
	port map (
		datain(0) 	=> de_step, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(31),
		dataout(0)  => open
	);
	de_fault_t : IOBUFFER
	port map (
		datain(0) 	=> '0', 
		oe(0) 		=> IS_IN,
		dataio(0)	=> GPIO_0(17),
		dataout(0)  => de_fault_n
	);
	
	
	
	
	fc_en_n : IOBUFFER
	port map (
		datain(0) 	=> fc_enable_n, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(22),
		dataout(0)  => open
	);
	fc_mode2 : IOBUFFER
	port map (
		datain(0) 	=> fc_mode(0), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(20),
		dataout(0)  => open
	);
	fc_mode1 : IOBUFFER
	port map (
		datain(0) 	=> fc_mode(1), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(18),
		dataout(0)  => open
	);
	fc_mode0 : IOBUFFER
	port map (
		datain(0) 	=> fc_mode(2), 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(16),
		dataout(0)  => open
	);
	fc_slp_n : IOBUFFER
	port map (
		datain(0) 	=> fc_sleep_n, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(14),
		dataout(0)  => open
	);
	fc_rstn : IOBUFFER
	port map (
		datain(0) 	=> fc_rst_n, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(12),
		dataout(0)  => open
	);
	fc_dir : IOBUFFER
	port map (
		datain(0) 	=> fc_direction, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(08),
		dataout(0)  => open
	);
	fc_step_t : IOBUFFER
	port map (
		datain(0) 	=> fc_step, 
		oe(0) 		=> IS_OUT,
		dataio(0)	=> GPIO_0(10),
		dataout(0)  => open
	);
	fc_fault_t : IOBUFFER
	port map (
		datain(0) 	=> '0', 
		oe(0) 		=> IS_IN,
		dataio(0)	=> GPIO_0(2),
		dataout(0)  => fc_fault_n
	);
	
end rtl;