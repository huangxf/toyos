; hello-os
; TAB=4
bits 16
	jmp		entry
msg:	
	DB		0x0a, 0x0a	
	DB		"hello, world"
	DB		0x0a		
	DB		0
read_err:
	DB		0x0a, 0x0a	
	DB		"Error load from disk"
	DB		0x0a		
	DB		0	
welcome:
	DB		0X0d, 0x0a
	DB		"Welcome to system"
	DB		0x0a
	DB		0
entry:	
	MOV		AX,0x07c0
	MOV 		BX,0x0000
	MOV		DS,AX
	MOV		SI,msg
	CALL		putloop
	MOV		SI,welcome
	CALL		putloop
load_head:
	MOV		AX, 0x0820
	MOV		ES, AX  ;data will be read into 0x0820
	MOV		DH, 0	;header 0
	MOV		CH, 0	;cylinder 0
	MOV		CL, 2	;sector 2, And sector 1 is boot sector
retry:	
	MOV		AH, 2   ;read from floppy, AH = 2
	MOV		AL, 1   ;read 1 section
	MOV		DL, 0   ;read floppy a
	MOV		BX, 0   ;ES:BX is data buffer
	INT		0x13	;read from floppy
	JNC		next
	MOV		SI, read_err
	CALL		putloop
	MOV		AH, 0x00 ;reset floppy
	MOV		DL, 0	 ;disk A
	INT		0x13	 ;reset
	JMP		retry    ;retry until successful
next:
	MOV		AX, ES
	ADD		AX, 0x20 
	MOV		ES, AX	;ES = ES + 512, read next section
	ADD		CL, 1
	CMP		CL, 16   ;read 16 sections in all
	JBE		retry
	
jump:	
	MOV		AX, 0x0820
	MOV 		ES, AX
	MOV		DS, AX
	JMP		0x0000:0x8200

fin:	
	HLT					
	JMP		fin

putloop:	
	MOV		AL,[SI]
	ADD		SI,1			
	CMP		AL,0
	JE		success
	MOV		AH,0x0e		
	MOV		BX,0x00		
	INT		0x10			
	JMP		putloop
success:
	RET
	
	RESB		510-($ - $$)	;$ indicates this line, $$ indicates this section (this program only has .text section)
	
signature:
	DB		0x55, 0xaa
