-------------------------------------------------------------------------
--
--  R8 PROCESSOR   -  GOLD VERSION  -  02/MAR/2013
--
--  moraes - 30/09/2001  - project start
--  moraes - 22/11/2001  - instruction decoding bug correction
--  moraes - 22/03/2002  - store instruction correction            
--  moraes - 05/04/2003  - SIDLE state inclusion in the control unit
--  calazans - 02/05/2003  - translation of comments to English. Names of
--    some signals, entities, etc have been changed accordingly
--  carara - 03/2013 - project split in several files. Each entity is described in a file with the same name.
--
--  Notes: 1) In this version, the register bank is designed using 
--    for-generate VHDL construction
--         2) The top-level R8 entity is
--
--      entity R8 is
--            port( clk,rst: in std_logic;
--                  data_in:  in  std_logic_vector(15 downto 0);    -- Data from memory
--                  data_out: out std_logic_vector(15 downto 0);    -- Data to memory
--                  address: out std_logic_vector(15 downto 0);     -- Address to memory
--                  ce,rw: out std_logic );                         -- Memory control
--      end R8;
-- 
-------------------------------------------------------------------------



-------------------------------------------------------------------------
-- Design unit: R8
-- Description: Top-level instantiation of the R8 data and control paths
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.R8_pkg.all;

entity R8 is
    generic(
        INTR_HND_ADDR  : std_logic_vector(15 downto 0) := x"0000"
    );
    port( 
        clk     : in std_logic;
        rst     : in std_logic;
        -- Interruption Request
        intr    : in std_logic;
        
        -- Memory interface
        data_in : in std_logic_vector(15 downto 0);
        data_out: out std_logic_vector(15 downto 0);
        address : out std_logic_vector(15 downto 0);
        ce      : out std_logic;
        rw      : out std_logic 
    );
end R8;

architecture structural of R8 is   

    signal flag: std_logic_vector(3 downto 0);
    signal uins: Microinstruction;
    signal instruction: std_logic_vector(15 downto 0);
    signal intr_status_signal : std_logic;
    signal currentSintr_s : std_logic;

begin   
  
    DATA_PATH: entity work.DataPath 
        port map(
            uins            => uins, 
            clk             => clk,
            rst             => rst,
            instruction     => instruction,
            address         => address,
            data_in         => data_in, 
            data_out        => data_out, 
            flag            => flag,
            intr_addr       => INTR_HND_ADDR,
            intr_status     => intr_status_signal,
            intr            => intr,
            currentSintr    => currentSintr_s
        );

    CONTROL_PATH: entity work.ControlPath 
        port map(
            uins                => uins, 
            clk                 => clk, 
            rst                 => rst, 
            flag                => flag, 
            ir                  => instruction,
            intr                => intr,
            intr_status         => intr_status_signal,
            currentSintr        => currentSintr_s
        );

    -- Memory signals
    ce <= uins.ce;
    rw <= uins.rw;

end structural;