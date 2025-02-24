library IEEE;
use IEEE.std_logic_1164.all;

entity aluctr is
    port (
        funct7 : in std_logic;
        funct3 : in std_logic_vector(2 downto 0);
        aluop  : in std_logic_vector(1 downto 0);
        Opout : out std_logic_vector(3 downto 0)
    );
end entity;

architecture arch of aluctr is
begin
    process(funct7, funct3, aluop)
    begin
        case aluop is
            when "00" => 
                case funct3 is
                    when "000" => Opout <= "0010";
                    when "111" => Opout <= "0000";
                    when "110" => Opout <= "0001";
                    when "100" => Opout <= "0100";
                    when "001" => Opout <= "0101";
                    when "101" => 
                        if (funct7 = '1') then
                            Opout <= "0111";
                        else
                            Opout <= "1111";
                        end if;
                    when "010" => Opout <= "1000";
                    when "011" => Opout <= "1001";
                    when others => Opout <= "0000";
                end case;
            
            when "01" => 
                case funct3 is
                    when "000" => Opout <= "0011";
                    when "001" => Opout <= "1110";
                    when "100" => Opout <= "1000";
                    when "101" => Opout <= "1010";
                    when others => Opout <= "0000";
                end case;
            
            when "10" => 
                case funct3 is
                    when "000" => 
                        if (funct7 = '1') then
                            Opout <= "0110";
                        else
                            Opout <= "0010";
                        end if;
                    when "111" => Opout <= "0000";
                    when "110" => Opout <= "0001";
                    when "100" => Opout <= "0100";
                    when "001" => Opout <= "0101";
                    when "101" => 
                        if (funct7 = '1') then
                            Opout <= "0111";
                        else
                            Opout <= "1111";
                        end if;
                    when "010" => Opout <= "1000";
                    when "011" => Opout <= "1001";
                    when others => Opout <= "0000";
                end case;
            
            when "11" => 
                case funct3 is
                    when "101" => Opout <= "1100";
                    when "001" => Opout <= "1101";
                    when others => Opout <= "0000";
                end case;
            
            when others => 
                Opout <= "0000";
        end case;
    end process;
end architecture;