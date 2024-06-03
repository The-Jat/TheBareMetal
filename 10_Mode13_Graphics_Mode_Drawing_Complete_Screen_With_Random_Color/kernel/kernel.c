
#include "vga.h"


void kmain(void)
{
while(1){}
console_init();
  char* video = (char*)0xA0000;
  video[0] = 4;
  ;video[0] = 'J';
  ;video[1] = 0x0a;
  
	//kprintf("HIIII");
//vga_buffer_write_char('M', 5, 5, 0x0F);

  // halt the cpu
  while(1);
}
