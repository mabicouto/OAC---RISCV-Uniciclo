library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity Code_mem_TB is
end entity;

architecture Behavioral of Code_mem_TB is
    -- Componente a ser testado
    component Code_mem is
        port (
            addr     : in  std_logic_vector(31 downto 0);
            data_out : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Sinais de teste
    signal clk      : std_logic := '0'; -- Sinal de clock
    signal addr     : std_logic_vector(31 downto 0) := (others => '0');
    signal data_out : std_logic_vector(31 downto 0);

    -- Constante para o período do clock
    constant CLK_PERIOD : time := 5 ns; -- Período do clock (10 ns = 100 MHz)

begin
    -- Instância do componente a ser testado
    UUT: Code_mem
        port map (
            addr     => addr,
            data_out => data_out
        );

    -- Processo para gerar o clock
    process
    begin
        while now < 1000 ns loop -- Simula por 1000 ns
            clk <= '0';
            wait for CLK_PERIOD;
            clk <= '1';
            wait for CLK_PERIOD;
        end loop;
        wait; -- Finaliza a simulação
    end process;

    -- Processo de teste
    process
    begin
        -- Aguarda o primeiro rising_edge do clock
        wait until rising_edge(clk);

        -- Teste 1: Ler o primeiro endereço (0x00000000)
        addr <= std_logic_vector(to_unsigned(0, 32));
        wait until rising_edge(clk); -- Sincroniza com o clock

        -- Teste 2: Ler o segundo endereço (0x00000004)
        addr <= std_logic_vector(to_unsigned(4, 32));
        wait until rising_edge(clk); -- Sincroniza com o clock

        -- Teste 3: Ler um endereço fora do limite (0x00002000)
        addr <= std_logic_vector(to_unsigned(8, 32));
        wait until rising_edge(clk); -- Sincroniza com o clock

        -- Teste 4: Ler um endereço intermediário (0x00000010)
        addr <= std_logic_vector(to_unsigned(16, 32));
        wait until rising_edge(clk); -- Sincroniza com o clock

        addr <= std_logic_vector(to_unsigned(20, 32));
        wait until rising_edge(clk); -- Sincroniza com o clock

        -- Finalizar simulação
        report "Testes concluídos!";
        wait;
    end process;
end architecture;