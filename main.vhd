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

architecture behavioral of main is

type states is (state_opr_in, 
                state_opd1_in, 
                state_opd2_in, 
                state_out);

signal current_state, next_state : states;

signal fop : std_logic_vector(1 downto 0);

begin

    fsm_dff: process (clock_100mhz, next_state, reset)
    begin
        if reset = '1' then 
            current_state <= state_opr_in;
        elsif rising_edge (clock_100mhz) then
            current_state <= next_state;
        end if;
    end process;
	 
	 fsm_gamma: process (current_state, reset, ok, save, get)
	 begin 
        next_state <= state_opr_in;
--		case current_state is
--			when state_opr_in => 
--				if ok = '1' then
--				
--				else
--				
--				end if;
--			when state_opd1_in => 
--				if then
--				
--				else
--				
--				end if;
--			when state_opd2_in => 
--				if then
--				
--				else
--				
--				end if;
--			when state_out => 
--				if then
--				
--				else
--				
--				end if;
--            when others => next_state <= state_opr_in;
--        end case;
	 end process;
     
     fsm_phi: process(current_state)
     begin
        case current_state is 
            when state_opr_in => fop <= "00";
			when state_opd1_in => fop <= "01";
			when state_opd2_in => fop <= "10";								
			when state_out => fop <= "11";				
            when others => fop <= "00";
        end case;
     end process;
     
     -- OUTPUT <= fop;  
end behavioral;

