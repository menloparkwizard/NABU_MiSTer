library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;
              use ieee.math_real.all;


entity clock_enable_generator is
  port ( ----------------------------------------------------------------------
    clkSysIn   : in    std_logic;
    rstSysIn   : in    std_logic;
    -------------------------------------------------------
    ce10p7In   : in    std_logic;
    -------------------------------------------------------
    ce3p58POut :   out std_logic;
    ce3p58NOut :   out std_logic;
    ce1p79POut :   out std_logic;
    ce1p79NOut :   out std_logic);
end entity clock_enable_generator;

architecture rtl of clock_enable_generator is

  -- CONSTANTS ----------------------------------------------------------------
  constant CE_10P7                : real    := 10.7;
  constant CE_3P58_DIVIDE_CNT     : integer := integer(ceil(CE_10P7/3.58));
  constant CE_3P58_DIVIDE_CNT_LEN : integer := integer(ceil(log(real(CE_3P58_DIVIDE_CNT))/log(2.0)));

  constant CE_1P79_DIVIDE_CNT     : integer := integer(ceil(CE_10P7/1.79));
  constant CE_1P79_DIVIDE_CNT_LEN : integer := integer(ceil(log(real(CE_1P79_DIVIDE_CNT))/log(2.0)));

  -- SIGNALS ------------------------------------------------------------------
  signal sClk3p58DividerCntR : unsigned(CE_3P58_DIVIDE_CNT_LEN-1 downto 00);
  signal sClk1p79DividerCntR : unsigned(CE_1P79_DIVIDE_CNT_LEN-1 downto 00);

  signal sCe3p58R            : std_logic;
  signal sCe1p79R            : std_logic;

begin

  -- OUTPUTS ------------------------------------------------------------------
  ce3p58POut <= sCe3p58R;
  ce3p58NOut <= not(sCe3p58R);
  ce1p79POut <= sCe1p79R;
  ce1p79NOut <= not(sCe1p79R);
  -----------------------------------------------------------------------------

  ClkDivProc : process (clkSysIn, rstSysIn) is
  begin
    if (rstSysIn = '1') then
      sClk3p58DividerCntR <= (others => '0');
      sClk1p79DividerCntR <= (others => '0');
      sCe3p58R            <= '0';
      sCe1p79R            <= '0';
    elsif (rising_edge(clkSysIn)) then
      if (ce10p7In = '1') then
        ---------------------------------------------------
        -- 3.58MHz Clock Enable Divider
        if (sClk3p58DividerCntR = 0) then
          -- reset counter value
          sClk3p58DividerCntR <= to_unsigned(CE_3P58_DIVIDE_CNT-1, sClk3p58DividerCntR'length);
          sCe3p58R            <= not(sCe3p58R);
        else
          -- decrement counter value by 1
          sClk3p58DividerCntR <= sClk3p58DividerCntR - 1;
        end if;
        ---------------------------------------------------

        ---------------------------------------------------
        -- 1.79MHz Clock Enable Divider
        if (sClk1p79DividerCntR = 0) then
          sClk1p79DividerCntR <= to_unsigned(CE_1P79_DIVIDE_CNT-1, sClk1p79DividerCntR'length);
          sCe1p79R            <= not(sCe1p79R);
        else
          -- decrement divider count by 1
          sClk1p79DividerCntR <= sClk1p79DividerCntR - 1;
        end if;
        ---------------------------------------------------
      end if;
    end if;
  end process ClkDivProc;

end architecture rtl;