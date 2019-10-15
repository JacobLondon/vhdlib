library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; -- unsigned math
use IEEE.STD_LOGIC_ARITH.ALL;    -- + sign

-- 
-- Controls
-- Switch 15, 14, 13 => Display Select
-- Switch 12         => Clock picker
--                      0 => slow clock
--                      1 => fast clock
-- Switch 11         => Clock enable
--                      0 => disabled
--                      1 => enabled
-- Switch 3, 2, 1, 0 => Digit Select
-- Button BTND       => Reset Segments and Counters
-- Button BTNR       => Set Segment to value from Digit Select
-- 

entity top is
    Port (
            iClk      : in std_logic;
            i16Switch : in std_logic_vector (15 downto 0);
            -- BTNC, BTNU, BTNL, BTNR, BTND
            i5Button  : in std_logic_vector (4 downto 0);
            -- LEDs
            --o16Led    : out std_logic_vector (15 downto 0);
            -- 7 segment display
            -- MSB -> LSB: A, B, C, D, E, F, G
            o7Segment : out std_logic_vector (6 downto 0);
            o8An      : out std_logic_vector (7 downto 0);
            oDp       : out std_logic
         );
end top;

architecture Behavioral of top is

    -- components

    component seven_seg is
        generic (refresh_rate : integer := 20);
        Port (
                iClk        : in std_logic;
                iRst        : in std_logic;
                i32DigitBuf : in std_logic_vector (31 downto 0);
                i8DpFmt     : in std_logic_vector  (7 downto 0);
                o7Segment   : out std_logic_vector (6 downto 0);
                o8An        : out std_logic_vector (7 downto 0);
                oDp         : out std_logic
            );
    end component;

    component counter is
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
    end component;
    
    component clock is
        generic (clock_size : integer := 28);
        Port (
                iClk : in  std_logic;
                iEn  : in  std_logic;
                oClk : out std_logic
             );
    end component;

    -- signals
    signal m32DigitBuf  : std_logic_vector (31 downto 0);
    signal m8DpFmt      : std_logic_vector (7 downto 0);
    signal m32DigitPre  : std_logic_vector (31 downto 0);
    signal mInternalClk : std_logic;
    signal mSlowClk     : std_logic;
    signal mFastClk     : std_logic;

    signal mCountOverflow : std_logic_vector (8 downto 0);
    
    signal temp1 : std_logic;
    signal temp2 : std_logic;

begin

    temp1 <= i5Button(3);
    temp2 <= i5Button(4);
    -- dp on first non decimal digit
    m8DpFmt <= "11101111";

    SevenSegmentControl: seven_seg
        generic map (
                        refresh_rate => 20
                    )
        port    map (
                        iClk        => iClk,
                        iRst        => i5Button(0),
                        i32DigitBuf => m32DigitBuf,
                        i8DpFmt     => m8DpFmt,
                        o7Segment   => o7Segment,
                        o8An        => o8An,
                        oDp         => oDp
                    );

    -- load preliminary buffer with digits based on muxed input
    PreBufferInput : process (iClk)
    begin
        -- 3 upper switches for controlling mux
        case i16Switch(15 downto 13) is
            -- set each section depending on what the mux directs to
            when "000" => m32DigitPre(3 downto 0)   <= i16Switch(3 downto 0);
            when "001" => m32DigitPre(7 downto 4)   <= i16Switch(3 downto 0);
            when "010" => m32DigitPre(11 downto 8)  <= i16Switch(3 downto 0);
            when "011" => m32DigitPre(15 downto 12) <= i16Switch(3 downto 0);
            when "100" => m32DigitPre(19 downto 16) <= i16Switch(3 downto 0);
            when "101" => m32DigitPre(23 downto 20) <= i16Switch(3 downto 0);
            when "110" => m32DigitPre(27 downto 24) <= i16Switch(3 downto 0);
            when "111" => m32DigitPre(31 downto 28) <= i16Switch(3 downto 0);
        end case;
    end process PreBufferInput;

    -- count for each digit from 0 to 9, only when enabled to do so
    -- increment the first, the rest should increment on overflow
--    mCountOverflow(0) <= mInternalClk;
--    -- note: 8 spots in mCountOverflow, DC when last overflows, it resets
--    for i in 0 to 7 generate
--        IncrementControl : counter
--            generic map (
--                            size => 4
--                        )
--            port    map (
--                            iClk => mCountOverflow(i),
--                            iRst => i5Button(0),
--                            iSet => i5Button(1),
--                            iSizeSetVal => m32DigitPre(i*4+3 downto i*4),
--                            iSizeMaxVal => "1001",
--                            oSizeVal    => i32DigitBuf(i*4+3 downto i*4),
--                            oVerflow    => mCountOverflow(i+1)
--                        );
--    end generate;
    Increment0 : counter generic map (size=>4)
                         port map (iClk => mInternalClk, iRst => i5Button(0), iSet => i5Button(1), iSizeSetVal => m32DigitPre(3 downto 0),
                                   iSizeMaxVal => "1001", oSizeVal => m32DigitBuf(3 downto 0),
                                   oVerflow => mCountOverflow(0));
    Increment1 : counter generic map (size=>4)
                         port map (iClk => mCountOverflow(0), iRst => i5Button(0), iSet => i5Button(1), iSizeSetVal => m32DigitPre(7 downto 4),
                                   iSizeMaxVal => "1001", oSizeVal => m32DigitBuf(7 downto 4),
                                   oVerflow => mCountOverflow(1));
    Increment2 : counter generic map (size=>4)
                         port map (iClk => mCountOverflow(1), iRst => i5Button(0), iSet => i5Button(1), iSizeSetVal => m32DigitPre(11 downto 8),
                                   iSizeMaxVal => "1001", oSizeVal => m32DigitBuf(11 downto 8),
                                   oVerflow => mCountOverflow(2));
    Increment3 : counter generic map (size=>4)
                         port map (iClk => mCountOverflow(2), iRst => i5Button(0), iSet => i5Button(1), iSizeSetVal => m32DigitPre(15 downto 12),
                                   iSizeMaxVal => "1001", oSizeVal => m32DigitBuf(15 downto 12),
                                   oVerflow => mCountOverflow(3));
    Increment4 : counter generic map (size=>4)
                         port map (iClk => mCountOverflow(3), iRst => i5Button(0), iSet => i5Button(1), iSizeSetVal => m32DigitPre(19 downto 16),
                                   iSizeMaxVal => "1001", oSizeVal => m32DigitBuf(19 downto 16),
                                   oVerflow => mCountOverflow(4));
    Increment5 : counter generic map (size=>4)
                         port map (iClk => mCountOverflow(4), iRst => i5Button(0), iSet => i5Button(1), iSizeSetVal => m32DigitPre(23 downto 20),
                                   iSizeMaxVal => "1001", oSizeVal => m32DigitBuf(23 downto 20),
                                   oVerflow => mCountOverflow(5));
    Increment6 : counter generic map (size=>4)
                         port map (iClk => mCountOverflow(5), iRst => i5Button(0), iSet => i5Button(1), iSizeSetVal => m32DigitPre(27 downto 24),
                                   iSizeMaxVal => "1001", oSizeVal => m32DigitBuf(27 downto 24),
                                   oVerflow => mCountOverflow(6));
    Increment7 : counter generic map (size=>4)
                         port map (iClk => mCountOverflow(6), iRst => i5Button(0), iSet => i5Button(1), iSizeSetVal => m32DigitPre(31 downto 28),
                                   iSizeMaxVal => "1001", oSizeVal => m32DigitBuf(31 downto 28),
                                   oVerflow => mCountOverflow(7));

    SlowClkGen: clock
        generic map (
                        clock_size => 28
                    )
        port    map (
                        iClk => iClk,
                        iEn  => i16Switch(11),
                        oClk => mSlowClk
                    );
    FastClkGen: clock
        generic map (
                        clock_size => 20
                    )
        port    map (
                        iClk => iClk,
                        iEn  => i16Switch(11),
                        oClk => mFastClk
                    );
    ClockPicker : process (i16Switch(12))
    begin
        if (i16Switch(12) = '0') then
            mInternalClk <= mSlowClk;
        else
            mInternalClk <= mFastClk;
        end if;
    end process ClockPicker;

end Behavioral;
