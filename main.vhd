library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

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
           deb_divop2 : out std_logic_vector(n-1 downto 0);
           deb_index: out integer;
           deb_state: out integer;
           deb_output: out std_logic_vector(n-1 downto 0);
           deb_ready : out std_logic
           ); -- debug output
end main;

architecture behavioral of main is

    constant n_div_2 : integer := 4;
    constant n_zeros : std_logic_vector(n-1 downto 0) := (others => '0');
    constant n_ones : std_logic_vector(n-1 downto 0) := (others => '1');

    -----------------------------components------------------------------------------------

	 component code_converter 
			 generic (n : integer);
			 port ( sign : in  std_logic;
					  in_vector : in  std_logic_vector (n-1 downto 0);
					  out_vector : out  std_logic_vector (n-1 downto 0));
	 end component;
	 
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
       
    component divide_wrapper is
        generic (total: integer);
        port (clk : in std_logic;
              go: in std_logic;
              m : in  std_logic_vector (total*2-1 downto 0);     
              n : in  std_logic_vector (total-1 downto 0);    
              quotient : out  std_logic_vector (total-1 downto 0);  
              remainder : out  std_logic_vector (total-1 downto 0);    
              ready : out std_logic;
              ovfl :out std_logic);  
    end component;
	 
	 component sync_register is
		generic ( n: integer);
		port ( din : in  std_logic_vector (n-1 downto 0);
           ce : in  std_logic;
           c : in  std_logic;
           dout : out  std_logic_vector (n-1 downto 0));	
	end component;
    
    -----------------------------operations-----------------------------------------------
    constant code_add : std_logic_vector (1 downto 0) := "00";
    constant code_div : std_logic_vector (1 downto 0) := "10";
    constant code_mult : std_logic_vector (1 downto 0) := "11";
      
    signal current_operation_code : std_logic_vector (1 downto 0) := (others => '0');
    -----------------------------states----------------------------------------------------
    type states is (s0, s1, s2, sg, ss);
    
    signal current_state, 
           next_state: states := s0;
           
    signal current_operand_index : integer := 0; -- use with save button only
    signal get_completed, save_completed : std_logic := '0'; -- synchronization flags
         
    -----------------------------operands--------------------------------------------------
    signal operand_2, -- result                    
           saved_operand : std_logic_vector (n-1 downto 0) := (others => '0');
            
    signal operand0,
           operand1,           
           output_operand,
			  additional_code_operand-- displayed value
                : std_logic_vector (n-1 downto 0) := (others => '0');
                
    ----------------------------add diff---------------------------------------------------                  
    signal add_operand_2: std_logic_vector (n-1 downto 0);   
    constant add_in: std_logic := '0';
    signal add_out: std_logic; 
    
    -----------------------------mult------------------------------------------------------  
    signal mult_operand_2: std_logic_vector (2*n-1 downto 0);
    signal mult_overflow: std_logic;  

    -----------------------------div-------------------------------------------------------  
    signal div_operand_2: std_logic_vector (n-1 downto 0); -- result  
   -- signal div_operand_2_copy: std_logic_vector (n-1 downto 0); -- result  
    signal div_remainder: std_logic_vector (n-1 downto 0);  
    signal div_go: std_logic := '0';   
    signal div_ready: std_logic := '0';  
    signal div_overflow: std_logic;  
    ----------------------------save-------------------------------------------------------
	 
	 signal not_saved_operand : std_logic_vector (n-1 downto 0);
	 signal save_enable :  std_logic := '0';
    ---------------------------------------------------------------------------------------    
    
	 signal deb_count : std_logic_vector (n-1 downto 0) := (others => '0');
begin
   
    -----------------------------display component-----------------------------------------                    
    u0: segment_display 
        port map (clk => clk, 
                  number => '0' & additional_code_operand(n-2 downto 0), 
                  minus => additional_code_operand(n-1), --output_operand(n-1), 
                  seg => seg, 
                  an => an);
						
    u7: code_converter generic map (n => n)
		  port map ( sign => '0', --output_operand(n-1),
					  in_vector => output_operand,
					  out_vector => additional_code_operand); 
					  
    ----------------------------add components---------------------------------------------                        
     
    u1: add generic map (n => n) 
        port map (a => operand0, 
                  b => operand1, 
                  s => add_operand_2, 
                  c_in => add_in,
                  c_out => add_out);


    
						
    ----------------------------mult components--------------------------------------------                        
    u4: multiply generic map (n => n)
        port map (a => operand0,
                  b => operand1,
                  output => mult_operand_2, -- length == 2*n
                  longer_than_operand => mult_overflow); 
            
    ----------------------------div components---------------------------------------------                        
    u5: divide_wrapper generic map (total => n)
        port map(clk => clk,
                 go => div_go,
                 m => n_zeros & operand0, 
                 n => operand1,
                 quotient => div_operand_2,
                 remainder => div_remainder,  
                 ready => div_ready,
                 ovfl => div_overflow);   

	----------------------------div components---------------------------------------------
	u6: sync_register generic map (n => n)
		 port map ( din => not_saved_operand,
						ce => save_enable,
						c => clk,
						dout => saved_operand);
						
						
						
                  
    -----------------------------debug output----------------------------------------------        
    
    dubug_process: process(current_state, 
                           operand0,
                           operand1,
                           operand_2,
                           saved_operand,
                           output_operand,
                           current_operand_index,
                           div_ready,
                           div_operand_2)
    begin
            deb_divop2 <= div_operand_2;
            deb_ready <= div_ready;
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
            elsif current_state = sg then
                deb_state <= 3;  
            else --elsif current_state = ss then
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
                                 add_operand_2,
                                 div_operand_2,
                                 mult_operand_2,
                                 operand0,
                                 operand1
                                 )   
    begin          
        if (current_state = s2) then                                  
            if (current_operation_code = code_div) then
             --   if (div_ready = '1') then      
             --       operand_2 <= div_operand_2;
             --   else
             --       div_go <= '1';  
             --   end if;
                if operand1 /= n_zeros then     
                    operand_2 <= std_logic_vector(signed(operand0) / signed(operand1));
                else
                    operand_2 <= (others => '1');
                end if;
            else
        --        div_go <= '0';
                if current_operation_code = code_add then
                    operand_2 <= add_operand_2;      
                elsif current_operation_code = code_mult then                
                    operand_2 <= mult_operand_2(2*n - 1) & mult_operand_2(n-2 downto 0);     
                else          
                    operand_2 <= (others => '1');
                end if;
            end if;
        --else 
        --    div_go <= '0';       
        end if;
    end process;
    -----------------------------save_process----------------------------------------------
	 save_process : process (save_button, save_enable)
	 begin
		if save_button = '1' then
			save_enable <= '1';
		else
			save_enable <= '0';
		end if;
	 end process;
	 
	 process (save_enable, current_state, operand0, operand1, operand_2)
	 begin
		if rising_edge(save_enable) then
			if current_state = s0 then
				not_saved_operand <= operand0;
			elsif current_state = s1 then
				not_saved_operand <= operand1;
			elsif current_state = s2 then
				not_saved_operand <= operand_2;
			end if;
		end if;
	 end process;
	
    -----------------------------fsm output------------------------------------------------    
    fsm_phi: process (a,
                      current_state, 
                      operand0, 
                      operand1, 
                      operand_2, 
                      saved_operand,
                      current_operand_index,
							 
							 
							 
							 enter_button, deb_count)
    begin
		if rising_edge(enter_button) then 
			deb_count <= deb_count + 1 ;
		end if;	
		output_operand <= deb_count;
		
--        case current_state is
--            when s0 | s1 =>           
--                output_operand <= a;
--            when s2 =>  
--                output_operand <= operand_2;
--            when sg => 
--                output_operand <= saved_operand;
--					 
--            when ss => 
--                if (current_operand_index = 0) or (current_operand_index = 1) then 
--                    output_operand <= a;
--                else 
--                    output_operand <= operand_2;
--                end if;
--            when others => 
--                output_operand <= operand_2;
--        end case;

    end process;
    
    -----------------------------fsm storage-----------------------------------------------    
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
    
    -----------------------------fsm transitions------------------------------------------- 
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
                    next_state <= ss;
                elsif rising_edge(get_button) then
                    next_state <= sg;
                end if;
            when s1 => 
                current_operand_index <= 1;
                if rising_edge(reset_button) then
                    next_state <= s0;
                elsif rising_edge(enter_button) then
                    next_state <= s2;
                elsif rising_edge(save_button) then
                    next_state <= ss;
                elsif rising_edge(get_button) then
                    next_state <= sg;
                end if;
            when s2 => 
                current_operand_index <= 2;
                if rising_edge(reset_button) then
                    next_state <= s0;
                elsif rising_edge(save_button) then
                    next_state <= ss;
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
