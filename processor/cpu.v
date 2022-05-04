

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


	 // instruction
    reg [15:0] curIns;
	 reg [15:0] nextIns;
	 reg [17:0] sram_addr_reg;
    reg [31:0] cycleCounter = 0;


    // calculate freq from note
    wire [19:0] freq;
	 wire isValidFreq;
	 
    wire [3:0] note = curIns[3:0];
	 wire [1:0] octave = curIns[5:4];
	 wire [31:0] waves = 50000000 / freq;
    wire [2:0] volume = curIns[7:6]+1;

    freqCalc fc (note, octave, freq, isValidFreq);


    // instruction decoding
    wire insIsNote = curIns[15];
    wire insIsEnd = curIns[15:12] == 4'b0000;
    wire insIsBpm = curIns[15:12] == 4'b0001;


	
	 // debugging frequency
	 assign LED_G[3:0] = note;
	 assign LED_R[9:0] = note+12*octave;

    // calculate cycles
    reg [63:0] bpm = 96;
    wire [63:0] cyclesPerBeat = 60 * 50000000 / bpm;
	 wire [63:0] noteCycles;
	 wire [3:0] length = curIns[11:8];
	 lengthCalc lc (length, cyclesPerBeat, noteCycles);

    // speaker
    reg [31:0] wavesCounter = 0;
														// adds a slight pause between notes
    wire isPlayingNote = isValidFreq && cycleCounter < noteCycles - 2000000;
    assign SPEAKER = isPlayingNote ? (wavesCounter > waves/4) : 0;
    
	 // counter for playing a frequency
    always @(posedge CLK) begin
        if(wavesCounter >= waves) begin
            wavesCounter <= 0;
        end else begin
            wavesCounter <= wavesCounter+1;
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


	 reg firstInstruction = 1;
	 
    // get next instructions
    always @(posedge CLK) begin
        if(cycleCounter == 1) begin
            sram_addr_reg <= pc;
        end
        if(cycleCounter == 3) begin
            nextIns <= SRAM_D;
            pc <= pc+1;
        end
		  if(firstInstruction && cycleCounter == 5) begin
				curIns <= nextIns;
				cycleCounter <= 0;
				firstInstruction <= 0;
		  end
        else if(!firstInstruction && cycleCounter == noteCycles) begin
				curIns <= nextIns;
            cycleCounter <= 0;
        end
        else begin
            cycleCounter <= cycleCounter+1;
        end
    end

    


endmodule