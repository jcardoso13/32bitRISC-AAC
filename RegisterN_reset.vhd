library ieee;
use ieee.std_logic_1164.all;

entity RegisterN_reset is
    generic(
        n_bits : natural := 31
        );
	port(	CLK: in std_logic;
			Reset: in std_logic;
            D: in std_logic_vector(n_bits-1 downto 0);
			Enable: in std_logic;
			Q: out std_logic_vector(n_bits-1 downto 0):=(others => '0')
			);
end RegisterN_reset;

architecture structural of RegisterN_reset is
begin
	Q <= (others=> '0') when CLK'event and CLK='1' and Reset='1' else 
			D when CLK'event and CLK='1' and Reset='0' and Enable='1';
end structural;
