ORG 00h

; Ports
LED  	 EQU P2
TEMP 	 EQU P3


; LEDs
LED_HEAT EQU LED.7
LED_RDY  EQU LED.6

; Temp Serial
RST 	 EQU TEMP.0
CLK 	 EQU TEMP.1
DQ  	 EQU TEMP.2

; Temp Trigger
TC  	 EQU TEMP.3
TL  	 EQU TEMP.4
TH  	 EQU TEMP.5


SETB CLK

LOOP:
  CALL SEND
  CALL RECEIVE
  CALL CHECK_READY
  CALL CHECK_COLD
  JMP LOOP

; Request Temperature (AAh = 10101010b)
SEND:
  ; Reset Thermometer
  CLR RST
  NOP
  SETB RST

  ; Send data to DS1620
  CALL SEND_0
  CALL SEND_1
  CALL SEND_0
  CALL SEND_1
  CALL SEND_0
  CALL SEND_1
  CALL SEND_0
  CALL SEND_1

  ; Refresh temperature display
  CALL REFRESH

  RET

RECEIVE:
  ; Clear A
  MOV A, #00h

  ; Pull DQ high
  SETB DQ

  ; Pulse clock
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
  MOV R2, B
  MOV P0, #11111110b

  MOV B, #0Ah
  DIV AB
  ; Wert von B auf mittlere 7-Segment Anzeige
  MOV P0, #11111111b
  CALL SHOW_NUMBER
  MOV R3, B
  MOV P0, #11111101b

  MOV B, A
  ; Wert von B auf linke 7-Segment Anzeige
  MOV P0, #11111111b
  CALL SHOW_NUMBER
  MOV R4, B
  MOV P0, #11111011b

  RET

SHOW_NUMBER:
  ; B auflösen auf Port 1
  XCH A, B
  MOV DPTR, #TABLE
  MOVC A, @A+DPTR
  MOV P1, A
  XCH A, B
  RET

REFRESH:
  ; Wert von B auf rechte 7-Segment Anzeige
  MOV P0, #11111111b
  MOV P1, R2
  MOV P0, #11111110b

  ; Wert von B auf mittlere 7-Segment Anzeige
  MOV P0, #11111111b
  MOV P1, R3
  MOV P0, #11111101b

  ; Wert von B auf linke 7-Segment Anzeige
  MOV P0, #11111111b
  MOV P1, R4
  MOV P0, #11111011b

  RET

CHECK_READY:
  MOV A, P3
  ANL A, #00100000b

  CJNE A, #00000000b, READY_ON
  RET

CHECK_COLD:
  MOV A, P3
  ANL A, #00010000b

  CJNE A, #00000000b, COLD_ON
  RET

COLD_ON:
  CLR  LED_HEAT
  SETB LED_RDY
  RET

READY_ON:
  CLR  LED_RDY
  SETB LED_HEAT
  RET


;-----------------------------------------------
; TABLE: Datenbank der 7-Segment-Darstellung
;-----------------------------------------------
ORG 300h

TABLE:
DB 11000000b
DB 11111001b, 10100100b, 10110000b
DB 10011001b, 10010010b, 10000010b
DB 11111000b, 10000000b, 10010000b

END