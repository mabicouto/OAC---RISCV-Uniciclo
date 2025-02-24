library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity data_mem is
  port (
    we         : in  std_logic;
    Byte_en    : in  std_logic;
    addr       : in  std_logic_vector(13 downto 0);
    datain     : in  std_logic_vector(31 downto 0);
    dataout    : out std_logic_vector(31 downto 0);
    SignExtend : in  std_logic
  );
end entity data_mem;

architecture RTL of data_mem is
  type mem_type is array (0 to 16383) of std_logic_vector(31 downto 0);
  
  impure function init_mem return mem_type is
    file text_file     : text open read_mode is "C:\\altera\\13.0sp1\\Risc_V\\data.txt";
    variable line_data : line;
    variable mem_data  : std_logic_vector(31 downto 0);
    variable mem       : mem_type := (others => (others => '0'));
    variable idx       : integer := 0;
  begin
    while (idx < mem_type'length and not endfile(text_file)) loop
      readline(text_file, line_data);
      hread(line_data, mem_data);
      mem(idx) := mem_data;
      idx := idx + 1;
    end loop;
    return mem;
  end function;

  signal mem : mem_type := init_mem;

  attribute ramstyle : string;
  attribute ramstyle of mem : signal is "M9K";

  constant DATA_BASE_ADDR : integer := 8192;

begin
  process(we, Byte_en, addr, datain, SignExtend)
    variable mem_addr : integer;
    variable byte_data : std_logic_vector(7 downto 0);
    variable byte_sel : integer range 0 to 3;
  begin
    mem_addr := to_integer(unsigned(addr)) - DATA_BASE_ADDR;
    if (mem_addr < 0 or mem_addr >= mem'length) then
      mem_addr := 0;
    end if;

    byte_sel := to_integer(unsigned(addr(1 downto 0)));

    if we = '1' then
      if Byte_en = '1' then
        case byte_sel is
          when 0 => mem(mem_addr)(7 downto 0) <= datain(7 downto 0);
          when 1 => mem(mem_addr)(15 downto 8) <= datain(7 downto 0);
          when 2 => mem(mem_addr)(23 downto 16) <= datain(7 downto 0);
          when 3 => mem(mem_addr)(31 downto 24) <= datain(7 downto 0);
        end case;
      else
        mem(mem_addr) <= datain(31 downto 0);
      end if;
    end if;

    if we = '0' then
      if Byte_en = '1' then
        case byte_sel is
          when 0 => byte_data := mem(mem_addr)(7 downto 0);
          when 1 => byte_data := mem(mem_addr)(15 downto 8);
          when 2 => byte_data := mem(mem_addr)(23 downto 16);
          when 3 => byte_data := mem(mem_addr)(31 downto 24);
        end case;
        if SignExtend = '1' and byte_data(7) = '1' then
          dataout <= x"FFFFFF" & byte_data;
        else
          dataout <= x"000000" & byte_data;
        end if;
      else
        dataout <= mem(mem_addr);
      end if;
    end if;
  end process;

end architecture RTL;
