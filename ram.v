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

// State 0: Memory is readable (optimized for zero).
// State 1: Erase cycle.
// State 2: Move to state 3.
// State 3: Write cycle.
// State 4: Move to state 5.
// State 5: Memory is readable (non-zero).

module ram
(
  input [3:0] address_bus,
  inout [7:0] data_bus,
  input clk,
  input web,
  output busy,
  input reset,
  output [7:0] glow_leds,
  input [7:0] glow_value,
  output [7:0] debug_state,
  output [7:0] debug_value
);

reg [2:0] state = 0;
reg [2:0] next_state = 0;
reg [7:0] value; // = 8'h00;
reg [23:0] count = 0;
reg busy = 0;
reg web_was_set = 0;
reg state_was_set = 0;
reg count_reset;

assign memoeb = web & clk;
assign memweb = ~web & clk;
assign data_bus = memoeb ? ~glow_value : 'z;
//assign debug_state = count[20:13];
assign debug_state = ~(state | (web_was_set << 4) | (state_was_set << 5));
assign debug_value = value;

always @(posedge clk) begin
  if (count_reset) begin
    count <= 0;
  end else begin
    count = count + 1;
  end
end

always @(posedge clk or negedge reset) begin
  if (~reset)
    state <= 0;
  else if (web == 0 && busy == 0)
    state <= 1;
  else
    state <= next_state;
end

always @(state or count) begin
  case (state)
    0:
      // State 0: Current value is 0.
      begin
        busy <= 0;
        glow_leds <= 0;
        count_reset <= 1;
        next_state = state;
      end
    1:
      // State 1: Erase cycle, pause CPU and wait for glow to disappear.
      begin
        busy <= 1;
        glow_leds <= 0;
        count_reset <= 1;

        if (glow_value == 8'hff) begin
          next_state = 2;
        end else begin
          next_state = state;
        end
      end
    2:
      // State 2: Prepare for state 3.
      begin
        busy <= 1;
        glow_leds <= 0;
        count_reset <= 1;
        next_state = 3;
      end
    3:
      // State 3: Write cycle, pause CPU.
      begin
        busy <= 1;
        count_reset <= 0;

        // Debug.
        state_was_set <= 1;

        if (value == 0) begin
          glow_leds <= 0;
          next_state = 0;
        end else if (count == 4000000) begin
          glow_leds <= 0;
          next_state = 4;
        end else begin
          glow_leds <= value;
          next_state = state;
        end
      end
    4:
      // State 4: Prepare for state 5.
      begin
        busy <= 1;
        glow_leds <= 0;
        count_reset <= 1;
        next_state = 5;
      end
    5:
     // State 5: Normal read state.
      begin
        busy <= 0;
        glow_leds <= 0;
        count_reset <= 0;

        if (count == 8000000) begin
          next_state = 2;
        end else begin
          next_state = state;
        end
      end
    default:
      begin
        busy <= 0;
        glow_leds <= 0;
        count_reset <= 0;
        next_state = state;
      end
  endcase
end

always @(posedge memweb) begin
  if (memweb == 1) begin
    web_was_set = 1;
  end
end

always @(negedge memweb) begin
  value <= data_bus;
end

endmodule

