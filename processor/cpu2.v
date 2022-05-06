// CONSTANTS
// 50MHz input clock
`define _CYCLES_PER_SEC 50000000
`define _SEC_PER_MIN 60
`define _DEFAULT_BPM 96
`define _PLACEHOLDER_INS 16'b1000000000000001
`define _PAUSE_NORMAL_LENGTH 2000000
`define _PAUSE_STACCATO_LENGTH 10000000
`define _DEFAULT_REPEAT_HI 000000000000

/*

TODO
- finish repeat logic for 1 repeat
- finish repeat logic for n nested repeats
- ensure that pause lengths do not shorten the note too much so that it is unhearable,
  also maybe make the pause length a fraction of the note length itself instead of constant

*/

module cpu2 (
    // 50 MHz clock
    input wire CLK,

	// play/pause switch
	input wire PAUSE,

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
    reg [17:0] FR_pc = 18'hff00;
    reg [15:0] FR_lastReadIns = `_PLACEHOLDER_INS;
    wire FR_shouldFetchIns = FR_insIsValid && !FR_insIsEnd && (!FR_insIsNote || X_cycleCounterForNotes == 0);
    wire FR_shouldReadIns  = FR_insIsValid && !FR_insIsEnd && (!FR_insIsNote || X_cycleCounterForNotes == 2);

    // Decoding
    wire FR_insIsNote  = (FR_lastReadIns[15] == 1);
    wire FR_insIsEnd   = (FR_lastReadIns[15:12] == 4'b0000);
    wire FR_insIsBpm   = (FR_lastReadIns[15:12] == 4'b0001);
    wire FR_insIsRep1  = (FR_lastReadIns[15:12] == 4'b0010);
    wire FR_insIsRep2  = (FR_lastReadIns[15:12] == 4'b0011);
    wire FR_insIsValid = FR_insIsNote || FR_insIsRep1 || FR_insIsRep2 || FR_insIsBpm || FR_insIsEnd;
    
    // Repeat - calculations
    wire [11:0] FR_insRepeatHi = FR_lastReadIns[11:0];
    wire [11:6] FR_insRepeatLo = FR_lastReadIns[11:6];
    wire [2:0] FR_insRepeatCount = FR_lastReadIns[5:3];
    wire [2:0] FR_insRepeatLevel = FR_lastReadIns[2:0];
    wire [17:0] FR_nextPc = {FR_regRepeatHi, FR_insRepeatLo};
    reg [2:0] FR_repCounters [7:0];  

    // Music Properties
    wire [11:0] FR_insBpm = FR_lastReadIns[11:0];

    // Initial settings
    reg [11:0] FR_regBpm = `_DEFAULT_BPM;
    reg [11:0] FR_regRepeatHi = `_DEFAULT_REPEAT_HI;

    // -----------------------------[ STAGE:  READ    ]-------------------------------
    wire FR_read = X_cycleCounterForNotes % 4 == 2;
    always @(posedge CLK) begin
        if(FR_read && FR_shouldReadIns) begin
            FR_lastReadIns <= SRAM_D;

            if(FR_insIsBpm) begin
                FR_regBpm <= FR_insBpm;
            end
            if(FR_insIsRep1) begin
                FR_regRepeatHi <= FR_insRepeatHi;
            end
            if (FR_insIsRep2) begin
                if (FR_insRepeatCount == 0) begin
                    FR_pc <= FR_pc+1;
                end
                case(FR_repCounters[FR_insRepeatLevel])
                    0: begin
                        FR_repCounters[FR_insRepeatLevel] <= FR_insRepeatCount;
                        FR_pc <= FR_nextPc;
                    end
                    1: begin
                        FR_repCounters[FR_insRepeatLevel] <= 0;
                        FR_pc <= FR_pc+1;
                    end
                    default: begin
                        FR_repCounters[FR_insRepeatLevel] <= FR_repCounters[FR_insRepeatLevel] - 1;
                        FR_pc <= FR_nextPc;
                    end
                endcase
            end
            else begin
                FR_pc <= FR_pc+1;
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
    wire [31:0] X_interNotePauseLength =    X_styleCode == 0 ? X_cyclesPerNote :
                                            X_styleCode == 1 ? `_PAUSE_STACCATO_LENGTH :
                                            X_styleCode == 2 ? `_PAUSE_NORMAL_LENGTH :
                                            X_styleCode == 3 ? 0 : 0;
    wire X_separationPause = X_cycleCounterForNotes > (X_cyclesPerNote - X_interNotePauseLength);
    wire [31:0] X_dutyCycleThreshold = X_volume == 0 ? 0 :
													X_volume == 1 ? X_cyclesPerSoundWave * 3 / 4 :
													X_volume == 2 ? X_cyclesPerSoundWave / 2 :
													X_volume == 3 ? X_cyclesPerSoundWave / 4 : 0;
    wire X_inDutyCycle = X_cycleCounterForSoundWaves > X_dutyCycleThreshold;

    wire X_isValidNote = X_freqIsValid && X_insIsNote;
    wire X_isNotStopped = !PAUSE && !X_separationPause;
    assign SPEAKER = X_isValidNote && X_isNotStopped && X_inDutyCycle;

    // leds
	assign LED_G[0] = !PAUSE;
	assign LED_G[1] = PAUSE;
	assign LED_R[9:0] = X_note+12*X_octave;

    // transfer information from FR to X
    always @(posedge CLK) begin
        if(X_cycleCounterForNotes == 0) begin
            X_bpm <= FR_regBpm;
            X_ins <= FR_lastReadIns;
        end
    end

    // manage cycleCounterForNotes
    always @(posedge CLK) begin
        if(X_cycleCounterForNotes >= X_cyclesPerNote-1) begin
            X_cycleCounterForNotes <= 0;
        end
        else begin
            X_cycleCounterForNotes <= X_cycleCounterForNotes + (PAUSE ? 0 : 1);
        end
    end

    // manage cycleCounterForSoundWaves
    always @(posedge CLK) begin
        if(X_cycleCounterForSoundWaves >= X_cyclesPerSoundWave) begin
            X_cycleCounterForSoundWaves <= 0;
        end else begin
            X_cycleCounterForSoundWaves <= X_cycleCounterForSoundWaves + (PAUSE ? 0 : 1);
        end
    end

    /* // only for simulation */
    /* always @(posedge CLK) begin */
    /*     if (X_ins == 0) begin */
    /*         $finish; */
    /*     end */
    /* end */
endmodule
