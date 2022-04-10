// glow_memory.
//
// Copyright 2022 - By Michael Kohn
// https://www.mikekohn.net/
// mike@mikekohn.net
//
// Board: iceFUN iCE40 HX8K
// Connect iceFUN to a set of 8 LEDs and 8 phototransistors that are covered
// by glow in the dark stickers so they can be used as 8 bits (1 byte) of RAM.
// On the other side of the iceFUN is a Western Design Center W65C265SXB.

module glow_memory
(
  output [7:0] glow_leds,
  input [7:0] glow_value,
  inout [7:0] data,
  input [3:0] address,
  input phi2,
  input web,
  output be,
  output [7:0] leds,
  output [3:0] column,
  input clk,
  input reset
);

reg [21:0] count = 0;
reg [7:0] debug_state;
reg [7:0] debug_value;
wire [3:0] state;
wire busy;

assign state = count[8:5];
assign be = ~reset | ~busy | ~phi2;

always @(posedge clk) begin
  count <= count + 1;
end

always @(state) begin
  case (state)
    4'b0000: begin column <= 4'b1110; leds <= ~data; end
    4'b0100: begin
      column <= 4'b1101;
      //leds[3:0] <= ~address;
      //leds[7:4] = 4'hf;
      leds[7:0] <= ~debug_value;
    end
    4'b1000: begin
      column <= 4'b1011;
      leds[0] <= ~web;
      leds[1] <= ~phi2;
      leds[2] <= ~be;
      leds[3] <= ~busy;
      leds[4] <= ~reset;
      leds[7:5] <= 3'b111;
    end
    //4'b1100: begin column <= 4'b0111; leds <= 8'hff; end
    4'b1100: begin column <= 4'b0111; leds <= debug_state; end
    default: begin column <= 4'b1111; leds <= 8'hff; end
  endcase
end

ram ram_0(
  .address_bus (address),
  .data_bus (data),
  .clk (phi2),
  .web (web),
  .busy (busy),
  .reset (reset),
  .glow_leds (glow_leds),
  .glow_value (glow_value),
  .debug_state (debug_state),
  .debug_value (debug_value)
);

endmodule

