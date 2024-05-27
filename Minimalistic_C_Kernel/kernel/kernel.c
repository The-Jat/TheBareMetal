void k_main() {
    char* video_memory = (char*)0xb8000;  // Declare a pointer to the VGA text mode memory address

    // Define the character and attribute bytes
    char character = 'J';
    char attribute = 0x0a;  // This attribute byte represents white text on a black background

    // Combine the character and attribute bytes and write to memory
    *video_memory = character;
    *(video_memory + 1) = attribute;  // The attribute byte follows the character byte in memory
}
