# bythoven



# riscmaninov



# mozarch


The many names of our final CS 429H (Computer Architecture) project, a processor dedicated to playing music. Our group of 4 designed a programming language (RISCmaninov) for aspiring musicians to write their music, wrote a compiler to convert it into our "assembly language" (BYThoven), designed a processor in Verilog to read our instruction set and output music to a speaker, and flashed it all onto a Cyclone V FPGA board. Oh and we have a transpiler to take midi files and turn it into RISCmaninov. Our 16-bit BYThoven instruction set includes 4 primary instructions: one for playing notes and rests, one to set the bpm, one for repeats, and an end instruction. We support every note spanning 4 octaves, a hand-curated list of the 16 most common beat denominators, speeds of up to 4096 beats per minute, and BYThoven files of 4Mb. We have a specialized pipelined multicycle design that results in a 0 cycle latency between consecutive notes, and our PWM algorithm outputs only the highest quality of sounds. Our repeat instruction is a condensed combination of register moving and branching, and (if it works) we support up to 64x repeats nested 8 layers deep. Our language is rich and expressive, allowing the musician to play legato and staccato at four different volume levels. Thank you all for your support, and more features are on the way.  

https://drive.google.com/file/d/1HX9qpktK-txyyVZEsxy0H3RYlLlWDbsL/view
