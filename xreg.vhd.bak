library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Uso correto para operações com números inteiros

entity Xreg is
    generic (WSIZE : natural := 32); -- Tamanho da palavra
    port (
        clk, wren : in std_logic;
        rs1, rs2, rd : in std_logic_vector(4 downto 0);
        data : in std_logic_vector(WSIZE-1 downto 0);
        ro1, ro2 : out std_logic_vector(WSIZE-1 downto 0)
    );
end Xreg;

architecture Behavioral of Xreg is
    type reg_array is array (0 to 31) of std_logic_vector(WSIZE-1 downto 0);
    constant ZERO_DATA : std_logic_vector(WSIZE-1 downto 0) := (others => '0'); -- Inicialização padrão
    signal registers : reg_array := (others => ZERO_DATA);
begin
    process (clk)
    begin
        if rising_edge(clk) then
            -- Proteção do registrador 0 e escrita nos demais registradores
            if wren = '1' and rd /= "00000" then
                registers(to_integer(unsigned(rd))) <= data;
            end if;
        end if;
    end process;

    -- Leitura dos registradores (registrador 0 sempre retorna ZERO_DATA)
    ro1 <= registers(to_integer(unsigned(rs1))) when rs1 /= "00000" else ZERO_DATA;
    ro2 <= registers(to_integer(unsigned(rs2))) when rs2 /= "00000" else ZERO_DATA;
    
end Behavioral;
