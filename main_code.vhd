Top Module:
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity TopModule is
  Port (value1: in STD_LOGIC_vECTOR(5 downto 0);
  value2: in STD_LOGIC_vECTOR(5 downto 0);
  value3: in STD_LOGIC_VECTOR(5 downto 0);
  available: inout STD_LOGIC_VECTOR(1 downto 0);
  seven_segment: out STD_LOGIC_VECTOR(6 downto 0);
  parklot1: out STD_LOGIC;
  parklot2: out STD_LOGIC;
  parklot3: out STD_LOGIC;
  clk: in STD_LOGIC;
  anodee: out STD_LOGIC_VECTOR(3 downto 0);
  reset: in STD_LOGIC;
  echo: in STD_LOGIC;
  trigger: out STD_LOGIC;
  BARRIER: out STD_LOGIC;
  MOVE: out STD_LOGIC);
end TopModule;

architecture Behavioral of TopModule is

component ultrasonic 
PORT(CLK: in STD_LOGIC;
  RESET: in STD_LOGIC;
  ECHO: in STD_LOGIC;
  TRIGGER: out STD_LOGIC;
  barrier: out STD_LOGIC;
  move: out STD_LOGIC);
end component;

component numberofslots
    Port(d1: in STD_LOGIC_VECTOR(5 downto 0);
    d2: in STD_LOGIC_VECTOR (5 downto 0);
    d3: in STD_LOGIC_VECTOR(5 downto 0);
    availableslots: inout STD_LOGIC_vector(1 downto 0);
    segment: out STD_LOGIC_VECTOR (6 downto 0);
    park1: out STD_LOGIC;
    park2: out STD_LOGIC;
    park3: out STD_LOGIC;
    clk: in STD_LOGIC;
    anode: out STD_LOGIC_VECTOR(3 downto 0));
end component;

begin
link_to_ultrasonic: ultrasonic port map(clk, reset, echo, trigger, BARRIER, MOVE);
link_to_parkinglots: numberofslots port map(value1, value2, value3, available, seven_segment, parklot1, parklot2, parklot3, clk, anodee);

end Behavioral;




“numberofslots” Module (for parking lots):
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;

entity numberofslots is
    Port(d1: in STD_LOGIC_VECTOR(5 downto 0);
    d2: in STD_LOGIC_VECTOR (5 downto 0);
    d3: in STD_LOGIC_VECTOR(5 downto 0);
    availableslots: inout STD_LOGIC_vector(1 downto 0);
    segment: out STD_LOGIC_VECTOR (6 downto 0);
    park1: out STD_LOGIC;
    park2: out STD_LOGIC;
    park3: out STD_LOGIC;
    clk: in STD_LOGIC;
    anode: out STD_LOGIC_VECTOR(3 downto 0));

end numberofslots;

architecture Behavioral of numberofslots is
signal lot1: STD_LOGIC;
signal lot2: STD_LOGIC;
signal lot3: STD_LOGIC;
signal sum: std_logic_vector(1 downto 0);
signal result: STD_LOGIC_VECTOR(1 downto 0);
signal counter: integer;

begin
process (clk)
begin
     
if rising_edge(clk) then
    if counter < 1000000 then
        counter <= counter + 1;
    else
        if d1 < "010000"  then
            lot1 <= '0';
        else
            lot1 <= '1';
        end if;

        if d2 < "000100" then
            lot2 <= '0';
        else
            lot2 <= '1';
        end if;

        if d3 < "010000" then
            lot3 <= '0';
        else
            lot3 <= '1';
        end if;
    end if;
end if;

park1<= lot1;
park2<= lot2;
park3 <= lot3;
sum(0)<= lot1 xor lot2;
sum(1)<= lot1 and lot2;
result(0)<= sum(0) xor lot3;
result(1)<= sum(1) xor (sum(0) and lot3);
availableslots<=result;
end process;
anode <= "1110";
with result select
segment <= "0110000" when "00", --car number 0, available slot 3
"0100100" when "01",-- car number 1, available slot 2
"1111001" when "10",-- car number 2, available slot 1
"1000000" when others;--car number 3, available slot 0

end Behavioral;

“ultrasonic” Module:
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

“servo” Module:
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity servo is
   PORT (
        clk   : IN  STD_LOGIC;
        reset : IN  STD_LOGIC;
        position  : IN  STD_LOGIC; --this will be the output data for the ultrasonic sensor which will indciate if there is a car in front of it (also can be named as “posin”)
        servo : OUT STD_LOGIC
    );
end servo;

architecture Behavioral of servo is
    -- Counter, from 0 to 1279.
    signal cnt : unsigned(10 downto 0);
    -- Temporal signal used to generate the PWM pulse.
    signal pwmi: unsigned(7 downto 0);
    signal pos: STD_LOGIC_VECTOR(6 downto 0); --this will be used to assign the position of the barrier
begin
    
    ultrasonic_connection: process (posin, clk)
    begin
        if falling_edge(clk) then
            if position= '1' then
                pos <= "1111111";
            else
                pos <= "1000000";
            end if;
        end if;
    end process;
                    pwmi <= unsigned('0' & pos);
    -- Counter process, from 0 to 1279.
    counter: process (reset, clk) 
    begin
        if (reset = '1') then
            cnt <= (others => '0');
        elsif rising_edge(clk) then
            if (cnt = 1279) then
                cnt <= (others => '0');
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;
    -- Output signal for the servomotor.
    servo <= '1' when (cnt < pwmi) else '0';
end Behavioral;



 “servo_and_clock” Module:

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity servo_and_clock is
    PORT(
        clk   : IN  STD_LOGIC;
        reset : IN  STD_LOGIC;
        position  : IN  STD_LOGIC; --this will be the output data for the ultrasonic sensor
        servo : OUT STD_LOGIC
    );
end servo_and_clock;

architecture Behavioral of servo_and_clock is
    COMPONENT clock
        PORT(
            clk    : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            clk_out: out STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT servo
        PORT (
        clk   : IN  STD_LOGIC;
        reset : IN  STD_LOGIC;
        position  : IN  STD_LOGIC; --this will be the output data for the ultrasonic sensor
        servo : OUT STD_LOGIC
        );
    END COMPONENT;
    
    signal clk_out : STD_LOGIC := '0';
begin
    clock_map: clock PORT MAP(
        clk, reset, clk_out
    );
    
    servo_map: servo PORT MAP(
        clk_out, reset, posin, servo
    );
end Behavioral;

“clock” Module:
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity clock is
    Port (
        clk    : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        clk_out: out STD_LOGIC
    );
end clock;
 
architecture Behavioral of clock is
    signal temporal: STD_LOGIC;
    signal counter : integer range 0 to 780 := 0;
begin
    freq_divider: process (reset, clk) begin
        if (reset = '1') then
            temporal <= '0';
            counter  <= 0;
        elsif rising_edge(clk) then
            if (counter = 780) then
                temporal <= NOT(temporal);
                counter  <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
 
    clk_out <= temporal;
end Behavioral;

Constraints:
# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
# LEDs
set_property PACKAGE_PIN U19 [get_ports {parklot3}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {parklot3}]
set_property PACKAGE_PIN E19 [get_ports {parklot2}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {parklot2}]
set_property PACKAGE_PIN U16 [get_ports {parklot1}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {parklot1}]
set_property PACKAGE_PIN U14 [get_ports {available[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {available[0]}]
set_property PACKAGE_PIN V14 [get_ports {available[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {available[1]}]
set_property PACKAGE_PIN L1 [get_ports {BARRIER}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {BARRIER}]


#7 segment display
set_property PACKAGE_PIN W7 [get_ports {seven_segment[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[0]}]
set_property PACKAGE_PIN W6 [get_ports {seven_segment[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[1]}]
set_property PACKAGE_PIN U8 [get_ports {seven_segment[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[2]}]
set_property PACKAGE_PIN V8 [get_ports {seven_segment[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[3]}]
set_property PACKAGE_PIN U5 [get_ports {seven_segment[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[4]}]
set_property PACKAGE_PIN V5 [get_ports {seven_segment[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[5]}]
set_property PACKAGE_PIN U7 [get_ports {seven_segment[6]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {seven_segment[6]}]

set_property PACKAGE_PIN U2 [get_ports {anodee[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anodee[0]}]
set_property PACKAGE_PIN U4 [get_ports {anodee[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anodee[1]}]
set_property PACKAGE_PIN V4 [get_ports {anodee[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anodee[2]}]
set_property PACKAGE_PIN W4 [get_ports {anodee[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {anodee[3]}]
#Pmod Header JA 
#Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports {value1[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value1[0]}]
#Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports {value1[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value1[1]}]
#Sch name = JA3
set_property PACKAGE_PIN J2 [get_ports {value1[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value1[2]}]
#Sch name = JA4
set_property PACKAGE_PIN G2 [get_ports {value1[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value1[3]}]
#Sch name = JA7
set_property PACKAGE_PIN H1 [get_ports {value1[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value1[4]}]
#Sch name = JA8
set_property PACKAGE_PIN K2 [get_ports {value1[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value1[5]}]
#Sch name = JA9
set_property PACKAGE_PIN H2 [get_ports {trigger}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {trigger}]
#Sch name = JA10
set_property PACKAGE_PIN G3 [get_ports {echo}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {echo}]

Pmod Header JB
Sch name = JB1
set_property PACKAGE_PIN A14 [get_ports {value2[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value2[0]}]
#Sch name = JB2
set_property PACKAGE_PIN A16 [get_ports {value2[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value2[1]}]
#Sch name = JB3
set_property PACKAGE_PIN B15 [get_ports {value2[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value2[2]}]
#Sch name = JB4
set_property PACKAGE_PIN B16 [get_ports {value2[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value2[3]}]
#Sch name = JB7
set_property PACKAGE_PIN A15 [get_ports {value2[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value2[4]}]
#Sch name = JB8
set_property PACKAGE_PIN A17 [get_ports {value2[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value2[5]}]
#Sch name = JB9
set_property PACKAGE_PIN C15 [get_ports {MOVE}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {MOVE}]



Pmod Header JC
Sch name = JC1
set_property PACKAGE_PIN K17 [get_ports {value3[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value3[0]}]
#Sch name = JC2
set_property PACKAGE_PIN M18 [get_ports {value3[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value3[1]}]
#Sch name = JC3
set_property PACKAGE_PIN N17 [get_ports {value3[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value3[2]}]
#Sch name = JC4
set_property PACKAGE_PIN P18 [get_ports {value3[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value3[3]}]
#Sch name = JC7
set_property PACKAGE_PIN L17 [get_ports {value3[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value3[4]}]
#Sch name = JC8
set_property PACKAGE_PIN M19 [get_ports {value3[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {value3[5]}]
	
# Switches
set_property PACKAGE_PIN V17 [get_ports {reset}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {reset}]
