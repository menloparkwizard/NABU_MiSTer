library ieee; use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- Address Decoder - 
--   This module combines the functions of several chips on the board that 
--   enable other functions throughout the computer based on the bus address
--   and other control bits. 
--   
--   U10 - LS138
--   The LS138 is a 3 to 8 decoder/demultiplexor with 3 additional enable bits.
--   In the NABU system Address lines A4-A6 are used as the 3 inputs with A7
--   being tied to E3 (E1 and E2 are grounded). For simplicity, the whole
--   address bus is brought into this module.
--
--   U57, U55
--
-------------------------------------------------------------------------------

entity addr_decoder is
  port ( ----------------------------------------------------------------------
    addrIn        : in    std_logic_vector(15 downto 00);
    -------------------------------------------------------
    memReqLowIn   : in    std_logic;
    romSelLowIn   : in    std_logic;
    z80RdLowIn    : in    std_logic;
    z80WrLowIn    : in    std_logic;
    -------------------------------------------------------
    -- U10 - LS138 outputs
    cs3LowOut     :   out std_logic; -- Y7
    cs2LowOut     :   out std_logic; -- Y6
    cs1LowOut     :   out std_logic; -- Y5
    cs0LowOut     :   out std_logic; -- Y4
    prtEnLowOut   :   out std_logic; -- Y3
    vdpEnLowOut   :   out std_logic; -- Y2
    keyBdEnLowOut :   out std_logic; -- Y1
    hccaEnLowOut  :   out std_logic; -- Y0
    -------------------------------------------------------
    romCeLowOut   :   out std_logic); 
end entity addr_decoder;

architecture rtl of addr_decoder is

begin

  -------------------------------------------------------------------------------------------------
  -- U10 - LS138 combinatorial outputs
  -- | NABU SCHEM | LS138 DS | HDL Signal |
  -- + ---------- + -------- + ---------- + 
  -- |    a0      |    A     | addrIn(4)  |
  -- |    a1      |    B     | addrIn(5)  |
  -- |    a2      |    C     | addrIn(6)  |
  -- |    e3      |    G1    | addrIn(7)  |
  -- + ---------- + -------- + ---------- +

  hccaEnLowOut  <= '0' when (addrIn(07 downto 04) = "1000") else '1';
  keyBdEnLowOut <= '0' when (addrIn(07 downto 04) = "1001") else '1';
  vdpEnLowOut   <= '0' when (addrIn(07 downto 04) = "1010") else '1';
  prtEnLowOut   <= '0' when (addrIn(07 downto 04) = "1011") else '1';
  cs0LowOut     <= '0' when (addrIn(07 downto 04) = "1100") else '1';
  cs1LowOut     <= '0' when (addrIn(07 downto 04) = "1101") else '1';
  cs2LowOut     <= '0' when (addrIn(07 downto 04) = "1110") else '1';
  cs3LowOut     <= '0' when (addrIn(07 downto 04) = "1111") else '1';
  -------------------------------------------------------------------------------------------------

  -------------------------------------------------------------------------------------------------
  -- U53 ROM Chip Enable
  rom_ce_blk : block
    signal upperAddressesAreLow : std_logic;
  begin
    -- This bit is equivalent to the output of the U55 NOR gate, the U56 inverter is omitted
    -- TODO: Handle 4K vs 8K jumpers w/ address bit 12
    upperAddressesAreLow <= '1' when (addrIn(15 downto 12) = "0000") else '0';
    romCeLowOut          <= '0' when (romSelLowIn = '0' and memReqLowIn = '0' and z80RdLowIn = '0' and upperAddressesAreLow = '1') else '1';
  end block rom_ce_blk;
end architecture rtl;