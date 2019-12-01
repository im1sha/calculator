library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity display is
    port(clock_100mhz : in std_logic;  
         reset : in std_logic;     
         -- 4 anode signals
         anode_activate : out std_logic_vector(3 downto 0);      
         -- cathode patterns of 7-segment display 
         led_out : out std_logic_vector(6 downto 0)); 
end display;


architecture behavioral of display is


-- counter for generating 1-second clock enable
-- 27 is least degree of 2 that's more than 100_000_000
signal one_second_counter: std_logic_vector(27 downto 0) := (others => '0');
-- one second enable for counting numbers
signal one_second_enable: std_logic := '0';
-- counting decimal number to be displayed on 4-digit 7-segment display
signal displayed_number: std_logic_vector(15 downto 0) := (others => '0');

signal led_bcd: std_logic_vector(3 downto 0) := (others => '0');
-- creating 10.5ms refresh period
signal refresh_counter: std_logic_vector(19 downto 0) := (others => '0');
-- the other 2-bit for creating 4 led-activating signals
-- count         0    ->  1(01)  ->  2(10)  ->  3(11)
-- activates     led1     led2       led3       led4
-- and repeat
signal led_activating_counter: std_logic_vector(1 downto 0) := (others => '0');


begin


-- vhdl code for bcd to 7-segment decoder
-- cathode patterns of the 7-segment led display 
led_out_process: process(led_bcd)
begin
    case led_bcd is
        when "0000" => led_out <= "0000001"; -- "0"     
        when "0001" => led_out <= "1001111"; -- "1" 
        when "0010" => led_out <= "0010010"; -- "2" 
        when "0011" => led_out <= "0000110"; -- "3" 
        when "0100" => led_out <= "1001100"; -- "4" 
        when "0101" => led_out <= "0100100"; -- "5" 
        when "0110" => led_out <= "0100000"; -- "6" 
        when "0111" => led_out <= "0001111"; -- "7" 
        when "1000" => led_out <= "0000000"; -- "8"     
        when "1001" => led_out <= "0000100"; -- "9" 
        when "1010" => led_out <= "0000010"; -- a
        when "1011" => led_out <= "1100000"; -- b
        when "1100" => led_out <= "0110001"; -- c
        when "1101" => led_out <= "1000010"; -- d
        when "1110" => led_out <= "0110000"; -- e
        when "1111" => led_out <= "0111000"; -- f
        when others => led_out <= "1111111"; -- null
    end case;
end process;


-- 7-segment display controller
-- generate refresh period of 10.5ms
refresh_counter_process: process(clock_100mhz, reset)
begin 
    if (reset = '1') then
        refresh_counter <= (others => '0');
    elsif (rising_edge(clock_100mhz)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;


led_activating_counter <= refresh_counter(19 downto 18);
 
 
-- 4-to-1 mux to generate anode activating signals for 4 leds 
anode_activate_process: process(led_activating_counter, displayed_number)
begin
    case led_activating_counter is
        when "00" =>      
            -- activate led and deactivate other leds
            anode_activate <= "0111"; 
            led_bcd <= displayed_number(15 downto 12);
        when "01" =>
            anode_activate <= "1011"; 
            led_bcd <= displayed_number(11 downto 8);
        when "10" =>
            anode_activate <= "1101"; 
            led_bcd <= displayed_number(7 downto 4);
        when others => -- "11"
            anode_activate <= "1110"; 
            led_bcd <= displayed_number(3 downto 0);
    end case;
end process;


-- counting the number to be displayed on 4-digit 7-segment display 
-- on basys 3 fpga board
one_second_counter_process: process(clock_100mhz, reset)
begin
    if (reset = '1') then
        one_second_counter <= (others => '0');
    elsif (rising_edge(clock_100mhz)) then
        if (one_second_counter >= x"5F5E0FF") then
            one_second_counter <= (others => '0');
        else
            one_second_counter <= one_second_counter + "0000001";
        end if;
    end if;
end process;


--  99_999_999 equals to 0x5F5E0FF
one_second_enable <= '1' when one_second_counter >= x"5F5E0FF" else '0';


displayed_number_process: process(clock_100mhz, reset, one_second_enable)
begin
    if (reset = '1') then
        displayed_number <= (others => '0');
    elsif (rising_edge(clock_100mhz)) then
        if (one_second_enable = '1') then
            displayed_number <= displayed_number + x"0001";
        end if;
    end if;
end process;


end behavioral;
