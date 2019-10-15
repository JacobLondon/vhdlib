library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; -- unsigned math
use IEEE.STD_LOGIC_ARITH.ALL;    -- + sign

entity clock is
    generic (clock_size : integer := 28);
    Port (
            iClk : in  std_logic;
            iEn  : in  std_logic;
            oClk : out std_logic
         );
end entity;

architecture Behavioral of clock is

    signal mCountBuf : std_logic_vector (clock_size - 1 downto 0);

begin

    ClockOperation: process (iClk)
    begin
        if (iEn = '1' and rising_edge(iClk)) then
            mCountBuf <= mCountBuf + 1;
        end if;
    end process ClockOperation;

    oClk <= mCountBuf(clock_size - 1);

end Behavioral;
