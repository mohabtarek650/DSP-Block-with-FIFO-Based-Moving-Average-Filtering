module ahb_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
)(
    input  logic                  i_clk_ahb,
    input  logic                  i_rstn_ahb,

    input  logic                  i_hready,
    input  logic                  i_htrans,
    input  logic [2:0]            i_hsize,
    input  logic                  i_hwrite,
    input  logic [ADDR_WIDTH-1:0] i_haddr,
    input  logic [DATA_WIDTH-1:0] i_hwdata,
    input  logic                  i_hselx,
    
    input  logic                  i_ready,
    input  logic                  i_rd_valid,
    input  logic [DATA_WIDTH-1:0] i_rd_data,
    
    output reg                    o_valid,
    output reg                    o_rd0_wr1,
    output reg [DATA_WIDTH-1:0]   o_wr_data,
    output reg [ADDR_WIDTH-1:0]   o_addr,

    output reg                    o_hreadyout,
    output reg                    o_hresp,
    output reg [DATA_WIDTH-1:0]   o_hrdata,

    input logic                    i_hmastlock,
    input logic [3:0]              i_hprot,
    input logic [2:0]              i_hburst
);

    typedef enum logic {
        IDLE = 1'b0,
        NONSEQ = 1'b1
    } state_t;

    state_t state;

    always_ff @(posedge i_clk_ahb or negedge i_rstn_ahb) begin
        if (!i_rstn_ahb) begin
            state       <= IDLE;
            o_hreadyout <= 1'b1;
            o_hresp     <= 1'b0;
            o_valid     <= 1'b0;
            o_rd0_wr1   <= 1'b0;

            o_addr      <= '0;
            o_hrdata    <= '0;
        end else begin
            if (i_hselx && i_hready) begin
                if (i_htrans == NONSEQ) begin
                    o_addr    <= i_haddr;
                    o_rd0_wr1 <= i_hwrite;
                    if (i_hwrite) begin
                        
                        o_valid   <= 1'b1;
                    end else begin
                        o_valid   <= 1'b1;
                    end
                end
            end

            if (i_rd_valid) begin
                o_hrdata    <= i_rd_data;
                o_hreadyout <= 1'b1;
            end else begin
                o_hreadyout <= 1'b0;
            end

            if (!i_hselx) begin
                state       <= IDLE;
                o_valid     <= 1'b0;
                o_hreadyout <= 1'b1;
            end
        end
    end
	
	assign o_wr_data = i_hwdata;
endmodule