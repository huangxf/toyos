#include <stdlib.h>
#include <stdio.h>

void convert(char * src, char * target)
{
  FILE *fp_s = fopen(src, "rb");
  if(!fp_s) {
    printf("%s open failed.\n", src);
    return;
  }
  
  FILE *fp_t = fopen(target, "wb");
  if(!fp_t) {
    printf("%s open failed.\n", target);
    return;
  }

  char ch;
  int count = 1;
  while(ch != EOF) {
      unsigned char font_char = 0x00;
      unsigned char mask_char = 0x80;
      for(int i = 0; i < 8; i++) {
	
	do {
	  ch = fgetc(fp_s);
	  if(ch == EOF) break;
	} while(ch != '.' && ch != '*');
	
	if(ch == EOF) break;
	if(ch == '*') font_char |= mask_char;
	mask_char /= 2;
      }
      if(ch != EOF) {
	fputc(font_char, fp_t);
	printf("0x%02x  ", font_char);
	if(count++ % 16 == 0) {printf("\n"); count = 1;}
      }
  }

  if(fp_s) fclose(fp_s);
  if(fp_t) fclose(fp_t);
}

int main(int argc, char ** argv)
{
  if(argc <= 2) puts("Usage: font src target \n");
  else
    convert(argv[1], argv[2]);
  return 0;
}
