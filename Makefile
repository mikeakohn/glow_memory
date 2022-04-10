
PROGRAM=glow_memory
SOURCE=$(PROGRAM).v ram.v

default:
	yosys -q -p "synth_ice40 -top $(PROGRAM) -json $(PROGRAM).json" $(SOURCE)
	nextpnr-ice40 -r --hx8k --json $(PROGRAM).json --package cb132 --asc $(PROGRAM).asc --opt-timing --pcf $(PROGRAM).pcf
	icepack $(PROGRAM).asc $(PROGRAM).bin

program:
	iceFUNprog $(PROGRAM).bin

clean:
	@rm -f $(PROGRAM).bin $(PROGRAM).json $(PROGRAM).asc
	@echo "Clean!"

