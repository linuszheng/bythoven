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

// octaves: c3 to c7
// = 4 octaves = 48 notes

integer freqArr[12] = {
    c3, cz3, d3, dz3, e3, f3, fz3, g3, gz3, a3, az3, b3
};

module freqCalc(input wire note, input wire octave, output wire [20] freq);
    assign freq = freqArr[note] * octave / 100;
endmodule;
