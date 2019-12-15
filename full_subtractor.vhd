library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity full_subtractor is
    port (a :    in std_logic;
          b :    in std_logic;
          c_in :  in std_logic;
          s :    out std_logic;
          c_out : out std_logic);
end full_subtractor;

architecture behavioral of full_subtractor is
    signal 
        a_xor_b, 
        cin_xor_axorb,
        not_a,
        b_and_nota,
        not_axorb,
        notaxorb_and_cin,
        down_or: std_logic;
begin
    a_xor_b <= a xor b;
    cin_xor_axorb <= a_xor_b xor c_in;
    not_a <= not a;
    b_and_nota <= not_a and b;
    not_axorb <= not a_xor_b;
    notaxorb_and_cin <= not_axorb and c_in;
    down_or <= b_and_nota or notaxorb_and_cin;
    s <= cin_xor_axorb;
    c_out <= down_or;
end behavioral;

