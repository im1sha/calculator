--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   02:27:25 12/16/2019
-- Design Name:   
-- Module Name:   E:/Git.Uni/calculator/div_tests.vhd
-- Project Name:  calc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: divide
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY div_wrapper_tests IS
END div_wrapper_tests;
 
ARCHITECTURE behavior OF div_wrapper_tests IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT divide_wrapper
    PORT(
         clk : IN  std_logic;
         go : IN  std_logic;
         m : IN  std_logic_vector(15 downto 0);
         n : IN  std_logic_vector(7 downto 0);
         quotient : OUT  std_logic_vector(7 downto 0);
         remainder : OUT  std_logic_vector(7 downto 0);
         ready : OUT  std_logic;
         ovfl : OUT  std_logic--;
         --deb_state : out integer
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal go : std_logic := '0';
   signal m : std_logic_vector(15 downto 0) := (others => '0');
   signal n : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal quotient : std_logic_vector(7 downto 0);
   signal remainder : std_logic_vector(7 downto 0);
   signal ready : std_logic;
   signal ovfl : std_logic;
   signal deb_state : integer;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: divide_wrapper PORT MAP (
          clk => clk,
          go => go,
          m => m,
          n => n,
          quotient => quotient,
          remainder => remainder,
          ready => ready,
          ovfl => ovfl--,
          --deb_state => deb_state
          );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	input_tb : process
	begin
		m <= "0000101001110101";
		n <= "00011010";
       wait for clk_period/2;

	end process;
	
	start_proc: process
	begin
		
        wait for clk_period;    
        go <= '1';

		wait for clk_period*100;
        go <= '0';  

	end process;
 

END;
