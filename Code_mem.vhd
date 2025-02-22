library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity Code_mem is
  port (
    addr : in std_logic_vector(31 downto 0);  -- Endereço de 32 bits
    data_out : out std_logic_vector(31 downto 0)  -- Instrução de 32 bits
  );
end entity Code_mem;

architecture RTL of Code_mem is
  type rom_type is array (0 to 2047) of std_logic_vector(31 downto 0); -- Memória ROM de 2048 instruções
  signal rom : rom_type := (others => (others => '0')); -- Inicializa a ROM com zeros

  -- Caminho para o arquivo de instruções
  file instr_file : text open read_mode is "C:\altera\13.0sp1\trab7_mem\inst.txt";

begin

  -- Processo de leitura do arquivo de instruções
  process
    variable idx : integer := 0;                  -- Índice para preencher a ROM
    variable line_data : line;                    -- Variável para ler cada linha do arquivo
    variable inst_data : std_logic_vector(31 downto 0) := (others => '0'); -- Inicializa com zeros
  begin
    -- Lendo o arquivo de instruções
    while (not endfile(instr_file)) loop
      readline(instr_file, line_data);           -- Lê uma linha do arquivo
      hread(line_data, inst_data);               -- Lê a linha e converte para std_logic_vector (hexadecimal)

      -- Atribuindo o valor lido à ROM (sinal)
      rom(idx) <= inst_data;                     -- Usando <= para atribuição ao sinal rom
      idx := idx + 1;

      -- Limita a ROM a 2048 instruções
      if idx = 2048 then
        exit;                                    -- Sai do loop se o limite for atingido
      end if;
    end loop;

    wait; -- Aguardar a execução do processo
  end process;

  -- Leitura da ROM: quando o endereço for fornecido, retorna a instrução correspondente
  data_out <= rom(to_integer(unsigned(addr(10 downto 0)))); -- Atribuição da instrução com base no endereço

end architecture RTL;