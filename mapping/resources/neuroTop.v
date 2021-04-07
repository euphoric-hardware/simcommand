
module neuroTop(sysclk_n, sysclk_p, reset, uartTx, uartRx);
    
input  sysclk_n, sysclk_p, reset, uartRx;
output uartTx;
wire clk;

clk_wiz_0 clkGen(
    .clk(clk),
    .reset(reset),
    .locked(),
    .clk_in1_p(sysclk_p),
    .clk_in1_n(sysclk_n)
);

NeuromorphicProcessor np(
    .clock(clk),
    .reset(reset),
    .io_uartTx(uartTx),
    .io_uartRx(uartRx)
);
    
endmodule
