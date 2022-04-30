

module freqCalc(input[3:0] note, input octave[1:0], output[19:0] freq);

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

    integer freqArr[11:0];

    // octaves: c3 to c7
    // = 4 octaves = 48 notes
    initial begin
        freqArr[0] = c3;
        freqArr[1] = cz3;
        freqArr[2] = d3;
        freqArr[3] = dz3;
        freqArr[4] = e3;
        freqArr[5] = f3;
        freqArr[6] = fz3;
        freqArr[7] = g3;
        freqArr[8] = gz3;
        freqArr[9] = a3;
        freqArr[10] = az3;
        freqArr[11] = b3;
    end

    assign freq = freqArr[note] * (2 ** octave) / 100;
endmodule
