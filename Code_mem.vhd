library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity Code_mem is
    port (
        addr     : in std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture RTL of Code_mem is

    type mem_type is array (0 to (2**16)-1) of std_logic_vector(31 downto 0); -- Memória de 64 KB (16K palavras de 32 bits)
    signal mem: mem_type := (others => (others => '0')); -- Inicializa a memória com zeros

    constant LIMIT : integer := 16#2000#; -- Limite de 8192 palavras (32 KB)

    -- Função para carregar a memória em blocos menores
    impure function init_mem return mem_type is
        file text_file : text open read_mode is "C:\altera\13.0sp1\Risc_V\inst.txt" ; -- Mudar diretório
        
        variable text_line : line;
        variable text_word : std_logic_vector(31 downto 0);
        variable memoria   : mem_type := (others => (others => '0')); -- Inicializa a memória com zeros
        variable n         : integer := 0;

    begin
        -- Loop para ler até o final do arquivo ou até atingir o limite
        while (n < (LIMIT / 4)) and not endfile(text_file) loop
            readline(text_file, text_line);
            read(text_line, text_word);  -- Lê a palavra (32 bits) do arquivo
            memoria(n) := text_word;
            n := n + 1;
        end loop;

        return memoria;
    end;

begin
    -- Inicializa a memória com os dados do arquivo
    mem <= init_mem;

    -- Leitura combinacional da memória (memória é lida baseado no endereço)
    process(addr)
    begin
        -- Quando o endereço for menor que o limite
        if (to_integer(unsigned(addr)) < LIMIT) then
            data_out <= mem(to_integer(unsigned(addr)) / 4); -- Divisão por 4 para acessar as palavras
        else
            data_out <= (others => '0'); -- Retorna zero se o endereço for inválido
        end if;
    end process;
end architecture;