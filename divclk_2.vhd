----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/08/20 21:01:34
-- Design Name: 
-- Module Name: divclk_2 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divclk_2 is
Port (
	clk_in:in std_logic;
    clk_div:out std_logic
);
end divclk_2;

architecture Behavioral of divclk_2 is
signal count_clkdisplay : integer range 0 to 1000000000:=0; --时钟计数
begin
process(clk_in)
begin 
        if(clk_in'event and clk_in='1')then                                                                 
            if(count_clkdisplay<=50000)then
                clk_div<='1';
                count_clkdisplay<=count_clkdisplay+1;
            elsif(count_clkdisplay>=50000 and count_clkdisplay<100000)then
                clk_div<='0';
                count_clkdisplay<=count_clkdisplay+1;
            else  count_clkdisplay<=0;
            end if;   
        end if;                
end process;
end Behavioral;
