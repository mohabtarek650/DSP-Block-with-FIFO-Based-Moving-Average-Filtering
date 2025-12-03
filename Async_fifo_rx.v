module Async_fifo #(
  parameter D_SIZE = 8,   // Data size
  parameter F_DEPTH = 8,  // FIFO depth
  parameter P_SIZE = 4    // Pointer width
)(
   input                    i_w_clk,   // Write domain clock
   input                    i_w_rstn,  // Write domain active low reset  
   input                    i_w_inc,   // Write enable
   input                    i_r_clk,   // Read domain clock
   input                    i_r_rstn,  // Read domain active low reset 
   input                    i_r_inc,   // Read enable
   input   [D_SIZE-1:0]     i_w_data,  // Write data bus 
   output  [D_SIZE-1:0]     o_r_data,  // Read data bus
   output                   o_full,    // FIFO full flag
   output                   o_empty    // FIFO empty flag
);

  // Internal signals
  reg [D_SIZE-1:0] mem [0:F_DEPTH-1];  // FIFO memory array
  reg [P_SIZE-1:0] w_ptr, r_ptr;       // Write and read pointers
  reg [P_SIZE:0]   fifo_count;         // FIFO count to track occupancy

  // Write operation
  always @(posedge i_w_clk or negedge i_w_rstn) begin
    if (!i_w_rstn)
      w_ptr <= 0;
    else if (i_w_inc && !o_full) begin
      mem[w_ptr] <= i_w_data;
      w_ptr <= w_ptr + 1;
    end
  end

  // Read operation
  always @(posedge i_r_clk or negedge i_r_rstn) begin
    if (!i_r_rstn)
      r_ptr <= 0;
    else if (i_r_inc && !o_empty) begin
      r_ptr <= r_ptr + 1;
    end
  end
  
  // FIFO occupancy counter
  always @(posedge i_w_clk or posedge i_r_clk or negedge i_w_rstn or negedge i_r_rstn) begin
    if (!i_w_rstn || !i_r_rstn)
      fifo_count <= 0;
    else if (i_w_inc && !o_full && !(i_r_inc && !o_empty))
      fifo_count <= fifo_count + 1;
    else if (i_r_inc && !o_empty && !(i_w_inc && !o_full))
      fifo_count <= fifo_count - 1;
  end

  // Full and Empty flags
  assign o_full  = (fifo_count == F_DEPTH);
  assign o_empty = (fifo_count == 0);
  assign o_r_data = mem[r_ptr];

endmodule
