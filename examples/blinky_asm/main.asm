; LED blink for Arduino Leonardo

.ORG 0x0000
RJMP main        ; Reset vector

.ORG 0x0056
main:
	; Set stack pointer to point at the end of RAM.
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
	SBI DDRC, 7

loop:
	SBI PORTC, 7
	RCALL delay
	CBI PORTC, 7
	RCALL delay
	RJMP loop

; Simple software delay
delay:
	LDI R24, 255
	RCALL delay_ms
	LDI R24, 255
	RCALL delay_ms
	LDI R24, 255
	RCALL delay_ms
	LDI R24, 255
	RCALL delay_ms
	RET

delay_micros: 
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DEC R24
	CPI R24, 0			; more loops to do?
	BRNE delay_micros	;	continue!
	RET

delay_ms:
	MOV R18, R24
loop_dms:
	LDI R24, 250
	RCALL delay_micros
	LDI R24, 250
	RCALL delay_micros
	LDI R24, 250
	RCALL delay_micros
	LDI R24, 250
	RCALL delay_micros
	DEC R18
	CPI R18, 0			; more loops to do?
	BRNE loop_dms		;	continue!
	RET
