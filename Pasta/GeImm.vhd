library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GeImm is
    port (
        instr : in std_logic_vector(31 downto 0);
        imm32 : out signed(31 downto 0)
    );
end GeImm;

architecture Behavioral of GeImm is
begin
    process(instr)
    variable opcode : std_logic_vector(6 downto 0);
    variable imm : signed(31 downto 0);
    begin
        opcode := instr(6 downto 0);
        
        case opcode is
            when "0110011" =>  -- R-type
                imm := (others => '0');
            
            when "0000011" | "0010011" | "1100111" =>  -- I-type (load, immediate, jalr)
                if instr(14 downto 12) = "101" and instr(31 downto 25) = "0100000" then
                    imm := resize(signed(instr(24 downto 20)), 32);
                else
                    imm := resize(signed(instr(31 downto 20)), 32);
                end if;
            
            when "0100011" =>  -- S-type
                imm := resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32);
            
            when "1100011" =>  -- B-type
                imm := resize(signed(
                    instr(31) & instr(7) & instr(30 downto 25) & 
                    instr(11 downto 8) & '0'), 32);
            
            when "0110111" | "0010111" =>  -- U-type (lui)
                imm := signed(instr(31 downto 12) & x"000");
					

            when "1101111" =>  -- UJ-type (jal)
                imm := resize(signed(
                    instr(31) & instr(19 downto 12) & instr(20) & 
                    instr(30 downto 21) & '0'), 32);
            
            when others =>
                imm := (others => '0');
        end case;
        
        imm32 <= imm;
    end process;
end Behavioral;
