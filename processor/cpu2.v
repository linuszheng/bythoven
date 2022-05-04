

module cpu (
    // clock
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

    // CONSTANTS
    // 50MHz input clock
    wire [31:0] _CYCLES_PER_SEC = 50000000;



    // -----------------------------[ STAGE: FETCH    ]------------------------------
    reg [17:0] F_pc = 0;



    // -----------------------------[ STAGE:  WAIT    ]-------------------------------
    reg [15:0] W_ins = 0;

    // get next instructions
    always @(posedge CLK) begin
        if(cycleCounter == 3) begin
            nextIns <= SRAM_D;
            pc <= pc+1;
        end
    end



    // -----------------------------[ STAGE:  EXECUTE ]-------------------------------
    reg [15:0] X_ins = 0;
    wire [3:0] X_note = X_ins[3:0];
    wire [31:0] X_soundWavesPerSec = ((X_note % 12 == 0) ? c3 :
                                    (X_note % 12 == 1) ? cz3 :
                                    (X_note % 12 == 2) ? d3 : 
                                    (X_note % 12 == 3) ? dz3 : 
                                    (X_note == 4) ? e3 : 
                                    (X_note == 5) ? f3 : 
                                    (X_note == 6) ? fz3 : 
                                    (X_note == 7) ? g3 : 
                                    (X_note == 8) ? gz3 : 
                                    (X_note == 9) ? a3 : 
                                    (X_note == 10) ? az3 : 
                                    (X_note == 11) ? b3 : 0) / 100;
    wire [31:0] X_cyclesPerSoundWave = _CYCLES_PER_SEC / X_soundWavesPerSec;

    reg [31:0] X_cycleCounter = 0;





    reg [15:0] curIns;
	 reg [15:0] nextIns;
	 reg [17:0] sram_addr_reg;
    reg [31:0] cycleCounter = 0;


	 
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
    


endmodule