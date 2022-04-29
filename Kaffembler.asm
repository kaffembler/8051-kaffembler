; Thermometer aktivieren
;
;             ---- DQ
;             |--- CLK
;             ||-- RST
;             |||
MOV P3, #00000001b

; LEDs ausschalten
MOV P2, #11111111b

LOOP:
  CALL CHECK_READY
  CALL CHECK_COLD
  
  JMP LOOP

CHECK_HOT:
  MOV A, P0
  ANL A, #00000001b

  CJNE A, #00000000b, READY_ON
  CJNE A, #00000001b, READY_OFF

  RET

CHECK_COLD:
  MOV A, P0
  ANL A, #00000010b

  CJNE A, #00000000b, COLD_ON
  CJNE A, #00000010b, COLD_OFF
  
  RET



COLD_ON:
  ANL P2, #01111111b

  RET

COLD_OFF:
  ORL P2, #10000000b

  RET

READY_ON:
  ANL P2, #10111111b

  RET

READY_OFF:
  ORL P2, #01000000b
  
  RET