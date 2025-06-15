//------------------------------------------------------------------------------------------------
// File Name : mealy_seq_det1101.sv
// Module    : Just a simple sequence detector
// Sequence  : output a 1 when serial input 1 -> 0 -> 1 -> 1 is detected, with overlapping pattern
// Glitches  : This design produces glitches when we have 1->0->1->0->1 pattern, why?
//-------------------------------------------------------------------------------------------------

` define RSTD_MSFF(q, i, clock, rst, rstd)              \
    always_ff @(posedge clock)                          \
        begin                                           \
            if (rst)                                    \
                q <= rstd;                              \
            else                                        \
                q <= i;                                 \
        end


module mealy_seq_det1101 (
    input  logic clk,
    input  logic rst_n,
    input  logic in_bit,
    output logic pattern_det
);

    //Binary coded states    
    parameter FSM1101_WIDTH = 2;
    typedef enum logic [FSM1101_WIDTH-1:0] {  
        INIT_0  = 2'b00,
        DET_1   = 2'b01,
        DET_01  = 2'b10,
        DET_101 = 2'b11
    } t_enum_fsm1101;

    //internal signals
    t_enum_fsm1101 cur_state, nxt_state;

    `RSTD_MSFF(cur_state, nxt_state, clk, !rst_n, INIT_0)
    
    always_comb begin : fsm1101_combi
        pattern_det = 1'b0;

        unique casez (cur_state)
            
            INIT_0  : begin
                if (in_bit) begin
                    nxt_state     = DET_1;
                    pattern_det   = 1'b0;
                end
                else begin
                    nxt_state     = INIT_0;
                    pattern_det   = 1'b0;
                end
            end //INIT_0

            DET_1   : begin
                if (in_bit) begin
                    nxt_state     = DET_1;
                    pattern_det   = 1'b0;
                end
                else begin
                    nxt_state     = DET_01;               
                    pattern_det   = 1'b0;
                end
            end //DET_1

            DET_01  : begin
                if (in_bit) begin
                    nxt_state     = DET_101;
                    pattern_det   = 1'b0;
                end
                else begin
                    nxt_state     = INIT_0;
                    pattern_det   = 1'b0;                
                end
            end //DET_01

            DET_101 : begin
                if (in_bit) begin
                    nxt_state     = DET_1;
                    //output a 1 when serial input 1 -> 0 -> 1 -> 1 is detected
                    pattern_det   = 1'b1;
                end 
                else begin
                    nxt_state     = DET_01;
                    pattern_det   = 1'b0;               
                end
            end //DET_101
            
            default : begin 
                nxt_state = cur_state;
                pattern_det   = 1'b0; 
            end
        endcase
    end //fsm1101_combi

endmodule //mealy_seq_det1101
