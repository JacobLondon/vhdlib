library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_arith.all;

-- 1024 word, 32-bit ram -> 4kB
entity ram is
    generic (
        -- word size
        SIZE  : positive := 32;
        DEPTH : positive := 64
    );
    Port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        en   : in std_logic;
        rw   : in  std_logic; -- 0 = read, 1 = write
        addr : in  std_logic_vector(integer(ceil(log2(real(DEPTH)))) - 1 downto 0);
        din  : in std_logic_vector(SIZE - 1 downto 0);
        dout : out std_logic_vector(SIZE - 1 downto 0)
    );
end ram;

architecture Behavioral of ram is

    type ram_array is array(0 to DEPTH - 1) of std_logic_vector(SIZE - 1 downto 0);
    signal myram : ram_array;

begin

    RAM_PROCESS: process (clk)
    begin
        if (rising_edge(clk)) then
            if en = '1' then
                if rw = '1' then
                    myram(conv_integer(addr)) <= din;
                else
                    dout <= myram(conv_integer(addr));
                end if;
            end if;
        end if;
    end process RAM_PROCESS;

end Behavioral;