#include "stdint.h"

#define VGA_BUFFER_ADDR 0xB8000
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

// Define text mode attributes
#define TEXT_COLOR 0x0F // White text on black background

// Function to write a single character to the VGA text mode buffer
void write_char(char c, size_t row, size_t col, uint8_t color) {
    uint16_t* buffer = (uint16_t*)VGA_BUFFER_ADDR;
    size_t index = (row * VGA_WIDTH + col);
    buffer[index] = (uint16_t)c | ((uint16_t)color << 8);
}

// Function to clear the screen
void clear_screen() {
    for (size_t row = 0; row < VGA_HEIGHT; row++) {
        for (size_t col = 0; col < VGA_WIDTH; col++) {
            write_char(' ', row, col, TEXT_COLOR);
        }
    }
}

// Function to calculate the VGA text mode buffer index from row and column
 size_t vga_buffer_index(size_t row, size_t col) {
    return (row * VGA_WIDTH + col) * 2;
}

void random(int abc){

int a;
int b;
int c;
int d;
int e;
int f;
int g;
unsigned long long h;
unsigned long long i;
unsigned long long j;
}

// Function to clear the screen with a specified background color
void clear(uint8_t background_color) {
    uint16_t* buffer = (uint16_t*)VGA_BUFFER_ADDR;
    uint8_t color = (background_color << 4) | 0x0F; // Combine background color with default text color

    // Fill the screen with spaces with the specified color attribute
    for (size_t row = 0; row < VGA_HEIGHT; row++) {
        for (size_t col = 0; col < VGA_WIDTH; col++) {
            size_t index = vga_buffer_index(row, col);
            buffer[index + 1] = color; // Set color attribute
        }
    }
}

// Function to initialize the console
void console_init() {
int abc;
int c;
int d;
int e;
int f;
int g;
unsigned long long h;
unsigned long long i;
unsigned long long j;
    clear_screen();
    //int b;
    // Other initialization steps such as setting cursor position can go here
}
