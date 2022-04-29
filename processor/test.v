<<<<<<< HEAD

module test (
input wire clk, // 50MHz input clock
output wire speaker,
output wire speaker2,
output wire LED
);

reg [31:0] cnt;
reg freq;
reg [31:0] LEDcnt;
reg LEDfreq;

initial begin
	cnt <= 32'h00000000;
	freq <= 0;
	LEDcnt <= 0;
	LEDfreq <= 0;
end
always @(posedge clk) begin
	if(cnt == 113636/2)
		cnt <= 0;
	else
		cnt <= cnt+1;
end

always @(posedge clk) begin
	if(cnt == 0)
		freq <= ~freq;
end

always @(posedge clk) begin
	if(LEDcnt == 440) begin
		LEDfreq <= ~LEDfreq;
		LEDcnt <= 0;
	end
	else if(cnt == 0)
		LEDcnt <= LEDcnt+1;

end

assign speaker = freq;
assign speaker2 = freq;
assign LED = LEDfreq;

endmodule
=======
input [9:0] SW; //Input Declarations: 10 slide switches
output [9:0] LEDR; //Output Declarations: 10 red LED lights

assign LEDR[7:0] = SW[7:0];
assign LEDR[8] = 1;
assign LEDR[9] = 0;
>>>>>>> 3c5eb237408dd1426611cdfe0ea8f002986b52ab
