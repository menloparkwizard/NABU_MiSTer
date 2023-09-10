library ieee; use ieee.std_logic_1164.all;

entity control_register is
  port ( ----------------------------------------------------------------------
    clkIn        : in    std_logic;
    rstIn        : in    std_logic;
    -------------------------------------------------------
    addrIn       : in    std_logic_vector(15 downto 00);
    dataIn       : in    std_logic_vector(07 downto 00);
    -------------------------------------------------------
    ioReqLowIn   : in    std_logic;
    z80WrLowIn   : in    std_logic;
    -------------------------------------------------------
    romSelLowOut :   out std_logic;
    vdoBufEnOut  :   out std_logic;
    prtStbOut    :   out std_logic;
    ledsOut      :   out std_logic_vector(02 downto 00));
end entity control_register;

architecture rtl of control_register is

  -- SIGNALS ------------------------------------------------------------------
  signal cntrlRegR  : std_logic_vector(07 downto 00);
  signal cntrlRegWr : std_logic;
  -----------------------------------------------------------------------------

begin

  -- OUTPUTS ------------------------------------------------------------------
  romSelLowOut <= cntrlRegR(7);
  vdoBufEnOut  <= cntrlRegR(0);
  prtStbOut    <= cntrlRegR(6);
  ledsOut      <= cntrlRegR(2) & cntrlRegR(5) & cntrlRegR(1);
  -----------------------------------------------------------------------------

  -- control register write enable bit
  cntrlRegWr <= '1' when (z80WrLowIn = '0' and ioReqLowIn = '0' and (addrIn(07) = '1' or addrIn(06) = '1')) else '0';

  RegProc : process (clkIn, rstIn) is
  begin
    if (rstIn = '1') then
      cntrlRegR <= (others => '0');
    elsif (rising_edge(clkIn)) then
      if (cntrlRegWr = '1') then
        cntrlRegR <= dataIn;
      end if;
    end if;
  end process RegProc;

end architecture rtl;