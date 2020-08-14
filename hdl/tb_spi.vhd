----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.08.2020 22:00:52
-- Design Name: 
-- Module Name: tb_spi - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_spi is
--  Port ( );
end tb_spi;

architecture Behavioral of tb_spi is
    component spislave is
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
   
    constant ADDR_WIDTH : Positive range 8 to 64 := 8;
	constant DATA_WIDTH : Positive range 8 to 64 := 32;
	constant AUTO_INC_ADDRESS : STD_LOGIC := '0';
	
	constant CLK_PERIOD : time := 7.5 ns;
	constant CLK_PERIOD_SPI : time := 40 ns;
	signal clk_150 :std_logic;
	signal spi_clk_mux, spi_clk_buf, spi_clk, spi_mosi, spi_miso : std_logic := '0';
	signal spi_ce : std_logic_vector(1 downto 0) := "11";
	
	
	signal wb_cycle :  STD_LOGIC;
	signal wb_write :  STD_LOGIC;
	signal wb_address :  STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
	signal wb_data_i1 :  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := X"00FF00FF";
	signal wb_data_i0 :  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0) := X"10FF00F1";
	signal wb_data_o :  STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
	signal wb_ack, spi_wb_ack :  STD_LOGIC_VECTOR(0 downto 0);
	signal wb_strobe : std_logic_vector(1 downto 0);
	
	signal spi_data :  STD_LOGIC_VECTOR(91 downto 0) := X"00006000000000000000000";
	signal spi_mask :  STD_LOGIC_VECTOR(91 downto 0) := X"000FF0FF0FF0FF0FF0FF000";
	signal idx, idx2 : integer := 91;
begin
       Clk_process :process
       begin
            clk_150 <= '0';
            --adcin <= std_logic_vector(unsigned(adcin) + 1);
            wait for CLK_PERIOD/2;  --for half of clock period clk stays at '0'.
            clk_150 <= '1';
            wait for CLK_PERIOD/2;  --for next half of clock period clk stays at '1'.
       end process;
       
       Clkspi_process :process
       begin
            spi_clk_buf <= '0';
            --adcin <= std_logic_vector(unsigned(adcin) + 1);
            wait for CLK_PERIOD_SPI/2;  --for half of clock period clk stays at '0'.
            spi_clk_buf <= '1';
            wait for CLK_PERIOD_SPI/2;  --for next half of clock period clk stays at '1'.
       end process;
       spi_clk <= spi_mask(idx) and spi_clk_buf;
       spi_mosi <= spi_data(idx);
       
       spi_trigger : process(spi_clk_buf) 
       begin
        if (rising_edge(spi_clk_buf)) then
            if (idx = 0) then
             idx <= 91;
            else
             idx <= idx - 1;
            end if;
            
            if idx > 4 and idx < 88 then
                spi_ce <= "10";
            else 
                spi_ce <= "11";
            end if;
        end if;
       
       end process;
       wb_ack <= "1";
    u_spislave : component spislave 
	 Generic map (
				  ADDR_WIDTH => ADDR_WIDTH,
				  DATA_WIDTH => DATA_WIDTH,
				  HOLDOFF => 8,
				  AUTO_INC_ADDRESS => AUTO_INC_ADDRESS
				  )
      Port map ( 
              sys_clk => clk_150,
			  
			  spi_clk => spi_clk,
			  spi_ce  => spi_ce,
			  spi_mosi=> spi_mosi,
			  spi_miso=> spi_miso,
			  spi_delayed_clk => open,
			  
			  wb_cycle => wb_cycle,
			  wb_strobe => wb_strobe,
			  wb_write => wb_write,
			  wb_address => wb_address,
			  wb_data_i1 => wb_data_i1,
			  wb_data_i0 => wb_data_i0,
			  wb_data_o => wb_data_o,
			  wb_ack => wb_ack(0)
			  );

end Behavioral;
