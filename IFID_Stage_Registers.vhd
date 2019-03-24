library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IFID_Stage_Registers is
    Port ( 
           CLK    : in STD_LOGIC;
           Enable : in STD_LOGIC;
           Reset:   in std_logic;
           IF_PC  : in STD_LOGIC_VECTOR (31 downto 0);
           IF_I   : in STD_LOGIC_VECTOR (31 downto 0);
           ID_PC  : out STD_LOGIC_VECTOR (31 downto 0);
           ID_I   : out STD_LOGIC_VECTOR (31 downto 0));
end IFID_Stage_Registers;

architecture Behavioral of IFID_Stage_Registers is

component RegisterN_reset
    generic(n_bits : natural := 31);
	port(	CLK: in std_logic;
            Reset: in std_logic;
            D: in std_logic_vector(n_bits-1 downto 0);
			Enable: in std_logic;
			Q: out std_logic_vector(n_bits-1 downto 0)
			);
end component;
signal zeroo:std_logic;
begin
zeroo<='0';
IF_ID_RegInst: RegisterN_reset generic map(n_bits=>32) port map(CLK=>CLK, D=>IF_I  , Reset=>Reset,Enable=>Enable, Q=>ID_I);
IF_ID_RegPC:   RegisterN_reset generic map(n_bits=>32) port map(CLK=>CLK, D=>IF_PC , Reset=>zeroo,Enable=>Enable, Q=>ID_PC);

end Behavioral;
