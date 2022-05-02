

module cpu (
     // 50MHz input clock
    input wire clk,

    // SRAM
    output wire SRAM_WE,
    output wire SRAM_CE,
    output wire SRAM_OE,
    output wire SRAM_LB,
    output wire SRAM_UB,
    output wire [17:0] SRAM_A,
    input wire [15:0] SRAM_D,

    // hardware
    output wire speaker,
    output wire [9:0] LED_R,
    output wire [7:0] LED_G
);

    // reg [31:0] cnt = 0;
    // reg freq = 0;
    // reg freq2 = 0;
    // reg [31:0] LEDcnt = 0;
    // reg [31:0] LEDcnt2 = 0;
    // reg LEDfreq = 1;
    // reg LEDfreq2 = 1;

    // always @(posedge clk) begin
    //     if(cnt == 113636)
    //         cnt <= 0;
    //     else
    //         cnt <= cnt+1;
            
    //     if(cnt2 == 160706)
    //         cnt2 <= 0;
    //     else
    //         cnt2 <= cnt2+1;
    // end

    // assign f1 = cnt > 113636/128*127;
    // assign f2 = cnt > 113636/4*3;

    // assign speaker = f1;
    // assign speaker2 = f2;
    // assign speakerBoth = f1 | f2;
    // assign LED = LEDfreq;
    // assign LED2 = LEDfreq2;




    wire [19:0] freq;
    // freqCalc(note, 0, freq);




    // m
    wire [63:0] bpm = 96;
    wire [63:0] cyclesPerBeat = 60 * 50000000 / bpm;

    reg [15:0] curIns;
    reg [17:0] sram_addr_reg;
    reg [31:0] counter = 0;

    assign LED_R[0] = curIns[0];


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
    always @(posedge clk) begin
        if(counter % cyclesPerBeat == 1) begin
            sram_addr_reg <= pc;
        end
        if(counter % cyclesPerBeat == 3) begin
            curIns <= SRAM_D;
            pc <= pc+1;

        end
        // if(curIns[0] == 1) begin
        //     // note
        // end
        // else begin
        //     // setting
        // end
        counter <= counter+1;
    end

    


endmodule