library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

entity mux is 
    generic (WSIZE : natural := 32); -- Tamanho da palavra
    port (
        a, b : in std_logic_vector(WSIZE-1 downto 0); -- Entradas
        ctrl : in std_logic;                          -- Sinal de controle
        z : out std_logic_vector(WSIZE-1 downto 0)    -- Saída
    );
end mux;

architecture main of mux is
begin
    -- Processo combinacional para seleção da saída
    process (a, b, ctrl)
    begin
        case ctrl is
            when '0' => z <= a;    -- Seleciona a entrada 'a'
            when '1' => z <= b;    -- Seleciona a entrada 'b'
            when others => z <= (others => '0'); -- Caso padrão (não deve ocorrer)
        end case;
    end process;
end main;