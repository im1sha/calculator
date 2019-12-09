
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

 
entity add_tests is
end add_tests;
 
architecture behavior of add_tests is 
 
    -- component declaration for the unit under test (uut)
 
    component add
    port(
         a : in  std_logic_vector(7 downto 0);
         b : in  std_logic_vector(7 downto 0);
         c_in : in  std_logic;
         s : out  std_logic_vector(7 downto 0);
         c_out : out  std_logic
        );
    end component;
    

   --inputs
   signal a : std_logic_vector(7 downto 0) := (others => '0');
   signal b : std_logic_vector(7 downto 0) := (others => '0');
   signal c_in : std_logic := '0';

 	--outputs
   signal s : std_logic_vector(7 downto 0);
   signal c_out : std_logic;
   -- no clocks detected in port list. replace <clock> below with 
   -- appropriate port name 
 
   constant clock_period : time := 10 ns;
    
    signal error : integer := 0;
    signal c_in_as_int : integer := 0;
    signal c_out_as_int : integer := 0;
    
    signal conv_test1 : integer := 0;
    signal shift : integer := 0;
    signal conv_test2 : integer := 0;
begin
 
	-- instantiate the unit under test (uut)
   uut: add port map (
          a => a,
          b => b,
          c_in => c_in,
          s => s,
          c_out => c_out
        );

   -- clock process definitions
   a_process :process
   begin       
        wait for clock_period;
        a <= a + '1';
   end process;
   
   b_process :process
   begin 
        wait for clock_period*2;
        b <= b + '1';       
   end process;
   
   c_in_process :process
   begin 
        c_in <= '0';
        wait for clock_period*2;
        c_in <= '1';
        wait for clock_period*2;        
   end process;
   
   check: process(c_in, c_out, a, b, s)
   begin 
        if (c_in = '0') then 
            c_in_as_int <= 0;
        else
            c_in_as_int <= 1;
        end if;
        
        
        if (c_out = '0') then 
            c_out_as_int <= 0;      
        else
            c_out_as_int <= 1;       
        end if;
                        
        conv_test1 <= conv_integer(a) + conv_integer(b) + c_in_as_int;

    end process;
   
end;
