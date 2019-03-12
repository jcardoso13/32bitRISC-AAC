library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity InstructionDecode is
    Port ( Instruction : in STD_LOGIC_VECTOR (31 downto 0);
            -- Instruction operands (OF => Operand Fetch)
           AA       : out STD_LOGIC_VECTOR ( 3 downto 0);
           MA       : out STD_LOGIC;
           BA       : out STD_LOGIC_VECTOR ( 3 downto 0);
           MB       : out STD_LOGIC;
           KNS      : out STD_LOGIC_VECTOR (31 downto 0);
           -- execution control (EX => Execute)
           FS       : out STD_LOGIC_VECTOR ( 3 downto 0);
           --FW       : out STD_LOGIC_VECTOR ( 3 downto 0);
           PL       : out STD_LOGIC_VECTOR(1 downto 0);
           BC       : out STD_LOGIC_VECTOR ( 3 downto 0);
           -- memory control (MEM => Memory)
           MMA      : out STD_LOGIC_VECTOR ( 1 downto 0);
           MMB      : out STD_LOGIC_VECTOR ( 1 downto 0);
           MW       : out STD_LOGIC;
            -- Instruction Result (WB => Write-Back)
           MD       : out STD_LOGIC_VECTOR(1 downto 0);
           DA       : out STD_LOGIC_VECTOR ( 3 downto 0)
          );
end InstructionDecode;

architecture Structural of InstructionDecode is
type storage_type is array (0 to 63) of std_logic_vector(30 downto 0);

--------------------------------------------------------------------------------------------------------------------------------  
-- SIGNAL PARTIAL DESCRIPTION  
--------------------------------------------------------------------------------------------------------------------------------  
-- when KNSSel is
--   "000" -> constant KNS(31:0) is zero-extended   0,...,0,I(17:0)
--   "001" -> constant KNS(31:0) is signed-extended I(17),...,I(17),I(17:0)
--   "010" -> constant KNS(31:0) is signed-extended I(25),...,I(25),I(25:22),I(13:0)
--   "011" -> constant KNS(31:0) is signed-extended I(13),...,I(13),I(13:0)
--   "100" -> constant KNS(31:0) is 0000h & I(15:0)
--   "101" -> constant KNS(31:0) is FFFFh & I(15:0)
--   "110" -> constant KNS(31:0) is I(15:0) & 0000h
--   "111" -> constant KNS(31:0) is I(15:0) & FFFFh

-- when MASel is
--   "00" -> AA=SA,                 OpA is R[AA] 
--   "10" -> AA=DECODE_MEMORY_AA,   OpA is R[AA]
--   "-1" -> AA=dont'care           OpA is KNS 

-- when MBSel is
--   "00" -> BA=SB,                 OpB is R[BA] 
--   "10" -> BA=DECODE_MEMORY_BA,   OpB is R[BA]
--   "-1" -> BA=dont'care           OpB is KNS 

-- when MdSel is
--   "00" -> DA=DR,                 Destination is R[DR] 
--   "10" -> DA=DECODE_MEMORY_DA,   Destination is R[DA]
--   "01" -> DA=dont'care           Saves Mem, Destination is R[DR]
--   "11"  ->DA=ddA                 Saves PC+1, Destination is R[DA] (for J and B DA=R15) 

-- when MMA/MMB is
--   "00" -> Memory Address/DataIn is KNS 
--   "01" -> Memory Address/DataIn is R[AA]
--   "10" -> Memory Address/DataIn is R[BA]
--   "11" -> Memory Address/DataIn is Functional Unit Output

-- when PL is
-- "00" -> no branch
-- "10" -> Branch
-- "11" -> Jump

signal decode_memory: storage_type := (
-- UNCOMMENT THE LINES CORRESPONDING TO YOUR OPCODES
  --------------------------------------------------------------------------------------------------------------------------------  
  -- OPCODE =>  PL  &  dAA    & dBA     & dDA     &  FS     &  KNSSel &  MASel &  MBSel &  MMA   & MMB   &  MW  &  MDSel
  -- (decimal) (31-30) & (29-26) & (25-22) & (21-18) & (17-14) & (13-11) & (10-9) & (8-7)  & (6-5)  & (4-3) &  (2) & (1-0)  
  --------------------------------------------------------------------------------------------------------------------------------  
          000000 =>  "00" &   x"0"  &  x"0"   &  x"0"   &  x"0"   &  "---"  &  "00"  &  "00"  &  "--"  & "--"  &  '0' &  "00",  -- ADD    R[DR],R[SA],R[SB]
          000001 =>  "00" &   x"0"  &  x"0"   &  x"0"   &  x"0"   &  "001"  &  "00"  &  "-1"  &  "--"  & "--"  &  '0' &  "00",  -- ADDI   R[DR],R[SA],SIMM18
          000010 =>  "00" &   x"0"  &  x"0"   &  x"0"   &  x"3"   &  "---"  &  "00"  &  "00"  &  "--"  & "--"  &  '0' &  "00",  -- SUB    R[DR],R[SA],R[SB]
          000011 =>  "00" &   x"0"  &  x"0"   &  x"0"   &  x"3"   &  "001"  &  "00"  &  "-1"  &  "--"  & "--"  &  '0' &  "00",  -- SUBI   R[DR],R[SA],SIMM18
  --------------------------------------------------------------------------------------------------------------------------------  
  -- OPCODE =>  PL  &  dAA    & dBA     & dDA     &  FS     &  KNSSel &  MASel &  MBSel &  MMA   & MMB   &  MW  &  MDSel
  --------------------------------------------------------------------------------------------------------------------------------  
          000100 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- AND    R[DR],R[SA],R[SB]
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- ANDIL  R[DR],R[SA],IMM16
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- ANDIH  R[DR],R[SA],IMM16
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- NAND   R[DR],R[SA],R[SB]
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- OR     R[DR],R[SA],R[BA]
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- ORIL   R[DR],R[SA],IMM16
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- ORIH   R[DR],R[SA],IMM16
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- NOR    R[DR],R[SA],R[SB]
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- XOR    R[DR],R[SA],R[SB]
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- XNOR   R[DR],R[SA],R[SB]
  --------------------------------------------------------------------------------------------------------------------------------  
  -- OPCODE =>  PL  &  dAA    & dBA     & dDA     &  FS     &  KNSSel &  MASel &  MBSel &  MMA   & MMB   &  MW  &  MDSel
  --------------------------------------------------------------------------------------------------------------------------------  
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- LSL    R[DR],R[SB]
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- LSR    R[DR],R[SB]
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- ROL    R[DR],R[SB]
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- ROR    R[DR],R[SB]
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- ASL    R[DR],R[SB]
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- ASR    R[DR],R[SB]
  --------------------------------------------------------------------------------------------------------------------------------  
  -- OPCODE =>  PL  &  dAA    & dBA     & dDA     &  FS     &  KNSSel &  MASel &  MBSel &  MMA   & MMB   &  MW  &  MDSel
  --------------------------------------------------------------------------------------------------------------------------------  
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- LD     R[DA],(R[AA]+R[BA])
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "00",  -- LDI    R[DA],(R[AA]+SIMM18)
          0 =>  "00" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "01",  -- ST     (R[AA]+SIMM18),R[SB]
  --------------------------------------------------------------------------------------------------------------------------------  
  -- OPCODE =>  PL  &  dAA    & dBA     & dDA     &  FS     &  KNSSel &  MASel &  MBSel &  MMA   & MMB   &  MW  &  MDSel
  --------------------------------------------------------------------------------------------------------------------------------  
          0 =>  "10" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "11",  -- B.cond  (R[SA] cond R[SB]),SIMM14
          0 =>  "10" &   x"?"  &  x"?"   &  x"?"   &  x"?"   &  "???"  &  "??"  &  "??"  &  "??"  & "??"  &  '?' &  "11",  -- BI.cond (R[SA] cond SIMM14),R[SB]
     others =>  "00" &   x"0"  &  x"0"   &  x"0"   &  x"0"   &  "000"  &  "00"  &  "00"  &  "00"  & "00"  &  '0' &  "10"   -- NOP
   );

signal Opcode : std_logic_vector(5 downto 0);
signal mem_out : std_logic_vector(30 downto 0);

signal SA,dAA : std_logic_vector(3 downto 0);
signal SB,dBA : std_logic_vector(3 downto 0);
signal DR,dDA : std_logic_vector(3 downto 0);
signal MASel, MBSel, MDSel : std_logic_vector(1 downto 0);
signal KNSSel : std_logic_vector(2 downto 0);

begin

-- Retrieve Instruction Fields
Opcode <= Instruction(31 downto 26);
DR     <= Instruction(25 downto 22);
SA     <= Instruction(21 downto 18);
SB     <= Instruction(17 downto 14);
BC     <= Instruction(25 downto 22);

-- Constant value (KNS) is always extended to 32 bits, depending on KNSSel
with KNSSel select
    KNS  <= (31 downto 18=>'0') & Instruction(17 downto 0)             when "000",
            (31 downto 18=>Instruction(17)) & Instruction(17 downto 0) when "001",
            (31 downto 18=>Instruction(25)) & Instruction(25 downto 22) & Instruction(13 downto 0) when "010",
            (31 downto 14=>Instruction(13)) & Instruction(13 downto 0) when "011",
            (31 downto 16=>'0')             & Instruction(15 downto 0) when "100",
            (31 downto 16=>'1')             & Instruction(15 downto 0) when "101",
            Instruction(15 downto 0)        & (31 downto 16=>'0')      when "110",
            Instruction(15 downto 0)        & (31 downto 16=>'1')      when others;

-- Fetch decode bits from memory
mem_out <= decode_memory(to_integer(unsigned(Opcode)));

-- Assign memory outputs
PL    <= mem_out(31 downto 30);
dDA   <= mem_out(21 downto 18);
dAA   <= mem_out(29 downto 26);
dBA   <= mem_out(25 downto 22);
MASel <= mem_out(10 downto 9);
MBSel <= mem_out( 8 downto 7);
FS    <= mem_out(17 downto 14);
KNSSel<= mem_out(13 downto 11);
MMA   <= mem_out( 6 downto 5);
MMB   <= mem_out( 4 downto 3);
MW    <= mem_out( 2);
MDSel <= mem_out( 1 downto 0);

-- select registers to read from the Register File ("Unidade de Armazenamento")
with MASel(1) select
    AA <= SA  when '0',
          dAA when others; 

with MBSel(1) select
    BA <= SB  when '0',
          dBA when others; 

with MDSel(1) select
    DA <= DR  when '0',
          dDA when others;
           
MA <= MASel(0);
MB <= MBSel(0);
MD <= MDSel;

end Structural;
