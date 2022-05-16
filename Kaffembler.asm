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


; Main loop
LOOP:
  ; Tell DS1620 to send current temperature
  CALL SEND
  ; Read data from DS1620
  CALL RECEIVE

  ; Turn on the "Ready" LED if TH is high
  CALL CHECK_READY
  ; Turn on the "Heating" LED if TL is high
  CALL CHECK_COLD

  JMP LOOP



;-----------------------------------------------
; Serial stuff
;-----------------------------------------------

; Tells DS1620 to send current temperature
; Command: AAh = 10101010b
SEND:
  ; Reset Thermometer
  CLR RST
  NOP
  SETB RST

  ; Send data
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


; Sends a "1" bit over the serial port
SEND_1:
  CLR CLK
  SETB DQ
  SETB CLK
  RET

; Sends a "0" bit over the serial port
SEND_0:
  CLR CLK
  CLR DQ
  SETB CLK
  RET


; Reads 9 bits from the serial port
; and shifts them into A
RECEIVE:
  ; Clear A
  MOV A, #00h

  ; Pull DQ high (DS1620 can only pull its data pin low when sending data)
  SETB DQ

  ; Read 9 bits from the serial port
  CALL READ_BIT
  CALL READ_BIT
  CALL READ_BIT
  CALL READ_BIT
  CALL READ_BIT
  CALL READ_BIT
  CALL READ_BIT
  CALL READ_BIT
  CALL READ_BIT

  CALL SHOW

  RET


; Reads a bit from the serial port and shifts it into A
READ_BIT:
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



; Converts the number stored in A to the corresponding bits
; needed to display the number on the 7 segment display and
; writes them into R2-R4
SHOW:
  MOV B, #0Ah
  DIV AB

  ; write 1-digit in R2
  MOV P0, #11111111b
  CALL SHOW_NUMBER
  MOV R2, B
  MOV P0, #11111110b

  MOV B, #0Ah
  DIV AB

  ; write 10-digit in R3
  MOV P0, #11111111b
  CALL SHOW_NUMBER
  MOV R3, B
  MOV P0, #11111101b

  MOV B, A

  ; write 100-digit in R4
  MOV P0, #11111111b
  CALL SHOW_NUMBER
  MOV R4, B
  MOV P0, #11111011b

  RET


; takes a value 0-9 from B, converts it to the bits needed to display
; the number on the 7 segment display and writes them to P1
SHOW_NUMBER:
  XCH A, B

  ; convert number to corresponding bits
  MOV DPTR, #TABLE
  MOVC A, @A+DPTR

  ; write bits to port 1
  MOV P1, A

  XCH A, B
  
  RET


; Refreshes the 7 segment display
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



;-----------------------------------------------
; Status-LEDs
;-----------------------------------------------

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