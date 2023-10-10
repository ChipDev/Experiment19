`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer:  James Ratner
// 
// Create Date: 07/07/2018 08:05:03 AM
// Design Name: 
// Module Name: fsm_template
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Generic FSM model with both Mealy & Moore outputs. 
//    Note: data widths of state variables are not specified 
//
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created (07-07-2018) 
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FSM_1J(CLK, RCO, BTN, GT, VALID, H_RAM_W, L_RAM_W, ROM_CTR_ADD, H_RAM_CTR_ADD, L_RAM_CTR_ADD, ALL_CLR, reset_n, L_RAM_CTR_RCO, H_RAM_CTR_RCO, VIEWING_ADDRESS_OF); 
   input  CLK, RCO, BTN, GT, VALID, reset_n, L_RAM_CTR_RCO, H_RAM_CTR_RCO; 
   output reg H_RAM_W, L_RAM_W, ROM_CTR_ADD, H_RAM_CTR_ADD, L_RAM_CTR_ADD, ALL_CLR;
   output reg [1:0] VIEWING_ADDRESS_OF;  //Viewing address of 0: ROM    1: RAM_L    2: RAM_H  Input to MUXes, mux has address of ROM/RAM counter and value from ROM/RAM
   
   //- next state & present state variables
   reg [2:0] NS, PS; 
   //- bit-level state representations
   parameter [2:0] EVAL_INIT=3'b000, EVAL=3'b001, VIEW_INIT=3'b010, VIEW_LOW=3'b011, VIEW_HIGH=3'b100; 
   

   //- model the state registers
   always @ (negedge reset_n, posedge CLK)
   begin
      if(reset_n == 0)
      begin
         PS <= EVAL_INIT;
      end
      else
      begin
         PS <= NS; 
      end
   end
    
    //- model the next-state and output decoders
   always @ (*)
   begin
      case(PS)
         EVAL_INIT:
         begin
            H_RAM_W = 0;
            L_RAM_W = 0;
            ROM_CTR_ADD = 0;
            H_RAM_CTR_ADD = 0;
            L_RAM_CTR_ADD = 0;
            ALL_CLR = 1;        
            VIEWING_ADDRESS_OF = 2'b00;
            if(BTN)
            begin
               NS = EVAL_INIT;
            end
            else
            begin
               NS = EVAL;
            end

         end

         EVAL:
         begin
            H_RAM_W = GT & VALID;
            L_RAM_W = ~GT & VALID;
            ROM_CTR_ADD = 1;
            H_RAM_CTR_ADD = GT & VALID;
            L_RAM_CTR_ADD = ~GT & VALID;
            ALL_CLR = 0;        
            VIEWING_ADDRESS_OF = 2'b00;
            if(BTN)
            begin
               NS = VIEW_INIT;
            end
            else if(RCO)
            begin
               NS = EVAL_INIT;
            end
            else
            begin
               NS = EVAL;
            end
         end

         VIEW_INIT:
         begin
            H_RAM_W = 0;
            L_RAM_W = 0;
            ROM_CTR_ADD = 0;
            H_RAM_CTR_ADD = 0;
            L_RAM_CTR_ADD = 0;
            ALL_CLR = 1;        
            VIEWING_ADDRESS_OF = 2'b00;
            if(BTN)
            begin
               NS = VIEW_INIT;
            end
            else
            begin
               NS = VIEW_LOW;
            end

         end

         VIEW_LOW:
         begin
            H_RAM_W = 0;
            L_RAM_W = 0;
            ROM_CTR_ADD = 0;
            H_RAM_CTR_ADD = 0;
            L_RAM_CTR_ADD = 1;
            ALL_CLR = 0;     
            VIEWING_ADDRESS_OF = 2'b01;
            if(BTN)
            begin
               NS = EVAL_INIT;
            end
            else if(L_RAM_CTR_RCO)
            begin
               NS = VIEW_HIGH;
            end
            else
            begin
               NS = VIEW_LOW;
            end
         end
         VIEW_HIGH:
         begin
            H_RAM_W = 0;
            L_RAM_W = 0;
            ROM_CTR_ADD = 0;
            H_RAM_CTR_ADD = 1;
            L_RAM_CTR_ADD = 0;
            ALL_CLR = 0;        
            VIEWING_ADDRESS_OF = 2'b10;
            if(BTN)
            begin
               NS = EVAL_INIT;
            end
            else if(H_RAM_CTR_RCO)
            begin
               NS = VIEW_LOW;
            end
            else
            begin
               NS = VIEW_HIGH;
            end
         end

         default:
         begin
            NS = EVAL_INIT; 
            H_RAM_W = 0;
            L_RAM_W = 0;
            ROM_CTR_ADD = 0;
            H_RAM_CTR_ADD = 0;
            L_RAM_CTR_ADD = 0;
            ALL_CLR = 1;        
            VIEWING_ADDRESS_OF = 2'b00;
         end
      endcase
   end              
endmodule

// module FSM_1J(reset_n, x_in, clk, mealy, moore); 
//     input  reset_n, x_in, clk; 
//     output reg mealy, moore;
     
//     //- next state & present state variables
//     reg [1:0] NS, PS; 
//     //- bit-level state representations
//     parameter [1:0] st_A=2'b00, st_B=2'b01, st_C=2'b11; 
    

//     //- model the state registers
//     always @ (negedge reset_n, posedge clk)
//        if (reset_n == 0) 
//           PS <= st_A; 
//        else
//           PS <= NS; 
    
    
//     //- model the next-state and output decoders
//     always @ (x_in,PS)
//     begin
//        mealy = 0; moore = 0; // assign all outputs
//        case(PS)
//           st_A:
//           begin
//              moore = 1;        
//              if (x_in == 1)
//              begin
//                 mealy = 0;   
//                 NS = st_A; 
//              end  
//              else
//              begin
//                 mealy = 1; 
//                 NS = st_B; 
//              end  
//           end
          
//           st_B:
//              begin
//                 moore = 0;
//                 mealy = 1;
//                 NS = st_C;
//              end   
             
//           st_C:
//              begin
//                  moore = 1; 
//                  if (x_in == 1)
//                  begin
//                     mealy = 1; 
//                     NS = st_B; 
//                  end  
//                  else
//                  begin
//                     mealy = 0; 
//                     NS = st_A; 
//                  end  
//              end
             
//           default: NS = st_A; 
            
//           endcase
//       end              
// endmodule


