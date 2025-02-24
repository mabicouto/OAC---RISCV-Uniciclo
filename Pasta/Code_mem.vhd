library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity Code_mem is
  port (
    addr     : in  std_logic_vector(31 downto 0);  -- Endereço de entrada
    data_out : out std_logic_vector(31 downto 0)   -- Dado de saída
  );
end entity Code_mem;

architecture RTL of Code_mem is
  -- Definição do tipo de memória
  type mem_type is array (0 to 16383) of std_logic_vector(31 downto 0);
  
  -- Função para inicializar a memória a partir do arquivo
  impure function mem_init return mem_type is
    file text_file     : text open read_mode is "C:\altera\13.0sp1\Risc_V\instr2.txt";  -- Abre o arquivo de instruções
    variable line_data : line;                              -- Variável para ler cada linha do arquivo
    variable inst_data : std_logic_vector(31 downto 0);     -- Dados lidos da linha
    variable mem       : mem_type := (others => (others => '0'));  -- Inicializa a memória com zeros
    variable idx       : integer := 0;                     -- Índice para percorrer a memória
  begin
    -- Lendo o arquivo de instruções
    while (idx < 16384 and not endfile(text_file)) loop
      readline(text_file, line_data);                       -- Lê uma linha do arquivo
      hread(line_data, inst_data);                          -- Converte a linha para std_logic_vector

      -- Atribuindo o valor lido à memória
      mem(idx) := inst_data;                                -- Usando := para atribuição à variável mem
      idx := idx + 4;
    end loop;

    return mem;  -- Retorna a memória inicializada
  end function;

  -- Sinal para armazenar a memória
  signal mem : mem_type := mem_init;  -- Inicializa a memória com a função

begin
  -- Leitura da memória: quando o endereço for fornecido, retorna a instrução correspondente
  data_out <= mem(to_integer(unsigned(addr(13 downto 0))));  -- Atribuição da instrução com base no endereço

end architecture RTL;