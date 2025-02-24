library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controle is
    port (
        instr      : in std_logic_vector(31 downto 0);  -- Instrução completa
        ALUOp      : out std_logic_vector(1 downto 0);  -- Controle da ULA
        ALUSrc     : out std_logic;                     -- Seleção da entrada B da ULA
        isCA       : out std_logic;                     -- Sinal para isCA
        Branch     : out std_logic;                     -- Sinal de branch
        MemRead    : out std_logic;                    -- Leitura da memória
        MemWrite   : out std_logic;                   -- Escrita na memória
        RegWrite   : out std_logic;                   -- Escrita no banco de registradores
        Mem2Reg    : out std_logic;                   -- Seleção do dado para write-back
        Byte_en    : out std_logic;                   -- Habilita escrita por byte
        SignExtend : out std_logic;                   -- Extensão de sinal para leitura de byte
        JAL        : out std_logic                    -- Sinal de controle para JAL
    );
end controle;

architecture behavioral of controle is
    signal opcode : std_logic_vector(6 downto 0);  -- Opcode da instrução
begin
    opcode <= instr(6 downto 0);  -- Extrai o opcode da instrução

    process (opcode) begin
        case opcode is
            -- Instruções Tipo R (ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA)
            when "0110011" => 
                ALUOp      <= "10";  -- Operação definida por funct3 e funct7
                ALUSrc     <= '0';    -- Usa o valor do registrador rs2
                Branch     <= '0';    -- Não é branch
                MemRead    <= '0';    -- Não lê da memória
                MemWrite   <= '0';    -- Não escreve na memória
                RegWrite   <= '1';    -- Escreve no banco de registradores
                Mem2Reg    <= '0';    -- Usa o resultado da ULA
                isCA       <= '0';    -- Não é isCA
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';    -- Não é JAL

            -- Instruções Tipo I (LW, LB, LBU)
            when "0000011" =>  
                ALUOp      <= "00";  -- Operação definida por funct3 e funct7
                ALUSrc     <= '1';    -- Usa o valor imediato
                Branch     <= '0';    -- Não é branch
                MemRead    <= '1';    -- Lê da memória
                MemWrite   <= '0';    -- Não escreve na memória
                RegWrite   <= '1';    -- Escreve no banco de registradores
                Mem2Reg    <= '1';    -- Usa o dado da memória
                isCA       <= '0';    -- Não é isCA
                if instr(14 downto 12) = "010" then  -- LW
                    Byte_en <= '0';
                else  -- LB ou LBU
                    Byte_en <= '1';
                    SignExtend <= instr(14);  -- 1 para LB, 0 para LBU
                end if;
                JAL        <= '0';    -- Não é JAL

            -- Instruções Tipo S (SW, SB)
            when "0100011" =>  
                ALUOp      <= "00";  -- Operação definida por funct3 e funct7
                ALUSrc     <= '1';    -- Usa o valor imediato
                Branch     <= '0';    -- Não é branch
                MemRead    <= '0';    -- Não lê da memória
                MemWrite   <= '1';    -- Escreve na memória
                RegWrite   <= '0';    -- Não escreve no banco de registradores
                Mem2Reg    <= '0';    -- Não é relevante
                isCA       <= '0';    -- Não é isCA
                if instr(14 downto 12) = "010" then  -- SW
                    Byte_en <= '0';
                else  -- SB
                    Byte_en <= '1';
                end if;
                JAL        <= '0';    -- Não é JAL

            -- Instruções Tipo I (ADDi, SLLI, SRLI, SRAI, ANDI, ORI, XORI, SLTI, SLTUI)
            when "0010011" =>  
                ALUOp      <= "10";  -- Operação definida por funct3 e funct7
                ALUSrc     <= '1';    -- Usa o valor imediato
                Branch     <= '0';    -- Não é branch
                MemRead    <= '0';    -- Não lê da memória
                MemWrite   <= '0';    -- Não escreve na memória
                RegWrite   <= '1';    -- Escreve no banco de registradores
                Mem2Reg    <= '0';    -- Usa o resultado da ULA
                isCA       <= '0';    -- Não é isCA
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';    -- Não é JAL

            -- Instruções Tipo B (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            when "1100011" =>  
                ALUOp      <= "01";  -- SUB (para comparação)
                ALUSrc     <= '1';    -- Usa o valor do registrador rs2
                Branch     <= '1';    -- É branch
                MemRead    <= '0';    -- Não lê da memória
                MemWrite   <= '0';    -- Não escreve na memória
                RegWrite   <= '0';    -- Não escreve no banco de registradores
                Mem2Reg    <= '0';    -- Não é relevante
                isCA       <= '0';    -- Não é isCA
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';    -- Não é JAL

            -- Instruções Tipo U (LUI, isCA)
            when "0110111" =>  -- LUI
                ALUOp      <= "11";  -- Operação específica para LUI
                ALUSrc     <= '1';    -- Usa o valor imediato
                Branch     <= '0';    -- Não é branch
                MemRead    <= '0';    -- Não lê da memória
                MemWrite   <= '0';    -- Não escreve na memória
                RegWrite   <= '1';    -- Escreve no banco de registradores
                Mem2Reg    <= '0';    -- Usa o valor imediato
                isCA       <= '0';    -- Não é isCA
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';    -- Não é JAL

            when "0010111" =>  -- isCA
                ALUOp      <= "11";  -- Operação específica para isCA
                ALUSrc     <= '1';    -- Usa o valor imediato
                Branch     <= '0';    -- Não é branch
                MemRead    <= '0';    -- Não lê da memória
                MemWrite   <= '0';    -- Não escreve na memória
                RegWrite   <= '1';    -- Escreve no banco de registradores
                Mem2Reg    <= '0';    -- Usa o valor imediato
                isCA       <= '1';    -- É isCA
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';    -- Não é JAL

            -- Instruções Tipo J (JAL)
            when "1101111" =>  
                ALUOp      <= "00";  -- ADD (para calcular o endereço de salto)
                ALUSrc     <= '1';    -- Usa o valor imediato
                Branch     <= '1';    -- É branch
                MemRead    <= '0';    -- Não lê da memória
                MemWrite   <= '0';    -- Não escreve na memória
                RegWrite   <= '1';    -- Escreve no banco de registradores (endereço de retorno)
                Mem2Reg    <= '0';    -- Usa o resultado da ULA
                isCA       <= '0';    -- Não é isCA
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '1';    -- É JAL

            -- Instruções Tipo I (JALR)
            when "1100111" =>  
                ALUOp      <= "10";  -- ADD (para calcular o endereço de salto)
                ALUSrc     <= '1';    -- Usa o valor imediato
                Branch     <= '1';    -- É branch
                MemRead    <= '0';    -- Não lê da memória
                MemWrite   <= '0';    -- Não escreve na memória
                RegWrite   <= '1';    -- Escreve no banco de registradores (endereço de retorno)
                Mem2Reg    <= '0';    -- Usa o resultado da ULA
                isCA       <= '0';    -- Não é isCA
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '1';    -- Não é JAL

            -- Instrução desconhecida (default)
            when others =>  
                ALUOp      <= "00";  -- Operação padrão
                ALUSrc     <= '0';    -- Usa o valor do registrador rs2
                Branch     <= '0';    -- Não é branch
                MemRead    <= '0';    -- Não lê da memória
                MemWrite   <= '0';    -- Não escreve na memória
                RegWrite   <= '0';    -- Não escreve no banco de registradores
                Mem2Reg    <= '0';    -- Não é relevante
                isCA       <= '0';    -- Não é isCA
                Byte_en    <= '0';
                SignExtend <= '0';
                JAL        <= '0';    -- Não é JAL
        end case;
    end process;
end behavioral;