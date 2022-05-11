ORG 00h
; Serial
RST EQU P3.0
CLK EQU P3.1
DQ  EQU P3.2
; Temp Trigger
;TC  EQU P0.0
;TL  EQU P0.1
;TH  EQU P0.2


SETB CLK



LOOP:
  CALL SEND
  CALL RECEIVE
  JMP LOOP

; Request Temperature (AAh = 10101010b)
SEND:
; Reset Thermometer
  CLR RST
  NOP
  SETB RST
  
  CALL SEND_0
  CALL SEND_1
  CALL SEND_0
  CALL SEND_1
  CALL SEND_0
  CALL SEND_1
  CALL SEND_0
  CALL SEND_1
  RET

; ==================
RECEIVE:
  MOV A, #00h
  SETB DQ
  CALL CLOCK
  CALL CLOCK
  CALL CLOCK
  CALL CLOCK
  CALL CLOCK
  CALL CLOCK
  CALL CLOCK
  CALL CLOCK
  CALL CLOCK
  CALL SHOW
  RET



SEND_1:
  CLR CLK
  SETB DQ
  SETB CLK
  RET

SEND_0:
  CLR CLK
  CLR DQ
  SETB CLK
  RET

CLOCK:
  CLR CLK
  JB DQ, SET_CARRY
  CALL SHIFT_AND_CLOCK_HIGH
  RET

SET_CARRY:
  SETB C
  CALL SHIFT_AND_CLOCK_HIGH
  RET

SHIFT_AND_CLOCK_HIGH:
  SETB CLK
  RRC A
  RET

SHOW:
  MOV B, #0Ah
  DIV AB
  ; Wert von B auf rechte 7-Segment Anzeige  
  MOV P0, #11111111b
  CALL SHOW_NUMBER
  MOV P0, #11111110b
  MOV B, #0Ah
  DIV AB
  ; Wert von B auf mittlere 7-Segment Anzeige
  MOV P0, #11111111b
  CALL SHOW_NUMBER
  MOV P0, #11111101b
  MOV B, A
  ; Wert von B auf linke 7-Segment Anzeige
  MOV P0, #11111111b
  CALL SHOW_NUMBER
  MOV P0, #11111011b
  RET

SHOW_NUMBER:
  ; B auflösen auf Port 1
  XCH A, B
  MOV DPTR, #table
  MOVC A,@A+DPTR
  MOV P1, A
  XCH A, B
  RET
;-----------------------------------------------
; TABLE: Datenbank der 7-Segment-Darstellung
;-----------------------------------------------
org 300h
table:
db 11000000b
db 11111001b, 10100100b, 10110000b
db 10011001b, 10010010b, 10000010b
db 11111000b, 10000000b, 10010000b

end
