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
 
ENTITY div_tests IS
END div_tests;
 
ARCHITECTURE behavior OF div_tests IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT divide
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         start : IN  std_logic;
         m : IN  std_logic_vector(15 downto 0);
         n : IN  std_logic_vector(7 downto 0);
         quotient : OUT  std_logic_vector(7 downto 0);
         remainder : OUT  std_logic_vector(7 downto 0);
         ready : OUT  std_logic;
         ovfl : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal start : std_logic := '0';
   signal m : std_logic_vector(15 downto 0) := (others => '0');
   signal n : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal quotient : std_logic_vector(7 downto 0);
   signal remainder : std_logic_vector(7 downto 0);
   signal ready : std_logic;
   signal ovfl : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: divide PORT MAP (
          clk => clk,
          reset => reset,
          start => start,
          m => m,
          n => n,
          quotient => quotient,
          remainder => remainder,
          ready => ready,
          ovfl => ovfl
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
		start <= '1';       
        reset <= '1';
		wait for clk_period;
		start <= '0';     
        reset <= '0';
		wait for 1000 ns;

	end process;
 

END;
