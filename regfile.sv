module RegFile #(
    parameter DATA_WIDTH = 32,
	 parameter BUS_WIDTH = 8,
    parameter REG_FILE_DEPTH = 26,
    parameter ADDR_WIDTH = 32
)(
    input    wire                     clk,
    input    wire                     rst,
    input    wire                     i_rd0_wr1,
    input    wire                     i_valid,
    input    wire   [ADDR_WIDTH-1:0]  i_addr,
    input    wire   [DATA_WIDTH-1:0]  i_data,
    output   reg    [DATA_WIDTH-1:0]  o_rd_data,
    output   reg                      o_rd_valid,
    output   reg                      o_ready,
    output   reg                      mode_sel_rx,
	output   reg                      mode_sel_tx,
    input   wire    [1:0]             dsp_stat_rx,
	input   wire    [3:0]             dsp_stat_tx,
    output   reg    [BUS_WIDTH-1:0]  write_dac,
    input   wire    [BUS_WIDTH-1:0]  read_adc,
    input   wire    [1:0]             fifo_level_rx,
	input   wire    [1:0]             fifo_level_tx,
	input   wire                      state_register_rx,
    input   wire                      state_register_tx,
	output   reg                      enable_interrupt_rx

);

    // register file of 8 registers each of 16 bits width
    reg [DATA_WIDTH-1:0] regArr [REG_FILE_DEPTH-1:0];

    always @(posedge clk or negedge rst) begin
        if (!rst) begin  // Asynchronous active low reset 
            o_rd_valid <= 1'b0;
            o_rd_data <= 'b0;
            o_ready <= 'b1;
            mode_sel_tx <= 'b0;
			mode_sel_rx <= 'b0;
            write_dac <= 'b0;

			
        end else if (i_rd0_wr1 && i_valid) begin
            regArr[i_addr] <= i_data;
        end else if (!i_rd0_wr1 && i_valid) begin
            o_rd_data <= regArr[i_addr];
            o_rd_valid <= 1'b1;
        
        end else begin
          
            o_rd_valid <= 1'b0;
        end
    end

    always @(*) begin
        
            mode_sel_rx = regArr[0][0];
			mode_sel_tx = regArr[0][1];
            regArr[4][1:0] = dsp_stat_rx;
			regArr[4][3:2] = dsp_stat_tx;
            write_dac = regArr[8][DATA_WIDTH-1:0];
            regArr[12][DATA_WIDTH-1:0] = read_adc;
            regArr[16][3:2] = fifo_level_rx;
			regArr[16][1:0] = fifo_level_tx;
            enable_interrupt_rx = regArr[20][0];
			regArr[24][0] = state_register_rx;
			regArr[24][1] = state_register_tx;
     
    end

endmodule