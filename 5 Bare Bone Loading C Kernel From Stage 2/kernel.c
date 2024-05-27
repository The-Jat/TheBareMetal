void kmain(void) {
    char *video_memory = (char *)0xB8000;
   *video_memory = 'j';
    *(video_memory + 1) = 0x07;  // Light grey on black background

    // Infinite loop to prevent exiting
    while (1) {}
}
