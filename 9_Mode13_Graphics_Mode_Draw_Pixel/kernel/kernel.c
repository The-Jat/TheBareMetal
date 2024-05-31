
#include "vga.h"


void kmain(void)
{
console_init();
  char* video = (char*)0xb8000;
  video[0] = 'J';
  video[1] = 0x0a;
  
	//kprintf("HIIII");
//vga_buffer_write_char('M', 5, 5, 0x0F);

  // halt the cpu
  while(1);
}
