module top_module #(parameter BUS_WIDTH = 8 , D_SIZE = 16 , DATA_WIDTH = 32, TAP_SIZE=4)(

input  wire                    clk_ahb,
input  wire                    rst_ahb,
input  wire                    clk_adc,
input  wire                    rst_adc,
input  wire                    i_hready,
input  wire                    i_htrans,
input  wire [2:0]              i_hsize,
input  wire                    i_hwrite,
input  wire [DATA_WIDTH-1:0]   i_haddr,
input  wire [DATA_WIDTH-1:0]   i_hwdata,
input  wire                    i_hselx,
output wire                    o_hreadyout,
output wire                    o_hresp,
output wire [DATA_WIDTH-1:0]   o_hrdata,
input  wire [BUS_WIDTH-1:0]     i_adc_data,
output  wire [BUS_WIDTH-1:0]     o_dac_data,
output wire                        irq         

);

wire      [BUS_WIDTH-1:0]   adc_data_top;
wire                        i_full_top;              
wire                        i_empty_top;
wire                        i_full_2_top;              
wire                        i_empty_2_top;
wire                        i_full_tx_top;              
wire                        i_empty_tx_top;
wire                        mode_sel_rx_top;
wire                        mode_sel_tx_top;
wire    [BUS_WIDTH-1:0]    read_adc_rx_top;
wire    [BUS_WIDTH-1:0]    write_dac_tx_top;
wire                        enable_interrupt_rx_top;
wire     [1:0]              dsp_stat_rx_top;
wire     [3:0]              dsp_stat_tx_top;
wire     [1:0]              fifo_level_rx;
wire     [1:0]              fifo_level_tx;
wire    [BUS_WIDTH-1:0]     i_rd_data;
wire                        o_w_inc;             
wire                        o_rd_inc; 
wire    [BUS_WIDTH-1:0]     i_rd_data_tx_top;
wire                        o_w_inc_tx_top;             
wire                        o_rd_inc_tx_top; 
wire    [BUS_WIDTH-1:0]     i_rd_data_2_top;
wire                        o_w_inc_2_top;             
wire                        o_rd_inc_2_top; 
wire                        state_register_rx;
wire                        state_register_tx;
wire     [BUS_WIDTH+1:0]    o_w_data;   
wire     [BUS_WIDTH+1:0]    o_w_data_tx_top; 
wire     [BUS_WIDTH+1:0]    o_w_data_2_top;        

wire                    i_ready;
wire                    i_rd_valid;
wire [DATA_WIDTH-1:0]   i_rd_data_mem;
wire                    o_valid;
wire                    o_rd0_wr1;
wire [DATA_WIDTH-1:0]   o_wr_data;
wire [DATA_WIDTH-1:0]   o_addr;


ahb_slave u5_ahb_slave (
.i_clk_ahb(clk_ahb),
.i_rstn_ahb(rst_ahb),
.i_hready(i_hready),
.i_htrans(i_htrans),
.i_hsize(i_hsize),
.i_hwrite(i_hwrite),
.i_haddr(i_haddr),
.i_hwdata(i_hwdata),
.i_hselx(i_hselx),
.i_ready(i_ready),
.i_rd_valid(i_rd_valid),
.i_rd_data(i_rd_data_mem),
.o_valid(o_valid),
.o_rd0_wr1(o_rd0_wr1),
.o_wr_data(o_wr_data),
.o_addr(o_addr),
.o_hreadyout(o_hreadyout),
.o_hresp(o_hresp),
.o_hrdata(o_hrdata)
    
);

Async_fifo_rx u0_Async_fifo_rx(
.i_w_clk(clk_ahb),              
.i_w_rstn(rst_ahb),           
.i_w_inc(o_w_inc),               
.i_r_clk(clk_ahb),              
.i_r_rstn(rst_ahb),            
.i_r_inc(o_rd_inc),         
.i_w_data(o_w_data),             
.o_r_data(i_rd_data),             
.o_full(i_full_top),               
.o_empty(i_empty_top)              

);

dsp_adc u1_dsp_adc(

.clk(clk_ahb),
.rst(rst_ahb),
.adc_data(adc_data_top),
.i_full(i_full_top),            
.i_empty(i_empty_top),
.mode_sel_rx(mode_sel_rx_top),
.read_adc_rx(read_adc_rx_top),
.enable_interrupt_0(enable_interrupt_rx_top),
.dsp_stat(dsp_stat_rx_top),
.fifo_level_rx(fifo_level_rx),
.i_rd_data(i_rd_data),
.o_w_inc(o_w_inc),            
.o_rd_inc(o_rd_inc), 
.irq(irq),             
.state_register_rx(state_register_rx),
.o_w_data(o_w_data)          

);


DATA_SYNC u2_DATA_SYNC( 
.CLK(clk_ahb),
.RST(rst_ahb),
.unsync_bus(i_adc_data),
.sync_bus(adc_data_top)
);

RegFile u3_RegFile(
   
.clk(clk_ahb),
.rst(rst_ahb),
.i_rd0_wr1(o_rd0_wr1),
.i_valid(o_valid),
.i_addr(o_addr),
.i_data(o_wr_data),
.o_rd_data(i_rd_data_mem),
.o_rd_valid(i_rd_valid),
.o_ready(i_ready),
.mode_sel_rx(mode_sel_rx_top),
.mode_sel_tx(mode_sel_tx_top),
.dsp_stat_rx(dsp_stat_rx_top),
.dsp_stat_tx(dsp_stat_tx_top),
.write_dac(write_dac_tx_top),
.read_adc(read_adc_rx_top),
.fifo_level_rx(fifo_level_rx),
.fifo_level_tx(fifo_level_tx),
.state_register_rx(state_register_rx),
.state_register_tx(state_register_tx),
.enable_interrupt_rx(enable_interrupt_rx_top)
);
/////////////////////////////////////////////////////////////
dsp_dac u0_dsp_dac(
.clk(clk_ahb),
.rst(rst_ahb),
.clk_adc(clk_adc),              
.rst_adc(rst_adc), 
.i_vaild_reg(o_valid),
.i_address_reg(o_addr),
.i_full(i_full_2_top),               // fifo full flag
.i_empty(i_empty_2_top),
.i_full_tx(i_full_tx_top),               // fifo full flag
.i_empty_tx(i_empty_tx_top),
.mode_sel_tx(mode_sel_tx_top),
.write_dac_tx(write_dac_tx_top), // mem
.dsp_stat(dsp_stat_tx_top),
.fifo_level_tx(fifo_level_tx),
.i_rd_data(i_rd_data_2_top),
.o_w_inc(o_w_inc_2_top),              // write control signal 
.o_rd_inc(o_rd_inc_2_top), 
.i_rd_data_tx(i_rd_data_tx_top),
.o_w_inc_tx(o_w_inc_tx_top),              // write control signal 
.o_rd_inc_tx(o_rd_inc_tx_top), 
.state_register_tx(state_register_tx),
.o_w_data(o_w_data_2_top),           // write data bus 
.o_w_data_tx(o_w_data_tx_top),  //fifo tx write 
.out_data(o_dac_data)
);

Async_fifo u0_Async_fifo_tx(
.i_w_clk(clk_ahb),              
.i_w_rstn(rst_ahb),           
.i_w_inc(o_w_inc_tx_top),               
.i_r_clk(clk_ahb),              
.i_r_rstn(rst_ahb),            
.i_r_inc(o_rd_inc_tx_top),         
.i_w_data(o_w_data_tx_top),             
.o_r_data(i_rd_data_tx_top),             
.o_full(i_full_tx_top),               
.o_empty(i_empty_tx_top)              

);


Async_fifo u0_Async_fifo(
.i_w_clk(clk_ahb),              
.i_w_rstn(rst_ahb),           
.i_w_inc(o_w_inc_2_top),               
.i_r_clk(clk_ahb),              
.i_r_rstn(rst_adc),            
.i_r_inc(o_rd_inc_2_top),         
.i_w_data(o_w_data_2_top),             
.o_r_data(i_rd_data_2_top),             
.o_full(i_full_2_top),               
.o_empty(i_empty_2_top)              

);

endmodule