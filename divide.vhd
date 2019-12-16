library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divide is
    generic (total : integer := 8);
    port (clk : in std_logic;
          reset : in std_logic;
          start : in std_logic;
          m : in  std_logic_vector (total * 2 - 1 downto 0);     -- input for dividend
          n : in  std_logic_vector (total - 1 downto 0);    -- input for divisor 
          quotient : out  std_logic_vector (total - 1 downto 0);    -- output for quotient
          remainder : out  std_logic_vector (total - 1 downto 0);    -- output for remainder
          ready :out std_logic; 
          ovfl : out std_logic);    -- indicates end of algorithm and overflow condition
 end divide;

 architecture behavioral of divide is
  
    -- type for the fsm states
    type state_type is (idle, shift, op);     

    -- inputs/outputs of the state register and the z, d, and i registers

    signal state_reg, state_next : state_type;   
    signal z_reg, z_next : unsigned(total * 2 downto 0);   
    signal d_reg, d_next : unsigned(total - 1 downto 0);
    signal i_reg, i_next : unsigned(total / 2 - 1 downto 0);
    constant i_next_bound_value : unsigned(total / 2 - 1 downto 0) := (total / 2 - 1 => '1', others => '0'); --"1000"
    signal quotient_store, remainder_store :std_logic_vector (total - 1 downto 0) := (others => '0');
    signal current_clock: integer := 0;
    -- the subtraction output 
    signal sub : unsigned(total downto 0);
          
 begin
      --control path: registers of the fsm
      process(clk, reset, state_next)
      begin
        if (reset='1') then
            state_reg <= idle;
        elsif (clk'event and clk='1') then
            state_reg <= state_next;
        end if;
    end process;
    
    --control path: the logic that determines the next state of the fsm (this part of
    --the code is written based on the green hexagons of figure 3)
    process(state_reg, start, m, n, i_next)
    begin
        case state_reg is
            when idle =>
                if ( start='1' ) then
                    if ( m(total*2-1 downto total) < n ) then
                    state_next <= shift;
                    else
                    state_next <= idle;
                    end if;
                else
                    state_next <= idle;
                end if;
                        
            when shift =>
                state_next <= op;
                
            when op =>
                if ( i_next = i_next_bound_value ) then
                    state_next <= idle;
                else
                    state_next <= shift;
                end if;
                        
            end case;
        end process;
                
    --control path: output logic
    ready <= '1' when state_reg=idle else
            '0';
    ovfl <= '1' when ( state_reg=idle and ( m(total*2-1 downto total) >= n ) ) else
        '0';
                            
    --control path: registers of the counter used to count the iterations
    process(clk, reset, i_next)
    begin
        if (reset='1') then
            i_reg <= ( others=>'0' );
        elsif (clk'event and clk='1') then
            i_reg <= i_next;
        end if;
    end process;
        
    --control path: the logic for the iteration counter
    process(state_reg, i_reg)
    begin
        case state_reg is
            when idle =>
                i_next <= (others => '0');
                                
            when shift =>
                i_next <= i_reg;
                
            when op =>
                i_next <= i_reg + 1;
        end case;
    end process;
                
        
        
    --data path: the registers used in the data path
    process(clk, reset, z_next, d_next)
    begin
        if ( reset='1' ) then
            z_reg <= (others => '0');
            d_reg <= (others => '0');
        elsif ( clk'event and clk='1' ) then
            z_reg <= z_next;
            d_reg <= d_next;
        end if;
    end process;
        
    --data path: the multiplexers of the data path (written based on the register
    --assignments that take place in different states of the asmd)
    process( state_reg, m, n, z_reg, d_reg, sub)
    begin
        d_next <= unsigned(n);
        case state_reg is
            when idle =>
                z_next <= unsigned( '0' & m );
                
            when shift =>
                z_next <= z_reg(total*2-1 downto 0) & '0';
            
            when op =>
                if ( z_reg(total*2 downto total) < ('0' & d_reg ) ) then
                    z_next <= z_reg;
                else
                    z_next <=  sub(total downto 0) & z_reg(total-1 downto 1) & '1';
                end if;
        end case;
    end process;
        
    --data path: functional units
    sub <= ( z_reg(total*2 downto total) - unsigned('0' & n) );
        
--    --data path: output
   quotient <= std_logic_vector( z_reg(total-1 downto 0) );
   remainder <= std_logic_vector( z_reg(total*2-1 downto total) );
--        

--    process(clk, current_clock, reset)
--    begin
--        if (reset='1') then
--            current_clock <= 0;
--        elsif rising_edge(clk) then 
--            current_clock <= current_clock + 1;
--        end if;    
--    end process;
--
--    output_process: process(reset, z_reg, clk, current_clock, quotient_store, remainder_store)
--    begin
--        if (reset='1') then
--            quotient_store <= (others => '0');
--            remainder_store <= (others => '0');
--        elsif rising_edge(clk) and (current_clock = total * 2) then 
--            quotient_store <= std_logic_vector( z_reg(total-1 downto 0));
--            remainder_store <= std_logic_vector( z_reg(total*2-1 downto total));
--        end if;
--        quotient <= quotient_store;
--        remainder <= remainder_store;
--    end process;
        
end behavioral;