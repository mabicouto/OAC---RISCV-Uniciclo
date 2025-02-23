library IEEE;
use IEEE.std_logic_1164.all;

entity aluctr is
    port (
        funct7 : in std_logic;  -- Campo funct7 da instrução
        funct3 : in std_logic_vector(2 downto 0);  -- Campo funct3 da instrução
        aluop  : in std_logic_vector(1 downto 0);  -- Sinal ALUOp do controlador principal
        Opout : out std_logic_vector(3 downto 0)  -- Sinal de controle da ULA
    );
end entity;

architecture arch of aluctr is
begin
    process(funct7, funct3, aluop)
    begin
        case aluop is
            -- Operações de Load/Store e ADDi (I-type)
            when "00" => 
                Opout <= "0010";  -- ADD (para LW, SW, ADDi)

            -- Operações de Branch (B-type)
            when "01" => 
                case funct3 is
                    when "000" => Opout <= "0110";  -- SUB (para BEQ)
                    when "001" => Opout <= "0110";  -- SUB (para BNE)
                    when "100" => Opout <= "1000";  -- SLT (para BLT)
                    when "101" => Opout <= "1010";  -- SGE (para BGE)
                    when others => Opout <= "0000";  -- Valor padrão
                end case;

            -- Operações R-type (aritméticas/lógicas)
            when "10" => 
                case funct3 is
                    when "000" => 
                        if (funct7 = '1') then
                            Opout <= "0110";  -- SUB
                        else
                            Opout <= "0010";  -- ADD
                        end if;
                    when "111" => Opout <= "0000";  -- AND
                    when "110" => Opout <= "0001";  -- OR
                    when "100" => Opout <= "0100";  -- XOR
                    when "001" => Opout <= "0101";  -- SLL (Shift Left Logical)
                    when "101" => 
                        if (funct7 = '1') then
                            Opout <= "0111";  -- SRA (Shift Right Arithmetic)
                        else
                            Opout <= "0110";  -- SRL (Shift Right Logical)
                        end if;
                    when "010" => Opout <= "1000";  -- SLT (Set Less Than)
                    when "011" => Opout <= "1001";  -- SLTU (Set Less Than Unsigned)
                    when others => Opout <= "0000";  -- Valor padrão
                end case;

            -- Operações de AUIPC e LUI
            when "11" => 
                case funct3 is
                    when "000" => Opout <= "1100";  -- LUI (copia o valor imediato)
                    when "001" => Opout <= "1101";  -- AUIPC (soma o valor imediato ao PC)
                    when others => Opout <= "0000";  -- Valor padrão
                end case;

            -- Valor padrão para casos não especificados
            when others => 
                Opout <= "0000";
        end case;
    end process;
end architecture;
