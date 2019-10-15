library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_arith.all;

-- 1024 word, 32-bit rom -> 4kB
entity rom is
    generic (
        -- word size
        SIZE  : positive := 16;
        DEPTH : positive := 4
    );
    Port (
        addr : in  std_logic_vector(integer(ceil(log2(real(depth)))) - 1 downto 0);
        dout : out std_logic_vector(SIZE - 1 downto 0)
    );
end rom;

architecture Behavioral of rom is

    type memory is array(0 to DEPTH - 1) of std_logic_vector(SIZE - 1 downto 0);

    constant myrom: memory := (
        x"1234", x"2345", x"0001", x"2346"
    );

begin

    dout <= myrom(conv_integer(addr));

end Behavioral;