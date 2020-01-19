#include "kernel.h"



void kernel()
{
  setup_idt(0x21, (int)int_21, 0x10, 0x8e);
  init_pic();
  io_sti();
  
  fill_vga(15);
  //strip();
  //square(0, 0, 319, 119, 10);

  io_out8(PIC0_IMR, 0xf9);
  io_out8(PIC1_IMR, 0xef);

  //putfont8(0, 0, 65, 0x00);

  for(;;) {
    halt();
  }
}

void fill_vga(int color)
{
  char *vga = VGA_ADDR;
  for(int i = 0; i < 0xffff; i++)
    vga[i] = color;
}

void draw(int x, int y, int color)
{
  char *vga = VGA_ADDR;
  if(x >= 320 || x < 0 || y >= 200 || y < 0) return;
  vga[x + y * 320] = color;
}

void square(int left, int top, int right, int bottom, int color)
{
  for(int x = left; x <= right; x++) {
    for(int y = top; y <= bottom; y++) {
      draw(x,y,color);
    }
  }
}

void strip()
{
  for(int y = 0; y < 200; y++)
    square(0, y, 319, y, y);
}

void putfont8(int x, int y, unsigned char code, int color)
{
  char *font8 = FONT_ADDR;
  int i = 0, j = 0;
  for(j = 0; j < 16; j++) {
    unsigned char row = font8[code * 16 + j];
    unsigned char mask = 0x80;
    for(i = 0; i < 8; i++) {
      //check if reach the end of a row
      if((row & mask) != 0) draw((x+i), (y+j), color);
      mask = mask / 2;
    }
  }
}

void clr(int color)
{
  char *vga = VGA_ADDR;
  for(int i = 0; i < 64000; i++)
    *(vga+i) = (char)color;
}

void init_pic(void)
{
  io_out8(PIC0_IMR,  0xff  ); 
  io_out8(PIC1_IMR,  0xff  ); 
  
  io_out8(PIC0_ICW1, 0x11  ); 
  io_out8(PIC0_ICW2, 0x20  ); 
  io_out8(PIC0_ICW3, 1 << 2); 
  io_out8(PIC0_ICW4, 0x01  );
  
  io_out8(PIC1_ICW1, 0x11  ); 
  io_out8(PIC1_ICW2, 0x28  ); 
  io_out8(PIC1_ICW3, 2     ); 
  io_out8(PIC1_ICW4, 0x01  ); 
  
  io_out8(PIC0_IMR,  0xfb  ); 
  io_out8(PIC1_IMR,  0xff  ); 
  
  return;
}

void setup_idt(int gate_num, int handler, int selector, int attribute)
{
  IDT_DESC * idt_addr = (IDT_DESC *)IDT_ADDR + gate_num;
  idt_addr->offset_low = handler & 0xffff;
  idt_addr->selector = selector;
  idt_addr->offset_high = (handler >> 16) & 0xffff;
  idt_addr->attribute = attribute & 0xffff;
  idt_addr->zero = 0x00;
}


void int21(int *esp)
{
  io_out8(PIC0_OCW2, 0x61);
  unsigned char data = io_in8(PORT_KEYDAT);
  clr(15);
  putfont8(0,0, data, 0x00);
  return;
}

void int27(int *esp)
{
  io_out8(PIC0_OCW2, 0x67);
  return;
}



