//---------------------------------------------------------------------------------------------
// File Name : simple_fifo.sv
// Module    : Just a simple fifo
//---------------------------------------------------------------------------------------------

`define RST_SET_MSFF(q, i, clock, rst, set)             \
    always_ff @(posedge clock)                          \
    begin                                               \
        if      (rst)    q <= '0;                       \
        else if (set)    q <= '1;                       \
        else             q <=  i;                       \
    end

module simple_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 32 
) (
  input logic clk, 
  input logic rst_n, 
  input logic [DATA_WIDTH-1:0] wrdata, 
  input logic wren,
  input logic rden,

  output logic [DATA_WIDTH-1:0] rddata,
  output logic data_valid,
  output logic full,
  output logic empty,
  output logic overflow_err,
  output logic underflow_err
);
  
localparam PTR_WIDTH = $clog2(DEPTH);

logic [PTR_WIDTH:0]  wr_ptr, rd_ptr;
logic [PTR_WIDTH:0]  wr_ptr_temp, rd_ptr_temp;

logic [DATA_WIDTH-1:0] reg_data [DEPTH];

//Increment write pointer
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    wr_ptr <= {PTR_WIDTH{1'b0}};
  else if(wren) begin
    //Write data to FIFO
    reg_data[wr_ptr[PTR_WIDTH-1:0]] <= wrdata;
    //Increment write pointer
    wr_ptr                          <= wr_ptr  + 1'b1;
  end
end

assign wr_ptr_temp = wr_ptr[PTR_WIDTH-1:0];

//Full empty calculation
assign empty =  (wr_ptr  == rd_ptr); 
assign full  = ( (wr_ptr[PTR_WIDTH-1:0]  == rd_ptr[PTR_WIDTH-1:0] )  && (wr_ptr[PTR_WIDTH]  != rd_ptr[PTR_WIDTH]) );

//Read pointer increment, should not increment while insert 1 or 0
always @(posedge clk or negedge rst_n) begin
  if(!rst_n)
    rd_ptr <= {PTR_WIDTH{1'b0}};
  else if(rden)
    //Read data from FIFO
    rddata = reg_data[rd_ptr_temp] ;
    //Increment read pointer
    rd_ptr <= rd_ptr + 1'b1 ;
end

assign rd_ptr_temp = rd_ptr[PTR_WIDTH-1:0];



//Data out valid, always set to "1" if FIFO is not empty
assign data_valid   = !empty;

//overflow & underflow
logic overflow, underflow;
assign overflow  = full  && wren;
assign underflow = empty && rden;

`RST_SET_MSFF(overflow_err,  overflow_err,  clk, !rst_n,  overflow)
`RST_SET_MSFF(underflow_err, underflow_err, clk, !rst_n,  underflow)

endmodule
