module ClockBufferVerilog(
  input   io_I,
  input   io_CE,
  output  io_O
);
  wire  bb_I; // @[ClockBuffer.scala 46:18]
  wire  bb_CE; // @[ClockBuffer.scala 46:18]
  wire  bb_O; // @[ClockBuffer.scala 46:18]
  ClockBufferBB bb ( // @[ClockBuffer.scala 46:18]
    .I(bb_I),
    .CE(bb_CE),
    .O(bb_O)
  );
  assign io_O = bb_O; // @[ClockBuffer.scala 47:6]
  assign bb_I = io_I; // @[ClockBuffer.scala 47:6]
  assign bb_CE = io_CE; // @[ClockBuffer.scala 47:6]
endmodule
module TrueDualPortMemory(
  input        io_clka,
  input        io_ena,
  input        io_wea,
  input  [8:0] io_addra,
  input  [8:0] io_dia,
  input        io_clkb,
  input        io_enb,
  input  [8:0] io_addrb,
  output [8:0] io_dob
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg [8:0] ram [0:511]; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_io_doa_MPORT_en; // @[TrueDualPortMemory.scala 30:16]
  wire [8:0] ram_io_doa_MPORT_addr; // @[TrueDualPortMemory.scala 30:16]
  wire [8:0] ram_io_doa_MPORT_data; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_io_dob_MPORT_en; // @[TrueDualPortMemory.scala 30:16]
  wire [8:0] ram_io_dob_MPORT_addr; // @[TrueDualPortMemory.scala 30:16]
  wire [8:0] ram_io_dob_MPORT_data; // @[TrueDualPortMemory.scala 30:16]
  wire [8:0] ram_MPORT_data; // @[TrueDualPortMemory.scala 30:16]
  wire [8:0] ram_MPORT_addr; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_MPORT_mask; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_MPORT_en; // @[TrueDualPortMemory.scala 30:16]
  wire [8:0] ram_MPORT_1_data; // @[TrueDualPortMemory.scala 30:16]
  wire [8:0] ram_MPORT_1_addr; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_MPORT_1_mask; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_MPORT_1_en; // @[TrueDualPortMemory.scala 30:16]
  reg  ram_io_doa_MPORT_en_pipe_0;
  reg [8:0] ram_io_doa_MPORT_addr_pipe_0;
  reg  ram_io_dob_MPORT_en_pipe_0;
  reg [8:0] ram_io_dob_MPORT_addr_pipe_0;
  assign ram_io_doa_MPORT_en = ram_io_doa_MPORT_en_pipe_0;
  assign ram_io_doa_MPORT_addr = ram_io_doa_MPORT_addr_pipe_0;
  assign ram_io_doa_MPORT_data = ram[ram_io_doa_MPORT_addr]; // @[TrueDualPortMemory.scala 30:16]
  assign ram_io_dob_MPORT_en = ram_io_dob_MPORT_en_pipe_0;
  assign ram_io_dob_MPORT_addr = ram_io_dob_MPORT_addr_pipe_0;
  assign ram_io_dob_MPORT_data = ram[ram_io_dob_MPORT_addr]; // @[TrueDualPortMemory.scala 30:16]
  assign ram_MPORT_data = io_dia;
  assign ram_MPORT_addr = io_addra;
  assign ram_MPORT_mask = 1'h1;
  assign ram_MPORT_en = io_ena & io_wea;
  assign ram_MPORT_1_data = 9'h0;
  assign ram_MPORT_1_addr = io_addrb;
  assign ram_MPORT_1_mask = 1'h1;
  assign ram_MPORT_1_en = 1'h0;
  assign io_dob = ram_io_dob_MPORT_data; // @[TrueDualPortMemory.scala 47:18 51:14]
  always @(posedge io_clka) begin
    if (ram_MPORT_en & ram_MPORT_mask) begin
      ram[ram_MPORT_addr] <= ram_MPORT_data; // @[TrueDualPortMemory.scala 30:16]
    end
    ram_io_doa_MPORT_en_pipe_0 <= io_ena;
    if (io_ena) begin
      ram_io_doa_MPORT_addr_pipe_0 <= io_addra;
    end
  end
  always @(posedge io_clkb) begin
    if (ram_MPORT_1_en & ram_MPORT_1_mask) begin
      ram[ram_MPORT_1_addr] <= ram_MPORT_1_data; // @[TrueDualPortMemory.scala 30:16]
    end
    ram_io_dob_MPORT_en_pipe_0 <= io_enb;
    if (io_enb) begin
      ram_io_dob_MPORT_addr_pipe_0 <= io_addrb;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 512; initvar = initvar+1)
    ram[initvar] = _RAND_0[8:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  ram_io_doa_MPORT_en_pipe_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  ram_io_doa_MPORT_addr_pipe_0 = _RAND_2[8:0];
  _RAND_3 = {1{`RANDOM}};
  ram_io_dob_MPORT_en_pipe_0 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  ram_io_dob_MPORT_addr_pipe_0 = _RAND_4[8:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module TrueDualPortMemory_2(
  input        io_clka,
  input        io_ena,
  input        io_wea,
  input  [3:0] io_addra,
  input  [7:0] io_dia,
  input        io_clkb,
  input        io_enb,
  input  [3:0] io_addrb,
  output [7:0] io_dob
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] ram [0:15]; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_io_doa_MPORT_en; // @[TrueDualPortMemory.scala 30:16]
  wire [3:0] ram_io_doa_MPORT_addr; // @[TrueDualPortMemory.scala 30:16]
  wire [7:0] ram_io_doa_MPORT_data; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_io_dob_MPORT_en; // @[TrueDualPortMemory.scala 30:16]
  wire [3:0] ram_io_dob_MPORT_addr; // @[TrueDualPortMemory.scala 30:16]
  wire [7:0] ram_io_dob_MPORT_data; // @[TrueDualPortMemory.scala 30:16]
  wire [7:0] ram_MPORT_data; // @[TrueDualPortMemory.scala 30:16]
  wire [3:0] ram_MPORT_addr; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_MPORT_mask; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_MPORT_en; // @[TrueDualPortMemory.scala 30:16]
  wire [7:0] ram_MPORT_1_data; // @[TrueDualPortMemory.scala 30:16]
  wire [3:0] ram_MPORT_1_addr; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_MPORT_1_mask; // @[TrueDualPortMemory.scala 30:16]
  wire  ram_MPORT_1_en; // @[TrueDualPortMemory.scala 30:16]
  reg  ram_io_doa_MPORT_en_pipe_0;
  reg [3:0] ram_io_doa_MPORT_addr_pipe_0;
  reg  ram_io_dob_MPORT_en_pipe_0;
  reg [3:0] ram_io_dob_MPORT_addr_pipe_0;
  assign ram_io_doa_MPORT_en = ram_io_doa_MPORT_en_pipe_0;
  assign ram_io_doa_MPORT_addr = ram_io_doa_MPORT_addr_pipe_0;
  assign ram_io_doa_MPORT_data = ram[ram_io_doa_MPORT_addr]; // @[TrueDualPortMemory.scala 30:16]
  assign ram_io_dob_MPORT_en = ram_io_dob_MPORT_en_pipe_0;
  assign ram_io_dob_MPORT_addr = ram_io_dob_MPORT_addr_pipe_0;
  assign ram_io_dob_MPORT_data = ram[ram_io_dob_MPORT_addr]; // @[TrueDualPortMemory.scala 30:16]
  assign ram_MPORT_data = io_dia;
  assign ram_MPORT_addr = io_addra;
  assign ram_MPORT_mask = 1'h1;
  assign ram_MPORT_en = io_ena & io_wea;
  assign ram_MPORT_1_data = 8'h0;
  assign ram_MPORT_1_addr = io_addrb;
  assign ram_MPORT_1_mask = 1'h1;
  assign ram_MPORT_1_en = 1'h0;
  assign io_dob = ram_io_dob_MPORT_data; // @[TrueDualPortMemory.scala 47:18 51:14]
  always @(posedge io_clka) begin
    if (ram_MPORT_en & ram_MPORT_mask) begin
      ram[ram_MPORT_addr] <= ram_MPORT_data; // @[TrueDualPortMemory.scala 30:16]
    end
    ram_io_doa_MPORT_en_pipe_0 <= io_ena;
    if (io_ena) begin
      ram_io_doa_MPORT_addr_pipe_0 <= io_addra;
    end
  end
  always @(posedge io_clkb) begin
    if (ram_MPORT_1_en & ram_MPORT_1_mask) begin
      ram[ram_MPORT_1_addr] <= ram_MPORT_1_data; // @[TrueDualPortMemory.scala 30:16]
    end
    ram_io_dob_MPORT_en_pipe_0 <= io_enb;
    if (io_enb) begin
      ram_io_dob_MPORT_addr_pipe_0 <= io_addrb;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 16; initvar = initvar+1)
    ram[initvar] = _RAND_0[7:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  ram_io_doa_MPORT_en_pipe_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  ram_io_doa_MPORT_addr_pipe_0 = _RAND_2[3:0];
  _RAND_3 = {1{`RANDOM}};
  ram_io_dob_MPORT_en_pipe_0 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  ram_io_dob_MPORT_addr_pipe_0 = _RAND_4[3:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module WriteControl(
  input        io_clkw,
  input        io_resetw,
  input        io_wr,
  input  [4:0] io_rPtr,
  output       io_full,
  output [4:0] io_wPtr,
  output [3:0] io_wAddr
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] wPtr; // @[TrueDualPortFIFO.scala 55:25]
  wire  gray1_bVec_0 = ^wPtr; // @[TrueDualPortFIFO.scala 29:60]
  wire  gray1_bVec_1 = ^wPtr[4:1]; // @[TrueDualPortFIFO.scala 29:60]
  wire  gray1_bVec_2 = ^wPtr[4:2]; // @[TrueDualPortFIFO.scala 29:60]
  wire  gray1_bVec_3 = ^wPtr[4:3]; // @[TrueDualPortFIFO.scala 29:60]
  wire  gray1_bVec_4 = ^wPtr[4]; // @[TrueDualPortFIFO.scala 29:60]
  wire [4:0] _gray1_b1_T = {gray1_bVec_4,gray1_bVec_3,gray1_bVec_2,gray1_bVec_1,gray1_bVec_0}; // @[TrueDualPortFIFO.scala 30:16]
  wire [4:0] gray1_b1 = _gray1_b1_T + 5'h1; // @[TrueDualPortFIFO.scala 30:23]
  wire [4:0] _gray1_T_1 = {1'h0,gray1_b1[4:1]}; // @[TrueDualPortFIFO.scala 31:20]
  wire [4:0] gray1 = gray1_b1 ^ _gray1_T_1; // @[TrueDualPortFIFO.scala 31:8]
  wire  rAddrMsb = io_rPtr[4] ^ io_rPtr[3]; // @[TrueDualPortFIFO.scala 68:34]
  wire  wAddrMsb = wPtr[4] ^ wPtr[3]; // @[TrueDualPortFIFO.scala 64:31]
  wire  fullFlag = io_rPtr[4] != wPtr[4] & io_rPtr[2:0] == wPtr[2:0] & rAddrMsb == wAddrMsb; // @[TrueDualPortFIFO.scala 69:98]
  assign io_full = io_rPtr[4] != wPtr[4] & io_rPtr[2:0] == wPtr[2:0] & rAddrMsb == wAddrMsb; // @[TrueDualPortFIFO.scala 69:98]
  assign io_wPtr = wPtr; // @[TrueDualPortFIFO.scala 73:16]
  assign io_wAddr = {wAddrMsb,wPtr[2:0]}; // @[TrueDualPortFIFO.scala 65:28]
  always @(posedge io_clkw or posedge io_resetw) begin
    if (io_resetw) begin // @[TrueDualPortFIFO.scala 61:22]
      wPtr <= 5'h0;
    end else if (io_wr & ~fullFlag) begin
      wPtr <= gray1;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  wPtr = _RAND_0[4:0];
`endif // RANDOMIZE_REG_INIT
  if (io_resetw) begin
    wPtr = 5'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ReadControl(
  input        io_clkr,
  input        io_resetr,
  input        io_rd,
  input  [4:0] io_wPtr,
  output       io_empty,
  output [4:0] io_rPtr,
  output [3:0] io_rAddr
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] rPtr; // @[TrueDualPortFIFO.scala 99:25]
  wire  gray1_bVec_0 = ^rPtr; // @[TrueDualPortFIFO.scala 29:60]
  wire  gray1_bVec_1 = ^rPtr[4:1]; // @[TrueDualPortFIFO.scala 29:60]
  wire  gray1_bVec_2 = ^rPtr[4:2]; // @[TrueDualPortFIFO.scala 29:60]
  wire  gray1_bVec_3 = ^rPtr[4:3]; // @[TrueDualPortFIFO.scala 29:60]
  wire  gray1_bVec_4 = ^rPtr[4]; // @[TrueDualPortFIFO.scala 29:60]
  wire [4:0] _gray1_b1_T = {gray1_bVec_4,gray1_bVec_3,gray1_bVec_2,gray1_bVec_1,gray1_bVec_0}; // @[TrueDualPortFIFO.scala 30:16]
  wire [4:0] gray1_b1 = _gray1_b1_T + 5'h1; // @[TrueDualPortFIFO.scala 30:23]
  wire [4:0] _gray1_T_1 = {1'h0,gray1_b1[4:1]}; // @[TrueDualPortFIFO.scala 31:20]
  wire [4:0] gray1 = gray1_b1 ^ _gray1_T_1; // @[TrueDualPortFIFO.scala 31:8]
  wire  wAddrMsb = io_wPtr[4] ^ io_wPtr[3]; // @[TrueDualPortFIFO.scala 112:35]
  wire  rAddrMsb = rPtr[4] ^ rPtr[3]; // @[TrueDualPortFIFO.scala 108:31]
  wire  emptyFlag = io_wPtr[4] == rPtr[4] & io_wPtr[2:0] == rPtr[2:0] & wAddrMsb == rAddrMsb; // @[TrueDualPortFIFO.scala 113:99]
  assign io_empty = io_wPtr[4] == rPtr[4] & io_wPtr[2:0] == rPtr[2:0] & wAddrMsb == rAddrMsb; // @[TrueDualPortFIFO.scala 113:99]
  assign io_rPtr = rPtr; // @[TrueDualPortFIFO.scala 117:16]
  assign io_rAddr = {rAddrMsb,rPtr[2:0]}; // @[TrueDualPortFIFO.scala 109:28]
  always @(posedge io_clkr or posedge io_resetr) begin
    if (io_resetr) begin // @[TrueDualPortFIFO.scala 105:22]
      rPtr <= 5'h0;
    end else if (io_rd & ~emptyFlag) begin
      rPtr <= gray1;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  rPtr = _RAND_0[4:0];
`endif // RANDOMIZE_REG_INIT
  if (io_resetr) begin
    rPtr = 5'h0;
  end
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module TrueDualPortFIFO(
  input        io_clki,
  input        io_we,
  input  [7:0] io_datai,
  output       io_full,
  input        io_clko,
  input        io_en,
  output [7:0] io_datao,
  output       io_empty,
  input        io_rst
);
  wire  ram_io_clka; // @[TrueDualPortFIFO.scala 123:21]
  wire  ram_io_ena; // @[TrueDualPortFIFO.scala 123:21]
  wire  ram_io_wea; // @[TrueDualPortFIFO.scala 123:21]
  wire [3:0] ram_io_addra; // @[TrueDualPortFIFO.scala 123:21]
  wire [7:0] ram_io_dia; // @[TrueDualPortFIFO.scala 123:21]
  wire  ram_io_clkb; // @[TrueDualPortFIFO.scala 123:21]
  wire  ram_io_enb; // @[TrueDualPortFIFO.scala 123:21]
  wire [3:0] ram_io_addrb; // @[TrueDualPortFIFO.scala 123:21]
  wire [7:0] ram_io_dob; // @[TrueDualPortFIFO.scala 123:21]
  wire  wctrl_io_clkw; // @[TrueDualPortFIFO.scala 124:21]
  wire  wctrl_io_resetw; // @[TrueDualPortFIFO.scala 124:21]
  wire  wctrl_io_wr; // @[TrueDualPortFIFO.scala 124:21]
  wire [4:0] wctrl_io_rPtr; // @[TrueDualPortFIFO.scala 124:21]
  wire  wctrl_io_full; // @[TrueDualPortFIFO.scala 124:21]
  wire [4:0] wctrl_io_wPtr; // @[TrueDualPortFIFO.scala 124:21]
  wire [3:0] wctrl_io_wAddr; // @[TrueDualPortFIFO.scala 124:21]
  wire  rctrl_io_clkr; // @[TrueDualPortFIFO.scala 125:21]
  wire  rctrl_io_resetr; // @[TrueDualPortFIFO.scala 125:21]
  wire  rctrl_io_rd; // @[TrueDualPortFIFO.scala 125:21]
  wire [4:0] rctrl_io_wPtr; // @[TrueDualPortFIFO.scala 125:21]
  wire  rctrl_io_empty; // @[TrueDualPortFIFO.scala 125:21]
  wire [4:0] rctrl_io_rPtr; // @[TrueDualPortFIFO.scala 125:21]
  wire [3:0] rctrl_io_rAddr; // @[TrueDualPortFIFO.scala 125:21]
  wire  _ram_io_ena_T = ~wctrl_io_full; // @[TrueDualPortFIFO.scala 135:28]
  TrueDualPortMemory_2 ram ( // @[TrueDualPortFIFO.scala 123:21]
    .io_clka(ram_io_clka),
    .io_ena(ram_io_ena),
    .io_wea(ram_io_wea),
    .io_addra(ram_io_addra),
    .io_dia(ram_io_dia),
    .io_clkb(ram_io_clkb),
    .io_enb(ram_io_enb),
    .io_addrb(ram_io_addrb),
    .io_dob(ram_io_dob)
  );
  WriteControl wctrl ( // @[TrueDualPortFIFO.scala 124:21]
    .io_clkw(wctrl_io_clkw),
    .io_resetw(wctrl_io_resetw),
    .io_wr(wctrl_io_wr),
    .io_rPtr(wctrl_io_rPtr),
    .io_full(wctrl_io_full),
    .io_wPtr(wctrl_io_wPtr),
    .io_wAddr(wctrl_io_wAddr)
  );
  ReadControl rctrl ( // @[TrueDualPortFIFO.scala 125:21]
    .io_clkr(rctrl_io_clkr),
    .io_resetr(rctrl_io_resetr),
    .io_rd(rctrl_io_rd),
    .io_wPtr(rctrl_io_wPtr),
    .io_empty(rctrl_io_empty),
    .io_rPtr(rctrl_io_rPtr),
    .io_rAddr(rctrl_io_rAddr)
  );
  assign io_full = wctrl_io_full; // @[TrueDualPortFIFO.scala 142:11]
  assign io_datao = ram_io_dob; // @[TrueDualPortFIFO.scala 152:16]
  assign io_empty = rctrl_io_empty; // @[TrueDualPortFIFO.scala 158:12]
  assign ram_io_clka = io_clki; // @[TrueDualPortFIFO.scala 132:16]
  assign ram_io_ena = io_we & ~wctrl_io_full; // @[TrueDualPortFIFO.scala 135:25]
  assign ram_io_wea = io_we & _ram_io_ena_T; // @[TrueDualPortFIFO.scala 136:25]
  assign ram_io_addra = wctrl_io_wAddr; // @[TrueDualPortFIFO.scala 126:19 144:9]
  assign ram_io_dia = io_datai; // @[TrueDualPortFIFO.scala 134:16]
  assign ram_io_clkb = io_clko; // @[TrueDualPortFIFO.scala 147:16]
  assign ram_io_enb = io_en & ~rctrl_io_empty; // @[TrueDualPortFIFO.scala 150:25]
  assign ram_io_addrb = rctrl_io_rAddr; // @[TrueDualPortFIFO.scala 128:19 160:9]
  assign wctrl_io_clkw = io_clki; // @[TrueDualPortFIFO.scala 138:17]
  assign wctrl_io_resetw = io_rst; // @[TrueDualPortFIFO.scala 139:19]
  assign wctrl_io_wr = io_we; // @[TrueDualPortFIFO.scala 140:15]
  assign wctrl_io_rPtr = rctrl_io_rPtr; // @[TrueDualPortFIFO.scala 129:19 159:8]
  assign rctrl_io_clkr = io_clko; // @[TrueDualPortFIFO.scala 154:17]
  assign rctrl_io_resetr = io_rst; // @[TrueDualPortFIFO.scala 155:19]
  assign rctrl_io_rd = io_en; // @[TrueDualPortFIFO.scala 156:15]
  assign rctrl_io_wPtr = wctrl_io_wPtr; // @[TrueDualPortFIFO.scala 127:19 143:8]
endmodule
module Tx(
  input        clock,
  input        reset,
  output       io_tx,
  output       io_ready,
  input        io_valid,
  input  [7:0] io_data
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_REG_INIT
  reg [10:0] clkCnt; // @[UART.scala 17:23]
  reg  baudtick; // @[UART.scala 18:25]
  reg [1:0] state; // @[UART.scala 19:22]
  reg [7:0] data; // @[UART.scala 20:21]
  reg  txBit; // @[UART.scala 21:22]
  reg [2:0] bitCnt; // @[UART.scala 22:23]
  reg  readyR; // @[UART.scala 23:23]
  wire  _T = clkCnt == 11'h2b6; // @[UART.scala 28:15]
  wire [10:0] _clkCnt_T_1 = clkCnt + 11'h1; // @[UART.scala 32:22]
  wire  _T_2 = baudtick & io_valid; // @[UART.scala 40:21]
  wire  _GEN_2 = baudtick & io_valid ? 1'h0 : txBit; // @[UART.scala 40:34 41:15 21:22]
  wire [7:0] _data_T_1 = {1'h1,data[7:1]}; // @[UART.scala 51:24]
  wire [2:0] _bitCnt_T_1 = bitCnt + 3'h1; // @[UART.scala 53:28]
  wire [2:0] _GEN_7 = bitCnt < 3'h7 ? _bitCnt_T_1 : 3'h0; // @[UART.scala 52:28 53:18 55:18]
  wire [1:0] _GEN_8 = bitCnt < 3'h7 ? state : 2'h2; // @[UART.scala 19:22 52:28 56:17]
  wire  _GEN_9 = baudtick ? data[0] : txBit; // @[UART.scala 49:22 50:15 21:22]
  wire  _GEN_13 = baudtick | txBit; // @[UART.scala 61:22 62:15 21:22]
  wire [1:0] _GEN_14 = baudtick ? 2'h0 : state; // @[UART.scala 61:22 63:15 19:22]
  wire  _GEN_15 = 2'h2 == state ? _GEN_13 : txBit; // @[UART.scala 38:17 21:22]
  wire  _GEN_17 = 2'h1 == state ? _GEN_9 : _GEN_15; // @[UART.scala 38:17]
  wire  _GEN_21 = 2'h0 == state ? _GEN_2 : _GEN_17; // @[UART.scala 38:17]
  wire  _GEN_24 = 2'h0 == state & _T_2; // @[UART.scala 36:10 38:17]
  assign io_tx = txBit; // @[UART.scala 25:9]
  assign io_ready = readyR; // @[UART.scala 26:12]
  always @(posedge clock) begin
    if (reset) begin // @[UART.scala 17:23]
      clkCnt <= 11'h0; // @[UART.scala 17:23]
    end else if (clkCnt == 11'h2b6) begin // @[UART.scala 28:30]
      clkCnt <= 11'h0; // @[UART.scala 29:12]
    end else begin
      clkCnt <= _clkCnt_T_1; // @[UART.scala 32:12]
    end
    if (reset) begin // @[UART.scala 18:25]
      baudtick <= 1'h0; // @[UART.scala 18:25]
    end else begin
      baudtick <= _T;
    end
    if (reset) begin // @[UART.scala 19:22]
      state <= 2'h0; // @[UART.scala 19:22]
    end else if (2'h0 == state) begin // @[UART.scala 38:17]
      if (baudtick & io_valid) begin // @[UART.scala 40:34]
        state <= 2'h1; // @[UART.scala 42:15]
      end
    end else if (2'h1 == state) begin // @[UART.scala 38:17]
      if (baudtick) begin // @[UART.scala 49:22]
        state <= _GEN_8;
      end
    end else if (2'h2 == state) begin // @[UART.scala 38:17]
      state <= _GEN_14;
    end
    if (reset) begin // @[UART.scala 20:21]
      data <= 8'h0; // @[UART.scala 20:21]
    end else if (2'h0 == state) begin // @[UART.scala 38:17]
      if (baudtick & io_valid) begin // @[UART.scala 40:34]
        data <= io_data; // @[UART.scala 45:14]
      end
    end else if (2'h1 == state) begin // @[UART.scala 38:17]
      if (baudtick) begin // @[UART.scala 49:22]
        data <= _data_T_1; // @[UART.scala 51:14]
      end
    end
    txBit <= reset | _GEN_21; // @[UART.scala 21:{22,22}]
    if (reset) begin // @[UART.scala 22:23]
      bitCnt <= 3'h0; // @[UART.scala 22:23]
    end else if (2'h0 == state) begin // @[UART.scala 38:17]
      if (baudtick & io_valid) begin // @[UART.scala 40:34]
        bitCnt <= 3'h0; // @[UART.scala 43:16]
      end
    end else if (2'h1 == state) begin // @[UART.scala 38:17]
      if (baudtick) begin // @[UART.scala 49:22]
        bitCnt <= _GEN_7;
      end
    end
    if (reset) begin // @[UART.scala 23:23]
      readyR <= 1'h0; // @[UART.scala 23:23]
    end else begin
      readyR <= _GEN_24;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  clkCnt = _RAND_0[10:0];
  _RAND_1 = {1{`RANDOM}};
  baudtick = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  state = _RAND_2[1:0];
  _RAND_3 = {1{`RANDOM}};
  data = _RAND_3[7:0];
  _RAND_4 = {1{`RANDOM}};
  txBit = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  bitCnt = _RAND_5[2:0];
  _RAND_6 = {1{`RANDOM}};
  readyR = _RAND_6[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Rx(
  input        clock,
  input        reset,
  input        io_rx,
  input        io_ready,
  output       io_valid,
  output [7:0] io_data
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [1:0] dataSr; // @[UART.scala 80:25]
  reg [1:0] filter; // @[UART.scala 81:25]
  reg  rxBit; // @[UART.scala 82:25]
  reg [3:0] spaceCnt; // @[UART.scala 83:25]
  reg [7:0] data; // @[UART.scala 84:25]
  reg [5:0] clkCnt; // @[UART.scala 85:25]
  reg  baudTick; // @[UART.scala 86:25]
  reg  bitTick; // @[UART.scala 87:25]
  reg [1:0] state; // @[UART.scala 88:25]
  reg [2:0] bitCnt; // @[UART.scala 89:25]
  reg  validR; // @[UART.scala 90:25]
  wire  _GEN_0 = validR & io_ready ? 1'h0 : validR; // @[UART.scala 95:28 96:12 90:25]
  wire  _T_1 = clkCnt == 6'h2b; // @[UART.scala 99:15]
  wire [5:0] _clkCnt_T_1 = clkCnt + 6'h1; // @[UART.scala 104:22]
  wire [1:0] _dataSr_T_1 = {dataSr[0],io_rx}; // @[UART.scala 110:25]
  wire [1:0] _filter_T_1 = filter + 2'h1; // @[UART.scala 113:24]
  wire [1:0] _filter_T_3 = filter - 2'h1; // @[UART.scala 115:24]
  wire  _GEN_5 = filter == 2'h0 ? 1'h0 : rxBit; // @[UART.scala 120:32 121:13 82:25]
  wire  _GEN_6 = filter == 2'h3 | _GEN_5; // @[UART.scala 118:26 119:13]
  wire  _T_11 = spaceCnt == 4'hf; // @[UART.scala 124:19]
  wire [3:0] _spaceCnt_T_1 = spaceCnt + 4'h1; // @[UART.scala 128:28]
  wire  _GEN_12 = baudTick ? _GEN_6 : rxBit; // @[UART.scala 109:18 82:25]
  wire  _GEN_13 = baudTick & _T_11; // @[UART.scala 107:11 109:18]
  wire [7:0] _data_T_1 = {rxBit,data[7:1]}; // @[UART.scala 143:23]
  wire [2:0] _bitCnt_T_1 = bitCnt + 3'h1; // @[UART.scala 145:28]
  wire [2:0] _GEN_16 = bitCnt < 3'h7 ? _bitCnt_T_1 : 3'h0; // @[UART.scala 144:27 145:18 147:18]
  wire [1:0] _GEN_17 = bitCnt < 3'h7 ? state : 2'h2; // @[UART.scala 144:27 148:17 88:25]
  wire [1:0] _GEN_21 = bitTick & rxBit ? 2'h0 : state; // @[UART.scala 153:30 154:15 88:25]
  wire  _GEN_22 = bitTick & rxBit | _GEN_0; // @[UART.scala 153:30 155:16]
  assign io_valid = validR; // @[UART.scala 93:12]
  assign io_data = data; // @[UART.scala 92:11]
  always @(posedge clock) begin
    if (reset) begin // @[UART.scala 80:25]
      dataSr <= 2'h3; // @[UART.scala 80:25]
    end else if (baudTick) begin // @[UART.scala 109:18]
      dataSr <= _dataSr_T_1; // @[UART.scala 110:12]
    end
    if (reset) begin // @[UART.scala 81:25]
      filter <= 2'h3; // @[UART.scala 81:25]
    end else if (baudTick) begin // @[UART.scala 109:18]
      if (dataSr[1] & filter < 2'h3) begin // @[UART.scala 112:37]
        filter <= _filter_T_1; // @[UART.scala 113:14]
      end else if (~dataSr[1] & filter > 2'h0) begin // @[UART.scala 114:44]
        filter <= _filter_T_3; // @[UART.scala 115:14]
      end
    end
    rxBit <= reset | _GEN_12; // @[UART.scala 82:{25,25}]
    if (reset) begin // @[UART.scala 83:25]
      spaceCnt <= 4'h0; // @[UART.scala 83:25]
    end else if (baudTick) begin // @[UART.scala 109:18]
      if (state == 2'h0) begin // @[UART.scala 130:28]
        spaceCnt <= 4'h0; // @[UART.scala 131:16]
      end else if (spaceCnt == 4'hf) begin // @[UART.scala 124:29]
        spaceCnt <= 4'h0; // @[UART.scala 126:16]
      end else begin
        spaceCnt <= _spaceCnt_T_1; // @[UART.scala 128:16]
      end
    end
    if (reset) begin // @[UART.scala 84:25]
      data <= 8'h0; // @[UART.scala 84:25]
    end else if (!(2'h0 == state)) begin // @[UART.scala 135:17]
      if (2'h1 == state) begin // @[UART.scala 135:17]
        if (bitTick) begin // @[UART.scala 142:21]
          data <= _data_T_1; // @[UART.scala 143:14]
        end
      end
    end
    if (reset) begin // @[UART.scala 85:25]
      clkCnt <= 6'h0; // @[UART.scala 85:25]
    end else if (clkCnt == 6'h2b) begin // @[UART.scala 99:34]
      clkCnt <= 6'h0; // @[UART.scala 101:12]
    end else begin
      clkCnt <= _clkCnt_T_1; // @[UART.scala 104:12]
    end
    if (reset) begin // @[UART.scala 86:25]
      baudTick <= 1'h0; // @[UART.scala 86:25]
    end else begin
      baudTick <= _T_1;
    end
    if (reset) begin // @[UART.scala 87:25]
      bitTick <= 1'h0; // @[UART.scala 87:25]
    end else begin
      bitTick <= _GEN_13;
    end
    if (reset) begin // @[UART.scala 88:25]
      state <= 2'h0; // @[UART.scala 88:25]
    end else if (2'h0 == state) begin // @[UART.scala 135:17]
      if (baudTick & ~rxBit) begin // @[UART.scala 137:32]
        state <= 2'h1; // @[UART.scala 138:15]
      end
    end else if (2'h1 == state) begin // @[UART.scala 135:17]
      if (bitTick) begin // @[UART.scala 142:21]
        state <= _GEN_17;
      end
    end else if (2'h2 == state) begin // @[UART.scala 135:17]
      state <= _GEN_21;
    end
    if (reset) begin // @[UART.scala 89:25]
      bitCnt <= 3'h0; // @[UART.scala 89:25]
    end else if (!(2'h0 == state)) begin // @[UART.scala 135:17]
      if (2'h1 == state) begin // @[UART.scala 135:17]
        if (bitTick) begin // @[UART.scala 142:21]
          bitCnt <= _GEN_16;
        end
      end
    end
    if (reset) begin // @[UART.scala 90:25]
      validR <= 1'h0; // @[UART.scala 90:25]
    end else if (2'h0 == state) begin // @[UART.scala 135:17]
      validR <= _GEN_0;
    end else if (2'h1 == state) begin // @[UART.scala 135:17]
      validR <= _GEN_0;
    end else if (2'h2 == state) begin // @[UART.scala 135:17]
      validR <= _GEN_22;
    end else begin
      validR <= _GEN_0;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  dataSr = _RAND_0[1:0];
  _RAND_1 = {1{`RANDOM}};
  filter = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  rxBit = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  spaceCnt = _RAND_3[3:0];
  _RAND_4 = {1{`RANDOM}};
  data = _RAND_4[7:0];
  _RAND_5 = {1{`RANDOM}};
  clkCnt = _RAND_5[5:0];
  _RAND_6 = {1{`RANDOM}};
  baudTick = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  bitTick = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  state = _RAND_8[1:0];
  _RAND_9 = {1{`RANDOM}};
  bitCnt = _RAND_9[2:0];
  _RAND_10 = {1{`RANDOM}};
  validR = _RAND_10[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Uart(
  input        clock,
  input        reset,
  input        io_rxd,
  output       io_txd,
  input        io_rxReady,
  output       io_rxValid,
  output [7:0] io_rxByte,
  output       io_txReady,
  input        io_txValid,
  input  [7:0] io_txByte
);
  wire  tx_clock; // @[UART.scala 175:18]
  wire  tx_reset; // @[UART.scala 175:18]
  wire  tx_io_tx; // @[UART.scala 175:18]
  wire  tx_io_ready; // @[UART.scala 175:18]
  wire  tx_io_valid; // @[UART.scala 175:18]
  wire [7:0] tx_io_data; // @[UART.scala 175:18]
  wire  rx_clock; // @[UART.scala 176:18]
  wire  rx_reset; // @[UART.scala 176:18]
  wire  rx_io_rx; // @[UART.scala 176:18]
  wire  rx_io_ready; // @[UART.scala 176:18]
  wire  rx_io_valid; // @[UART.scala 176:18]
  wire [7:0] rx_io_data; // @[UART.scala 176:18]
  Tx tx ( // @[UART.scala 175:18]
    .clock(tx_clock),
    .reset(tx_reset),
    .io_tx(tx_io_tx),
    .io_ready(tx_io_ready),
    .io_valid(tx_io_valid),
    .io_data(tx_io_data)
  );
  Rx rx ( // @[UART.scala 176:18]
    .clock(rx_clock),
    .reset(rx_reset),
    .io_rx(rx_io_rx),
    .io_ready(rx_io_ready),
    .io_valid(rx_io_valid),
    .io_data(rx_io_data)
  );
  assign io_txd = tx_io_tx; // @[UART.scala 178:10]
  assign io_rxValid = rx_io_valid; // @[UART.scala 185:14]
  assign io_rxByte = rx_io_data; // @[UART.scala 186:13]
  assign io_txReady = tx_io_ready; // @[UART.scala 179:14]
  assign tx_clock = clock;
  assign tx_reset = reset;
  assign tx_io_valid = io_txValid; // @[UART.scala 180:15]
  assign tx_io_data = io_txByte; // @[UART.scala 181:14]
  assign rx_clock = clock;
  assign rx_reset = reset;
  assign rx_io_rx = io_rxd; // @[UART.scala 183:12]
  assign rx_io_ready = io_rxReady; // @[UART.scala 184:15]
endmodule
module OffChipCom(
  input        clock,
  input        reset,
  output       io_tx,
  input        io_rx,
  output       io_inC0We,
  output [8:0] io_inC0Addr,
  output [8:0] io_inC0Di,
  output       io_inC1We,
  output [8:0] io_inC1Addr,
  output [8:0] io_inC1Di,
  output       io_qEn,
  input  [7:0] io_qData,
  input        io_qEmpty,
  input        io_inC0HSin,
  output       io_inC0HSout,
  input        io_inC1HSin,
  output       io_inC1HSout
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  wire  uart_clock; // @[OffChipCom.scala 34:20]
  wire  uart_reset; // @[OffChipCom.scala 34:20]
  wire  uart_io_rxd; // @[OffChipCom.scala 34:20]
  wire  uart_io_txd; // @[OffChipCom.scala 34:20]
  wire  uart_io_rxReady; // @[OffChipCom.scala 34:20]
  wire  uart_io_rxValid; // @[OffChipCom.scala 34:20]
  wire [7:0] uart_io_rxByte; // @[OffChipCom.scala 34:20]
  wire  uart_io_txReady; // @[OffChipCom.scala 34:20]
  wire  uart_io_txValid; // @[OffChipCom.scala 34:20]
  wire [7:0] uart_io_txByte; // @[OffChipCom.scala 34:20]
  reg [7:0] txBuf; // @[OffChipCom.scala 35:22]
  reg  txV; // @[OffChipCom.scala 36:20]
  wire  _GEN_0 = uart_io_txReady & txV ? 1'h0 : txV; // @[OffChipCom.scala 36:20 46:32 47:9]
  reg  enReg; // @[OffChipCom.scala 52:22]
  wire  en = ~io_qEmpty & ~txV & ~enReg; // @[OffChipCom.scala 53:28]
  wire [7:0] _GEN_1 = enReg ? io_qData : txBuf; // @[OffChipCom.scala 56:15 57:11 35:22]
  wire  _GEN_2 = enReg | _GEN_0; // @[OffChipCom.scala 56:15 58:9]
  reg [7:0] addr1; // @[OffChipCom.scala 62:22]
  reg [7:0] addr0; // @[OffChipCom.scala 63:22]
  reg [7:0] rate1; // @[OffChipCom.scala 64:22]
  reg [7:0] rate0; // @[OffChipCom.scala 65:22]
  reg  phase; // @[OffChipCom.scala 68:22]
  wire [8:0] _GEN_63 = {{1'd0}, addr0}; // @[OffChipCom.scala 71:42]
  wire [8:0] _defAddr_T_1 = _GEN_63 + 9'h100; // @[OffChipCom.scala 71:42]
  wire [15:0] _defData_T = {rate1,rate0}; // @[OffChipCom.scala 72:25]
  reg [1:0] stateReg; // @[OffChipCom.scala 85:25]
  reg [1:0] byteCnt; // @[OffChipCom.scala 86:25]
  reg [8:0] pixCnt; // @[OffChipCom.scala 87:25]
  wire [1:0] _byteCnt_T_1 = byteCnt + 2'h1; // @[OffChipCom.scala 116:28]
  wire [1:0] _GEN_9 = byteCnt == 2'h3 ? 2'h3 : 2'h2; // @[OffChipCom.scala 118:31 119:20 121:20]
  wire [7:0] _GEN_10 = uart_io_rxValid ? addr0 : addr1; // @[OffChipCom.scala 109:29 110:15 62:22]
  wire [7:0] _GEN_11 = uart_io_rxValid ? rate1 : addr0; // @[OffChipCom.scala 109:29 111:15 63:22]
  wire [7:0] _GEN_12 = uart_io_rxValid ? rate0 : rate1; // @[OffChipCom.scala 109:29 112:15 64:22]
  wire [7:0] _GEN_13 = uart_io_rxValid ? uart_io_rxByte : rate0; // @[OffChipCom.scala 109:29 113:15 65:22]
  wire  _GEN_14 = uart_io_rxValid; // @[OffChipCom.scala 109:29 114:25 40:19]
  wire [1:0] _GEN_15 = uart_io_rxValid ? _byteCnt_T_1 : byteCnt; // @[OffChipCom.scala 109:29 116:17 86:25]
  wire [1:0] _GEN_16 = uart_io_rxValid ? _GEN_9 : stateReg; // @[OffChipCom.scala 109:29 85:25]
  wire  _T_9 = addr1 == 8'h0; // @[OffChipCom.scala 127:18]
  wire  _GEN_18 = addr1 == 8'h0 ? 1'h0 : 1'h1; // @[OffChipCom.scala 127:27 79:16 130:19]
  wire [8:0] _pixCnt_T_1 = pixCnt + 9'h1; // @[OffChipCom.scala 132:24]
  wire [1:0] _GEN_19 = pixCnt == 9'h1e3 ? 2'h0 : 2'h2; // @[OffChipCom.scala 136:40 137:18 140:18]
  wire  _GEN_20 = pixCnt == 9'h1e3 ? ~phase : phase; // @[OffChipCom.scala 136:40 138:15 68:22]
  wire [8:0] _GEN_23 = 2'h3 == stateReg ? _pixCnt_T_1 : pixCnt; // @[OffChipCom.scala 132:14 88:20 87:25]
  wire [1:0] _GEN_24 = 2'h3 == stateReg ? _GEN_19 : stateReg; // @[OffChipCom.scala 88:20 85:25]
  wire  _GEN_25 = 2'h3 == stateReg ? _GEN_20 : phase; // @[OffChipCom.scala 88:20 68:22]
  wire  _GEN_33 = 2'h2 == stateReg ? 1'h0 : 2'h3 == stateReg & _T_9; // @[OffChipCom.scala 74:16 88:20]
  wire  _GEN_34 = 2'h2 == stateReg ? 1'h0 : 2'h3 == stateReg & _GEN_18; // @[OffChipCom.scala 79:16 88:20]
  wire  _GEN_46 = 2'h1 == stateReg ? 1'h0 : 2'h2 == stateReg & _GEN_14; // @[OffChipCom.scala 40:19 88:20]
  wire  _GEN_47 = 2'h1 == stateReg ? 1'h0 : _GEN_33; // @[OffChipCom.scala 74:16 88:20]
  wire  _GEN_48 = 2'h1 == stateReg ? 1'h0 : _GEN_34; // @[OffChipCom.scala 79:16 88:20]
  Uart uart ( // @[OffChipCom.scala 34:20]
    .clock(uart_clock),
    .reset(uart_reset),
    .io_rxd(uart_io_rxd),
    .io_txd(uart_io_txd),
    .io_rxReady(uart_io_rxReady),
    .io_rxValid(uart_io_rxValid),
    .io_rxByte(uart_io_rxByte),
    .io_txReady(uart_io_txReady),
    .io_txValid(uart_io_txValid),
    .io_txByte(uart_io_txByte)
  );
  assign io_tx = uart_io_txd; // @[OffChipCom.scala 43:9]
  assign io_inC0We = 2'h0 == stateReg ? 1'h0 : _GEN_47; // @[OffChipCom.scala 74:16 88:20]
  assign io_inC0Addr = phase ? {{1'd0}, addr0} : _defAddr_T_1; // @[OffChipCom.scala 71:21]
  assign io_inC0Di = _defData_T[8:0]; // @[OffChipCom.scala 72:34]
  assign io_inC1We = 2'h0 == stateReg ? 1'h0 : _GEN_48; // @[OffChipCom.scala 79:16 88:20]
  assign io_inC1Addr = phase ? {{1'd0}, addr0} : _defAddr_T_1; // @[OffChipCom.scala 71:21]
  assign io_inC1Di = _defData_T[8:0]; // @[OffChipCom.scala 72:34]
  assign io_qEn = ~io_qEmpty & ~txV & ~enReg; // @[OffChipCom.scala 53:28]
  assign io_inC0HSout = phase; // @[OffChipCom.scala 73:16]
  assign io_inC1HSout = phase; // @[OffChipCom.scala 78:16]
  assign uart_clock = clock;
  assign uart_reset = reset;
  assign uart_io_rxd = io_rx; // @[OffChipCom.scala 39:15]
  assign uart_io_rxReady = 2'h0 == stateReg ? 1'h0 : _GEN_46; // @[OffChipCom.scala 40:19 88:20]
  assign uart_io_txValid = txV; // @[OffChipCom.scala 44:19]
  assign uart_io_txByte = txBuf; // @[OffChipCom.scala 45:18]
  always @(posedge clock) begin
    if (reset) begin // @[OffChipCom.scala 35:22]
      txBuf <= 8'h0; // @[OffChipCom.scala 35:22]
    end else if (2'h0 == stateReg) begin // @[OffChipCom.scala 88:20]
      txBuf <= _GEN_1;
    end else if (2'h1 == stateReg) begin // @[OffChipCom.scala 88:20]
      if (uart_io_txReady) begin // @[OffChipCom.scala 98:29]
        txBuf <= _GEN_1;
      end else begin
        txBuf <= 8'hff; // @[OffChipCom.scala 103:15]
      end
    end else begin
      txBuf <= _GEN_1;
    end
    if (reset) begin // @[OffChipCom.scala 36:20]
      txV <= 1'h0; // @[OffChipCom.scala 36:20]
    end else if (2'h0 == stateReg) begin // @[OffChipCom.scala 88:20]
      txV <= _GEN_2;
    end else if (2'h1 == stateReg) begin // @[OffChipCom.scala 88:20]
      if (uart_io_txReady) begin // @[OffChipCom.scala 98:29]
        txV <= _GEN_2;
      end else begin
        txV <= 1'h1; // @[OffChipCom.scala 104:13]
      end
    end else begin
      txV <= _GEN_2;
    end
    if (reset) begin // @[OffChipCom.scala 52:22]
      enReg <= 1'h0; // @[OffChipCom.scala 52:22]
    end else begin
      enReg <= en; // @[OffChipCom.scala 54:9]
    end
    if (reset) begin // @[OffChipCom.scala 62:22]
      addr1 <= 8'h0; // @[OffChipCom.scala 62:22]
    end else if (!(2'h0 == stateReg)) begin // @[OffChipCom.scala 88:20]
      if (!(2'h1 == stateReg)) begin // @[OffChipCom.scala 88:20]
        if (2'h2 == stateReg) begin // @[OffChipCom.scala 88:20]
          addr1 <= _GEN_10;
        end
      end
    end
    if (reset) begin // @[OffChipCom.scala 63:22]
      addr0 <= 8'h0; // @[OffChipCom.scala 63:22]
    end else if (!(2'h0 == stateReg)) begin // @[OffChipCom.scala 88:20]
      if (!(2'h1 == stateReg)) begin // @[OffChipCom.scala 88:20]
        if (2'h2 == stateReg) begin // @[OffChipCom.scala 88:20]
          addr0 <= _GEN_11;
        end
      end
    end
    if (reset) begin // @[OffChipCom.scala 64:22]
      rate1 <= 8'h0; // @[OffChipCom.scala 64:22]
    end else if (!(2'h0 == stateReg)) begin // @[OffChipCom.scala 88:20]
      if (!(2'h1 == stateReg)) begin // @[OffChipCom.scala 88:20]
        if (2'h2 == stateReg) begin // @[OffChipCom.scala 88:20]
          rate1 <= _GEN_12;
        end
      end
    end
    if (reset) begin // @[OffChipCom.scala 65:22]
      rate0 <= 8'h0; // @[OffChipCom.scala 65:22]
    end else if (!(2'h0 == stateReg)) begin // @[OffChipCom.scala 88:20]
      if (!(2'h1 == stateReg)) begin // @[OffChipCom.scala 88:20]
        if (2'h2 == stateReg) begin // @[OffChipCom.scala 88:20]
          rate0 <= _GEN_13;
        end
      end
    end
    if (reset) begin // @[OffChipCom.scala 68:22]
      phase <= 1'h0; // @[OffChipCom.scala 68:22]
    end else if (!(2'h0 == stateReg)) begin // @[OffChipCom.scala 88:20]
      if (!(2'h1 == stateReg)) begin // @[OffChipCom.scala 88:20]
        if (!(2'h2 == stateReg)) begin // @[OffChipCom.scala 88:20]
          phase <= _GEN_25;
        end
      end
    end
    if (reset) begin // @[OffChipCom.scala 85:25]
      stateReg <= 2'h0; // @[OffChipCom.scala 85:25]
    end else if (2'h0 == stateReg) begin // @[OffChipCom.scala 88:20]
      if (phase == io_inC0HSin & io_inC0HSin == io_inC1HSin) begin // @[OffChipCom.scala 91:66]
        stateReg <= 2'h1; // @[OffChipCom.scala 92:18]
      end
    end else if (2'h1 == stateReg) begin // @[OffChipCom.scala 88:20]
      if (uart_io_txReady) begin // @[OffChipCom.scala 98:29]
        stateReg <= 2'h2; // @[OffChipCom.scala 99:18]
      end
    end else if (2'h2 == stateReg) begin // @[OffChipCom.scala 88:20]
      stateReg <= _GEN_16;
    end else begin
      stateReg <= _GEN_24;
    end
    if (reset) begin // @[OffChipCom.scala 86:25]
      byteCnt <= 2'h0; // @[OffChipCom.scala 86:25]
    end else if (!(2'h0 == stateReg)) begin // @[OffChipCom.scala 88:20]
      if (2'h1 == stateReg) begin // @[OffChipCom.scala 88:20]
        if (!(uart_io_txReady)) begin // @[OffChipCom.scala 98:29]
          byteCnt <= 2'h0; // @[OffChipCom.scala 102:17]
        end
      end else if (2'h2 == stateReg) begin // @[OffChipCom.scala 88:20]
        byteCnt <= _GEN_15;
      end
    end
    if (reset) begin // @[OffChipCom.scala 87:25]
      pixCnt <= 9'h0; // @[OffChipCom.scala 87:25]
    end else if (!(2'h0 == stateReg)) begin // @[OffChipCom.scala 88:20]
      if (2'h1 == stateReg) begin // @[OffChipCom.scala 88:20]
        if (!(uart_io_txReady)) begin // @[OffChipCom.scala 98:29]
          pixCnt <= 9'h0; // @[OffChipCom.scala 101:16]
        end
      end else if (!(2'h2 == stateReg)) begin // @[OffChipCom.scala 88:20]
        pixCnt <= _GEN_23;
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  txBuf = _RAND_0[7:0];
  _RAND_1 = {1{`RANDOM}};
  txV = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  enReg = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  addr1 = _RAND_3[7:0];
  _RAND_4 = {1{`RANDOM}};
  addr0 = _RAND_4[7:0];
  _RAND_5 = {1{`RANDOM}};
  rate1 = _RAND_5[7:0];
  _RAND_6 = {1{`RANDOM}};
  rate0 = _RAND_6[7:0];
  _RAND_7 = {1{`RANDOM}};
  phase = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  stateReg = _RAND_8[1:0];
  _RAND_9 = {1{`RANDOM}};
  byteCnt = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  pixCnt = _RAND_10[8:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module BusArbiter(
  input   clock,
  input   reset,
  input   io_reqs_0,
  input   io_reqs_1,
  input   io_reqs_2,
  input   io_reqs_3,
  input   io_reqs_4,
  output  io_grants_0,
  output  io_grants_1,
  output  io_grants_2,
  output  io_grants_3,
  output  io_grants_4
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
`endif // RANDOMIZE_REG_INIT
  reg  maskRegs_0; // @[BusArbiter.scala 14:27]
  reg  maskRegs_1; // @[BusArbiter.scala 14:27]
  reg  maskRegs_2; // @[BusArbiter.scala 14:27]
  reg  maskRegs_3; // @[BusArbiter.scala 14:27]
  reg  maskRegs_4; // @[BusArbiter.scala 14:27]
  reg  grantRegs_0; // @[BusArbiter.scala 16:27]
  reg  grantRegs_1; // @[BusArbiter.scala 16:27]
  reg  grantRegs_2; // @[BusArbiter.scala 16:27]
  reg  grantRegs_3; // @[BusArbiter.scala 16:27]
  reg  grantRegs_4; // @[BusArbiter.scala 16:27]
  wire  maskedReqs_0 = maskRegs_0 & io_reqs_0; // @[BusArbiter.scala 31:34]
  wire  maskedReqs_4 = maskRegs_4 & io_reqs_4; // @[BusArbiter.scala 31:34]
  wire  maskedReqs_3 = maskRegs_3 & io_reqs_3; // @[BusArbiter.scala 31:34]
  wire  maskedReqs_2 = maskRegs_2 & io_reqs_2; // @[BusArbiter.scala 31:34]
  wire  maskedReqs_1 = maskRegs_1 & io_reqs_1; // @[BusArbiter.scala 31:34]
  wire [1:0] _GEN_5 = maskedReqs_2 ? 2'h2 : {{1'd0}, maskedReqs_1}; // @[BusArbiter.scala 34:25 36:14]
  wire [1:0] _GEN_7 = maskedReqs_3 ? 2'h3 : _GEN_5; // @[BusArbiter.scala 34:25 36:14]
  wire [2:0] value = maskedReqs_4 ? 3'h4 : {{1'd0}, _GEN_7}; // @[BusArbiter.scala 34:25 36:14]
  wire  oneReq = maskedReqs_4 | (maskedReqs_3 | (maskedReqs_2 | (maskedReqs_1 | maskedReqs_0))); // @[BusArbiter.scala 34:25 35:14]
  wire  grants_0 = 3'h0 == value & oneReq; // @[BusArbiter.scala 40:33]
  wire  grants_1 = 3'h1 == value & oneReq; // @[BusArbiter.scala 40:33]
  wire  grants_2 = 3'h2 == value & oneReq; // @[BusArbiter.scala 40:33]
  wire  grants_3 = 3'h3 == value & oneReq; // @[BusArbiter.scala 40:33]
  wire  grants_4 = 3'h4 == value & oneReq; // @[BusArbiter.scala 40:33]
  wire  mask_4 = value == 3'h0; // @[BusArbiter.scala 47:26]
  wire  mask_3 = mask_4 | maskedReqs_4; // @[BusArbiter.scala 45:28]
  wire  mask_2 = mask_3 | maskedReqs_3; // @[BusArbiter.scala 45:28]
  wire  mask_1 = mask_2 | maskedReqs_2; // @[BusArbiter.scala 45:28]
  wire  mask_0 = mask_1 | maskedReqs_1; // @[BusArbiter.scala 45:28]
  assign io_grants_0 = grantRegs_0; // @[BusArbiter.scala 49:13]
  assign io_grants_1 = grantRegs_1; // @[BusArbiter.scala 49:13]
  assign io_grants_2 = grantRegs_2; // @[BusArbiter.scala 49:13]
  assign io_grants_3 = grantRegs_3; // @[BusArbiter.scala 49:13]
  assign io_grants_4 = grantRegs_4; // @[BusArbiter.scala 49:13]
  always @(posedge clock) begin
    maskRegs_0 <= reset | mask_0; // @[BusArbiter.scala 14:{27,27} 27:18]
    maskRegs_1 <= reset | mask_1; // @[BusArbiter.scala 14:{27,27} 27:18]
    maskRegs_2 <= reset | mask_2; // @[BusArbiter.scala 14:{27,27} 27:18]
    maskRegs_3 <= reset | mask_3; // @[BusArbiter.scala 14:{27,27} 27:18]
    maskRegs_4 <= reset | mask_4; // @[BusArbiter.scala 14:{27,27} 27:18]
    if (reset) begin // @[BusArbiter.scala 16:27]
      grantRegs_0 <= 1'h0; // @[BusArbiter.scala 16:27]
    end else begin
      grantRegs_0 <= grants_0; // @[BusArbiter.scala 28:18]
    end
    if (reset) begin // @[BusArbiter.scala 16:27]
      grantRegs_1 <= 1'h0; // @[BusArbiter.scala 16:27]
    end else begin
      grantRegs_1 <= grants_1; // @[BusArbiter.scala 28:18]
    end
    if (reset) begin // @[BusArbiter.scala 16:27]
      grantRegs_2 <= 1'h0; // @[BusArbiter.scala 16:27]
    end else begin
      grantRegs_2 <= grants_2; // @[BusArbiter.scala 28:18]
    end
    if (reset) begin // @[BusArbiter.scala 16:27]
      grantRegs_3 <= 1'h0; // @[BusArbiter.scala 16:27]
    end else begin
      grantRegs_3 <= grants_3; // @[BusArbiter.scala 28:18]
    end
    if (reset) begin // @[BusArbiter.scala 16:27]
      grantRegs_4 <= 1'h0; // @[BusArbiter.scala 16:27]
    end else begin
      grantRegs_4 <= grants_4; // @[BusArbiter.scala 28:18]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  maskRegs_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  maskRegs_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  maskRegs_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  maskRegs_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  maskRegs_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  grantRegs_0 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  grantRegs_1 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  grantRegs_2 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  grantRegs_3 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  grantRegs_4 = _RAND_9[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module BusInterface(
  input         io_grant,
  output        io_reqOut,
  output [10:0] io_tx,
  input  [10:0] io_spikeID,
  output        io_ready,
  input         io_reqIn
);
  assign io_reqOut = io_reqIn & ~io_grant; // @[BusInterface.scala 32:25]
  assign io_tx = io_grant ? io_spikeID : 11'h0; // @[BusInterface.scala 31:15]
  assign io_ready = io_grant; // @[BusInterface.scala 33:13]
endmodule
module PriorityMaskRstEncoder(
  input        io_reqs_0,
  input        io_reqs_1,
  input        io_reqs_2,
  input        io_reqs_3,
  input        io_reqs_4,
  input        io_reqs_5,
  input        io_reqs_6,
  input        io_reqs_7,
  output [2:0] io_value,
  output       io_mask_0,
  output       io_mask_1,
  output       io_mask_2,
  output       io_mask_3,
  output       io_mask_4,
  output       io_mask_5,
  output       io_mask_6,
  output       io_mask_7,
  output       io_rst_0,
  output       io_rst_1,
  output       io_rst_2,
  output       io_rst_3,
  output       io_rst_4,
  output       io_rst_5,
  output       io_rst_6,
  output       io_rst_7,
  output       io_valid
);
  wire [1:0] _GEN_5 = io_reqs_2 ? 2'h2 : {{1'd0}, io_reqs_1}; // @[PriorityMaskRstEncoder.scala 21:22 23:16]
  wire [1:0] _GEN_7 = io_reqs_3 ? 2'h3 : _GEN_5; // @[PriorityMaskRstEncoder.scala 21:22 23:16]
  wire [2:0] _GEN_9 = io_reqs_4 ? 3'h4 : {{1'd0}, _GEN_7}; // @[PriorityMaskRstEncoder.scala 21:22 23:16]
  wire [2:0] _GEN_11 = io_reqs_5 ? 3'h5 : _GEN_9; // @[PriorityMaskRstEncoder.scala 21:22 23:16]
  wire [2:0] _GEN_13 = io_reqs_6 ? 3'h6 : _GEN_11; // @[PriorityMaskRstEncoder.scala 21:22 23:16]
  assign io_value = io_reqs_7 ? 3'h7 : _GEN_13; // @[PriorityMaskRstEncoder.scala 21:22 23:16]
  assign io_mask_0 = io_mask_1 | io_reqs_1; // @[PriorityMaskRstEncoder.scala 29:34]
  assign io_mask_1 = io_mask_2 | io_reqs_2; // @[PriorityMaskRstEncoder.scala 29:34]
  assign io_mask_2 = io_mask_3 | io_reqs_3; // @[PriorityMaskRstEncoder.scala 29:34]
  assign io_mask_3 = io_mask_4 | io_reqs_4; // @[PriorityMaskRstEncoder.scala 29:34]
  assign io_mask_4 = io_mask_5 | io_reqs_5; // @[PriorityMaskRstEncoder.scala 29:34]
  assign io_mask_5 = io_mask_6 | io_reqs_6; // @[PriorityMaskRstEncoder.scala 29:34]
  assign io_mask_6 = io_mask_7 | io_reqs_7; // @[PriorityMaskRstEncoder.scala 29:34]
  assign io_mask_7 = io_value == 3'h0; // @[PriorityMaskRstEncoder.scala 30:38]
  assign io_rst_0 = 3'h0 == io_value & io_valid; // @[PriorityMaskRstEncoder.scala 34:35]
  assign io_rst_1 = 3'h1 == io_value & io_valid; // @[PriorityMaskRstEncoder.scala 34:35]
  assign io_rst_2 = 3'h2 == io_value & io_valid; // @[PriorityMaskRstEncoder.scala 34:35]
  assign io_rst_3 = 3'h3 == io_value & io_valid; // @[PriorityMaskRstEncoder.scala 34:35]
  assign io_rst_4 = 3'h4 == io_value & io_valid; // @[PriorityMaskRstEncoder.scala 34:35]
  assign io_rst_5 = 3'h5 == io_value & io_valid; // @[PriorityMaskRstEncoder.scala 34:35]
  assign io_rst_6 = 3'h6 == io_value & io_valid; // @[PriorityMaskRstEncoder.scala 34:35]
  assign io_rst_7 = 3'h7 == io_value & io_valid; // @[PriorityMaskRstEncoder.scala 34:35]
  assign io_valid = io_reqs_7 | (io_reqs_6 | (io_reqs_5 | (io_reqs_4 | (io_reqs_3 | (io_reqs_2 | (io_reqs_1 | io_reqs_0)
    ))))); // @[PriorityMaskRstEncoder.scala 21:22 22:16]
endmodule
module TransmissionSystem(
  input         clock,
  input         reset,
  output [10:0] io_data,
  input         io_ready,
  output        io_valid,
  input  [4:0]  io_n,
  input         io_spikes_0,
  input         io_spikes_1,
  input         io_spikes_2,
  input         io_spikes_3,
  input         io_spikes_4,
  input         io_spikes_5,
  input         io_spikes_6,
  input         io_spikes_7
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
`endif // RANDOMIZE_REG_INIT
  wire  spikeEncoder_io_reqs_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_7; // @[TransmissionSystem.scala 22:28]
  wire [2:0] spikeEncoder_io_value; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_7; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_7; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_valid; // @[TransmissionSystem.scala 22:28]
  reg  spikeRegs_0; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_1; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_2; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_3; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_4; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_5; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_6; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_7; // @[TransmissionSystem.scala 18:29]
  reg [4:0] neuronIdMSB_0; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_1; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_2; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_3; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_4; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_5; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_6; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_7; // @[TransmissionSystem.scala 19:29]
  reg  maskRegs_0; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_1; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_2; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_3; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_4; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_5; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_6; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_7; // @[TransmissionSystem.scala 20:29]
  wire  rstReadySel_0 = ~(spikeEncoder_io_rst_0 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_0 = rstReadySel_0 & spikeRegs_0; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_0 = ~spikeEncoder_io_valid | maskRegs_0; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_1 = io_ready ? spikeEncoder_io_mask_0 : _GEN_0; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_1 = {3'h0,neuronIdMSB_0,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_4 = 3'h0 == spikeEncoder_io_value ? _io_data_T_1 : 11'h0; // @[TransmissionSystem.scala 28:12 49:41 50:15]
  wire  rstReadySel_1 = ~(spikeEncoder_io_rst_1 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_1 = rstReadySel_1 & spikeRegs_1; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_5 = ~spikeEncoder_io_valid | maskRegs_1; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_6 = io_ready ? spikeEncoder_io_mask_1 : _GEN_5; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_3 = {3'h0,neuronIdMSB_1,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_9 = 3'h1 == spikeEncoder_io_value ? _io_data_T_3 : _GEN_4; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_2 = ~(spikeEncoder_io_rst_2 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_2 = rstReadySel_2 & spikeRegs_2; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_10 = ~spikeEncoder_io_valid | maskRegs_2; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_11 = io_ready ? spikeEncoder_io_mask_2 : _GEN_10; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_5 = {3'h0,neuronIdMSB_2,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_14 = 3'h2 == spikeEncoder_io_value ? _io_data_T_5 : _GEN_9; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_3 = ~(spikeEncoder_io_rst_3 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_3 = rstReadySel_3 & spikeRegs_3; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_15 = ~spikeEncoder_io_valid | maskRegs_3; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_16 = io_ready ? spikeEncoder_io_mask_3 : _GEN_15; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_7 = {3'h0,neuronIdMSB_3,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_19 = 3'h3 == spikeEncoder_io_value ? _io_data_T_7 : _GEN_14; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_4 = ~(spikeEncoder_io_rst_4 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_4 = rstReadySel_4 & spikeRegs_4; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_20 = ~spikeEncoder_io_valid | maskRegs_4; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_21 = io_ready ? spikeEncoder_io_mask_4 : _GEN_20; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_9 = {3'h0,neuronIdMSB_4,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_24 = 3'h4 == spikeEncoder_io_value ? _io_data_T_9 : _GEN_19; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_5 = ~(spikeEncoder_io_rst_5 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_5 = rstReadySel_5 & spikeRegs_5; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_25 = ~spikeEncoder_io_valid | maskRegs_5; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_26 = io_ready ? spikeEncoder_io_mask_5 : _GEN_25; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_11 = {3'h0,neuronIdMSB_5,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_29 = 3'h5 == spikeEncoder_io_value ? _io_data_T_11 : _GEN_24; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_6 = ~(spikeEncoder_io_rst_6 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_6 = rstReadySel_6 & spikeRegs_6; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_30 = ~spikeEncoder_io_valid | maskRegs_6; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_31 = io_ready ? spikeEncoder_io_mask_6 : _GEN_30; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_13 = {3'h0,neuronIdMSB_6,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_34 = 3'h6 == spikeEncoder_io_value ? _io_data_T_13 : _GEN_29; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_7 = ~(spikeEncoder_io_rst_7 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_7 = rstReadySel_7 & spikeRegs_7; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_35 = ~spikeEncoder_io_valid | maskRegs_7; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_36 = io_ready ? spikeEncoder_io_mask_7 : _GEN_35; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_15 = {3'h0,neuronIdMSB_7,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  PriorityMaskRstEncoder spikeEncoder ( // @[TransmissionSystem.scala 22:28]
    .io_reqs_0(spikeEncoder_io_reqs_0),
    .io_reqs_1(spikeEncoder_io_reqs_1),
    .io_reqs_2(spikeEncoder_io_reqs_2),
    .io_reqs_3(spikeEncoder_io_reqs_3),
    .io_reqs_4(spikeEncoder_io_reqs_4),
    .io_reqs_5(spikeEncoder_io_reqs_5),
    .io_reqs_6(spikeEncoder_io_reqs_6),
    .io_reqs_7(spikeEncoder_io_reqs_7),
    .io_value(spikeEncoder_io_value),
    .io_mask_0(spikeEncoder_io_mask_0),
    .io_mask_1(spikeEncoder_io_mask_1),
    .io_mask_2(spikeEncoder_io_mask_2),
    .io_mask_3(spikeEncoder_io_mask_3),
    .io_mask_4(spikeEncoder_io_mask_4),
    .io_mask_5(spikeEncoder_io_mask_5),
    .io_mask_6(spikeEncoder_io_mask_6),
    .io_mask_7(spikeEncoder_io_mask_7),
    .io_rst_0(spikeEncoder_io_rst_0),
    .io_rst_1(spikeEncoder_io_rst_1),
    .io_rst_2(spikeEncoder_io_rst_2),
    .io_rst_3(spikeEncoder_io_rst_3),
    .io_rst_4(spikeEncoder_io_rst_4),
    .io_rst_5(spikeEncoder_io_rst_5),
    .io_rst_6(spikeEncoder_io_rst_6),
    .io_rst_7(spikeEncoder_io_rst_7),
    .io_valid(spikeEncoder_io_valid)
  );
  assign io_data = 3'h7 == spikeEncoder_io_value ? _io_data_T_15 : _GEN_34; // @[TransmissionSystem.scala 49:41 50:15]
  assign io_valid = spikeEncoder_io_valid; // @[TransmissionSystem.scala 29:12]
  assign spikeEncoder_io_reqs_0 = maskRegs_0 & spikeRegs_0; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_1 = maskRegs_1 & spikeRegs_1; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_2 = maskRegs_2 & spikeRegs_2; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_3 = maskRegs_3 & spikeRegs_3; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_4 = maskRegs_4 & spikeRegs_4; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_5 = maskRegs_5 & spikeRegs_5; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_6 = maskRegs_6 & spikeRegs_6; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_7 = maskRegs_7 & spikeRegs_7; // @[TransmissionSystem.scala 33:35]
  always @(posedge clock) begin
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_0 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_0) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_0 <= io_spikes_0; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_1 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_1) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_1 <= io_spikes_1; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_2 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_2) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_2 <= io_spikes_2; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_3 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_3) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_3 <= io_spikes_3; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_4 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_4) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_4 <= io_spikes_4; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_5 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_5) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_5 <= io_spikes_5; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_6 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_6) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_6 <= io_spikes_6; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_7 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_7) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_7 <= io_spikes_7; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_0 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_0) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_0 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_1 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_1) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_1 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_2 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_2) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_2 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_3 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_3) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_3 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_4 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_4) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_4 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_5 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_5) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_5 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_6 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_6) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_6 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_7 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_7) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_7 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    maskRegs_0 <= reset | _GEN_1; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_1 <= reset | _GEN_6; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_2 <= reset | _GEN_11; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_3 <= reset | _GEN_16; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_4 <= reset | _GEN_21; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_5 <= reset | _GEN_26; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_6 <= reset | _GEN_31; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_7 <= reset | _GEN_36; // @[TransmissionSystem.scala 20:{29,29}]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  spikeRegs_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  spikeRegs_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  spikeRegs_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  spikeRegs_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  spikeRegs_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  spikeRegs_5 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  spikeRegs_6 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  spikeRegs_7 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  neuronIdMSB_0 = _RAND_8[4:0];
  _RAND_9 = {1{`RANDOM}};
  neuronIdMSB_1 = _RAND_9[4:0];
  _RAND_10 = {1{`RANDOM}};
  neuronIdMSB_2 = _RAND_10[4:0];
  _RAND_11 = {1{`RANDOM}};
  neuronIdMSB_3 = _RAND_11[4:0];
  _RAND_12 = {1{`RANDOM}};
  neuronIdMSB_4 = _RAND_12[4:0];
  _RAND_13 = {1{`RANDOM}};
  neuronIdMSB_5 = _RAND_13[4:0];
  _RAND_14 = {1{`RANDOM}};
  neuronIdMSB_6 = _RAND_14[4:0];
  _RAND_15 = {1{`RANDOM}};
  neuronIdMSB_7 = _RAND_15[4:0];
  _RAND_16 = {1{`RANDOM}};
  maskRegs_0 = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  maskRegs_1 = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  maskRegs_2 = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  maskRegs_3 = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  maskRegs_4 = _RAND_20[0:0];
  _RAND_21 = {1{`RANDOM}};
  maskRegs_5 = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  maskRegs_6 = _RAND_22[0:0];
  _RAND_23 = {1{`RANDOM}};
  maskRegs_7 = _RAND_23[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module InputCore(
  input         clock,
  input         reset,
  output        io_pmClkEn,
  input         io_newTS,
  input         io_offCCHSin,
  output        io_offCCHSout,
  output        io_memEn,
  output [8:0]  io_memAddr,
  input  [8:0]  io_memDo,
  input         io_grant,
  output        io_req,
  output [10:0] io_tx
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
`endif // RANDOMIZE_REG_INIT
  wire  interface__io_grant; // @[InputCore.scala 33:25]
  wire  interface__io_reqOut; // @[InputCore.scala 33:25]
  wire [10:0] interface__io_tx; // @[InputCore.scala 33:25]
  wire [10:0] interface__io_spikeID; // @[InputCore.scala 33:25]
  wire  interface__io_ready; // @[InputCore.scala 33:25]
  wire  interface__io_reqIn; // @[InputCore.scala 33:25]
  wire  spikeTrans_clock; // @[InputCore.scala 40:26]
  wire  spikeTrans_reset; // @[InputCore.scala 40:26]
  wire [10:0] spikeTrans_io_data; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_ready; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_valid; // @[InputCore.scala 40:26]
  wire [4:0] spikeTrans_io_n; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_0; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_1; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_2; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_3; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_4; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_5; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_6; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_7; // @[InputCore.scala 40:26]
  reg [2:0] state; // @[InputCore.scala 47:23]
  reg [8:0] ts; // @[InputCore.scala 48:23]
  reg [7:0] pixCnt; // @[InputCore.scala 49:23]
  reg [7:0] pixCntLate; // @[InputCore.scala 50:28]
  reg [7:0] pixCntLater; // @[InputCore.scala 51:28]
  reg  spikePulse_0; // @[InputCore.scala 54:29]
  reg  spikePulse_1; // @[InputCore.scala 54:29]
  reg  spikePulse_2; // @[InputCore.scala 54:29]
  reg  spikePulse_3; // @[InputCore.scala 54:29]
  reg  spikePulse_4; // @[InputCore.scala 54:29]
  reg  spikePulse_5; // @[InputCore.scala 54:29]
  reg  spikePulse_6; // @[InputCore.scala 54:29]
  reg  spikePulse_7; // @[InputCore.scala 54:29]
  reg  phase; // @[InputCore.scala 57:22]
  wire [8:0] _shouldSpike_res_T_3 = ts % io_memDo; // @[InputCore.scala 62:59]
  wire [8:0] shouldSpike_res = ts == 9'h0 | io_memDo == 9'h0 ? 9'h1 : _shouldSpike_res_T_3; // @[InputCore.scala 62:18]
  wire  shouldSpike = shouldSpike_res == 9'h0; // @[InputCore.scala 63:9]
  wire [8:0] _GEN_43 = {{1'd0}, pixCnt}; // @[InputCore.scala 76:35]
  wire [8:0] _io_memAddr_T_1 = _GEN_43 + 9'h100; // @[InputCore.scala 76:35]
  wire  _T_2 = io_offCCHSin != phase & io_newTS; // @[InputCore.scala 84:35]
  wire [7:0] _pixCnt_T_1 = pixCnt + 8'h1; // @[InputCore.scala 94:24]
  wire [3:0] _sPulseDecSig_T_1 = {1'h0,pixCntLate[2:0]}; // @[InputCore.scala 105:34]
  wire [3:0] _GEN_3 = shouldSpike ? _sPulseDecSig_T_1 : 4'h8; // @[InputCore.scala 104:25 105:22]
  wire [2:0] _GEN_4 = pixCnt == 8'hff ? 3'h3 : state; // @[InputCore.scala 108:43 109:15 47:23]
  wire [8:0] _ts_T_1 = ts + 9'h1; // @[InputCore.scala 115:16]
  wire  _GEN_6 = ~interface__io_reqOut & ~io_newTS ? 1'h0 : 1'h1; // @[InputCore.scala 126:47 127:20 74:14]
  wire [2:0] _GEN_7 = ts == 9'h1f3 ? 3'h0 : 3'h1; // @[InputCore.scala 132:28 133:17 135:17]
  wire  _GEN_8 = io_newTS | _GEN_6; // @[InputCore.scala 130:22 131:20]
  wire [2:0] _GEN_9 = io_newTS ? _GEN_7 : state; // @[InputCore.scala 130:22 47:23]
  wire  _GEN_10 = 3'h4 == state ? _GEN_8 : 1'h1; // @[InputCore.scala 74:14 77:17]
  wire [2:0] _GEN_11 = 3'h4 == state ? _GEN_9 : state; // @[InputCore.scala 77:17 47:23]
  wire [8:0] _GEN_12 = 3'h3 == state ? _ts_T_1 : ts; // @[InputCore.scala 115:10 77:17 48:23]
  wire [3:0] _GEN_13 = 3'h3 == state ? _GEN_3 : 4'h8; // @[InputCore.scala 77:17]
  wire [2:0] _GEN_14 = 3'h3 == state ? 3'h4 : _GEN_11; // @[InputCore.scala 120:13 77:17]
  wire [3:0] _GEN_18 = 3'h2 == state ? _GEN_3 : _GEN_13; // @[InputCore.scala 77:17]
  wire  _GEN_22 = 3'h1 == state | 3'h2 == state; // @[InputCore.scala 77:17 93:16]
  wire [3:0] _GEN_25 = 3'h1 == state ? 4'h8 : _GEN_18; // @[InputCore.scala 77:17]
  wire  _GEN_27 = 3'h1 == state | (3'h2 == state | (3'h3 == state | _GEN_10)); // @[InputCore.scala 74:14 77:17]
  wire [3:0] sPulseDecSig = 3'h0 == state ? 4'h8 : _GEN_25; // @[InputCore.scala 77:17]
  wire  _T_12 = sPulseDecSig == 4'h0; // @[InputCore.scala 144:24]
  wire  _T_13 = sPulseDecSig == 4'h1; // @[InputCore.scala 144:24]
  wire  _T_14 = sPulseDecSig == 4'h2; // @[InputCore.scala 144:24]
  wire  _T_15 = sPulseDecSig == 4'h3; // @[InputCore.scala 144:24]
  wire  _T_16 = sPulseDecSig == 4'h4; // @[InputCore.scala 144:24]
  wire  _T_17 = sPulseDecSig == 4'h5; // @[InputCore.scala 144:24]
  wire  _T_18 = sPulseDecSig == 4'h6; // @[InputCore.scala 144:24]
  wire  _T_19 = sPulseDecSig == 4'h7; // @[InputCore.scala 144:24]
  BusInterface interface_ ( // @[InputCore.scala 33:25]
    .io_grant(interface__io_grant),
    .io_reqOut(interface__io_reqOut),
    .io_tx(interface__io_tx),
    .io_spikeID(interface__io_spikeID),
    .io_ready(interface__io_ready),
    .io_reqIn(interface__io_reqIn)
  );
  TransmissionSystem spikeTrans ( // @[InputCore.scala 40:26]
    .clock(spikeTrans_clock),
    .reset(spikeTrans_reset),
    .io_data(spikeTrans_io_data),
    .io_ready(spikeTrans_io_ready),
    .io_valid(spikeTrans_io_valid),
    .io_n(spikeTrans_io_n),
    .io_spikes_0(spikeTrans_io_spikes_0),
    .io_spikes_1(spikeTrans_io_spikes_1),
    .io_spikes_2(spikeTrans_io_spikes_2),
    .io_spikes_3(spikeTrans_io_spikes_3),
    .io_spikes_4(spikeTrans_io_spikes_4),
    .io_spikes_5(spikeTrans_io_spikes_5),
    .io_spikes_6(spikeTrans_io_spikes_6),
    .io_spikes_7(spikeTrans_io_spikes_7)
  );
  assign io_pmClkEn = 3'h0 == state ? _T_2 : _GEN_27; // @[InputCore.scala 77:17]
  assign io_offCCHSout = phase; // @[InputCore.scala 58:17]
  assign io_memEn = 3'h0 == state ? 1'h0 : _GEN_22; // @[InputCore.scala 75:14 77:17]
  assign io_memAddr = phase ? _io_memAddr_T_1 : {{1'd0}, pixCnt}; // @[InputCore.scala 76:20]
  assign io_req = interface__io_reqOut; // @[InputCore.scala 35:22]
  assign io_tx = interface__io_tx; // @[InputCore.scala 36:22]
  assign interface__io_grant = io_grant; // @[InputCore.scala 34:22]
  assign interface__io_spikeID = spikeTrans_io_data; // @[InputCore.scala 41:27]
  assign interface__io_reqIn = spikeTrans_io_valid; // @[InputCore.scala 43:27]
  assign spikeTrans_clock = clock;
  assign spikeTrans_reset = reset;
  assign spikeTrans_io_ready = interface__io_ready; // @[InputCore.scala 42:27]
  assign spikeTrans_io_n = pixCntLater[7:3]; // @[InputCore.scala 150:33]
  assign spikeTrans_io_spikes_0 = spikePulse_0; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_1 = spikePulse_1; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_2 = spikePulse_2; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_3 = spikePulse_3; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_4 = spikePulse_4; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_5 = spikePulse_5; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_6 = spikePulse_6; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_7 = spikePulse_7; // @[InputCore.scala 152:29]
  always @(posedge clock) begin
    if (reset) begin // @[InputCore.scala 47:23]
      state <= 3'h0; // @[InputCore.scala 47:23]
    end else if (3'h0 == state) begin // @[InputCore.scala 77:17]
      if (io_offCCHSin != phase & io_newTS) begin // @[InputCore.scala 84:48]
        state <= 3'h1; // @[InputCore.scala 86:15]
      end
    end else if (3'h1 == state) begin // @[InputCore.scala 77:17]
      state <= 3'h2; // @[InputCore.scala 96:13]
    end else if (3'h2 == state) begin // @[InputCore.scala 77:17]
      state <= _GEN_4;
    end else begin
      state <= _GEN_14;
    end
    if (reset) begin // @[InputCore.scala 48:23]
      ts <= 9'h0; // @[InputCore.scala 48:23]
    end else if (3'h0 == state) begin // @[InputCore.scala 77:17]
      ts <= 9'h0; // @[InputCore.scala 81:10]
    end else if (!(3'h1 == state)) begin // @[InputCore.scala 77:17]
      if (!(3'h2 == state)) begin // @[InputCore.scala 77:17]
        ts <= _GEN_12;
      end
    end
    if (reset) begin // @[InputCore.scala 49:23]
      pixCnt <= 8'h0; // @[InputCore.scala 49:23]
    end else if (3'h0 == state) begin // @[InputCore.scala 77:17]
      pixCnt <= 8'h0; // @[InputCore.scala 82:14]
    end else if (3'h1 == state) begin // @[InputCore.scala 77:17]
      pixCnt <= _pixCnt_T_1; // @[InputCore.scala 94:14]
    end else if (3'h2 == state) begin // @[InputCore.scala 77:17]
      pixCnt <= _pixCnt_T_1; // @[InputCore.scala 103:14]
    end
    pixCntLate <= pixCnt; // @[InputCore.scala 50:28]
    pixCntLater <= pixCntLate; // @[InputCore.scala 51:28]
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_0 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_0 <= _T_12;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_1 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_1 <= _T_13;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_2 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_2 <= _T_14;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_3 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_3 <= _T_15;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_4 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_4 <= _T_16;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_5 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_5 <= _T_17;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_6 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_6 <= _T_18;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_7 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_7 <= _T_19;
    end
    if (reset) begin // @[InputCore.scala 57:22]
      phase <= 1'h0; // @[InputCore.scala 57:22]
    end else if (3'h0 == state) begin // @[InputCore.scala 77:17]
      if (io_offCCHSin != phase & io_newTS) begin // @[InputCore.scala 84:48]
        phase <= ~phase; // @[InputCore.scala 87:15]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  ts = _RAND_1[8:0];
  _RAND_2 = {1{`RANDOM}};
  pixCnt = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  pixCntLate = _RAND_3[7:0];
  _RAND_4 = {1{`RANDOM}};
  pixCntLater = _RAND_4[7:0];
  _RAND_5 = {1{`RANDOM}};
  spikePulse_0 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  spikePulse_1 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  spikePulse_2 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  spikePulse_3 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  spikePulse_4 = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  spikePulse_5 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  spikePulse_6 = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  spikePulse_7 = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  phase = _RAND_13[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module TransmissionSystem_1(
  input         clock,
  input         reset,
  output [10:0] io_data,
  input         io_ready,
  output        io_valid,
  input  [4:0]  io_n,
  input         io_spikes_0,
  input         io_spikes_1,
  input         io_spikes_2,
  input         io_spikes_3,
  input         io_spikes_4,
  input         io_spikes_5,
  input         io_spikes_6,
  input         io_spikes_7
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
`endif // RANDOMIZE_REG_INIT
  wire  spikeEncoder_io_reqs_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_7; // @[TransmissionSystem.scala 22:28]
  wire [2:0] spikeEncoder_io_value; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_7; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_7; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_valid; // @[TransmissionSystem.scala 22:28]
  reg  spikeRegs_0; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_1; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_2; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_3; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_4; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_5; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_6; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_7; // @[TransmissionSystem.scala 18:29]
  reg [4:0] neuronIdMSB_0; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_1; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_2; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_3; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_4; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_5; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_6; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_7; // @[TransmissionSystem.scala 19:29]
  reg  maskRegs_0; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_1; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_2; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_3; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_4; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_5; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_6; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_7; // @[TransmissionSystem.scala 20:29]
  wire  rstReadySel_0 = ~(spikeEncoder_io_rst_0 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_0 = rstReadySel_0 & spikeRegs_0; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_0 = ~spikeEncoder_io_valid | maskRegs_0; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_1 = io_ready ? spikeEncoder_io_mask_0 : _GEN_0; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_1 = {3'h1,neuronIdMSB_0,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_4 = 3'h0 == spikeEncoder_io_value ? _io_data_T_1 : 11'h0; // @[TransmissionSystem.scala 28:12 49:41 50:15]
  wire  rstReadySel_1 = ~(spikeEncoder_io_rst_1 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_1 = rstReadySel_1 & spikeRegs_1; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_5 = ~spikeEncoder_io_valid | maskRegs_1; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_6 = io_ready ? spikeEncoder_io_mask_1 : _GEN_5; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_3 = {3'h1,neuronIdMSB_1,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_9 = 3'h1 == spikeEncoder_io_value ? _io_data_T_3 : _GEN_4; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_2 = ~(spikeEncoder_io_rst_2 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_2 = rstReadySel_2 & spikeRegs_2; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_10 = ~spikeEncoder_io_valid | maskRegs_2; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_11 = io_ready ? spikeEncoder_io_mask_2 : _GEN_10; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_5 = {3'h1,neuronIdMSB_2,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_14 = 3'h2 == spikeEncoder_io_value ? _io_data_T_5 : _GEN_9; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_3 = ~(spikeEncoder_io_rst_3 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_3 = rstReadySel_3 & spikeRegs_3; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_15 = ~spikeEncoder_io_valid | maskRegs_3; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_16 = io_ready ? spikeEncoder_io_mask_3 : _GEN_15; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_7 = {3'h1,neuronIdMSB_3,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_19 = 3'h3 == spikeEncoder_io_value ? _io_data_T_7 : _GEN_14; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_4 = ~(spikeEncoder_io_rst_4 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_4 = rstReadySel_4 & spikeRegs_4; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_20 = ~spikeEncoder_io_valid | maskRegs_4; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_21 = io_ready ? spikeEncoder_io_mask_4 : _GEN_20; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_9 = {3'h1,neuronIdMSB_4,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_24 = 3'h4 == spikeEncoder_io_value ? _io_data_T_9 : _GEN_19; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_5 = ~(spikeEncoder_io_rst_5 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_5 = rstReadySel_5 & spikeRegs_5; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_25 = ~spikeEncoder_io_valid | maskRegs_5; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_26 = io_ready ? spikeEncoder_io_mask_5 : _GEN_25; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_11 = {3'h1,neuronIdMSB_5,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_29 = 3'h5 == spikeEncoder_io_value ? _io_data_T_11 : _GEN_24; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_6 = ~(spikeEncoder_io_rst_6 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_6 = rstReadySel_6 & spikeRegs_6; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_30 = ~spikeEncoder_io_valid | maskRegs_6; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_31 = io_ready ? spikeEncoder_io_mask_6 : _GEN_30; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_13 = {3'h1,neuronIdMSB_6,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_34 = 3'h6 == spikeEncoder_io_value ? _io_data_T_13 : _GEN_29; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_7 = ~(spikeEncoder_io_rst_7 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_7 = rstReadySel_7 & spikeRegs_7; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_35 = ~spikeEncoder_io_valid | maskRegs_7; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_36 = io_ready ? spikeEncoder_io_mask_7 : _GEN_35; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_15 = {3'h1,neuronIdMSB_7,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  PriorityMaskRstEncoder spikeEncoder ( // @[TransmissionSystem.scala 22:28]
    .io_reqs_0(spikeEncoder_io_reqs_0),
    .io_reqs_1(spikeEncoder_io_reqs_1),
    .io_reqs_2(spikeEncoder_io_reqs_2),
    .io_reqs_3(spikeEncoder_io_reqs_3),
    .io_reqs_4(spikeEncoder_io_reqs_4),
    .io_reqs_5(spikeEncoder_io_reqs_5),
    .io_reqs_6(spikeEncoder_io_reqs_6),
    .io_reqs_7(spikeEncoder_io_reqs_7),
    .io_value(spikeEncoder_io_value),
    .io_mask_0(spikeEncoder_io_mask_0),
    .io_mask_1(spikeEncoder_io_mask_1),
    .io_mask_2(spikeEncoder_io_mask_2),
    .io_mask_3(spikeEncoder_io_mask_3),
    .io_mask_4(spikeEncoder_io_mask_4),
    .io_mask_5(spikeEncoder_io_mask_5),
    .io_mask_6(spikeEncoder_io_mask_6),
    .io_mask_7(spikeEncoder_io_mask_7),
    .io_rst_0(spikeEncoder_io_rst_0),
    .io_rst_1(spikeEncoder_io_rst_1),
    .io_rst_2(spikeEncoder_io_rst_2),
    .io_rst_3(spikeEncoder_io_rst_3),
    .io_rst_4(spikeEncoder_io_rst_4),
    .io_rst_5(spikeEncoder_io_rst_5),
    .io_rst_6(spikeEncoder_io_rst_6),
    .io_rst_7(spikeEncoder_io_rst_7),
    .io_valid(spikeEncoder_io_valid)
  );
  assign io_data = 3'h7 == spikeEncoder_io_value ? _io_data_T_15 : _GEN_34; // @[TransmissionSystem.scala 49:41 50:15]
  assign io_valid = spikeEncoder_io_valid; // @[TransmissionSystem.scala 29:12]
  assign spikeEncoder_io_reqs_0 = maskRegs_0 & spikeRegs_0; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_1 = maskRegs_1 & spikeRegs_1; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_2 = maskRegs_2 & spikeRegs_2; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_3 = maskRegs_3 & spikeRegs_3; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_4 = maskRegs_4 & spikeRegs_4; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_5 = maskRegs_5 & spikeRegs_5; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_6 = maskRegs_6 & spikeRegs_6; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_7 = maskRegs_7 & spikeRegs_7; // @[TransmissionSystem.scala 33:35]
  always @(posedge clock) begin
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_0 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_0) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_0 <= io_spikes_0; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_1 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_1) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_1 <= io_spikes_1; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_2 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_2) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_2 <= io_spikes_2; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_3 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_3) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_3 <= io_spikes_3; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_4 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_4) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_4 <= io_spikes_4; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_5 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_5) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_5 <= io_spikes_5; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_6 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_6) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_6 <= io_spikes_6; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_7 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_7) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_7 <= io_spikes_7; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_0 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_0) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_0 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_1 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_1) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_1 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_2 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_2) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_2 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_3 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_3) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_3 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_4 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_4) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_4 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_5 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_5) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_5 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_6 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_6) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_6 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_7 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_7) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_7 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    maskRegs_0 <= reset | _GEN_1; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_1 <= reset | _GEN_6; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_2 <= reset | _GEN_11; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_3 <= reset | _GEN_16; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_4 <= reset | _GEN_21; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_5 <= reset | _GEN_26; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_6 <= reset | _GEN_31; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_7 <= reset | _GEN_36; // @[TransmissionSystem.scala 20:{29,29}]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  spikeRegs_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  spikeRegs_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  spikeRegs_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  spikeRegs_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  spikeRegs_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  spikeRegs_5 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  spikeRegs_6 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  spikeRegs_7 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  neuronIdMSB_0 = _RAND_8[4:0];
  _RAND_9 = {1{`RANDOM}};
  neuronIdMSB_1 = _RAND_9[4:0];
  _RAND_10 = {1{`RANDOM}};
  neuronIdMSB_2 = _RAND_10[4:0];
  _RAND_11 = {1{`RANDOM}};
  neuronIdMSB_3 = _RAND_11[4:0];
  _RAND_12 = {1{`RANDOM}};
  neuronIdMSB_4 = _RAND_12[4:0];
  _RAND_13 = {1{`RANDOM}};
  neuronIdMSB_5 = _RAND_13[4:0];
  _RAND_14 = {1{`RANDOM}};
  neuronIdMSB_6 = _RAND_14[4:0];
  _RAND_15 = {1{`RANDOM}};
  neuronIdMSB_7 = _RAND_15[4:0];
  _RAND_16 = {1{`RANDOM}};
  maskRegs_0 = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  maskRegs_1 = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  maskRegs_2 = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  maskRegs_3 = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  maskRegs_4 = _RAND_20[0:0];
  _RAND_21 = {1{`RANDOM}};
  maskRegs_5 = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  maskRegs_6 = _RAND_22[0:0];
  _RAND_23 = {1{`RANDOM}};
  maskRegs_7 = _RAND_23[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module InputCore_1(
  input         clock,
  input         reset,
  output        io_pmClkEn,
  input         io_newTS,
  input         io_offCCHSin,
  output        io_offCCHSout,
  output        io_memEn,
  output [8:0]  io_memAddr,
  input  [8:0]  io_memDo,
  input         io_grant,
  output        io_req,
  output [10:0] io_tx
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
`endif // RANDOMIZE_REG_INIT
  wire  interface__io_grant; // @[InputCore.scala 33:25]
  wire  interface__io_reqOut; // @[InputCore.scala 33:25]
  wire [10:0] interface__io_tx; // @[InputCore.scala 33:25]
  wire [10:0] interface__io_spikeID; // @[InputCore.scala 33:25]
  wire  interface__io_ready; // @[InputCore.scala 33:25]
  wire  interface__io_reqIn; // @[InputCore.scala 33:25]
  wire  spikeTrans_clock; // @[InputCore.scala 40:26]
  wire  spikeTrans_reset; // @[InputCore.scala 40:26]
  wire [10:0] spikeTrans_io_data; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_ready; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_valid; // @[InputCore.scala 40:26]
  wire [4:0] spikeTrans_io_n; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_0; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_1; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_2; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_3; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_4; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_5; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_6; // @[InputCore.scala 40:26]
  wire  spikeTrans_io_spikes_7; // @[InputCore.scala 40:26]
  reg [2:0] state; // @[InputCore.scala 47:23]
  reg [8:0] ts; // @[InputCore.scala 48:23]
  reg [7:0] pixCnt; // @[InputCore.scala 49:23]
  reg [7:0] pixCntLate; // @[InputCore.scala 50:28]
  reg [7:0] pixCntLater; // @[InputCore.scala 51:28]
  reg  spikePulse_0; // @[InputCore.scala 54:29]
  reg  spikePulse_1; // @[InputCore.scala 54:29]
  reg  spikePulse_2; // @[InputCore.scala 54:29]
  reg  spikePulse_3; // @[InputCore.scala 54:29]
  reg  spikePulse_4; // @[InputCore.scala 54:29]
  reg  spikePulse_5; // @[InputCore.scala 54:29]
  reg  spikePulse_6; // @[InputCore.scala 54:29]
  reg  spikePulse_7; // @[InputCore.scala 54:29]
  reg  phase; // @[InputCore.scala 57:22]
  wire [8:0] _shouldSpike_res_T_3 = ts % io_memDo; // @[InputCore.scala 62:59]
  wire [8:0] shouldSpike_res = ts == 9'h0 | io_memDo == 9'h0 ? 9'h1 : _shouldSpike_res_T_3; // @[InputCore.scala 62:18]
  wire  shouldSpike = shouldSpike_res == 9'h0; // @[InputCore.scala 63:9]
  wire [8:0] _GEN_43 = {{1'd0}, pixCnt}; // @[InputCore.scala 76:35]
  wire [8:0] _io_memAddr_T_1 = _GEN_43 + 9'h100; // @[InputCore.scala 76:35]
  wire  _T_2 = io_offCCHSin != phase & io_newTS; // @[InputCore.scala 84:35]
  wire [7:0] _pixCnt_T_1 = pixCnt + 8'h1; // @[InputCore.scala 94:24]
  wire [3:0] _sPulseDecSig_T_1 = {1'h0,pixCntLate[2:0]}; // @[InputCore.scala 105:34]
  wire [3:0] _GEN_3 = shouldSpike ? _sPulseDecSig_T_1 : 4'h8; // @[InputCore.scala 104:25 105:22]
  wire [2:0] _GEN_4 = pixCnt == 8'hff ? 3'h3 : state; // @[InputCore.scala 108:43 109:15 47:23]
  wire [8:0] _ts_T_1 = ts + 9'h1; // @[InputCore.scala 115:16]
  wire  _GEN_6 = ~interface__io_reqOut & ~io_newTS ? 1'h0 : 1'h1; // @[InputCore.scala 126:47 127:20 74:14]
  wire [2:0] _GEN_7 = ts == 9'h1f3 ? 3'h0 : 3'h1; // @[InputCore.scala 132:28 133:17 135:17]
  wire  _GEN_8 = io_newTS | _GEN_6; // @[InputCore.scala 130:22 131:20]
  wire [2:0] _GEN_9 = io_newTS ? _GEN_7 : state; // @[InputCore.scala 130:22 47:23]
  wire  _GEN_10 = 3'h4 == state ? _GEN_8 : 1'h1; // @[InputCore.scala 74:14 77:17]
  wire [2:0] _GEN_11 = 3'h4 == state ? _GEN_9 : state; // @[InputCore.scala 77:17 47:23]
  wire [8:0] _GEN_12 = 3'h3 == state ? _ts_T_1 : ts; // @[InputCore.scala 115:10 77:17 48:23]
  wire [3:0] _GEN_13 = 3'h3 == state ? _GEN_3 : 4'h8; // @[InputCore.scala 77:17]
  wire [2:0] _GEN_14 = 3'h3 == state ? 3'h4 : _GEN_11; // @[InputCore.scala 120:13 77:17]
  wire [3:0] _GEN_18 = 3'h2 == state ? _GEN_3 : _GEN_13; // @[InputCore.scala 77:17]
  wire  _GEN_22 = 3'h1 == state | 3'h2 == state; // @[InputCore.scala 77:17 93:16]
  wire [3:0] _GEN_25 = 3'h1 == state ? 4'h8 : _GEN_18; // @[InputCore.scala 77:17]
  wire  _GEN_27 = 3'h1 == state | (3'h2 == state | (3'h3 == state | _GEN_10)); // @[InputCore.scala 74:14 77:17]
  wire [3:0] sPulseDecSig = 3'h0 == state ? 4'h8 : _GEN_25; // @[InputCore.scala 77:17]
  wire  _T_12 = sPulseDecSig == 4'h0; // @[InputCore.scala 144:24]
  wire  _T_13 = sPulseDecSig == 4'h1; // @[InputCore.scala 144:24]
  wire  _T_14 = sPulseDecSig == 4'h2; // @[InputCore.scala 144:24]
  wire  _T_15 = sPulseDecSig == 4'h3; // @[InputCore.scala 144:24]
  wire  _T_16 = sPulseDecSig == 4'h4; // @[InputCore.scala 144:24]
  wire  _T_17 = sPulseDecSig == 4'h5; // @[InputCore.scala 144:24]
  wire  _T_18 = sPulseDecSig == 4'h6; // @[InputCore.scala 144:24]
  wire  _T_19 = sPulseDecSig == 4'h7; // @[InputCore.scala 144:24]
  BusInterface interface_ ( // @[InputCore.scala 33:25]
    .io_grant(interface__io_grant),
    .io_reqOut(interface__io_reqOut),
    .io_tx(interface__io_tx),
    .io_spikeID(interface__io_spikeID),
    .io_ready(interface__io_ready),
    .io_reqIn(interface__io_reqIn)
  );
  TransmissionSystem_1 spikeTrans ( // @[InputCore.scala 40:26]
    .clock(spikeTrans_clock),
    .reset(spikeTrans_reset),
    .io_data(spikeTrans_io_data),
    .io_ready(spikeTrans_io_ready),
    .io_valid(spikeTrans_io_valid),
    .io_n(spikeTrans_io_n),
    .io_spikes_0(spikeTrans_io_spikes_0),
    .io_spikes_1(spikeTrans_io_spikes_1),
    .io_spikes_2(spikeTrans_io_spikes_2),
    .io_spikes_3(spikeTrans_io_spikes_3),
    .io_spikes_4(spikeTrans_io_spikes_4),
    .io_spikes_5(spikeTrans_io_spikes_5),
    .io_spikes_6(spikeTrans_io_spikes_6),
    .io_spikes_7(spikeTrans_io_spikes_7)
  );
  assign io_pmClkEn = 3'h0 == state ? _T_2 : _GEN_27; // @[InputCore.scala 77:17]
  assign io_offCCHSout = phase; // @[InputCore.scala 58:17]
  assign io_memEn = 3'h0 == state ? 1'h0 : _GEN_22; // @[InputCore.scala 75:14 77:17]
  assign io_memAddr = phase ? _io_memAddr_T_1 : {{1'd0}, pixCnt}; // @[InputCore.scala 76:20]
  assign io_req = interface__io_reqOut; // @[InputCore.scala 35:22]
  assign io_tx = interface__io_tx; // @[InputCore.scala 36:22]
  assign interface__io_grant = io_grant; // @[InputCore.scala 34:22]
  assign interface__io_spikeID = spikeTrans_io_data; // @[InputCore.scala 41:27]
  assign interface__io_reqIn = spikeTrans_io_valid; // @[InputCore.scala 43:27]
  assign spikeTrans_clock = clock;
  assign spikeTrans_reset = reset;
  assign spikeTrans_io_ready = interface__io_ready; // @[InputCore.scala 42:27]
  assign spikeTrans_io_n = pixCntLater[7:3]; // @[InputCore.scala 150:33]
  assign spikeTrans_io_spikes_0 = spikePulse_0; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_1 = spikePulse_1; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_2 = spikePulse_2; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_3 = spikePulse_3; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_4 = spikePulse_4; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_5 = spikePulse_5; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_6 = spikePulse_6; // @[InputCore.scala 152:29]
  assign spikeTrans_io_spikes_7 = spikePulse_7; // @[InputCore.scala 152:29]
  always @(posedge clock) begin
    if (reset) begin // @[InputCore.scala 47:23]
      state <= 3'h0; // @[InputCore.scala 47:23]
    end else if (3'h0 == state) begin // @[InputCore.scala 77:17]
      if (io_offCCHSin != phase & io_newTS) begin // @[InputCore.scala 84:48]
        state <= 3'h1; // @[InputCore.scala 86:15]
      end
    end else if (3'h1 == state) begin // @[InputCore.scala 77:17]
      state <= 3'h2; // @[InputCore.scala 96:13]
    end else if (3'h2 == state) begin // @[InputCore.scala 77:17]
      state <= _GEN_4;
    end else begin
      state <= _GEN_14;
    end
    if (reset) begin // @[InputCore.scala 48:23]
      ts <= 9'h0; // @[InputCore.scala 48:23]
    end else if (3'h0 == state) begin // @[InputCore.scala 77:17]
      ts <= 9'h0; // @[InputCore.scala 81:10]
    end else if (!(3'h1 == state)) begin // @[InputCore.scala 77:17]
      if (!(3'h2 == state)) begin // @[InputCore.scala 77:17]
        ts <= _GEN_12;
      end
    end
    if (reset) begin // @[InputCore.scala 49:23]
      pixCnt <= 8'h0; // @[InputCore.scala 49:23]
    end else if (3'h0 == state) begin // @[InputCore.scala 77:17]
      pixCnt <= 8'h0; // @[InputCore.scala 82:14]
    end else if (3'h1 == state) begin // @[InputCore.scala 77:17]
      pixCnt <= _pixCnt_T_1; // @[InputCore.scala 94:14]
    end else if (3'h2 == state) begin // @[InputCore.scala 77:17]
      pixCnt <= _pixCnt_T_1; // @[InputCore.scala 103:14]
    end
    pixCntLate <= pixCnt; // @[InputCore.scala 50:28]
    pixCntLater <= pixCntLate; // @[InputCore.scala 51:28]
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_0 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_0 <= _T_12;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_1 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_1 <= _T_13;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_2 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_2 <= _T_14;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_3 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_3 <= _T_15;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_4 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_4 <= _T_16;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_5 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_5 <= _T_17;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_6 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_6 <= _T_18;
    end
    if (reset) begin // @[InputCore.scala 54:29]
      spikePulse_7 <= 1'h0; // @[InputCore.scala 54:29]
    end else begin
      spikePulse_7 <= _T_19;
    end
    if (reset) begin // @[InputCore.scala 57:22]
      phase <= 1'h0; // @[InputCore.scala 57:22]
    end else if (3'h0 == state) begin // @[InputCore.scala 77:17]
      if (io_offCCHSin != phase & io_newTS) begin // @[InputCore.scala 84:48]
        phase <= ~phase; // @[InputCore.scala 87:15]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  ts = _RAND_1[8:0];
  _RAND_2 = {1{`RANDOM}};
  pixCnt = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  pixCntLate = _RAND_3[7:0];
  _RAND_4 = {1{`RANDOM}};
  pixCntLater = _RAND_4[7:0];
  _RAND_5 = {1{`RANDOM}};
  spikePulse_0 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  spikePulse_1 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  spikePulse_2 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  spikePulse_3 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  spikePulse_4 = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  spikePulse_5 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  spikePulse_6 = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  spikePulse_7 = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  phase = _RAND_13[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module BusInterface_2(
  input         clock,
  input         reset,
  input         io_grant,
  output        io_reqOut,
  output [10:0] io_tx,
  input  [10:0] io_rx,
  output [9:0]  io_axonID,
  output        io_valid,
  input  [10:0] io_spikeID,
  output        io_ready,
  input         io_reqIn
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] axonIDLSBReg; // @[BusInterface.scala 36:29]
  reg [2:0] synROMReg; // @[BusInterface.scala 39:27]
  wire [2:0] _GEN_1 = 3'h1 == io_rx[10:8] ? 3'h5 : 3'h4; // @[BusInterface.scala 40:{19,19}]
  wire [2:0] _GEN_2 = 3'h2 == io_rx[10:8] ? 3'h0 : _GEN_1; // @[BusInterface.scala 40:{19,19}]
  assign io_reqOut = io_reqIn & ~io_grant; // @[BusInterface.scala 32:25]
  assign io_tx = io_grant ? io_spikeID : 11'h0; // @[BusInterface.scala 31:15]
  assign io_axonID = {synROMReg[1:0],axonIDLSBReg}; // @[BusInterface.scala 43:47]
  assign io_valid = synROMReg[2]; // @[BusInterface.scala 42:25]
  assign io_ready = io_grant; // @[BusInterface.scala 33:13]
  always @(posedge clock) begin
    if (reset) begin // @[BusInterface.scala 36:29]
      axonIDLSBReg <= 8'h0; // @[BusInterface.scala 36:29]
    end else begin
      axonIDLSBReg <= io_rx[7:0]; // @[BusInterface.scala 37:16]
    end
    if (reset) begin // @[BusInterface.scala 39:27]
      synROMReg <= 3'h0; // @[BusInterface.scala 39:27]
    end else if (|io_rx) begin // @[BusInterface.scala 40:19]
      if (3'h4 == io_rx[10:8]) begin // @[BusInterface.scala 40:19]
        synROMReg <= 3'h0; // @[BusInterface.scala 40:19]
      end else if (3'h3 == io_rx[10:8]) begin // @[BusInterface.scala 40:19]
        synROMReg <= 3'h6; // @[BusInterface.scala 40:19]
      end else begin
        synROMReg <= _GEN_2;
      end
    end else begin
      synROMReg <= 3'h0;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  axonIDLSBReg = _RAND_0[7:0];
  _RAND_1 = {1{`RANDOM}};
  synROMReg = _RAND_1[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module AxonSystem(
  input        clock,
  input        reset,
  input  [9:0] io_axonIn,
  input        io_axonValid,
  input        io_inOut,
  output [9:0] io_spikeCnt,
  input  [9:0] io_rAddr,
  input        io_rEna,
  output [9:0] io_rData
);
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_3;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
`endif // RANDOMIZE_REG_INIT
  reg [9:0] axonMem0 [0:1023]; // @[AxonSystem.scala 36:29]
  wire  axonMem0_rdata0_MPORT_en; // @[AxonSystem.scala 36:29]
  wire [9:0] axonMem0_rdata0_MPORT_addr; // @[AxonSystem.scala 36:29]
  wire [9:0] axonMem0_rdata0_MPORT_data; // @[AxonSystem.scala 36:29]
  wire [9:0] axonMem0_MPORT_data; // @[AxonSystem.scala 36:29]
  wire [9:0] axonMem0_MPORT_addr; // @[AxonSystem.scala 36:29]
  wire  axonMem0_MPORT_mask; // @[AxonSystem.scala 36:29]
  wire  axonMem0_MPORT_en; // @[AxonSystem.scala 36:29]
  reg  axonMem0_rdata0_MPORT_en_pipe_0;
  reg [9:0] axonMem0_rdata0_MPORT_addr_pipe_0;
  reg [9:0] axonMem1 [0:1023]; // @[AxonSystem.scala 52:29]
  wire  axonMem1_rdata1_MPORT_en; // @[AxonSystem.scala 52:29]
  wire [9:0] axonMem1_rdata1_MPORT_addr; // @[AxonSystem.scala 52:29]
  wire [9:0] axonMem1_rdata1_MPORT_data; // @[AxonSystem.scala 52:29]
  wire [9:0] axonMem1_MPORT_1_data; // @[AxonSystem.scala 52:29]
  wire [9:0] axonMem1_MPORT_1_addr; // @[AxonSystem.scala 52:29]
  wire  axonMem1_MPORT_1_mask; // @[AxonSystem.scala 52:29]
  wire  axonMem1_MPORT_1_en; // @[AxonSystem.scala 52:29]
  reg  axonMem1_rdata1_MPORT_en_pipe_0;
  reg [9:0] axonMem1_rdata1_MPORT_addr_pipe_0;
  reg  inOutReg; // @[AxonSystem.scala 21:25]
  reg [9:0] spikeCntReg; // @[AxonSystem.scala 22:28]
  wire [9:0] _spikeCntReg_T_1 = spikeCntReg + 10'h1; // @[AxonSystem.scala 26:32]
  wire  wr0 = ~io_inOut; // @[AxonSystem.scala 64:8]
  wire [9:0] rdata0 = axonMem0_rdata0_MPORT_data; // @[AxonSystem.scala 40:15 43:14]
  wire  ena0 = wr0 ? io_axonValid : io_rEna; // @[AxonSystem.scala 64:19 65:12 76:14]
  wire  wr1 = wr0 ? 1'h0 : 1'h1; // @[AxonSystem.scala 64:19 71:14 83:14]
  wire [9:0] rdata1 = axonMem1_rdata1_MPORT_data; // @[AxonSystem.scala 56:15 59:14]
  wire  ena1 = wr0 ? io_rEna : io_axonValid; // @[AxonSystem.scala 64:19 70:14 82:14]
  assign axonMem0_rdata0_MPORT_en = axonMem0_rdata0_MPORT_en_pipe_0;
  assign axonMem0_rdata0_MPORT_addr = axonMem0_rdata0_MPORT_addr_pipe_0;
  assign axonMem0_rdata0_MPORT_data = axonMem0[axonMem0_rdata0_MPORT_addr]; // @[AxonSystem.scala 36:29]
  assign axonMem0_MPORT_data = wr0 ? io_axonIn : 10'h0;
  assign axonMem0_MPORT_addr = wr0 ? spikeCntReg : io_rAddr;
  assign axonMem0_MPORT_mask = 1'h1;
  assign axonMem0_MPORT_en = ena0 & wr0;
  assign axonMem1_rdata1_MPORT_en = axonMem1_rdata1_MPORT_en_pipe_0;
  assign axonMem1_rdata1_MPORT_addr = axonMem1_rdata1_MPORT_addr_pipe_0;
  assign axonMem1_rdata1_MPORT_data = axonMem1[axonMem1_rdata1_MPORT_addr]; // @[AxonSystem.scala 52:29]
  assign axonMem1_MPORT_1_data = wr0 ? 10'h0 : io_axonIn;
  assign axonMem1_MPORT_1_addr = wr0 ? io_rAddr : spikeCntReg;
  assign axonMem1_MPORT_1_mask = 1'h1;
  assign axonMem1_MPORT_1_en = ena1 & wr1;
  assign io_spikeCnt = spikeCntReg; // @[AxonSystem.scala 28:15]
  assign io_rData = wr0 ? rdata1 : rdata0; // @[AxonSystem.scala 64:19 72:14 78:14]
  always @(posedge clock) begin
    if (axonMem0_MPORT_en & axonMem0_MPORT_mask) begin
      axonMem0[axonMem0_MPORT_addr] <= axonMem0_MPORT_data; // @[AxonSystem.scala 36:29]
    end
    axonMem0_rdata0_MPORT_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      if (wr0) begin
        axonMem0_rdata0_MPORT_addr_pipe_0 <= spikeCntReg;
      end else begin
        axonMem0_rdata0_MPORT_addr_pipe_0 <= io_rAddr;
      end
    end
    if (axonMem1_MPORT_1_en & axonMem1_MPORT_1_mask) begin
      axonMem1[axonMem1_MPORT_1_addr] <= axonMem1_MPORT_1_data; // @[AxonSystem.scala 52:29]
    end
    axonMem1_rdata1_MPORT_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      if (wr0) begin
        axonMem1_rdata1_MPORT_addr_pipe_0 <= io_rAddr;
      end else begin
        axonMem1_rdata1_MPORT_addr_pipe_0 <= spikeCntReg;
      end
    end
    inOutReg <= io_inOut; // @[AxonSystem.scala 21:25]
    if (reset) begin // @[AxonSystem.scala 22:28]
      spikeCntReg <= 10'h0; // @[AxonSystem.scala 22:28]
    end else if (inOutReg != io_inOut) begin // @[AxonSystem.scala 23:31]
      spikeCntReg <= 10'h0; // @[AxonSystem.scala 24:17]
    end else if (io_axonValid) begin // @[AxonSystem.scala 25:28]
      spikeCntReg <= _spikeCntReg_T_1; // @[AxonSystem.scala 26:17]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1024; initvar = initvar+1)
    axonMem0[initvar] = _RAND_0[9:0];
  _RAND_3 = {1{`RANDOM}};
  for (initvar = 0; initvar < 1024; initvar = initvar+1)
    axonMem1[initvar] = _RAND_3[9:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  axonMem0_rdata0_MPORT_en_pipe_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  axonMem0_rdata0_MPORT_addr_pipe_0 = _RAND_2[9:0];
  _RAND_4 = {1{`RANDOM}};
  axonMem1_rdata1_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  axonMem1_rdata1_MPORT_addr_pipe_0 = _RAND_5[9:0];
  _RAND_6 = {1{`RANDOM}};
  inOutReg = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  spikeCntReg = _RAND_7[9:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module TransmissionSystem_2(
  input         clock,
  input         reset,
  output [10:0] io_data,
  input         io_ready,
  output        io_valid,
  input  [4:0]  io_n,
  input         io_spikes_0,
  input         io_spikes_1,
  input         io_spikes_2,
  input         io_spikes_3,
  input         io_spikes_4,
  input         io_spikes_5,
  input         io_spikes_6,
  input         io_spikes_7
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
`endif // RANDOMIZE_REG_INIT
  wire  spikeEncoder_io_reqs_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_7; // @[TransmissionSystem.scala 22:28]
  wire [2:0] spikeEncoder_io_value; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_7; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_7; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_valid; // @[TransmissionSystem.scala 22:28]
  reg  spikeRegs_0; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_1; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_2; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_3; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_4; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_5; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_6; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_7; // @[TransmissionSystem.scala 18:29]
  reg [4:0] neuronIdMSB_0; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_1; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_2; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_3; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_4; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_5; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_6; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_7; // @[TransmissionSystem.scala 19:29]
  reg  maskRegs_0; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_1; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_2; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_3; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_4; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_5; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_6; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_7; // @[TransmissionSystem.scala 20:29]
  wire  rstReadySel_0 = ~(spikeEncoder_io_rst_0 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_0 = rstReadySel_0 & spikeRegs_0; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_0 = ~spikeEncoder_io_valid | maskRegs_0; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_1 = io_ready ? spikeEncoder_io_mask_0 : _GEN_0; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_1 = {3'h2,neuronIdMSB_0,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_4 = 3'h0 == spikeEncoder_io_value ? _io_data_T_1 : 11'h0; // @[TransmissionSystem.scala 28:12 49:41 50:15]
  wire  rstReadySel_1 = ~(spikeEncoder_io_rst_1 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_1 = rstReadySel_1 & spikeRegs_1; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_5 = ~spikeEncoder_io_valid | maskRegs_1; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_6 = io_ready ? spikeEncoder_io_mask_1 : _GEN_5; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_3 = {3'h2,neuronIdMSB_1,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_9 = 3'h1 == spikeEncoder_io_value ? _io_data_T_3 : _GEN_4; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_2 = ~(spikeEncoder_io_rst_2 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_2 = rstReadySel_2 & spikeRegs_2; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_10 = ~spikeEncoder_io_valid | maskRegs_2; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_11 = io_ready ? spikeEncoder_io_mask_2 : _GEN_10; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_5 = {3'h2,neuronIdMSB_2,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_14 = 3'h2 == spikeEncoder_io_value ? _io_data_T_5 : _GEN_9; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_3 = ~(spikeEncoder_io_rst_3 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_3 = rstReadySel_3 & spikeRegs_3; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_15 = ~spikeEncoder_io_valid | maskRegs_3; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_16 = io_ready ? spikeEncoder_io_mask_3 : _GEN_15; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_7 = {3'h2,neuronIdMSB_3,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_19 = 3'h3 == spikeEncoder_io_value ? _io_data_T_7 : _GEN_14; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_4 = ~(spikeEncoder_io_rst_4 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_4 = rstReadySel_4 & spikeRegs_4; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_20 = ~spikeEncoder_io_valid | maskRegs_4; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_21 = io_ready ? spikeEncoder_io_mask_4 : _GEN_20; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_9 = {3'h2,neuronIdMSB_4,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_24 = 3'h4 == spikeEncoder_io_value ? _io_data_T_9 : _GEN_19; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_5 = ~(spikeEncoder_io_rst_5 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_5 = rstReadySel_5 & spikeRegs_5; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_25 = ~spikeEncoder_io_valid | maskRegs_5; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_26 = io_ready ? spikeEncoder_io_mask_5 : _GEN_25; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_11 = {3'h2,neuronIdMSB_5,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_29 = 3'h5 == spikeEncoder_io_value ? _io_data_T_11 : _GEN_24; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_6 = ~(spikeEncoder_io_rst_6 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_6 = rstReadySel_6 & spikeRegs_6; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_30 = ~spikeEncoder_io_valid | maskRegs_6; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_31 = io_ready ? spikeEncoder_io_mask_6 : _GEN_30; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_13 = {3'h2,neuronIdMSB_6,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_34 = 3'h6 == spikeEncoder_io_value ? _io_data_T_13 : _GEN_29; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_7 = ~(spikeEncoder_io_rst_7 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_7 = rstReadySel_7 & spikeRegs_7; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_35 = ~spikeEncoder_io_valid | maskRegs_7; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_36 = io_ready ? spikeEncoder_io_mask_7 : _GEN_35; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_15 = {3'h2,neuronIdMSB_7,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  PriorityMaskRstEncoder spikeEncoder ( // @[TransmissionSystem.scala 22:28]
    .io_reqs_0(spikeEncoder_io_reqs_0),
    .io_reqs_1(spikeEncoder_io_reqs_1),
    .io_reqs_2(spikeEncoder_io_reqs_2),
    .io_reqs_3(spikeEncoder_io_reqs_3),
    .io_reqs_4(spikeEncoder_io_reqs_4),
    .io_reqs_5(spikeEncoder_io_reqs_5),
    .io_reqs_6(spikeEncoder_io_reqs_6),
    .io_reqs_7(spikeEncoder_io_reqs_7),
    .io_value(spikeEncoder_io_value),
    .io_mask_0(spikeEncoder_io_mask_0),
    .io_mask_1(spikeEncoder_io_mask_1),
    .io_mask_2(spikeEncoder_io_mask_2),
    .io_mask_3(spikeEncoder_io_mask_3),
    .io_mask_4(spikeEncoder_io_mask_4),
    .io_mask_5(spikeEncoder_io_mask_5),
    .io_mask_6(spikeEncoder_io_mask_6),
    .io_mask_7(spikeEncoder_io_mask_7),
    .io_rst_0(spikeEncoder_io_rst_0),
    .io_rst_1(spikeEncoder_io_rst_1),
    .io_rst_2(spikeEncoder_io_rst_2),
    .io_rst_3(spikeEncoder_io_rst_3),
    .io_rst_4(spikeEncoder_io_rst_4),
    .io_rst_5(spikeEncoder_io_rst_5),
    .io_rst_6(spikeEncoder_io_rst_6),
    .io_rst_7(spikeEncoder_io_rst_7),
    .io_valid(spikeEncoder_io_valid)
  );
  assign io_data = 3'h7 == spikeEncoder_io_value ? _io_data_T_15 : _GEN_34; // @[TransmissionSystem.scala 49:41 50:15]
  assign io_valid = spikeEncoder_io_valid; // @[TransmissionSystem.scala 29:12]
  assign spikeEncoder_io_reqs_0 = maskRegs_0 & spikeRegs_0; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_1 = maskRegs_1 & spikeRegs_1; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_2 = maskRegs_2 & spikeRegs_2; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_3 = maskRegs_3 & spikeRegs_3; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_4 = maskRegs_4 & spikeRegs_4; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_5 = maskRegs_5 & spikeRegs_5; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_6 = maskRegs_6 & spikeRegs_6; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_7 = maskRegs_7 & spikeRegs_7; // @[TransmissionSystem.scala 33:35]
  always @(posedge clock) begin
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_0 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_0) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_0 <= io_spikes_0; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_1 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_1) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_1 <= io_spikes_1; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_2 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_2) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_2 <= io_spikes_2; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_3 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_3) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_3 <= io_spikes_3; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_4 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_4) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_4 <= io_spikes_4; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_5 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_5) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_5 <= io_spikes_5; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_6 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_6) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_6 <= io_spikes_6; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_7 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_7) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_7 <= io_spikes_7; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_0 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_0) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_0 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_1 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_1) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_1 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_2 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_2) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_2 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_3 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_3) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_3 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_4 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_4) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_4 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_5 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_5) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_5 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_6 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_6) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_6 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_7 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_7) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_7 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    maskRegs_0 <= reset | _GEN_1; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_1 <= reset | _GEN_6; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_2 <= reset | _GEN_11; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_3 <= reset | _GEN_16; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_4 <= reset | _GEN_21; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_5 <= reset | _GEN_26; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_6 <= reset | _GEN_31; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_7 <= reset | _GEN_36; // @[TransmissionSystem.scala 20:{29,29}]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  spikeRegs_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  spikeRegs_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  spikeRegs_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  spikeRegs_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  spikeRegs_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  spikeRegs_5 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  spikeRegs_6 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  spikeRegs_7 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  neuronIdMSB_0 = _RAND_8[4:0];
  _RAND_9 = {1{`RANDOM}};
  neuronIdMSB_1 = _RAND_9[4:0];
  _RAND_10 = {1{`RANDOM}};
  neuronIdMSB_2 = _RAND_10[4:0];
  _RAND_11 = {1{`RANDOM}};
  neuronIdMSB_3 = _RAND_11[4:0];
  _RAND_12 = {1{`RANDOM}};
  neuronIdMSB_4 = _RAND_12[4:0];
  _RAND_13 = {1{`RANDOM}};
  neuronIdMSB_5 = _RAND_13[4:0];
  _RAND_14 = {1{`RANDOM}};
  neuronIdMSB_6 = _RAND_14[4:0];
  _RAND_15 = {1{`RANDOM}};
  neuronIdMSB_7 = _RAND_15[4:0];
  _RAND_16 = {1{`RANDOM}};
  maskRegs_0 = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  maskRegs_1 = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  maskRegs_2 = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  maskRegs_3 = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  maskRegs_4 = _RAND_20[0:0];
  _RAND_21 = {1{`RANDOM}};
  maskRegs_5 = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  maskRegs_6 = _RAND_22[0:0];
  _RAND_23 = {1{`RANDOM}};
  maskRegs_7 = _RAND_23[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ControlUnit(
  input         clock,
  input         reset,
  output        io_done,
  input         io_newTS,
  output [1:0]  io_addr_sel,
  output [14:0] io_addr_pos,
  output        io_wr,
  output        io_ena,
  input         io_spikeIndi_0,
  input         io_spikeIndi_1,
  input         io_spikeIndi_2,
  input         io_spikeIndi_3,
  input         io_spikeIndi_4,
  input         io_spikeIndi_5,
  input         io_spikeIndi_6,
  input         io_spikeIndi_7,
  input         io_refracIndi_0,
  input         io_refracIndi_1,
  input         io_refracIndi_2,
  input         io_refracIndi_3,
  input         io_refracIndi_4,
  input         io_refracIndi_5,
  input         io_refracIndi_6,
  input         io_refracIndi_7,
  output [1:0]  io_cntrSels_0_potSel,
  output [1:0]  io_cntrSels_0_spikeSel,
  output        io_cntrSels_0_refracSel,
  output        io_cntrSels_0_decaySel,
  output [1:0]  io_cntrSels_0_writeDataSel,
  output [1:0]  io_cntrSels_1_potSel,
  output [1:0]  io_cntrSels_1_spikeSel,
  output        io_cntrSels_1_refracSel,
  output        io_cntrSels_1_decaySel,
  output [1:0]  io_cntrSels_1_writeDataSel,
  output [1:0]  io_cntrSels_2_potSel,
  output [1:0]  io_cntrSels_2_spikeSel,
  output        io_cntrSels_2_refracSel,
  output        io_cntrSels_2_decaySel,
  output [1:0]  io_cntrSels_2_writeDataSel,
  output [1:0]  io_cntrSels_3_potSel,
  output [1:0]  io_cntrSels_3_spikeSel,
  output        io_cntrSels_3_refracSel,
  output        io_cntrSels_3_decaySel,
  output [1:0]  io_cntrSels_3_writeDataSel,
  output [1:0]  io_cntrSels_4_potSel,
  output [1:0]  io_cntrSels_4_spikeSel,
  output        io_cntrSels_4_refracSel,
  output        io_cntrSels_4_decaySel,
  output [1:0]  io_cntrSels_4_writeDataSel,
  output [1:0]  io_cntrSels_5_potSel,
  output [1:0]  io_cntrSels_5_spikeSel,
  output        io_cntrSels_5_refracSel,
  output        io_cntrSels_5_decaySel,
  output [1:0]  io_cntrSels_5_writeDataSel,
  output [1:0]  io_cntrSels_6_potSel,
  output [1:0]  io_cntrSels_6_spikeSel,
  output        io_cntrSels_6_refracSel,
  output        io_cntrSels_6_decaySel,
  output [1:0]  io_cntrSels_6_writeDataSel,
  output [1:0]  io_cntrSels_7_potSel,
  output [1:0]  io_cntrSels_7_spikeSel,
  output        io_cntrSels_7_refracSel,
  output        io_cntrSels_7_decaySel,
  output [1:0]  io_cntrSels_7_writeDataSel,
  output        io_evalEnable,
  output        io_inOut,
  input  [9:0]  io_spikeCnt,
  output [9:0]  io_aAddr,
  output        io_aEna,
  input  [9:0]  io_aData,
  output [4:0]  io_n,
  output        io_spikes_0,
  output        io_spikes_1,
  output        io_spikes_2,
  output        io_spikes_3,
  output        io_spikes_4,
  output        io_spikes_5,
  output        io_spikes_6,
  output        io_spikes_7
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
`endif // RANDOMIZE_REG_INIT
  reg [3:0] state; // @[ControlUnit.scala 36:22]
  reg  spikePulse_0; // @[ControlUnit.scala 42:27]
  reg  spikePulse_1; // @[ControlUnit.scala 42:27]
  reg  spikePulse_2; // @[ControlUnit.scala 42:27]
  reg  spikePulse_3; // @[ControlUnit.scala 42:27]
  reg  spikePulse_4; // @[ControlUnit.scala 42:27]
  reg  spikePulse_5; // @[ControlUnit.scala 42:27]
  reg  spikePulse_6; // @[ControlUnit.scala 42:27]
  reg  spikePulse_7; // @[ControlUnit.scala 42:27]
  reg [4:0] n; // @[ControlUnit.scala 45:22]
  reg [9:0] a; // @[ControlUnit.scala 47:22]
  reg [9:0] spikeCnt; // @[ControlUnit.scala 50:25]
  reg  inOut; // @[ControlUnit.scala 52:22]
  reg  evalUnitActive_0; // @[ControlUnit.scala 55:31]
  reg  evalUnitActive_1; // @[ControlUnit.scala 55:31]
  reg  evalUnitActive_2; // @[ControlUnit.scala 55:31]
  reg  evalUnitActive_3; // @[ControlUnit.scala 55:31]
  reg  evalUnitActive_4; // @[ControlUnit.scala 55:31]
  reg  evalUnitActive_5; // @[ControlUnit.scala 55:31]
  reg  evalUnitActive_6; // @[ControlUnit.scala 55:31]
  reg  evalUnitActive_7; // @[ControlUnit.scala 55:31]
  wire [7:0] _evalUnitActive_0_T = {n, 3'h0}; // @[ControlUnit.scala 70:44]
  wire [8:0] _evalUnitActive_0_T_1 = {{1'd0}, _evalUnitActive_0_T}; // @[ControlUnit.scala 70:66]
  wire [1:0] _GEN_45 = io_refracIndi_0 ? 2'h1 : 2'h2; // @[ControlUnit.scala 176:32 177:37 63:35]
  wire  _T_12 = spikeCnt == 10'h0; // @[ControlUnit.scala 223:21]
  wire [1:0] _GEN_130 = 4'h7 == state ? _GEN_45 : 2'h2; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_155 = 4'h6 == state ? _GEN_45 : _GEN_130; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_190 = 4'h5 == state ? _GEN_45 : _GEN_155; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_224 = 4'h4 == state ? _GEN_45 : _GEN_190; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_258 = 4'h3 == state ? 2'h0 : _GEN_224; // @[ControlUnit.scala 100:17 152:33]
  wire [1:0] _GEN_294 = 4'h2 == state ? 2'h2 : _GEN_258; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_330 = 4'h1 == state ? 2'h2 : _GEN_294; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] localCntrSels_0_potSel = 4'h0 == state ? 2'h2 : _GEN_330; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_113 = 4'h8 == state ? 2'h0 : 2'h2; // @[ControlUnit.scala 100:17 265:35 64:35]
  wire [1:0] _GEN_139 = 4'h7 == state ? 2'h2 : _GEN_113; // @[ControlUnit.scala 100:17 64:35]
  wire [1:0] _GEN_172 = 4'h6 == state ? 2'h2 : _GEN_139; // @[ControlUnit.scala 100:17 64:35]
  wire [1:0] _GEN_207 = 4'h5 == state ? 2'h2 : _GEN_172; // @[ControlUnit.scala 100:17 64:35]
  wire [1:0] _GEN_241 = 4'h4 == state ? 2'h2 : _GEN_207; // @[ControlUnit.scala 100:17 64:35]
  wire [1:0] _GEN_275 = 4'h3 == state ? 2'h2 : _GEN_241; // @[ControlUnit.scala 100:17 64:35]
  wire [1:0] _GEN_310 = 4'h2 == state ? 2'h2 : _GEN_275; // @[ControlUnit.scala 100:17 64:35]
  wire [1:0] _GEN_325 = 4'h1 == state ? 2'h1 : _GEN_310; // @[ControlUnit.scala 100:17 123:35]
  wire [1:0] localCntrSels_0_spikeSel = 4'h0 == state ? 2'h2 : _GEN_325; // @[ControlUnit.scala 100:17 64:35]
  wire  _GEN_290 = 4'h2 == state ? 1'h0 : 1'h1; // @[ControlUnit.scala 100:17 136:36 65:35]
  wire  localCntrSels_0_refracSel = 4'h0 == state | (4'h1 == state | _GEN_290); // @[ControlUnit.scala 100:17 65:35]
  wire  _GEN_87 = 4'ha == state ? 1'h0 : 4'hb == state; // @[ControlUnit.scala 100:17 288:20]
  wire [1:0] _GEN_97 = 4'h9 == state ? 2'h2 : {{1'd0}, _GEN_87}; // @[ControlUnit.scala 100:17 278:39]
  wire [1:0] _GEN_115 = 4'h8 == state ? 2'h0 : _GEN_97; // @[ControlUnit.scala 100:17 66:35]
  wire [1:0] _GEN_140 = 4'h7 == state ? 2'h0 : _GEN_115; // @[ControlUnit.scala 100:17 66:35]
  wire [1:0] _GEN_173 = 4'h6 == state ? 2'h0 : _GEN_140; // @[ControlUnit.scala 100:17 66:35]
  wire [1:0] _GEN_208 = 4'h5 == state ? 2'h0 : _GEN_173; // @[ControlUnit.scala 100:17 66:35]
  wire [1:0] _GEN_242 = 4'h4 == state ? 2'h0 : _GEN_208; // @[ControlUnit.scala 100:17 66:35]
  wire [1:0] _GEN_276 = 4'h3 == state ? 2'h0 : _GEN_242; // @[ControlUnit.scala 100:17 66:35]
  wire [1:0] _GEN_311 = 4'h2 == state ? 2'h0 : _GEN_276; // @[ControlUnit.scala 100:17 66:35]
  wire [1:0] _GEN_346 = 4'h1 == state ? 2'h0 : _GEN_311; // @[ControlUnit.scala 100:17 66:35]
  wire [1:0] localCntrSels_0_writeDataSel = 4'h0 == state ? 2'h0 : _GEN_346; // @[ControlUnit.scala 100:17 66:35]
  wire  _GEN_64 = spikeCnt == 10'h0 & io_refracIndi_0; // @[ControlUnit.scala 223:30 67:35]
  wire  _GEN_199 = 4'h5 == state ? 1'h0 : 4'h6 == state & _GEN_64; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_225 = 4'h4 == state ? io_refracIndi_0 : _GEN_199; // @[ControlUnit.scala 100:17]
  wire  _GEN_267 = 4'h3 == state ? 1'h0 : _GEN_225; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_302 = 4'h2 == state ? 1'h0 : _GEN_267; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_338 = 4'h1 == state ? 1'h0 : _GEN_302; // @[ControlUnit.scala 100:17 67:35]
  wire  localCntrSels_0_decaySel = 4'h0 == state ? 1'h0 : _GEN_338; // @[ControlUnit.scala 100:17 67:35]
  wire [7:0] _evalUnitActive_1_T_2 = _evalUnitActive_0_T + 8'h1; // @[ControlUnit.scala 70:66]
  wire [1:0] _GEN_47 = io_refracIndi_1 ? 2'h1 : 2'h2; // @[ControlUnit.scala 176:32 177:37 63:35]
  wire [1:0] _GEN_131 = 4'h7 == state ? _GEN_47 : 2'h2; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_157 = 4'h6 == state ? _GEN_47 : _GEN_131; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_191 = 4'h5 == state ? _GEN_47 : _GEN_157; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_226 = 4'h4 == state ? _GEN_47 : _GEN_191; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_259 = 4'h3 == state ? 2'h0 : _GEN_226; // @[ControlUnit.scala 100:17 152:33]
  wire [1:0] _GEN_295 = 4'h2 == state ? 2'h2 : _GEN_259; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_331 = 4'h1 == state ? 2'h2 : _GEN_295; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] localCntrSels_1_potSel = 4'h0 == state ? 2'h2 : _GEN_331; // @[ControlUnit.scala 100:17 63:35]
  wire  _GEN_66 = spikeCnt == 10'h0 & io_refracIndi_1; // @[ControlUnit.scala 223:30 67:35]
  wire  _GEN_200 = 4'h5 == state ? 1'h0 : 4'h6 == state & _GEN_66; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_227 = 4'h4 == state ? io_refracIndi_1 : _GEN_200; // @[ControlUnit.scala 100:17]
  wire  _GEN_268 = 4'h3 == state ? 1'h0 : _GEN_227; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_303 = 4'h2 == state ? 1'h0 : _GEN_268; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_339 = 4'h1 == state ? 1'h0 : _GEN_303; // @[ControlUnit.scala 100:17 67:35]
  wire  localCntrSels_1_decaySel = 4'h0 == state ? 1'h0 : _GEN_339; // @[ControlUnit.scala 100:17 67:35]
  wire [7:0] _evalUnitActive_2_T_2 = _evalUnitActive_0_T + 8'h2; // @[ControlUnit.scala 70:66]
  wire [1:0] _GEN_49 = io_refracIndi_2 ? 2'h1 : 2'h2; // @[ControlUnit.scala 176:32 177:37 63:35]
  wire [1:0] _GEN_132 = 4'h7 == state ? _GEN_49 : 2'h2; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_159 = 4'h6 == state ? _GEN_49 : _GEN_132; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_192 = 4'h5 == state ? _GEN_49 : _GEN_159; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_228 = 4'h4 == state ? _GEN_49 : _GEN_192; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_260 = 4'h3 == state ? 2'h0 : _GEN_228; // @[ControlUnit.scala 100:17 152:33]
  wire [1:0] _GEN_296 = 4'h2 == state ? 2'h2 : _GEN_260; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_332 = 4'h1 == state ? 2'h2 : _GEN_296; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] localCntrSels_2_potSel = 4'h0 == state ? 2'h2 : _GEN_332; // @[ControlUnit.scala 100:17 63:35]
  wire  _GEN_68 = spikeCnt == 10'h0 & io_refracIndi_2; // @[ControlUnit.scala 223:30 67:35]
  wire  _GEN_201 = 4'h5 == state ? 1'h0 : 4'h6 == state & _GEN_68; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_229 = 4'h4 == state ? io_refracIndi_2 : _GEN_201; // @[ControlUnit.scala 100:17]
  wire  _GEN_269 = 4'h3 == state ? 1'h0 : _GEN_229; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_304 = 4'h2 == state ? 1'h0 : _GEN_269; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_340 = 4'h1 == state ? 1'h0 : _GEN_304; // @[ControlUnit.scala 100:17 67:35]
  wire  localCntrSels_2_decaySel = 4'h0 == state ? 1'h0 : _GEN_340; // @[ControlUnit.scala 100:17 67:35]
  wire [7:0] _evalUnitActive_3_T_2 = _evalUnitActive_0_T + 8'h3; // @[ControlUnit.scala 70:66]
  wire [1:0] _GEN_51 = io_refracIndi_3 ? 2'h1 : 2'h2; // @[ControlUnit.scala 176:32 177:37 63:35]
  wire [1:0] _GEN_133 = 4'h7 == state ? _GEN_51 : 2'h2; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_161 = 4'h6 == state ? _GEN_51 : _GEN_133; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_193 = 4'h5 == state ? _GEN_51 : _GEN_161; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_230 = 4'h4 == state ? _GEN_51 : _GEN_193; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_261 = 4'h3 == state ? 2'h0 : _GEN_230; // @[ControlUnit.scala 100:17 152:33]
  wire [1:0] _GEN_297 = 4'h2 == state ? 2'h2 : _GEN_261; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_333 = 4'h1 == state ? 2'h2 : _GEN_297; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] localCntrSels_3_potSel = 4'h0 == state ? 2'h2 : _GEN_333; // @[ControlUnit.scala 100:17 63:35]
  wire  _GEN_70 = spikeCnt == 10'h0 & io_refracIndi_3; // @[ControlUnit.scala 223:30 67:35]
  wire  _GEN_202 = 4'h5 == state ? 1'h0 : 4'h6 == state & _GEN_70; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_231 = 4'h4 == state ? io_refracIndi_3 : _GEN_202; // @[ControlUnit.scala 100:17]
  wire  _GEN_270 = 4'h3 == state ? 1'h0 : _GEN_231; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_305 = 4'h2 == state ? 1'h0 : _GEN_270; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_341 = 4'h1 == state ? 1'h0 : _GEN_305; // @[ControlUnit.scala 100:17 67:35]
  wire  localCntrSels_3_decaySel = 4'h0 == state ? 1'h0 : _GEN_341; // @[ControlUnit.scala 100:17 67:35]
  wire [7:0] _evalUnitActive_4_T_2 = _evalUnitActive_0_T + 8'h4; // @[ControlUnit.scala 70:66]
  wire [1:0] _GEN_53 = io_refracIndi_4 ? 2'h1 : 2'h2; // @[ControlUnit.scala 176:32 177:37 63:35]
  wire [1:0] _GEN_134 = 4'h7 == state ? _GEN_53 : 2'h2; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_163 = 4'h6 == state ? _GEN_53 : _GEN_134; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_194 = 4'h5 == state ? _GEN_53 : _GEN_163; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_232 = 4'h4 == state ? _GEN_53 : _GEN_194; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_262 = 4'h3 == state ? 2'h0 : _GEN_232; // @[ControlUnit.scala 100:17 152:33]
  wire [1:0] _GEN_298 = 4'h2 == state ? 2'h2 : _GEN_262; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_334 = 4'h1 == state ? 2'h2 : _GEN_298; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] localCntrSels_4_potSel = 4'h0 == state ? 2'h2 : _GEN_334; // @[ControlUnit.scala 100:17 63:35]
  wire  _GEN_72 = spikeCnt == 10'h0 & io_refracIndi_4; // @[ControlUnit.scala 223:30 67:35]
  wire  _GEN_203 = 4'h5 == state ? 1'h0 : 4'h6 == state & _GEN_72; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_233 = 4'h4 == state ? io_refracIndi_4 : _GEN_203; // @[ControlUnit.scala 100:17]
  wire  _GEN_271 = 4'h3 == state ? 1'h0 : _GEN_233; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_306 = 4'h2 == state ? 1'h0 : _GEN_271; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_342 = 4'h1 == state ? 1'h0 : _GEN_306; // @[ControlUnit.scala 100:17 67:35]
  wire  localCntrSels_4_decaySel = 4'h0 == state ? 1'h0 : _GEN_342; // @[ControlUnit.scala 100:17 67:35]
  wire [7:0] _evalUnitActive_5_T_2 = _evalUnitActive_0_T + 8'h5; // @[ControlUnit.scala 70:66]
  wire [1:0] _GEN_55 = io_refracIndi_5 ? 2'h1 : 2'h2; // @[ControlUnit.scala 176:32 177:37 63:35]
  wire [1:0] _GEN_135 = 4'h7 == state ? _GEN_55 : 2'h2; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_165 = 4'h6 == state ? _GEN_55 : _GEN_135; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_195 = 4'h5 == state ? _GEN_55 : _GEN_165; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_234 = 4'h4 == state ? _GEN_55 : _GEN_195; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_263 = 4'h3 == state ? 2'h0 : _GEN_234; // @[ControlUnit.scala 100:17 152:33]
  wire [1:0] _GEN_299 = 4'h2 == state ? 2'h2 : _GEN_263; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_335 = 4'h1 == state ? 2'h2 : _GEN_299; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] localCntrSels_5_potSel = 4'h0 == state ? 2'h2 : _GEN_335; // @[ControlUnit.scala 100:17 63:35]
  wire  _GEN_74 = spikeCnt == 10'h0 & io_refracIndi_5; // @[ControlUnit.scala 223:30 67:35]
  wire  _GEN_204 = 4'h5 == state ? 1'h0 : 4'h6 == state & _GEN_74; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_235 = 4'h4 == state ? io_refracIndi_5 : _GEN_204; // @[ControlUnit.scala 100:17]
  wire  _GEN_272 = 4'h3 == state ? 1'h0 : _GEN_235; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_307 = 4'h2 == state ? 1'h0 : _GEN_272; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_343 = 4'h1 == state ? 1'h0 : _GEN_307; // @[ControlUnit.scala 100:17 67:35]
  wire  localCntrSels_5_decaySel = 4'h0 == state ? 1'h0 : _GEN_343; // @[ControlUnit.scala 100:17 67:35]
  wire [7:0] _evalUnitActive_6_T_2 = _evalUnitActive_0_T + 8'h6; // @[ControlUnit.scala 70:66]
  wire [1:0] _GEN_57 = io_refracIndi_6 ? 2'h1 : 2'h2; // @[ControlUnit.scala 176:32 177:37 63:35]
  wire [1:0] _GEN_136 = 4'h7 == state ? _GEN_57 : 2'h2; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_167 = 4'h6 == state ? _GEN_57 : _GEN_136; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_196 = 4'h5 == state ? _GEN_57 : _GEN_167; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_236 = 4'h4 == state ? _GEN_57 : _GEN_196; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_264 = 4'h3 == state ? 2'h0 : _GEN_236; // @[ControlUnit.scala 100:17 152:33]
  wire [1:0] _GEN_300 = 4'h2 == state ? 2'h2 : _GEN_264; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_336 = 4'h1 == state ? 2'h2 : _GEN_300; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] localCntrSels_6_potSel = 4'h0 == state ? 2'h2 : _GEN_336; // @[ControlUnit.scala 100:17 63:35]
  wire  _GEN_76 = spikeCnt == 10'h0 & io_refracIndi_6; // @[ControlUnit.scala 223:30 67:35]
  wire  _GEN_205 = 4'h5 == state ? 1'h0 : 4'h6 == state & _GEN_76; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_237 = 4'h4 == state ? io_refracIndi_6 : _GEN_205; // @[ControlUnit.scala 100:17]
  wire  _GEN_273 = 4'h3 == state ? 1'h0 : _GEN_237; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_308 = 4'h2 == state ? 1'h0 : _GEN_273; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_344 = 4'h1 == state ? 1'h0 : _GEN_308; // @[ControlUnit.scala 100:17 67:35]
  wire  localCntrSels_6_decaySel = 4'h0 == state ? 1'h0 : _GEN_344; // @[ControlUnit.scala 100:17 67:35]
  wire [7:0] _evalUnitActive_7_T_2 = _evalUnitActive_0_T + 8'h7; // @[ControlUnit.scala 70:66]
  wire [1:0] _GEN_59 = io_refracIndi_7 ? 2'h1 : 2'h2; // @[ControlUnit.scala 176:32 177:37 63:35]
  wire [1:0] _GEN_137 = 4'h7 == state ? _GEN_59 : 2'h2; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_169 = 4'h6 == state ? _GEN_59 : _GEN_137; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_197 = 4'h5 == state ? _GEN_59 : _GEN_169; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_238 = 4'h4 == state ? _GEN_59 : _GEN_197; // @[ControlUnit.scala 100:17]
  wire [1:0] _GEN_265 = 4'h3 == state ? 2'h0 : _GEN_238; // @[ControlUnit.scala 100:17 152:33]
  wire [1:0] _GEN_301 = 4'h2 == state ? 2'h2 : _GEN_265; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] _GEN_337 = 4'h1 == state ? 2'h2 : _GEN_301; // @[ControlUnit.scala 100:17 63:35]
  wire [1:0] localCntrSels_7_potSel = 4'h0 == state ? 2'h2 : _GEN_337; // @[ControlUnit.scala 100:17 63:35]
  wire  _GEN_78 = spikeCnt == 10'h0 & io_refracIndi_7; // @[ControlUnit.scala 223:30 67:35]
  wire  _GEN_206 = 4'h5 == state ? 1'h0 : 4'h6 == state & _GEN_78; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_239 = 4'h4 == state ? io_refracIndi_7 : _GEN_206; // @[ControlUnit.scala 100:17]
  wire  _GEN_274 = 4'h3 == state ? 1'h0 : _GEN_239; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_309 = 4'h2 == state ? 1'h0 : _GEN_274; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_345 = 4'h1 == state ? 1'h0 : _GEN_309; // @[ControlUnit.scala 100:17 67:35]
  wire  localCntrSels_7_decaySel = 4'h0 == state ? 1'h0 : _GEN_345; // @[ControlUnit.scala 100:17 67:35]
  wire  _GEN_40 = io_newTS ? 1'h0 : 1'h1; // @[ControlUnit.scala 103:15 107:22 108:18]
  wire [5:0] _GEN_395 = {{1'd0}, n}; // @[ControlUnit.scala 133:24]
  wire [5:0] _io_addr_pos_T_1 = _GEN_395 + 6'h20; // @[ControlUnit.scala 133:24]
  wire [9:0] _a_T_1 = a + 10'h1; // @[ControlUnit.scala 148:14]
  wire [3:0] _GEN_44 = _T_12 ? 4'h6 : 4'h4; // @[ControlUnit.scala 154:30 155:15 157:15]
  wire [14:0] _io_addr_pos_T_2 = n * 10'h300; // @[ControlUnit.scala 167:27]
  wire [14:0] _GEN_396 = {{5'd0}, io_aData}; // @[ControlUnit.scala 167:40]
  wire [14:0] _io_addr_pos_T_4 = _io_addr_pos_T_2 + _GEN_396; // @[ControlUnit.scala 167:40]
  wire [3:0] _GEN_61 = spikeCnt == a ? 4'h6 : 4'h5; // @[ControlUnit.scala 182:28 183:15 185:15]
  wire [9:0] _T_9 = a - 10'h1; // @[ControlUnit.scala 209:27]
  wire [3:0] _GEN_62 = spikeCnt == _T_9 ? 4'h6 : 4'h5; // @[ControlUnit.scala 209:34 210:15 212:15]
  wire [4:0] nNext = n + 5'h1; // @[ControlUnit.scala 306:21]
  wire [7:0] _T_18 = {nNext, 3'h0}; // @[ControlUnit.scala 308:19]
  wire [3:0] _GEN_79 = _T_18 >= 8'hc8 ? 4'h0 : 4'h1; // @[ControlUnit.scala 308:58 309:15 311:15]
  wire [1:0] _GEN_81 = 4'hb == state ? 2'h1 : 2'h0; // @[ControlUnit.scala 100:17 299:19 89:15]
  wire [5:0] _GEN_82 = 4'hb == state ? _io_addr_pos_T_1 : 6'h0; // @[ControlUnit.scala 100:17 300:19 90:15]
  wire [9:0] _GEN_83 = 4'hb == state ? 10'h0 : a; // @[ControlUnit.scala 100:17 305:9 47:22]
  wire [4:0] _GEN_84 = 4'hb == state ? nNext : n; // @[ControlUnit.scala 100:17 307:9 45:22]
  wire [3:0] _GEN_85 = 4'hb == state ? _GEN_79 : state; // @[ControlUnit.scala 100:17 36:22]
  wire  _GEN_86 = 4'ha == state | 4'hb == state; // @[ControlUnit.scala 100:17 287:20]
  wire [1:0] _GEN_88 = 4'ha == state ? 2'h0 : _GEN_81; // @[ControlUnit.scala 100:17 289:19]
  wire [5:0] _GEN_89 = 4'ha == state ? 6'h0 : _GEN_82; // @[ControlUnit.scala 100:17 290:19]
  wire [3:0] _GEN_90 = 4'ha == state ? 4'hb : _GEN_85; // @[ControlUnit.scala 100:17 292:17]
  wire [9:0] _GEN_91 = 4'ha == state ? a : _GEN_83; // @[ControlUnit.scala 100:17 47:22]
  wire [4:0] _GEN_92 = 4'ha == state ? n : _GEN_84; // @[ControlUnit.scala 100:17 45:22]
  wire  _GEN_93 = 4'h9 == state | _GEN_86; // @[ControlUnit.scala 100:17 272:19]
  wire  _GEN_94 = 4'h9 == state | _GEN_87; // @[ControlUnit.scala 100:17 273:19]
  wire [1:0] _GEN_95 = 4'h9 == state ? 2'h1 : _GEN_88; // @[ControlUnit.scala 100:17 274:19]
  wire [5:0] _GEN_96 = 4'h9 == state ? {{1'd0}, n} : _GEN_89; // @[ControlUnit.scala 100:17 275:19]
  wire  _GEN_98 = 4'h9 == state & io_spikeIndi_0; // @[ControlUnit.scala 100:17 279:23 62:35]
  wire  _GEN_99 = 4'h9 == state & io_spikeIndi_1; // @[ControlUnit.scala 100:17 279:23 62:35]
  wire  _GEN_100 = 4'h9 == state & io_spikeIndi_2; // @[ControlUnit.scala 100:17 279:23 62:35]
  wire  _GEN_101 = 4'h9 == state & io_spikeIndi_3; // @[ControlUnit.scala 100:17 279:23 62:35]
  wire  _GEN_102 = 4'h9 == state & io_spikeIndi_4; // @[ControlUnit.scala 100:17 279:23 62:35]
  wire  _GEN_103 = 4'h9 == state & io_spikeIndi_5; // @[ControlUnit.scala 100:17 279:23 62:35]
  wire  _GEN_104 = 4'h9 == state & io_spikeIndi_6; // @[ControlUnit.scala 100:17 279:23 62:35]
  wire  _GEN_105 = 4'h9 == state & io_spikeIndi_7; // @[ControlUnit.scala 100:17 279:23 62:35]
  wire [3:0] _GEN_106 = 4'h9 == state ? 4'ha : _GEN_90; // @[ControlUnit.scala 100:17 282:13]
  wire [9:0] _GEN_107 = 4'h9 == state ? a : _GEN_91; // @[ControlUnit.scala 100:17 47:22]
  wire [4:0] _GEN_108 = 4'h9 == state ? n : _GEN_92; // @[ControlUnit.scala 100:17 45:22]
  wire  _GEN_109 = 4'h8 == state | _GEN_93; // @[ControlUnit.scala 100:17 259:19]
  wire  _GEN_110 = 4'h8 == state ? 1'h0 : _GEN_94; // @[ControlUnit.scala 100:17 260:19]
  wire [1:0] _GEN_111 = 4'h8 == state ? 2'h0 : _GEN_95; // @[ControlUnit.scala 100:17 261:19]
  wire [5:0] _GEN_112 = 4'h8 == state ? 6'h1 : _GEN_96; // @[ControlUnit.scala 100:17 262:19]
  wire [3:0] _GEN_114 = 4'h8 == state ? 4'h9 : _GEN_106; // @[ControlUnit.scala 100:17 267:13]
  wire  _GEN_116 = 4'h8 == state ? 1'h0 : _GEN_98; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_117 = 4'h8 == state ? 1'h0 : _GEN_99; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_118 = 4'h8 == state ? 1'h0 : _GEN_100; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_119 = 4'h8 == state ? 1'h0 : _GEN_101; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_120 = 4'h8 == state ? 1'h0 : _GEN_102; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_121 = 4'h8 == state ? 1'h0 : _GEN_103; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_122 = 4'h8 == state ? 1'h0 : _GEN_104; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_123 = 4'h8 == state ? 1'h0 : _GEN_105; // @[ControlUnit.scala 100:17 62:35]
  wire [9:0] _GEN_124 = 4'h8 == state ? a : _GEN_107; // @[ControlUnit.scala 100:17 47:22]
  wire [4:0] _GEN_125 = 4'h8 == state ? n : _GEN_108; // @[ControlUnit.scala 100:17 45:22]
  wire  _GEN_126 = 4'h7 == state | _GEN_109; // @[ControlUnit.scala 100:17 243:20]
  wire  _GEN_127 = 4'h7 == state ? 1'h0 : _GEN_110; // @[ControlUnit.scala 100:17 244:20]
  wire [1:0] _GEN_128 = 4'h7 == state ? 2'h2 : _GEN_111; // @[ControlUnit.scala 100:17 245:20]
  wire [5:0] _GEN_129 = 4'h7 == state ? _io_addr_pos_T_1 : _GEN_112; // @[ControlUnit.scala 100:17 246:20]
  wire [3:0] _GEN_138 = 4'h7 == state ? 4'h8 : _GEN_114; // @[ControlUnit.scala 100:17 254:13]
  wire  _GEN_141 = 4'h7 == state ? 1'h0 : _GEN_116; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_142 = 4'h7 == state ? 1'h0 : _GEN_117; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_143 = 4'h7 == state ? 1'h0 : _GEN_118; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_144 = 4'h7 == state ? 1'h0 : _GEN_119; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_145 = 4'h7 == state ? 1'h0 : _GEN_120; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_146 = 4'h7 == state ? 1'h0 : _GEN_121; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_147 = 4'h7 == state ? 1'h0 : _GEN_122; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_148 = 4'h7 == state ? 1'h0 : _GEN_123; // @[ControlUnit.scala 100:17 62:35]
  wire [9:0] _GEN_149 = 4'h7 == state ? a : _GEN_124; // @[ControlUnit.scala 100:17 47:22]
  wire [4:0] _GEN_150 = 4'h7 == state ? n : _GEN_125; // @[ControlUnit.scala 100:17 45:22]
  wire  _GEN_151 = 4'h6 == state | _GEN_126; // @[ControlUnit.scala 100:17 218:19]
  wire  _GEN_152 = 4'h6 == state ? 1'h0 : _GEN_127; // @[ControlUnit.scala 100:17 219:19]
  wire [1:0] _GEN_153 = 4'h6 == state ? 2'h2 : _GEN_128; // @[ControlUnit.scala 100:17 220:19]
  wire [5:0] _GEN_154 = 4'h6 == state ? {{1'd0}, n} : _GEN_129; // @[ControlUnit.scala 100:17 221:19]
  wire [3:0] _GEN_171 = 4'h6 == state ? 4'h7 : _GEN_138; // @[ControlUnit.scala 100:17 238:13]
  wire  _GEN_174 = 4'h6 == state ? 1'h0 : _GEN_141; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_175 = 4'h6 == state ? 1'h0 : _GEN_142; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_176 = 4'h6 == state ? 1'h0 : _GEN_143; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_177 = 4'h6 == state ? 1'h0 : _GEN_144; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_178 = 4'h6 == state ? 1'h0 : _GEN_145; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_179 = 4'h6 == state ? 1'h0 : _GEN_146; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_180 = 4'h6 == state ? 1'h0 : _GEN_147; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_181 = 4'h6 == state ? 1'h0 : _GEN_148; // @[ControlUnit.scala 100:17 62:35]
  wire [9:0] _GEN_182 = 4'h6 == state ? a : _GEN_149; // @[ControlUnit.scala 100:17 47:22]
  wire [4:0] _GEN_183 = 4'h6 == state ? n : _GEN_150; // @[ControlUnit.scala 100:17 45:22]
  wire  _GEN_184 = 4'h5 == state | _GEN_151; // @[ControlUnit.scala 100:17 191:19]
  wire  _GEN_185 = 4'h5 == state ? 1'h0 : _GEN_152; // @[ControlUnit.scala 100:17 192:19]
  wire [1:0] _GEN_186 = 4'h5 == state ? 2'h3 : _GEN_153; // @[ControlUnit.scala 100:17 193:19]
  wire [14:0] _GEN_187 = 4'h5 == state ? _io_addr_pos_T_4 : {{9'd0}, _GEN_154}; // @[ControlUnit.scala 100:17 195:21]
  wire [9:0] _GEN_188 = 4'h5 == state ? _a_T_1 : _GEN_182; // @[ControlUnit.scala 100:17 200:9]
  wire [3:0] _GEN_198 = 4'h5 == state ? _GEN_62 : _GEN_171; // @[ControlUnit.scala 100:17]
  wire  _GEN_209 = 4'h5 == state ? 1'h0 : _GEN_174; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_210 = 4'h5 == state ? 1'h0 : _GEN_175; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_211 = 4'h5 == state ? 1'h0 : _GEN_176; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_212 = 4'h5 == state ? 1'h0 : _GEN_177; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_213 = 4'h5 == state ? 1'h0 : _GEN_178; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_214 = 4'h5 == state ? 1'h0 : _GEN_179; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_215 = 4'h5 == state ? 1'h0 : _GEN_180; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_216 = 4'h5 == state ? 1'h0 : _GEN_181; // @[ControlUnit.scala 100:17 62:35]
  wire [4:0] _GEN_217 = 4'h5 == state ? n : _GEN_183; // @[ControlUnit.scala 100:17 45:22]
  wire  _GEN_218 = 4'h4 == state | _GEN_184; // @[ControlUnit.scala 100:17 163:19]
  wire  _GEN_219 = 4'h4 == state ? 1'h0 : _GEN_185; // @[ControlUnit.scala 100:17 164:19]
  wire [1:0] _GEN_220 = 4'h4 == state ? 2'h3 : _GEN_186; // @[ControlUnit.scala 100:17 165:19]
  wire [14:0] _GEN_221 = 4'h4 == state ? _io_addr_pos_T_4 : _GEN_187; // @[ControlUnit.scala 100:17 167:21]
  wire  _GEN_222 = 4'h4 == state | 4'h5 == state; // @[ControlUnit.scala 100:17 172:15]
  wire [9:0] _GEN_223 = 4'h4 == state ? _a_T_1 : _GEN_188; // @[ControlUnit.scala 100:17 173:9]
  wire [3:0] _GEN_240 = 4'h4 == state ? _GEN_61 : _GEN_198; // @[ControlUnit.scala 100:17]
  wire  _GEN_243 = 4'h4 == state ? 1'h0 : _GEN_209; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_244 = 4'h4 == state ? 1'h0 : _GEN_210; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_245 = 4'h4 == state ? 1'h0 : _GEN_211; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_246 = 4'h4 == state ? 1'h0 : _GEN_212; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_247 = 4'h4 == state ? 1'h0 : _GEN_213; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_248 = 4'h4 == state ? 1'h0 : _GEN_214; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_249 = 4'h4 == state ? 1'h0 : _GEN_215; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_250 = 4'h4 == state ? 1'h0 : _GEN_216; // @[ControlUnit.scala 100:17 62:35]
  wire [4:0] _GEN_251 = 4'h4 == state ? n : _GEN_217; // @[ControlUnit.scala 100:17 45:22]
  wire  _GEN_252 = 4'h3 == state | _GEN_218; // @[ControlUnit.scala 100:17 143:19]
  wire  _GEN_253 = 4'h3 == state ? 1'h0 : _GEN_219; // @[ControlUnit.scala 100:17 144:19]
  wire [1:0] _GEN_254 = 4'h3 == state ? 2'h0 : _GEN_220; // @[ControlUnit.scala 100:17 145:19]
  wire [14:0] _GEN_255 = 4'h3 == state ? 15'h2 : _GEN_221; // @[ControlUnit.scala 100:17 146:19]
  wire [9:0] _GEN_256 = 4'h3 == state ? _a_T_1 : _GEN_223; // @[ControlUnit.scala 100:17 148:9]
  wire  _GEN_257 = 4'h3 == state | _GEN_222; // @[ControlUnit.scala 100:17 149:15]
  wire [3:0] _GEN_266 = 4'h3 == state ? _GEN_44 : _GEN_240; // @[ControlUnit.scala 100:17]
  wire  _GEN_277 = 4'h3 == state ? 1'h0 : _GEN_243; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_278 = 4'h3 == state ? 1'h0 : _GEN_244; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_279 = 4'h3 == state ? 1'h0 : _GEN_245; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_280 = 4'h3 == state ? 1'h0 : _GEN_246; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_281 = 4'h3 == state ? 1'h0 : _GEN_247; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_282 = 4'h3 == state ? 1'h0 : _GEN_248; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_283 = 4'h3 == state ? 1'h0 : _GEN_249; // @[ControlUnit.scala 100:17 62:35]
  wire  _GEN_284 = 4'h3 == state ? 1'h0 : _GEN_250; // @[ControlUnit.scala 100:17 62:35]
  wire [4:0] _GEN_285 = 4'h3 == state ? n : _GEN_251; // @[ControlUnit.scala 100:17 45:22]
  wire  _GEN_286 = 4'h2 == state | _GEN_252; // @[ControlUnit.scala 100:17 130:19]
  wire  _GEN_287 = 4'h2 == state ? 1'h0 : _GEN_253; // @[ControlUnit.scala 100:17 131:19]
  wire [1:0] _GEN_288 = 4'h2 == state ? 2'h1 : _GEN_254; // @[ControlUnit.scala 100:17 132:19]
  wire [14:0] _GEN_289 = 4'h2 == state ? {{9'd0}, _io_addr_pos_T_1} : _GEN_255; // @[ControlUnit.scala 100:17 133:19]
  wire  _GEN_293 = 4'h2 == state ? 1'h0 : _GEN_257; // @[ControlUnit.scala 100:17 96:11]
  wire  _GEN_321 = 4'h1 == state | _GEN_286; // @[ControlUnit.scala 100:17 117:19]
  wire  _GEN_322 = 4'h1 == state ? 1'h0 : _GEN_287; // @[ControlUnit.scala 100:17 118:19]
  wire [1:0] _GEN_323 = 4'h1 == state ? 2'h1 : _GEN_288; // @[ControlUnit.scala 100:17 119:19]
  wire [14:0] _GEN_324 = 4'h1 == state ? {{10'd0}, n} : _GEN_289; // @[ControlUnit.scala 100:17 120:19]
  wire  _GEN_329 = 4'h1 == state ? 1'h0 : _GEN_293; // @[ControlUnit.scala 100:17 96:11]
  assign io_done = 4'h0 == state & _GEN_40; // @[ControlUnit.scala 100:17 99:11]
  assign io_addr_sel = 4'h0 == state ? 2'h0 : _GEN_323; // @[ControlUnit.scala 100:17 89:15]
  assign io_addr_pos = 4'h0 == state ? 15'h0 : _GEN_324; // @[ControlUnit.scala 100:17 90:15]
  assign io_wr = 4'h0 == state ? 1'h0 : _GEN_322; // @[ControlUnit.scala 100:17 92:10]
  assign io_ena = 4'h0 == state ? 1'h0 : _GEN_321; // @[ControlUnit.scala 100:17 91:10]
  assign io_cntrSels_0_potSel = evalUnitActive_0 ? localCntrSels_0_potSel : 2'h2; // @[ControlUnit.scala 71:29 72:35 78:35]
  assign io_cntrSels_0_spikeSel = evalUnitActive_0 ? localCntrSels_0_spikeSel : 2'h2; // @[ControlUnit.scala 71:29 73:35 79:35]
  assign io_cntrSels_0_refracSel = evalUnitActive_0 ? localCntrSels_0_refracSel : 1'h1; // @[ControlUnit.scala 71:29 74:35 80:35]
  assign io_cntrSels_0_decaySel = evalUnitActive_0 & localCntrSels_0_decaySel; // @[ControlUnit.scala 71:29 76:35 82:35]
  assign io_cntrSels_0_writeDataSel = evalUnitActive_0 ? localCntrSels_0_writeDataSel : 2'h0; // @[ControlUnit.scala 71:29 75:35 81:35]
  assign io_cntrSels_1_potSel = evalUnitActive_1 ? localCntrSels_1_potSel : 2'h2; // @[ControlUnit.scala 71:29 72:35 78:35]
  assign io_cntrSels_1_spikeSel = evalUnitActive_1 ? localCntrSels_0_spikeSel : 2'h2; // @[ControlUnit.scala 71:29 73:35 79:35]
  assign io_cntrSels_1_refracSel = evalUnitActive_1 ? localCntrSels_0_refracSel : 1'h1; // @[ControlUnit.scala 71:29 74:35 80:35]
  assign io_cntrSels_1_decaySel = evalUnitActive_1 & localCntrSels_1_decaySel; // @[ControlUnit.scala 71:29 76:35 82:35]
  assign io_cntrSels_1_writeDataSel = evalUnitActive_1 ? localCntrSels_0_writeDataSel : 2'h0; // @[ControlUnit.scala 71:29 75:35 81:35]
  assign io_cntrSels_2_potSel = evalUnitActive_2 ? localCntrSels_2_potSel : 2'h2; // @[ControlUnit.scala 71:29 72:35 78:35]
  assign io_cntrSels_2_spikeSel = evalUnitActive_2 ? localCntrSels_0_spikeSel : 2'h2; // @[ControlUnit.scala 71:29 73:35 79:35]
  assign io_cntrSels_2_refracSel = evalUnitActive_2 ? localCntrSels_0_refracSel : 1'h1; // @[ControlUnit.scala 71:29 74:35 80:35]
  assign io_cntrSels_2_decaySel = evalUnitActive_2 & localCntrSels_2_decaySel; // @[ControlUnit.scala 71:29 76:35 82:35]
  assign io_cntrSels_2_writeDataSel = evalUnitActive_2 ? localCntrSels_0_writeDataSel : 2'h0; // @[ControlUnit.scala 71:29 75:35 81:35]
  assign io_cntrSels_3_potSel = evalUnitActive_3 ? localCntrSels_3_potSel : 2'h2; // @[ControlUnit.scala 71:29 72:35 78:35]
  assign io_cntrSels_3_spikeSel = evalUnitActive_3 ? localCntrSels_0_spikeSel : 2'h2; // @[ControlUnit.scala 71:29 73:35 79:35]
  assign io_cntrSels_3_refracSel = evalUnitActive_3 ? localCntrSels_0_refracSel : 1'h1; // @[ControlUnit.scala 71:29 74:35 80:35]
  assign io_cntrSels_3_decaySel = evalUnitActive_3 & localCntrSels_3_decaySel; // @[ControlUnit.scala 71:29 76:35 82:35]
  assign io_cntrSels_3_writeDataSel = evalUnitActive_3 ? localCntrSels_0_writeDataSel : 2'h0; // @[ControlUnit.scala 71:29 75:35 81:35]
  assign io_cntrSels_4_potSel = evalUnitActive_4 ? localCntrSels_4_potSel : 2'h2; // @[ControlUnit.scala 71:29 72:35 78:35]
  assign io_cntrSels_4_spikeSel = evalUnitActive_4 ? localCntrSels_0_spikeSel : 2'h2; // @[ControlUnit.scala 71:29 73:35 79:35]
  assign io_cntrSels_4_refracSel = evalUnitActive_4 ? localCntrSels_0_refracSel : 1'h1; // @[ControlUnit.scala 71:29 74:35 80:35]
  assign io_cntrSels_4_decaySel = evalUnitActive_4 & localCntrSels_4_decaySel; // @[ControlUnit.scala 71:29 76:35 82:35]
  assign io_cntrSels_4_writeDataSel = evalUnitActive_4 ? localCntrSels_0_writeDataSel : 2'h0; // @[ControlUnit.scala 71:29 75:35 81:35]
  assign io_cntrSels_5_potSel = evalUnitActive_5 ? localCntrSels_5_potSel : 2'h2; // @[ControlUnit.scala 71:29 72:35 78:35]
  assign io_cntrSels_5_spikeSel = evalUnitActive_5 ? localCntrSels_0_spikeSel : 2'h2; // @[ControlUnit.scala 71:29 73:35 79:35]
  assign io_cntrSels_5_refracSel = evalUnitActive_5 ? localCntrSels_0_refracSel : 1'h1; // @[ControlUnit.scala 71:29 74:35 80:35]
  assign io_cntrSels_5_decaySel = evalUnitActive_5 & localCntrSels_5_decaySel; // @[ControlUnit.scala 71:29 76:35 82:35]
  assign io_cntrSels_5_writeDataSel = evalUnitActive_5 ? localCntrSels_0_writeDataSel : 2'h0; // @[ControlUnit.scala 71:29 75:35 81:35]
  assign io_cntrSels_6_potSel = evalUnitActive_6 ? localCntrSels_6_potSel : 2'h2; // @[ControlUnit.scala 71:29 72:35 78:35]
  assign io_cntrSels_6_spikeSel = evalUnitActive_6 ? localCntrSels_0_spikeSel : 2'h2; // @[ControlUnit.scala 71:29 73:35 79:35]
  assign io_cntrSels_6_refracSel = evalUnitActive_6 ? localCntrSels_0_refracSel : 1'h1; // @[ControlUnit.scala 71:29 74:35 80:35]
  assign io_cntrSels_6_decaySel = evalUnitActive_6 & localCntrSels_6_decaySel; // @[ControlUnit.scala 71:29 76:35 82:35]
  assign io_cntrSels_6_writeDataSel = evalUnitActive_6 ? localCntrSels_0_writeDataSel : 2'h0; // @[ControlUnit.scala 71:29 75:35 81:35]
  assign io_cntrSels_7_potSel = evalUnitActive_7 ? localCntrSels_7_potSel : 2'h2; // @[ControlUnit.scala 71:29 72:35 78:35]
  assign io_cntrSels_7_spikeSel = evalUnitActive_7 ? localCntrSels_0_spikeSel : 2'h2; // @[ControlUnit.scala 71:29 73:35 79:35]
  assign io_cntrSels_7_refracSel = evalUnitActive_7 ? localCntrSels_0_refracSel : 1'h1; // @[ControlUnit.scala 71:29 74:35 80:35]
  assign io_cntrSels_7_decaySel = evalUnitActive_7 & localCntrSels_7_decaySel; // @[ControlUnit.scala 71:29 76:35 82:35]
  assign io_cntrSels_7_writeDataSel = evalUnitActive_7 ? localCntrSels_0_writeDataSel : 2'h0; // @[ControlUnit.scala 71:29 75:35 81:35]
  assign io_evalEnable = 4'h0 == state ? 1'h0 : 1'h1; // @[ControlUnit.scala 100:17 106:21 94:17]
  assign io_inOut = inOut; // @[ControlUnit.scala 53:12]
  assign io_aAddr = a; // @[ControlUnit.scala 48:12]
  assign io_aEna = 4'h0 == state ? 1'h0 : _GEN_329; // @[ControlUnit.scala 100:17 96:11]
  assign io_n = n; // @[ControlUnit.scala 46:12]
  assign io_spikes_0 = spikePulse_0; // @[ControlUnit.scala 86:18]
  assign io_spikes_1 = spikePulse_1; // @[ControlUnit.scala 86:18]
  assign io_spikes_2 = spikePulse_2; // @[ControlUnit.scala 86:18]
  assign io_spikes_3 = spikePulse_3; // @[ControlUnit.scala 86:18]
  assign io_spikes_4 = spikePulse_4; // @[ControlUnit.scala 86:18]
  assign io_spikes_5 = spikePulse_5; // @[ControlUnit.scala 86:18]
  assign io_spikes_6 = spikePulse_6; // @[ControlUnit.scala 86:18]
  assign io_spikes_7 = spikePulse_7; // @[ControlUnit.scala 86:18]
  always @(posedge clock) begin
    if (reset) begin // @[ControlUnit.scala 36:22]
      state <= 4'h0; // @[ControlUnit.scala 36:22]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      if (io_newTS) begin // @[ControlUnit.scala 107:22]
        state <= 4'h1; // @[ControlUnit.scala 111:18]
      end
    end else if (4'h1 == state) begin // @[ControlUnit.scala 100:17]
      state <= 4'h2; // @[ControlUnit.scala 125:13]
    end else if (4'h2 == state) begin // @[ControlUnit.scala 100:17]
      state <= 4'h3; // @[ControlUnit.scala 138:13]
    end else begin
      state <= _GEN_266;
    end
    if (reset) begin // @[ControlUnit.scala 42:27]
      spikePulse_0 <= 1'h0; // @[ControlUnit.scala 42:27]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_0 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h1 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_0 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h2 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_0 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else begin
      spikePulse_0 <= _GEN_277;
    end
    if (reset) begin // @[ControlUnit.scala 42:27]
      spikePulse_1 <= 1'h0; // @[ControlUnit.scala 42:27]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_1 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h1 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_1 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h2 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_1 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else begin
      spikePulse_1 <= _GEN_278;
    end
    if (reset) begin // @[ControlUnit.scala 42:27]
      spikePulse_2 <= 1'h0; // @[ControlUnit.scala 42:27]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_2 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h1 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_2 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h2 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_2 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else begin
      spikePulse_2 <= _GEN_279;
    end
    if (reset) begin // @[ControlUnit.scala 42:27]
      spikePulse_3 <= 1'h0; // @[ControlUnit.scala 42:27]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_3 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h1 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_3 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h2 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_3 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else begin
      spikePulse_3 <= _GEN_280;
    end
    if (reset) begin // @[ControlUnit.scala 42:27]
      spikePulse_4 <= 1'h0; // @[ControlUnit.scala 42:27]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_4 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h1 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_4 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h2 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_4 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else begin
      spikePulse_4 <= _GEN_281;
    end
    if (reset) begin // @[ControlUnit.scala 42:27]
      spikePulse_5 <= 1'h0; // @[ControlUnit.scala 42:27]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_5 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h1 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_5 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h2 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_5 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else begin
      spikePulse_5 <= _GEN_282;
    end
    if (reset) begin // @[ControlUnit.scala 42:27]
      spikePulse_6 <= 1'h0; // @[ControlUnit.scala 42:27]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_6 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h1 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_6 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h2 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_6 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else begin
      spikePulse_6 <= _GEN_283;
    end
    if (reset) begin // @[ControlUnit.scala 42:27]
      spikePulse_7 <= 1'h0; // @[ControlUnit.scala 42:27]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_7 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h1 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_7 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else if (4'h2 == state) begin // @[ControlUnit.scala 100:17]
      spikePulse_7 <= 1'h0; // @[ControlUnit.scala 62:35]
    end else begin
      spikePulse_7 <= _GEN_284;
    end
    if (reset) begin // @[ControlUnit.scala 45:22]
      n <= 5'h0; // @[ControlUnit.scala 45:22]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      n <= 5'h0; // @[ControlUnit.scala 104:9]
    end else if (!(4'h1 == state)) begin // @[ControlUnit.scala 100:17]
      if (!(4'h2 == state)) begin // @[ControlUnit.scala 100:17]
        n <= _GEN_285;
      end
    end
    if (reset) begin // @[ControlUnit.scala 47:22]
      a <= 10'h0; // @[ControlUnit.scala 47:22]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      a <= 10'h0; // @[ControlUnit.scala 105:9]
    end else if (!(4'h1 == state)) begin // @[ControlUnit.scala 100:17]
      if (!(4'h2 == state)) begin // @[ControlUnit.scala 100:17]
        a <= _GEN_256;
      end
    end
    if (reset) begin // @[ControlUnit.scala 50:25]
      spikeCnt <= 10'h0; // @[ControlUnit.scala 50:25]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      if (io_newTS) begin // @[ControlUnit.scala 107:22]
        spikeCnt <= io_spikeCnt; // @[ControlUnit.scala 109:18]
      end
    end
    if (reset) begin // @[ControlUnit.scala 52:22]
      inOut <= 1'h0; // @[ControlUnit.scala 52:22]
    end else if (4'h0 == state) begin // @[ControlUnit.scala 100:17]
      if (io_newTS) begin // @[ControlUnit.scala 107:22]
        inOut <= ~inOut; // @[ControlUnit.scala 110:18]
      end
    end
    if (reset) begin // @[ControlUnit.scala 55:31]
      evalUnitActive_0 <= 1'h0; // @[ControlUnit.scala 55:31]
    end else begin
      evalUnitActive_0 <= 8'hc8 > _evalUnitActive_0_T_1[7:0]; // @[ControlUnit.scala 70:23]
    end
    if (reset) begin // @[ControlUnit.scala 55:31]
      evalUnitActive_1 <= 1'h0; // @[ControlUnit.scala 55:31]
    end else begin
      evalUnitActive_1 <= 8'hc8 > _evalUnitActive_1_T_2; // @[ControlUnit.scala 70:23]
    end
    if (reset) begin // @[ControlUnit.scala 55:31]
      evalUnitActive_2 <= 1'h0; // @[ControlUnit.scala 55:31]
    end else begin
      evalUnitActive_2 <= 8'hc8 > _evalUnitActive_2_T_2; // @[ControlUnit.scala 70:23]
    end
    if (reset) begin // @[ControlUnit.scala 55:31]
      evalUnitActive_3 <= 1'h0; // @[ControlUnit.scala 55:31]
    end else begin
      evalUnitActive_3 <= 8'hc8 > _evalUnitActive_3_T_2; // @[ControlUnit.scala 70:23]
    end
    if (reset) begin // @[ControlUnit.scala 55:31]
      evalUnitActive_4 <= 1'h0; // @[ControlUnit.scala 55:31]
    end else begin
      evalUnitActive_4 <= 8'hc8 > _evalUnitActive_4_T_2; // @[ControlUnit.scala 70:23]
    end
    if (reset) begin // @[ControlUnit.scala 55:31]
      evalUnitActive_5 <= 1'h0; // @[ControlUnit.scala 55:31]
    end else begin
      evalUnitActive_5 <= 8'hc8 > _evalUnitActive_5_T_2; // @[ControlUnit.scala 70:23]
    end
    if (reset) begin // @[ControlUnit.scala 55:31]
      evalUnitActive_6 <= 1'h0; // @[ControlUnit.scala 55:31]
    end else begin
      evalUnitActive_6 <= 8'hc8 > _evalUnitActive_6_T_2; // @[ControlUnit.scala 70:23]
    end
    if (reset) begin // @[ControlUnit.scala 55:31]
      evalUnitActive_7 <= 1'h0; // @[ControlUnit.scala 55:31]
    end else begin
      evalUnitActive_7 <= 8'hc8 > _evalUnitActive_7_T_2; // @[ControlUnit.scala 70:23]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  state = _RAND_0[3:0];
  _RAND_1 = {1{`RANDOM}};
  spikePulse_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  spikePulse_1 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  spikePulse_2 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  spikePulse_3 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  spikePulse_4 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  spikePulse_5 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  spikePulse_6 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  spikePulse_7 = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  n = _RAND_9[4:0];
  _RAND_10 = {1{`RANDOM}};
  a = _RAND_10[9:0];
  _RAND_11 = {1{`RANDOM}};
  spikeCnt = _RAND_11[9:0];
  _RAND_12 = {1{`RANDOM}};
  inOut = _RAND_12[0:0];
  _RAND_13 = {1{`RANDOM}};
  evalUnitActive_0 = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  evalUnitActive_1 = _RAND_14[0:0];
  _RAND_15 = {1{`RANDOM}};
  evalUnitActive_2 = _RAND_15[0:0];
  _RAND_16 = {1{`RANDOM}};
  evalUnitActive_3 = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  evalUnitActive_4 = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  evalUnitActive_5 = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  evalUnitActive_6 = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  evalUnitActive_7 = _RAND_20[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module NeuronEvaluator(
  input         clock,
  input         reset,
  input  [16:0] io_dataIn,
  output [16:0] io_dataOut,
  output        io_spikeIndi,
  output        io_refracIndi,
  input  [1:0]  io_cntrSels_potSel,
  input  [1:0]  io_cntrSels_spikeSel,
  input         io_cntrSels_refracSel,
  input         io_cntrSels_decaySel,
  input  [1:0]  io_cntrSels_writeDataSel,
  input         io_evalEnable
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  reg [16:0] membPotReg; // @[Reg.scala 28:20]
  wire [17:0] sumIn1 = {{1{membPotReg[16]}},membPotReg}; // @[NeuronEvaluator.scala 21:30 34:14]
  wire [16:0] potDecay = $signed(membPotReg) >>> io_dataIn[2:0]; // @[NeuronEvaluator.scala 73:26]
  wire [16:0] _sumIn2_T_2 = 17'sh0 - $signed(potDecay); // @[NeuronEvaluator.scala 35:43]
  wire [16:0] _sumIn2_T_3 = io_cntrSels_decaySel ? $signed(_sumIn2_T_2) : $signed(io_dataIn); // @[NeuronEvaluator.scala 35:20]
  wire [17:0] sumIn2 = {{1{_sumIn2_T_3[16]}},_sumIn2_T_3}; // @[NeuronEvaluator.scala 22:30 35:14]
  wire [17:0] sum = $signed(sumIn1) + $signed(sumIn2); // @[NeuronEvaluator.scala 36:24]
  wire [17:0] _GEN_3 = $signed(sum) > 18'shffff ? $signed(18'shffff) : $signed(sum); // @[NeuronEvaluator.scala 44:53 45:12 47:12]
  wire [17:0] _GEN_4 = $signed(sum) < -18'sh10000 ? $signed(-18'sh10000) : $signed(_GEN_3); // @[NeuronEvaluator.scala 42:47 43:12]
  wire [16:0] sumSat = _GEN_4[16:0]; // @[NeuronEvaluator.scala 20:30]
  reg [16:0] refracCntReg; // @[Reg.scala 16:16]
  wire [16:0] refracRegNext = ~io_cntrSels_refracSel ? $signed(io_dataIn) : $signed(refracCntReg); // @[NeuronEvaluator.scala 76:23]
  reg  spikeIndiReg; // @[Reg.scala 28:20]
  wire [16:0] _GEN_10 = ~spikeIndiReg ? $signed(membPotReg) : $signed(io_dataIn); // @[NeuronEvaluator.scala 94:27 95:20 97:20]
  wire [16:0] _GEN_11 = spikeIndiReg ? $signed(io_dataIn) : $signed(refracCntReg); // @[NeuronEvaluator.scala 102:28 103:22 105:22]
  wire [16:0] _io_dataOut_T_2 = $signed(refracCntReg) - 17'sh1; // @[NeuronEvaluator.scala 108:36]
  wire [16:0] _GEN_12 = io_refracIndi ? $signed(_GEN_11) : $signed(_io_dataOut_T_2); // @[NeuronEvaluator.scala 101:27 108:20]
  wire [16:0] _GEN_13 = 2'h2 == io_cntrSels_writeDataSel ? $signed(_GEN_12) : $signed(io_dataIn); // @[NeuronEvaluator.scala 33:14 89:36]
  wire [16:0] _GEN_14 = 2'h1 == io_cntrSels_writeDataSel ? $signed(_GEN_10) : $signed(_GEN_13); // @[NeuronEvaluator.scala 89:36]
  assign io_dataOut = 2'h0 == io_cntrSels_writeDataSel ? $signed(io_dataIn) : $signed(_GEN_14); // @[NeuronEvaluator.scala 89:36 91:18]
  assign io_spikeIndi = spikeIndiReg; // @[NeuronEvaluator.scala 114:17]
  assign io_refracIndi = $signed(refracRegNext) == 17'sh0; // @[NeuronEvaluator.scala 113:34]
  always @(posedge clock) begin
    if (reset) begin // @[Reg.scala 28:20]
      membPotReg <= 17'sh0; // @[Reg.scala 28:20]
    end else if (io_evalEnable) begin // @[Reg.scala 29:18]
      if (2'h0 == io_cntrSels_potSel) begin // @[NeuronEvaluator.scala 51:30]
        membPotReg <= io_dataIn; // @[NeuronEvaluator.scala 53:22]
      end else if (2'h1 == io_cntrSels_potSel) begin // @[NeuronEvaluator.scala 51:30]
        membPotReg <= sumSat; // @[NeuronEvaluator.scala 56:22]
      end
    end
    if (io_evalEnable) begin // @[Reg.scala 17:18]
      if (~io_cntrSels_refracSel) begin // @[NeuronEvaluator.scala 76:23]
        refracCntReg <= io_dataIn;
      end
    end
    if (reset) begin // @[Reg.scala 28:20]
      spikeIndiReg <= 1'h0; // @[Reg.scala 28:20]
    end else if (io_evalEnable) begin // @[Reg.scala 29:18]
      if (2'h0 == io_cntrSels_spikeSel) begin // @[NeuronEvaluator.scala 79:32]
        spikeIndiReg <= $signed(membPotReg) > $signed(io_dataIn); // @[NeuronEvaluator.scala 81:24]
      end else if (2'h1 == io_cntrSels_spikeSel) begin // @[NeuronEvaluator.scala 79:32]
        spikeIndiReg <= 1'h0; // @[NeuronEvaluator.scala 84:24]
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  membPotReg = _RAND_0[16:0];
  _RAND_1 = {1{`RANDOM}};
  refracCntReg = _RAND_1[16:0];
  _RAND_2 = {1{`RANDOM}};
  spikeIndiReg = _RAND_2[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc2.mem", constmem);
  $readmemb("mapping/meminit/potrefc2.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc2e0.mem", btmem);
  $readmemb("mapping/meminit/weightsc2e0.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_1(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc2.mem", constmem);
  $readmemb("mapping/meminit/potrefc2.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc2e1.mem", btmem);
  $readmemb("mapping/meminit/weightsc2e1.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_2(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc2.mem", constmem);
  $readmemb("mapping/meminit/potrefc2.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc2e2.mem", btmem);
  $readmemb("mapping/meminit/weightsc2e2.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_3(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc2.mem", constmem);
  $readmemb("mapping/meminit/potrefc2.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc2e3.mem", btmem);
  $readmemb("mapping/meminit/weightsc2e3.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_4(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc2.mem", constmem);
  $readmemb("mapping/meminit/potrefc2.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc2e4.mem", btmem);
  $readmemb("mapping/meminit/weightsc2e4.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_5(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc2.mem", constmem);
  $readmemb("mapping/meminit/potrefc2.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc2e5.mem", btmem);
  $readmemb("mapping/meminit/weightsc2e5.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_6(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc2.mem", constmem);
  $readmemb("mapping/meminit/potrefc2.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc2e6.mem", btmem);
  $readmemb("mapping/meminit/weightsc2e6.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_7(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc2.mem", constmem);
  $readmemb("mapping/meminit/potrefc2.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc2e7.mem", btmem);
  $readmemb("mapping/meminit/weightsc2e7.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Neurons(
  input        clock,
  input        reset,
  output       io_done,
  input        io_newTS,
  output       io_inOut,
  input  [9:0] io_spikeCnt,
  output [9:0] io_aAddr,
  output       io_aEna,
  input  [9:0] io_aData,
  output [4:0] io_n,
  output       io_spikes_0,
  output       io_spikes_1,
  output       io_spikes_2,
  output       io_spikes_3,
  output       io_spikes_4,
  output       io_spikes_5,
  output       io_spikes_6,
  output       io_spikes_7
);
  wire  controlUnit_clock; // @[Neurons.scala 22:27]
  wire  controlUnit_reset; // @[Neurons.scala 22:27]
  wire  controlUnit_io_done; // @[Neurons.scala 22:27]
  wire  controlUnit_io_newTS; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_addr_sel; // @[Neurons.scala 22:27]
  wire [14:0] controlUnit_io_addr_pos; // @[Neurons.scala 22:27]
  wire  controlUnit_io_wr; // @[Neurons.scala 22:27]
  wire  controlUnit_io_ena; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_0; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_1; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_2; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_3; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_4; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_5; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_6; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_7; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_0; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_1; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_2; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_3; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_4; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_5; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_6; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_7; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_0_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_0_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_0_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_0_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_0_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_1_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_1_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_1_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_1_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_1_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_2_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_2_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_2_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_2_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_2_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_3_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_3_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_3_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_3_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_3_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_4_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_4_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_4_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_4_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_4_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_5_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_5_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_5_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_5_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_5_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_6_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_6_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_6_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_6_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_6_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_7_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_7_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_7_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_7_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_7_writeDataSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_evalEnable; // @[Neurons.scala 22:27]
  wire  controlUnit_io_inOut; // @[Neurons.scala 22:27]
  wire [9:0] controlUnit_io_spikeCnt; // @[Neurons.scala 22:27]
  wire [9:0] controlUnit_io_aAddr; // @[Neurons.scala 22:27]
  wire  controlUnit_io_aEna; // @[Neurons.scala 22:27]
  wire [9:0] controlUnit_io_aData; // @[Neurons.scala 22:27]
  wire [4:0] controlUnit_io_n; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_0; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_1; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_2; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_3; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_4; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_5; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_6; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_7; // @[Neurons.scala 22:27]
  wire  evalUnits_0_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_0_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_0_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_0_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_0_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_0_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_0_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_0_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_0_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_0_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_0_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_0_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_1_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_1_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_1_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_1_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_1_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_1_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_1_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_1_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_1_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_1_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_1_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_1_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_2_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_2_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_2_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_2_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_2_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_2_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_2_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_2_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_2_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_2_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_2_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_2_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_3_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_3_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_3_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_3_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_3_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_3_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_3_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_3_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_3_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_3_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_3_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_3_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_4_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_4_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_4_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_4_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_4_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_4_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_4_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_4_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_4_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_4_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_4_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_4_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_5_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_5_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_5_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_5_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_5_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_5_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_5_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_5_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_5_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_5_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_5_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_5_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_6_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_6_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_6_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_6_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_6_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_6_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_6_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_6_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_6_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_6_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_6_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_6_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_7_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_7_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_7_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_7_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_7_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_7_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_7_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_7_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_7_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_7_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_7_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_7_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalMems_0_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_0_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_0_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_0_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_0_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_0_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_0_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_1_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_1_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_1_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_1_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_1_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_1_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_1_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_2_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_2_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_2_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_2_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_2_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_2_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_2_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_3_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_3_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_3_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_3_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_3_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_3_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_3_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_4_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_4_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_4_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_4_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_4_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_4_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_4_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_5_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_5_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_5_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_5_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_5_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_5_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_5_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_6_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_6_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_6_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_6_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_6_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_6_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_6_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_7_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_7_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_7_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_7_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_7_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_7_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_7_io_writeData; // @[Neurons.scala 24:56]
  ControlUnit controlUnit ( // @[Neurons.scala 22:27]
    .clock(controlUnit_clock),
    .reset(controlUnit_reset),
    .io_done(controlUnit_io_done),
    .io_newTS(controlUnit_io_newTS),
    .io_addr_sel(controlUnit_io_addr_sel),
    .io_addr_pos(controlUnit_io_addr_pos),
    .io_wr(controlUnit_io_wr),
    .io_ena(controlUnit_io_ena),
    .io_spikeIndi_0(controlUnit_io_spikeIndi_0),
    .io_spikeIndi_1(controlUnit_io_spikeIndi_1),
    .io_spikeIndi_2(controlUnit_io_spikeIndi_2),
    .io_spikeIndi_3(controlUnit_io_spikeIndi_3),
    .io_spikeIndi_4(controlUnit_io_spikeIndi_4),
    .io_spikeIndi_5(controlUnit_io_spikeIndi_5),
    .io_spikeIndi_6(controlUnit_io_spikeIndi_6),
    .io_spikeIndi_7(controlUnit_io_spikeIndi_7),
    .io_refracIndi_0(controlUnit_io_refracIndi_0),
    .io_refracIndi_1(controlUnit_io_refracIndi_1),
    .io_refracIndi_2(controlUnit_io_refracIndi_2),
    .io_refracIndi_3(controlUnit_io_refracIndi_3),
    .io_refracIndi_4(controlUnit_io_refracIndi_4),
    .io_refracIndi_5(controlUnit_io_refracIndi_5),
    .io_refracIndi_6(controlUnit_io_refracIndi_6),
    .io_refracIndi_7(controlUnit_io_refracIndi_7),
    .io_cntrSels_0_potSel(controlUnit_io_cntrSels_0_potSel),
    .io_cntrSels_0_spikeSel(controlUnit_io_cntrSels_0_spikeSel),
    .io_cntrSels_0_refracSel(controlUnit_io_cntrSels_0_refracSel),
    .io_cntrSels_0_decaySel(controlUnit_io_cntrSels_0_decaySel),
    .io_cntrSels_0_writeDataSel(controlUnit_io_cntrSels_0_writeDataSel),
    .io_cntrSels_1_potSel(controlUnit_io_cntrSels_1_potSel),
    .io_cntrSels_1_spikeSel(controlUnit_io_cntrSels_1_spikeSel),
    .io_cntrSels_1_refracSel(controlUnit_io_cntrSels_1_refracSel),
    .io_cntrSels_1_decaySel(controlUnit_io_cntrSels_1_decaySel),
    .io_cntrSels_1_writeDataSel(controlUnit_io_cntrSels_1_writeDataSel),
    .io_cntrSels_2_potSel(controlUnit_io_cntrSels_2_potSel),
    .io_cntrSels_2_spikeSel(controlUnit_io_cntrSels_2_spikeSel),
    .io_cntrSels_2_refracSel(controlUnit_io_cntrSels_2_refracSel),
    .io_cntrSels_2_decaySel(controlUnit_io_cntrSels_2_decaySel),
    .io_cntrSels_2_writeDataSel(controlUnit_io_cntrSels_2_writeDataSel),
    .io_cntrSels_3_potSel(controlUnit_io_cntrSels_3_potSel),
    .io_cntrSels_3_spikeSel(controlUnit_io_cntrSels_3_spikeSel),
    .io_cntrSels_3_refracSel(controlUnit_io_cntrSels_3_refracSel),
    .io_cntrSels_3_decaySel(controlUnit_io_cntrSels_3_decaySel),
    .io_cntrSels_3_writeDataSel(controlUnit_io_cntrSels_3_writeDataSel),
    .io_cntrSels_4_potSel(controlUnit_io_cntrSels_4_potSel),
    .io_cntrSels_4_spikeSel(controlUnit_io_cntrSels_4_spikeSel),
    .io_cntrSels_4_refracSel(controlUnit_io_cntrSels_4_refracSel),
    .io_cntrSels_4_decaySel(controlUnit_io_cntrSels_4_decaySel),
    .io_cntrSels_4_writeDataSel(controlUnit_io_cntrSels_4_writeDataSel),
    .io_cntrSels_5_potSel(controlUnit_io_cntrSels_5_potSel),
    .io_cntrSels_5_spikeSel(controlUnit_io_cntrSels_5_spikeSel),
    .io_cntrSels_5_refracSel(controlUnit_io_cntrSels_5_refracSel),
    .io_cntrSels_5_decaySel(controlUnit_io_cntrSels_5_decaySel),
    .io_cntrSels_5_writeDataSel(controlUnit_io_cntrSels_5_writeDataSel),
    .io_cntrSels_6_potSel(controlUnit_io_cntrSels_6_potSel),
    .io_cntrSels_6_spikeSel(controlUnit_io_cntrSels_6_spikeSel),
    .io_cntrSels_6_refracSel(controlUnit_io_cntrSels_6_refracSel),
    .io_cntrSels_6_decaySel(controlUnit_io_cntrSels_6_decaySel),
    .io_cntrSels_6_writeDataSel(controlUnit_io_cntrSels_6_writeDataSel),
    .io_cntrSels_7_potSel(controlUnit_io_cntrSels_7_potSel),
    .io_cntrSels_7_spikeSel(controlUnit_io_cntrSels_7_spikeSel),
    .io_cntrSels_7_refracSel(controlUnit_io_cntrSels_7_refracSel),
    .io_cntrSels_7_decaySel(controlUnit_io_cntrSels_7_decaySel),
    .io_cntrSels_7_writeDataSel(controlUnit_io_cntrSels_7_writeDataSel),
    .io_evalEnable(controlUnit_io_evalEnable),
    .io_inOut(controlUnit_io_inOut),
    .io_spikeCnt(controlUnit_io_spikeCnt),
    .io_aAddr(controlUnit_io_aAddr),
    .io_aEna(controlUnit_io_aEna),
    .io_aData(controlUnit_io_aData),
    .io_n(controlUnit_io_n),
    .io_spikes_0(controlUnit_io_spikes_0),
    .io_spikes_1(controlUnit_io_spikes_1),
    .io_spikes_2(controlUnit_io_spikes_2),
    .io_spikes_3(controlUnit_io_spikes_3),
    .io_spikes_4(controlUnit_io_spikes_4),
    .io_spikes_5(controlUnit_io_spikes_5),
    .io_spikes_6(controlUnit_io_spikes_6),
    .io_spikes_7(controlUnit_io_spikes_7)
  );
  NeuronEvaluator evalUnits_0 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_0_clock),
    .reset(evalUnits_0_reset),
    .io_dataIn(evalUnits_0_io_dataIn),
    .io_dataOut(evalUnits_0_io_dataOut),
    .io_spikeIndi(evalUnits_0_io_spikeIndi),
    .io_refracIndi(evalUnits_0_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_0_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_0_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_0_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_0_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_0_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_0_io_evalEnable)
  );
  NeuronEvaluator evalUnits_1 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_1_clock),
    .reset(evalUnits_1_reset),
    .io_dataIn(evalUnits_1_io_dataIn),
    .io_dataOut(evalUnits_1_io_dataOut),
    .io_spikeIndi(evalUnits_1_io_spikeIndi),
    .io_refracIndi(evalUnits_1_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_1_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_1_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_1_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_1_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_1_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_1_io_evalEnable)
  );
  NeuronEvaluator evalUnits_2 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_2_clock),
    .reset(evalUnits_2_reset),
    .io_dataIn(evalUnits_2_io_dataIn),
    .io_dataOut(evalUnits_2_io_dataOut),
    .io_spikeIndi(evalUnits_2_io_spikeIndi),
    .io_refracIndi(evalUnits_2_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_2_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_2_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_2_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_2_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_2_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_2_io_evalEnable)
  );
  NeuronEvaluator evalUnits_3 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_3_clock),
    .reset(evalUnits_3_reset),
    .io_dataIn(evalUnits_3_io_dataIn),
    .io_dataOut(evalUnits_3_io_dataOut),
    .io_spikeIndi(evalUnits_3_io_spikeIndi),
    .io_refracIndi(evalUnits_3_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_3_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_3_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_3_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_3_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_3_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_3_io_evalEnable)
  );
  NeuronEvaluator evalUnits_4 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_4_clock),
    .reset(evalUnits_4_reset),
    .io_dataIn(evalUnits_4_io_dataIn),
    .io_dataOut(evalUnits_4_io_dataOut),
    .io_spikeIndi(evalUnits_4_io_spikeIndi),
    .io_refracIndi(evalUnits_4_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_4_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_4_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_4_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_4_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_4_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_4_io_evalEnable)
  );
  NeuronEvaluator evalUnits_5 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_5_clock),
    .reset(evalUnits_5_reset),
    .io_dataIn(evalUnits_5_io_dataIn),
    .io_dataOut(evalUnits_5_io_dataOut),
    .io_spikeIndi(evalUnits_5_io_spikeIndi),
    .io_refracIndi(evalUnits_5_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_5_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_5_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_5_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_5_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_5_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_5_io_evalEnable)
  );
  NeuronEvaluator evalUnits_6 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_6_clock),
    .reset(evalUnits_6_reset),
    .io_dataIn(evalUnits_6_io_dataIn),
    .io_dataOut(evalUnits_6_io_dataOut),
    .io_spikeIndi(evalUnits_6_io_spikeIndi),
    .io_refracIndi(evalUnits_6_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_6_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_6_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_6_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_6_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_6_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_6_io_evalEnable)
  );
  NeuronEvaluator evalUnits_7 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_7_clock),
    .reset(evalUnits_7_reset),
    .io_dataIn(evalUnits_7_io_dataIn),
    .io_dataOut(evalUnits_7_io_dataOut),
    .io_spikeIndi(evalUnits_7_io_spikeIndi),
    .io_refracIndi(evalUnits_7_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_7_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_7_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_7_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_7_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_7_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_7_io_evalEnable)
  );
  EvaluationMemory evalMems_0 ( // @[Neurons.scala 24:56]
    .clock(evalMems_0_clock),
    .io_addr_sel(evalMems_0_io_addr_sel),
    .io_addr_pos(evalMems_0_io_addr_pos),
    .io_ena(evalMems_0_io_ena),
    .io_wr(evalMems_0_io_wr),
    .io_readData(evalMems_0_io_readData),
    .io_writeData(evalMems_0_io_writeData)
  );
  EvaluationMemory_1 evalMems_1 ( // @[Neurons.scala 24:56]
    .clock(evalMems_1_clock),
    .io_addr_sel(evalMems_1_io_addr_sel),
    .io_addr_pos(evalMems_1_io_addr_pos),
    .io_ena(evalMems_1_io_ena),
    .io_wr(evalMems_1_io_wr),
    .io_readData(evalMems_1_io_readData),
    .io_writeData(evalMems_1_io_writeData)
  );
  EvaluationMemory_2 evalMems_2 ( // @[Neurons.scala 24:56]
    .clock(evalMems_2_clock),
    .io_addr_sel(evalMems_2_io_addr_sel),
    .io_addr_pos(evalMems_2_io_addr_pos),
    .io_ena(evalMems_2_io_ena),
    .io_wr(evalMems_2_io_wr),
    .io_readData(evalMems_2_io_readData),
    .io_writeData(evalMems_2_io_writeData)
  );
  EvaluationMemory_3 evalMems_3 ( // @[Neurons.scala 24:56]
    .clock(evalMems_3_clock),
    .io_addr_sel(evalMems_3_io_addr_sel),
    .io_addr_pos(evalMems_3_io_addr_pos),
    .io_ena(evalMems_3_io_ena),
    .io_wr(evalMems_3_io_wr),
    .io_readData(evalMems_3_io_readData),
    .io_writeData(evalMems_3_io_writeData)
  );
  EvaluationMemory_4 evalMems_4 ( // @[Neurons.scala 24:56]
    .clock(evalMems_4_clock),
    .io_addr_sel(evalMems_4_io_addr_sel),
    .io_addr_pos(evalMems_4_io_addr_pos),
    .io_ena(evalMems_4_io_ena),
    .io_wr(evalMems_4_io_wr),
    .io_readData(evalMems_4_io_readData),
    .io_writeData(evalMems_4_io_writeData)
  );
  EvaluationMemory_5 evalMems_5 ( // @[Neurons.scala 24:56]
    .clock(evalMems_5_clock),
    .io_addr_sel(evalMems_5_io_addr_sel),
    .io_addr_pos(evalMems_5_io_addr_pos),
    .io_ena(evalMems_5_io_ena),
    .io_wr(evalMems_5_io_wr),
    .io_readData(evalMems_5_io_readData),
    .io_writeData(evalMems_5_io_writeData)
  );
  EvaluationMemory_6 evalMems_6 ( // @[Neurons.scala 24:56]
    .clock(evalMems_6_clock),
    .io_addr_sel(evalMems_6_io_addr_sel),
    .io_addr_pos(evalMems_6_io_addr_pos),
    .io_ena(evalMems_6_io_ena),
    .io_wr(evalMems_6_io_wr),
    .io_readData(evalMems_6_io_readData),
    .io_writeData(evalMems_6_io_writeData)
  );
  EvaluationMemory_7 evalMems_7 ( // @[Neurons.scala 24:56]
    .clock(evalMems_7_clock),
    .io_addr_sel(evalMems_7_io_addr_sel),
    .io_addr_pos(evalMems_7_io_addr_pos),
    .io_ena(evalMems_7_io_ena),
    .io_wr(evalMems_7_io_wr),
    .io_readData(evalMems_7_io_readData),
    .io_writeData(evalMems_7_io_writeData)
  );
  assign io_done = controlUnit_io_done; // @[Neurons.scala 33:11]
  assign io_inOut = controlUnit_io_inOut; // @[Neurons.scala 26:27]
  assign io_aAddr = controlUnit_io_aAddr; // @[Neurons.scala 28:27]
  assign io_aEna = controlUnit_io_aEna; // @[Neurons.scala 29:27]
  assign io_n = controlUnit_io_n; // @[Neurons.scala 31:27]
  assign io_spikes_0 = controlUnit_io_spikes_0; // @[Neurons.scala 37:18]
  assign io_spikes_1 = controlUnit_io_spikes_1; // @[Neurons.scala 37:18]
  assign io_spikes_2 = controlUnit_io_spikes_2; // @[Neurons.scala 37:18]
  assign io_spikes_3 = controlUnit_io_spikes_3; // @[Neurons.scala 37:18]
  assign io_spikes_4 = controlUnit_io_spikes_4; // @[Neurons.scala 37:18]
  assign io_spikes_5 = controlUnit_io_spikes_5; // @[Neurons.scala 37:18]
  assign io_spikes_6 = controlUnit_io_spikes_6; // @[Neurons.scala 37:18]
  assign io_spikes_7 = controlUnit_io_spikes_7; // @[Neurons.scala 37:18]
  assign controlUnit_clock = clock;
  assign controlUnit_reset = reset;
  assign controlUnit_io_newTS = io_newTS; // @[Neurons.scala 34:24]
  assign controlUnit_io_spikeIndi_0 = evalUnits_0_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_1 = evalUnits_1_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_2 = evalUnits_2_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_3 = evalUnits_3_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_4 = evalUnits_4_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_5 = evalUnits_5_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_6 = evalUnits_6_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_7 = evalUnits_7_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_refracIndi_0 = evalUnits_0_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_1 = evalUnits_1_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_2 = evalUnits_2_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_3 = evalUnits_3_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_4 = evalUnits_4_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_5 = evalUnits_5_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_6 = evalUnits_6_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_7 = evalUnits_7_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_spikeCnt = io_spikeCnt; // @[Neurons.scala 27:27]
  assign controlUnit_io_aData = io_aData; // @[Neurons.scala 30:27]
  assign evalUnits_0_clock = clock;
  assign evalUnits_0_reset = reset;
  assign evalUnits_0_io_dataIn = evalMems_0_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_0_io_cntrSels_potSel = controlUnit_io_cntrSels_0_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_0_io_cntrSels_spikeSel = controlUnit_io_cntrSels_0_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_0_io_cntrSels_refracSel = controlUnit_io_cntrSels_0_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_0_io_cntrSels_decaySel = controlUnit_io_cntrSels_0_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_0_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_0_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_0_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_1_clock = clock;
  assign evalUnits_1_reset = reset;
  assign evalUnits_1_io_dataIn = evalMems_1_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_1_io_cntrSels_potSel = controlUnit_io_cntrSels_1_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_1_io_cntrSels_spikeSel = controlUnit_io_cntrSels_1_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_1_io_cntrSels_refracSel = controlUnit_io_cntrSels_1_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_1_io_cntrSels_decaySel = controlUnit_io_cntrSels_1_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_1_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_1_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_1_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_2_clock = clock;
  assign evalUnits_2_reset = reset;
  assign evalUnits_2_io_dataIn = evalMems_2_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_2_io_cntrSels_potSel = controlUnit_io_cntrSels_2_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_2_io_cntrSels_spikeSel = controlUnit_io_cntrSels_2_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_2_io_cntrSels_refracSel = controlUnit_io_cntrSels_2_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_2_io_cntrSels_decaySel = controlUnit_io_cntrSels_2_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_2_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_2_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_2_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_3_clock = clock;
  assign evalUnits_3_reset = reset;
  assign evalUnits_3_io_dataIn = evalMems_3_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_3_io_cntrSels_potSel = controlUnit_io_cntrSels_3_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_3_io_cntrSels_spikeSel = controlUnit_io_cntrSels_3_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_3_io_cntrSels_refracSel = controlUnit_io_cntrSels_3_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_3_io_cntrSels_decaySel = controlUnit_io_cntrSels_3_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_3_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_3_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_3_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_4_clock = clock;
  assign evalUnits_4_reset = reset;
  assign evalUnits_4_io_dataIn = evalMems_4_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_4_io_cntrSels_potSel = controlUnit_io_cntrSels_4_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_4_io_cntrSels_spikeSel = controlUnit_io_cntrSels_4_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_4_io_cntrSels_refracSel = controlUnit_io_cntrSels_4_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_4_io_cntrSels_decaySel = controlUnit_io_cntrSels_4_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_4_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_4_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_4_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_5_clock = clock;
  assign evalUnits_5_reset = reset;
  assign evalUnits_5_io_dataIn = evalMems_5_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_5_io_cntrSels_potSel = controlUnit_io_cntrSels_5_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_5_io_cntrSels_spikeSel = controlUnit_io_cntrSels_5_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_5_io_cntrSels_refracSel = controlUnit_io_cntrSels_5_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_5_io_cntrSels_decaySel = controlUnit_io_cntrSels_5_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_5_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_5_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_5_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_6_clock = clock;
  assign evalUnits_6_reset = reset;
  assign evalUnits_6_io_dataIn = evalMems_6_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_6_io_cntrSels_potSel = controlUnit_io_cntrSels_6_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_6_io_cntrSels_spikeSel = controlUnit_io_cntrSels_6_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_6_io_cntrSels_refracSel = controlUnit_io_cntrSels_6_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_6_io_cntrSels_decaySel = controlUnit_io_cntrSels_6_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_6_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_6_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_6_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_7_clock = clock;
  assign evalUnits_7_reset = reset;
  assign evalUnits_7_io_dataIn = evalMems_7_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_7_io_cntrSels_potSel = controlUnit_io_cntrSels_7_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_7_io_cntrSels_spikeSel = controlUnit_io_cntrSels_7_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_7_io_cntrSels_refracSel = controlUnit_io_cntrSels_7_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_7_io_cntrSels_decaySel = controlUnit_io_cntrSels_7_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_7_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_7_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_7_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalMems_0_clock = clock;
  assign evalMems_0_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_0_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_0_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_0_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_0_io_writeData = evalUnits_0_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_1_clock = clock;
  assign evalMems_1_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_1_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_1_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_1_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_1_io_writeData = evalUnits_1_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_2_clock = clock;
  assign evalMems_2_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_2_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_2_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_2_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_2_io_writeData = evalUnits_2_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_3_clock = clock;
  assign evalMems_3_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_3_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_3_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_3_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_3_io_writeData = evalUnits_3_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_4_clock = clock;
  assign evalMems_4_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_4_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_4_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_4_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_4_io_writeData = evalUnits_4_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_5_clock = clock;
  assign evalMems_5_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_5_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_5_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_5_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_5_io_writeData = evalUnits_5_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_6_clock = clock;
  assign evalMems_6_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_6_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_6_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_6_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_6_io_writeData = evalUnits_6_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_7_clock = clock;
  assign evalMems_7_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_7_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_7_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_7_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_7_io_writeData = evalUnits_7_io_dataOut; // @[Neurons.scala 40:43]
endmodule
module NeuronCore(
  input         clock,
  input         reset,
  output        io_pmClkEn,
  input         io_newTS,
  input         io_grant,
  output        io_req,
  output [10:0] io_tx,
  input  [10:0] io_rx
);
  wire  interface__clock; // @[NeuronCore.scala 19:26]
  wire  interface__reset; // @[NeuronCore.scala 19:26]
  wire  interface__io_grant; // @[NeuronCore.scala 19:26]
  wire  interface__io_reqOut; // @[NeuronCore.scala 19:26]
  wire [10:0] interface__io_tx; // @[NeuronCore.scala 19:26]
  wire [10:0] interface__io_rx; // @[NeuronCore.scala 19:26]
  wire [9:0] interface__io_axonID; // @[NeuronCore.scala 19:26]
  wire  interface__io_valid; // @[NeuronCore.scala 19:26]
  wire [10:0] interface__io_spikeID; // @[NeuronCore.scala 19:26]
  wire  interface__io_ready; // @[NeuronCore.scala 19:26]
  wire  interface__io_reqIn; // @[NeuronCore.scala 19:26]
  wire  axonSystem_clock; // @[NeuronCore.scala 20:26]
  wire  axonSystem_reset; // @[NeuronCore.scala 20:26]
  wire [9:0] axonSystem_io_axonIn; // @[NeuronCore.scala 20:26]
  wire  axonSystem_io_axonValid; // @[NeuronCore.scala 20:26]
  wire  axonSystem_io_inOut; // @[NeuronCore.scala 20:26]
  wire [9:0] axonSystem_io_spikeCnt; // @[NeuronCore.scala 20:26]
  wire [9:0] axonSystem_io_rAddr; // @[NeuronCore.scala 20:26]
  wire  axonSystem_io_rEna; // @[NeuronCore.scala 20:26]
  wire [9:0] axonSystem_io_rData; // @[NeuronCore.scala 20:26]
  wire  spikeTrans_clock; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_reset; // @[NeuronCore.scala 21:26]
  wire [10:0] spikeTrans_io_data; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_ready; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_valid; // @[NeuronCore.scala 21:26]
  wire [4:0] spikeTrans_io_n; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_0; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_1; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_2; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_3; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_4; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_5; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_6; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_7; // @[NeuronCore.scala 21:26]
  wire  neurons_clock; // @[NeuronCore.scala 22:26]
  wire  neurons_reset; // @[NeuronCore.scala 22:26]
  wire  neurons_io_done; // @[NeuronCore.scala 22:26]
  wire  neurons_io_newTS; // @[NeuronCore.scala 22:26]
  wire  neurons_io_inOut; // @[NeuronCore.scala 22:26]
  wire [9:0] neurons_io_spikeCnt; // @[NeuronCore.scala 22:26]
  wire [9:0] neurons_io_aAddr; // @[NeuronCore.scala 22:26]
  wire  neurons_io_aEna; // @[NeuronCore.scala 22:26]
  wire [9:0] neurons_io_aData; // @[NeuronCore.scala 22:26]
  wire [4:0] neurons_io_n; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_0; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_1; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_2; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_3; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_4; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_5; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_6; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_7; // @[NeuronCore.scala 22:26]
  BusInterface_2 interface_ ( // @[NeuronCore.scala 19:26]
    .clock(interface__clock),
    .reset(interface__reset),
    .io_grant(interface__io_grant),
    .io_reqOut(interface__io_reqOut),
    .io_tx(interface__io_tx),
    .io_rx(interface__io_rx),
    .io_axonID(interface__io_axonID),
    .io_valid(interface__io_valid),
    .io_spikeID(interface__io_spikeID),
    .io_ready(interface__io_ready),
    .io_reqIn(interface__io_reqIn)
  );
  AxonSystem axonSystem ( // @[NeuronCore.scala 20:26]
    .clock(axonSystem_clock),
    .reset(axonSystem_reset),
    .io_axonIn(axonSystem_io_axonIn),
    .io_axonValid(axonSystem_io_axonValid),
    .io_inOut(axonSystem_io_inOut),
    .io_spikeCnt(axonSystem_io_spikeCnt),
    .io_rAddr(axonSystem_io_rAddr),
    .io_rEna(axonSystem_io_rEna),
    .io_rData(axonSystem_io_rData)
  );
  TransmissionSystem_2 spikeTrans ( // @[NeuronCore.scala 21:26]
    .clock(spikeTrans_clock),
    .reset(spikeTrans_reset),
    .io_data(spikeTrans_io_data),
    .io_ready(spikeTrans_io_ready),
    .io_valid(spikeTrans_io_valid),
    .io_n(spikeTrans_io_n),
    .io_spikes_0(spikeTrans_io_spikes_0),
    .io_spikes_1(spikeTrans_io_spikes_1),
    .io_spikes_2(spikeTrans_io_spikes_2),
    .io_spikes_3(spikeTrans_io_spikes_3),
    .io_spikes_4(spikeTrans_io_spikes_4),
    .io_spikes_5(spikeTrans_io_spikes_5),
    .io_spikes_6(spikeTrans_io_spikes_6),
    .io_spikes_7(spikeTrans_io_spikes_7)
  );
  Neurons neurons ( // @[NeuronCore.scala 22:26]
    .clock(neurons_clock),
    .reset(neurons_reset),
    .io_done(neurons_io_done),
    .io_newTS(neurons_io_newTS),
    .io_inOut(neurons_io_inOut),
    .io_spikeCnt(neurons_io_spikeCnt),
    .io_aAddr(neurons_io_aAddr),
    .io_aEna(neurons_io_aEna),
    .io_aData(neurons_io_aData),
    .io_n(neurons_io_n),
    .io_spikes_0(neurons_io_spikes_0),
    .io_spikes_1(neurons_io_spikes_1),
    .io_spikes_2(neurons_io_spikes_2),
    .io_spikes_3(neurons_io_spikes_3),
    .io_spikes_4(neurons_io_spikes_4),
    .io_spikes_5(neurons_io_spikes_5),
    .io_spikes_6(neurons_io_spikes_6),
    .io_spikes_7(neurons_io_spikes_7)
  );
  assign io_pmClkEn = ~neurons_io_done | interface__io_reqOut; // @[NeuronCore.scala 43:34]
  assign io_req = interface__io_reqOut; // @[NeuronCore.scala 25:27]
  assign io_tx = interface__io_tx; // @[NeuronCore.scala 26:27]
  assign interface__clock = clock;
  assign interface__reset = reset;
  assign interface__io_grant = io_grant; // @[NeuronCore.scala 24:27]
  assign interface__io_rx = io_rx; // @[NeuronCore.scala 27:27]
  assign interface__io_spikeID = spikeTrans_io_data; // @[NeuronCore.scala 30:27]
  assign interface__io_reqIn = spikeTrans_io_valid; // @[NeuronCore.scala 32:27]
  assign axonSystem_clock = clock;
  assign axonSystem_reset = reset;
  assign axonSystem_io_axonIn = interface__io_axonID; // @[NeuronCore.scala 28:27]
  assign axonSystem_io_axonValid = interface__io_valid; // @[NeuronCore.scala 29:27]
  assign axonSystem_io_inOut = neurons_io_inOut; // @[NeuronCore.scala 34:27]
  assign axonSystem_io_rAddr = neurons_io_aAddr; // @[NeuronCore.scala 36:27]
  assign axonSystem_io_rEna = neurons_io_aEna; // @[NeuronCore.scala 37:27]
  assign spikeTrans_clock = clock;
  assign spikeTrans_reset = reset;
  assign spikeTrans_io_ready = interface__io_ready; // @[NeuronCore.scala 31:27]
  assign spikeTrans_io_n = neurons_io_n; // @[NeuronCore.scala 40:27]
  assign spikeTrans_io_spikes_0 = neurons_io_spikes_0; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_1 = neurons_io_spikes_1; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_2 = neurons_io_spikes_2; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_3 = neurons_io_spikes_3; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_4 = neurons_io_spikes_4; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_5 = neurons_io_spikes_5; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_6 = neurons_io_spikes_6; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_7 = neurons_io_spikes_7; // @[NeuronCore.scala 41:27]
  assign neurons_clock = clock;
  assign neurons_reset = reset;
  assign neurons_io_newTS = io_newTS; // @[NeuronCore.scala 44:20]
  assign neurons_io_spikeCnt = axonSystem_io_spikeCnt; // @[NeuronCore.scala 35:27]
  assign neurons_io_aData = axonSystem_io_rData; // @[NeuronCore.scala 38:27]
endmodule
module BusInterface_3(
  input         clock,
  input         reset,
  input         io_grant,
  output        io_reqOut,
  output [10:0] io_tx,
  input  [10:0] io_rx,
  output [9:0]  io_axonID,
  output        io_valid,
  input  [10:0] io_spikeID,
  output        io_ready,
  input         io_reqIn
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  reg [7:0] axonIDLSBReg; // @[BusInterface.scala 36:29]
  reg [2:0] synROMReg; // @[BusInterface.scala 39:27]
  wire [2:0] _GEN_2 = 3'h2 == io_rx[10:8] ? 3'h4 : 3'h0; // @[BusInterface.scala 40:{19,19}]
  assign io_reqOut = io_reqIn & ~io_grant; // @[BusInterface.scala 32:25]
  assign io_tx = io_grant ? io_spikeID : 11'h0; // @[BusInterface.scala 31:15]
  assign io_axonID = {synROMReg[1:0],axonIDLSBReg}; // @[BusInterface.scala 43:47]
  assign io_valid = synROMReg[2]; // @[BusInterface.scala 42:25]
  assign io_ready = io_grant; // @[BusInterface.scala 33:13]
  always @(posedge clock) begin
    if (reset) begin // @[BusInterface.scala 36:29]
      axonIDLSBReg <= 8'h0; // @[BusInterface.scala 36:29]
    end else begin
      axonIDLSBReg <= io_rx[7:0]; // @[BusInterface.scala 37:16]
    end
    if (reset) begin // @[BusInterface.scala 39:27]
      synROMReg <= 3'h0; // @[BusInterface.scala 39:27]
    end else if (|io_rx) begin // @[BusInterface.scala 40:19]
      if (3'h4 == io_rx[10:8]) begin // @[BusInterface.scala 40:19]
        synROMReg <= 3'h0; // @[BusInterface.scala 40:19]
      end else if (3'h3 == io_rx[10:8]) begin // @[BusInterface.scala 40:19]
        synROMReg <= 3'h0; // @[BusInterface.scala 40:19]
      end else begin
        synROMReg <= _GEN_2;
      end
    end else begin
      synROMReg <= 3'h0;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  axonIDLSBReg = _RAND_0[7:0];
  _RAND_1 = {1{`RANDOM}};
  synROMReg = _RAND_1[2:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module TransmissionSystem_3(
  input         clock,
  input         reset,
  output [10:0] io_data,
  input         io_ready,
  output        io_valid,
  input  [4:0]  io_n,
  input         io_spikes_0,
  input         io_spikes_1,
  input         io_spikes_2,
  input         io_spikes_3,
  input         io_spikes_4,
  input         io_spikes_5,
  input         io_spikes_6,
  input         io_spikes_7
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
`endif // RANDOMIZE_REG_INIT
  wire  spikeEncoder_io_reqs_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_reqs_7; // @[TransmissionSystem.scala 22:28]
  wire [2:0] spikeEncoder_io_value; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_mask_7; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_0; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_1; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_2; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_3; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_4; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_5; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_6; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_rst_7; // @[TransmissionSystem.scala 22:28]
  wire  spikeEncoder_io_valid; // @[TransmissionSystem.scala 22:28]
  reg  spikeRegs_0; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_1; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_2; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_3; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_4; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_5; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_6; // @[TransmissionSystem.scala 18:29]
  reg  spikeRegs_7; // @[TransmissionSystem.scala 18:29]
  reg [4:0] neuronIdMSB_0; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_1; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_2; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_3; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_4; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_5; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_6; // @[TransmissionSystem.scala 19:29]
  reg [4:0] neuronIdMSB_7; // @[TransmissionSystem.scala 19:29]
  reg  maskRegs_0; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_1; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_2; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_3; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_4; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_5; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_6; // @[TransmissionSystem.scala 20:29]
  reg  maskRegs_7; // @[TransmissionSystem.scala 20:29]
  wire  rstReadySel_0 = ~(spikeEncoder_io_rst_0 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_0 = rstReadySel_0 & spikeRegs_0; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_0 = ~spikeEncoder_io_valid | maskRegs_0; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_1 = io_ready ? spikeEncoder_io_mask_0 : _GEN_0; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_1 = {3'h3,neuronIdMSB_0,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_4 = 3'h0 == spikeEncoder_io_value ? _io_data_T_1 : 11'h0; // @[TransmissionSystem.scala 28:12 49:41 50:15]
  wire  rstReadySel_1 = ~(spikeEncoder_io_rst_1 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_1 = rstReadySel_1 & spikeRegs_1; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_5 = ~spikeEncoder_io_valid | maskRegs_1; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_6 = io_ready ? spikeEncoder_io_mask_1 : _GEN_5; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_3 = {3'h3,neuronIdMSB_1,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_9 = 3'h1 == spikeEncoder_io_value ? _io_data_T_3 : _GEN_4; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_2 = ~(spikeEncoder_io_rst_2 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_2 = rstReadySel_2 & spikeRegs_2; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_10 = ~spikeEncoder_io_valid | maskRegs_2; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_11 = io_ready ? spikeEncoder_io_mask_2 : _GEN_10; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_5 = {3'h3,neuronIdMSB_2,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_14 = 3'h2 == spikeEncoder_io_value ? _io_data_T_5 : _GEN_9; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_3 = ~(spikeEncoder_io_rst_3 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_3 = rstReadySel_3 & spikeRegs_3; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_15 = ~spikeEncoder_io_valid | maskRegs_3; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_16 = io_ready ? spikeEncoder_io_mask_3 : _GEN_15; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_7 = {3'h3,neuronIdMSB_3,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_19 = 3'h3 == spikeEncoder_io_value ? _io_data_T_7 : _GEN_14; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_4 = ~(spikeEncoder_io_rst_4 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_4 = rstReadySel_4 & spikeRegs_4; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_20 = ~spikeEncoder_io_valid | maskRegs_4; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_21 = io_ready ? spikeEncoder_io_mask_4 : _GEN_20; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_9 = {3'h3,neuronIdMSB_4,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_24 = 3'h4 == spikeEncoder_io_value ? _io_data_T_9 : _GEN_19; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_5 = ~(spikeEncoder_io_rst_5 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_5 = rstReadySel_5 & spikeRegs_5; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_25 = ~spikeEncoder_io_valid | maskRegs_5; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_26 = io_ready ? spikeEncoder_io_mask_5 : _GEN_25; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_11 = {3'h3,neuronIdMSB_5,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_29 = 3'h5 == spikeEncoder_io_value ? _io_data_T_11 : _GEN_24; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_6 = ~(spikeEncoder_io_rst_6 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_6 = rstReadySel_6 & spikeRegs_6; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_30 = ~spikeEncoder_io_valid | maskRegs_6; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_31 = io_ready ? spikeEncoder_io_mask_6 : _GEN_30; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_13 = {3'h3,neuronIdMSB_6,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  wire [10:0] _GEN_34 = 3'h6 == spikeEncoder_io_value ? _io_data_T_13 : _GEN_29; // @[TransmissionSystem.scala 49:41 50:15]
  wire  rstReadySel_7 = ~(spikeEncoder_io_rst_7 & io_ready); // @[TransmissionSystem.scala 35:23]
  wire  spikeUpdate_7 = rstReadySel_7 & spikeRegs_7; // @[TransmissionSystem.scala 36:38]
  wire  _GEN_35 = ~spikeEncoder_io_valid | maskRegs_7; // @[TransmissionSystem.scala 40:40 41:19 20:29]
  wire  _GEN_36 = io_ready ? spikeEncoder_io_mask_7 : _GEN_35; // @[TransmissionSystem.scala 38:20 39:19]
  wire [10:0] _io_data_T_15 = {3'h3,neuronIdMSB_7,spikeEncoder_io_value}; // @[TransmissionSystem.scala 50:62]
  PriorityMaskRstEncoder spikeEncoder ( // @[TransmissionSystem.scala 22:28]
    .io_reqs_0(spikeEncoder_io_reqs_0),
    .io_reqs_1(spikeEncoder_io_reqs_1),
    .io_reqs_2(spikeEncoder_io_reqs_2),
    .io_reqs_3(spikeEncoder_io_reqs_3),
    .io_reqs_4(spikeEncoder_io_reqs_4),
    .io_reqs_5(spikeEncoder_io_reqs_5),
    .io_reqs_6(spikeEncoder_io_reqs_6),
    .io_reqs_7(spikeEncoder_io_reqs_7),
    .io_value(spikeEncoder_io_value),
    .io_mask_0(spikeEncoder_io_mask_0),
    .io_mask_1(spikeEncoder_io_mask_1),
    .io_mask_2(spikeEncoder_io_mask_2),
    .io_mask_3(spikeEncoder_io_mask_3),
    .io_mask_4(spikeEncoder_io_mask_4),
    .io_mask_5(spikeEncoder_io_mask_5),
    .io_mask_6(spikeEncoder_io_mask_6),
    .io_mask_7(spikeEncoder_io_mask_7),
    .io_rst_0(spikeEncoder_io_rst_0),
    .io_rst_1(spikeEncoder_io_rst_1),
    .io_rst_2(spikeEncoder_io_rst_2),
    .io_rst_3(spikeEncoder_io_rst_3),
    .io_rst_4(spikeEncoder_io_rst_4),
    .io_rst_5(spikeEncoder_io_rst_5),
    .io_rst_6(spikeEncoder_io_rst_6),
    .io_rst_7(spikeEncoder_io_rst_7),
    .io_valid(spikeEncoder_io_valid)
  );
  assign io_data = 3'h7 == spikeEncoder_io_value ? _io_data_T_15 : _GEN_34; // @[TransmissionSystem.scala 49:41 50:15]
  assign io_valid = spikeEncoder_io_valid; // @[TransmissionSystem.scala 29:12]
  assign spikeEncoder_io_reqs_0 = maskRegs_0 & spikeRegs_0; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_1 = maskRegs_1 & spikeRegs_1; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_2 = maskRegs_2 & spikeRegs_2; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_3 = maskRegs_3 & spikeRegs_3; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_4 = maskRegs_4 & spikeRegs_4; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_5 = maskRegs_5 & spikeRegs_5; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_6 = maskRegs_6 & spikeRegs_6; // @[TransmissionSystem.scala 33:35]
  assign spikeEncoder_io_reqs_7 = maskRegs_7 & spikeRegs_7; // @[TransmissionSystem.scala 33:35]
  always @(posedge clock) begin
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_0 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_0) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_0 <= io_spikes_0; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_1 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_1) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_1 <= io_spikes_1; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_2 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_2) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_2 <= io_spikes_2; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_3 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_3) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_3 <= io_spikes_3; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_4 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_4) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_4 <= io_spikes_4; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_5 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_5) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_5 <= io_spikes_5; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_6 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_6) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_6 <= io_spikes_6; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 18:29]
      spikeRegs_7 <= 1'h0; // @[TransmissionSystem.scala 18:29]
    end else if (~spikeUpdate_7) begin // @[TransmissionSystem.scala 44:27]
      spikeRegs_7 <= io_spikes_7; // @[TransmissionSystem.scala 46:20]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_0 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_0) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_0 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_1 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_1) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_1 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_2 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_2) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_2 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_3 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_3) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_3 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_4 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_4) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_4 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_5 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_5) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_5 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_6 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_6) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_6 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    if (reset) begin // @[TransmissionSystem.scala 19:29]
      neuronIdMSB_7 <= 5'h0; // @[TransmissionSystem.scala 19:29]
    end else if (~spikeUpdate_7) begin // @[TransmissionSystem.scala 44:27]
      neuronIdMSB_7 <= io_n; // @[TransmissionSystem.scala 45:22]
    end
    maskRegs_0 <= reset | _GEN_1; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_1 <= reset | _GEN_6; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_2 <= reset | _GEN_11; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_3 <= reset | _GEN_16; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_4 <= reset | _GEN_21; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_5 <= reset | _GEN_26; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_6 <= reset | _GEN_31; // @[TransmissionSystem.scala 20:{29,29}]
    maskRegs_7 <= reset | _GEN_36; // @[TransmissionSystem.scala 20:{29,29}]
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  spikeRegs_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  spikeRegs_1 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  spikeRegs_2 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  spikeRegs_3 = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  spikeRegs_4 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  spikeRegs_5 = _RAND_5[0:0];
  _RAND_6 = {1{`RANDOM}};
  spikeRegs_6 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  spikeRegs_7 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  neuronIdMSB_0 = _RAND_8[4:0];
  _RAND_9 = {1{`RANDOM}};
  neuronIdMSB_1 = _RAND_9[4:0];
  _RAND_10 = {1{`RANDOM}};
  neuronIdMSB_2 = _RAND_10[4:0];
  _RAND_11 = {1{`RANDOM}};
  neuronIdMSB_3 = _RAND_11[4:0];
  _RAND_12 = {1{`RANDOM}};
  neuronIdMSB_4 = _RAND_12[4:0];
  _RAND_13 = {1{`RANDOM}};
  neuronIdMSB_5 = _RAND_13[4:0];
  _RAND_14 = {1{`RANDOM}};
  neuronIdMSB_6 = _RAND_14[4:0];
  _RAND_15 = {1{`RANDOM}};
  neuronIdMSB_7 = _RAND_15[4:0];
  _RAND_16 = {1{`RANDOM}};
  maskRegs_0 = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  maskRegs_1 = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  maskRegs_2 = _RAND_18[0:0];
  _RAND_19 = {1{`RANDOM}};
  maskRegs_3 = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  maskRegs_4 = _RAND_20[0:0];
  _RAND_21 = {1{`RANDOM}};
  maskRegs_5 = _RAND_21[0:0];
  _RAND_22 = {1{`RANDOM}};
  maskRegs_6 = _RAND_22[0:0];
  _RAND_23 = {1{`RANDOM}};
  maskRegs_7 = _RAND_23[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_8(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc3.mem", constmem);
  $readmemb("mapping/meminit/potrefc3.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc3e0.mem", btmem);
  $readmemb("mapping/meminit/weightsc3e0.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_9(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc3.mem", constmem);
  $readmemb("mapping/meminit/potrefc3.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc3e1.mem", btmem);
  $readmemb("mapping/meminit/weightsc3e1.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_10(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc3.mem", constmem);
  $readmemb("mapping/meminit/potrefc3.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc3e2.mem", btmem);
  $readmemb("mapping/meminit/weightsc3e2.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_11(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc3.mem", constmem);
  $readmemb("mapping/meminit/potrefc3.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc3e3.mem", btmem);
  $readmemb("mapping/meminit/weightsc3e3.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_12(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc3.mem", constmem);
  $readmemb("mapping/meminit/potrefc3.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc3e4.mem", btmem);
  $readmemb("mapping/meminit/weightsc3e4.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_13(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc3.mem", constmem);
  $readmemb("mapping/meminit/potrefc3.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc3e5.mem", btmem);
  $readmemb("mapping/meminit/weightsc3e5.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_14(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc3.mem", constmem);
  $readmemb("mapping/meminit/potrefc3.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc3e6.mem", btmem);
  $readmemb("mapping/meminit/weightsc3e6.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module EvaluationMemory_15(
  input         clock,
  input  [1:0]  io_addr_sel,
  input  [14:0] io_addr_pos,
  input         io_ena,
  input         io_wr,
  output [16:0] io_readData,
  input  [16:0] io_writeData
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_6;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
`endif // RANDOMIZE_REG_INIT
  reg [4:0] constmem [0:3]; // @[EvaluationMemory.scala 24:29]
  wire  constmem_constRead_MPORT_en; // @[EvaluationMemory.scala 24:29]
  wire [1:0] constmem_constRead_MPORT_addr; // @[EvaluationMemory.scala 24:29]
  wire [4:0] constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 24:29]
  reg  constmem_constRead_MPORT_en_pipe_0;
  reg [1:0] constmem_constRead_MPORT_addr_pipe_0;
  reg [16:0] dynamem [0:63]; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_dynaRead_MPORT_en; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_dynaRead_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [16:0] dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
  wire [5:0] dynamem_MPORT_addr; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_mask; // @[EvaluationMemory.scala 25:29]
  wire  dynamem_MPORT_en; // @[EvaluationMemory.scala 25:29]
  reg  dynamem_dynaRead_MPORT_en_pipe_0;
  reg [5:0] dynamem_dynaRead_MPORT_addr_pipe_0;
  reg [16:0] btmem [0:63]; // @[EvaluationMemory.scala 26:29]
  wire  btmem_btRead_MPORT_en; // @[EvaluationMemory.scala 26:29]
  wire [5:0] btmem_btRead_MPORT_addr; // @[EvaluationMemory.scala 26:29]
  wire [16:0] btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 26:29]
  reg  btmem_btRead_MPORT_en_pipe_0;
  reg [5:0] btmem_btRead_MPORT_addr_pipe_0;
  reg [10:0] wghtmem [0:24575]; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_wghtRead_MPORT_en; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_wghtRead_MPORT_addr; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 27:29]
  wire [10:0] wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
  wire [14:0] wghtmem_MPORT_1_addr; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_mask; // @[EvaluationMemory.scala 27:29]
  wire  wghtmem_MPORT_1_en; // @[EvaluationMemory.scala 27:29]
  reg  wghtmem_wghtRead_MPORT_en_pipe_0;
  reg [14:0] wghtmem_wghtRead_MPORT_addr_pipe_0;
  reg [1:0] selPipe; // @[Reg.scala 16:16]
  reg [1:0] addrPipe; // @[Reg.scala 16:16]
  wire  _T = 2'h0 == io_addr_sel; // @[EvaluationMemory.scala 59:25]
  wire  _GEN_7 = io_wr ? 1'h0 : 1'h1; // @[EvaluationMemory.scala 64:21 25:29 67:30]
  wire [16:0] dynaRead = dynamem_dynaRead_MPORT_data; // @[EvaluationMemory.scala 64:21 67:20]
  wire [10:0] wghtRead = wghtmem_wghtRead_MPORT_data; // @[EvaluationMemory.scala 75:21 78:20]
  wire [16:0] btRead = btmem_btRead_MPORT_data; // @[EvaluationMemory.scala 59:25 71:16]
  wire  _GEN_30 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_35 = 2'h2 == io_addr_sel ? 1'h0 : 2'h3 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_46 = 2'h1 == io_addr_sel ? 1'h0 : 2'h2 == io_addr_sel; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_52 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_30; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_57 = 2'h1 == io_addr_sel ? 1'h0 : _GEN_35; // @[EvaluationMemory.scala 59:25 27:29]
  wire [4:0] constRead = constmem_constRead_MPORT_data; // @[EvaluationMemory.scala 59:25 61:19]
  wire  _GEN_65 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & io_wr; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_68 = 2'h0 == io_addr_sel ? 1'h0 : 2'h1 == io_addr_sel & _GEN_7; // @[EvaluationMemory.scala 59:25 25:29]
  wire  _GEN_72 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_46; // @[EvaluationMemory.scala 59:25 26:29]
  wire  _GEN_78 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_52; // @[EvaluationMemory.scala 59:25 27:29]
  wire  _GEN_83 = 2'h0 == io_addr_sel ? 1'h0 : _GEN_57; // @[EvaluationMemory.scala 59:25 27:29]
  wire [14:0] _res_T_1 = {constRead,10'h0}; // @[EvaluationMemory.scala 85:42]
  wire [16:0] res = {{2{_res_T_1[14]}},_res_T_1}; // @[EvaluationMemory.scala 85:52]
  wire [16:0] oth = {{12'd0}, constRead}; // @[EvaluationMemory.scala 86:45]
  wire [16:0] _memRead_T_2 = ~(|addrPipe) ? $signed(res) : $signed(oth); // @[EvaluationMemory.scala 87:21]
  wire [15:0] _res_T_4 = {wghtRead[9:0],6'h0}; // @[EvaluationMemory.scala 97:64]
  wire [16:0] res_1 = {{1{_res_T_4[15]}},_res_T_4}; // @[EvaluationMemory.scala 97:74]
  wire [16:0] oth_1 = {{6'd0}, wghtRead}; // @[EvaluationMemory.scala 98:44]
  wire [16:0] _memRead_T_4 = wghtRead[10] ? $signed(res_1) : $signed(oth_1); // @[EvaluationMemory.scala 99:21]
  wire [16:0] _GEN_112 = 2'h2 == selPipe ? $signed(btRead) : $signed(_memRead_T_4); // @[EvaluationMemory.scala 83:19 93:15]
  wire [16:0] _GEN_113 = 2'h1 == selPipe ? $signed(dynaRead) : $signed(_GEN_112); // @[EvaluationMemory.scala 83:19 90:15]
  assign constmem_constRead_MPORT_en = constmem_constRead_MPORT_en_pipe_0;
  assign constmem_constRead_MPORT_addr = constmem_constRead_MPORT_addr_pipe_0;
  assign constmem_constRead_MPORT_data = constmem[constmem_constRead_MPORT_addr]; // @[EvaluationMemory.scala 24:29]
  assign dynamem_dynaRead_MPORT_en = dynamem_dynaRead_MPORT_en_pipe_0;
  assign dynamem_dynaRead_MPORT_addr = dynamem_dynaRead_MPORT_addr_pipe_0;
  assign dynamem_dynaRead_MPORT_data = dynamem[dynamem_dynaRead_MPORT_addr]; // @[EvaluationMemory.scala 25:29]
  assign dynamem_MPORT_data = io_writeData;
  assign dynamem_MPORT_addr = io_addr_pos[5:0];
  assign dynamem_MPORT_mask = 1'h1;
  assign dynamem_MPORT_en = io_ena & _GEN_65;
  assign btmem_btRead_MPORT_en = btmem_btRead_MPORT_en_pipe_0;
  assign btmem_btRead_MPORT_addr = btmem_btRead_MPORT_addr_pipe_0;
  assign btmem_btRead_MPORT_data = btmem[btmem_btRead_MPORT_addr]; // @[EvaluationMemory.scala 26:29]
  assign wghtmem_wghtRead_MPORT_en = wghtmem_wghtRead_MPORT_en_pipe_0;
  assign wghtmem_wghtRead_MPORT_addr = wghtmem_wghtRead_MPORT_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_wghtRead_MPORT_data = wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `else
  assign wghtmem_wghtRead_MPORT_data = wghtmem_wghtRead_MPORT_addr >= 15'h6000 ? _RAND_6[10:0] :
    wghtmem[wghtmem_wghtRead_MPORT_addr]; // @[EvaluationMemory.scala 27:29]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign wghtmem_MPORT_1_data = io_writeData[10:0];
  assign wghtmem_MPORT_1_addr = io_addr_pos;
  assign wghtmem_MPORT_1_mask = 1'h1;
  assign wghtmem_MPORT_1_en = io_ena & _GEN_78;
  assign io_readData = 2'h0 == selPipe ? $signed(_memRead_T_2) : $signed(_GEN_113); // @[EvaluationMemory.scala 83:19 87:15]
  always @(posedge clock) begin
    constmem_constRead_MPORT_en_pipe_0 <= io_ena & _T;
    if (io_ena & _T) begin
      constmem_constRead_MPORT_addr_pipe_0 <= io_addr_pos[1:0];
    end
    if (dynamem_MPORT_en & dynamem_MPORT_mask) begin
      dynamem[dynamem_MPORT_addr] <= dynamem_MPORT_data; // @[EvaluationMemory.scala 25:29]
    end
    dynamem_dynaRead_MPORT_en_pipe_0 <= io_ena & _GEN_68;
    if (io_ena & _GEN_68) begin
      dynamem_dynaRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    btmem_btRead_MPORT_en_pipe_0 <= io_ena & _GEN_72;
    if (io_ena & _GEN_72) begin
      btmem_btRead_MPORT_addr_pipe_0 <= io_addr_pos[5:0];
    end
    if (wghtmem_MPORT_1_en & wghtmem_MPORT_1_mask) begin
      wghtmem[wghtmem_MPORT_1_addr] <= wghtmem_MPORT_1_data; // @[EvaluationMemory.scala 27:29]
    end
    wghtmem_wghtRead_MPORT_en_pipe_0 <= io_ena & _GEN_83;
    if (io_ena & _GEN_83) begin
      wghtmem_wghtRead_MPORT_addr_pipe_0 <= io_addr_pos;
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      selPipe <= io_addr_sel; // @[Reg.scala 17:22]
    end
    if (io_ena) begin // @[Reg.scala 17:18]
      addrPipe <= io_addr_pos[1:0]; // @[Reg.scala 17:22]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
  integer initvar;
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_6 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  constmem_constRead_MPORT_en_pipe_0 = _RAND_0[0:0];
  _RAND_1 = {1{`RANDOM}};
  constmem_constRead_MPORT_addr_pipe_0 = _RAND_1[1:0];
  _RAND_2 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  dynamem_dynaRead_MPORT_addr_pipe_0 = _RAND_3[5:0];
  _RAND_4 = {1{`RANDOM}};
  btmem_btRead_MPORT_en_pipe_0 = _RAND_4[0:0];
  _RAND_5 = {1{`RANDOM}};
  btmem_btRead_MPORT_addr_pipe_0 = _RAND_5[5:0];
  _RAND_7 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_en_pipe_0 = _RAND_7[0:0];
  _RAND_8 = {1{`RANDOM}};
  wghtmem_wghtRead_MPORT_addr_pipe_0 = _RAND_8[14:0];
  _RAND_9 = {1{`RANDOM}};
  selPipe = _RAND_9[1:0];
  _RAND_10 = {1{`RANDOM}};
  addrPipe = _RAND_10[1:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
  $readmemb("mapping/meminit/constc3.mem", constmem);
  $readmemb("mapping/meminit/potrefc3.mem", dynamem);
  $readmemb("mapping/meminit/biasthreshc3e7.mem", btmem);
  $readmemb("mapping/meminit/weightsc3e7.mem", wghtmem);
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module Neurons_1(
  input        clock,
  input        reset,
  output       io_done,
  input        io_newTS,
  output       io_inOut,
  input  [9:0] io_spikeCnt,
  output [9:0] io_aAddr,
  output       io_aEna,
  input  [9:0] io_aData,
  output [4:0] io_n,
  output       io_spikes_0,
  output       io_spikes_1,
  output       io_spikes_2,
  output       io_spikes_3,
  output       io_spikes_4,
  output       io_spikes_5,
  output       io_spikes_6,
  output       io_spikes_7
);
  wire  controlUnit_clock; // @[Neurons.scala 22:27]
  wire  controlUnit_reset; // @[Neurons.scala 22:27]
  wire  controlUnit_io_done; // @[Neurons.scala 22:27]
  wire  controlUnit_io_newTS; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_addr_sel; // @[Neurons.scala 22:27]
  wire [14:0] controlUnit_io_addr_pos; // @[Neurons.scala 22:27]
  wire  controlUnit_io_wr; // @[Neurons.scala 22:27]
  wire  controlUnit_io_ena; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_0; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_1; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_2; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_3; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_4; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_5; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_6; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikeIndi_7; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_0; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_1; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_2; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_3; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_4; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_5; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_6; // @[Neurons.scala 22:27]
  wire  controlUnit_io_refracIndi_7; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_0_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_0_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_0_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_0_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_0_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_1_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_1_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_1_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_1_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_1_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_2_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_2_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_2_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_2_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_2_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_3_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_3_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_3_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_3_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_3_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_4_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_4_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_4_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_4_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_4_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_5_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_5_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_5_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_5_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_5_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_6_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_6_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_6_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_6_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_6_writeDataSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_7_potSel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_7_spikeSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_7_refracSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_cntrSels_7_decaySel; // @[Neurons.scala 22:27]
  wire [1:0] controlUnit_io_cntrSels_7_writeDataSel; // @[Neurons.scala 22:27]
  wire  controlUnit_io_evalEnable; // @[Neurons.scala 22:27]
  wire  controlUnit_io_inOut; // @[Neurons.scala 22:27]
  wire [9:0] controlUnit_io_spikeCnt; // @[Neurons.scala 22:27]
  wire [9:0] controlUnit_io_aAddr; // @[Neurons.scala 22:27]
  wire  controlUnit_io_aEna; // @[Neurons.scala 22:27]
  wire [9:0] controlUnit_io_aData; // @[Neurons.scala 22:27]
  wire [4:0] controlUnit_io_n; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_0; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_1; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_2; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_3; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_4; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_5; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_6; // @[Neurons.scala 22:27]
  wire  controlUnit_io_spikes_7; // @[Neurons.scala 22:27]
  wire  evalUnits_0_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_0_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_0_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_0_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_0_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_0_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_0_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_0_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_0_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_0_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_0_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_0_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_1_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_1_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_1_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_1_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_1_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_1_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_1_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_1_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_1_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_1_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_1_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_1_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_2_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_2_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_2_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_2_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_2_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_2_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_2_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_2_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_2_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_2_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_2_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_2_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_3_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_3_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_3_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_3_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_3_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_3_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_3_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_3_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_3_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_3_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_3_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_3_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_4_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_4_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_4_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_4_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_4_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_4_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_4_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_4_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_4_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_4_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_4_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_4_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_5_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_5_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_5_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_5_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_5_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_5_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_5_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_5_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_5_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_5_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_5_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_5_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_6_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_6_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_6_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_6_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_6_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_6_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_6_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_6_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_6_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_6_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_6_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_6_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalUnits_7_clock; // @[Neurons.scala 23:56]
  wire  evalUnits_7_reset; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_7_io_dataIn; // @[Neurons.scala 23:56]
  wire [16:0] evalUnits_7_io_dataOut; // @[Neurons.scala 23:56]
  wire  evalUnits_7_io_spikeIndi; // @[Neurons.scala 23:56]
  wire  evalUnits_7_io_refracIndi; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_7_io_cntrSels_potSel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_7_io_cntrSels_spikeSel; // @[Neurons.scala 23:56]
  wire  evalUnits_7_io_cntrSels_refracSel; // @[Neurons.scala 23:56]
  wire  evalUnits_7_io_cntrSels_decaySel; // @[Neurons.scala 23:56]
  wire [1:0] evalUnits_7_io_cntrSels_writeDataSel; // @[Neurons.scala 23:56]
  wire  evalUnits_7_io_evalEnable; // @[Neurons.scala 23:56]
  wire  evalMems_0_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_0_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_0_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_0_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_0_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_0_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_0_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_1_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_1_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_1_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_1_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_1_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_1_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_1_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_2_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_2_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_2_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_2_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_2_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_2_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_2_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_3_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_3_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_3_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_3_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_3_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_3_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_3_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_4_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_4_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_4_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_4_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_4_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_4_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_4_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_5_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_5_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_5_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_5_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_5_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_5_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_5_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_6_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_6_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_6_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_6_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_6_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_6_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_6_io_writeData; // @[Neurons.scala 24:56]
  wire  evalMems_7_clock; // @[Neurons.scala 24:56]
  wire [1:0] evalMems_7_io_addr_sel; // @[Neurons.scala 24:56]
  wire [14:0] evalMems_7_io_addr_pos; // @[Neurons.scala 24:56]
  wire  evalMems_7_io_ena; // @[Neurons.scala 24:56]
  wire  evalMems_7_io_wr; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_7_io_readData; // @[Neurons.scala 24:56]
  wire [16:0] evalMems_7_io_writeData; // @[Neurons.scala 24:56]
  ControlUnit controlUnit ( // @[Neurons.scala 22:27]
    .clock(controlUnit_clock),
    .reset(controlUnit_reset),
    .io_done(controlUnit_io_done),
    .io_newTS(controlUnit_io_newTS),
    .io_addr_sel(controlUnit_io_addr_sel),
    .io_addr_pos(controlUnit_io_addr_pos),
    .io_wr(controlUnit_io_wr),
    .io_ena(controlUnit_io_ena),
    .io_spikeIndi_0(controlUnit_io_spikeIndi_0),
    .io_spikeIndi_1(controlUnit_io_spikeIndi_1),
    .io_spikeIndi_2(controlUnit_io_spikeIndi_2),
    .io_spikeIndi_3(controlUnit_io_spikeIndi_3),
    .io_spikeIndi_4(controlUnit_io_spikeIndi_4),
    .io_spikeIndi_5(controlUnit_io_spikeIndi_5),
    .io_spikeIndi_6(controlUnit_io_spikeIndi_6),
    .io_spikeIndi_7(controlUnit_io_spikeIndi_7),
    .io_refracIndi_0(controlUnit_io_refracIndi_0),
    .io_refracIndi_1(controlUnit_io_refracIndi_1),
    .io_refracIndi_2(controlUnit_io_refracIndi_2),
    .io_refracIndi_3(controlUnit_io_refracIndi_3),
    .io_refracIndi_4(controlUnit_io_refracIndi_4),
    .io_refracIndi_5(controlUnit_io_refracIndi_5),
    .io_refracIndi_6(controlUnit_io_refracIndi_6),
    .io_refracIndi_7(controlUnit_io_refracIndi_7),
    .io_cntrSels_0_potSel(controlUnit_io_cntrSels_0_potSel),
    .io_cntrSels_0_spikeSel(controlUnit_io_cntrSels_0_spikeSel),
    .io_cntrSels_0_refracSel(controlUnit_io_cntrSels_0_refracSel),
    .io_cntrSels_0_decaySel(controlUnit_io_cntrSels_0_decaySel),
    .io_cntrSels_0_writeDataSel(controlUnit_io_cntrSels_0_writeDataSel),
    .io_cntrSels_1_potSel(controlUnit_io_cntrSels_1_potSel),
    .io_cntrSels_1_spikeSel(controlUnit_io_cntrSels_1_spikeSel),
    .io_cntrSels_1_refracSel(controlUnit_io_cntrSels_1_refracSel),
    .io_cntrSels_1_decaySel(controlUnit_io_cntrSels_1_decaySel),
    .io_cntrSels_1_writeDataSel(controlUnit_io_cntrSels_1_writeDataSel),
    .io_cntrSels_2_potSel(controlUnit_io_cntrSels_2_potSel),
    .io_cntrSels_2_spikeSel(controlUnit_io_cntrSels_2_spikeSel),
    .io_cntrSels_2_refracSel(controlUnit_io_cntrSels_2_refracSel),
    .io_cntrSels_2_decaySel(controlUnit_io_cntrSels_2_decaySel),
    .io_cntrSels_2_writeDataSel(controlUnit_io_cntrSels_2_writeDataSel),
    .io_cntrSels_3_potSel(controlUnit_io_cntrSels_3_potSel),
    .io_cntrSels_3_spikeSel(controlUnit_io_cntrSels_3_spikeSel),
    .io_cntrSels_3_refracSel(controlUnit_io_cntrSels_3_refracSel),
    .io_cntrSels_3_decaySel(controlUnit_io_cntrSels_3_decaySel),
    .io_cntrSels_3_writeDataSel(controlUnit_io_cntrSels_3_writeDataSel),
    .io_cntrSels_4_potSel(controlUnit_io_cntrSels_4_potSel),
    .io_cntrSels_4_spikeSel(controlUnit_io_cntrSels_4_spikeSel),
    .io_cntrSels_4_refracSel(controlUnit_io_cntrSels_4_refracSel),
    .io_cntrSels_4_decaySel(controlUnit_io_cntrSels_4_decaySel),
    .io_cntrSels_4_writeDataSel(controlUnit_io_cntrSels_4_writeDataSel),
    .io_cntrSels_5_potSel(controlUnit_io_cntrSels_5_potSel),
    .io_cntrSels_5_spikeSel(controlUnit_io_cntrSels_5_spikeSel),
    .io_cntrSels_5_refracSel(controlUnit_io_cntrSels_5_refracSel),
    .io_cntrSels_5_decaySel(controlUnit_io_cntrSels_5_decaySel),
    .io_cntrSels_5_writeDataSel(controlUnit_io_cntrSels_5_writeDataSel),
    .io_cntrSels_6_potSel(controlUnit_io_cntrSels_6_potSel),
    .io_cntrSels_6_spikeSel(controlUnit_io_cntrSels_6_spikeSel),
    .io_cntrSels_6_refracSel(controlUnit_io_cntrSels_6_refracSel),
    .io_cntrSels_6_decaySel(controlUnit_io_cntrSels_6_decaySel),
    .io_cntrSels_6_writeDataSel(controlUnit_io_cntrSels_6_writeDataSel),
    .io_cntrSels_7_potSel(controlUnit_io_cntrSels_7_potSel),
    .io_cntrSels_7_spikeSel(controlUnit_io_cntrSels_7_spikeSel),
    .io_cntrSels_7_refracSel(controlUnit_io_cntrSels_7_refracSel),
    .io_cntrSels_7_decaySel(controlUnit_io_cntrSels_7_decaySel),
    .io_cntrSels_7_writeDataSel(controlUnit_io_cntrSels_7_writeDataSel),
    .io_evalEnable(controlUnit_io_evalEnable),
    .io_inOut(controlUnit_io_inOut),
    .io_spikeCnt(controlUnit_io_spikeCnt),
    .io_aAddr(controlUnit_io_aAddr),
    .io_aEna(controlUnit_io_aEna),
    .io_aData(controlUnit_io_aData),
    .io_n(controlUnit_io_n),
    .io_spikes_0(controlUnit_io_spikes_0),
    .io_spikes_1(controlUnit_io_spikes_1),
    .io_spikes_2(controlUnit_io_spikes_2),
    .io_spikes_3(controlUnit_io_spikes_3),
    .io_spikes_4(controlUnit_io_spikes_4),
    .io_spikes_5(controlUnit_io_spikes_5),
    .io_spikes_6(controlUnit_io_spikes_6),
    .io_spikes_7(controlUnit_io_spikes_7)
  );
  NeuronEvaluator evalUnits_0 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_0_clock),
    .reset(evalUnits_0_reset),
    .io_dataIn(evalUnits_0_io_dataIn),
    .io_dataOut(evalUnits_0_io_dataOut),
    .io_spikeIndi(evalUnits_0_io_spikeIndi),
    .io_refracIndi(evalUnits_0_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_0_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_0_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_0_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_0_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_0_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_0_io_evalEnable)
  );
  NeuronEvaluator evalUnits_1 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_1_clock),
    .reset(evalUnits_1_reset),
    .io_dataIn(evalUnits_1_io_dataIn),
    .io_dataOut(evalUnits_1_io_dataOut),
    .io_spikeIndi(evalUnits_1_io_spikeIndi),
    .io_refracIndi(evalUnits_1_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_1_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_1_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_1_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_1_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_1_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_1_io_evalEnable)
  );
  NeuronEvaluator evalUnits_2 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_2_clock),
    .reset(evalUnits_2_reset),
    .io_dataIn(evalUnits_2_io_dataIn),
    .io_dataOut(evalUnits_2_io_dataOut),
    .io_spikeIndi(evalUnits_2_io_spikeIndi),
    .io_refracIndi(evalUnits_2_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_2_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_2_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_2_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_2_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_2_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_2_io_evalEnable)
  );
  NeuronEvaluator evalUnits_3 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_3_clock),
    .reset(evalUnits_3_reset),
    .io_dataIn(evalUnits_3_io_dataIn),
    .io_dataOut(evalUnits_3_io_dataOut),
    .io_spikeIndi(evalUnits_3_io_spikeIndi),
    .io_refracIndi(evalUnits_3_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_3_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_3_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_3_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_3_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_3_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_3_io_evalEnable)
  );
  NeuronEvaluator evalUnits_4 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_4_clock),
    .reset(evalUnits_4_reset),
    .io_dataIn(evalUnits_4_io_dataIn),
    .io_dataOut(evalUnits_4_io_dataOut),
    .io_spikeIndi(evalUnits_4_io_spikeIndi),
    .io_refracIndi(evalUnits_4_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_4_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_4_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_4_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_4_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_4_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_4_io_evalEnable)
  );
  NeuronEvaluator evalUnits_5 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_5_clock),
    .reset(evalUnits_5_reset),
    .io_dataIn(evalUnits_5_io_dataIn),
    .io_dataOut(evalUnits_5_io_dataOut),
    .io_spikeIndi(evalUnits_5_io_spikeIndi),
    .io_refracIndi(evalUnits_5_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_5_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_5_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_5_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_5_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_5_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_5_io_evalEnable)
  );
  NeuronEvaluator evalUnits_6 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_6_clock),
    .reset(evalUnits_6_reset),
    .io_dataIn(evalUnits_6_io_dataIn),
    .io_dataOut(evalUnits_6_io_dataOut),
    .io_spikeIndi(evalUnits_6_io_spikeIndi),
    .io_refracIndi(evalUnits_6_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_6_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_6_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_6_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_6_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_6_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_6_io_evalEnable)
  );
  NeuronEvaluator evalUnits_7 ( // @[Neurons.scala 23:56]
    .clock(evalUnits_7_clock),
    .reset(evalUnits_7_reset),
    .io_dataIn(evalUnits_7_io_dataIn),
    .io_dataOut(evalUnits_7_io_dataOut),
    .io_spikeIndi(evalUnits_7_io_spikeIndi),
    .io_refracIndi(evalUnits_7_io_refracIndi),
    .io_cntrSels_potSel(evalUnits_7_io_cntrSels_potSel),
    .io_cntrSels_spikeSel(evalUnits_7_io_cntrSels_spikeSel),
    .io_cntrSels_refracSel(evalUnits_7_io_cntrSels_refracSel),
    .io_cntrSels_decaySel(evalUnits_7_io_cntrSels_decaySel),
    .io_cntrSels_writeDataSel(evalUnits_7_io_cntrSels_writeDataSel),
    .io_evalEnable(evalUnits_7_io_evalEnable)
  );
  EvaluationMemory_8 evalMems_0 ( // @[Neurons.scala 24:56]
    .clock(evalMems_0_clock),
    .io_addr_sel(evalMems_0_io_addr_sel),
    .io_addr_pos(evalMems_0_io_addr_pos),
    .io_ena(evalMems_0_io_ena),
    .io_wr(evalMems_0_io_wr),
    .io_readData(evalMems_0_io_readData),
    .io_writeData(evalMems_0_io_writeData)
  );
  EvaluationMemory_9 evalMems_1 ( // @[Neurons.scala 24:56]
    .clock(evalMems_1_clock),
    .io_addr_sel(evalMems_1_io_addr_sel),
    .io_addr_pos(evalMems_1_io_addr_pos),
    .io_ena(evalMems_1_io_ena),
    .io_wr(evalMems_1_io_wr),
    .io_readData(evalMems_1_io_readData),
    .io_writeData(evalMems_1_io_writeData)
  );
  EvaluationMemory_10 evalMems_2 ( // @[Neurons.scala 24:56]
    .clock(evalMems_2_clock),
    .io_addr_sel(evalMems_2_io_addr_sel),
    .io_addr_pos(evalMems_2_io_addr_pos),
    .io_ena(evalMems_2_io_ena),
    .io_wr(evalMems_2_io_wr),
    .io_readData(evalMems_2_io_readData),
    .io_writeData(evalMems_2_io_writeData)
  );
  EvaluationMemory_11 evalMems_3 ( // @[Neurons.scala 24:56]
    .clock(evalMems_3_clock),
    .io_addr_sel(evalMems_3_io_addr_sel),
    .io_addr_pos(evalMems_3_io_addr_pos),
    .io_ena(evalMems_3_io_ena),
    .io_wr(evalMems_3_io_wr),
    .io_readData(evalMems_3_io_readData),
    .io_writeData(evalMems_3_io_writeData)
  );
  EvaluationMemory_12 evalMems_4 ( // @[Neurons.scala 24:56]
    .clock(evalMems_4_clock),
    .io_addr_sel(evalMems_4_io_addr_sel),
    .io_addr_pos(evalMems_4_io_addr_pos),
    .io_ena(evalMems_4_io_ena),
    .io_wr(evalMems_4_io_wr),
    .io_readData(evalMems_4_io_readData),
    .io_writeData(evalMems_4_io_writeData)
  );
  EvaluationMemory_13 evalMems_5 ( // @[Neurons.scala 24:56]
    .clock(evalMems_5_clock),
    .io_addr_sel(evalMems_5_io_addr_sel),
    .io_addr_pos(evalMems_5_io_addr_pos),
    .io_ena(evalMems_5_io_ena),
    .io_wr(evalMems_5_io_wr),
    .io_readData(evalMems_5_io_readData),
    .io_writeData(evalMems_5_io_writeData)
  );
  EvaluationMemory_14 evalMems_6 ( // @[Neurons.scala 24:56]
    .clock(evalMems_6_clock),
    .io_addr_sel(evalMems_6_io_addr_sel),
    .io_addr_pos(evalMems_6_io_addr_pos),
    .io_ena(evalMems_6_io_ena),
    .io_wr(evalMems_6_io_wr),
    .io_readData(evalMems_6_io_readData),
    .io_writeData(evalMems_6_io_writeData)
  );
  EvaluationMemory_15 evalMems_7 ( // @[Neurons.scala 24:56]
    .clock(evalMems_7_clock),
    .io_addr_sel(evalMems_7_io_addr_sel),
    .io_addr_pos(evalMems_7_io_addr_pos),
    .io_ena(evalMems_7_io_ena),
    .io_wr(evalMems_7_io_wr),
    .io_readData(evalMems_7_io_readData),
    .io_writeData(evalMems_7_io_writeData)
  );
  assign io_done = controlUnit_io_done; // @[Neurons.scala 33:11]
  assign io_inOut = controlUnit_io_inOut; // @[Neurons.scala 26:27]
  assign io_aAddr = controlUnit_io_aAddr; // @[Neurons.scala 28:27]
  assign io_aEna = controlUnit_io_aEna; // @[Neurons.scala 29:27]
  assign io_n = controlUnit_io_n; // @[Neurons.scala 31:27]
  assign io_spikes_0 = controlUnit_io_spikes_0; // @[Neurons.scala 37:18]
  assign io_spikes_1 = controlUnit_io_spikes_1; // @[Neurons.scala 37:18]
  assign io_spikes_2 = controlUnit_io_spikes_2; // @[Neurons.scala 37:18]
  assign io_spikes_3 = controlUnit_io_spikes_3; // @[Neurons.scala 37:18]
  assign io_spikes_4 = controlUnit_io_spikes_4; // @[Neurons.scala 37:18]
  assign io_spikes_5 = controlUnit_io_spikes_5; // @[Neurons.scala 37:18]
  assign io_spikes_6 = controlUnit_io_spikes_6; // @[Neurons.scala 37:18]
  assign io_spikes_7 = controlUnit_io_spikes_7; // @[Neurons.scala 37:18]
  assign controlUnit_clock = clock;
  assign controlUnit_reset = reset;
  assign controlUnit_io_newTS = io_newTS; // @[Neurons.scala 34:24]
  assign controlUnit_io_spikeIndi_0 = evalUnits_0_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_1 = evalUnits_1_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_2 = evalUnits_2_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_3 = evalUnits_3_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_4 = evalUnits_4_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_5 = evalUnits_5_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_6 = evalUnits_6_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_spikeIndi_7 = evalUnits_7_io_spikeIndi; // @[Neurons.scala 41:43]
  assign controlUnit_io_refracIndi_0 = evalUnits_0_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_1 = evalUnits_1_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_2 = evalUnits_2_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_3 = evalUnits_3_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_4 = evalUnits_4_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_5 = evalUnits_5_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_6 = evalUnits_6_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_refracIndi_7 = evalUnits_7_io_refracIndi; // @[Neurons.scala 42:43]
  assign controlUnit_io_spikeCnt = io_spikeCnt; // @[Neurons.scala 27:27]
  assign controlUnit_io_aData = io_aData; // @[Neurons.scala 30:27]
  assign evalUnits_0_clock = clock;
  assign evalUnits_0_reset = reset;
  assign evalUnits_0_io_dataIn = evalMems_0_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_0_io_cntrSels_potSel = controlUnit_io_cntrSels_0_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_0_io_cntrSels_spikeSel = controlUnit_io_cntrSels_0_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_0_io_cntrSels_refracSel = controlUnit_io_cntrSels_0_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_0_io_cntrSels_decaySel = controlUnit_io_cntrSels_0_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_0_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_0_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_0_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_1_clock = clock;
  assign evalUnits_1_reset = reset;
  assign evalUnits_1_io_dataIn = evalMems_1_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_1_io_cntrSels_potSel = controlUnit_io_cntrSels_1_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_1_io_cntrSels_spikeSel = controlUnit_io_cntrSels_1_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_1_io_cntrSels_refracSel = controlUnit_io_cntrSels_1_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_1_io_cntrSels_decaySel = controlUnit_io_cntrSels_1_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_1_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_1_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_1_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_2_clock = clock;
  assign evalUnits_2_reset = reset;
  assign evalUnits_2_io_dataIn = evalMems_2_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_2_io_cntrSels_potSel = controlUnit_io_cntrSels_2_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_2_io_cntrSels_spikeSel = controlUnit_io_cntrSels_2_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_2_io_cntrSels_refracSel = controlUnit_io_cntrSels_2_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_2_io_cntrSels_decaySel = controlUnit_io_cntrSels_2_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_2_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_2_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_2_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_3_clock = clock;
  assign evalUnits_3_reset = reset;
  assign evalUnits_3_io_dataIn = evalMems_3_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_3_io_cntrSels_potSel = controlUnit_io_cntrSels_3_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_3_io_cntrSels_spikeSel = controlUnit_io_cntrSels_3_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_3_io_cntrSels_refracSel = controlUnit_io_cntrSels_3_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_3_io_cntrSels_decaySel = controlUnit_io_cntrSels_3_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_3_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_3_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_3_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_4_clock = clock;
  assign evalUnits_4_reset = reset;
  assign evalUnits_4_io_dataIn = evalMems_4_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_4_io_cntrSels_potSel = controlUnit_io_cntrSels_4_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_4_io_cntrSels_spikeSel = controlUnit_io_cntrSels_4_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_4_io_cntrSels_refracSel = controlUnit_io_cntrSels_4_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_4_io_cntrSels_decaySel = controlUnit_io_cntrSels_4_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_4_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_4_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_4_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_5_clock = clock;
  assign evalUnits_5_reset = reset;
  assign evalUnits_5_io_dataIn = evalMems_5_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_5_io_cntrSels_potSel = controlUnit_io_cntrSels_5_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_5_io_cntrSels_spikeSel = controlUnit_io_cntrSels_5_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_5_io_cntrSels_refracSel = controlUnit_io_cntrSels_5_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_5_io_cntrSels_decaySel = controlUnit_io_cntrSels_5_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_5_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_5_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_5_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_6_clock = clock;
  assign evalUnits_6_reset = reset;
  assign evalUnits_6_io_dataIn = evalMems_6_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_6_io_cntrSels_potSel = controlUnit_io_cntrSels_6_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_6_io_cntrSels_spikeSel = controlUnit_io_cntrSels_6_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_6_io_cntrSels_refracSel = controlUnit_io_cntrSels_6_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_6_io_cntrSels_decaySel = controlUnit_io_cntrSels_6_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_6_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_6_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_6_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalUnits_7_clock = clock;
  assign evalUnits_7_reset = reset;
  assign evalUnits_7_io_dataIn = evalMems_7_io_readData; // @[Neurons.scala 39:43]
  assign evalUnits_7_io_cntrSels_potSel = controlUnit_io_cntrSels_7_potSel; // @[Neurons.scala 43:43]
  assign evalUnits_7_io_cntrSels_spikeSel = controlUnit_io_cntrSels_7_spikeSel; // @[Neurons.scala 44:43]
  assign evalUnits_7_io_cntrSels_refracSel = controlUnit_io_cntrSels_7_refracSel; // @[Neurons.scala 45:43]
  assign evalUnits_7_io_cntrSels_decaySel = controlUnit_io_cntrSels_7_decaySel; // @[Neurons.scala 47:43]
  assign evalUnits_7_io_cntrSels_writeDataSel = controlUnit_io_cntrSels_7_writeDataSel; // @[Neurons.scala 46:43]
  assign evalUnits_7_io_evalEnable = controlUnit_io_evalEnable; // @[Neurons.scala 48:43]
  assign evalMems_0_clock = clock;
  assign evalMems_0_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_0_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_0_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_0_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_0_io_writeData = evalUnits_0_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_1_clock = clock;
  assign evalMems_1_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_1_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_1_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_1_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_1_io_writeData = evalUnits_1_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_2_clock = clock;
  assign evalMems_2_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_2_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_2_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_2_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_2_io_writeData = evalUnits_2_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_3_clock = clock;
  assign evalMems_3_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_3_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_3_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_3_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_3_io_writeData = evalUnits_3_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_4_clock = clock;
  assign evalMems_4_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_4_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_4_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_4_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_4_io_writeData = evalUnits_4_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_5_clock = clock;
  assign evalMems_5_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_5_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_5_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_5_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_5_io_writeData = evalUnits_5_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_6_clock = clock;
  assign evalMems_6_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_6_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_6_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_6_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_6_io_writeData = evalUnits_6_io_dataOut; // @[Neurons.scala 40:43]
  assign evalMems_7_clock = clock;
  assign evalMems_7_io_addr_sel = controlUnit_io_addr_sel; // @[Neurons.scala 50:43]
  assign evalMems_7_io_addr_pos = controlUnit_io_addr_pos; // @[Neurons.scala 50:43]
  assign evalMems_7_io_ena = controlUnit_io_ena; // @[Neurons.scala 52:43]
  assign evalMems_7_io_wr = controlUnit_io_wr; // @[Neurons.scala 51:43]
  assign evalMems_7_io_writeData = evalUnits_7_io_dataOut; // @[Neurons.scala 40:43]
endmodule
module NeuronCore_1(
  input         clock,
  input         reset,
  output        io_pmClkEn,
  input         io_newTS,
  input         io_grant,
  output        io_req,
  output [10:0] io_tx,
  input  [10:0] io_rx
);
  wire  interface__clock; // @[NeuronCore.scala 19:26]
  wire  interface__reset; // @[NeuronCore.scala 19:26]
  wire  interface__io_grant; // @[NeuronCore.scala 19:26]
  wire  interface__io_reqOut; // @[NeuronCore.scala 19:26]
  wire [10:0] interface__io_tx; // @[NeuronCore.scala 19:26]
  wire [10:0] interface__io_rx; // @[NeuronCore.scala 19:26]
  wire [9:0] interface__io_axonID; // @[NeuronCore.scala 19:26]
  wire  interface__io_valid; // @[NeuronCore.scala 19:26]
  wire [10:0] interface__io_spikeID; // @[NeuronCore.scala 19:26]
  wire  interface__io_ready; // @[NeuronCore.scala 19:26]
  wire  interface__io_reqIn; // @[NeuronCore.scala 19:26]
  wire  axonSystem_clock; // @[NeuronCore.scala 20:26]
  wire  axonSystem_reset; // @[NeuronCore.scala 20:26]
  wire [9:0] axonSystem_io_axonIn; // @[NeuronCore.scala 20:26]
  wire  axonSystem_io_axonValid; // @[NeuronCore.scala 20:26]
  wire  axonSystem_io_inOut; // @[NeuronCore.scala 20:26]
  wire [9:0] axonSystem_io_spikeCnt; // @[NeuronCore.scala 20:26]
  wire [9:0] axonSystem_io_rAddr; // @[NeuronCore.scala 20:26]
  wire  axonSystem_io_rEna; // @[NeuronCore.scala 20:26]
  wire [9:0] axonSystem_io_rData; // @[NeuronCore.scala 20:26]
  wire  spikeTrans_clock; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_reset; // @[NeuronCore.scala 21:26]
  wire [10:0] spikeTrans_io_data; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_ready; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_valid; // @[NeuronCore.scala 21:26]
  wire [4:0] spikeTrans_io_n; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_0; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_1; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_2; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_3; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_4; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_5; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_6; // @[NeuronCore.scala 21:26]
  wire  spikeTrans_io_spikes_7; // @[NeuronCore.scala 21:26]
  wire  neurons_clock; // @[NeuronCore.scala 22:26]
  wire  neurons_reset; // @[NeuronCore.scala 22:26]
  wire  neurons_io_done; // @[NeuronCore.scala 22:26]
  wire  neurons_io_newTS; // @[NeuronCore.scala 22:26]
  wire  neurons_io_inOut; // @[NeuronCore.scala 22:26]
  wire [9:0] neurons_io_spikeCnt; // @[NeuronCore.scala 22:26]
  wire [9:0] neurons_io_aAddr; // @[NeuronCore.scala 22:26]
  wire  neurons_io_aEna; // @[NeuronCore.scala 22:26]
  wire [9:0] neurons_io_aData; // @[NeuronCore.scala 22:26]
  wire [4:0] neurons_io_n; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_0; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_1; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_2; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_3; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_4; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_5; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_6; // @[NeuronCore.scala 22:26]
  wire  neurons_io_spikes_7; // @[NeuronCore.scala 22:26]
  BusInterface_3 interface_ ( // @[NeuronCore.scala 19:26]
    .clock(interface__clock),
    .reset(interface__reset),
    .io_grant(interface__io_grant),
    .io_reqOut(interface__io_reqOut),
    .io_tx(interface__io_tx),
    .io_rx(interface__io_rx),
    .io_axonID(interface__io_axonID),
    .io_valid(interface__io_valid),
    .io_spikeID(interface__io_spikeID),
    .io_ready(interface__io_ready),
    .io_reqIn(interface__io_reqIn)
  );
  AxonSystem axonSystem ( // @[NeuronCore.scala 20:26]
    .clock(axonSystem_clock),
    .reset(axonSystem_reset),
    .io_axonIn(axonSystem_io_axonIn),
    .io_axonValid(axonSystem_io_axonValid),
    .io_inOut(axonSystem_io_inOut),
    .io_spikeCnt(axonSystem_io_spikeCnt),
    .io_rAddr(axonSystem_io_rAddr),
    .io_rEna(axonSystem_io_rEna),
    .io_rData(axonSystem_io_rData)
  );
  TransmissionSystem_3 spikeTrans ( // @[NeuronCore.scala 21:26]
    .clock(spikeTrans_clock),
    .reset(spikeTrans_reset),
    .io_data(spikeTrans_io_data),
    .io_ready(spikeTrans_io_ready),
    .io_valid(spikeTrans_io_valid),
    .io_n(spikeTrans_io_n),
    .io_spikes_0(spikeTrans_io_spikes_0),
    .io_spikes_1(spikeTrans_io_spikes_1),
    .io_spikes_2(spikeTrans_io_spikes_2),
    .io_spikes_3(spikeTrans_io_spikes_3),
    .io_spikes_4(spikeTrans_io_spikes_4),
    .io_spikes_5(spikeTrans_io_spikes_5),
    .io_spikes_6(spikeTrans_io_spikes_6),
    .io_spikes_7(spikeTrans_io_spikes_7)
  );
  Neurons_1 neurons ( // @[NeuronCore.scala 22:26]
    .clock(neurons_clock),
    .reset(neurons_reset),
    .io_done(neurons_io_done),
    .io_newTS(neurons_io_newTS),
    .io_inOut(neurons_io_inOut),
    .io_spikeCnt(neurons_io_spikeCnt),
    .io_aAddr(neurons_io_aAddr),
    .io_aEna(neurons_io_aEna),
    .io_aData(neurons_io_aData),
    .io_n(neurons_io_n),
    .io_spikes_0(neurons_io_spikes_0),
    .io_spikes_1(neurons_io_spikes_1),
    .io_spikes_2(neurons_io_spikes_2),
    .io_spikes_3(neurons_io_spikes_3),
    .io_spikes_4(neurons_io_spikes_4),
    .io_spikes_5(neurons_io_spikes_5),
    .io_spikes_6(neurons_io_spikes_6),
    .io_spikes_7(neurons_io_spikes_7)
  );
  assign io_pmClkEn = ~neurons_io_done | interface__io_reqOut; // @[NeuronCore.scala 43:34]
  assign io_req = interface__io_reqOut; // @[NeuronCore.scala 25:27]
  assign io_tx = interface__io_tx; // @[NeuronCore.scala 26:27]
  assign interface__clock = clock;
  assign interface__reset = reset;
  assign interface__io_grant = io_grant; // @[NeuronCore.scala 24:27]
  assign interface__io_rx = io_rx; // @[NeuronCore.scala 27:27]
  assign interface__io_spikeID = spikeTrans_io_data; // @[NeuronCore.scala 30:27]
  assign interface__io_reqIn = spikeTrans_io_valid; // @[NeuronCore.scala 32:27]
  assign axonSystem_clock = clock;
  assign axonSystem_reset = reset;
  assign axonSystem_io_axonIn = interface__io_axonID; // @[NeuronCore.scala 28:27]
  assign axonSystem_io_axonValid = interface__io_valid; // @[NeuronCore.scala 29:27]
  assign axonSystem_io_inOut = neurons_io_inOut; // @[NeuronCore.scala 34:27]
  assign axonSystem_io_rAddr = neurons_io_aAddr; // @[NeuronCore.scala 36:27]
  assign axonSystem_io_rEna = neurons_io_aEna; // @[NeuronCore.scala 37:27]
  assign spikeTrans_clock = clock;
  assign spikeTrans_reset = reset;
  assign spikeTrans_io_ready = interface__io_ready; // @[NeuronCore.scala 31:27]
  assign spikeTrans_io_n = neurons_io_n; // @[NeuronCore.scala 40:27]
  assign spikeTrans_io_spikes_0 = neurons_io_spikes_0; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_1 = neurons_io_spikes_1; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_2 = neurons_io_spikes_2; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_3 = neurons_io_spikes_3; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_4 = neurons_io_spikes_4; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_5 = neurons_io_spikes_5; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_6 = neurons_io_spikes_6; // @[NeuronCore.scala 41:27]
  assign spikeTrans_io_spikes_7 = neurons_io_spikes_7; // @[NeuronCore.scala 41:27]
  assign neurons_clock = clock;
  assign neurons_reset = reset;
  assign neurons_io_newTS = io_newTS; // @[NeuronCore.scala 44:20]
  assign neurons_io_spikeCnt = axonSystem_io_spikeCnt; // @[NeuronCore.scala 35:27]
  assign neurons_io_aData = axonSystem_io_rData; // @[NeuronCore.scala 38:27]
endmodule
module OutputCore(
  input         clock,
  input         reset,
  output        io_pmClkEn,
  output        io_qWe,
  output [7:0]  io_qDi,
  input         io_qFull,
  input         io_grant,
  output        io_req,
  output [10:0] io_tx,
  input  [10:0] io_rx
);
  wire  interface__clock; // @[OutputCore.scala 23:25]
  wire  interface__reset; // @[OutputCore.scala 23:25]
  wire  interface__io_grant; // @[OutputCore.scala 23:25]
  wire  interface__io_reqOut; // @[OutputCore.scala 23:25]
  wire [10:0] interface__io_tx; // @[OutputCore.scala 23:25]
  wire [10:0] interface__io_rx; // @[OutputCore.scala 23:25]
  wire [9:0] interface__io_axonID; // @[OutputCore.scala 23:25]
  wire  interface__io_valid; // @[OutputCore.scala 23:25]
  wire [10:0] interface__io_spikeID; // @[OutputCore.scala 23:25]
  wire  interface__io_ready; // @[OutputCore.scala 23:25]
  wire  interface__io_reqIn; // @[OutputCore.scala 23:25]
  BusInterface_3 interface_ ( // @[OutputCore.scala 23:25]
    .clock(interface__clock),
    .reset(interface__reset),
    .io_grant(interface__io_grant),
    .io_reqOut(interface__io_reqOut),
    .io_tx(interface__io_tx),
    .io_rx(interface__io_rx),
    .io_axonID(interface__io_axonID),
    .io_valid(interface__io_valid),
    .io_spikeID(interface__io_spikeID),
    .io_ready(interface__io_ready),
    .io_reqIn(interface__io_reqIn)
  );
  assign io_pmClkEn = |io_rx | interface__io_valid; // @[OutputCore.scala 39:27]
  assign io_qWe = interface__io_valid & ~io_qFull; // @[OutputCore.scala 34:27]
  assign io_qDi = interface__io_axonID[7:0]; // @[OutputCore.scala 33:32]
  assign io_req = interface__io_reqOut; // @[OutputCore.scala 25:24]
  assign io_tx = interface__io_tx; // @[OutputCore.scala 26:24]
  assign interface__clock = clock;
  assign interface__reset = reset;
  assign interface__io_grant = io_grant; // @[OutputCore.scala 24:24]
  assign interface__io_rx = io_rx; // @[OutputCore.scala 27:24]
  assign interface__io_spikeID = 11'h0; // @[OutputCore.scala 29:24]
  assign interface__io_reqIn = 1'h0; // @[OutputCore.scala 28:24]
endmodule
module NeuromorphicProcessor(
  input   clock,
  input   reset,
  output  io_uartTx,
  input   io_uartRx
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
`endif // RANDOMIZE_REG_INIT
  wire  cBufTop_io_I; // @[NeuromorphicProcessor.scala 32:24]
  wire  cBufTop_io_CE; // @[NeuromorphicProcessor.scala 32:24]
  wire  cBufTop_io_O; // @[NeuromorphicProcessor.scala 32:24]
  wire  cBufCore_io_I; // @[NeuromorphicProcessor.scala 38:25]
  wire  cBufCore_io_CE; // @[NeuromorphicProcessor.scala 38:25]
  wire  cBufCore_io_O; // @[NeuromorphicProcessor.scala 38:25]
  wire  inC0Mem_io_clka; // @[NeuromorphicProcessor.scala 44:23]
  wire  inC0Mem_io_ena; // @[NeuromorphicProcessor.scala 44:23]
  wire  inC0Mem_io_wea; // @[NeuromorphicProcessor.scala 44:23]
  wire [8:0] inC0Mem_io_addra; // @[NeuromorphicProcessor.scala 44:23]
  wire [8:0] inC0Mem_io_dia; // @[NeuromorphicProcessor.scala 44:23]
  wire  inC0Mem_io_clkb; // @[NeuromorphicProcessor.scala 44:23]
  wire  inC0Mem_io_enb; // @[NeuromorphicProcessor.scala 44:23]
  wire [8:0] inC0Mem_io_addrb; // @[NeuromorphicProcessor.scala 44:23]
  wire [8:0] inC0Mem_io_dob; // @[NeuromorphicProcessor.scala 44:23]
  wire  inC1Mem_io_clka; // @[NeuromorphicProcessor.scala 50:23]
  wire  inC1Mem_io_ena; // @[NeuromorphicProcessor.scala 50:23]
  wire  inC1Mem_io_wea; // @[NeuromorphicProcessor.scala 50:23]
  wire [8:0] inC1Mem_io_addra; // @[NeuromorphicProcessor.scala 50:23]
  wire [8:0] inC1Mem_io_dia; // @[NeuromorphicProcessor.scala 50:23]
  wire  inC1Mem_io_clkb; // @[NeuromorphicProcessor.scala 50:23]
  wire  inC1Mem_io_enb; // @[NeuromorphicProcessor.scala 50:23]
  wire [8:0] inC1Mem_io_addrb; // @[NeuromorphicProcessor.scala 50:23]
  wire [8:0] inC1Mem_io_dob; // @[NeuromorphicProcessor.scala 50:23]
  wire  outMem_io_clki; // @[NeuromorphicProcessor.scala 56:22]
  wire  outMem_io_we; // @[NeuromorphicProcessor.scala 56:22]
  wire [7:0] outMem_io_datai; // @[NeuromorphicProcessor.scala 56:22]
  wire  outMem_io_full; // @[NeuromorphicProcessor.scala 56:22]
  wire  outMem_io_clko; // @[NeuromorphicProcessor.scala 56:22]
  wire  outMem_io_en; // @[NeuromorphicProcessor.scala 56:22]
  wire [7:0] outMem_io_datao; // @[NeuromorphicProcessor.scala 56:22]
  wire  outMem_io_empty; // @[NeuromorphicProcessor.scala 56:22]
  wire  outMem_io_rst; // @[NeuromorphicProcessor.scala 56:22]
  wire  offCC_clock; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_reset; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_io_tx; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_io_rx; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_io_inC0We; // @[NeuromorphicProcessor.scala 75:23]
  wire [8:0] offCC_io_inC0Addr; // @[NeuromorphicProcessor.scala 75:23]
  wire [8:0] offCC_io_inC0Di; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_io_inC1We; // @[NeuromorphicProcessor.scala 75:23]
  wire [8:0] offCC_io_inC1Addr; // @[NeuromorphicProcessor.scala 75:23]
  wire [8:0] offCC_io_inC1Di; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_io_qEn; // @[NeuromorphicProcessor.scala 75:23]
  wire [7:0] offCC_io_qData; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_io_qEmpty; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_io_inC0HSin; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_io_inC0HSout; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_io_inC1HSin; // @[NeuromorphicProcessor.scala 75:23]
  wire  offCC_io_inC1HSout; // @[NeuromorphicProcessor.scala 75:23]
  wire  arbiter_clock; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_reset; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_io_reqs_0; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_io_reqs_1; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_io_reqs_2; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_io_reqs_3; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_io_reqs_4; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_io_grants_0; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_io_grants_1; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_io_grants_2; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_io_grants_3; // @[NeuromorphicProcessor.scala 104:25]
  wire  arbiter_io_grants_4; // @[NeuromorphicProcessor.scala 104:25]
  wire  inCores_0_clock; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_0_reset; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_0_io_pmClkEn; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_0_io_newTS; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_0_io_offCCHSin; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_0_io_offCCHSout; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_0_io_memEn; // @[NeuromorphicProcessor.scala 110:46]
  wire [8:0] inCores_0_io_memAddr; // @[NeuromorphicProcessor.scala 110:46]
  wire [8:0] inCores_0_io_memDo; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_0_io_grant; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_0_io_req; // @[NeuromorphicProcessor.scala 110:46]
  wire [10:0] inCores_0_io_tx; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_1_clock; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_1_reset; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_1_io_pmClkEn; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_1_io_newTS; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_1_io_offCCHSin; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_1_io_offCCHSout; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_1_io_memEn; // @[NeuromorphicProcessor.scala 110:46]
  wire [8:0] inCores_1_io_memAddr; // @[NeuromorphicProcessor.scala 110:46]
  wire [8:0] inCores_1_io_memDo; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_1_io_grant; // @[NeuromorphicProcessor.scala 110:46]
  wire  inCores_1_io_req; // @[NeuromorphicProcessor.scala 110:46]
  wire [10:0] inCores_1_io_tx; // @[NeuromorphicProcessor.scala 110:46]
  wire  neuCores_0_clock; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_0_reset; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_0_io_pmClkEn; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_0_io_newTS; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_0_io_grant; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_0_io_req; // @[NeuromorphicProcessor.scala 111:47]
  wire [10:0] neuCores_0_io_tx; // @[NeuromorphicProcessor.scala 111:47]
  wire [10:0] neuCores_0_io_rx; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_1_clock; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_1_reset; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_1_io_pmClkEn; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_1_io_newTS; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_1_io_grant; // @[NeuromorphicProcessor.scala 111:47]
  wire  neuCores_1_io_req; // @[NeuromorphicProcessor.scala 111:47]
  wire [10:0] neuCores_1_io_tx; // @[NeuromorphicProcessor.scala 111:47]
  wire [10:0] neuCores_1_io_rx; // @[NeuromorphicProcessor.scala 111:47]
  wire  outCore_clock; // @[NeuromorphicProcessor.scala 112:25]
  wire  outCore_reset; // @[NeuromorphicProcessor.scala 112:25]
  wire  outCore_io_pmClkEn; // @[NeuromorphicProcessor.scala 112:25]
  wire  outCore_io_qWe; // @[NeuromorphicProcessor.scala 112:25]
  wire [7:0] outCore_io_qDi; // @[NeuromorphicProcessor.scala 112:25]
  wire  outCore_io_qFull; // @[NeuromorphicProcessor.scala 112:25]
  wire  outCore_io_grant; // @[NeuromorphicProcessor.scala 112:25]
  wire  outCore_io_req; // @[NeuromorphicProcessor.scala 112:25]
  wire [10:0] outCore_io_tx; // @[NeuromorphicProcessor.scala 112:25]
  wire [10:0] outCore_io_rx; // @[NeuromorphicProcessor.scala 112:25]
  reg [5:0] enCnt; // @[NeuromorphicProcessor.scala 23:23]
  wire  enVec_0 = inCores_0_io_pmClkEn; // @[NeuromorphicProcessor.scala 107:21 146:23]
  wire  enVec_1 = inCores_1_io_pmClkEn; // @[NeuromorphicProcessor.scala 107:21 146:23]
  wire  enVec_2 = neuCores_0_io_pmClkEn; // @[NeuromorphicProcessor.scala 107:21 152:23]
  wire  enVec_3 = neuCores_1_io_pmClkEn; // @[NeuromorphicProcessor.scala 107:21 152:23]
  wire  enVec_4 = outCore_io_pmClkEn; // @[NeuromorphicProcessor.scala 107:21 158:23]
  (* dont_touch = "yes" *)
  wire  clkEn = enVec_0 | enVec_1 | (enVec_2 | enVec_3) | enVec_4; // @[NeuromorphicProcessor.scala 162:33]
  wire  _T_3 = enCnt != 6'h0; // @[NeuromorphicProcessor.scala 26:30]
  wire [5:0] _enCnt_T_1 = enCnt - 6'h1; // @[NeuromorphicProcessor.scala 27:20]
  wire  topClock = cBufTop_io_O; // @[NeuromorphicProcessor.scala 31:22 35:12]
  reg [16:0] tsCycleCnt; // @[NeuromorphicProcessor.scala 70:29]
  (* dont_touch = "yes" *)
  wire  newTS = tsCycleCnt == 17'h0; // @[NeuromorphicProcessor.scala 71:25]
  wire [16:0] _tsCycleCnt_T_1 = tsCycleCnt - 17'h1; // @[NeuromorphicProcessor.scala 72:57]
  wire [10:0] txVec_0 = inCores_0_io_tx; // @[NeuromorphicProcessor.scala 105:21 145:23]
  wire [10:0] txVec_1 = inCores_1_io_tx; // @[NeuromorphicProcessor.scala 105:21 145:23]
  wire [10:0] _busTx_T = txVec_0 | txVec_1; // @[NeuromorphicProcessor.scala 161:33]
  wire [10:0] txVec_2 = neuCores_0_io_tx; // @[NeuromorphicProcessor.scala 105:21 151:23]
  wire [10:0] txVec_3 = neuCores_1_io_tx; // @[NeuromorphicProcessor.scala 105:21 151:23]
  wire [10:0] _busTx_T_1 = txVec_2 | txVec_3; // @[NeuromorphicProcessor.scala 161:33]
  wire [10:0] _busTx_T_2 = _busTx_T | _busTx_T_1; // @[NeuromorphicProcessor.scala 161:33]
  wire [10:0] txVec_4 = outCore_io_tx; // @[NeuromorphicProcessor.scala 105:21 157:23]
  ClockBufferVerilog cBufTop ( // @[NeuromorphicProcessor.scala 32:24]
    .io_I(cBufTop_io_I),
    .io_CE(cBufTop_io_CE),
    .io_O(cBufTop_io_O)
  );
  ClockBufferVerilog cBufCore ( // @[NeuromorphicProcessor.scala 38:25]
    .io_I(cBufCore_io_I),
    .io_CE(cBufCore_io_CE),
    .io_O(cBufCore_io_O)
  );
  TrueDualPortMemory inC0Mem ( // @[NeuromorphicProcessor.scala 44:23]
    .io_clka(inC0Mem_io_clka),
    .io_ena(inC0Mem_io_ena),
    .io_wea(inC0Mem_io_wea),
    .io_addra(inC0Mem_io_addra),
    .io_dia(inC0Mem_io_dia),
    .io_clkb(inC0Mem_io_clkb),
    .io_enb(inC0Mem_io_enb),
    .io_addrb(inC0Mem_io_addrb),
    .io_dob(inC0Mem_io_dob)
  );
  TrueDualPortMemory inC1Mem ( // @[NeuromorphicProcessor.scala 50:23]
    .io_clka(inC1Mem_io_clka),
    .io_ena(inC1Mem_io_ena),
    .io_wea(inC1Mem_io_wea),
    .io_addra(inC1Mem_io_addra),
    .io_dia(inC1Mem_io_dia),
    .io_clkb(inC1Mem_io_clkb),
    .io_enb(inC1Mem_io_enb),
    .io_addrb(inC1Mem_io_addrb),
    .io_dob(inC1Mem_io_dob)
  );
  TrueDualPortFIFO outMem ( // @[NeuromorphicProcessor.scala 56:22]
    .io_clki(outMem_io_clki),
    .io_we(outMem_io_we),
    .io_datai(outMem_io_datai),
    .io_full(outMem_io_full),
    .io_clko(outMem_io_clko),
    .io_en(outMem_io_en),
    .io_datao(outMem_io_datao),
    .io_empty(outMem_io_empty),
    .io_rst(outMem_io_rst)
  );
  OffChipCom offCC ( // @[NeuromorphicProcessor.scala 75:23]
    .clock(offCC_clock),
    .reset(offCC_reset),
    .io_tx(offCC_io_tx),
    .io_rx(offCC_io_rx),
    .io_inC0We(offCC_io_inC0We),
    .io_inC0Addr(offCC_io_inC0Addr),
    .io_inC0Di(offCC_io_inC0Di),
    .io_inC1We(offCC_io_inC1We),
    .io_inC1Addr(offCC_io_inC1Addr),
    .io_inC1Di(offCC_io_inC1Di),
    .io_qEn(offCC_io_qEn),
    .io_qData(offCC_io_qData),
    .io_qEmpty(offCC_io_qEmpty),
    .io_inC0HSin(offCC_io_inC0HSin),
    .io_inC0HSout(offCC_io_inC0HSout),
    .io_inC1HSin(offCC_io_inC1HSin),
    .io_inC1HSout(offCC_io_inC1HSout)
  );
  BusArbiter arbiter ( // @[NeuromorphicProcessor.scala 104:25]
    .clock(arbiter_clock),
    .reset(arbiter_reset),
    .io_reqs_0(arbiter_io_reqs_0),
    .io_reqs_1(arbiter_io_reqs_1),
    .io_reqs_2(arbiter_io_reqs_2),
    .io_reqs_3(arbiter_io_reqs_3),
    .io_reqs_4(arbiter_io_reqs_4),
    .io_grants_0(arbiter_io_grants_0),
    .io_grants_1(arbiter_io_grants_1),
    .io_grants_2(arbiter_io_grants_2),
    .io_grants_3(arbiter_io_grants_3),
    .io_grants_4(arbiter_io_grants_4)
  );
  InputCore inCores_0 ( // @[NeuromorphicProcessor.scala 110:46]
    .clock(inCores_0_clock),
    .reset(inCores_0_reset),
    .io_pmClkEn(inCores_0_io_pmClkEn),
    .io_newTS(inCores_0_io_newTS),
    .io_offCCHSin(inCores_0_io_offCCHSin),
    .io_offCCHSout(inCores_0_io_offCCHSout),
    .io_memEn(inCores_0_io_memEn),
    .io_memAddr(inCores_0_io_memAddr),
    .io_memDo(inCores_0_io_memDo),
    .io_grant(inCores_0_io_grant),
    .io_req(inCores_0_io_req),
    .io_tx(inCores_0_io_tx)
  );
  InputCore_1 inCores_1 ( // @[NeuromorphicProcessor.scala 110:46]
    .clock(inCores_1_clock),
    .reset(inCores_1_reset),
    .io_pmClkEn(inCores_1_io_pmClkEn),
    .io_newTS(inCores_1_io_newTS),
    .io_offCCHSin(inCores_1_io_offCCHSin),
    .io_offCCHSout(inCores_1_io_offCCHSout),
    .io_memEn(inCores_1_io_memEn),
    .io_memAddr(inCores_1_io_memAddr),
    .io_memDo(inCores_1_io_memDo),
    .io_grant(inCores_1_io_grant),
    .io_req(inCores_1_io_req),
    .io_tx(inCores_1_io_tx)
  );
  NeuronCore neuCores_0 ( // @[NeuromorphicProcessor.scala 111:47]
    .clock(neuCores_0_clock),
    .reset(neuCores_0_reset),
    .io_pmClkEn(neuCores_0_io_pmClkEn),
    .io_newTS(neuCores_0_io_newTS),
    .io_grant(neuCores_0_io_grant),
    .io_req(neuCores_0_io_req),
    .io_tx(neuCores_0_io_tx),
    .io_rx(neuCores_0_io_rx)
  );
  NeuronCore_1 neuCores_1 ( // @[NeuromorphicProcessor.scala 111:47]
    .clock(neuCores_1_clock),
    .reset(neuCores_1_reset),
    .io_pmClkEn(neuCores_1_io_pmClkEn),
    .io_newTS(neuCores_1_io_newTS),
    .io_grant(neuCores_1_io_grant),
    .io_req(neuCores_1_io_req),
    .io_tx(neuCores_1_io_tx),
    .io_rx(neuCores_1_io_rx)
  );
  OutputCore outCore ( // @[NeuromorphicProcessor.scala 112:25]
    .clock(outCore_clock),
    .reset(outCore_reset),
    .io_pmClkEn(outCore_io_pmClkEn),
    .io_qWe(outCore_io_qWe),
    .io_qDi(outCore_io_qDi),
    .io_qFull(outCore_io_qFull),
    .io_grant(outCore_io_grant),
    .io_req(outCore_io_req),
    .io_tx(outCore_io_tx),
    .io_rx(outCore_io_rx)
  );
  assign io_uartTx = offCC_io_tx; // @[NeuromorphicProcessor.scala 76:15]
  assign cBufTop_io_I = clock; // @[NeuromorphicProcessor.scala 34:17]
  assign cBufTop_io_CE = 1'h1; // @[NeuromorphicProcessor.scala 33:17]
  assign cBufCore_io_I = clock; // @[NeuromorphicProcessor.scala 40:18]
  assign cBufCore_io_CE = newTS | _T_3; // @[NeuromorphicProcessor.scala 29:22]
  assign inC0Mem_io_clka = cBufTop_io_O; // @[NeuromorphicProcessor.scala 31:22 35:12]
  assign inC0Mem_io_ena = offCC_io_inC0We; // @[NeuromorphicProcessor.scala 85:20]
  assign inC0Mem_io_wea = offCC_io_inC0We; // @[NeuromorphicProcessor.scala 86:20]
  assign inC0Mem_io_addra = offCC_io_inC0Addr; // @[NeuromorphicProcessor.scala 87:22]
  assign inC0Mem_io_dia = offCC_io_inC0Di; // @[NeuromorphicProcessor.scala 84:20]
  assign inC0Mem_io_clkb = cBufCore_io_O; // @[NeuromorphicProcessor.scala 37:23 41:13]
  assign inC0Mem_io_enb = inCores_0_io_memEn; // @[NeuromorphicProcessor.scala 116:25]
  assign inC0Mem_io_addrb = inCores_0_io_memAddr; // @[NeuromorphicProcessor.scala 117:25]
  assign inC1Mem_io_clka = cBufTop_io_O; // @[NeuromorphicProcessor.scala 31:22 35:12]
  assign inC1Mem_io_ena = offCC_io_inC1We; // @[NeuromorphicProcessor.scala 90:20]
  assign inC1Mem_io_wea = offCC_io_inC1We; // @[NeuromorphicProcessor.scala 91:20]
  assign inC1Mem_io_addra = offCC_io_inC1Addr; // @[NeuromorphicProcessor.scala 92:22]
  assign inC1Mem_io_dia = offCC_io_inC1Di; // @[NeuromorphicProcessor.scala 89:20]
  assign inC1Mem_io_clkb = cBufCore_io_O; // @[NeuromorphicProcessor.scala 37:23 41:13]
  assign inC1Mem_io_enb = inCores_1_io_memEn; // @[NeuromorphicProcessor.scala 123:25]
  assign inC1Mem_io_addrb = inCores_1_io_memAddr; // @[NeuromorphicProcessor.scala 124:25]
  assign outMem_io_clki = cBufCore_io_O; // @[NeuromorphicProcessor.scala 37:23 41:13]
  assign outMem_io_we = outCore_io_qWe; // @[NeuromorphicProcessor.scala 133:22]
  assign outMem_io_datai = outCore_io_qDi; // @[NeuromorphicProcessor.scala 134:22]
  assign outMem_io_clko = cBufTop_io_O; // @[NeuromorphicProcessor.scala 31:22 35:12]
  assign outMem_io_en = offCC_io_qEn; // @[NeuromorphicProcessor.scala 94:22]
  assign outMem_io_rst = reset; // @[NeuromorphicProcessor.scala 59:27]
  assign offCC_clock = cBufTop_io_O; // @[NeuromorphicProcessor.scala 31:22 35:12]
  assign offCC_reset = reset;
  assign offCC_io_rx = io_uartRx; // @[NeuromorphicProcessor.scala 77:17]
  assign offCC_io_qData = outMem_io_datao; // @[NeuromorphicProcessor.scala 95:22]
  assign offCC_io_qEmpty = outMem_io_empty; // @[NeuromorphicProcessor.scala 96:22]
  assign offCC_io_inC0HSin = inCores_0_io_offCCHSout; // @[NeuromorphicProcessor.scala 115:14 62:22]
  assign offCC_io_inC1HSin = inCores_1_io_offCCHSout; // @[NeuromorphicProcessor.scala 122:14 63:22]
  assign arbiter_clock = cBufCore_io_O; // @[NeuromorphicProcessor.scala 37:23 41:13]
  assign arbiter_reset = reset;
  assign arbiter_io_reqs_0 = inCores_0_io_req; // @[NeuromorphicProcessor.scala 143:33]
  assign arbiter_io_reqs_1 = inCores_1_io_req; // @[NeuromorphicProcessor.scala 143:33]
  assign arbiter_io_reqs_2 = neuCores_0_io_req; // @[NeuromorphicProcessor.scala 149:33]
  assign arbiter_io_reqs_3 = neuCores_1_io_req; // @[NeuromorphicProcessor.scala 149:33]
  assign arbiter_io_reqs_4 = outCore_io_req; // @[NeuromorphicProcessor.scala 155:33]
  assign inCores_0_clock = cBufCore_io_O; // @[NeuromorphicProcessor.scala 37:23 41:13]
  assign inCores_0_reset = reset;
  assign inCores_0_io_newTS = tsCycleCnt == 17'h0; // @[NeuromorphicProcessor.scala 71:25]
  assign inCores_0_io_offCCHSin = offCC_io_inC0HSout; // @[NeuromorphicProcessor.scala 64:24 80:16]
  assign inCores_0_io_memDo = inC0Mem_io_dob; // @[NeuromorphicProcessor.scala 118:25]
  assign inCores_0_io_grant = arbiter_io_grants_0; // @[NeuromorphicProcessor.scala 144:22]
  assign inCores_1_clock = cBufCore_io_O; // @[NeuromorphicProcessor.scala 37:23 41:13]
  assign inCores_1_reset = reset;
  assign inCores_1_io_newTS = tsCycleCnt == 17'h0; // @[NeuromorphicProcessor.scala 71:25]
  assign inCores_1_io_offCCHSin = offCC_io_inC1HSout; // @[NeuromorphicProcessor.scala 65:24 81:16]
  assign inCores_1_io_memDo = inC1Mem_io_dob; // @[NeuromorphicProcessor.scala 125:25]
  assign inCores_1_io_grant = arbiter_io_grants_1; // @[NeuromorphicProcessor.scala 144:22]
  assign neuCores_0_clock = cBufCore_io_O; // @[NeuromorphicProcessor.scala 37:23 41:13]
  assign neuCores_0_reset = reset;
  assign neuCores_0_io_newTS = tsCycleCnt == 17'h0; // @[NeuromorphicProcessor.scala 71:25]
  assign neuCores_0_io_grant = arbiter_io_grants_2; // @[NeuromorphicProcessor.scala 150:22]
  assign neuCores_0_io_rx = _busTx_T_2 | txVec_4; // @[NeuromorphicProcessor.scala 161:33]
  assign neuCores_1_clock = cBufCore_io_O; // @[NeuromorphicProcessor.scala 37:23 41:13]
  assign neuCores_1_reset = reset;
  assign neuCores_1_io_newTS = tsCycleCnt == 17'h0; // @[NeuromorphicProcessor.scala 71:25]
  assign neuCores_1_io_grant = arbiter_io_grants_3; // @[NeuromorphicProcessor.scala 150:22]
  assign neuCores_1_io_rx = _busTx_T_2 | txVec_4; // @[NeuromorphicProcessor.scala 161:33]
  assign outCore_clock = cBufCore_io_O; // @[NeuromorphicProcessor.scala 37:23 41:13]
  assign outCore_reset = reset;
  assign outCore_io_qFull = outMem_io_full; // @[NeuromorphicProcessor.scala 135:22]
  assign outCore_io_grant = arbiter_io_grants_4; // @[NeuromorphicProcessor.scala 156:22]
  assign outCore_io_rx = _busTx_T_2 | txVec_4; // @[NeuromorphicProcessor.scala 161:33]
  always @(posedge clock) begin
    if (reset) begin // @[NeuromorphicProcessor.scala 23:23]
      enCnt <= 6'h32; // @[NeuromorphicProcessor.scala 23:23]
    end else if (clkEn & enCnt != 6'h32) begin // @[NeuromorphicProcessor.scala 24:35]
      enCnt <= 6'h32; // @[NeuromorphicProcessor.scala 25:11]
    end else if (~clkEn & enCnt != 6'h0) begin // @[NeuromorphicProcessor.scala 26:39]
      enCnt <= _enCnt_T_1; // @[NeuromorphicProcessor.scala 27:11]
    end
  end
  always @(posedge topClock) begin
    if (reset) begin // @[NeuromorphicProcessor.scala 70:29]
      tsCycleCnt <= 17'h13880; // @[NeuromorphicProcessor.scala 70:29]
    end else if (newTS) begin // @[NeuromorphicProcessor.scala 72:22]
      tsCycleCnt <= 17'h13880;
    end else begin
      tsCycleCnt <= _tsCycleCnt_T_1;
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  enCnt = _RAND_0[5:0];
  _RAND_1 = {1{`RANDOM}};
  tsCycleCnt = _RAND_1[16:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
