library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Execute is
  Generic (n_bits : integer := 32);
  Port (
    A      : in std_logic_vector(n_bits-1 downto 0); 
    B      : in std_logic_vector(n_bits-1 downto 0);
    MA     : in std_logic_vector(1 downto 0);
    MB     : in std_logic_vector(1 downto 0);
    KNS    : in std_logic_vector(n_bits-1 downto 0); 
    FS     : in std_logic_vector( 3 downto 0);
    PL     : in std_logic_vector(1 downto 0);
    BC     : in std_logic_vector( 3 downto 0);
    PC     : in std_logic_vector(31 downto 0);
    Branch_Forward: in STD_LOGIC_VECTOR(1 downto 0);
    MEM_ALUData: in std_logic_vector(31 downto 0);
    WB_ALUData: in std_logic_vector(31 downto 0);
    PCLoadValue : out std_logic_vector(31 downto 0);
    PCLoadEnable : out std_logic;
    DataD  : out std_logic_vector(n_bits-1 downto 0) ;
    WR_Branch: out std_logic;
    PC_WR: out std_logic_vector(31 downto 0)
  );
end Execute;

architecture Structural of Execute is

component FunctionalUnit
  Generic (n_bits : integer := 32);
    Port ( A : in std_logic_vector (n_bits-1 downto 0);
           B : in std_logic_vector (n_bits-1 downto 0);
           FS : in std_logic_vector (3 downto 0);
           D : out std_logic_vector (n_bits-1 downto 0);
           FL : out std_logic_vector (3 downto 0));
end component;

component branchcontrol
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
end component;

signal OpA, OpB, AD : std_logic_vector(n_bits-1 downto 0);
signal Flags : std_logic_vector(3 downto 0); -- {Z,C,N,V}

begin

-- select operands for the functional unit
--with MA select 
  --  OpA <= A when '0',
    --     KNS when others;
OpA<= A when MA="00" else
      MEM_ALUData when MA="10" else
      WB_ALUData when MA="11" else
      KNS;

OpB<= B when MB="00" else
      MEM_ALUData when MB="10" else
      WB_ALUData when MB="11" else
      KNS;
--with MB select 
  --  OpB <= B when '0',
    --       KNS when others;

--with MB(0) select 
   -- AD <= KNS when '0',
     --     B when others;
AD<= MEM_ALUData when Branch_Forward="10" else
    WB_ALUData when  Branch_Forward="11" else
    B when        Branch_Forward="01" else
    KNS;

-- instantiate the functional unit
ALU: FunctionalUnit port map( A => OpA , B => OpB , FS => FS, D => DataD, FL => Flags);

-- instantiate the Branch Control Unit
UCS: BranchControl port map(PL=>PL, BC=>BC, PC=>PC, AD=>AD, Flags=>Flags, PCLoad=>PCLoadEnable, PCValue=>PCLoadValue, WR_Branch =>WR_Branch, PC_WR=>PC_WR);

end Structural;
