library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- in use 

entity main is
    port(clock_100mhz : in std_logic;
    
         ----------------- buttons -----------------------        
         reset : in std_logic; -- to first state  
         ok : in std_logic; -- to next state
         save : in std_logic; -- save number to memory
         -- operand : get number from memory. 
         -- operator : select next one
         get : in std_logic; 
         -------------------------------------------------
         
         switches : in std_logic_vector(7 downto 0);
         
         -- 4 anode signals
         anode_activate : out std_logic_vector(3 downto 0);      
         -- cathode patterns of 7-segment display 
         led_out : out std_logic_vector(6 downto 0)); 
end main;

architecture Behavioral of main is

type states is (operator_input_state, op1_input_state, op2_input_state, output_state);

signal current_state, next_state : states;

begin

    FSM_dff: process (clock_100mhz)
    begin
        if reset = '1' then 
            current_state <= operator_input_state;
        elsif rising_edge (clock_100mhz) then
            current_state <= next_state;
        end if;
    end process;
end Behavioral;

