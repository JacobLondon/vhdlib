library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; -- unsigned math
use IEEE.STD_LOGIC_ARITH.ALL;    -- + sign

entity counter is
    -- bits wide
    generic (size : integer := 8);
    Port (
            iClk        : in std_logic;
            iRst        : in std_logic;
            -- make the current value the set value when hi
            iSet        : in std_logic;
            iSizeSetVal : in std_logic_vector  (size - 1 downto 0);
            iSizeMaxVal : in std_logic_vector  (size - 1 downto 0);
            oSizeVal    : out std_logic_vector (size - 1 downto 0);
            -- activate when the counter hit the max value, then reset it
            oVerflow    : out std_logic
         );
end counter;

architecture Behavioral of counter is

    signal mSizeInternal : std_logic_vector (size - 1 downto 0);
    signal mOverflow     : std_logic;

begin

    CountOperation : process (iClk, iRst, iSet)
    begin
        -- reset
        if (iRst = '1') then
            mSizeInternal <= (others => '0');
        -- max bounds
        elsif (mSizeInternal = iSizeMaxVal) then
            mSizeInternal <= (others => '0');
            mOverflow     <= '1';
        -- set
        elsif (iSet = '1') then
            mSizeInternal <= iSizeSetVal;
        -- increment and reset overflow
        elsif (rising_edge(iClk)) then
            mSizeInternal <= mSizeInternal + 1;
            mOverflow     <= '0';
        end if;
    end process CountOperation;

    oSizeVal <= mSizeInternal;
    oVerflow <= mOverflow;

end Behavioral;
