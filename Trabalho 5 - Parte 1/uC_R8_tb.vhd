-------------------------------------------------------------------------
-- Design unit: 
-- Description:              
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;        

entity uC_R8_tb is
end uC_R8_tb;

architecture behavioral of uC_R8_tb is      
  signal clk                      	: std_logic := '0';  
  signal rst           				: std_logic;
  signal port_a, port_b 		  	: std_logic_vector(15 downto 0);

begin

    MICROCONTROLADOR: entity work.uc_R8
      port map (
        clk         => clk, 
        rst         => rst,
        port_a      => port_a,
        port_b      => port_b,
       	time_out 	=> port_a(13)
      );

    SYNTHESIZER: entity work.SpeechSynthesizer
      generic map(
        PROCESSING_TIME => 30 us
      )
      port map(
        rst   => rst,
        A     => port_a(7 downto 0),
        SBY   => port_a(15),
        ALD   => port_a(9)
      );

    INPUT_PERIPHERAL: entity work.InputPeripheral
      generic map(
        INTERVAL => 15 us
      )
      port map(
        data      => port_b,
        data_av   => port_a(14),  -- interruption
        data_ack  => port_a(11)
      );

    -- Generates the clock signal            
    clk <= not clk after 10 ns;

    -- Generates the reset signal
    rst <= '1', '0' after 5 ns; 
    
end behavioral;
