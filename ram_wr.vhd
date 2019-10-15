library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_arith.all;

-- ram that can be written to and read from simultaneously
entity read_wr is
    generic (
        -- word size
        SIZE  : positive := 32;
        DEPTH : positive := 64
    );
    Port (
        clk  : in  std_logic;
        rst  : in  std_logic;
        wr   : in  std_logic;
        rd   : in  std_logic;
        addr_wr : in  std_logic_vector(integer(ceil(log2(real(DEPTH)))) - 1 downto 0);
        addr_rd : in  std_logic_vector(integer(ceil(log2(real(DEPTH)))) - 1 downto 0);
        din  : in std_logic_vector(SIZE - 1 downto 0);
        dout : out std_logic_vector(SIZE - 1 downto 0)
    );
end read_wr;

architecture Behavioral of read_wr is

    type ram_array is array(0 to DEPTH - 1) of std_logic_vector(SIZE - 1 downto 0);
    signal myram : ram_array;

begin

    RAM_PROCESS_WR: process (clk)
    begin
        if (rising_edge(clk)) then
            if wr = '1' then
                myram(conv_integer(addr_wr)) <= din;
            else
                dout <= myram(conv_integer(addr_wr));
            end if;
        end if;
    end process RAM_PROCESS_WR;
    
    RAM_PROCESS_RD: process (clk)
    begin
        if (rising_edge(clk)) then
            if rd = '1' then
                myram(conv_integer(addr_rd)) <= din;
            else
                dout <= myram(conv_integer(addr_rd));
            end if;
        end if;
    end process RAM_PROCESS_RD;

end Behavioral;