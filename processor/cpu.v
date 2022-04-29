`timescale 1ps/1ps





module clock(output clkOut);
    reg clock = 0;
    assign clkOut = clock;

    always begin
        #500;
        clock <= !clock;
    end
endmodule







module bythoven();

    wire clkOut;
    clock myclock(clkOut);

    reg [63:0]regs[0:31];                   // 64 bits * 31 regs
    reg [7:0]mem[0:1023];                   // 8 bits (1 byte) * 1024 = 32 bits (1 word) * 64

    reg [63:0]pc = 64'h0000000000000000;    // 16 * 4 = 64
    wire [7:0]rdata = mem[raddr];           // 8 bits
    reg [31:0]curIns = 32'h00000000;

    wire [9:0]raddr;                        // 10 bits (2^10=1024)
    wire isUndefined;

    wire isSingleNote = curIns[30:23] == 8'b00000000;
    
    integer i;

    // debugging
    reg[5:0] emergencyCounter = 0;




    always @(posedge clkOut) begin
        emergencyCounter <= emergencyCounter + 1;
    end




    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0,main);
    end

    initial begin
        $readmemh("mem.hex",mem);
    end
/*
    initial begin
        $readmemh("regs.hex",regs);
    end
	 */

endmodule


