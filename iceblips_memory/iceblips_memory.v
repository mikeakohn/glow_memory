module iceblips_memory
(
  output led_0,
  output led_1,
  inout [3:0] data,
  input [3:0] address,
  input phi2,
  input web,
  output be,
  input clk
);

reg [3:0] data_out = 4'ha;
reg [3:0] memory = 0;

reg [21:0] count = 0;
reg [21:0] bus_hold_count = 0;
reg led_value = 0;
reg web_was_high = 0;
reg be_value = 1;

assign memoeb = web & phi2;
assign memweb = ~web & phi2;
assign data = memoeb ? data_out : 'z;
assign bus_is_busy = bus_hold_count != 0;
assign be = be_value | ~phi2;
//assign be = bus_hold_count < 4;
//assign be = bus_hold_count == 0;
//assign nmib = 0;
//assign led_0 = bus_hold_cout == 0;
assign led_0 = led_value;
assign led_1 = be;

always @(posedge memoeb) begin
  case (address)
    0: data_out <= 4'b1110;
    1: data_out <= 4'b0110;
    2: data_out <= 4'b1010;
    3: data_out <= 4'b1100;
    4: data_out <= 4'b0110;
    5: data_out <= 4'b1010;
    6: data_out <= 4'b0000;
    7: data_out <= 4'b1100;
    8: data_out <= memory;
    default: data_out <= 4'hf;
  endcase
end

always @(negedge memweb) begin
  if (address == 8) begin
    memory <= data;
  end
end

always @(posedge clk) begin
  count = count + 1;
end

always @(posedge phi2) begin
  if (web == 0 && web_was_high == 0 && address == 8) begin
    bus_hold_count <= 4000000;
    web_was_high <= 1;
    be_value <= 0;
  end else if (bus_hold_count == 1) begin
    be_value <= 1;
    bus_hold_count <= bus_hold_count - 1;
  end else if (bus_hold_count > 1) begin
    bus_hold_count <= bus_hold_count - 1;
  end else if (bus_hold_count == 0 && web == 1) begin
    web_was_high <= 0;
  end
end

always @(posedge count[21]) begin
  led_value <= led_value ^ 1;
end

endmodule

