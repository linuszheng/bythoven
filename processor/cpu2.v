

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
    wire [31:0] _SEC_PER_MIN = 60;
    wire [31:0] _DEFAULT_BPM = 96;
    wire [15:0] _PLACEHOLDER_INS = 0'b1000000000001111;


    // SRAM
    assign SRAM_WE = 1;
    assign SRAM_CE = 0;
    assign SRAM_OE = 0;
    assign SRAM_LB = 0;
    assign SRAM_UB = 0;
    assign SRAM_A = sramAddrReg;

    reg sramAddrReg = 0;



    // FW
    reg [17:0] FW_pc = 0;
    reg [15:0] FW_ins = 0;
    wire FW_shouldFetchIns  = FW_insIsValid && !FW_insIsEnd && (!FW_insIsNote || X_cycleCounterForNotes == 0);
    wire FW_shouldDecodeIns = FW_insIsValid && !FW_insIsEnd && (!FW_insIsNote || X_cycleCounterForNotes == 2);

    // Decoding
    wire FW_insIsNote = (FW_ins[15] == 1);
    wire FW_insIsEnd = (FW_ins[15:12] == 4'b0000);
    wire FW_insIsBpm = (FW_ins[15:12] == 4'b0001);
    wire FW_insIsValid = FW_insIsNote || FW_insIsBpm || FW_insIsEnd;

    // Music Properties
    wire FW_insBpm = FW_ins[11:0];

    // Initial settings
    reg FW_bpm = _DEFAULT_BPM;

    // -----------------------------[ STAGE: FETCH    ]------------------------------
    wire FW_fetch = X_cycleCounterForNotes % 3 == 0;
    always @(posedge CLK) begin
        if(FW_fetch && FW_shouldFetchIns) begin
            sramAddrReg <= FW_pc;
        end
    end



    // -----------------------------[ STAGE:  WAIT    ]-------------------------------
    wire FW_wait = X_cycleCounterForNotes % 3 == 2;
    always @(posedge CLK) begin
        if(FW_wait && FW_shouldDecodeIns) begin
            FW_ins <= SRAM_D;
            FW_pc <= FW_pc+1;

            if(FW_insIsBpm) begin
                FW_bpm <= FW_insBpm;
            end
        end
    end



    // -----------------------------[ STAGE:  EXECUTE ]-------------------------------
    reg X_insIsValid = 1;
    reg [31:0] X_cycleCounter = 0;
    reg [15:0] X_ins = _PLACEHOLDER_INS;

    reg [31:0] X_cycleCounterForNotes = 0;
    reg [31:0] X_cycleCounterForSoundWaves = 0;

    // Music Properties
    reg [31:0] X_bpm = 1;

    // Note Decoding
    wire X_insIsNote = (X_ins[15] == 1);
    wire [3:0] X_note = X_ins[3:0];
    wire [1:0] X_octave = X_ins[5:4];
    wire [2:0] X_volume = X_ins[7:6]+1;
    wire [3:0] X_lengthCode = X_ins[11:8];
    wire [1:0] X_styleCode = X_ins[13:12];
    wire X_extraInfo = X_ins[14];

    // note
    wire [63:0] X_cyclesPerBeat = _CYCLES_PER_SEC * _SEC_PER_MIN / X_bpm;
    wire [63:0] X_cyclesPerNote;
    lengthCalc lc (X_lengthCode, X_cyclesPerBeat, X_cyclesPerNote);

    // soundwave
    wire [31:0] X_soundWavesPerSec;     // = X_freq
    wire [31:0] X_cyclesPerSoundWave = _CYCLES_PER_SEC / X_soundWavesPerSec;
    wire X_freqIsValid;
    freqCalc fc (X_note, X_octave, X_soundWavesPerSec, X_freqIsValid);

    // speaker
    wire X_separationPause = X_cycleCounterForSoundWaves > X_cyclesPerSoundWave - 2000000;
    wire X_playNote = X_freqIsValid && !X_separationPause;
    wire X_oneMinusDutyCycle = X_cyclesPerSoundWave / 4;
    wire X_inDutyCycle = X_cycleCounterForSoundWaves > X_oneMinusDutyCycle;
    assign SPEAKER = X_playNote && X_inDutyCycle;


    // transfer information from FW to X
    always @(posedge CLK) begin
        if(X_cycleCounter == 0) begin
            X_bpm <= FW_bpm;
            X_ins <= FW_ins;
            X_insIsValid <= FW_insIsValid;
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

    


endmodule