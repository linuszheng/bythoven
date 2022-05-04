

module lengthCalc(
	input wire [3:0] length,
    input wire [63:0] cyclesPerBeat,
    output wire [63:0] cyclesForCurNote
);

	assign cyclesForCurNote = cyclesPerBeat *4 /( (length == 0) ? 1 : 
                                                (length == 1) ? 2 :
                                                (length == 2) ? 3 :
                                                (length == 3) ? 4 :
                                                (length == 4) ? 5 :
                                                (length == 5) ? 6 :
                                                (length == 6) ? 7 :
                                                (length == 7) ? 8 :
                                                (length == 8) ? 9 :
                                                (length == 9) ? 10 :
                                                (length == 10) ? 12 :
                                                (length == 11) ? 15 :
                                                (length == 12) ? 16 :
                                                (length == 13) ? 24 :
                                                (length == 14) ? 32 :
                                                (length == 15) ? 64 : 0 );
	
endmodule
