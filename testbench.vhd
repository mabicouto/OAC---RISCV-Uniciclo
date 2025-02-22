library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity testbench is
    generic(WSIZE : natural := 32); -- Tamanho da palavra
end testbench;

architecture test of testbench is

    -- Declaração do componente RiscV
    component RiscV is
        generic(WSIZE : natural := 32);
        port (
            clk : in std_logic; -- Sinal de clock
            rst : in std_logic  -- Sinal de reset
        );
    end component;

    -- Sinais do testbench
    signal clk : std_logic := '0'; -- Sinal de clock (inicializado em '0')
    signal rst : std_logic := '1'; -- Sinal de reset (inicializado em '1')

begin

    -- Instanciação do DUT (Device Under Test)
    DUT: RiscV
        generic map (WSIZE => WSIZE)
        port map (
            clk => clk,
            rst => rst
        );

    -- Processo para gerar o clock
    process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- Processo para controlar o reset e a simulação
    process
    begin
        -- Mantém o reset ativo por 10 ns
        rst <= '1';
        wait for 10 ns;

        -- Desativa o reset
        rst <= '0';
		  wait for 1000 ns;


        -- Aguarda o fim da simulação

        -- Finaliza a simulação
        wait;
    end process;


end test;