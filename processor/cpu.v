

module cpu (
     // 50MHz input clock
    input wire CLK,

    // SRAM
    output wire SRAM_WE,
    output wire SRAM_CE,
    output wire SRAM_OE,
    output wire SRAM_LB,
    output wire SRAM_UB,
    output wire [17:0] SRAM_A,
    input wire [15:0] SRAM_D,

    // hardware
    output wire SPEAKER,
    output wire [9:0] LED_R,
    output wire [7:0] LED_G
);


    reg [15:0] curIns;
	 reg [17:0] sram_addr_reg;
    reg [31:0] cycleCounter = 0;


    // calculate freq from note
    wire [19:0] freq;
    wire [3:0] note = curIns[3:0];
    freqCalc fc (note, 0, freq);

    // calculate cycles
    wire [63:0] bpm = 30;
    wire [63:0] cyclesPerBeat = 60 * 50000000 / bpm;

	//debug LED
    assign LED_R[0] = curIns[15];


    // speaker
    reg [31:0] freqCur = 227272;
    reg [31:0] freqCounter = 0;
    reg isPlayingNote = curIns[0];
    assign SPEAKER = isPlayingNote ? (freqCounter >= freqCur/2) : 0;

    always @(posedge CLK) begin
        if(freqCounter >= freqCur) begin
            freqCounter <= 0;
        end else begin
            freqCounter <= freqCounter+1;
        end
    end


    // sram stuff
    wire readSram;
    assign SRAM_WE = 1;
    assign SRAM_CE = 0;
    assign SRAM_OE = 0;
    assign SRAM_LB = 0;
    assign SRAM_UB = 0;
    assign SRAM_A = sram_addr_reg;

    reg [17:0] pc = 18'b000000000000000000;


    // get next instructions
    always @(posedge CLK) begin
        if(cycleCounter == 1) begin
            sram_addr_reg <= pc;
        end
        if(cycleCounter == 3) begin
            curIns <= SRAM_D;
            pc <= pc+1;
        end
        if(cycleCounter == cyclesPerBeat-1) begin
            cycleCounter <= 0;
            // freqCur <= freq;
        end
        else begin
            cycleCounter <= cycleCounter+1;
        end
    end

    


endmodule