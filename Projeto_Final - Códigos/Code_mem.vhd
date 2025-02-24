library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity Code_mem is
  port (
    addr     : in  std_logic_vector(31 downto 0);  
    data_out : out std_logic_vector(31 downto 0)  
  );
end entity Code_mem;

architecture RTL of Code_mem is
  type mem_type is array (0 to 16383) of std_logic_vector(31 downto 0);
  
  impure function mem_init return mem_type is
    file text_file     : text open read_mode is "C:\altera\13.0sp1\Risc_V\instr2.txt";  
    variable line_data : line;                              
    variable inst_data : std_logic_vector(31 downto 0);    
    variable mem       : mem_type := (others => (others => '0')); 
    variable idx       : integer := 0;                     
  begin
    while (idx < 16384 and not endfile(text_file)) loop
      readline(text_file, line_data);                      
      hread(line_data, inst_data);                         

      mem(idx) := inst_data;                                
      idx := idx + 4;
    end loop;

    return mem; 
  end function;

  signal mem : mem_type := mem_init;  

begin
  data_out <= mem(to_integer(unsigned(addr(13 downto 0))));  

end architecture RTL;