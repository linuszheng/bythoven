

// CONSTANTS
// 50MHz input clock
`define _CYCLES_PER_SEC 50000000
`define _SEC_PER_MIN 60
`define _DEFAULT_BPM 96
`define _PLACEHOLDER_INS 16'b1000000000000001
`define _PAUSE_LENGTH 2000000

module cpu2 (
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


    // SRAM
    assign SRAM_WE = 1;
    assign SRAM_CE = 0;
    assign SRAM_OE = 0;
    assign SRAM_LB = 0;
    assign SRAM_UB = 0;
    assign SRAM_A  = FR_pc;

    // FW = Fetch + Wait (Multicycle)
    reg [17:0] FR_pc = 0;
    reg [15:0] FR_lastReadIns = `_PLACEHOLDER_INS;
    wire FR_shouldFetchIns = FR_insIsValid && !FR_insIsEnd && (!FR_insIsNote || X_cycleCounterForNotes == 0);
    wire FR_shouldReadIns  = FR_insIsValid && !FR_insIsEnd && (!FR_insIsNote || X_cycleCounterForNotes == 2);

    // Decoding
    wire FR_insIsNote  = (FR_lastReadIns[15] == 1);
    wire FR_insIsEnd   = (FR_lastReadIns[15:12] == 4'b0000);
    wire FR_insIsBpm   = (FR_lastReadIns[15:12] == 4'b0001);
    wire FR_insIsValid = FR_insIsNote || FR_insIsBpm || FR_insIsEnd;

    // Music Properties
    wire [11:0] FR_insBpm = FR_lastReadIns[11:0];

    // Initial settings
    reg [11:0] FR_bpm = `_DEFAULT_BPM;

    /* assign sramAddrReg = FR_pc; */
    /* // -----------------------------[ STAGE: FETCH    ]------------------------------ */
    /* wire FR_fetch = X_cycleCounterForNotes % 3 == 0; */
    /* always @(posedge CLK) begin */
    /*     if(FR_fetch && FR_shouldFetchIns) begin */
    /*         sramAddrReg <= FR_pc; */
    /*     end */
    /* end */


    // -----------------------------[ STAGE:  READ    ]-------------------------------
    wire FR_read = X_cycleCounterForNotes % 4 == 2;
    always @(posedge CLK) begin
        if(FR_read && FR_shouldReadIns) begin
            FR_lastReadIns <= SRAM_D;
            FR_pc <= FR_pc+1;

            if(FR_insIsBpm) begin
                FR_bpm <= FR_insBpm;
            end
        end
    end



    // -----------------------------[ STAGE:  EXECUTE ]-------------------------------
    reg [15:0] X_ins = `_PLACEHOLDER_INS;

    reg [31:0] X_cycleCounterForNotes = 0;
    reg [31:0] X_cycleCounterForSoundWaves = 0;

    // Music Properties
    reg [11:0] X_bpm = `_DEFAULT_BPM;

    // Note Decoding
    wire X_insIsNote = (X_ins[15] == 1);
    wire [3:0] X_note = X_ins[3:0];
    wire [1:0] X_octave = X_ins[5:4];
    wire [2:0] X_volume = X_ins[7:6];
    wire [3:0] X_lengthCode = X_ins[11:8];
    wire [1:0] X_styleCode = X_ins[13:12];
    wire X_extraInfo = X_ins[14];

    // note
    wire [63:0] X_cyclesPerBeat = `_CYCLES_PER_SEC * `_SEC_PER_MIN / X_bpm;
    wire [63:0] X_cyclesPerNote;
    lengthCalc lc (X_lengthCode, X_cyclesPerBeat, X_cyclesPerNote);

    // soundwave
    wire [31:0] X_cyclesPerSoundWave = `_CYCLES_PER_SEC / X_soundWavesPerSec;
    wire [19:0] X_soundWavesPerSec;     // = X_freq
    wire X_freqIsValid;
    freqCalc fc (X_note, X_octave, X_soundWavesPerSec, X_freqIsValid);

    // speaker
    wire X_separationPause = X_cycleCounterForSoundWaves > X_cyclesPerSoundWave - `_PAUSE_LENGTH;
    wire X_playNote = X_freqIsValid && !X_separationPause;
    wire [31:0] X_oneMinusDutyCycle = X_cyclesPerSoundWave / 4;
    wire X_inDutyCycle = X_cycleCounterForSoundWaves > X_oneMinusDutyCycle;
    assign SPEAKER = X_playNote && X_inDutyCycle && X_insIsNote;

    // leds
	assign LED_G[3:0] = X_note;
	assign LED_R[9:0] = X_note+12*X_octave;

    // transfer information from FR to X
    always @(posedge CLK) begin
        if(X_cycleCounterForNotes == 0) begin
            X_bpm <= FR_bpm;
            X_ins <= FR_lastReadIns;
        end
    end

    // manage cycleCounterForNotes
    always @(posedge CLK) begin
        if(X_cycleCounterForNotes == X_cyclesPerNote-1) begin
            X_cycleCounterForNotes <= 0;
        end
        else begin
            X_cycleCounterForNotes <= X_cycleCounterForNotes+1;
        end
    end

    // manage cycleCounterForSoundWaves
    always @(posedge CLK) begin
        if(X_cycleCounterForSoundWaves >= X_cyclesPerSoundWave) begin
            X_cycleCounterForSoundWaves <= 0;
        end else begin
            X_cycleCounterForSoundWaves <= X_cycleCounterForSoundWaves+1;
        end
    end

    /* // only for simulation */
    /* always @(posedge CLK) begin */
    /*     if (X_ins == 0) begin */
    /*         $finish; */
    /*     end */
    /* end */
endmodule
