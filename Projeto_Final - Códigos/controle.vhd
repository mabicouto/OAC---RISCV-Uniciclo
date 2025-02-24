library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controle is
    port (
        instr      : in std_logic_vector(31 downto 0);
        ALUOp      : out std_logic_vector(1 downto 0);
        ALUSrc     : out std_logic;
        isCA       : out std_logic;
        Branch     : out std_logic;
        MemRead    : out std_logic;
        MemWrite   : out std_logic;
        RegWrite   : out std_logic;
        Mem2Reg    : out std_logic;
        Byte_en    : out std_logic;
        SignExtend : out std_logic;
        JAL        : out std_logic
    );
end controle;

architecture behavioral of controle is
    signal opcode : std_logic_vector(6 downto 0);
begin
    opcode <= instr(6 downto 0);

    process (opcode) begin
        case opcode is
            when "0110011" => 
                ALUOp      <= "10";
                ALUSrc     <= '0';
                Branch     <= '0';
                MemRead    <= '0';
                MemWrite   <= '0';
                RegWrite   <= '1';
                Mem2Reg    <= '0';
                isCA       <= '0';
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';
            
            when "0000011" =>  
                ALUOp      <= "00";
                ALUSrc     <= '1';
                Branch     <= '0';
                MemRead    <= '1';
                MemWrite   <= '0';
                RegWrite   <= '1';
                Mem2Reg    <= '1';
                isCA       <= '0';
                if instr(14 downto 12) = "010" then  
                    Byte_en <= '0';
                else  
                    Byte_en <= '1';
                    SignExtend <= instr(14);
                end if;
                JAL        <= '0';

            when "0100011" =>  
                ALUOp      <= "00";
                ALUSrc     <= '1';
                Branch     <= '0';
                MemRead    <= '0';
                MemWrite   <= '1';
                RegWrite   <= '0';
                Mem2Reg    <= '0';
                isCA       <= '0';
                if instr(14 downto 12) = "010" then  
                    Byte_en <= '0';
                else  
                    Byte_en <= '1';
                end if;
                JAL        <= '0';

            when "0010011" =>  
                ALUOp      <= "00";
                ALUSrc     <= '1';
                Branch     <= '0';
                MemRead    <= '0';
                MemWrite   <= '0';
                RegWrite   <= '1';
                Mem2Reg    <= '0';
                isCA       <= '0';
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';

            when "1100011" =>  
                ALUOp      <= "01";
                ALUSrc     <= '1';
                Branch     <= '1';
                MemRead    <= '0';
                MemWrite   <= '0';
                RegWrite   <= '0';
                Mem2Reg    <= '0';
                isCA       <= '0';
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';

            when "0110111" =>  
                ALUOp      <= "11";
                ALUSrc     <= '1';
                Branch     <= '0';
                MemRead    <= '0';
                MemWrite   <= '0';
                RegWrite   <= '1';
                Mem2Reg    <= '0';
                isCA       <= '0';
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';

            when "0010111" =>  
                ALUOp      <= "11";
                ALUSrc     <= '1';
                Branch     <= '0';
                MemRead    <= '0';
                MemWrite   <= '0';
                RegWrite   <= '1';
                Mem2Reg    <= '0';
                isCA       <= '1';
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';

            when "1101111" =>  
                ALUOp      <= "10";
                ALUSrc     <= '1';
                Branch     <= '1';
                MemRead    <= '0';
                MemWrite   <= '0';
                RegWrite   <= '1';
                Mem2Reg    <= '0';
                isCA       <= '0';
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '1';

            when "1100111" =>  
                ALUOp      <= "00";
                ALUSrc     <= '1';
                Branch     <= '1';
                MemRead    <= '0';
                MemWrite   <= '0';
                RegWrite   <= '1';
                Mem2Reg    <= '0';
                isCA       <= '0';
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '1';

            when others =>  
                ALUOp      <= "00";
                ALUSrc     <= '0';
                Branch     <= '0';
                MemRead    <= '0';
                MemWrite   <= '0';
                RegWrite   <= '0';
                Mem2Reg    <= '0';
                isCA       <= '0';
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';
        end case;
    end process;
end behavioral;
