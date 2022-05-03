`define C3 382233
`define D3 340529
`define F3 286352
`define A3 227272


module arpeggiator (
input wire CLK, // 50MHz input clock
output wire SPEAKER,
output wire LED1,
output wire LED2
);

reg [31:0]cnt = 0;
reg [31:0]switchcnt = 0;
reg LEDfreq1 = 1;
reg LEDfreq2 = 1;

wire [31:0]pitch = switchcnt < 10000000 ? `C3/2
						: switchcnt < 20000000 ? `D3
						: switchcnt < 30000000 ? `F3
						: `A3;

always @(posedge CLK) begin
	if(cnt >= pitch)
		cnt <= 0;
	else
		cnt <= cnt+1;
		
	if(switchcnt == 40000000)
		switchcnt <= 0;
	else
		switchcnt <= switchcnt + 1;
end


assign SPEAKER = cnt > pitch/2;

assign LED1 = LEDfreq1;
assign LED2 = LEDfreq2;

endmodule