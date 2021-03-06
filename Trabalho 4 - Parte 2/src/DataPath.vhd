-------------------------------------------------------------------------
-- Design unit: Data path
-- Description: R8 structural data path.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.R8_pkg.all;
   
entity DataPath is
    port( 
        clk         : in std_logic;
        rst         : in std_logic;
        
        -- Memory interface
        address     : out std_logic_vector(15 downto 0);
        data_in     : in  std_logic_vector(15 downto 0);
        data_out    : out std_logic_vector(15 downto 0);
        
        -- Control path interface
        uins            : in Microinstruction;
        instruction     : out std_logic_vector(15 downto 0);
        flag            : out std_logic_vector(3 downto 0);
        intr            : in std_logic;
        DOut_control    : in std_logic_vector(1 downto 0)
    );
end DataPath;

architecture DataPath of DataPath is

    -- Data path registers output
    signal pc, sp, ir, rA, rB, ralu : std_logic_vector(15 downto 0);
    
    -- Data path multiplexers output
    signal dtReg, dtPC, dtSP, opA, opB : std_logic_vector(15 downto 0);
    
    -- ALU flags
    signal carryFlag, negativeFlag, zeroFlag, overflowFlag: std_logic;
    
    -- Register file and ALU outputs
    signal s1, s2, outALU: std_logic_vector(15 downto 0);

    signal flags_out, intr_addr : std_logic_vector(15 downto 0);
    
begin
    
    ----------------------------------------------------------------------------------------------------------
    -- Data path stages
    --      First stage : instruction fetch (common to all instructions)
    --      Second stage: instruction decode and operands fetch (common to all instructions)
    --      Third stage : ALU operation (common to all instructions, except for HALT and NOP)
    --      Fouth stage : instruction execution. (depends on the specific type of operation, may not exist)
    ----------------------------------------------------------------------------------------------------------
    
    
    --==============================================================================
    -- First stage components
    --==============================================================================
    
    -- Instruction register
    INSTRUCTION_REGISTER: entity work.RegisterNbits
        generic map (
            WIDTH   => 16
        )
        port map (
            clk     => clk, 
            rst     => rst, 
            ce      => uins.wIR,   
            d       => data_in, 
            q       => ir 
        );
        
    -- Sends the current instruction to control path
    instruction <= ir;
    
  
   
   
   --==============================================================================
    -- Second stage components
    --==============================================================================
        
    -- Register file writing contents selection    
    dtReg <= data_in when uins.mRegs = '1' else ralu; -- MUX connected to the registers file 'inREG' input
                
    -- Registers bank
    REGISTER_FILE: entity work.RegisterFile
        port map( 
            clk     => clk,
            rst     => rst, 
            wReg    => uins.wReg, 
            mS2     => uins.mS2,
            ir      => ir, 
            inREG   => dtReg, 
            source1 => s1, 
            source2 => s2
        );
        
     -- RA register
     REGISTER_A: entity work.RegisterNbits
        generic map (
            WIDTH   => 16
        )
        port map(
            clk     => clk, 
            rst     => rst, 
            ce      => uins.wAB,   
            d       => s1,     
            q       => rA 
        );
     
     -- RB register
    REGISTER_B: entity work.RegisterNbits
        generic map (
            WIDTH   => 16
        )
        port map(
            clk     => clk, 
            rst     => rst, 
            ce      => uins.wAB,   
            d       => s2,     
            q       => rB 
        );
        
        
        
    --==============================================================================
    -- Third stage components
    --==============================================================================
    
    -- Selects the A operand for the ALU    
    opA <= ir when uins.ma = '1' else ra;   -- MUX connected to the ALU 'A' input    
      
    -- Selects the B operand for the ALU, or memory
    opB <=  sp when uins.mb = "01" else     -- MUX connected to the ALU 'B' input   
            pc when uins.mb = "10" else 
            rb;
         
    -- ALU: operation depends only on the current instruction (decoded in the control path)
    ALU: entity work.ALU 
        port map (
            A           => opA,
            B           => opB,
            operation   => uins.inst,
            result      => outALU,
            n           => negativeFlag,
            z           => zeroFlag,
            c           => carryFlag,
            v           => overflowFlag            
        );
         
    
    -- Status flags register (n, z, c, v) depends on the ALU output
    process (clk, rst)
    begin
        if rst = '1' then
            flags_out <= (others =>'0');
        
        elsif rising_edge(clk) then
            if DOut_control = "11" then
                flags_out <= data_in;
            else
                if uins.wnz = '1' then
                    flags_out(0) <= negativeFlag;
                    flags_out(1) <= zeroFlag;  
                end if;
            
                if uins.wcv = '1' then
                    flags_out(2) <= carryFlag;      
                    flags_out(3) <= overflowFlag;   
                end if;
            end if;
             
        end if;
    end process;

    flag(0) <= flags_out(0);
    flag(1) <= flags_out(1);
    flag(2) <= flags_out(2);
    flag(3) <= flags_out(3);
    
    
    -- RALU register
    REGISTER_RALU: entity work.RegisterNbits
        generic map (
            WIDTH   => 16
        )
        port map(
            clk     => clk, 
            rst     => rst, 
            ce      => uins.wRalu,  
            d       => outALU, 
            q       => ralu 
        );
        
        
        
    
    --==============================================================================
    -- Fourth stage components
    --==============================================================================
    
    -- Operand selection for PC register.
    dtPC <= ralu        when uins.mPC = "01" else    -- MUX connected to the PC register input       
            data_in     when uins.mPC = "00" else
            intr_addr   when uins.mPC = "11" else
            pc + 1; -- by default the PC is incremented;
    
    
    -- Operand selection for SP register
    dtSP <= sp-1 when uins.mSP = '1' else ralu; -- MUX connected to the SP register input   
    
    -- PC register
    PROGRAM_COUNTER_REGISTER: entity work.RegisterNbits
        generic map (
            WIDTH   => 16
        )
        port map(
            clk     => clk, 
            rst     => rst, 
            ce      => uins.wPC,   
            d       => dtPC,   
            q       => pc 
        );
                                                                                           
    -- Stack pointer register
    STACK_POINTER_REGISTER: entity work.RegisterNbits
        generic map (
            WIDTH   => 16
        )
        port map(
            clk     => clk, 
            rst     => rst, 
            ce      => uins.wSP,   
            d       => dtSP,   
            q       => sp
        );

    -- Interruption Handler Address
    INTA: entity work.RegisterNbits
        generic map (
            WIDTH   => 16
        )
        port map(
            clk     => clk, 
            rst     => rst, 
            ce      => uins.wINTA,   
            d       => ralu,   
            q       => intr_addr
        );

    -- Selection of who addresses the external memory   
    address <=  ralu    when uins.mAddr = "00" else   -- MUX connected to the memory address input
                pc      when uins.mAddr = "01" else
                sp;
                

    data_out <= s2          when DOut_control = "01" else
                flags_out   when DOut_control = "10" else
                opB;
               
end DataPath;