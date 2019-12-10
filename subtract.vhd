library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity sub is
    generic (n: integer := 8);
    port ( 
           a       : in  std_logic_vector (n-1 downto 0); -- operand a
           b       : in  std_logic_vector (n-1 downto 0); -- operand b
           c_in    : in  std_logic;
           s       : out std_logic_vector (n-1 downto 0);
           c_out   : out std_logic);
end sub;

architecture structural of sub is
component full_subtractor
      port ( 
           a      : in   std_logic;
           b      : in   std_logic;
           c_in   : in   std_logic;
           s      : out  std_logic;
           c_out  : out  std_logic);
end component;

signal carry: std_logic_vector(n-1 downto 0);
signal buf_result: std_logic_vector(n-1 downto 0) := (others => '0');

begin
    u1: full_subtractor port map (a(0), b(0), c_in, buf_result(0), carry(0));
    u2: buf port map (I => buf_result(0), O => s(0));

    u3: for i in 1 to n-2 generate
        u4: full_subtractor port map (a(i), b(i), carry(i-1), buf_result(i), carry(i));
        u5: buf port map (I => buf_result(i), O => s(i));
    end generate;
    
    u6: full_subtractor port map (a(n-1), b(n-1), carry(n-2), buf_result(n-1), carry(n-1));	 
    u7: buf port map (I => buf_result(n-1), O => s(n-1));
    u8: buf port map (I => carry(n-1), O => c_out);
end structural;
