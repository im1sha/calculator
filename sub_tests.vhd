library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity sub_tests is
end sub_tests;
 
architecture behavior of sub_tests is 
 
    -- component declaration for the unit under test (uut)
 
    component sub
    port( 
           a       : in  std_logic_vector (7 downto 0); -- operand a
           b       : in  std_logic_vector (7 downto 0); -- operand b
           c_in    : in  std_logic;
           s       : out std_logic_vector (7 downto 0);
           c_out   : out std_logic);
    end component;
    

   --inputs
   signal c_in : std_logic := '0';
   signal a : std_logic_vector(7 downto 0) := (others => '0');
   signal b : std_logic_vector(7 downto 0) := (others => '0');

 	--outputs
   signal s : std_logic_vector(7 downto 0);
   signal c_out : std_logic;

   -- clock period definitions
   constant clock_period : time := 10 ns;
 
begin
 
	-- instantiate the unit under test (uut)
   uut: sub port map (
          a => a,
          b => b,
          c_in => c_in,
          s => s,
          c_out => c_out
        );

   op1_process :process
   begin       
        wait for clock_period;
        a <= a + '1';
   end process;
   
   op2_process :process
   begin 
        wait for clock_period*3;
        b <= b + '1';       
   end process;

end;
