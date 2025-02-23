library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
-- testbench has no ports.
end testbench;

architecture behavior of testbench is 

    -- component declaration for the unit under test (uut)
    component Risc_V
    generic (WSIZE : natural := 32); -- tamanho da palavra
    port(
        clk : in  std_logic;  -- sinal de clock
        rst : in  std_logic   -- sinal de reset
    );
    end component;

    -- end of simulation flag
    signal test_finished : boolean := false;
    
    -- inputs
    signal clk : std_logic := '0';  -- inicializado com '0'
    signal rst : std_logic := '1';  -- sinal de reset adicionado

    -- clock period definition
    constant clk_period : time := 10 ns; -- período do clock (10 ns)

begin 
    -- instantiate the unit under test (uut)
    uut: Risc_V
        generic map (wsize => 32)
        port map (
            clk => clk,
            rst => rst
        );

    -- clock process
    clk_process: process
    begin
        wait for clk_period/2;
        while not test_finished loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        clk <= '0';
        wait for clk_period/2;
        wait;
    end process;

    -- test stimulus process
    stimulus: process
    begin
        -- aplica o reset
        rst <= '1';  -- ativa o reset
        wait for clk_period * 2;  -- mantém o reset ativo por 2 ciclos de clock
        rst <= '0';  -- desativa o reset

        -- aguarda alguns ciclos de clock para o processador operar
        wait for 10 * clk_period;

        -- finaliza a simulação
        test_finished <= true;
        
        wait;  -- aguarda indefinidamente
    end process;

end behavior;