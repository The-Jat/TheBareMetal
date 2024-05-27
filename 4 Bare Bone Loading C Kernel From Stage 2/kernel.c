//extern kmain();
void kmain(void) {
    char *video_memory = (char *)0xB8000;
   *video_memory = 'j';
    *(video_memory + 1) = 0x0a;  // Light grey on black background

    // Infinite loop to prevent exiting
//return;
    while (1) {}
}
