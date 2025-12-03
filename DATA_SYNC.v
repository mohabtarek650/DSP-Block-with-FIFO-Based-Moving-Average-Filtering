/////////////////////////////////////////////////////////////
//////////////////// data synchronizer //////////////////////
/////////////////////////////////////////////////////////////

module DATA_SYNC # ( 
     parameter NUM_STAGES = 2 ,
     parameter BUS_WIDTH = 8 
)(
input    wire                      CLK,
input    wire                      RST,
input    wire     [BUS_WIDTH-1:0]  unsync_bus,
output   reg      [BUS_WIDTH-1:0]  sync_bus
);

//internal connections
reg   [NUM_STAGES-1:0]    sync_reg;
reg   [BUS_WIDTH-1:0]     sync_bus_intermediate;

//----------------- Multi flop synchronizer for data --------------

always @(posedge CLK or negedge RST)
 begin
  if(!RST)      // active low
   begin
    sync_reg <= 'b0 ;
    sync_bus_intermediate <= 'b0 ;
    sync_bus <= 'b0 ;
   end
  else
   begin
    sync_reg <= {sync_reg[NUM_STAGES-2:0], unsync_bus[0]}; // Synchronize a single bit as a representative
    sync_bus_intermediate <= unsync_bus;                   // Capture the unsynchronized bus
    sync_bus <= sync_bus_intermediate;                     // Output the synchronized bus
   end  
 end

endmodule