library IEEE;
use IEEE.STD_LOGIC_1164.all,
  ieee.numeric_std.all;


entity DDR_VCO is
  generic (
    --! Division counter size.\n
    --! For a power of 2, this value is the power.\n
    --! For other values, it is the power of 2 that generates the first value
    --!   above the required value.
    --! BE CAREFUL , this code has to be upgraded, see below.
    division_counter_size : integer range 2 to integer'high);
  port(
    MASTER_CLK : in  std_logic;
    --! Reference clock, active on the rising edge.
    --! It should return to 0 no later than the end of the division counter
    REF_CLK    : in  std_logic;
    OUT_CLK    : out std_logic);
end entity DDR_VCO;

architecture arch of DDR_VCO is
  signal division_counter_1       : std_logic_vector (division_counter_size downto 0) := (others => '0');
  signal division_counter_2       : std_logic_vector (division_counter_size downto 0) := (others => '0');
  signal division_counter_CLK     : std_logic;
  signal Q1, Q2                   : std_logic                                         := '0';
  signal CLK_from_Q1, CLK_from_Q2 : std_logic;
  signal reset_requested_1        : std_logic;
  signal reset_requested_2        : std_logic;
begin
  OUT_CLK              <= division_counter_CLK;
  division_counter_CLK <= CLK_from_Q1 or CLK_from_Q2 after 7 ns;
  CLK_from_Q1          <= Q1 and not MASTER_CLK      after 7 ns;
  CLK_from_Q2          <= Q2 and MASTER_CLK          after 7 ns;
  reset_requested_1    <= division_counter_1(division_counter_1'high);
  reset_requested_2    <= division_counter_2(division_counter_2'high);

  -- At each edge of the reference clock,
  --   if a rising edge of the master clock comes first,
  --   the latch activates and locks Q2
  mode_1 : process(MASTER_CLK, Q2) is
  begin
    RST_IF : if Q2 /= '1' then
      CLK_IF : if rising_edge(MASTER_CLK) then
        if reset_requested_1 = '1' and REF_CLK = '1' then
          Q1 <= not Q1 after 14 nS;
        elsif reset_requested_1 = '1' then
          Q1 <= '0' after 14 nS;
        elsif REF_CLK = '1' then
          Q1 <= '1' after 14 nS;
        end if;
      end if CLK_IF;
    end if RST_IF;
  end process mode_1;

  -- At each edge of the reference clock,
  --   if a falling edge of the master clock comes first,
  --   the latch activates and locks Q1
  mode_2 : process(MASTER_CLK, Q1) is
  begin
    RST_IF : if Q1 /= '1' then
      CLK_IF : if falling_edge(MASTER_CLK) then
        if reset_requested_2 = '1' and REF_CLK = '1' then
          Q2 <= not Q2 after 14 nS;
        elsif reset_requested_2 = '1' then
          Q2 <= '0' after 14 nS;
        elsif REF_CLK = '1' then
          Q2 <= '1' after 14 nS;
        end if;
      end if CLK_IF;
    end if RST_IF;
  end process mode_2;

  counter_proc_1 : process(master_CLK) is
  begin
    -- This a sample code. It has been designed to divide by 2 ** counter_size.
    -- For other ratios, the counter would have to be compared to a reference value.
    -- To avoid the propagation delay of an xor followed by an or reduce,
    --   the counter is not reset but loaded by its complement.
    -- In such case, one can modified the line below
    if rising_edge(master_CLK) then
      if Q1 = '1' then
        division_counter_1 <= std_logic_vector(unsigned (division_counter_1) + 1) after 14 nS;
      else
        -- This is a work around because only power of 2 values are handled
        -- A clean up is to take the number (in the generics), not a power of 2,
        --   subtract 1,
        --   take the complement,
        --   generate a counter of the relevant size (+1)
        division_counter_1(division_counter_1'high downto division_counter_1'low + 1) <= (others => '0') after 14 nS;
        division_counter_1(division_counter_1'low) <= '1' after 14 nS;
      end if;
    end if;
  end process counter_proc_1;

  counter_proc_2 : process(master_CLK) is
  begin
    -- See the instructions on the counter_proc_1, above
    if falling_edge(master_CLK) then
      if Q2 = '1' then
        division_counter_2 <= std_logic_vector(unsigned (division_counter_2) + 1) after 14 nS;
      else
        division_counter_2(division_counter_2'high downto division_counter_2'low + 1) <= (others => '0') after 14 nS;
        division_counter_2(division_counter_2'low) <= '1' after 14 nS;
      end if;
    end if;
  end process counter_proc_2;
  
end architecture arch;

