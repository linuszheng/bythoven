
module test (
input wire clk, // 50MHz input clock
output wire speaker,
output wire speaker2,
output wire speakerBoth,
output wire LED,
output wire LED2
);

reg [31:0] cnt = 0;
reg [31:0] cnt2 = 0;
reg freq = 0;
reg freq2 = 0;
reg [31:0] LEDcnt = 0;
reg [31:0] LEDcnt2 = 0;
reg LEDfreq = 1;
reg LEDfreq2 = 1;
/*
initial begin
	cnt <= 32'h00000000;
	cnt2 <= 32'h00000000;
	freq <= 0;
	freq2 <= 0;
	LEDcnt <= 0;
	LEDfreq <= 0;
end
*/
always @(posedge clk) begin
	if(cnt == 113636)
		cnt <= 0;
	else
		cnt <= cnt+1;
		
	if(cnt2 == 160706)
		cnt2 <= 0;
	else
		cnt2 <= cnt2+1;
end

/*
always @(posedge clk) begin
	if(cnt == 0)
		freq <= ~freq;
	if(cnt2 == 0)
		freq2 <= ~freq2;
end


always @(posedge clk) begin
	if(LEDcnt == 440) begin
		LEDfreq <= ~LEDfreq;
		LEDcnt <= 0;
	end
	else if(cnt == 0)
		LEDcnt <= LEDcnt+1;

	if(LEDcnt2 == 311) begin
		LEDfreq2 <= ~LEDfreq2;
		LEDcnt2 <= 0;
	end
	else if(cnt2 == 0)
		LEDcnt2 <= LEDcnt2+1;
end

*/

assign f1 = cnt > 113636/128*127;
assign f2 = cnt > 113636/4*3;

assign speaker = f1;
assign speaker2 = f2;
assign speakerBoth = f1 | f2;
assign LED = LEDfreq;
assign LED2 = LEDfreq2;

endmodule