`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2023 10:50:47 PM
// Design Name: 
// Module Name: experiment1j
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module experiment1j #(parameter addr_size = 4,
                      parameter word_size = 8,
                      parameter cdiv = 26)
                    
    (
    input BTN,
    input fast_clock,
    input reset_n,
    output [addr_size-1:0] LED,
    output [7:0] ssegs,
    output [3:0] disp_en,
    output CLK_OUT
    );

    // COUNTER WIRES -- BEGIN
    wire CLEAR_COUNTERS;           

    wire ROM_COUNTER_ADD;
    wire RAML_COUNTER_ADD;
    wire RAMH_COUNTER_ADD;
    
    wire ROM_COUNTER_RCO;
    wire L_RAM_CTR_RCO;
    wire H_RAM_CTR_RCO;

    wire [addr_size-1:0] ROM_COUNTER_CNT;
    wire [addr_size-1:0] RAML_COUNTER_CNT;
    wire [addr_size-1:0] RAMH_COUNTER_CNT;
    // COUNTER WIRES -- END

    // ROM, RAM WIRES -- BEGIN
    wire [addr_size-1:0] ROM_ADDRESS;
    wire [word_size-1:0] ROM_VAL;

    wire [addr_size-1:0] RAML_ADDR;
    wire RAML_W;
    wire [word_size-1:0] RAML_VAL;

    wire [addr_size-1:0] RAMH_ADDR;
    wire RAMH_W;
    wire [word_size-1:0] RAMH_VAL;
    // ROM, RAM WIRES -- END

    // COMPARATORS

    wire SORT_GT;
    wire SORT_VALID;

    // COMPARATORS END 

    //MUX stuff
    wire [1:0] VIEWING_ADDRESS_OF;
    wire [word_size-1:0] CURRENT_DATA_VIEW;
    wire [addr_size-1:0] CURRENT_ADDR_VIEW;



    //CLK DIVIDER (100Mhz -> 1.5Hz)

    wire CLK; 
    assign CLK_OUT = RAML_COUNTER_ADD;

    clk_2n_div_test #(.n(cdiv)) CLK_DIVIDER (
         .clockin   (fast_clock), 
         .fclk_only (0),          
         .clockout  (CLK)   );
    
    // 5-Bit counters for 16x8 ROM & RAM
    cntr_up_clr_nb #(.n(addr_size)) ROM_COUNTER (
    .clk   (CLK), 
    .clr   (CLEAR_COUNTERS), 
    .up    (ROM_COUNTER_ADD), 
    .ld    (0), 
    .D     (0), 
    .count (ROM_COUNTER_CNT), 
    .rco   (ROM_COUNTER_RCO)   ); 

    assign ROM_ADDRESS = ROM_COUNTER_CNT;

    cntr_up_clr_nb #(.n(addr_size)) RAML_COUNTER (
    .clk   (CLK), 
    .clr   (CLEAR_COUNTERS), 
    .up    (RAML_COUNTER_ADD), 
    .ld    (0), 
    .D     (0), 
    .count (RAML_COUNTER_CNT), 
    .rco   (L_RAM_CTR_RCO)   ); 

    cntr_up_clr_nb #(.n(addr_size)) RAMH_COUNTER (
    .clk   (CLK), 
    .clr   (CLEAR_COUNTERS), 
    .up    (RAMH_COUNTER_ADD), 
    .ld    (0), 
    .D     (0), 
    .count (RAMH_COUNTER_CNT), 
    .rco   (H_RAM_CTR_RCO)   ); 

    // ROM, RAMs
    ROM_16x8_exp1j ROM (
    .addr  (ROM_ADDRESS),  
    .data  (ROM_VAL),  
    .rd_en (1));

    assign RAML_ADDR = RAML_COUNTER_CNT;

    ram_single_port #(.n(4),.m(8)) RAML (
    .data_in  (ROM_VAL),  // m spec
    .addr     (RAML_ADDR),  // n spec 
    .we       (RAML_W),
    .clk      (CLK),
    .data_out (RAML_VAL) //Reading data
    );  

    assign RAMH_ADDR = RAMH_COUNTER_CNT;

    ram_single_port #(.n(4),.m(8)) RAMH (
    .data_in  (ROM_VAL),  // m spec
    .addr     (RAMH_ADDR),  // n spec 
    .we       (RAMH_W),
    .clk      (CLK),
    .data_out (RAMH_VAL) //Reading data
    );  

    // COMPS
    comp_nb #(.n(8)) COMPARATOR_50 (
    .a  (ROM_VAL), 
    .b  (50), 
    .eq (), 
    .gt (SORT_GT), 
    .lt ()
    );

    comp_nb #(.n(8)) COMPARATOR_VALID (
    .a  (100),                       //If val==100, invalid--range [0,100)
    .b  (ROM_VAL), 
    .eq (), 
    .gt (SORT_VALID),                // 100 > x
    .lt ()
    );

    //FSM
    FSM_1J FINITE_STATE_MACHINE (
        .CLK(CLK), 
        .RCO(ROM_COUNTER_RCO), 
        .BTN(BTN), 
        .GT(SORT_GT), 
        .VALID(SORT_VALID),
        .H_RAM_W(RAMH_W), 
        .L_RAM_W(RAML_W), 
        .ROM_CTR_ADD(ROM_COUNTER_ADD), 
        .H_RAM_CTR_ADD(RAMH_COUNTER_ADD), 
        .L_RAM_CTR_ADD(RAML_COUNTER_ADD), 
        .ALL_CLR(CLEAR_COUNTERS),
        .reset_n(~reset_n),
        .L_RAM_CTR_RCO(L_RAM_CTR_RCO),
        .H_RAM_CTR_RCO(H_RAM_CTR_RCO),
        .VIEWING_ADDRESS_OF(VIEWING_ADDRESS_OF)
        ); 

    // MUXES for displaying
    mux_4t1_nb #(.n(word_size)) VALUE_MUX(
        .SEL   (VIEWING_ADDRESS_OF), 
        .D0    (ROM_VAL), 
        .D1    (RAML_VAL), 
        .D2    (RAMH_VAL), 
        .D3    (0),
        .D_OUT (CURRENT_DATA_VIEW) 
    );  

    assign LED = CURRENT_ADDR_VIEW;

    mux_4t1_nb #(.n(addr_size)) ADDR_MUX(
        .SEL   (VIEWING_ADDRESS_OF), 
        .D0    (ROM_ADDRESS), 
        .D1    (RAML_ADDR), 
        .D2    (RAMH_ADDR), 
        .D3    (0),
        .D_OUT (CURRENT_ADDR_VIEW) 
    );  

    univ_sseg DISPLAY_SEVEN_SEG (
        .cnt1    (CURRENT_ADDR_VIEW), 
        .cnt2    (SORT_VALID ? CURRENT_DATA_VIEW : 8'b0000000), 
        .valid   (1), 
        .dp_en   ({1'b0, ~SORT_VALID}), 
        .dp_sel  (2'b01), 
        .mod_sel (2'b01), 
        .sign    (0), 
        .clk     (fast_clock), 
        .ssegs   (ssegs), 
        .disp_en (disp_en)   
    ); 


endmodule
