input [9:0] SW; //Input Declarations: 10 slide switches
output [9:0] LEDR; //Output Declarations: 10 red LED lights

assign LEDR[7:0] = SW[7:0];
assign LEDR[8] = 1;
assign LEDR[9] = 0;
