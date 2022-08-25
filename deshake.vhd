----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/08/20 21:21:43
-- Design Name: 
-- Module Name: deshake - Behavioral
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

entity deshake is
port(
    key_in:in std_logic;----按键输入
    clk:in std_logic;
    key_en:out std_logic----输出信号
	);
end deshake;

architecture Behavioral of deshake is
-------计数型消抖
begin
process(clk)

constant s:integer :=5000000 ;----仿真用s=3,开发板s=5000000
variable count:integer range 0 to s := 0;
begin
if (clk'event and clk='1') then
	if (key_in = '1') then 
		if count = s-1 then key_en<='1';--小于30ns（50ms）则不计入按下的动作
		else key_en<='0';
		end if;

		if (count = s) then count := count;
		else count := count+1;
		end if;
		
	else count := 0;
	end if;
end if;
end process;
end Behavioral;