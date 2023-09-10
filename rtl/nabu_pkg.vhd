library ieee; use ieee.std_logic_1164.all;

package nabu_pkg is

  -- TYPES --------------------------------------------------------------------
  type Slv8ArrayType is array(integer range <>) of std_logic_vector(07 downto 00);

  -- CONSTANTS ----------------------------------------------------------------
  constant PROM_DATA_4K : Slv8ArrayType(0 to 4095) := ( -----------------------
    others => x"00"
  ); --------------------------------------------------------------------------

end package nabu_pkg;