library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity full_adder is
    port ( a      : in  std_logic;
           b      : in  std_logic;
           c_in   : in  std_logic;
           s      : out  std_logic;
           c_out  : out  std_logic);
end full_adder;

architecture behavioral of full_adder is

signal a_xor_b,
       a_xor_b_and_c, 
       a_and_b : std_logic;
begin
     a_xor_b <= a xor b;
     a_xor_b_and_c <= a_xor_b and c_in;
     a_and_b <= a and b;
     s <= a_xor_b xor c_in;
     c_out <= a_xor_b_and_c or a_and_b;
end behavioral;

