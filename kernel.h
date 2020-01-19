#define PIC0_ICW1		0x0020
#define PIC0_OCW2		0x0020
#define PIC0_IMR		0x0021
#define PIC0_ICW2		0x0021
#define PIC0_ICW3		0x0021
#define PIC0_ICW4		0x0021
#define PIC1_ICW1		0x00a0
#define PIC1_OCW2		0x00a0
#define PIC1_IMR		0x00a1
#define PIC1_ICW2		0x00a1
#define PIC1_ICW3		0x00a1
#define PIC1_ICW4		0x00a1

#define PORT_KEYDAT             0X0060

#define VGA_ADDR  0xa0000
#define FONT_ADDR 0x00008600
#define TEMP_ADDR 0x0000a000
#define IDT_ADDR  0x00000000

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;


typedef struct {
  uint16 offset_low;
  uint16 selector;
  uint8  zero;
  uint8  attribute;
  uint16 offset_high;
} IDT_DESC;


void kernel();
void fill_vga(int);
void draw(int x, int y, int color);
void square(int, int, int, int, int);
void strip();
void putfont8(int x, int y, unsigned char code, int color);
void clr(int color);
void setup_idt(int gate_num, int handler, int selector, int attribute);
void init_pic(void);
void int21();
void int27();

extern halt();
extern int_21();
extern io_cli();
extern io_sti();
extern io_out8(int port, int data);
extern io_in8(int port);

