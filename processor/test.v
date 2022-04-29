
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