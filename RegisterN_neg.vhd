library ieee;
use ieee.std_logic_1164.all;

entity RegisterN_neg is
    generic(
        n_bits : natural := 31
        );
	port(	CLK: in std_logic;
            D: in std_logic_vector(n_bits-1 downto 0);
			Enable: in std_logic;
			Q: out std_logic_vector(n_bits-1 downto 0):=(others => '0')
			);
end RegisterN_neg;

architecture structural of RegisterN_neg is
begin
	Q <= D when falling_edge(clk) and Enable='1';
end structural;
