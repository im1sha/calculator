library ieee;
use ieee.std_logic_1164.all;

entity divide_wrapper is
    generic (total : integer := 8);
    port(clk : in  std_logic;
         go : in  std_logic;
         m : in  std_logic_vector(total*2-1 downto 0);
         n : in  std_logic_vector(total-1 downto 0);
         quotient : out  std_logic_vector(total-1 downto 0);
         remainder : out  std_logic_vector(total-1 downto 0);
         ready : out  std_logic;
         ovfl : out  std_logic
        );
end divide_wrapper;

architecture behavioral of divide_wrapper is

    component divide   
        generic (total : integer);
        port(
             clk : in  std_logic;
             reset : in  std_logic;
             start : in  std_logic;
             m : in  std_logic_vector(total*2-1 downto 0);
             n : in  std_logic_vector(total-1 downto 0);
             quotient : out  std_logic_vector(total-1 downto 0);
             remainder : out  std_logic_vector(total-1 downto 0);
             ready : out  std_logic;
             ovfl : out  std_logic
            );
    end component;
    

    signal div_reset, div_start, div_ready: std_logic := '0';
    signal div_quotient : std_logic_vector(total-1 downto 0) := (others => '0');
    signal div_remainder : std_logic_vector(total-1 downto 0) := (others => '0');
    signal div_n : std_logic_vector(total-1 downto 0) := (others => '0');
    signal div_m : std_logic_vector(total*2-1 downto 0) := (others => '0');
    signal div_n_copy : std_logic_vector(total-1 downto 0) := (others => '0');
    signal div_m_copy : std_logic_vector(total*2-1 downto 0) := (others => '0');
    signal div_quotient_copy : std_logic_vector(total-1 downto 0) := (others => '0');
    signal div_remainder_copy : std_logic_vector(total-1 downto 0) := (others => '0');
    signal is_ready, is_start, is_reset : std_logic := '0';
    signal s_started: integer := -1; 
begin

    uu: divide generic map (total => total)
        port map(clk => clk,
                 reset => div_reset,
                 start => div_start,
                 m => div_m, 
                 n => div_n,
                 quotient => div_quotient,
                 remainder => div_remainder,  
                 ready => div_ready,
                 ovfl => ovfl);    
       
    process(clk, s_started, div_ready, go, div_quotient, div_remainder)
    begin
        
       if rising_edge(go) then
           if s_started = -1 then
               div_n_copy <= n;
               div_m_copy <= m;
               div_quotient_copy <= (others => '0');
               div_remainder_copy <= (others => '0');              
               s_started <= 0;            
               is_ready <= '0';
           end if;
       end if;
       
       if rising_edge(clk) then
            if (s_started = 0)  then 
                s_started <= 1;
                
                is_start <= '0';
                is_reset <= '1';
                
            elsif s_started = 1 then 
                s_started <= 2;
                
                is_start <= '1';               
                is_reset <= '0';
                
            elsif s_started = 2 then 
                
                is_start <= '0';
                is_reset <= '0'; 
                               
                if div_ready = '1' then 
                    s_started <= -1;

                    div_quotient_copy <= div_quotient;
                    div_remainder_copy <= div_remainder;
                    
                    is_ready <= '1'; 
                    
                end if;
                
            end if;
       end if;            
    end process;
       
    div_start <= is_start;
    div_reset <= is_reset;  
    ready <= is_ready;
    quotient <= div_quotient_copy;
    remainder <= div_remainder_copy;
    div_m <= div_m_copy;
    div_n <= div_n_copy;
    
    --deb_state <= s_started;
end behavioral;

