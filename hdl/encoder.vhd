----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.03.2023 16:14:42
-- Design Name: 
-- Module Name: encoder - Behavioral
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

entity encoder is
  GENERIC(
    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
  Port ( 
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    position  : OUT    STD_LOGIC_VECTOR(11 DOWNTO 0); --data read from slave
    i2c_error : OUT    STD_LOGIC;                    --flag if improper acknowledge from slave
    encoder_error : OUT    STD_LOGIC_VECTOR(2 downto 0);                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC                   --serial clock output of i2c bus
  );
end encoder;

architecture Behavioral of encoder is
component i2c_master IS
  GENERIC(
    input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
    bus_clk   : INTEGER := 400_000);   --speed the i2c bus (scl) will run at in Hz
  PORT(
    clk       : IN     STD_LOGIC;                    --system clock
    reset_n   : IN     STD_LOGIC;                    --active low reset
    ena       : IN     STD_LOGIC;                    --latch in command
    addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
    rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
    data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
    busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
    data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
    data_rd_v : OUT    STD_LOGIC; --data read from slave
    ack_error : OUT    STD_LOGIC;                    --flag if improper acknowledge from slave
    sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
    scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
END component;

signal ena       : STD_LOGIC;                    --latch in command
signal addr      : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"36"; --address of target slave
signal rw        : STD_LOGIC := '1';                    --'0' is write, '1' is read
signal data_wr   : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001011"; --data to write to slave
signal busy, busy_delay      : STD_LOGIC;                    --indicates transaction in progress
signal data_rd_v : STD_LOGIC; --data read from slave
signal data_rd   : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal ack_error : STD_LOGIC; 
TYPE machine IS(RESET, PAUSE, ADDRESS, STATUS, FIRST, SECOND, OUTP); --needed states
SIGNAL state_b, state         : machine := RESET;                       --state machine

signal count : integer := 0;

signal position_buffer, position_tmp  : STD_LOGIC_VECTOR(11 DOWNTO 0) := (others => '0');

ATTRIBUTE MARK_DEBUG : string;
ATTRIBUTE MARK_DEBUG of state_b, data_rd, position_buffer, busy_delay: SIGNAL IS "TRUE";
begin

    process (clk, reset_n)
    begin
        if reset_n = '0' then
            ena <= '0';
            position <= (others => '0');
            position_tmp <= (others => '0');
            count <= 0;
            i2c_error <= '0';
            rw <= '0';
            busy_delay <= '0';
        elsif rising_edge(clk) then
            position <= position_buffer; 
            position_tmp <= position_tmp;
            busy_delay <= busy;
            state_b <= state;
            case state is
                when RESET => 
                    count <= 0;
                    ena <= '0';
                    rw <= '0';
                    position_tmp <= (others => '0');
                    if busy = '0' then
                        state <= PAUSE;
                    end if;
                when PAUSE => 
                    count <= count + 1;
                    rw <= '0';
                    if count = 50000 then
                        state <= ADDRESS;
                    end if;
                when ADDRESS => 
                    ena <= '1';
                    rw <= '0';
                    if busy = '0' and busy_delay = '1' then
                        state <= STATUS;
                        rw <= '1';
                    end if;
                when STATUS => 
                    rw <= '1';
                    ena <= '1';
                    if busy = '0' and busy_delay = '1'  then
                        state <= FIRST;
                        encoder_error <= data_rd(5 downto 3);
                    end if;
                when FIRST =>
                    rw <= '1';
                    ena <= '1';
                    if busy = '0' and busy_delay = '1'  then
                        state <= SECOND;
                        position_tmp(11 downto 8) <= data_rd(3 downto 0);
                    end if;
                when SECOND =>
                    rw <= '1';
                    ena <= '1';
                    if busy = '0' and busy_delay = '1'  then
                        state <= OUTP;
                        position_tmp(7 downto 0) <= data_rd;
                        ena <= '0';
                    end if;
                when OUTP =>
                    rw <= '0';
                    position_buffer <= position_tmp;
                    ena <= '0';
                    state <= RESET;
                    i2c_error <= '0';
                when OTHERS =>
                    state <= RESET;
             end case;
                
             if  ack_error = '1' then
                state <= RESET;
                i2c_error <= '1';
             end if; 
        end if;
    end process;

i2c: i2c_master 
  GENERIC map(
        input_clk => input_clk, --input clock speed from user logic in Hz
        bus_clk   => bus_clk
    )   --speed the i2c bus (scl) will run at in Hz
  PORT map(
    clk       => clk,                   --system clock
    reset_n   => reset_n   , --active low reset
    ena       => ena       , --latch in command
    addr      => addr(6 downto 0)      , --address of target slave
    rw        => rw        , --'0' is write, '1' is read
    data_wr   => data_wr   , --data to write to slave
    busy      => busy      , --indicates transaction in progress
    data_rd   => data_rd   , --data read from slave
    data_rd_v => data_rd_v , --data read from slave
    ack_error => ack_error , --flag if improper acknowledge from slave
    sda       => sda       , --serial data output of i2c bus
    scl       => scl        --serial clock output of i2c bus
    );
end Behavioral;
