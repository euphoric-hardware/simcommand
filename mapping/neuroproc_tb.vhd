-- Inspired by https://github.com/ricardo-jasinski/vhdl-csv-file-reader/blob/master/hdl/package/csv_file_reader_pkg.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity neuroproc_tb is
end neuroproc_tb;

architecture rtl of neuroproc_tb is
    constant T_clk : time := 5 ns;
    constant FREQ     : natural := 200_000_000;
    constant BAUDRATE : natural := 115_200;
    constant BITDELAY : time := (FREQ / BAUDRATE + 1) * T_clk;

    signal sysclk_n, sysclk_p, reset, uartRx, uartTx : std_logic;

    component NeuroTop is
        port (
            sysclk_n : in std_logic;
            sysclk_p : in std_logic;
            reset    : in std_logic;
            uartRx   : in std_logic;
            uartTx   : out std_logic
        );
    end component;

    shared variable timeCount : time := 0 sec;

begin

    dut : NeuroTop
    port map ( sysclk_n=>sysclk_n, 
               sysclk_p=>sysclk_p, 
               reset=>reset, 
               uartTx=>uartTx, 
               uartRx=>uartRx );

    stimuli : process is
        file image   : text open read_mode is "image.txt";
        file results : text open read_mode is "results.txt";
        variable L   : line;
        variable val : integer;
        variable index, rxRate : std_logic_vector(15 downto 0);
        variable txByte : std_logic_vector(7 downto 0);

        procedure skip_sep is
            variable c : character;
        begin
            read(L, c);
        end;

        impure function read_integer return integer is
            variable rV : integer;
        begin
            read(L, rV);
            skip_sep;
            return rV;
        end;

        procedure trans_byte(b : std_logic_vector(7 downto 0)) is
        begin
            -- Transmit start bit
            uartRx <= '0';
            wait for BITDELAY;

            -- Transmit byte
            for i in 0 to 7 loop
                uartRx <= b(i);
                wait for BITDELAY;
            end loop;

            -- Transmit stop bit
            uartRx <= '1';
            wait for BITDELAY;
        end;

        procedure rec_byte is
        begin
            -- Expected the start bit to have been received already
            wait for BITDELAY;
            for i in 0 to 7 loop
                txByte(i) := uartTx;
                wait for BITDELAY;
            end loop;

            -- Receive stop bit
            assert uartTx = '1'
                report "stop bit not received"
                severity failure;
        end;
    begin

        -- Reset the accelerator
        reset  <= '0';
        uartRx <= '1';
        wait until falling_edge(sysclk_p);
        reset  <= '0';
        wait for T_clk;

        -- Write image to processor
        readline(image, L);
        inp : for i in 0 to 483 loop
            index := std_logic_vector(to_unsigned(i, 16));
            
            -- Read rate
            val := read_integer;
            report "inputting rate " & integer'image(val);
            rxRate := std_logic_vector(to_unsigned(val, 16));

            -- Transmit index
            trans_byte(index(15 downto 8));
            trans_byte(index( 7 downto 0));

            -- Transmit rate
            trans_byte(rxRate(15 downto 8));
            trans_byte(rxRate( 7 downto 0));
        end loop inp;

        -- Read out spikes and verify according to results file
        readline(results, L);
        outp : while timeCount < 1 sec loop
            if uartTx = '0' then
                rec_byte;
                val := read_integer;
                assert txByte = std_logic_vector(to_unsigned(val, 8))
                    report "expected spike " & integer'image(val) & " but got " & integer'image(to_integer(unsigned(txByte)))
                    severity failure;
            end if;
            wait for T_clk;
        end loop outp;

        std.env.stop(0); -- replace with std.env.finish;

    end process stimuli;

    clk : process is
    begin
        sysclk_p <= '1'; sysclk_n <= '0'; wait for T_clk / 2;
        sysclk_p <= '0'; sysclk_n <= '1'; wait for T_clk / 2;
        timeCount := timeCount + T_clk;
    end process clk;

end rtl;
