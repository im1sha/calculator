--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:42:20 12/15/2019
-- Design Name:   
-- Module Name:   E:/Git.Uni/Project/main_tests.vhd
-- Project Name:  Lab2Dop
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY main_tests IS
END main_tests;
 
ARCHITECTURE behavior OF main_tests IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main
    PORT(
         a : IN  std_logic_vector(7 downto 0);
         clk : IN  std_logic;
         operation_switches : IN  std_logic_vector(1 downto 0);
         reset_button : IN  std_logic;
         enter_button : IN  std_logic;
         save_button : IN  std_logic;
         get_button : IN  std_logic;
         seg : OUT  std_logic_vector(6 downto 0);
         an : OUT  std_logic_vector(7 downto 0);
         deb_0 : out std_logic_vector(7 downto 0);
         deb_1 : out std_logic_vector(7 downto 0);
         deb_2 : out std_logic_vector(7 downto 0);
         deb_s : out std_logic_vector(7 downto 0);          
         deb_index: out integer;
         deb_state: out integer;     
         deb_output : out std_logic_vector(7 downto 0)          
        );
    END COMPONENT;
    

   --Inputs
   signal a : std_logic_vector(7 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal operation_switches : std_logic_vector(1 downto 0) := "10";
   signal reset_button : std_logic := '0';
   signal enter_button : std_logic := '0';
   signal save_button : std_logic := '0';
   signal get_button : std_logic := '0';

 	--Outputs
   signal seg : std_logic_vector(6 downto 0);
   signal an : std_logic_vector(7 downto 0);
   
   signal deb_0 : std_logic_vector(7 downto 0);
   signal deb_1 : std_logic_vector(7 downto 0);
   signal deb_2 : std_logic_vector(7 downto 0);
   signal deb_s : std_logic_vector(7 downto 0);
   signal deb_output : std_logic_vector(7 downto 0);
   signal deb_index :integer;
   signal deb_state :integer;


   -- Clock period definitions
   constant clk_period : time := 10 ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main PORT MAP (
          a => a,
          clk => clk,
          operation_switches => operation_switches,
          reset_button => reset_button,
          enter_button => enter_button,
          save_button => save_button,
          get_button => get_button,
          seg => seg,
          an => an,
          deb_0 => deb_0,
          deb_1 => deb_1,
          deb_2 => deb_2,
          deb_s => deb_s,
          deb_index => deb_index,
          deb_state => deb_state,
          deb_output => deb_output
        );
   

   clock_100mhz_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
   
   a_proc: process
   begin	
      a <= a+'1';
      wait for clk_period * 0.139;
   end process;
   
   sw_proc: process
   begin	  
      wait for clk_period * 149;	
      reset_button <= '1';   
      --operation_switches <= operation_switches + '1';
      wait for clk_period ;
      reset_button <= '0';
   end process;

   enter_porcess: process
   begin
      wait for clk_period * 29;
      enter_button <= '1';
      wait for clk_period;
      enter_button <= '0';  
   end process;



END;
