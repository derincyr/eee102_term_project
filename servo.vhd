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
