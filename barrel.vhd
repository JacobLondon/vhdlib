library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity barrel is
	generic (
		size:   integer := 8
    );
	Port (
        iBuf : in  std_logic_vector(size - 1 downto 0);
	    -- 10 sll, 11 srl, 00 rol, 01 ror
        iCmd : in  std_logic_vector(1 downto 0);
        iAmt : in  std_logic_vector(integer(ceil(log2(real(size)))) - 1 downto 0);
        oBuf : out std_logic_vector(size - 1 downto 0)
    );
end barrel;

architecture Behavioral of barrel is
begin

    process (iBuf, iAmt)
    begin
        case iCmd is
            -- rol
            when "00" => oBuf <= std_logic_vector(rotate_left(unsigned(iBuf), to_integer(unsigned(iAmt))));
            -- ror
            when "01" => oBuf <= std_logic_vector(rotate_right(unsigned(iBuf), to_integer(unsigned(iAmt))));
            -- sll
            when "10" => oBuf <= std_logic_vector(shift_left(unsigned(iBuf), to_integer(unsigned(iAmt))));
            -- srl
            when "11" => oBuf <= std_logic_vector(shift_right(unsigned(iBuf), to_integer(unsigned(iAmt))));
            -- invalid
            when others => oBuf <= (others => '0');
        end case;
    end process;

end Behavioral;
