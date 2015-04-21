-------------------------------------------------------------------------
-- Design unit: Speech Sythesizer
-- Description: Behavioral emulation of the processor interface 
--      based on Digital Design and Computer Architecture by David Money Harris (pp.497)
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity SpeechSynthesizer is
    generic (
        PROCESSING_TIME : time := 1000 ns
    );
    port( 
        rst     : in std_logic;
        
        A       : in std_logic_vector(7 downto 0);
        SBY     : out std_logic;
        ALD     : in std_logic
    );
end SpeechSynthesizer;

architecture structural of SpeechSynthesizer is

    signal allophone : std_logic_vector(7 downto 0);

begin

    process
    begin
        
        SBY <= '1';
        allophone <= (others=>'0');
        
        -- Blocks here until reset is released
        wait until rst = '0';
        
        
        while true loop
            --wait until (ALD'event and ALD = '1');
            wait until rising_edge(ALD);
            allophone <= A;
            SBY <= '0';
        
            -- Emulates the time to produce the sound corresponding to the stored allophone
            wait for PROCESSING_TIME;
            SBY <= '1';
        end loop;
        
    end process;
  
   
end structural;