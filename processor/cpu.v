

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
	 reg [15:0] nextIns;
	 reg [17:0] sram_addr_reg;
    reg [31:0] cycleCounter = 0;


    // calculate freq from note
    wire [19:0] freq;
    wire [31:0] waves = 50000000 / freq;
    wire [3:0] note = curIns[3:0];
	 wire [1:0] octave = curIns[5:4];
    // freqCalc fc (note, 0, freq);
	 
	 // frequencies x100
	 integer  c3 = 13081;
    integer cz3 = 13859;
    integer  d3 = 14683;
    integer dz3 = 15556;
    integer  e3 = 16481;
    integer  f3 = 17461;
    integer fz3 = 18500;
    integer  g3 = 19600;
    integer gz3 = 20765;
    integer  a3 = 22000;
    integer az3 = 23308;
    integer  b3 = 24694;

	 assign freq =((note % 12 == 0) ? c3 :
						(note % 12 == 1) ? cz3 :
						(note % 12 == 2) ? d3 : 
						(note % 12 == 3) ? dz3 : 
						(note == 4) ? e3 : 
						(note == 5) ? f3 : 
						(note == 6) ? fz3 : 
						(note == 7) ? g3 : 
						(note == 8) ? gz3 : 
						(note == 9) ? a3 : 
						(note == 10) ? az3 : 
						(note == 11) ? b3 : 0) * (2 ** octave) / 100;
	 
	 // Debugging frequency
	 assign LED_G[7:0] = freq[7:0];
	 assign LED_R[9:0] = freq[9:0];

    // calculate cycles
    wire [63:0] bpm = 96;
    wire [63:0] cyclesPerBeat = 60 * 50000000 / bpm;

    // speaker
    reg [31:0] wavesCur = 0;
    reg [31:0] wavesCounter = 0;
    wire isPlayingNote = 1;
    assign SPEAKER = isPlayingNote ? (wavesCounter >= wavesCur/2) : 0;
    

    always @(posedge CLK) begin
        if(wavesCounter >= wavesCur) begin
            wavesCounter <= 0;
        end else begin
            wavesCounter <= wavesCounter+1;
        end
    end
    
	 //debug LED
    // assign LED_R[0] = isPlayingNote;


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
            nextIns <= SRAM_D;
            pc <= pc+1;
        end
        if(cycleCounter == cyclesPerBeat-1) begin
				curIns <= nextIns;
            cycleCounter <= 0;
            wavesCur <= waves;
        end
        else begin
            cycleCounter <= cycleCounter+1;
        end
    end

    


endmodule