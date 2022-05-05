`timescale 1ps/1ps

module main();
    wire clk;
    clock theClock(clk);

    wire SRAM_WE, SRAM_CE, SRAM_OE, SRAM_LB, SRAM_UB;
    wire [17:0]SRAM_A;
    wire [15:0]SRAM_D;

    wire SPEAKER;
    wire [9:0]LED_R;
    wire [7:0]LED_G;

    cpu2 CPU(clk, SRAM_WE, SRAM_CE, SRAM_OE, SRAM_LB, SRAM_UB, SRAM_A, SRAM_D, SPEAKER, LED_R, LED_G);
    harness_SRAM sram(clk, SRAM_A, SRAM_D);
endmodule

module clock(output clk);
    reg theClock = 0;
    assign clk = theClock;

    always begin
        #8;
        theClock = !theClock;
    end
endmodule

module harness_SRAM(input clk, input [17:0]SRAM_A, output [15:0]SRAM_D);
    reg [15:0]data[0:2047];
    
    reg [17:0]mar;
    reg [15:0]mdr;

    assign SRAM_D = mdr;

    always @(posedge clk) begin
        mar <= SRAM_A;
        mdr <= data[mar];
    end

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, main);
        $readmemh("mem.hex", data);
    end
endmodule
