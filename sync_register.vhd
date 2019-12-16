library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity sync_register is
    generic ( n : integer := 8);
    port ( din : in  std_logic_vector (n-1 downto 0);
           ce : in  std_logic;
           c : in  std_logic;
           dout : out  std_logic_vector (n-1 downto 0));
end sync_register;

architecture structural of sync_register is
begin
   u1: for i in 0 to n-1 generate
      u2: fde port map ( d => din(i), 
                         ce => ce, 
                         c => c, 
                         q => dout(i));
   end generate;
end structural;

architecture behavioral of syncregister is
signal reg : std_logic_vector (n-1 downto 0) := (others => '0');
begin
   main : process ( din, ce, c )
   begin
      if rising_edge(c) then
         if ce = '1' then
            reg <= din;
         end if;
      end if;
   end process;
   
   dout <= reg;
end behavioral;