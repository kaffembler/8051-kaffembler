; Thermometer aktivieren
;
;             ---- DQ
;             |--- CLK
;             ||-- RST
;             |||
MOV P3, #00000001b

; 
;
MOV P2, #11111111b

LOOP:
  CALL CHECK_HOT
  CALL CHECK_COLD
  
  JMP LOOP

CHECK_HOT:
  MOV A, P0
  ANL A, #00000001b

  CJNE A, #00000000b, HOT_ON
  CJNE A, #00000001b, HOT_OFF

  RET

CHECK_COLD:
  MOV A, P0
  ANL A, #00000010b

  CJNE A, #00000000b, COLD_ON
  CJNE A, #00000010b, COLD_OFF
  
  RET



COLD_ON:
  MOV A, P2
  ANL A, #01111111b
  MOV P2, A
  RET

COLD_OFF:
  MOV A, P2
  ORL A, #10000000b
  MOV P2, A
  RET

HOT_ON:
  MOV A, P2
  ANL A, #10111111b
  MOV P2, A
  RET

HOT_OFF:
  MOV A, P2
  ORL A, #01000000b
  MOV P2, A
  RET