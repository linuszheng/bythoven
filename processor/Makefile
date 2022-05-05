VFILES=$(wildcard *.v)

all: cpu

cpu: $(VFILES) Makefile
	iverilog -o cpu $(VFILES)

