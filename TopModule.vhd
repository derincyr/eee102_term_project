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
