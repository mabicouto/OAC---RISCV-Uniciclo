library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controle is
    port (
        instr  : in std_logic_vector(31 downto 0);  -- Instrução completa
        ALUOp  : out std_logic_vector(1 downto 0);  -- controlee da ULA
        ALUSrc : out std_logic;                     -- Seleção da entrada B da ULA
        isCA  : out std_logic;                     -- Sinal para isCA
        Branch : out std_logic;                     -- Sinal de branch
        MemRead : out std_logic;                    -- Leitura da memória
        MemWrite : out std_logic;                   -- Escrita na memória
        RegWrite : out std_logic;                   -- Escrita no banco de registradores
        Mem2Reg : out std_logic;
		  Byte_en : out std_logic;
		  SignExtend : out std_logic-- Seleção do dado para write-back
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
                ALUOp  <= "10";  -- Operação definida por funct3 e funct7
                ALUSrc <= '0';    -- Usa o valor do registrador rs2
                Branch <= '0';    -- Não é branch
                MemRead <= '0';   -- Não lê da memória
                MemWrite <= '0';  -- Não escreve na memória
                RegWrite <= '1';  -- Escreve no banco de registradores
                Mem2Reg <= '0';   -- Usa o resultado da ULA
                isCA <= '0';     -- Não é isCA
					 Byte_en <= '0';
					 SignExtend <= '0';


            -- Instruções Tipo I (LW, ADDi, SLLI, SRLI, SRAI, ANDI, ORI, XORI, SLTI, SLTUI)
				when "0000011" =>  -- LW, LB, LBU
					 ALUOp  <= "00";  -- Operação definida por funct3 e funct7
					 ALUSrc <= '1';    -- 
					 Branch <= '0';    -- Não é branch
					 MemRead <= '1';   -- 
					 MemWrite <= '0';  -- Não escreve na memória
					 RegWrite <= '1';  -- Escreve no banco de registradores
					 Mem2Reg <= '1';   -- Usa o resultado da ULA
					 isCA <= '0';     -- Não é isCA
	

					 if instr(14 downto 12) = "010" then  -- LW
						  Byte_en <= '0';
					 else  -- LB ou LBU
						  Byte_en <= '1';
						  SignExtend <= instr(14);  -- 1 para LB, 0 para LBU
					 end if;

				when "0100011" =>  -- SW, SB
					 ALUOp  <= "00";  -- Operação definida por funct3 e funct7
					 ALUSrc <= '1';    -- 
					 Branch <= '0';    -- Não é branch
					 MemRead <= '0';   -- 
					 MemWrite <= '1';  -- 
					 RegWrite <= '0';  -- Escreve no banco de registradores
					 Mem2Reg <= '0';   -- Usa o resultado da ULA
					 isCA <= '0';     -- Não é isCA

					 MemWrite <= '1';
					 if instr(14 downto 12) = "010" then  -- SW
						  Byte_en <= '0';
					 else  -- SB
						  Byte_en <= '1';
					 end if;

            when "0010011" =>  -- ADDi, SLLI, SRLI, SRAI, ANDI, ORI, XORI, SLTI, SLTUI
                ALUOp  <= "10";  -- Operação definida por funct3 e funct7
                ALUSrc <= '1';   -- Usa o valor imediato
                Branch <= '0';   -- Não é branch
                MemRead <= '0';  -- Não lê da memória
                MemWrite <= '0'; -- Não escreve na memória
                RegWrite <= '1';  -- Escreve no banco de registradores
                Mem2Reg <= '0';   -- Usa o resultado da ULA
                isCA <= '0';     -- Não é isCA
					 Byte_en <= '0';
					 SignExtend <= '0';


            -- Instruções Tipo B (BEQ, BNE, BLT, BGE, BLTU, BGEU)
            when "1100011" => 
                ALUOp  <= "01";  -- SUB (para comparação)
                ALUSrc <= '0';   -- Usa o valor do registrador rs2
                Branch <= '1';   -- É branch
                MemRead <= '0';  -- Não lê da memória
                MemWrite <= '0'; -- Não escreve na memória
                RegWrite <= '0'; -- Não escreve no banco de registradores
                Mem2Reg <= '0';   -- Não é relevante
                isCA <= '0';     -- Não é isCA
					 Byte_en <= '0';
					 SignExtend <= '0';
					 
            -- Instruções Tipo U (LUI, isCA)
            when "0110111" =>  -- LUI
                ALUOp  <= "11";  -- Operação específica para LUI
                ALUSrc <= '1';   -- Usa o valor imediato
                Branch <= '0';   -- Não é branch
                MemRead <= '0';  -- Não lê da memória
                MemWrite <= '0'; -- Não escreve na memória
                RegWrite <= '1'; -- Escreve no banco de registradores
                Mem2Reg <= '0';  -- Usa o valor imediato
                isCA <= '0';    -- Não é isCA
					 Byte_en <= '0';
					 SignExtend <= '0';
					 
            when "0010111" =>  -- isCA
                ALUOp  <= "11";  -- Operação específica para isCA
                ALUSrc <= '1';   -- Usa o valor imediato
                Branch <= '0';   -- Não é branch
                MemRead <= '0';  -- Não lê da memória
                MemWrite <= '0'; -- Não escreve na memória
                RegWrite <= '1'; -- Escreve no banco de registradores
                Mem2Reg <= '0';  -- Usa o valor imediato
                isCA <= '1';    -- É isCA
					 Byte_en <= '0';
					 SignExtend <= '0';
					 
            -- Instruções Tipo J (JAL)
            when "1101111" => 
                ALUOp  <= "00";  -- ADD (para calcular o endereço de salto)
                ALUSrc <= '1';   -- Usa o valor imediato
                Branch <= '1';   -- É branch
                MemRead <= '0';  -- Não lê da memória
                MemWrite <= '0'; -- Não escreve na memória
                RegWrite <= '1'; -- Escreve no banco de registradores (endereço de retorno)
                Mem2Reg <= '0';  -- Usa o resultado da ULA
                isCA <= '0';    -- Não é isCA
					 Byte_en <= '0';
					 SignExtend <= '0';
					 
            -- Instruções Tipo I (JALR)
            when "1100111" => 
                ALUOp  <= "00";  -- ADD (para calcular o endereço de salto)
                ALUSrc <= '1';   -- Usa o valor imediato
                Branch <= '1';   -- É branch
                MemRead <= '0';  -- Não lê da memória
                MemWrite <= '0'; -- Não escreve na memória
                RegWrite <= '1'; -- Escreve no banco de registradores (endereço de retorno)
                Mem2Reg <= '0';  -- Usa o resultado da ULA
                isCA <= '0';    -- Não é isCA
					 Byte_en <= '0';
					 SignExtend <= '0';
					 
            -- Instrução desconhecida (default)
            when others => 
                ALUOp  <= "00";  -- Operação padrão
                ALUSrc <= '0';   -- Usa o valor do registrador rs2
                Branch <= '0';   -- Não é branch
                MemRead <= '0';  -- Não lê da memória
                MemWrite <= '0'; -- Não escreve na memória
                RegWrite <= '0'; -- Não escreve no banco de registradores
                Mem2Reg <= '0';  -- Não é relevante
                isCA <= '0';    -- Não é isCA
					 Byte_en <= '0';
					 SignExtend <= '0';
					 
        end case;
    end process;
end behavioral;
