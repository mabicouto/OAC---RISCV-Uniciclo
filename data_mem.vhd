library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Memória de Dados (RAM)
entity data_mem is
  port (
    we       : in  std_logic;                     -- Sinal de escrita (Write Enable)
    byte_en  : in  std_logic_vector(3 downto 0);  -- Habilita escrita por byte (um bit para cada byte)
    address  : in  std_logic_vector(13 downto 0); -- Endereço de 14 bits (2^14 = 16KB)
    datain   : in  std_logic_vector(31 downto 0); -- Dado de entrada (para escrita)
    dataout  : out std_logic_vector(31 downto 0); -- Dado de saída (para leitura)
    sign_ext : in  std_logic                      -- Extensão de sinal para leitura de byte
  );
end entity data_mem;

architecture RTL of data_mem is
  type mem_type is array (0 to 16383) of std_logic_vector(7 downto 0); -- Memória de 16KB (16384 bytes)
  shared variable mem : mem_type := (others => (others => '0'));       -- Inicializa a memória com zeros

  -- Endereço base do segmento de dados no RARS (0x00002000)
  constant DATA_BASE_ADDR : integer := 8192; -- 0x2000 em decimal

begin

  -- Processo combinacional para leitura e escrita
  process(we, byte_en, address, datain, sign_ext)
    variable mem_addr : integer; -- Endereço de memória ajustado
    variable byte_data : std_logic_vector(7 downto 0); -- Dado de 8 bits (byte)
  begin
    -- Ajusta o endereço para o segmento de dados (subtrai o endereço base)
    mem_addr := to_integer(unsigned(address)) - DATA_BASE_ADDR;

    -- Operação de escrita
    if we = '1' then
      -- Escreve byte a byte
      if byte_en(0) = '1' then
        mem(mem_addr) := datain(7 downto 0); -- Byte 0
      end if;
      if byte_en(1) = '1' then
        mem(mem_addr + 1) := datain(15 downto 8); -- Byte 1
      end if;
      if byte_en(2) = '1' then
        mem(mem_addr + 2) := datain(23 downto 16); -- Byte 2
      end if;
      if byte_en(3) = '1' then
        mem(mem_addr + 3) := datain(31 downto 24); -- Byte 3
      end if;
    end if;

    -- Operação de leitura
    if we = '0' then
      -- Lê byte a byte
      byte_data := mem(mem_addr);
      if sign_ext = '1' and byte_data(7) = '1' then
        -- Extensão de sinal para leitura de byte
        dataout <= x"FFFFFF" & byte_data; -- Estende o sinal para 32 bits
      else
        dataout <= x"000000" & byte_data; -- Sem extensão de sinal
      end if;
    end if;
  end process;

end architecture RTL;