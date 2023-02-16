

// Code your design here
// `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.01.2023 21:07:34
// Design Name: 
// Module Name: nikhilum
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


module nikhilum(input [3:0]a2, input [3:0]b2, output [7:0]out  );
    wire [7:0] multiplier_output;
    wire [3:0] temp2;
    wire [7:0] temp3;
    wire [3:0]a2_compliment;
    wire [3:0]b2_compliment;

    
   //step 1 
    twos_compliment first (a2, a2_compliment);
    twos_compliment second (b2, b2_compliment);
    
    
    //step2 
    multiplier mul_first(a2_compliment, b2_compliment, multiplier_output);
    
    //step 3 
   assign temp2 = a2 - b2_compliment;
   
   //step 4 
   assign temp3 = temp2<<4;
   
   //step 5 
   assign out = multiplier_output + temp3;
    
endmodule


module multiplier (input [3:0]a1,input [3:0]b1, output [7:0]c1);
    assign c1 = a1*b1;
endmodule




module twos_compliment(input [3:0]x, output [3:0]y);
    assign y = ~x+1;
endmodule

interface add_if;
 logic [3:0]a2;
 logic [3:0]b2;
 logic [7:0]out;
endinterface

