library IEEE;
use IEEE.STD_LOGIC_1164.all,
  ieee.numeric_std.all;

entity DDR_VCO_test is
end entity DDR_VCO_test;

architecture arch of DDR_VCO_test is
  signal CLK                : std_logic                := '0';
  signal main_counter       : unsigned(15 downto 0) := (others            => '0');
  constant main_counter_max : unsigned(15 downto 0) := (main_counter'high => '1', others => '0');
  component DDR_VCO is
    generic (
      division_counter_size : integer range 2 to integer'high);
    port(
      MASTER_CLK : in  std_logic;
      REF_CLK    : in  std_logic;
      OUT_CLK    : out std_logic);
  end component DDR_VCO;
  signal REF_CLK : std_logic;
  signal OUT_CLK : std_logic;
begin

  main_CLK_proc : process
  begin
    if main_counter /= main_counter_max then
      if CLK = '1' then
        main_counter <= main_counter + 1;

      end if;
      CLK <= not CLK;
--      wait for 15.620 ns;
      wait for 15.3 nS;
    else
      report "Simulation is over" severity note;
      wait;
    end if;
  end process main_CLK_proc;

  ref_CLK_proc : process
  begin
    if main_counter /= main_counter_max then
      if REF_CLK = '1' then
        REF_CLK <= '0';
--        wait for 59 us;
        wait for 920 nS;
      else
        REF_CLK <= '1';
--        wait for 5 us;
        wait for 80 nS;
      end if;
    else
      wait;
    end if;
  end process ref_CLK_proc;

  DUT : DDR_VCO generic map
    (
--      division_counter_size => 11
      division_counter_size => 5
      )
    port map
    (
      MASTER_CLK => CLK,
      REF_CLK    => REF_CLK,
      OUT_CLK    => OUT_CLK
      );

end architecture arch;
