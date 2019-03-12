library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity branchcontrol is
    Port ( PL : in STD_LOGIC_VECTOR(1 downto 0);
           BC : in STD_LOGIC_VECTOR(3 downto 0);
           PC : in STD_LOGIC_VECTOR (31 downto 0);
           AD : in STD_LOGIC_VECTOR (31 downto 0);
           Flags : in STD_LOGIC_VECTOR(3 downto 0);
           PCLoad : out STD_LOGIC;
           PCValue : out STD_LOGIC_VECTOR (31 downto 0);
           WR_Branch: out STD_LOGIC;
           PC_WR: out STD_LOGIC_VECTOR(31 downto 0)
           );
end branchcontrol;

architecture Behavioral of branchcontrol is

signal Z,N,P,C,V: std_logic;
signal Y: std_logic;
signal PCValue_buf: signed(31 downto 0);
begin

Z <= Flags(3);        -- zero flag
N <= Flags(2);        -- negative flag
P <= not N and not Z; -- positive flag
C <= FLags(1);        -- carry flag
V <= Flags(0);        -- overflow flag

-- Definir a l�gica relativa ao calculo do sinal PCLoad, o qual dever� ter o n�vel l�gico '1' sempre que
-- ocorrer uma instru��o de salto (branch), mas apenas nos casos em que a condi��o de salto � verdadeira.
-- Em todos os outros casos (i.e., a instru��o n�o � de branch, ou a condi��o de salto � falsa) o valor 
-- dever� ser zero.

Y<= 0 when BC(2 downto 0)="000" else
    1 when BC(2 downto 0)="001" else
    Z when BC(2 downto 0)="010" else 
    not(Z) when BC(2 downto 0)="011" else
    P when BC(2 downto 0)="100" else
    P or Z when BC(2 downto 0)="101" else
    N when BC(2 downto 0)="110" else
    N or Z;

PCLoad <= PL(1) and Y;

-- Calculo do novo valor de PC (caso a condicao de salto seja verdadeira)
PCValue_buf<=unsigned(PC)+signed(AD) when PL="10" else signed(AD) when PL="11" else unsigned(PC);
PCValue<=STD_LOGIC_VECTOR(PCValue_buf);
WR_Branch <= '1' when (PCLoad <='1' and BC(3)='1') or PL(1)='0' else '0';  


end Behavioral;
