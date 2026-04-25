library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hazard_detection_unit is
    Port (
        reset :          in STD_LOGIC;
        -- Here are the signals I need
        instr          : in STD_LOGIC_VECTOR(31 downto 0);
        pc             : in STD_LOGIC_VECTOR(31 downto 0);
        if_id_instr    : in STD_LOGIC_VECTOR(31 downto 0);
        branch         : in STD_LOGIC;
        jump           : in STD_LOGIC;
        stall_counter  : in integer range 0 to 3 := 0;
        start_stall    : out STD_LOGIC
    );
end hazard_detection_unit;

-- NOTE: only looking  one instruction before dependency (not two or three before)
architecture Behavioral of hazard_detection_unit is
   signal working_opcode, incoming_opcode       : STD_LOGIC_VECTOR(6 downto 0);
   signal working_rs1, incoming_rs1             : STD_LOGIC_VECTOR(4 downto 0);
   signal working_rs2, incoming_rs2             : STD_LOGIC_VECTOR(4 downto 0);
   signal working_rd, incoming_rd               : STD_LOGIC_VECTOR(4 downto 0);
   signal double_stall : STD_LOGIC := '0';
begin
    -- would opcodes of instructions be useful?
    working_opcode <= if_id_instr(6 downto 0);
    incoming_opcode <= instr(6 downto 0);
    
    working_rs1 <= if_id_instr(19 downto 15);
    incoming_rs1 <= instr(19 downto 15);
    
    working_rs2 <= if_id_instr(24 downto 20);
    incoming_rs2 <= instr(24 downto 20);
    
    working_rd <= if_id_instr(11 downto 7);
    incoming_rd <= instr(11 downto 7);
    process(instr, branch, jump, stall_counter, working_opcode, incoming_opcode, working_rs1, incoming_rs1, working_rs2, incoming_rs2, working_rd, incoming_rd) -- any others?)
    begin      
        if (reset = '1') then
            start_stall <= '0';
        -- stall cases, dependency on a (1)load from memory, (2) load_addr, (3) add, (4) addi/subi
        
        -- Detection of the jump function. We should stall before the branch
        elsif (incoming_opcode = "1101111" and stall_counter = 0) then
                start_stall <= '1';
        -- We have to stall before the lw functions. We want the branch function to fully go, but not the jump
        elsif (incoming_rs1 = working_rd and stall_counter = 0) then -- single stall data dependency case and pc /= "00000000000000000000000000100100"
                start_stall <= '1';  
        else        
                start_stall <= '0';
        end if;    
        
    end process;
end Behavioral;
