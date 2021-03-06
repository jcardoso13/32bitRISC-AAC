library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity FiveStagePipeline is
  Port (
        CLK  : in std_logic;
        PC   : out std_logic_vector(31 downto 0); 
        I    : out std_logic_vector(31 downto 0);
        Data : out std_logic_vector(31 downto 0)
        );
end FiveStagePipeline;

architecture Structural of FiveStagePipeline is

component RegisterN is
    Generic (n_bits : integer := 32);
	port(	D: in std_logic_vector(n_bits-1 downto 0);
			Enable: in std_logic;
			CLK: in std_logic;
			Q: out std_logic_vector(n_bits-1 downto 0):=(others => '0')
			);
end component;

component InstructionFetch
    Port ( 
           CLK          : in std_logic;
           StageEnable  : in std_logic;
           PCLoadEnable : in std_logic;
           PCLoadValue  : in std_logic_vector(31 downto 0);
           Instruction  : out std_logic_vector(31 downto 0);
           PCCurrValue  : out std_logic_vector(31 downto 0)
         );
end component;

component IFID_Stage_Registers
    Port ( 
           CLK    : in STD_LOGIC;
           Enable : in STD_LOGIC;
           Reset:   in STD_LOGIC;
           IF_PC  : in STD_LOGIC_VECTOR (31 downto 0);
           IF_I   : in STD_LOGIC_VECTOR (31 downto 0);
           ID_PC  : out STD_LOGIC_VECTOR (31 downto 0);
           ID_I   : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component InstructionDecode
    Port ( Instruction : in STD_LOGIC_VECTOR (31 downto 0);
            -- Instruction operands (OF => Operand Fetch)
           AA       : out STD_LOGIC_VECTOR ( 3 downto 0);
           MA       : out STD_LOGIC_VECTOR(1 downto 0);
           BA       : out STD_LOGIC_VECTOR ( 3 downto 0);
           MB       : out STD_LOGIC_VECTOR(1 downto 0);
           KNS      : out STD_LOGIC_VECTOR (31 downto 0);
           --Stalls
           EX_DA: in STD_LOGIC_VECTOR(3 downto 0);
           MEM_DA: in STD_LOGIC_VECTOR(3 downto 0);
           EX_MD: in STD_LOGIC_VECTOR(1 downto 0);
           Disable  : out STD_LOGIC;
           Branch_Forward: out STD_LOGIC_VECTOR(1 downto 0);
           -- execution control (EX => Execute)
           FS       : out STD_LOGIC_VECTOR ( 3 downto 0);
           PL       : out STD_LOGIC_VECTOR (1 downto 0);
           BC       : out STD_LOGIC_VECTOR ( 3 downto 0);
           -- memory control (MEM => Memory)
           MMA      : out STD_LOGIC_VECTOR ( 1 downto 0);
           MMB      : out STD_LOGIC_VECTOR ( 1 downto 0);
           MW       : out STD_LOGIC;
            -- Instruction Result (WB => Write-Back)
           MD       : out STD_LOGIC_VECTOR(1 downto 0);
           DA       : out STD_LOGIC_VECTOR ( 3 downto 0)
          );
end component;

component IDEX_Stage_Registers
    Port ( 
        CLK    : in STD_LOGIC;
        Enable : in STD_LOGIC;
        Reset  : in STD_LOGIC;  
        ID_PC  : in STD_LOGIC_VECTOR (31 downto 0);
        ID_I   : in STD_LOGIC_VECTOR (31 downto 0);
        ID_A   : in STD_LOGIC_VECTOR (31 downto 0);
        ID_B   : in STD_LOGIC_VECTOR (31 downto 0);
        ID_KNS : in STD_LOGIC_VECTOR (31 downto 0);
        ID_MA  : in STD_LOGIC_VECTOR(1 downto 0);
        ID_MB  : in STD_LOGIC_VECTOR(1 downto 0);
        ID_FS  : in STD_LOGIC_VECTOR (3 downto 0);
        ID_PL  : in STD_LOGIC_VECTOR( 1 downto 0);
        ID_BC  : in STD_LOGIC_VECTOR (3 downto 0);
        ID_MMA : in STD_LOGIC_VECTOR (1 downto 0);
        ID_MMB : in STD_LOGIC_VECTOR (1 downto 0);
        ID_MW  : in STD_LOGIC;
        ID_MD  : in STD_LOGIC_VECTOR(1 downto 0);
        ID_DA  : in STD_LOGIC_VECTOR (3 downto 0);
        EX_PC  : out STD_LOGIC_VECTOR (31 downto 0);
        EX_I   : out STD_LOGIC_VECTOR (31 downto 0);
        EX_A   : out STD_LOGIC_VECTOR (31 downto 0);
        EX_B   : out STD_LOGIC_VECTOR (31 downto 0);
        EX_KNS : out STD_LOGIC_VECTOR (31 downto 0);
        EX_MA  : out STD_LOGIC_VECTOR(1 downto 0);
        EX_MB  : out STD_LOGIC_VECTOR(1 downto 0);
        EX_FS  : out STD_LOGIC_VECTOR (3 downto 0);
        EX_PL  : out STD_LOGIC_VECTOR( 1 downto 0);
        EX_BC  : out STD_LOGIC_VECTOR (3 downto 0);
        EX_MMA : out STD_LOGIC_VECTOR (1 downto 0);
        EX_MMB : out STD_LOGIC_VECTOR (1 downto 0);
        EX_MW  : out STD_LOGIC;
        EX_MD  : out STD_LOGIC_VECTOR(1 downto 0);
        EX_DA  : out STD_LOGIC_VECTOR (3 downto 0)
       );
end component;

component Execute
  Port (
    A      : in std_logic_vector(31 downto 0); 
    B      : in std_logic_vector(31 downto 0);
    MA     : in std_logic_vector(1 downto 0);
    MB     : in std_logic_vector(1 downto 0);
    KNS    : in std_logic_vector(31 downto 0); 
    FS     : in std_logic_vector( 3 downto 0);
    PL     : in std_logic_vector(1 downto 0);
    BC     : in std_logic_vector( 3 downto 0);
    PC     : in std_logic_vector(31 downto 0);
    Branch_Forward: in STD_LOGIC_VECTOR(1 downto 0);
    MEM_ALUData: in std_logic_vector(31 downto 0);
    WB_ALUData: in std_logic_vector(31 downto 0);
    PCLoadValue : out std_logic_vector(31 downto 0);
    PCLoadEnable : out std_logic;
    DataD  : out std_logic_vector(31 downto 0);
    WR_Branch: out std_logic;
    PC_WR: out std_logic_vector(31 downto 0)
  );
end component;

component EXMEM_Stage_Registers
    Port ( 
        CLK     : in STD_LOGIC;
        Enable  : in STD_LOGIC;
        EX_PC   : in STD_LOGIC_VECTOR (31 downto 0);
        EX_I    : in STD_LOGIC_VECTOR (31 downto 0);
        EX_A    : in STD_LOGIC_VECTOR (31 downto 0);
        EX_B    : in STD_LOGIC_VECTOR (31 downto 0);
        EX_D    : in STD_LOGIC_VECTOR (31 downto 0);
        EX_KNS  : in STD_LOGIC_VECTOR (31 downto 0);
        EX_MMA  : in STD_LOGIC_VECTOR (1 downto 0);
        EX_MMB  : in STD_LOGIC_VECTOR (1 downto 0);
        EX_MW   : in STD_LOGIC;
        EX_MD   : in STD_LOGIC_VECTOR(1 downto 0);
        EX_PC_WR: in STD_LOGIC_VECTOR(31 downto 0);
        EX_WR:    in STD_LOGIC;
        EX_DA   : in STD_LOGIC_VECTOR (3 downto 0);
        Forwarding: in STD_LOGIC_VECTOR(1 downto 0);
        StallData: in STD_LOGIC_VECTOR(31 downto 0);
        MEM_PC  : out STD_LOGIC_VECTOR (31 downto 0);
        MEM_I   : out STD_LOGIC_VECTOR (31 downto 0);
        MEM_A   : out STD_LOGIC_VECTOR (31 downto 0);
        MEM_B   : out STD_LOGIC_VECTOR (31 downto 0);
        MEM_D   : out STD_LOGIC_VECTOR (31 downto 0);
        MEM_KNS : out STD_LOGIC_VECTOR (31 downto 0);
        MEM_MMA : out STD_LOGIC_VECTOR (1 downto 0);
        MEM_MMB : out STD_LOGIC_VECTOR (1 downto 0);
        MEM_MW  : out STD_LOGIC;
        MEM_MD  : out STD_LOGIC_VECTOR(1 downto 0);
        MEM_PC_WR: out STD_LOGIC_VECTOR(31 downto 0);
        MEM_WR  : out STD_LOGIC;
        MEM_Forwarding: out STD_LOGIC_VECTOR(1 downto 0);
        StalledData: out STD_LOGIC_VECTOR(31 downto 0);
        MEM_DA  : out STD_LOGIC_VECTOR (3 downto 0)
   );
end component;

component Memory is
  Port (
    CLK   : in std_logic;
    StageEnable: in std_logic;
    A     : in std_logic_vector(31 downto 0); 
    B     : in std_logic_vector(31 downto 0);
    KNS   : in std_logic_vector(31 downto 0);
    Din   : in std_logic_vector(31 downto 0);
    MMA   : in std_logic_vector( 1 downto 0);
    MMB   : in std_logic_vector( 1 downto 0);
    MW    : in std_logic;
    Dout  : out std_logic_vector(31 downto 0)
  );
end component;

component MEMWB_Stage_Registers
    Port ( 
        CLK      : in STD_LOGIC;
        Enable   : in STD_LOGIC;
        MEM_PC   : in STD_LOGIC_VECTOR (31 downto 0);
        MEM_I    : in STD_LOGIC_VECTOR (31 downto 0);
        MEM_DMem : in STD_LOGIC_VECTOR (31 downto 0);
        MEM_DALU : in STD_LOGIC_VECTOR (31 downto 0);
        MEM_MD   : in STD_LOGIC_VECTOR(1 downto 0);
        MEM_DA   : in STD_LOGIC_VECTOR (3 downto 0);
        MEM_PC_WR: in STD_LOGIC_VECTOR(31 downto 0);
        MEM_WR:   in STD_LOGIC;
        WB_PC    : out STD_LOGIC_VECTOR (31 downto 0);
        WB_I     : out STD_LOGIC_VECTOR (31 downto 0);
        WB_DMem  : out STD_LOGIC_VECTOR (31 downto 0);
        WB_DALU  : out STD_LOGIC_VECTOR (31 downto 0);
        WB_MD    : out STD_LOGIC_VECTOR(1 downto 0);
        WB_PC_WR :  out STD_LOGIC_VECTOR(31 downto 0);
        WB_WR   : out STD_LOGIC;
        WB_DA    : out STD_LOGIC_VECTOR (3 downto 0)
    );
end component;

component WriteBack
  Port (
        Enable   : in STD_LOGIC;
        DA       : in STD_LOGIC_VECTOR(3 downto 0);
        MD       : in STD_LOGIC_VECTOR(1 downto 0);
        PC_WR    : in STD_LOGIC_VECTOR(31 downto 0);
        ALUData  : in STD_LOGIC_VECTOR(31 downto 0);
        MemData  : in STD_LOGIC_VECTOR(31 downto 0);
        WR       : out STD_LOGIC;
        RFData   : out STD_LOGIC_VECTOR(31 downto 0)
        );
end component;

component RegisterFile
    Generic (n_bits : natural := 32);
    Port ( CLK : in std_logic;
           Data : in std_logic_vector (n_bits-1 downto 0);
           DA : in std_logic_vector (3 downto 0);
           WR: in std_logic;
           AA : in std_logic_vector (3 downto 0);
           BA : in std_logic_vector (3 downto 0);
           A : out std_logic_vector (n_bits-1 downto 0);
           B : out std_logic_vector (n_bits-1 downto 0));
end component;


signal EnableIF, EnableID, EnableEX, EnableMEM, EnableWB : std_logic;

-- Instruction & PC signals
signal IF_Instruction, ID_Instruction, EX_Instruction, MEM_Instruction, WB_Instruction : std_logic_vector(31 downto 0);
signal IF_PC, ID_PC, EX_PC, MEM_PC, WB_PC, EX_PCLoadValue : std_logic_vector(31 downto 0);
signal ID_BC, EX_BC : std_logic_vector(3 downto 0);
signal EX_PCLoadEnable : std_logic;
signal EX_PL, ID_PL: std_logic_vector(1 downto 0);
signal Branch_Forward,EX_Branch_Forward: std_logic_vector(1 downto 0);

-- RF addressing and operand selection signals
signal ID_AA, ID_BA, ID_DA, EX_DA, MEM_DA, WB_DA ,EX_BA: std_logic_vector(3 downto 0);
signal ID_MA, EX_MA, ID_MB, EX_MB : std_logic_vector(1 downto 0);
signal ID_MMA, EX_MMA, MEM_MMA, ID_MMB, EX_MMB, MEM_MMB : std_logic_vector(1 downto 0);
signal ID_MD, EX_MD, MEM_MD, WB_MD : std_logic_vector(1 downto 0);

-- Functional Unit and Memory Operation Signals
signal ID_FS, EX_FS : std_logic_vector(3 downto 0);
signal ID_MW, EX_MW, MEM_MW : std_logic;

-- Data Signals
signal ID_KNS, EX_KNS, MEM_KNS : std_logic_vector(31 downto 0);
signal ID_A, EX_A, MEM_A: std_logic_vector(31 downto 0);
signal ID_B, EX_B, MEM_B: std_logic_vector(31 downto 0);
signal EX_ALUData, MEM_ALUData, WB_ALUData: std_logic_vector(31 downto 0);
signal MEM_MemData, WB_MemData,Data_IN_MEM_buf: std_logic_vector(31 downto 0);
signal WB_RFData: std_logic_vector(31 downto 0);


signal EX_PC_WR,MEM_PC_WR,WB_PC_WR: std_logic_vector(31 downto 0);
signal EX_WR,MEM_WR,WB_WR: std_logic;
signal Forwarding,MEM_Forwarding: std_logic_vector(1 downto 0);
signal StallData,StalledData:std_logic_vector(31 downto 0);
signal Data_IN_MEM: std_logic_vector(31 downto 0);
signal ID_Disable,Disable,ID_Flush,WR,Reset2:std_logic;

signal aux1:unsigned(31 downto 0);

begin

EnableIF<=not(Disable);
EnableID<=not(Disable);
EnableEX<='1';
EnableMEM<='1';
EnableWB<='1';

-- Passing BA from ID->EX
 I_BA:RegisterN generic map(n_bits=>4) port map(CLK=>CLK, D=>ID_BA,     Enable=>'1', Q=>EX_BA);
-- Pasing branch forward from ID->EX
I_Branch:RegisterN generic map(n_bits=>2) port map(CLK=>CLK, D=>Branch_Forward,     Enable=>'1', Q=>EX_Branch_Forward);

--------------------------------------------------------------------------------------------------------------------------
-- IF Stage
--------------------------------------------------------------------------------------------------------------------------
-- Instruction Fetch (IF) Stage Logic
IFetch: InstructionFetch port map(CLK=>CLK, StageEnable=>EnableIF, PCLoadEnable=>EX_PCLoadEnable, PCLoadValue=>EX_PCLoadValue, Instruction=>IF_Instruction, PCCurrValue=>IF_PC);
-- Registers between IF and ID Stage
IF2ID: IFID_Stage_Registers port map(CLK=>CLK, Enable=>EnableIF, Reset=>EX_PCLoadEnable,
    IF_PC=>IF_PC, IF_I=>IF_Instruction, 
    ID_PC=>ID_PC, ID_I=>ID_Instruction);

Reset2<=EX_PCLoadEnable or Disable;
--------------------------------------------------------------------------------------------------------------------------
-- ID Stage
--------------------------------------------------------------------------------------------------------------------------
-- Instruction Decode (ID) Stage
ID: InstructionDecode port map(Instruction=>ID_Instruction,Branch_Forward=>Branch_Forward, AA=>ID_AA, MA=>ID_MA, BA=>ID_BA, MB=>ID_MB, KNS=>ID_KNS, FS=>ID_FS, PL=>ID_PL, BC=>ID_BC, MMA=>ID_MMA, MMB=>ID_MMB, MW=>ID_MW, MD=>ID_MD, DA=>ID_DA,Disable=>ID_Disable,EX_DA=>EX_DA,MEM_DA=>MEM_DA,EX_MD=>EX_MD);
-- Registers between ID and EX Stage
ID2EX: IDEX_Stage_Registers port map(CLK=>CLK, Enable=>EnableID, Reset=>Reset2,
    ID_I=>ID_Instruction, ID_PC=>ID_PC, ID_A=>ID_A, ID_B=>ID_B, ID_KNS=>ID_KNS, ID_MA=>ID_MA, ID_MB=>ID_MB, ID_MMA=>ID_MMA, ID_MMB=>ID_MMB, ID_MW=>ID_MW, ID_FS=>ID_FS, ID_PL=>ID_PL, ID_BC=>ID_BC, ID_MD=>ID_MD, ID_DA=>ID_DA,
    EX_I=>EX_Instruction, EX_PC=>EX_PC, EX_A=>EX_A, EX_B=>EX_B, EX_KNS=>EX_KNS, EX_MA=>EX_MA, EX_MB=>EX_MB, EX_MMA=>EX_MMA, EX_MMB=>EX_MMB, EX_MW=>EX_MW, EX_FS=>EX_FS, EX_PL=>EX_PL, EX_BC=>EX_BC, EX_MD=>EX_MD, EX_DA=>EX_DA);

aux1<=unsigned(MEM_PC)-unsigned(EX_PC);
Disable<='1' when aux1/=x"0" and ID_Disable='1' else '0';
--------------------------------------------------------------------------------------------------------------------------
-- EX Stage
--------------------------------------------------------------------------------------------------------------------------
EX: Execute port map(A => EX_A, B => EX_B, MA=>EX_MA, MB=>EX_MB, KNS=>EX_KNS,Branch_Forward=>EX_Branch_Forward, FS=>EX_FS, PL=>EX_PL, BC=>EX_BC, PC=>EX_PC, PCLoadEnable=>EX_PCLoadEnable, PCLoadValue=>EX_PCLoadValue, WB_ALUData=>WB_RFData,MEM_ALUData=>MEM_ALUData,DataD=>EX_ALUData, WR_Branch=>EX_WR,PC_WR=>EX_PC_WR);
-- Registers between EX and MEM Stage
EX2MEM: EXMEM_Stage_Registers port map(CLK=>CLK, Enable=>EnableEX, 
     EX_I=>EX_Instruction,   EX_PC=>EX_PC,   EX_A=>EX_A,   EX_B=>EX_B,   EX_KNS=>EX_KNS,   EX_D=>EX_ALUData,   EX_MMA=>EX_MMA,   EX_MMB=>EX_MMB,   EX_MW=>EX_MW,   EX_MD=>EX_MD,   EX_DA=>EX_DA, EX_WR => EX_WR, EX_PC_WR => EX_PC_WR,Forwarding=>Forwarding,StallData=>StallData,
    MEM_I=>MEM_Instruction, MEM_PC=>MEM_PC, MEM_A=>MEM_A, MEM_B=>MEM_B, MEM_KNS=>MEM_KNS, MEM_D=>MEM_ALUData, MEM_MMA=>MEM_MMA, MEM_MMB=>MEM_MMB, MEM_MW=>MEM_MW, MEM_MD=>MEM_MD, MEM_DA=>MEM_DA, MEM_WR=>MEM_WR,MEM_PC_WR=>MEM_PC_WR,MEM_Forwarding=>MEM_Forwarding,StalledData=>StalledData);


--Forwarding for Store Instructions
Forwarding<="11" when(EX_MMB="10" and WB_DA=EX_BA) else
            "10" when (EX_MMB="10" and MEM_DA=EX_BA) else
            "00";
StallData<=WB_RFData;

--Data_IN_MEM<=WB_RFData when MEM_Forwarding<="10" else
  --       StalledData when MEM_Forwarding<="11" else
    --     MEM_B when MEM_Forwarding<="00" else
      --  MEM_B;

Data_IN_MEM_buf<=WB_RFData when MEM_Forwarding(0)='0' else StalledData;
Data_IN_MEM<= MEM_B when MEM_Forwarding(1)='0' else Data_IN_MEM_buf;
--


--------------------------------------------------------------------------------------------------------------------------
-- MEM Stage
--------------------------------------------------------------------------------------------------------------------------
MEM: Memory port map(CLK=>CLK, StageEnable=>EnableMEM, A =>MEM_A, B => Data_IN_MEM, Din=>MEM_ALUData, KNS=>MEM_KNS, MMA=>MEM_MMA, MMB=>MEM_MMB, MW=>MEM_MW, Dout=>MEM_MemData);
-- Registers between MEM and WB Stage
MEM2WB: MEMWB_Stage_Registers port map(CLK=>CLK, Enable=>EnableMEM, 
    MEM_I=>MEM_Instruction, MEM_PC=>MEM_PC, MEM_DALU=>MEM_ALUData, MEM_DMem=>MEM_MemData, MEM_MD=>MEM_MD, MEM_DA=>MEM_DA, MEM_WR=>MEM_WR,MEM_PC_WR=>MEM_PC_WR,
     WB_I=>WB_Instruction,   WB_PC=>WB_PC,   WB_DALU=>WB_ALUData,   WB_DMem=>WB_MemData,   WB_MD=>WB_MD,   WB_DA=>WB_DA,WB_WR=>WB_WR,WB_PC_WR=>WB_PC_WR);

--------------------------------------------------------------------------------------------------------------------------
-- WB Stage
--------------------------------------------------------------------------------------------------------------------------
WB: WriteBack port map(enable=>WB_WR, DA=>WB_DA, MD=>WB_MD,WR=>WR,ALUData=>WB_ALUData, MemData=>WB_MemData, RFData=>WB_RFData,PC_WR=>WB_PC_WR);

--------------------------------------------------------------------------------------------------------------------------
-- Register File
--------------------------------------------------------------------------------------------------------------------------
RF: RegisterFile generic map(n_bits=>32) port map(CLK=>CLK,WR=>WR, Data=>WB_RFData, DA=>WB_DA, AA=>ID_AA, BA=>ID_BA, A=>ID_A, B=>ID_B); 

--------------------------------------------------------------------------------------------------------------------------
-- Output
--------------------------------------------------------------------------------------------------------------------------
Data<=WB_RFData;
I<=ID_Instruction;
PC<=ID_PC;

end Structural;
