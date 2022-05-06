import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;

public class MidiToRISCmaninov {

    static class Note {
        String note;
        int octave;
        int length;
        boolean isRest;

        public Note(String note, int octave, int length, boolean isRest) {
            this.note = note;
            this.octave = octave;
            this.length = length;
            this.isRest = isRest;
        }

        @Override
        public String toString() {
            if (isRest) {
                return "rest 1/" + length;
            } else {
                return note + " " + octave + " 1/" + length;
            }
        }
    }

    private static final String HEADER = "Header";
    private static final String TEMPO = "Tempo";
    private static final String NOTE_ON_C = "Note_on_c";

    private static final double MINUTE_MICROSECONDS = 6e7;
    private static final int MIN_NOTE_LENGTH = 64;
    private static final int NOTE_OFFSET = 12;
    private static final int NUM_NOTE_LENGTHS = 16;

    private static final String[] notes = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
    private static final int[] noteLengths = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 16, 24, 32, 64};

    public static void main(String[] args) {
        /*
         * Midi to CSV
         *
         * Works with MIDI Format Type 1 only
         *
         * Assumes only one note is played at a time
         */
        try {
            String[] command = {"midicsv", args[0], "csv.in"};
            execute(command);
        } catch (IOException e) {
            System.out.println(e.getMessage());
            System.out.println(e.getStackTrace());
        } catch (InterruptedException e) {
            System.out.println(e.getMessage());
            System.out.println(e.getStackTrace());
        }

        // CSV to Bythoven
        try {
            BufferedReader bufferedReader = new BufferedReader(new FileReader("csv.in"));
            PrintWriter printWriter = new PrintWriter(new FileWriter("output.music"));

            String line;

            int measureLength = 48;
            int measureMinLength = 0;
            int bpm = 120;

            int previousTime = 0;

            ArrayList<Note> instructions = new ArrayList<>();

            while ((line = bufferedReader.readLine()) != null) {
                String[] instruction = line.split(", ");
                int time1 = Integer.parseInt(instruction[1]);
                String instructionType = instruction[2];

                switch(instructionType) {
                    case HEADER:
                        measureLength = Integer.parseInt(instruction[5]);
                        measureMinLength = measureLength / MIN_NOTE_LENGTH;
                        break;
                    case TEMPO:
                        bpm = (int) MINUTE_MICROSECONDS / Integer.parseInt(instruction[3]);
                        break;
                    case NOTE_ON_C:
                        int timeDifference = (time1 - previousTime);

                        if (timeDifference > measureMinLength) {
                            for (int i = 0; i < NUM_NOTE_LENGTHS; i++) {
                                while (timeDifference - measureLength / noteLengths[i] > 0) {
                                    timeDifference -= measureLength / noteLengths[i];
                                    Note note = makeNote(-1, noteLengths[i], measureLength);
                                    instructions.add(note);
                                }
                            }
                        }

                        line = bufferedReader.readLine();
                        instruction = line.split(", ");

                        int time2 = Integer.parseInt(instruction[1]);
                        int noteValue = Integer.parseInt(instruction[4]);

                        Note note = makeNote(noteValue, time2 - time1, measureLength);

                        instructions.add(note);

                        previousTime = time2;

                        break;
                }
            }

            printWriter.println("bpm " + bpm);

            for (Note note : instructions) {
                printWriter.println(note);
            }

            printWriter.println("end");

            bufferedReader.close();
            printWriter.close();
        } catch (IOException e) {
            System.out.println(e.getMessage());
            System.out.println(Arrays.toString(e.getStackTrace()));
        }
    }

    public static void execute(String[] command) throws IOException, InterruptedException {
        ProcessBuilder processBuilder = new ProcessBuilder(command);
        Process process = processBuilder.start();
        process.waitFor();
    }

    public static Note makeNote(int noteValue, int noteLength, int measureLength) {
        if (noteValue == -1) {
            return new Note("", -1, noteLength, true);
        }

        int octave = (noteValue - NOTE_OFFSET) / NOTE_OFFSET;
        String note = notes[noteValue - NOTE_OFFSET * (octave + 1)];
        int length = (int) Math.round((double) measureLength / noteLength);

        return new Note(note, octave, length, false);
    }
}
