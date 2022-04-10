;; Glow Blink
;; Copyright 2022 - Michael Kohn
;;
;; Blink two LEDs on the WDC MENSCH Microcomputer board.
;;
;; After setting an LED on, write some data to location 0x200 (mapped to
;; the FPGA). After pausing (before sitting the next LED) read the data from
;; 0x200 back to see if it matches what's expected.
;;

.65816

.include "w65c265.inc"

.macro PAUSE
.scope
  ldy #0
repeat:
  dey
  bne repeat
.ends
.endm

.org 0xc0
start:

  ; Disable interrupts
  sei

  ; Set native mode
  clc
  xce

  ; Set A to 8-bit
  sep #0x20

  ; Set X/Y to 16-bit
  rep #0x10

  ; Set port 7 in data mode.  Port 7 seems to be always an output
  ; port.  The PCS7 register needs to be set to 0 to let this port
  ; work.
  lda.b #0x00
  sta PCS7

  ; Set port 7 value to 0x80.  Port 7 is hooked up to 8 LEDs.  Every
  ; bit in the PD7 register is conneted to one LED.  So by setting this
  ; register to 0x80 (binary 10000000), LED number 7 will be turned on.
  sta PD7

  ; Enable interrupts
  cli

main:
  ;; Turn on LED 0.
  lda data
  ora.b #0x01
  sta PD7
  ;; Set glow memory byte to 0x01.
  lda.b #0x01
  sta 0x0200
  PAUSE
  ;; Clear error LEDs.
  lda.b #0x00
  sta data
  ;; Verify glow memory reads back as 0x01.
  lda 0x0200
  cmp.b #0x01
  beq value_01_okay
  ;; If value is wrong turns on LED 7.
  lda.b #0x80
  sta data
value_01_okay:
  ;; Turn on LED 1.
  lda data
  ora.b #0x02
  sta PD7
  ;; Set glow memory byte to 0x60.
  lda.b #0x60
  sta 0x0200
  PAUSE
  ;; Clear error LEDs.
  lda.b #0x00
  sta data
  ;; Verify glow memory reads back as 0x60.
  lda 0x0200
  cmp.b #0x60
  beq value_60_okay
  ;; If value is wrong turns on LED 6.
  lda.b #0x40
  sta data
value_60_okay:
  jmp main

data:
 .db 0

