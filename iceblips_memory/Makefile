
PROGRAM=iceblips_memory
SOURCE=$(PROGRAM).v

default:
	yosys -q -p "synth_ice40 -top $(PROGRAM) -json $(PROGRAM).json" $(SOURCE)
	nextpnr-ice40 -r --lp1k --json $(PROGRAM).json --package cm36 --asc $(PROGRAM).asc --opt-timing --pcf $(PROGRAM).pcf
	icepack $(PROGRAM).asc $(PROGRAM).bin

program:
	iceBliProg $(PROGRAM).bin

clean:
	@rm -f $(PROGRAM).bin $(PROGRAM).json $(PROGRAM).asc
	@echo "Clean!"

