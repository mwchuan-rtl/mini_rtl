//=============================================================================================
// TB for mealy_seq_det1101
//=============================================================================================

module mealy_seq_det1101_tb ();
    
    //Parameters
    parameter CLK_PERIOD = 2;   //Clock period

    logic tb_clk, tb_rst_n;
    logic tb_in_bit;
    logic tb_pattern_det;
    logic rand_in_bit;

    //Instantiate DUT
    mealy_seq_det1101 dut_mealy_seq_det1101 (
      //input
        .clk            (tb_clk),
        .rst_n          (tb_rst_n),
        .in_bit         (tb_in_bit),
      //output
        .pattern_det    (tb_pattern_det)
    );

    //wait cycles
    task wait_cycles (int num_cycles);
        repeat (num_cycles) @(posedge tb_clk);
    endtask

    task drive_reset (); //active high reset
        tb_rst_n        = 1'b0;
        wait_cycles(10);
        tb_rst_n        = 1'b1;
        wait_cycles(10);
        $display("DUT is out of reset\n");
    endtask

    //initial values
    initial begin 
        tb_clk          = '0; 
        tb_rst_n        = '1;
        tb_in_bit       = '0;
    end 

    //Clock generation
    always begin
        #(CLK_PERIOD/2);
        tb_clk=~tb_clk;
    end

    initial begin
       
        //underflow check
        drive_reset();
        
        wait_cycles(2);
        repeat(200) begin
            rand_in_bit = $urandom_range(0,1);
            @(posedge tb_clk) begin
                tb_in_bit   = rand_in_bit;
                if (tb_pattern_det) $display("Pattern Detected!\n"); 
            end
        end

        wait_cycles(10);
        $display("Simulation will finish in 10 cycles\n");
        wait_cycles(10);

    end

endmodule //mealy_seq_det1101_tb
