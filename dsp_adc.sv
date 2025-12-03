module dsp_adc #(parameter BUS_WIDTH = 8 , D_SIZE = 16 , DATA_WIDTH = 32, TAP_SIZE=4)(


input   wire                       clk,
input   wire                       rst,
input   wire      [BUS_WIDTH-1:0]  adc_data,
input   wire                       i_full,               // fifo full flag
input   wire                       i_empty,
input   wire                      mode_sel_rx,
output   reg    [BUS_WIDTH-1:0]  read_adc_rx,
input   wire                      enable_interrupt_0,
output  reg     [1:0]             dsp_stat,
output   reg     [1:0]            fifo_level_rx,
input   wire    [BUS_WIDTH-1:0]   i_rd_data,
output  reg                        o_w_inc,              // write control signal 
output  reg                        o_rd_inc, 
output  reg                        irq,              // write control signal 
output  reg                        state_register_rx,
output  reg     [BUS_WIDTH+1:0]     o_w_data           // write data bus 

);

    // Internal buffer to store the last TAP_SIZE samples
    logic [BUS_WIDTH-1:0] filter_buffer [0:TAP_SIZE-1];
    logic [BUS_WIDTH+1:0] filter_sum; 
    logic [BUS_WIDTH+1:0] data_out; 
	logic [4:0] counter; 

    // Shift register and summation logic
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            filter_buffer <= '{default: {DATA_WIDTH{1'b0}}};
            filter_sum <= {DATA_WIDTH+2{1'b0}};
        end else if (mode_sel_rx && !i_full) begin
            filter_buffer <= {adc_data, filter_buffer[0:TAP_SIZE-2]};
            filter_sum <= adc_data + filter_buffer[0] + filter_buffer[1] + filter_buffer[2];
        end 
    end
 
 
    always_comb begin
	     fifo_level_rx[0] = i_full ; 
		 fifo_level_rx[1] = i_empty ; 
		 state_register_rx = !i_empty;
		 read_adc_rx = i_rd_data;
	     data_out = filter_sum >> 2; // Divide by 4 (2^2) for 4-tap filter
	     o_w_data = data_out ;
	     if (counter<4)
		 dsp_stat = 1;
			
	    if(counter==4 && !i_full && mode_sel_rx) begin
	         o_w_inc =1;
	         dsp_stat = 2;
	     end else begin
	         o_w_inc =0;
			 
           
	     end
	end
	
	always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
          o_rd_inc <= 0;
		
	    end else begin
	    if( mode_sel_rx && counter==4) begin
        	o_rd_inc <= 1;
			
			
				 
	    end else begin
         	o_rd_inc  <= 0;
		end	
		end	
	end
	
	always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
			
        end else if (counter<9 && mode_sel_rx) begin
           counter <= counter +1;
		   
		 if( enable_interrupt_0 && counter==4 )begin
        	     irq <= 1;
	
	         end else begin
         	     irq <= 0;
			
				 end
		
		end else begin
           counter <= 0;   
          
        end
    end


endmodule