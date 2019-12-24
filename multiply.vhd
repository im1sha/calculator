library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity multiply is
    generic (n : integer := 8);
    port ( a : in std_logic_vector ((n-1) downto 0);
           b : in std_logic_vector ((n-1) downto 0);
           output : out std_logic_vector ((2*n-1) downto 0);
           longer_than_operand : out std_logic); -- output value has length which is less than n
end multiply;

architecture behavioral of multiply is
    constant n_without1_zeros : std_logic_vector (n-2 downto 0) := (others => '0');
    constant n_without1_ones : std_logic_vector (n-2 downto 0) := (others => '0');
    signal fit : std_logic;
    signal first_sign, second_sign : std_logic ;
    signal first_number, second_number : std_logic_vector (n-2 downto 0);
    signal pre_result : std_logic_vector (2*n-3 downto 0) := (others => '0');
    signal result : std_logic_vector (2*n-1 downto 0) := (others => '0');
begin
    main : process (a, b, first_number, second_number, pre_result, fit)
    begin
        for i in 0 to n-2 loop
            first_number(i) <= a(i);
            second_number(i) <= b(i);
        end loop;
        first_sign <= a(n-1);
        second_sign <= b(n-1);
        pre_result <= first_number * second_number;
        
        if (pre_result and (n_without1_zeros & n_without1_ones)) /= pre_result then
           fit <= '1';
        else    
           fit <= '0';
        end if;
        
        if first_sign = second_sign then 
            result(2*n-1) <= '0';
        else
            result(2*n-1) <= '1';
        end if;
        for i in 0 to 2*n-3 loop
            result(i) <= pre_result(i);
        end loop;
        result(2*n-2) <= '0';        
    end process;
    
    longer_than_operand <= fit;
    output <= result;
end behavioral;
