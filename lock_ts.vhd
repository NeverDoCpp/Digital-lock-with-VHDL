----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/08/20 19:03:28
-- Design Name: 
-- Module Name: lock_ts - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lock_ts is
--port();
end lock_ts;

architecture Behavioral of lock_ts is
component e_lock  
Port (
    clk : in STD_LOGIC;
    i_user : in STD_LOGIC;
    i_admin : in STD_LOGIC;

    i_enter : in STD_LOGIC;
    i_back : in STD_LOGIC;
    i_clear : in STD_LOGIC;
    switch0 : in STD_LOGIC;
    switch1 : in STD_LOGIC;
    switch2 : in STD_LOGIC;
    switch3 : in STD_LOGIC;
    switch4 : in STD_LOGIC;
    switch5 : in STD_LOGIC;
    switch6 : in STD_LOGIC;
    switch7 : in STD_LOGIC;
    switch8 : in STD_LOGIC;
    switch9 : in STD_LOGIC;
    RGB1_blue : out STD_LOGIC;
    RGB1_green : out STD_LOGIC;
    RGB1_red : out STD_LOGIC;
    RGB2_blue : out STD_LOGIC;
    RGB2_green : out STD_LOGIC;
    RGB2_red : out STD_LOGIC;  
                
    seg7:out std_logic_vector(7downto 0); --数码管显示内容
    segselect8: out std_logic_vector(7downto 0)  --数码管片选   

);

end component;  
--input
signal  clk :  STD_LOGIC:='0';
signal  i_user :  STD_LOGIC:='0';
signal  i_admin :  STD_LOGIC:='0';

signal  i_enter :  STD_LOGIC:='0';
signal  i_back :  STD_LOGIC:='0';
signal  i_clear :  STD_LOGIC:='0';
signal  switch0 :  STD_LOGIC:='0';
signal  switch1 :  STD_LOGIC:='0';
signal  switch2 :  STD_LOGIC:='0';
signal  switch3 :  STD_LOGIC:='0';
signal  switch4 :  STD_LOGIC:='0';
signal  switch5 :  STD_LOGIC:='0';
signal  switch6 :  STD_LOGIC:='0';
signal  switch7 :  STD_LOGIC:='0';
signal  switch8 :  STD_LOGIC:='0';
signal  switch9 :  STD_LOGIC:='0';

--output
signal RGB1_blue : STD_LOGIC;
signal RGB1_green : STD_LOGIC;
signal RGB1_red : STD_LOGIC;
signal RGB2_blue :STD_LOGIC;
signal RGB2_green :STD_LOGIC;
signal RGB2_red :STD_LOGIC;                 
signal seg7: std_logic_vector(7downto 0); --数码管显示内容
signal segselect8: std_logic_vector(7downto 0);  --数码管片选   



-- Clock period definitions
constant clk_period : time := 10 ns;

begin
uut: e_lock PORT MAP (
clk=>clk,

i_user=>i_user,
i_admin=>i_admin,

i_enter=> i_enter,
i_back=>i_back ,
i_clear=>i_clear,
switch0=>switch0,
switch1=>switch1,
switch2 =>switch2,
switch3=>switch3,
switch4=>switch4,
switch5=>switch5,
switch6=>switch6,
switch7=>switch7,
switch8=>switch8,
switch9=>switch9,
RGB1_blue=>RGB1_blue,
RGB1_green=>RGB1_green,
RGB1_red=>RGB1_red,
RGB2_blue=>RGB2_blue,
RGB2_green=>RGB2_green,
RGB2_red=>RGB2_red,    
seg7=>seg7,
segselect8=>segselect8
);

process
begin
clk<='0';
wait for 5 ns;
clk<='1';
wait for 5 ns;
end process;

process
begin

wait for 20 us;--等待状态测试按键（不显示）
switch9<='1';
wait for 20 us;
switch8<='1';
wait for 20 us;


wait for 10 us;--按下用户键进入s1输入状态
i_user<='1';
wait for 40 us;
i_user<='0';
wait for 20 us;


switch1<='1';--1
wait for 40 us;

switch1<='0';--1
wait for 40 us;

i_back<='1';--退格键删除第二位数字
wait for 40 us;
i_back<='0';
wait for 40 us;

switch2<='1';--2
wait for 40 us;

switch3<='1';--3
wait for 40 us;

switch4<='1';--4
wait for 40 us;

i_enter<='1';--确认键（密码错误进入A1提示状态）
wait for 40 us;
i_enter<='0';
wait for 20 us;

i_enter<='1';--确认键（回到输入状态状态）
wait for 40 us;
i_enter<='0';
wait for 20 us;

switch4<='0';--4
wait for 40 us;

switch3<='0';--3
wait for 40 us;

switch2<='0';--2
wait for 40 us;

switch1<='1';--1
wait for 40 us;

i_enter<='1';--确认键（密码错误进入A1提示状态）
wait for 40 us;
i_enter<='0';
wait for 20 us;

i_enter<='1';--确认键（回到输入状态状态）
wait for 40 us;
i_enter<='0';
wait for 20 us;

switch6<='1';--6
wait for 40 us;

switch6<='0';--6
wait for 40 us;

switch6<='1';--6
wait for 40 us;

switch6<='0';--6
wait for 40 us;

i_enter<='1';--确认键（密码错误进入A2警报状态）
wait for 40 us;
i_enter<='0';
wait for 20 us;

i_admin<='1';--进入管理员状态
wait for 40 us;
i_admin<='0';  
wait for 20 us;

i_clear<='1';--清除警报后回到等待状态s
wait for 40 us;
i_clear<='0';    


i_admin<='1';--进入管理员状态（修改密码）
wait for 40 us;
i_admin<='0';
wait for 20 us;

switch1<='0';--1
wait for 20 us;
switch2<='1';--2
wait for 20 us;
switch3<='1';--3
wait for 20 us;
switch4<='1';--4
wait for 20 us;

i_enter<='1';--确认修改后进入等待状态
wait for 40 us;
i_enter<='0';
wait for 10 us;


i_user<='1';--进入用户输入状态
wait for 40 us;
i_user<='0';
wait for 20 us;

switch1<='1';--1
wait for 20 us;
switch2<='0';--2
wait for 20 us;
switch3<='0';--3
wait for 20 us;
switch4<='0';--4
wait for 20 us;

i_enter<='1';--确认密码正确
wait for 40 us;
i_enter<='0';
wait for 20 us;

i_enter<='1';--回到等待状态
wait for 40 us;
i_enter<='0';
wait for 20 us;

wait;
end process;


END;

