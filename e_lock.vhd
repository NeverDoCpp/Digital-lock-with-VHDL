----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/08/20 19:00:52
-- Design Name: 
-- Module Name: e_lock - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity e_lock is
    Port ( clk : in STD_LOGIC;--时钟信号输入
        i_user : in STD_LOGIC;--用户键（消抖前）
        i_admin : in STD_LOGIC;--管理员键（消抖前）
        i_enter : in STD_LOGIC;--确认键（消抖前）
        i_back : in STD_LOGIC;--退格键（消抖前）
        i_clear : in STD_LOGIC;--解除警报建（消抖前）

        switch0 : in STD_LOGIC;--数字输入开关（0-9）
        switch1 : in STD_LOGIC;
        switch2 : in STD_LOGIC;
        switch3 : in STD_LOGIC;
        switch4 : in STD_LOGIC;
        switch5 : in STD_LOGIC;
        switch6 : in STD_LOGIC;
        switch7 : in STD_LOGIC;
        switch8 : in STD_LOGIC;
        switch9 : in STD_LOGIC;

        RGB1_blue : out STD_LOGIC;--RGB灯显示当前状态
        RGB1_green : out STD_LOGIC;
        RGB1_red : out STD_LOGIC;
        RGB2_blue : out STD_LOGIC;
        RGB2_green : out STD_LOGIC;
        RGB2_red : out STD_LOGIC;

        seg7:out std_logic_vector(7downto 0); --数码管显示内容
        segselect8: out std_logic_vector(7downto 0) --数码管片选

        );
end e_lock;

architecture Behavioral of e_lock is

type states is (s,s1,s2,s3,A1,A2); --s等待状态 s1输入状态 s2解锁状态 s3管理员状态 A1提示错误状态 A2警报状态
signal state: states:=s;--初始状态赋值


signal input_time1: integer range 0 to 10;--输入密码次数
signal count1:integer range 0 to 200:=0;    --指针1
signal count2:integer range 0 to 200:=0;    --指针2

signal back:std_logic:='0';--退位（消抖后）
signal enter:std_logic:='0';--确认（消抖后）
signal clear:std_logic:='0';--管理员取消警报（消抖后）
signal user:std_logic:='0';--用户（消抖后）
signal admin:std_logic:='0';--管理员（消抖后）

signal sleep:std_logic:='0';--无输入休眠信号
signal inkey:std_logic:='0';--总按键信号
signal inkey1:std_logic:='0';--功能按键信号
signal inkey2:std_logic:='0';--数字按键信号

signal trusted:std_logic:='0';--锁定状态信号



signal sw0:std_logic:='0';--内部数字初始信号全设为0
signal sw1:std_logic:='0';
signal sw2:std_logic:='0';
signal sw3:std_logic:='0';
signal sw4:std_logic:='0';
signal sw5:std_logic:='0';
signal sw6:std_logic:='0';
signal sw7:std_logic:='0';
signal sw8:std_logic:='0';
signal sw9:std_logic:='0';

signal data:integer range 0 to 10;--数码管显示数字


type row is array (0 to 3) of integer range 0 to 10; 
signal row_code: row:=(0,0,0,0);--设定的密码（初始为0000）
signal row_code_receive1:row;--输入的密码

signal clkcount:std_logic:='0';--主程序运行时钟信号1Hz
signal clkdisplay:std_logic:='0';--LED显示时钟信号1kHz


component deshake--消抖
port(
    key_in:in std_logic;----按键输入
    clk:in std_logic;
    key_en:out std_logic----输出信号
);
end component;

component divclk--分频：计时
port(
	clk_in:in std_logic;
	clk_div:out std_logic
	);
end component;

component divclk_2--分频：显示
port(
	clk_in:in std_logic;
	clk_div:out std_logic
	);
end component;



BEGIN
--给信号赋值

--分频
clkdiv:divclk
	port map(
        clk_in =>clk,
		clk_div =>clkcount	
	);
clkdiv_2:divclk_2
    port map(
        clk_in =>clk,
        clk_div =>clkdisplay
    );

---消抖
--用户键消抖
user_deshake:deshake
	port map(   
        key_in => i_user,
		clk =>clk,
		key_en =>user 
	);
--管理员键消抖			
admin_deshake:deshake
    port map(   
        key_in => i_admin,
        clk =>clk,
        key_en =>admin 
    );				
--确认键消抖
enter_deshake:deshake
	port map(
        key_in => i_enter,
		clk =>clk,
		key_en => enter
	);
--退格键消抖				
back_deshake:deshake
	port map(
        key_in => i_back,
		clk =>clk,
		key_en => back
	);
--清除报警键消抖				
clear_deshake:deshake
	port map(
        key_in => i_clear,
		clk =>clk,
		key_en => clear
	);
				
inkey2<= user or admin or clear or enter or back; 
inkey1<=(switch0 xor sw0) or (switch1 xor sw1) or (switch2 xor sw2) or (switch3 xor sw3) or (switch4 xor sw4) or (switch5 xor sw5) or (switch6 xor sw6) or (switch7 xor sw7) or (switch8 xor sw8) or (switch9 xor sw9);
inkey<=inkey1 or inkey2;--没有按键输入时，inkey=0



main:process(clk)
begin

    if(clk'event and clk='1')then
    case state is
        when s=>--初始等待状态
            --若处于等待状态，则执行以下操态:双灯熄灭
            RGB1_blue<='0';RGB1_green<='0';RGB1_red<='0';
            RGB2_blue<='0';RGB2_green<='0';RGB2_red<='0';
            
            --禁止按键输入
            sw0<=switch0;sw1<=switch1;sw2<=switch2;sw3<=switch3;sw4<=switch4;
            sw5<=switch5;sw6<=switch6;sw7<=switch7;sw8<=switch8;sw9<=switch9;

            --初始输入密码清除
            for i in 0 to 3 loop
                row_code_receive1(i)<=10;
            end loop;
            input_time1<=0;--错误次数清零
            count1<=0;
            count2<=0;--指针清零
            if(admin='1')then--管理员键按下
                state<=s3;
            end if;
            if(user='1')then--用户键按下
                state<=s1;
            end if;

        when s1=>--输入状态
            --若处于用户输入密码状态，则执行以下操作:一绿一红
                RGB1_blue<='0';RGB1_green<='1';RGB1_red<='0';
                RGB2_blue<='0';RGB2_green<='0';RGB2_red<='1';
            
            if(sleep='1')then state<=s;end if;--长时间无输入，则回到等待状态

            if(enter='1')then--按下确认键
                count1<=0;--指针1清零
                if(row_code=row_code_receive1)then
                    state<=s2;--密码正确则解锁进入状态s2
                else
                    input_time1<=input_time1+1;--错误次数+1
                    state<=A1;--进入提示密码错误状态A1           
                end if;

            elsif(back='1')then--按下退位位键
                if(count1>0)then
                row_code_receive1(count1-1)<=10;--原位清零
                count1<=count1-1;--指针减1
                end if;

            elsif(admin='1')then--管理员键按下
                for i in 0 to 3 loop
                row_code_receive1(i)<=10;
                end loop;
                count1<=0;--指针1清零
                state<=s3;--清除数据后进入管理员状态

            elsif(sw0/=switch0)then--输入0
                sw0<=switch0;
                if(count1<=3)then
                    row_code_receive1(count1)<=0;
                    count1<=count1+1;
                end if;
            elsif(sw1/=switch1)then--输入1
                sw1<=switch1;
                if(count1<=3)then
                    row_code_receive1(count1)<=1;
                    count1<=count1+1;
                end if;
            elsif(sw2/=switch2)then--输入2
                sw2<=switch2;
                if(count1<=3)then
                    row_code_receive1(count1)<=2;
                    count1<=count1+1;
                end if;
            elsif(sw3/=switch3)then--输入3
                sw3<=switch3;
                if(count1<=3)then
                    row_code_receive1(count1)<=3;
                    count1<=count1+1;
                end if;
            elsif(sw4/=switch4)then--输入4
                sw4<=switch4;
                if(count1<=3)then
                    row_code_receive1(count1)<=4;
                    count1<=count1+1;
                end if;
            elsif(sw5/=switch5)then--输入5
                sw5<=switch5;
                if(count1<=3)then
                    row_code_receive1(count1)<=5;
                    count1<=count1+1;
                end if;
            elsif(sw6/=switch6)then--输入6
                sw6<=switch6;
                if(count1<=3)then
                    row_code_receive1(count1)<=6;
                    count1<=count1+1;
                end if;
            elsif(sw7/=switch7)then--输入7
                sw7<=switch7;
                if(count1<=3)then
                    row_code_receive1(count1)<=7;
                    count1<=count1+1;
                end if;
            elsif(sw8/=switch8)then--输入8
                sw8<=switch8;
                if(count1<=3)then
                    row_code_receive1(count1)<=8;
                    count1<=count1+1;
                end if;
            elsif(sw9/=switch9)then--输入9
                sw9<=switch9;
                if(count1<=3)then
                    row_code_receive1(count1)<=9;
                    count1<=count1+1;
                end if;
            end if;
    
        when A1=>--提示错误状态
            --若处于提示错误状态，则执行以下操作:一蓝一红
            RGB1_blue<='1';RGB1_green<='0';RGB1_red<='0';
            RGB2_blue<='0';RGB2_green<='0';RGB2_red<='1';
            --禁止按键输入
            sw0<=switch0;sw1<=switch1;sw2<=switch2;sw3<=switch3;sw4<=switch4;
            sw5<=switch5;sw6<=switch6;sw7<=switch7;sw8<=switch8;sw9<=switch9;
            for i in 0 to 3 loop
                row_code_receive1(i)<=10;--所有密码位清零
            end loop;  
            if(input_time1=3)then
                state<=A2;--3次输入错误进入警告状态A2
            end if;
            if(user='1')then--按下用户键重新输入
                count1<=0;--指针1清零
                state<=s1;
            end if;
            if(admin='1')then--进入管理员键
                state<=s3;--进入管理员状态s3
            end if;
            if(enter='1')then--按下确认键重新输入
                count1<=0;--指针1清零
                state<=s1;
            end if;

        when A2=>--报警状态
            --若处于报警状态，则执行以下操作:双红
            RGB1_blue<='0';RGB1_green<='0';RGB1_red<='1';
            RGB2_blue<='0';RGB2_green<='0';RGB2_red<='1';
            --禁止按键输入
            sw0<=switch0;sw1<=switch1;sw2<=switch2;sw3<=switch3;sw4<=switch4;
            sw5<=switch5;sw6<=switch6;sw7<=switch7;sw8<=switch8;sw9<=switch9;     
            
            
            for i in 0 to 3 loop
                row_code_receive1(i)<=10;--所有密码位清零
            end loop; 
                
            if(admin='1')then--处于管理员状态
                state<=s3;
            end if;

        when s2=>--用户解锁状态
            --若处于用户开锁状态，则执行以下操作:双绿灯长亮
            RGB1_blue<='0';RGB1_green<='1';RGB1_red<='0';
            RGB2_blue<='0';RGB2_green<='1';RGB2_red<='0';

            for i in 0 to 3 loop
                row_code_receive1(i)<=10;
            end loop;

            if(sleep='1')then state<=s;end if;--10s无操作进入等待状态

            --禁止按键输入
            sw0<=switch0;sw1<=switch1;sw2<=switch2;sw3<=switch3;sw4<=switch4;
            sw5<=switch5;sw6<=switch6;sw7<=switch7;sw8<=switch8;sw9<=switch9;   
            
            if(enter='1')then--按下确认键直接回到等待状态
                state<=s;
            elsif(admin='1')then--按下管理员键进入管理员模式s3
                state<=s3;
            end if;

        when s3=>--管理员状态
            --若处于管理员状态，则执行以下操作:双蓝灯
                RGB1_blue<='1';RGB1_green<='0';RGB1_red<='0';
                RGB2_blue<='1';RGB2_green<='0';RGB2_red<='0';  

                if(sleep='1')then state<=s;end if;--20s无操作进入等待状态

                if(enter='1')then--按下确认键即完成密码修改（若有未输入的密码位，则无法修改）
                    if(count2=4)then 
                    for i in 0 to 3 loop
                        row_code(i)<=row_code_receive1(i);
                    end loop;
                    state<=s;--返回原状态s
                    end if;               
                elsif(back='1')then--按下退位位键
                    if(count2>0)then
                    row_code_receive1(count2-1)<=10;--原位清零(不可逆！！！)
                    count2<=count2-1;--指针减1
                    end if;
                elsif(clear='1')then--按下取消报警键
                    state<=s;--返回等待状态s
                            
                elsif(sw0/=switch0)then--输入0
                    sw0<=switch0;
                    if(count2<=3)then
                        row_code_receive1(count2)<=0;
                        count2<=count2+1;
                    end if;
                elsif(sw1/=switch1)then--输入1
                    sw1<=switch1;
                    if(count2<=3)then
                        row_code_receive1(count2)<=1;
                        count2<=count2+1;
                    end if;
                elsif(sw2/=switch2)then--输入2
                    sw2<=switch2;
                    if(count2<=3)then
                        row_code_receive1(count2)<=2;
                        count2<=count2+1;
                        end if;
                elsif(sw3/=switch3)then--输入3
                    sw3<=switch3;
                    if(count2<=3)then
                        row_code_receive1(count2)<=3;
                        count2<=count2+1;
                    end if;
                elsif(sw4/=switch4)then--输入4
                    sw4<=switch4;
                    if(count2<=3)then
                        row_code_receive1(count2)<=4;
                        count2<=count2+1;
                    end if;
                elsif(sw5/=switch5)then--输入5
                    sw5<=switch5;
                    if(count2<=3)then
                        row_code_receive1(count2)<=5;
                        count2<=count2+1;
                    end if;
                elsif(sw6/=switch6)then--输入6
                    sw6<=switch6;
                    if(count2<=3)then
                        row_code_receive1(count2)<=6;
                        count2<=count2+1;
                    end if;
                elsif(sw7/=switch7)then--输入7
                    sw7<=switch7;
                    if(count2<=3)then
                        row_code_receive1(count2)<=7;
                        count2<=count2+1;
                    end if;
                elsif(sw8/=switch8)then--输入8
                    sw8<=switch8;
                    if(count2<=3)then
                        row_code_receive1(count2)<=8;
                        count2<=count2+1;
                    end if;
                elsif(sw9/=switch9)then--输入9
                    sw9<=switch9;
                    if(count2<=3)then
                        row_code_receive1(count2)<=9;
                        count2<=count2+1;
                    end if;
                end if;

        end case;
    end if;
end process main;

--实物用
--timelimit:process(inkey,clk,trusted,clkcount)          --计时信号，若进入睡眠状态sleep=1
--    variable numtime:std_logic_vector(5 downto 0):="000000";
--    begin
--    if(inkey='1')then
--        sleep<='0';
--        numtime:="000000";
--    elsif ((clkcount'event  and clkcount='1')and inkey='0')then  --用户输入状态下，10s无操作发出睡眠信号
--        if(trusted='0')then
--            numtime:=numtime+1;                            
--            if numtime="001010" then
--                sleep<='1';
--                numtime:="000000";
--            end if;
--        elsif(trusted='1')then                        --管理员或用户解锁状态下，20s无操作发出睡眠信号
--            numtime:=numtime+1;                            
--            if numtime="010100" then
--                sleep<='1';
--                numtime:="000000";
--            end if;
--        end if;
--    end if;


--end process timelimit;

--测试用
timelimit:process(inkey,clk,trusted,clkdisplay)          --计时信号，若进入睡眠状态sleep=1
    variable numtime:std_logic_vector(5 downto 0):="000000";
    begin
    if(inkey='1')then
        sleep<='0';
        numtime:="000000";
    elsif ((clkdisplay'event  and clkdisplay='1')and inkey='0')then  --用户输入状态下，10ms无操作发出睡眠信号
        if(trusted='0')then
            numtime:=numtime+1;                            
            if numtime="001010" then
                sleep<='1';
                numtime:="000000";
            end if;
        elsif(trusted='1')then          --管理员或用户解锁状态下，20ms无操作发出睡眠信号
            numtime:=numtime+1;                            
            if numtime="010100" then
                sleep<='1';
                numtime:="000000";
            end if;
        end if;
    end if;


end process timelimit;






set_passworddisplay: process (clk)                --数码管显示内容
    Begin
    case data is
        when 0 =>seg7<="11000000";              --数码管显示内容为0
        when 1 =>seg7<="11111001";              --数码管显示内容为1
        when 2 =>seg7<="10100100";              --数码管显示内容为2
        when 3 =>seg7<="10110000";              --数码管显示内容为3
        when 4 =>seg7<="10011001";              --数码管显示内容为4
        when 5 =>seg7<="10010010";              --数码管显示内容为5
        when 6 =>seg7<="10000010";              --数码管显示内容为6
        when 7 =>seg7<="11111000";              --数码管显示内容为7
        when 8 =>seg7<="10000000";              --数码管显示内容为8
        when 9 =>seg7<="10010000";              --数码管显示内容为9
        when others =>seg7<="10111111";         --数码管显示内容为-
    end case;
end process set_passworddisplay;


password_display:process(clkdisplay)                     --数码管显示模块：固定显示4位密码 
    variable n:std_logic_vector(2 downto 0):="000";
    begin
    if(clkdisplay'event and clkdisplay = '1') then                            --1khz的时钟信号触发
        case n is
            when "000"=> segselect8<="01111111";data<= row_code_receive1(0);    --显示第一位密码
            when "001" =>segselect8<="10111111";data<=row_code_receive1(1);     --显示第二位密码
            when "010" =>segselect8<="11011111";data<=row_code_receive1(2);     --显示第三位密码
            when "011" =>segselect8<="11101111";data<=row_code_receive1(3);     --显示第四位密码
            when others =>segselect8<="11111111";data<=10;
        end case;
        n:=n+1;
        if(n="100")then                                           --循环显示4位数字，循环周期为4ms
            n:="000";
        end if;
    end if;

end process password_display; 


with STATE select--虚拟接口判断上锁状态（'1'为解锁）
trusted <=  '1' when s3, 
            '1'when s2,
            '0' when others;
end Behavioral;