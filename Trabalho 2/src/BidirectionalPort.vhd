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
		clk         : in std_logic;
		rst	        : in std_logic; 
		-- Processor interface
		data        : inout std_logic_vector (DATA_WIDTH-1 downto 0);
		address     : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
		ce          : in std_logic;
		rw          : in std_logic;
		-- "World" interface
		port_io     : inout std_logic_vector (DATA_WIDTH-1 downto 0)
	);
end BidirectionalPort;

architecture Behavioral of BidirectionalPort  is
	-- Configuration register
	signal port_config 		: std_logic_vector(DATA_WIDTH-1 downto 0);
	-- Output data register
	signal port_out 	 	: std_logic_vector(DATA_WIDTH-1 downto 0);

	-- Intermediate Signals
	signal port_config_s, port_out_s 	: std_logic_vector(DATA_WIDTH-1 downto 0);

	begin

		for i in DATA_WIDTH-1 to 0 generate
			port_io(i) 	<= port_out(i) when port_config(i) = '0' else 'Z';
		end generate;
	
		process(clk, rst)
		begin
			if rst = '1' then
				port_config 	<= x"FFFF";
				port_out    	<= x"0000";
			elsif rising_edge(clk) then
				if ce = '1' then
					for i in DATA_WIDTH-1 downto 0 loop
						if address = DATA_DIRECTION_ADDR and rw = '0' then
							port_config_s(i) <= data(i);
						elsif address = DATA_DIRECTION_ADDR and rw = '1' then
							data(i) <= port_config_s(i);
						
						elsif address = OUTPUT_DATA_ADDR and rw = '0' then
							port_out_s(i) <= data(i);
						elsif address = OUTPUT_DATA_ADDR and rw = '1' then
							 data(i) <= port_out_s(i);

						elsif address = INPUT_DATA_ADDR and rw = '1' then
							data(i) <= port_io(i);     
						elsif address = INPUT_DATA_ADDR and rw = '0' then
							data(i) <= 'Z';

						else
							data(i) <= 'Z';
						end if;
					end loop;
				else
					data <= (others => 'Z');
				end if;
			end if;
		end process;

		-- rw = 0 -> write
		-- rw = 1 -> read

end Behavioral;
