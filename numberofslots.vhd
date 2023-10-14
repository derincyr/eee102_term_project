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
