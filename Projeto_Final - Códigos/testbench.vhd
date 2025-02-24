library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity testbench is
end testbench;

architecture behavior of testbench is 

    component Risc_V
    generic (WSIZE : natural := 32);
    port(
        clk : in  std_logic;
        rst : in  std_logic
    );
    end component;

    signal test_finished : boolean := false;
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    constant clk_period : time := 10 ns;

begin 
    uut: Risc_V
        generic map (wsize => 32)
        port map (
            clk => clk,
            rst => rst
        );

    clk_process: process
    begin
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

    stimulus: process
    begin
        rst <= '1';
        wait for 1ns;
        rst <= '0';
        wait for 10000ns;
        test_finished <= true;
        wait;
    end process;

end behavior;
