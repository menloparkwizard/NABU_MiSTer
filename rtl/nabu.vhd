library ieee; use ieee.std_logic_1164.all;

library work; use work.nabu_pkg.all;

entity nabu is
  port ( ----------------------------------------------------------------------
    -- Clock and Reset
    clkSysIn     : in    std_logic;
    rstSysIn     : in    std_logic;
    -------------------------------------------------------
    -- Clock Enables
    ce10p7In     : in    std_logic;
    -------------------------------------------------------
    palIn        : in    std_logic;
    scandoubleIn : in    std_logic;
    -------------------------------------------------------
    cePixOut     :   out std_logic;
    -------------------------------------------------------
    hBlankOut    :   out std_logic;
    hSyncOut     :   out std_logic;
    vBlankOut    :   out std_logic;
    vSyncOut     :   out std_logic;
    -------------------------------------------------------
    videoOut     :   out std_logic_vector(07 downto 00));
end entity nabu;

architecture rtl of nabu is
  -- SIGNALS ------------------------------------------------------------------
  signal sRstN               : std_logic;
  signal sCe3p58P            : std_logic;
  signal sCe3p58N            : std_logic;
  signal sCe1p79P            : std_logic;
  signal sCe1p79N            : std_logic;

  -- system control
  signal sMachineCycleOneLow : std_logic;
  signal sMemoryRequestLow   : std_logic;
  signal sInputOutputReqLow  : std_logic;
  signal sRefreshLow         : std_logic;
  signal sMemRdLow           : std_logic;
  signal sMemWrLow           : std_logic;

  -- cpu control
  signal sHaltLow             : std_logic;
  signal sWaitLow             : std_logic;
  signal sInterruptReqLow     : std_logic;
  signal sNonMaskInterruptLow : std_logic;
  signal sCpuRegsDebug        : std_logic_vector(211 downto 000);

  -- cpu bus control
  signal sBusRequestLow       : std_logic;
  signal sBusAckLow           : std_logic;

  -- system addr/data bus
  signal sAddrBus             : std_logic_vector(15 downto 00);
  signal sDataBus             : std_logic_vector(07 downto 00);
  signal sDataToCpu           : std_logic_vector(07 downto 00);
  signal sDataFromCpu         : std_logic_vector(07 downto 00);

  -- module enables
  signal romCeLow             : std_logic;

  -- control register signals
  signal romSelLow            : std_logic;
  signal leds                 : std_logic_vector(02 downto 00);
begin

  -----------------------------------------------------------------------------
  -- Clocks and Resets
  sRstN <= not(rstSysIn);
  clk_en_gen_inst : entity work.clock_enable_generator(rtl)
    port map ( ----------------------------------------------------------------
      clkSysIn  => clkSysIn,
      rstSysIn  => rstSysIn,
      -----------------------------------------------------
      ce10p7In  => ce10p7In,
      -----------------------------------------------------
      ce3p58POut => sCe3p58P,
      ce3p58NOut => sCe3p58N,
      ce1p79POut => sCe1p79P,
      ce1p79NOut => sCe1p79N
    ); ------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Z80 Processor (U54)
  sBusRequestLow       <= '1';
  sNonMaskInterruptLow <= '1';

  z80_proc_inst : entity work.T80pa(rtl)
    generic map ( -------------------------------------------------------------
      Mode       => 0)
    port map ( ----------------------------------------------------------------
      RESET_n    => sRstN,
      CLK        => clkSysIn,
      CEN_p      => sCe3p58P,
      CEN_n      => sCe3p58N,
      WAIT_n     => sWaitLow,
      INT_n      => sInterruptReqLow,
      NMI_n      => sNonMaskInterruptLow,
      BUSRQ_n    => sBusRequestLow,
      M1_n       => sMachineCycleOneLow,
      MREQ_n     => sMemoryRequestLow,
      IORQ_n     => sInputOutputReqLow,
      RD_n       => sMemRdLow,
      WR_n       => sMemWrLow,
      RFSH_n     => sRefreshLow,
      HALT_n     => sHaltLow,
      BUSAK_n    => sBusAckLow,
      A          => sAddrBus,
      DI         => sDataToCpu,
      DO         => sDataFromCpu,
      R800_mode  => '0',
      REG        => sCpuRegsDebug,
      DIRSet     => '0',
      DIR        => (211 downto 000 => '0')
    ); ------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Enable Generators - Address Decoder
  enable_generator_inst : entity work.addr_decoder(rtl)
    port map ( ----------------------------------------------------------------
      addrIn        => sAddrBus,
      -----------------------------------------------------
      memReqLowIn   => sMemoryRequestLow,
      romSelLowIn   => romSelLow,
      z80RdLowIn    => sMemRdLow,
      z80WrLowIn    => sMemWrLow,
      -----------------------------------------------------
      cs3LowOut     => open,
      cs2LowOut     => open,
      cs1LowOut     => open,
      cs0LowOut     => open,
      prtEnLowOut   => open,
      vdpEnLowOut   => open,
      keyBdEnLowOut => open,
      hccaEnLowOut  => open,
      -----------------------------------------------------
      romCeLowOut   => romCeLow
    ); ------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- 4K/8K PROM (U53)
  prom_inst : entity work.sp_rom_async(rtl)
    generic map ( -------------------------------------------------------------
      INIT_DATA => PROM_DATA_4K)
    port map ( ----------------------------------------------------------------
      clkIn     => clkSysIn,
      addrIn    => sAddrBus,
      enIn      => romCeLow,
      dataOut   => sDataBus
    ); ------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------
  
  -----------------------------------------------------------------------------
  -- U6 - Control Register
  -- Octal D-Type Flip-Flop with Clear, functionality modeled based on LS273
  control_reg_inst : entity work.control_register(rtl)
    port map ( ----------------------------------------------------------------
      clkIn        => clkSysIn,
      rstIn        => rstSysIn,
      -----------------------------------------------------
      addrIn       => sAddrBus,
      dataIn       => sDataBus,
      -----------------------------------------------------
      ioReqLowIn   => sInputOutputReqLow,
      z80WrLowIn   => sMemWrLow,
      -----------------------------------------------------
      romSelLowOut => romSelLow,
      vdoBufEnOut  => open,
      prtStbOut    => open,
      ledsOut      => leds
    ); ------------------------------------------------------------------------
  --
  -----------------------------------------------------------------------------

end architecture rtl;
