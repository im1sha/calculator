library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity main is
     generic (n : integer := 8);    
     port (a : in  std_logic_vector (n-1 downto 0);
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
           deb_index: out integer;
           deb_state: out integer;
           deb_output: out std_logic_vector(n-1 downto 0)
           ); -- debug output
end main;

architecture behavioral of main is

    constant n_div_2 : integer := 4;
    constant n_zeros : std_logic_vector(n-1 downto 0) := (others => '0');
    constant n_ones : std_logic_vector(n-1 downto 0) := (others => '1');

    -----------------------------COMPONENTS------------------------------------------------
    component segment_display
        port (clk : in std_logic;
              number : in  std_logic_vector(7 downto 0);
              minus : in std_logic;
              seg : out std_logic_vector(6 downto 0);
              an : out std_logic_vector(7 downto 0));
    end component;

    component add
        generic (n : integer);
        port (a : in  std_logic_vector (n-1 downto 0); -- operand a
              b : in  std_logic_vector (n-1 downto 0); -- operand b
              c_in : in  std_logic;
              s : out std_logic_vector (n-1 downto 0);
              c_out : out std_logic);
    end component;
     
    component multiply is
        generic (n: integer);
        port (a : in std_logic_vector ((n - 1) downto 0);
              b : in std_logic_vector ((n - 1) downto 0);
              output : out std_logic_vector ((n*2 - 1) downto 0);
              longer_than_operand : out std_logic);
    end component;
       
    component divide is
        generic (total: integer);
        port (clk : in std_logic;
              reset: in std_logic;
              start : in std_logic;
              m : in  std_logic_vector (total*2-1 downto 0);     
              n : in  std_logic_vector (total-1 downto 0);    
              quotient : out  std_logic_vector (total-1 downto 0);  
              remainder : out  std_logic_vector (total-1 downto 0);    
              ready : out std_logic;
              ovfl :out std_logic);  
    end component;
    
    -----------------------------OPERATIONS-----------------------------------------------
    constant code_add : std_logic_vector (1 downto 0) := "00";
    constant code_div : std_logic_vector (1 downto 0) := "10";
    constant code_mult : std_logic_vector (1 downto 0) := "11";
      
    signal current_operation_code : std_logic_vector (1 downto 0) := (others => '0');
    -----------------------------STATES----------------------------------------------------
    type states is (s0, s1, s2, sG, sS);
    
    signal current_state, 
           next_state: states := s0;
           
    signal current_operand_index : integer := 0; -- use with save button only
    signal get_completed, save_completed : std_logic := '0'; -- synchronization flags
         
    -----------------------------OPERANDS--------------------------------------------------
    signal operand_2, -- result                    
           saved_operand : std_logic_vector (n-1 downto 0) := (others => '0');
            
    signal operand0,
           operand1,           
           output_operand -- displayed value
                : std_logic_vector (n-1 downto 0) := (others => '0');
                
    ----------------------------ADD DIFF---------------------------------------------------                  
    signal add_operand_2: std_logic_vector (n-1 downto 0);   
    constant add_in: std_logic := '0';
    signal add_out: std_logic; 
    
    -----------------------------MULT------------------------------------------------------  
    signal mult_operand2: std_logic_vector (2*n-1 downto 0);
    signal mult_overflow: std_logic;  

    -----------------------------DIV-------------------------------------------------------  
    signal div_operand2: std_logic_vector (n-1 downto 0); -- result  
    signal div_remainder: std_logic_vector (n-1 downto 0);  
    signal div_reset: std_logic := '0';   
    signal div_start: std_logic := '0';  
    signal div_ready: std_logic;  
    signal div_overflow: std_logic;  
    signal div_started: integer := 0;
    
    ---------------------------------------------------------------------------------------    
    
begin
   
    -----------------------------DISPLAY COMPONENT-----------------------------------------                    
    u0: segment_display 
        port map (clk => clk, 
                  number => output_operand, 
                  minus => output_operand(n-1), 
                  seg => seg, 
                  an => an);
                  
    ----------------------------ADD COMPONENTS---------------------------------------------                        
     
    u1: add generic map (n => n) 
        port map (a => operand0, 
                  b => operand1, 
                  s => add_operand_2, 
                  c_in => add_in,
                  c_out => add_out);
                                             
    ----------------------------MULT COMPONENTS--------------------------------------------                        
    u4: multiply generic map (n => n)
        port map (a => operand0,
                  b => operand1,
                  output => mult_operand2, -- length == 2*n
                  longer_than_operand => mult_overflow); 
            
    ----------------------------DIV COMPONENTS---------------------------------------------                        
    u5: divide generic map (total => n)
        port map(clk => clk,
                 reset => div_reset,
                 start => div_start,
                 m => n_zeros & operand0, 
                 n => operand1,
                 quotient => div_operand2,
                 remainder => div_remainder,  
                 ready => div_ready,
                 ovfl => div_overflow);      
                  
    -----------------------------DEBUG OUTPUT----------------------------------------------        
    
    dubug_process: process(current_state, 
                           operand0,
                           operand1,
                           operand_2,
                           saved_operand,
                           output_operand,
                           current_operand_index)
    begin
            deb_0 <= operand0;
            deb_1 <= operand1;
            deb_2 <= operand_2;
            deb_s <= saved_operand;
            deb_output <= output_operand;
            deb_index <= current_operand_index;  
            if current_state = s0 then 
                deb_state <= 0;
            elsif current_state = s1 then
                deb_state <= 1;
            elsif current_state = s2 then
                deb_state <= 2;
            elsif current_state = sG then
                deb_state <= 3;  
            else --elsif current_state = sS then
                deb_state <= 4;
            end if;
    end process;   
             
    ---------------------------------------------------------------------------------------        
    a_sw_input_process: process (a, 
                                 operation_switches,
                                 current_state
                                 )
    begin
        if current_state = s0 then
            operand0 <= a;
        elsif current_state = s1 then
            operand1 <= a;           
            current_operation_code <= operation_switches;      
        end if;  
    end process;   
    
    ---------------------------------------------------------------------------------------
    operations_process: process (clk,
                                 current_state,
                                 current_operation_code,
                                 div_ready,
                                 div_started,
                                 add_operand_2,
                                 div_operand2,
                                 mult_operand2
                                 )   
    begin
        if rising_edge(clk) and (current_state = s2) then                                  
            if current_operation_code = code_div then
                if div_started = 0 then 
                    div_started <= 1;
                    div_start <= '1';
                    div_reset <= '1';
                else 
                    div_start <= '0';
                    div_reset <= '0';
                    if div_ready = '1' then                        
                        operand_2 <= div_operand2; 
                    end if;
                end if;
            else
                div_started <= 0; -- reset div calculations
                
                if current_operation_code = code_add then
                    operand_2 <= add_operand_2;      
                elsif current_operation_code = code_mult then                
                    operand_2 <= mult_operand2(2*n - 1) & mult_operand2(n-2 downto 0);     
                else          
                    operand_2 <= (others => '1');
                end if;
            end if;
        end if;
    end process;
         
    -----------------------------FSM OUTPUT------------------------------------------------    
    fsm_phi: process (a,
                      current_state, 
                      operand0, 
                      operand1, 
                      operand_2, 
                      saved_operand,
                      current_operand_index)
    begin
        case current_state is
            when s0 | s1 =>           
                output_operand <= a;
            when s2 =>  
                output_operand <= operand_2;
            when sg => 
                output_operand <= saved_operand;
            when ss => 
                if (current_operand_index = 0) or (current_operand_index = 1) then 
                    output_operand <= a;
                else 
                    output_operand <= operand_2;
                end if;
            when others => 
                output_operand <= operand_2;
        end case;
    end process;
    
    -----------------------------FSM STORAGE-----------------------------------------------    
    fsm_dff: process (clk,
                      next_state, 
                      reset_button)
    begin
        if reset_button = '1' then 
            current_state <= s0;
        else --elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    -----------------------------FSM TRANSITIONS------------------------------------------- 
    fsm_gamma: process (current_state, 
                        enter_button,
                        reset_button, 
                        get_button, 
                        save_button,
                        get_completed, 
                        save_completed, 
                        current_operand_index,
                        clk)
    begin
        case current_state is
            when s0 =>     
                current_operand_index <= 0;
                if rising_edge(enter_button) then
                    next_state <= s1;
                elsif rising_edge(save_button) then      
                    next_state <= sS;
                elsif rising_edge(get_button) then
                    next_state <= sG;
                end if;
            when s1 => 
                current_operand_index <= 1;
                if rising_edge(reset_button) then
                    next_state <= s0;
                elsif rising_edge(enter_button) then
                    next_state <= s2;
                elsif rising_edge(save_button) then
                    next_state <= sS;
                elsif rising_edge(get_button) then
                    next_state <= sG;
                end if;
            when s2 => 
                current_operand_index <= 2;
                if rising_edge(reset_button) then
                    next_state <= s0;
                elsif rising_edge(save_button) then
                    next_state <= sS;
                end if;                
            when ss => 
                if rising_edge(clk) and (save_completed = '1') then 
                    if current_operand_index = 0 then -- integer
                        next_state <= s0;
                    elsif current_operand_index = 1 then
                        next_state <= s1;
                    else -- current_operand_index = 2
                        next_state <= s2;
                    end if;
                    save_completed <= '0';
                end if;
            when sg => 
                if rising_edge(clk) and (get_completed = '1') then 
                    if current_operand_index = 0 then 
                        next_state <= s1;
                    else -- current_operand_index == 2 || current_operand_index == 1 
                        next_state <= s2;
                    end if;
                    get_completed <= '0';
                end if;
            when others => 
                next_state <= s0;
        end case;
    end process;
 
end behavioral;
