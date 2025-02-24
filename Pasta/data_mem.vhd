library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity data_mem is
  port (
    we         : in  std_logic;                     -- Sinal de escrita (Write Enable)
    Byte_en    : in  std_logic;                     -- Habilita escrita por byte (1 para byte, 0 para word)
    addr       : in  std_logic_vector(13 downto 0); -- Endereço de 14 bits (2^14 = 16KB)
    datain     : in  std_logic_vector(31 downto 0); -- Dado de entrada (para escrita)
    dataout    : out std_logic_vector(31 downto 0); -- Dado de saída (para leitura)
    SignExtend : in  std_logic                      -- Extensão de sinal para leitura de byte
  );
end entity data_mem;

architecture RTL of data_mem is
  -- Definição de memória de bloco com 16KB, usando vetores de 32 bits (1 word por endereço)
  type mem_type is array (0 to 16383) of std_logic_vector(31 downto 0);  -- 16KB de memória (16384 words)
  
  -- Função para inicializar a memória a partir de um arquivo
  impure function init_mem return mem_type is
    file text_file     : text open read_mode is "C:\altera\13.0sp1\Risc_V\data.txt";  -- Abre o arquivo de dados
    variable line_data : line;                              -- Variável para ler cada linha do arquivo
    variable mem_data  : std_logic_vector(31 downto 0);     -- Dados lidos da linha
    variable mem       : mem_type := (others => (others => '0'));  -- Inicializa a memória com zeros
    variable idx       : integer := 0;                     -- Índice para percorrer a memória
  begin
    -- Lendo o arquivo de dados
    while (idx < mem_type'length and not endfile(text_file)) loop
      readline(text_file, line_data);                       -- Lê uma linha do arquivo
      hread(line_data, mem_data);                           -- Converte a linha para std_logic_vector

      -- Atribuindo o valor lido à memória
      mem(idx) := mem_data;                                 -- Usando := para atribuição à variável mem
      idx := idx + 1;
    end loop;

    return mem;  -- Retorna a memória inicializada
  end function;

  -- Sinal para armazenar a memória
  signal mem : mem_type := init_mem;  -- Inicializa a memória com a função

  -- Atributo para mapear a memória em blocos de RAM (Intel/Altera)
  attribute ramstyle : string;
  attribute ramstyle of mem : signal is "M9K"; -- Usa blocos M9K da FPGA

  -- Endereço base do segmento de dados no RARS (0x00002000)
  constant DATA_BASE_ADDR : integer := 8192; -- 0x2000 em decimal

begin
  -- Processo combinacional para leitura e escrita
  process(we, Byte_en, addr, datain, SignExtend)
    variable mem_addr : integer; -- Endereço de memória ajustado
    variable byte_data : std_logic_vector(7 downto 0); -- Dado de 8 bits (byte)
    variable byte_sel : integer range 0 to 3; -- Seleção do byte (0 a 3)

  begin
    -- Ajusta o endereço para o segmento de dados (subtrai o endereço base)
    mem_addr := to_integer(unsigned(addr)) - DATA_BASE_ADDR;
    if (mem_addr < 0 or mem_addr >= mem'length) then
      mem_addr := 0; -- Define um valor padrão seguro
    end if;

    byte_sel := to_integer(unsigned(addr(1 downto 0)));

    -- Operação de escrita
    if we = '1' then
      if Byte_en = '1' then
        -- Escrita de byte (apenas no byte selecionado)
        case byte_sel is
          when 0 => mem(mem_addr)(7 downto 0) <= datain(7 downto 0);   -- Byte 0
          when 1 => mem(mem_addr)(15 downto 8) <= datain(7 downto 0);  -- Byte 1
          when 2 => mem(mem_addr)(23 downto 16) <= datain(7 downto 0); -- Byte 2
          when 3 => mem(mem_addr)(31 downto 24) <= datain(7 downto 0); -- Byte 3
        end case;
      else
        -- Escrita de word (32 bits)
        mem(mem_addr) <= datain(31 downto 0);   --
      end if;
    end if;

    -- Operação de leitura
    if we = '0' then
      if Byte_en = '1' then
        -- Lê um byte da memória
        case byte_sel is
          when 0 => byte_data := mem(mem_addr)(7 downto 0);   -- Byte 0
          when 1 => byte_data := mem(mem_addr)(15 downto 8);  -- Byte 1
          when 2 => byte_data := mem(mem_addr)(23 downto 16); -- Byte 2
          when 3 => byte_data := mem(mem_addr)(31 downto 24); -- Byte 3
        end case;
        -- Extensão de sinal, se necessário
        if SignExtend = '1' and byte_data(7) = '1' then
          -- Extensão de sinal para leitura de byte
          dataout <= x"FFFFFF" & byte_data; -- Estende o sinal para 32 bits
        else
          -- Sem extensão de sinal
          dataout <= x"000000" & byte_data; -- Completa com zeros
        end if;
      else
        -- Lê uma word (32 bits) da memória
        dataout <= mem(mem_addr);
      end if;
    end if;
  end process;

end architecture RTL;