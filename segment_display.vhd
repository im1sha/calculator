library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity segment_display is
	port ( 
		clk : in std_logic;
		number : in  std_logic_vector(7 downto 0);
		minus : in std_logic;
		seg : out std_logic_vector(6 downto 0);
		an : out std_logic_vector(7 downto 0));
	
end segment_display;

architecture behavioral of segment_display is
	signal counter: std_logic_vector(12 downto 0) := (others => '0');
	signal currentnumber: std_logic_vector(4 downto 0);
	signal segnum: std_logic_vector(6 downto 0);
	signal intan: std_logic_vector(7 downto 0);
begin
	an <= intan;
	seg <= segnum;
	
	clockdivider: process(clk)
	begin
		if rising_edge(clk) then
			counter <= counter + '1';		
		end if;
	end process;
	
	numberposition: process(counter, number, minus)
	begin
		case counter(12 downto 10) is
			when "001" => 
				currentnumber <= "0" & number(3 downto 0);
			when "010" => currentnumber <= "0" & number(7 downto 4);
			when "011" => currentnumber <= minus & "0000";
			when others => currentnumber <= "11111";
		end case;
	end process;
	
	encodenumber: process(currentnumber)
		constant codeminus : std_logic_vector(6 downto 0) := "1111110";
		constant codezero : std_logic_vector(6 downto 0)  := "0000001";
		constant codeone : std_logic_vector(6 downto 0)   := "1001111";
		constant codetwo : std_logic_vector(6 downto 0)   := "0010010";
		constant codethree : std_logic_vector(6 downto 0) := "0000110";
		constant codefour : std_logic_vector(6 downto 0)  := "1001100";
		constant codefive : std_logic_vector(6 downto 0)  := "0100100";
		constant codesix : std_logic_vector(6 downto 0)   := "0100001";
		constant codeseven : std_logic_vector(6 downto 0) := "0001111";
		constant codeeight : std_logic_vector(6 downto 0) := "0000000";
		constant codenine : std_logic_vector(6 downto 0)  := "0000100";
		constant codea : std_logic_vector(6 downto 0)     := "0000010";
		constant codeb : std_logic_vector(6 downto 0)     := "1100000";
		constant codec : std_logic_vector(6 downto 0)     := "0110001";
		constant coded : std_logic_vector(6 downto 0)     := "1000010";
		constant codee : std_logic_vector(6 downto 0)     := "0110000";
		constant codef : std_logic_vector(6 downto 0)     := "0111000";
		constant codenone : std_logic_vector(6 downto 0)  := "1111111";
	begin
		case currentnumber is
			when "00000" => segnum <= codezero;
			when "00001" => segnum <= codeone;
			when "00010" => segnum <= codetwo;
			when "00011" => segnum <= codethree;
			when "00100" => segnum <= codefour;
			when "00101" => segnum <= codefive;
			when "00110" => segnum <= codesix;
			when "00111" => segnum <= codeseven;
			when "01000" => segnum <= codeeight;
			when "01001" => segnum <= codenine;
			when "01010" => segnum <= codea;
			when "01011" => segnum <= codeb;
			when "01100" => segnum <= codec;
			when "01101" => segnum <= coded;
			when "01110" => segnum <= codee;
			when "01111" => segnum <= codef;
			when "10000" => segnum <= codeminus;
			when others => segnum <= codenone;
		end case;
	end process;
	
	with counter(12 downto 10) select  
		intan <=
			"11111110" when "001",
			"11111101" when "010",
			"11111011" when "011",
			"11111111" when others;
end behavioral;