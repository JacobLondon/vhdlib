library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity default_tb is
-- Port();
end default_tb;

architecture Behavioral of default_tb is

    component default is
        Port ( );
    end component;

    constant clk_period: time := 4 ns;

begin

    clk_gen: process
    begin
        clk_tb <= '1';
        wait for clk_period / 2;
        clk_tb <= '0';
        wait for clk_period / 2;
    end process clk_gen;

    default_gen: default port map ();

    default_sim: process
    begin

        wait for clk_period;

        wait;

    end process SIM_GEN;

end Behavioral;