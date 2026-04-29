library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instr_mem is
    Port (
        addr    : in  STD_LOGIC_VECTOR(31 downto 0);
        instr   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end instr_mem;

architecture Behavioral of instr_mem is
    type memory_array is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    signal memory : memory_array := (
        0 => x"00900293", -- addi x5, x0, 9         000000001001 00000 000 00101 0010011
        1 => x"00000317", -- load_addr x6, array (custom instruction), where array is 0x10000000
        -- <20 bit dont care><5 bit rd><7 bit opcode>
        -- 0000 0000 0000 0000 0000 00110 0010111
        -- 0 0 0 0 0 3 1 7
        2 => x"00032383", -- lw x7, 0(x6) 
        -- <12 bit imm><5 bit rs1><3 bit funct3><5 bit rd><7 bit opcode>
        -- 000000000000 00110 010 00111 0000011
        -- 0 0 0 3 2 3 8 3          
        3 => x"00430313", -- loop: addi x6, x6, 4 
        -- <12 bit imm><5 bit rs1><3 bit funct3><5 bit rd><7 bit opcode>
        -- 000000000100 00110 000 00110 0010011
        -- 0 0 4 3 0 3 1 3 
        4 => x"00032503", --       lw x10, 0(x6) 
        -- <12 bit imm><5 bit rs1><3 bit funct3><5 bit rd><7 bit opcode>
        -- 000000000000 00110 010 01010 0000011
        -- 0 0 0 3 2 5 0 3   
        5 => x"007503B3", --       add x7, x10, x7 
        -- <7 bit funct7><5 bit rs2><5 bit rs1><3 bit funct3><5 bit rd><7 bit opcode>
        -- 0000000 00111 01010 000 00111 0110011
        -- 0 0 7 5 0 3 B 3
        6 => x"00129293", --       subi x5, x5, 1 (or "addi x5, x5, -1")  
        -- <12 bit imm><5 bit rs1><3 bit funct3><5 bit rd><7 bit opcode>
        -- 0000 0000 0001 00101 001 00101 0010011
        -- 0 0 1 2 9 2 9 3
        7 => x"FA0298E3", --     bne x5, x0, loop   1 [jump -20; note: assumes PC is incremented by 4]
        -- <imm[11]><imm[9:4]><5 bit rs2><5 bit rs1><3 bit funct3><imm[3:1]><unused bit><imm[10]><7 bit opcode>
        -- imm: -40/2 = -20 => 111111011000
        -- 1 111101 00000 00101 001 100 0 1 1100011
        -- F A 0 2 9 8 E 3
        8 => x"FF9FF06F", -- done: j done             [jump -4; note: assumes PC is incremented by 4]      
        -- <imm[20]><imm[10:1]><imm[11]><imm[19:12]><5 bit rd><7 bit opcode>
        -- imm: = -4 => 1111 1111 1111 1111 1111 1100 
        -- 1 1111111100 1 11111111 00000 1101111
        -- F F 9 F F 0 6 F    
        others => (others => '0')
    );
begin
    process(addr)
    begin
        instr <= memory(to_integer(unsigned(addr(7 downto 0))));
    end process;
end Behavioral;
