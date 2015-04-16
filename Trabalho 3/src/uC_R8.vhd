-------------------------------------------------------------------------
-- Design unit: uC R8
-- Description: Comprised of the usual R8 processor, a memory and two
--              configurable IO ports.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;       
use work.R8_pkg.all;

entity uC_R8 is
    port (
        clk     : in std_logic;
        rst     : in std_logic;
        port_a  : inout std_logic_vector(15 downto 0);
        port_b  : inout std_logic_vector(15 downto 0)
    );
end uC_R8;

architecture structural of uC_R8 is
  signal ce, ce_n, ce_p, we_n, oe_n, rw, irq : std_logic;
	signal dataBus, dataR8, addressR8, address, port_io: std_logic_vector(15 downto 0);
begin
  
  R8: entity work.R8
    generic map(
      INTR_HND_ADDR => x"000C"
    )
    port map(
      clk       => clk,
      rst       => rst,
      data_in   => dataBus,
      data_out  => dataR8,
      address   => addressR8,
      ce        => ce,
      rw        => rw,
      intr      => irq
    );
    
  MEM: entity work.Memory
    generic map(
      SIZE          => 1024,      -- 1024 words (2KB)
      imageFileName => "BSort_Intr.txt"
    )
    port map(
      clk       => clk,
      ce_n      => ce_n,
      we_n      => we_n,
      oe_n      => oe_n,
      address   => addressR8,
      data      => dataBus
    );
    
  BIPORT_A: entity work.BidirectionalPort
		generic map(
			DATA_DIRECTION_ADDR => x"FFF0",
			OUTPUT_DATA_ADDR		=> x"FFF1",
			INPUT_DATA_ADDR			=> x"FFF2"
		)
    port map(
      clk         => clk,
      rst         => rst,
      data        => dataBus,
      address     => addressR8,
      ce          => ce_p,
      rw          => rw,
      port_io     => port_a,
      irq         => irq
    );
    
  BIPORT_B: entity work.BidirectionalPort
		generic map(
			DATA_DIRECTION_ADDR => x"FFF3",
			OUTPUT_DATA_ADDR		=> x"FFF4",
			INPUT_DATA_ADDR			=> x"FFF5"
		)
    port map(
      clk       => clk,
      rst       => rst,
      data      => dataBus,
      address   => addressR8,
      ce        => ce_p,
      rw        => rw,
      port_io   => port_b
    );


	-- Memory management (disables memory when accessing peripherals)
  --	ce_n <= ce when addressR8 < x"FFF0" else '0';
  ce_p <= ce when addressR8 > x"FFEF" else '0';
  
  -- Memory access control signals       
  ce_n <= '0' when (ce = '1' or addressR8 > x"FFEF") else '1';
  oe_n <= '0' when (ce = '1' and rw = '1') else '1';       
  we_n <= '0' when (ce = '1' and rw = '0') else '1';    
        
  dataBus <= dataR8 when ce = '1' and rw = '0' else     -- Writing access
             (others => 'Z');
    
end structural;
			
