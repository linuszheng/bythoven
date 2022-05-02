

module cpu (
     // 50MHz input clock
    input wire clk,

    // SRAM
    output wire sram_WE,
    output wire sram_CE,
    output wire sram_OE,
    output wire sram_LB,
    output wire sram_UB,
    output wire [17:0] sram_addr;
    input wire [15:0] sram_io;

    // hardware
    output wire speaker,
    output wire LED,
    output wire LED2
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




    // sram stuff
    wire readSram;
    assign sram_WE = 1;
    assign sram_CE = 0;
    assign sram_OE = 0;
    assign sram_LB = 0;
    assign sram_UB = 0;
    assign sram_addr = sram_addr_reg;


    // m
    integer bpm = 96;
    integer cyclesPerBeat = 60 * 50000000 / bpm;

    reg [15:0] curIns;
    reg [17:0] sram_addr_reg;
    reg [31:0] counter = 0;

    assign LED = curIns[0];
    assign LED2 = curIns[1];

    reg firstIns = 1;
    // get first instruction
    always @(posedge clk) begin
        if(firstIns) begin
            sram_addr_reg <= 0'b000000000000000000;
            firstIns <= 0;
        end
        if(counter == 2) begin
            curIns <= sram_io;
        end
        counter <= counter+1;
    end
    // get next instructions
    always @(posedge clk) begin
        if(counter % 2 == 3) begin
            
        end
    end

    


endmodule