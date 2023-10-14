library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ultrasonic is
  Port (CLK: in STD_LOGIC;
  RESET: in STD_LOGIC;
  ECHO: in STD_LOGIC;
  TRIGGER: out STD_LOGIC;
  barrier: out STD_LOGIC;
  move: out STD_LOGIC);
end ultrasonic;

architecture Behavioral of ultrasonic is
component servo_and_clock 
 PORT(
        clk   : IN  STD_LOGIC;
        reset : IN  STD_LOGIC;
        moveservo: IN  STD_LOGIC; --this will be the output data for the ultrasonic sensor
        servo : OUT STD_LOGIC);
end component;
signal sayma: unsigned(16 downto 0):= (others => '0');
signal cm: unsigned(15 downto 0):= (others => '0');
signal cmbirler: unsigned(3 downto 0) := (others => '0');
signal cmonlar: unsigned(3 downto 0) := (others => '0');
signal birler : unsigned(3 downto 0) := (others => '0');
signal onlar : unsigned(3 downto 0) := (others => '0');
signal digitler : unsigned(3 downto 0) := (others => '0');
signal echoson : std_logic := '0';
signal echos : std_logic := '0';
signal echonots : std_logic := '0';
signal bekle : std_logic := '0';
signal segment : unsigned(15 downto 0) := (others => '0');

signal ultrasonic_value: STD_LOGIC; 
begin

seven_seg: process(CLK)
begin
if rising_edge(CLK) then
    if segment(segment'high) = '1' then
        digitler <= birler;
    else
        digitler <= onlar;
    end if;
    segment <= segment +1;
end if;
end process;

process(CLK)
begin
if rising_edge(CLK) then
    if bekle = '0' then
        if sayma = 1000 then -- 10us tetikleme
            TRIGGER <= '0';
            bekle <= '1';
            sayma <= (others => '0');
        else
            TRIGGER <= '1';
            sayma <= sayma+1;
        end if;
    elsif echoson = '0' and echos = '1' then
        sayma <= (others => '0');
        cm <= (others => '0');
        cmbirler <= (others => '0');
        cmonlar <= (others => '0');
    elsif echoson = '1' and echos = '0' then
        birler <= cmbirler;
        onlar <= cmonlar;
        if cmonlar < 1 then
            barrier<= '1';
            ultrasonic_value <= '1';
        else
            barrier<= '0';
            ultrasonic_value <= '0';
            end if;
    elsif sayma = 5799 then --5800-1
        if cmbirler = 9 then
            cmbirler <= (others => '0');
            cmonlar <= cmonlar + 1;
        else
            cmbirler <= cmbirler + 1;
        end if;
        cm <= cm + 1;
        sayma <= (others => '0');
            if cm = 3448 then
            bekle <= '0';
        end if;
    else
        sayma <= sayma + 1;
end if;
echoson <= echos;
echos <= echonots;
echonots <= ECHO;
end if;
end process;
pm1 : servo_and_clock port map(CLK, RESET, ultrasonic_value, move);
end Behavioral;
