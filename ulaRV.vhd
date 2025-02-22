library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ulaRV is


	generic (WSIZE : natural := 32);
	port (
		opcode : in std_logic_vector(3 downto 0);
      A : in std_logic_vector(WSIZE-1 downto 0);
      B : in std_logic_vector(WSIZE-1 downto 0);		
		Z : out std_logic_vector(WSIZE-1 downto 0); 
		cond : out std_logic);
end ulaRV;
architecture Behavioral of ulaRV is
	signal temp_result : signed(WSIZE-1 downto 0);  -- Definindo a variável intermediária para armazenar o resultado do SRA
   signal sign_bit : std_logic;

	begin
		 process (opcode, A, B)
		 begin
			  case opcode is
					when "0000" => -- Operação de soma
						 Z <= std_logic_vector(signed(A) + signed(B));
						 cond <= '0'; 
					when "0001" => -- Operação de subtração
						 Z <= std_logic_vector(signed(A) - signed(B));
						 cond <= '0';
					when "0010" => -- Operação AND
						 Z <= A and B;
						 cond <= '0';
					when "0011" => -- Operação OR
						 Z <= A or B;
						 cond <= '0';
					when "0100" => -- Operação XOR
						 Z <= A xor B;
						 cond <= '0';
					when "0101" => -- Operação SLL A,B
                   Z <= std_logic_vector(signed(A) sll to_integer(unsigned(B(4 downto 0))));
						 cond <= '0';
					when "0110" => -- Operação SRL A,B
                   Z <= std_logic_vector(unsigned(A) srl to_integer(unsigned(B(4 downto 0))));
						 cond <= '0';
					when "0111" => -- Operação SRA A,B
						 -- Desloca A para a direita por um número de bits especificado em B(4 downto 0)
						 if A(WSIZE-1) = '1' then  -- Se o bit de sinal for 1 (número negativo)
							  Z <= (others => '1'); -- Preenche com 1s
							  Z(WSIZE-2 downto 0) <= A(WSIZE-1 downto 1); -- Desloca os bits restantes
						 else
							  Z <= (others => '0'); -- Se o bit de sinal for 0 (número positivo)
							  Z(WSIZE-2 downto 0) <= A(WSIZE-1 downto 1); -- Desloca os bits restantes
						 end if;
						 cond <= '0';

					when "1000" => -- Operação SLT A,B
						 if signed(A) < signed(B) then
							Z <= (others => '0'); Z(0) <= '1';
							cond <= '1';

						 else
							Z <= (others => '0');
						 end if;
						 cond <= '0';
					when "1001" => -- Operação SLTU A,B
						 if unsigned(A) < unsigned(B) then
							Z <= (others => '0'); Z(0) <= '1';
							cond <= '1';
						 else
							Z <= (others => '0');
						 end if;
						 cond <= '0';

					when "1010" => -- Operação SGE A,B
						 if signed(A) >= signed(B) then
							Z <= (others => '0'); Z(0) <= '1';
							cond <= '1';
						 else
							Z <= (others => '0');
						 end if;
						 cond <= '0';
						 
					when "1011" => -- Operação SGEU A,B
						 if unsigned(A) >= unsigned(B) then
							Z <= (others => '0'); Z(0) <= '1';
							cond <= '1';
						 else
							Z <= (others => '0');
						 end if;
						 cond <= '0';
						 
					when "1100" => --Operação SEQ A,B
						 if A = B then
							Z <= (others => '0'); Z(0) <= '1';
						 else
							  Z <= (others => '0');
						 end if;
						 cond <= '1';
					when "1101" => -- Operação SNE A,B
						 if A /= B then
							Z <= (others => '0'); Z(0) <= '1';
						 else
							  Z <= (others => '0');
						 end if;
						 cond <= '1';
					 when others =>
						Z <= (others => '0');
						cond <= '0';
						 
			  end case;
			end process;
end Behavioral;