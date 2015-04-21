library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity BidirectionalPort is
	generic (
		DATA_WIDTH			: integer := 16;					-- Port width in bits
		ADDRESS_WIDTH 		: integer := 16;					-- Address bus width in bits
		DATA_DIRECTION_ADDR	: std_logic_vector(15 downto 0);	-- I/O bits configuration register address
		OUTPUT_DATA_ADDR    : std_logic_vector(15 downto 0);	-- Data output register address
		INPUT_DATA_ADDR     : std_logic_vector(15 downto 0)		-- Read data address
	);
	port (  
		clk         	: in std_logic;
		rst	        	: in std_logic; 
		-- Processor interface
		data        	: inout std_logic_vector (DATA_WIDTH-1 downto 0);
		address     	: in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
		ce          	: in std_logic;
		rw          	: in std_logic;
		-- "World" interface
		irq_a, irq_b	: out std_logic;
		port_io     	: inout std_logic_vector (DATA_WIDTH-1 downto 0)
	);
end BidirectionalPort;

architecture Behavioral of BidirectionalPort  is
	-- Configuration register
	signal port_config 		: std_logic_vector(DATA_WIDTH-1 downto 0);
	-- Output data register
	signal port_out 	 	: std_logic_vector(DATA_WIDTH-1 downto 0);

	begin	
		process(clk, rst)
		begin
			if rst = '1' then
				port_config 	<= x"FFFF";
				port_out    	<= x"0000";
			elsif rising_edge(clk) then
				if ce = '1' then
					if address = DATA_DIRECTION_ADDR and rw = '0' then
						port_config <= data;					
					elsif address = OUTPUT_DATA_ADDR and rw = '0' then
						port_out <= data;
					end if;
				end if;
			end if;
		end process;

		data <= port_config when address = DATA_DIRECTION_ADDR and rw = '1' else
				port_out 	when address = OUTPUT_DATA_ADDR and rw = '1' else
				port_io 	when address = INPUT_DATA_ADDR and rw = '1' else
				(others => 'Z');

		output: for i in DATA_WIDTH-1 downto 0 generate
			port_io(i) 	<= port_out(i) when port_config(i) = '0' else 'Z';
		end generate;

		irq_a <= port_io(15) when port_config(15) = '1' else '0';
		irq_b <= port_io(14) when port_config(14) = '1' else '0';

		-- rw = 0 -> write
		-- rw = 1 -> read

end Behavioral;
