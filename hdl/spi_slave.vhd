----------------------------------------------------------------------------------
--
-- SPI slave device
--
-- Parameters:
--   ADDR_WIDTH  -- Wishbone address width in bits (8, 16, 24, 32...64)
--   DATA_WIDTH  -- Wishbone data width in bits (8, 16, 24, 32...64)
--
-- Signals: Clock, Reset, standard wishbone, SPI: CLK, CE, MOSI, MISO
--
-- SPI Protocol:  (For data bytes sent over SPI)
--
-- This device works with clock polarity and phase = 0, so data is stable
-- on rising edge of clock.
--
-- Writes: First (ADDR_WIDTH/8) bytes must be WB address.  The top bit
--         of the address must be set to '1' to indicate a write cycle.
--         After sending the WB address, send (DATA_WIDTH/8) bytes of WB data.
--         Sending partial WB data results in the write being cancelled.
--
-- Reads: First perform a write of (ADDR_WIDTH/8) bytes to set the WB address.
--        The top bit of the addressw must be set to '0' to indicate a read
--        cycle.  Send (DATA_WIDTH/8) more bytes of any value while reading
--        from the MISO pin.  Performing a partial read will read the first N
--        bits of the WB data.
--
-- WB addresses and data are in big endian order, MSB first.
--
-- Because the SPI protocol has no way to tell the master device to wait for
-- data to become available, WB reads must be complete within one SPI clock
-- cycle.  With a Raspberry PI running SPI at 32MHz and sys_clk at 100MHz, that
-- is less than 3 sys_clk cycles.
-- alternatively, the HOLDOFF can be put in to add a 8-bit word during which transmitted
-- data are discarded but allows enough cycles to pass for proper clock domain 
-- syncronisation 
--
----------------------------------------------------------------------------------
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity spislave is
	 Generic (
				  ADDR_WIDTH : Positive range 8 to 64 := 8;
				  DATA_WIDTH : Positive range 8 to 64 := 8;
				  HOLDOFF : integer range 0 to 16 := 8;
				  AUTO_INC_ADDRESS : STD_LOGIC := '1'
				  );
    Port ( sys_clk : in  STD_LOGIC;
			  
			  spi_clk : in STD_LOGIC;
			  spi_ce : in STD_LOGIC_VECTOR(1 downto 0);
			  spi_mosi : in STD_LOGIC;
			  spi_miso : out STD_LOGIC;
			  spi_delayed_clk : out STD_LOGIC;
			  
			  wb_cycle : out STD_LOGIC;
			  wb_strobe : out STD_LOGIC_VECTOR(1 downto 0);
			  wb_write : out STD_LOGIC;
			  wb_address : out STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
			  wb_data_i1 : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
			  wb_data_i0 : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
			  wb_data_o : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
			  wb_ack : in STD_LOGIC
			  );
end spislave;

architecture Behavioral of spislave is
    ATTRIBUTE MARK_DEBUG : string;
	signal spi_addr_shift_reg : std_logic_vector(ADDR_WIDTH-1 downto 0);
	signal spi_shift_in_reg : std_logic_vector(DATA_WIDTH + HOLDOFF - 1 downto 0);
	signal wb_data_i : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal spi_shift_out_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
	
	signal spi_shift_count : integer range 0 to 255;
	
	signal last_spi_ce, spi_rst, i_did_a_reset : std_logic := '1';
	
	signal wb_cycle_reg : std_logic := '0';
	signal wb_strobe_reg : std_logic := '0';
	signal wb_write_reg : std_logic := '0';
	signal wb_data_o_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
	
	signal spi_clk_buf, spi_clk_delayed, spi_out_en : std_logic;
	
	ATTRIBUTE MARK_DEBUG of spi_clk, spi_ce, spi_miso, spi_mosi, spi_out_en: SIGNAL IS "TRUE";
	ATTRIBUTE MARK_DEBUG of wb_cycle, wb_strobe, wb_write, wb_address: SIGNAL IS "TRUE";
	ATTRIBUTE MARK_DEBUG of wb_data_i1, wb_data_i0, wb_data_o, wb_ack: SIGNAL IS "TRUE";
	ATTRIBUTE MARK_DEBUG of spi_shift_out_reg, spi_shift_count, spi_shift_in_reg, spi_addr_shift_reg: SIGNAL IS "TRUE";
	

begin
	
	wb_cycle <= wb_cycle_reg;
	wb_strobe(0) <= wb_strobe_reg and (not spi_ce(0));
	wb_strobe(1) <= wb_strobe_reg and (not spi_ce(1));
	wb_data_i <= wb_data_i0 when spi_ce(0) = '0' else 
	             wb_data_i1 when spi_ce(1) = '0' else (others => '0');
	wb_write <= wb_write_reg;
	--wb_data_o <= wb_data_o_reg;
	g_GENERATE_FOR: for byte_index in 0 to (DATA_WIDTH/8-1) generate
        wb_data_o(byte_index*8+7 downto byte_index*8) <= wb_data_o_reg((DATA_WIDTH/8-1-byte_index)*8+7 downto (DATA_WIDTH/8-1-byte_index)*8);
	end generate;
	wb_address <= "0" & spi_addr_shift_reg(ADDR_WIDTH-2 downto 0);
	
	
	-- Delay spi_clk by one sys_clk cycle.  This seems to be necessary to transfer
	-- 1K blocks at 32MHz without any bit errors.
	process(sys_clk)
	begin
	
		if rising_edge(sys_clk) then
		    last_spi_ce <= spi_ce(0) and spi_ce(1);
		    spi_rst <= last_spi_ce  and (spi_ce(0) and spi_ce(1));
			spi_clk_buf <= spi_clk;
		end if;
	end process;
	bufg_spi_clk : BUFG port map (I => spi_clk_buf ,  O => spi_clk_delayed);
	spi_delayed_clk <= spi_clk_delayed;
	
	-- Clocking in address and data
	process(spi_clk_delayed, spi_rst)
	begin
	
		if spi_rst = '1' then
			
			spi_shift_count <= 0;
			wb_cycle_reg <= '0';
			wb_strobe_reg <= '0';
			wb_write_reg <= '0';
			i_did_a_reset <= '1';
			
		elsif rising_edge(spi_clk_delayed ) then
			i_did_a_reset <= '0';
			-- Counting the number of bits shifted in so far
			if spi_shift_count < ADDR_WIDTH + DATA_WIDTH + HOLDOFF then
				spi_shift_count <= spi_shift_count + 1;
			end if;
			
			-- Shifting address and data input
			-- The last shift here is not really needed since we save to wb_address
			-- below during the last shift in.
			if spi_shift_count > (ADDR_WIDTH-1) then
				
				spi_shift_in_reg <= spi_shift_in_reg(DATA_WIDTH + HOLDOFF - 2 downto 0) & spi_mosi;
				
			else
				
				spi_addr_shift_reg <= spi_addr_shift_reg(ADDR_WIDTH-2 downto 0) & spi_mosi;
				
			end if;
			
			-- Read cycle is done as soon as address is complete
			if spi_shift_count = (ADDR_WIDTH-1) and spi_addr_shift_reg(ADDR_WIDTH-2) = '0' then
				
				wb_cycle_reg <= '1';
				wb_strobe_reg <= '1';
				wb_write_reg <= '0';
				
				wb_data_o_reg <= (others => '0');
			-- Write cycle is done after data has arrived
			elsif spi_shift_count = (ADDR_WIDTH+DATA_WIDTH-1) and spi_addr_shift_reg(ADDR_WIDTH-1) = '1' then
				
				wb_cycle_reg <= '1';
				wb_strobe_reg <= '1';
				wb_write_reg <= '1';
				wb_data_o_reg <= spi_shift_in_reg(DATA_WIDTH-2 downto 0) & spi_mosi;
				
				
			end if;

			-- End of read or write cycle
			if wb_strobe_reg = '1' and wb_ack = '1' then
				
				wb_cycle_reg <= '0';
				wb_strobe_reg <= '0';
				-- If we allow multiple writes without de-asserting CE, then
				-- increment address and go back to data phase
--				if AUTO_INC_ADDRESS = '1' and wb_write_reg = '1' then
					
--					spi_addr_shift_reg <= spi_addr_shift_reg + 1;
					
--					spi_shift_count <= ADDR_WIDTH+1;
					
--				end if;
				
			end if;
			
		end if;
		
	end process;
	
	-- Make first bit available from wb_data immediately, and otherwise use shift register
        spi_miso <= spi_shift_out_reg(DATA_WIDTH-1) when spi_out_en = '1' else spi_mosi;
	--spi_miso <= wb_data_i(DATA_WIDTH-1) when spi_shift_count = ADDR_WIDTH else spi_shift_out_reg(DATA_WIDTH-1);
	
	-- Clocking out data
	process(spi_clk_delayed)
	begin
	
		-- In theory, data should change on the falling edge of spi_clk, but to achieve 
		-- higher speeds we give extra time by transitioning on the delayed rising edge
		if spi_rst ='1' then
		  spi_out_en <= '0';
			spi_shift_out_reg <= (others => '0');
		elsif rising_edge(spi_clk_delayed) then
			
			-- Shifting data output
			if spi_shift_count > (ADDR_WIDTH + HOLDOFF - 1) then
				
				spi_shift_out_reg <= spi_shift_out_reg(DATA_WIDTH-2 downto 0) & '0';
				
			elsif  wb_ack = '1' then
				for byte_index in 0 to (DATA_WIDTH/8-1) loop
                    spi_shift_out_reg(byte_index*8+7 downto byte_index*8) <= wb_data_i((DATA_WIDTH/8-1-byte_index)*8+7 downto (DATA_WIDTH/8-1-byte_index)*8);
				end loop;
				spi_out_en <= '1';
				
			end if;	
			-- Capture data from wishbone device and start output
--			elsif spi_shift_count = ADDR_WIDTH and wb_ack = '1' then
				
--				spi_shift_out_reg <= wb_data_i(DATA_WIDTH-2 downto 0) & '0';
				
--			end if;
			
		end if;
		
	end process;
	
	
end Behavioral;
