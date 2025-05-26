`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.05.2025 10:53:10
// Design Name: 
// Module Name: write_buffer_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_W_FIFO_design;

  // Parameters
  localparam FIFO_DEPTH   = 128;
  localparam DATA_WIDTH   = 32;
  localparam STRB_WIDTH   = DATA_WIDTH/8;
  localparam FIFO_WIDTH   = DATA_WIDTH + STRB_WIDTH + 1;

  // Clock and Reset
  logic wr_clk = 0;
  logic rd_clk = 0;
  logic rst    = 1;

  always #5 wr_clk = ~wr_clk;  // 100 MHz
  always #6 rd_clk = ~rd_clk;  // Different domain to test dual-clock

  // Control Signals
  logic wr_en, rd_en;
  logic w_fifo_full, w_fifo_empty;

  // Master input signals (from interconnect)
  logic [DATA_WIDTH-1:0] w_data_in;
  logic [STRB_WIDTH-1:0] w_strb_in;
  logic                  wvalid_in;
  logic                  wready_out;

  // Slave interface (to memory controller)
  logic [DATA_WIDTH-1:0] w_data_out;
  logic [STRB_WIDTH-1:0] w_strb_out;
  logic                  wvalid_out;
  logic                  wready_in;

  // Instantiate DUT
  W_FIFO_design #(
    .FIFO_DEPTH(FIFO_DEPTH),
    .DATA_WIDTH(DATA_WIDTH),
    .STRB_WIDTH(STRB_WIDTH)
  ) dut (
    .W_fifo_write_clk(wr_clk),
    .W_fifo_read_clk(rd_clk),
    .W_fifo_rst(rst),
    .W_fifo_w_en(wr_en),
    .W_fifo_r_en(rd_en),
    .W_fifo_full(w_fifo_full),
    .W_fifo_empty(w_fifo_empty),

    .in_fifo_WDATA(w_data_in),
    .in_fifo_WSTRB(w_strb_in),
    .in_fifo_WLAST(w_last_in),
    .in_fifo_WVALID(wvalid_in),
    .in_fifo_WREADY(wready_in), // from slave

    .out_fifo_WDATA(w_data_out),
    .out_fifo_WSTRB(w_strb_out),
    .out_fifo_WLAST(w_last_out),
    .out_fifo_WVALID(wvalid_out),
    .out_fifo_WREADY(wready_out) // to master
  );
integer i=0;
  // Testbench Process
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    // Initial values
    wr_en        = 0;
    rd_en        = 0;
    wvalid_in   = 0;
    wready_in   = 0;
    rst          = 1;

    #20;
    rst = 0;
    // Drive a few AW transactions into FIFO
    repeat (248) begin
      @(posedge wr_clk);
      w_data_in   = $random;
      w_strb_in   = $random;
      wvalid_in  = 1;
      wr_en       = 1;
      
      // Wait for FIFO to say ready
      wait (wready_out);
      @(posedge wr_clk);
      wvalid_in = 0;
      wr_en      = 0;
      i=i+1;
    end

    // Now simulate the memory controller reading from FIFO
    
    

    #50;
    $display("Simulation complete");
    $finish;
  end

    always@(posedge wr_clk)
        begin
           if(i>0 && i<128)
            begin
               
                  @(posedge rd_clk);
                  rd_en = 1;
                  wready_in = 1; // slave is ready to accept
                  @(posedge rd_clk);
                  rd_en = 0;
                  wready_in = 0;
                
            end 
        end

endmodule



