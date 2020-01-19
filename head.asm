BITS 16

LEDS	EQU		0x0ff1
VMODE	EQU		0x0ff2
SCRNX	EQU		0x0ff4
SCRNY	EQU		0x0ff6
VRAM	EQU		0x0ff8
	
	MOV		AX, 0x0820
	MOV		ES, AX
	MOV		DS, AX
	MOV		BX, 0

	MOV		AL,0x13	
	MOV		AH,0x00
	INT		0x10
	MOV		BYTE [VMODE],8	
	MOV		WORD [SCRNX],320
	MOV		WORD [SCRNY],200
	MOV		DWORD [VRAM],0x000a0000

	MOV		AH,0x02
	INT		0x16 
	MOV		[LEDS],AL

	
	MOV		AL,0xff
	OUT		0x21,AL
	NOP
	OUT		0xa1,AL

	;; enable A20 sequence
	CLI			;stop all possiable interruption

	;; check keyboard	
	CALL	waitkbdout
	MOV		AL,0xd1
	OUT		0x64,AL
	CALL	waitkbdout
		

	IN		AL, 0x92
	OR		AL, 0x02
	OUT		0x92, AL  	; enable A20

	;; SETUP GDT
	LGDT		[GDTR0]
	;; SETUP IDT, CLEAR 2048 BYTES DATA FROM 0x0000
	MOV	AX, 0X0000
	MOV 	ES, AX
	MOV 	DI, 0
	MOV	CX, 2048
	REP	STOSB
	LIDT		[IDTR0]
	
	MOV		EAX,CR0
	AND		EAX,0x7fffffff	
	OR		EAX,0x00000001
	MOV		CR0,EAX	;enable protect mode


	;; Setup segment value.
	;; 0x08 is segment selector for data segment -> DS
	;; 0x10 is segment selector for code segment -> CS (through JMP FAR operate)
	;; if 0x10 is assigned to DS, the memory where DS pointing to
	;; will be considered as code. Exception will be raised
	;; when you try to write data into code memory. Because code
	;; segment won't allow you to write data by MOV.

	;;set all segment registers to 0x08 (selector 0x08), which is a data segment in GDT	
	MOV		AX, 0x08
	MOV		DS, AX
	MOV		ES, AX
	MOV		FS, AX
	MOV		GS, AX
	MOV		SS, AX
	

	JMP		DWORD 0x10:0000	;0x10 is the selector number in GDT


GDT0:
	;; descriptor 1(selector 0x00): null descriptor
	DW		0x0000,0x0000,0x0000,0x0000
	
	;; descriptor 2(selector 0x08): 32 bits data segment
	DW		0xffff
	DW		0x0000
	DW		0x9200 	;This word makes this descriptor as data segment
	DW		0x00cf

	;; discriptor 3(selector 0x10): 32 bits code segment
	DW		0xffff
 	DW	        0x8400  ;lower 16 bits of base address of segment.

				;The base address value is same as segment address in 16-bit mode  
	DW		0x9a00  ;This word makes this descriptor as code segment
	DW		0x0047

	
GDTR0:
	;; GDTR0 is for GDTR register (48 bits in all)
	;; lower 16 bits indicates size of GDT
	;; highter 32 bits indicates entry address (base address) of GDT
	
	;size of gdt table (16 bits)
	DW		8*3-1
	;; base address of gdt table (32 bits)
	DW		0x8200 + GDT0 
	DW		0x0000  ;fill 32 bits



waitkbdout:
	IN		 AL,0x64
	AND		 AL,0x02
	JNZ		 waitkbdout
	RET

BITS 32
hlt:
	HLT
	JMP hlt

IDTR0:	
	;; size of idt (16 bits)
	DW	2048 - 1
	;; Address of idt list (here is 0x00000000)
	DW	0X0000
	DW	0X0000

