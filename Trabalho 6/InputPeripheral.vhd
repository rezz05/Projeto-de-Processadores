-------------------------------------------------------------------------
-- Design unit: Input Peripheral
-- Description: Produces data at each time interval
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity InputPeripheral is
    generic (
        INTERVAL    : time := 15 us;
        COUNTER     : integer := 20
    );
    port(         
        data        : out std_logic_vector(15 downto 0);
        data_av     : out std_logic;
        data_ack    : in std_logic
    );
end InputPeripheral;

architecture structural of InputPeripheral is
begin

    process
        variable x: std_logic_vector(15 downto 0);
    begin
        
        data_av <= '0';
        data <= (others=> 'U');
        x := x"1234";
        
        for i in 0 to COUNTER-1 loop
            wait for INTERVAL;
            data_av <= '1';
            data <= x;
        
            wait until rising_edge(data_ack);
            data_av <= '0';
            data <= (others=> 'U');
            x := x + 1;
        end loop;
        
        wait;
        
    end process;
  
   
end structural;