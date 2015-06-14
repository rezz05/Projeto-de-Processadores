-----------------------------------------------------------------------------
-- DESIGN UNIT  : Timer                                       --
-- DESCRIPTION  :  --
--              :                     --
-- AUTHOR       : Everton Alceu Carara                                     --
-- CREATED      : February, 2014                                          --
-- VERSION      : 1.0                                                      --
-- HISTORY      : Version 1.0 - January, 2014 - Everton Alceu Carara     --
--------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Timer  is
	generic (
		COUNT_WIDTH  : integer := 16    -- Port width in bits
    );
	port (  
		clk         : in std_logic;
		rst	        : in std_logic; 
		data_in     : in std_logic_vector (COUNT_WIDTH-1 downto 0);
        load        : in std_logic;     -- Write enable
        time_out    : out std_logic
	);
end Timer ;


architecture Behavioral of Timer  is

    signal count        : std_logic_vector (COUNT_WIDTH-1 downto 0);
    signal loaded       : boolean;

begin

    process(clk, rst)
	begin
		if rst = '1' then
			count <= (others=>'0');
            time_out <= '0';
            loaded <= false;
		
		elsif rising_edge(clk) then
            if count > 0 and loaded then 
                count <= count - 1;              
            
            elsif count = 0 and loaded then
                time_out <= '1';
                loaded <= false;
            end if;
            
            if load = '1' then
                count <= data_in;
                loaded <= true;
                time_out <= '0';
            end if;
		end if;
	end process;
        
        
end Behavioral;