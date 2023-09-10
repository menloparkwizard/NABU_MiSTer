library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;

library work; use work.nabu_pkg.all;

entity sp_rom_async is
  generic ( -------------------------------------------------------------------
    INIT_DATA :      Slv8ArrayType);
  port ( ----------------------------------------------------------------------
    clkIn     : in    std_logic;
    addrIn    : in    std_logic_vector(12 downto 00);
    enIn      : in    std_logic;
    dataOut   :   out std_logic_vector(07 downto 00));
end entity sp_rom_async;

architecture rtl of sp_rom_async is

begin

  dataOut <= INIT_DATA(to_integer(unsigned(addrIn))) when enIn = '1' else (others => 'Z');

end architecture rtl;