library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; -- unsigned math
use IEEE.STD_LOGIC_ARITH.ALL;    -- + sign

entity seven_seg is
    generic (refresh_rate : integer := 20);
    Port (
            iClk        : in std_logic;
            iRst        : in std_logic;
            i32DigitBuf : in std_logic_vector  (31 downto 0);
            i8DpFmt     : in std_logic_vector  (7 downto 0);
            o7Segment   : out std_logic_vector (6 downto 0);
            o8An        : out std_logic_vector (7 downto 0);
            oDp         : out std_logic
         );
end seven_seg;

architecture Behavioral of seven_seg is

    signal mRefreshCounter : std_logic_vector (refresh_rate - 1 downto 0);
    -- top 3 bits of RefreshCounter to indicate which digit is being udpated
    signal m3DigitSelect   : std_logic_vector (2 downto 0);
    -- current digit being loaded, traverses iDigitBuf
    signal m4DigitLoad     : std_logic_vector (3 downto 0);

begin

    -- clock signal
    UpdateCounter : process (iClk, iRst)
    begin
        if (iRst = '1') then
            mRefreshCounter <= (others => '0');
            m3DigitSelect   <= (others => '0');
        elsif (rising_edge(iClk)) then
            mRefreshCounter <= mRefreshCounter + 1;
            m3DigitSelect   <= mRefreshCounter(refresh_rate - 1 downto refresh_rate - 3);
        end if;
    end process UpdateCounter;

    AnSelect : process (m3DigitSelect)
    begin
        case m3DigitSelect is
            when "000"  => o8An  <= "11111110";
            when "001"  => o8An  <= "11111101";
            when "010"  => o8An  <= "11111011";
            when "011"  => o8An  <= "11110111";
            when "100"  => o8An  <= "11101111";
            when "101"  => o8An  <= "11011111";
            when "110"  => o8An  <= "10111111";
            when "111"  => o8An  <= "01111111";
        end case;
    end process AnSelect;

    -- select which portion of the input will be loaded
    LoadSelect : process (m3DigitSelect)
    begin
        case m3DigitSelect is
            when "000" => m4DigitLoad <= i32DigitBuf(3  downto 0);
            when "001" => m4DigitLoad <= i32DigitBuf(7  downto 4);
            when "010" => m4DigitLoad <= i32DigitBuf(11 downto 8);
            when "011" => m4DigitLoad <= i32DigitBuf(15 downto 12);
            when "100" => m4DigitLoad <= i32DigitBuf(19 downto 16);
            when "101" => m4DigitLoad <= i32DigitBuf(23 downto 20);
            when "110" => m4DigitLoad <= i32DigitBuf(27 downto 24);
            when "111" => m4DigitLoad <= i32DigitBuf(31 downto 28);
        end case;
    end process LoadSelect;

    SegEncode : process (m3DigitSelect)
    begin
        case m4DigitLoad is
            when "0000" => o7Segment <= "0000001";
            when "0001" => o7Segment <= "1001111";
            when "0010" => o7Segment <= "0010010";
            when "0011" => o7Segment <= "0000110";
            when "0100" => o7Segment <= "1001100";
            when "0101" => o7Segment <= "0100100";
            when "0110" => o7Segment <= "0100000";
            when "0111" => o7Segment <= "0001111";
            when "1000" => o7Segment <= "0000000";
            when "1001" => o7Segment <= "0001100";
            when others => o7Segment <= (others => 'Z');
        end case;
    end process SegEncode;

    -- select the dp based on dp format
    DpSelect : process (m3DigitSelect)
    begin
        case m3DigitSelect is
            when "000" => oDp <= i8DpFmt(0);
            when "001" => oDp <= i8DpFmt(1);
            when "010" => oDp <= i8DpFmt(2);
            when "011" => oDp <= i8DpFmt(3);
            when "100" => oDp <= i8DpFmt(4);
            when "101" => oDp <= i8DpFmt(5);
            when "110" => oDp <= i8DpFmt(6);
            when "111" => oDp <= i8DpFmt(7);
        end case;
    end process DpSelect;

end Behavioral;
