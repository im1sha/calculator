library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity code_converter is
	 generic (n : integer := 8);
    port ( sign : in  std_logic;
           in_vector : in  std_logic_vector (n-1 downto 0);
           out_vector : out  std_logic_vector (n-1 downto 0));
end code_converter;

architecture behavioral of code_converter is
	signal temp: std_logic_vector (n-1 downto 0) := (others => '0');
begin
	out_vector <= (not in_vector) + "1" when sign = '1' else in_vector;
end behavioral;