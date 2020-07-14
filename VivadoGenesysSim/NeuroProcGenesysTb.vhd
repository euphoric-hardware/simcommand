----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2020 12:03:14 PM
-- Design Name: 
-- Module Name: NeuroProcGenesysTb - Behavioral
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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity NeuroProcGenesysTb is
--  Port ( );
end NeuroProcGenesysTb;

architecture Behavioral of NeuroProcGenesysTb is

constant clock_period : time := 5 ns;
constant sys_clk_per  : time := 12.5 ns;


signal clk_p : std_logic := '0';
signal clk_n : std_logic := '1';
signal rst : std_logic := '1';

signal rx : std_logic := '1';
signal tx : std_logic;

signal temp : unsigned(15 downto 0);
signal temp2 : unsigned(15 downto 0);



component neuroTop
    port(
    sysclk_n: in std_logic;
    sysclk_p: in std_logic;
    reset:    in std_logic;
    uartTx:   out std_logic;
    uartRx:   in std_logic);
end component;
    

begin

    insNeuroTop: neuroTop
        port map(
        sysclk_n => clk_p,
        sysclk_p => clk_n,
        reset => rst,
        uartTx => tx,
        uartRx => rx);
    
    process
--    file file_handler     : text open read_mode is "periods.txt";
--    Variable row          : line;
--    Variable rPer         : integer;
    begin             
--        wait until rst = '0';
        
--        wait for sys_clk_per*10;
        
--        for k in 0 to 483 loop
--            readline(file_handler, row);
--            read(row,rPer);
            
--            -- send address
--            rx <= '0';
--            wait for sys_clk_per*695; --baud period
                        
--            for a in 0 to 7 loop
                
--                temp <= to_unsigned(k, 16);
--                wait for 1 ps;
--                temp2 <= (temp srl (8+a)) and to_unsigned(1,16);
--                wait for 1 ps;
--                rx <= temp2(0);
--                wait for sys_clk_per*695;
                
--            end loop;
            
--            rx <= '1'; --stopbit 
--            wait for sys_clk_per*800; --longer than one baud period for good measure
            
--            rx <= '0';
--            wait for sys_clk_per*695; --baud period
                        
--            for b in 0 to 7 loop
                
                
--                temp2 <= (temp srl b) and to_unsigned(1,16);
--                wait for 1 ps;
--                rx <= temp2(0);
--                wait for sys_clk_per*695;
                
--            end loop;
            
--            rx <= '1'; --stopbit 
--            wait for sys_clk_per*800; --longer than one baud period for good measure
            
--            -- send period
--            rx <= '0';
--            wait for sys_clk_per*695; --baud period
                        
--            for c in 0 to 7 loop
                
--                temp <= to_unsigned(rPer, 16);
--                wait for 1 ps;
--                temp2 <= (temp srl (8+c)) and to_unsigned(1,16);
--                wait for 1 ps;
--                rx <= temp2(0);
--                wait for sys_clk_per*695;
                
--            end loop;
            
--            rx <= '1'; --stopbit 
--            wait for sys_clk_per*800; --longer than one baud period for good measure
            
--            rx <= '0';
--            wait for sys_clk_per*695; --baud period
                        
--            for d in 0 to 7 loop
                
                
--                temp2 <= (temp srl d) and to_unsigned(1,16);
--                wait for 1 ps;
--                rx <= temp2(0);
--                wait for sys_clk_per*695;
                
--            end loop;
            
--            rx <= '1'; --stopbit 
--            wait for sys_clk_per*800; --longer than one baud period for good measure
--        end loop;
        
        wait for sys_clk_per*80000*50; --wait for a full input period plus 5 for some lead way
        
    
        std.env.finish;
        wait;
    end process;
    
    
    
    --clock process
    process
    begin
        wait for clock_period/2;
        clk_p <= not clk_p;
        clk_n <= not clk_n;
        
    end process;
    
    
    --reset process
    process
    begin
        rst <= '1';
        wait for clock_period*5;
        rst <= '0';
        wait;
    end process;
        
end Behavioral;


