------------------------------------------------------------------------------
-- DESIGN UNIT  : Interrupt controller                                      --
-- DESCRIPTION  :                                                           --
--              :                                                           --
-- AUTHOR       : Everton Alceu Carara                                      --
-- CREATED      : February, 2014                                            --
-- VERSION      : 1.0                                                       --
-- HISTORY      : Version 1.0 - February, 2014 - Everton Alceu Carara       --
--                Version 1.1 - February, 2015 - Everton Alceu Carara       --
--                  - When acking the PIC, processor indicates, through     --
--                  data bus, the handled interrupt ID                      --
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity InterruptController  is
	generic (
        ADDRESS_WIDTH   : integer := 16;    -- Address bus width in bits
        IRQ_ID_ADDR     : std_logic_vector(15 downto 0);          
        INT_ACK_ADDR    : std_logic_vector(15 downto 0);          -- Interrupt acknowledgement address
        MASK_ADDR       : std_logic_vector(15 downto 0)           -- Mask register address
    );
	port (  
		clk         : in std_logic;
		rst	        : in std_logic; 
        data        : inout std_logic_vector (7 downto 0);
        address     : in std_logic_vector (ADDRESS_WIDTH-1 downto 0);
        rw          : in std_logic;
        ce          : in std_logic;
        intr        : out std_logic;
        irq         : in std_logic_vector (7 downto 0) -- Interrupt request
	);
end InterruptController ;


architecture Behavioral of InterruptController  is

    signal pendingRequests  : std_logic_vector (7 downto 0);    -- Interrupt request register
    signal mask             : std_logic_vector (7 downto 0);    -- IMR: interrupt mask register
    signal maskedReq        : std_logic_vector (7 downto 0);
    signal highPriorityReq  : std_logic_vector(2 downto 0);
    signal idle             : std_logic;
   
begin
    -----------------------------------------
    -- Set/Reset the interruption requests --
    -----------------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            pendingRequests <= (others=>'0');
            
        elsif rising_edge(clk) then
            for i in irq'reverse_range loop
                if irq(i) = '1' then
                    pendingRequests(i) <= '1';
                end if; 
            end loop;
                
            -- IRQ reset (on processor acknowledgement)
            if address = INT_ACK_ADDR and ce = '1' and rw = '0' then
                pendingRequests(TO_INTEGER(UNSIGNED(data))) <= '0';
            end if;
        
        end if;
    end process;
    
    --------------------------------
    -- Interruption mask register --
    --------------------------------
    process(clk, rst)
    begin
        if rst = '1' then
            mask <= (others=>'0');
        elsif rising_edge(clk) then
            if address = MASK_ADDR and ce = '1' and rw = '0' then
                mask <= data;
            end if;
        end if;
    end process;
    
    -- Interruption masking
    maskedReq <= pendingRequests and mask;
    
    PRIORITY_ENCODER: entity work.PriorityEncoder 
        port map (
            requests    => maskedReq,
            reqID       => highPriorityReq,
            idle        => idle
        );
        
    intr <= not idle;
    
    data <= "00000" & highPriorityReq when address = IRQ_ID_ADDR and ce = '1' and rw = '1' else
            mask when address = MASK_ADDR and ce = '1' and rw = '1' else
            (others=>'Z');
        
end Behavioral;