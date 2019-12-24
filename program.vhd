
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity program is
	generic (n : integer := 8);
    port ( a : in  std_logic_vector (n-1 downto 0);
           clk: in std_logic;     
           
           operation_switches : in std_logic_vector(1 downto 0);
           
           reset_button : in std_logic;
           enter_button : in std_logic;
           
           save_button : in std_logic;
           get_button : in std_logic;
           
           seg : out std_logic_vector(6 downto 0);
           an : out std_logic_vector(7 downto 0));
end program;

architecture Behavioral of program is
	component main
		generic(n : integer);
      port(a : in  std_logic_vector (n-1 downto 0);
           clk: in std_logic;     
           
           operation_switches : in std_logic_vector(1 downto 0);
           
           reset_button : in std_logic;
           enter_button : in std_logic;
           
           save_button : in std_logic;
           get_button : in std_logic;
           
           seg : out std_logic_vector(6 downto 0);
           an : out std_logic_vector(7 downto 0);
			  
           deb_0 : out std_logic_vector(n-1 downto 0);
           deb_1 : out std_logic_vector(n-1 downto 0);
           deb_2 : out std_logic_vector(n-1 downto 0);
           deb_s : out std_logic_vector(n-1 downto 0);
           deb_divop2 : out std_logic_vector(n-1 downto 0);
           deb_index: out integer;
           deb_state: out integer;
           deb_output: out std_logic_vector(n-1 downto 0);
           deb_ready : out std_logic
           ); 
end component;
			  
			  signal var_deb_0 :  std_logic_vector(n-1 downto 0);
           signal var_deb_1 : std_logic_vector(n-1 downto 0);
           signal var_deb_2 :  std_logic_vector(n-1 downto 0);
           signal var_deb_s :  std_logic_vector(n-1 downto 0);
           signal var_deb_divop2 :  std_logic_vector(n-1 downto 0);
           signal var_deb_index:  integer;
           signal var_deb_state:  integer;
           signal var_deb_output:  std_logic_vector(n-1 downto 0);
           signal var_deb_ready :  std_logic;

begin
	 uu: main generic map (n => n)
        port map(a => a,
					  clk => clk,     
					  
					  operation_switches => operation_switches ,
					  
					  reset_button => reset_button,
					  enter_button => enter_button,
					  
					  save_button => save_button,
					  get_button => get_button,
					  
					  seg => seg,
					  an => an,
					  deb_0 => var_deb_0,
					  deb_1 => var_deb_1,
					  deb_2 => var_deb_2,
					  deb_s => var_deb_s,
					  deb_divop2 => var_deb_divop2,
					  deb_index => var_deb_index,
					  deb_state => var_deb_state,
					  deb_output => var_deb_output,
					  deb_ready => var_deb_ready  );    

end Behavioral;

