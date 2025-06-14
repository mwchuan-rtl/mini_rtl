//=============================================================================================
// TB for simple fifo
//=============================================================================================

module simple_fifo_tb ();
    
    //Parameters
    parameter CLK_PERIOD = 2;   //Clock period
    parameter DATA_WIDTH = 8;  //Data type for the read and write data
    parameter DEPTH      = 32;        //Depth of the fifo

    parameter type DTYPE = logic [DATA_WIDTH-1:0];

    logic tb_clk;
    logic tb_rst_n;
    logic tb_fifo_wren;   //Pushing data into fifo
    DTYPE tb_fifo_wrdata;
    logic tb_shiften;     //Poping data out from fifo
    logic tb_fifo_empty; //fifo is empty
    logic tb_fifo_full;  //fifo is full
    logic tb_fifo_valid;
    DTYPE tb_fifo_rddata;
    logic tb_overflow_err;
    logic tb_underflow_err;

    DTYPE tb_dummy_wrdata;

    simple_fifo #(
        .DATA_WIDTH  (DATA_WIDTH),
        .DEPTH       (DEPTH)
    ) dut_simple_fifo (
    //input
        .clk           (tb_clk), 
        .rst_n         (tb_rst_n), 
        .wrdata        (tb_fifo_wrdata), 
        .wren          (tb_fifo_wren),
        .rden          (tb_shiften),
    //output
        .rddata        (tb_fifo_rddata),
        .data_valid    (tb_fifo_valid),
        .full          (tb_fifo_full),
        .empty         (tb_fifo_empty),
        .overflow_err  (tb_overflow_err),
        .underflow_err (tb_underflow_err)
    );

    //wait cycles
    task wait_cycles (int num_cycles);
        repeat (num_cycles) @(posedge tb_clk);
    endtask

    task drive_reset (); //active high reset
        tb_rst_n        = 1'b0;
        tb_dummy_wrdata = '0;
        wait_cycles(10);
        tb_rst_n        = 1'b1;
        tb_dummy_wrdata = '0;
        wait_cycles(10);
        $display("DUT is out of reset\n");
    endtask

    task push_data (DTYPE in_wrdata); //active high reset
        tb_fifo_wrdata = in_wrdata;
        tb_fifo_wren   = 1'b1;
        wait_cycles(1);
        tb_fifo_wren   = 1'b0;
        if (tb_fifo_full)    $display("FIFO is full!\n");
    endtask

    task pop_data (); //active high reset
        tb_shiften   = 1'b1;
        wait_cycles(1);
        tb_shiften   = 1'b0;
        if (tb_fifo_empty)    $display("FIFO is empty!\n");    
    endtask

    //initial values
    initial begin 
        tb_clk          = '0; 
        tb_rst_n        = '1;     
        tb_fifo_wren    = '0;   //Pushing data into fifo
        tb_fifo_wrdata  = '0;
        tb_shiften      = '0;   //Poping data out from fifo
        tb_fifo_empty   = '0;   //fifo is empty
        tb_fifo_full    = '0;   //fifo is full
        tb_fifo_valid   = '0;
        tb_fifo_rddata  = '0;
        tb_dummy_wrdata = '0;
    end 

    //Clock generation
    always begin
        #(CLK_PERIOD/2);
        tb_clk=~tb_clk;
    end

    initial begin
       
        //underflow check
        drive_reset();
        pop_data();
        wait_cycles(2);
        if (tb_underflow_err) $display("UNDERFLOW, please check\n"); 
        wait_cycles(10);

        //overflow check
        drive_reset();
        for (int i = 0; i < DEPTH+1; i ++) begin
            push_data(tb_dummy_wrdata);
            tb_dummy_wrdata = tb_dummy_wrdata + 1;
        end
        wait_cycles(2);
        if (tb_overflow_err) $display("OVERFLOW, please check\n");
        wait_cycles(10);

        //normal read and write
        drive_reset();
       for (int i = 0; i < DEPTH; i ++) begin
            push_data(tb_dummy_wrdata);
            tb_dummy_wrdata = tb_dummy_wrdata + 1;
        end
        wait_cycles(10);
        
        for (int i = 0; i < DEPTH; i ++) begin
            pop_data();
        end
        
        $display("Simulation will finish in 10 cycles\n");
        wait_cycles(10);

    end
        
endmodule //generic_fifo_tb
