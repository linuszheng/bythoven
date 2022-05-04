

module freqCalc(
	input wire [3:0] note,
	input wire [1:0] octave,
	
	output wire [19:0] freq,
	output wire isValid);

   // frequency x100
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

	assign freq = ((note == 0) ? c3 :
					   (note == 1) ? cz3 :
						(note == 2) ? d3 : 
						(note == 3) ? dz3 : 
						(note == 4) ? e3 : 
						(note == 5) ? f3 : 
						(note == 6) ? fz3 : 
						(note == 7) ? g3 : 
						(note == 8) ? gz3 : 
						(note == 9) ? a3 : 
						(note == 10) ? az3 : 
						(note == 11) ? b3 : 0) * (2 ** octave) / 100;
						
	assign isValid = freq != 0;
	
endmodule
