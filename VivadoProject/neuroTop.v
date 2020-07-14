module neuroTop(
    input sysclk_n,
    input sysclk_p,
    input reset,
    output uartTx,
    input uartRx
    );
    
    wire clk_n;
    wire clk_p;
    wire clk;
    wire np_reset;
    wire np_io_uartTx;
    wire np_io_uartRx;
 
    clk_wiz_0 clkGen(
        .clk_out1(clk),
        .reset(np_reset),
        .clk_in1_p(clk_p),
        .clk_in1_n(clk_n)
    );
        
    NeuromorphicProcessor np(
        .clock(clk),
        .reset(np_reset),
        .io_uartTx(np_io_uartTx),
        .io_uartRx(np_io_uartRx)
    );
    
    assign np_reset = reset;
    assign uartTx = np_io_uartTx;
    assign np_io_uartRx = uartRx;
    assign clk_n = sysclk_n;
    assign clk_p = sysclk_p;
    
endmodule
