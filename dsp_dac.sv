module dsp_dac #(parameter BUS_WIDTH = 8 , D_SIZE = 16 , DATA_WIDTH = 32, TAP_SIZE=4)(


input   wire                         clk,
input   wire                         rst,
input  wire                         clk_adc,
input  wire                         rst_adc,
input   wire                       i_vaild_reg,
input   wire     [DATA_WIDTH-1:0]  i_address_reg,
input   wire                       i_full,               // fifo full flag
input   wire                       i_empty,
input   wire                       i_full_tx,               // fifo full flag
input   wire                       i_empty_tx,
input   wire                      mode_sel_tx,
input   wire    [BUS_WIDTH-1:0]  write_dac_tx, // mem
output  reg     [3:0]              dsp_stat,
output  reg     [1:0]            fifo_level_tx,
input   wire    [BUS_WIDTH-1:0]   i_rd_data,
output  reg                        o_w_inc,              // write control signal 
output  reg                        o_rd_inc, 
input   wire    [BUS_WIDTH-1:0]   i_rd_data_tx,
output  reg                        o_w_inc_tx,              // write control signal 
output  reg                        o_rd_inc_tx, 
output  reg                        state_register_tx,
output  reg     [BUS_WIDTH+1:0]   o_w_data,           // write data bus 
output  reg     [BUS_WIDTH+1:0]   o_w_data_tx,  //fifo tx write 
output   reg     [BUS_WIDTH-1:0]  out_data
);


    // Internal buffer to store the last TAP_SIZE samples
    reg [BUS_WIDTH-1:0] filter_buffer [0:TAP_SIZE-1];
    reg [BUS_WIDTH+1:0] filter_sum; 
	reg [BUS_WIDTH-1:0] read_data_tx;
	reg [BUS_WIDTH-1:0] o_w_data_tx_reg;
	reg [BUS_WIDTH-1:0] o_w_data_tx_reg_2;
    reg [BUS_WIDTH+1:0] data_out; 
    reg [4:0] counter; 
	reg [4:0] counter_2; 
	reg     [DATA_WIDTH-1:0]  reg_address;
	reg reg_valid; 
    // Shift register and summation logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            filter_buffer <= '{default: {DATA_WIDTH{1'b0}}};
            filter_sum <= {DATA_WIDTH+2{1'b0}};
        end else if (mode_sel_tx && !i_full ) begin
            filter_buffer <= {read_data_tx, filter_buffer[0:TAP_SIZE-2]};
            filter_sum <= read_data_tx + filter_buffer[0] + filter_buffer[1] + filter_buffer[2];
        end 
    end
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 always_comb begin
        
		
		   
			
           if (reg_valid && reg_address== 8 ) begin
		    o_w_inc_tx = 1;
			o_w_data_tx = write_dac_tx;
		   end else begin
		   o_w_inc_tx = 0;
		   end
        
    end
 
 always @(posedge clk or negedge rst) begin
        if (!rst) begin
          reg_valid <= 0;
		  reg_address<= 0;
	    end else begin
        	reg_valid <= i_vaild_reg;
			reg_address<= i_address_reg;
		end	
	end
  
	
	
	always @(posedge clk or negedge rst) begin
        if (!rst) begin
          o_rd_inc_tx <= 0;
		  read_data_tx <=0;
	    end else begin
	    if(counter==0 && mode_sel_tx ) begin
        	o_rd_inc_tx <= 1;
			 read_data_tx <= i_rd_data_tx;
		
	    end else begin
         	o_rd_inc_tx  <= 0;
		end	
		end	
	end
	/////////////////////////////////////////////////////////////////////////////////////////////
    always @(*) begin
	     fifo_level_tx[0] = i_full_tx ; 
		 fifo_level_tx[1] = i_empty_tx ; 
		 state_register_tx = !i_empty_tx;
	     data_out = filter_sum >> 2; // Divide by 4 (2^2) for 4-tap filter
	     o_w_data = data_out ;
	
		 out_data = i_rd_data;	
		 
	    if(counter==5 && !i_full && mode_sel_tx) begin
	         o_w_inc =1;
	         dsp_stat = 8;
			
	     end else begin
	         o_w_inc =0;
			 dsp_stat = 4;
           
	     end
	end
	
	
	always @(*) begin
        
	    if(mode_sel_tx && (counter_2 ==5||counter_2 ==15)) begin
        	o_rd_inc = 1;
			out_data = i_rd_data;	
	    end else begin
         	o_rd_inc  = 0;
		end	
		
	end

	always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
			dsp_stat = 'b00;
        end else if (counter<5 && mode_sel_tx) begin
           counter <= counter +1;
		  
		end else begin
           counter <= 0;   
          
        end
    end
	
		always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter_2 <= 0;
			
        end else if (counter_2<19 && mode_sel_tx) begin
           counter_2 <= counter_2 +1;
		  
		end else begin
           counter_2 <= 0;   
          
        end
    end



endmodule
