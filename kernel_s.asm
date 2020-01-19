BITS 32
	
[section .text]
	
GLOBAL halt, int_21, io_cli, io_sti, io_out8, io_in8
EXTERN int21, int27

halt:
	HLT
	JMP halt	
;;io_out8 must not be placed at the end of source file, otherwise
;;it will be assemled into a weird machine code. Don't know why.
io_out8:
	MOV		EDX,[ESP+4]		; port
	MOV		EAX ,[ESP+8]		; data
	OUT		DX,AL
	RET
io_in8:
	MOV		EDX,[ESP+4] 		;port
	MOV		EAX, 0
	IN		AL, DX
	RET
io_cli:
	CLI
	RET
io_sti:
	STI
	RET
int_21:
	PUSH	ES
	PUSH	DS
	PUSHAD
	MOV	EAX,ESP
	PUSH	EAX
	MOV	AX,SS
	MOV	DS,AX
	MOV	ES,AX
	CALL	int21
	POP	EAX
	POPAD
	POP	DS
	POP	ES
	IRETD
int_27:
	PUSH	ES
	PUSH	DS
	PUSHAD
	MOV	EAX,ESP
	PUSH	EAX
	MOV	AX,SS
	MOV	DS,AX
	MOV	ES,AX
	CALL	int27
	POP	EAX
	POPAD
	POP	DS
	POP	ES
	IRETD
