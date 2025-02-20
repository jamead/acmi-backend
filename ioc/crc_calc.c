#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_LINE_LENGTH 256
#define MAX_SETTINGS 100

// CRC-32 Polynomial (0x04C11DB7)
#define CRC32_POLY 0x04C11DB7


// Function to compute CRC32 with 8-bit input
uint32_t crc32_update(uint32_t crc, uint8_t data) {
    crc ^= ((uint32_t)data << 24); // Align data to the highest byte

    for (int i = 0; i < 8; i++) { // Process 8 bits
        if (crc & 0x80000000) {   // Check MSB
            crc = (crc << 1) ^ CRC32_POLY;
        } else {
            crc <<= 1;
        }
    }
    return crc;
}


// Test the CRC32 function
int main() {
    char line[MAX_LINE_LENGTH];
    char name[MAX_LINE_LENGTH];
    int byteoffset, value;
    int values[MAX_SETTINGS];
    unsigned char byteval;
    int count=0;
    int i;

    FILE *file = fopen("crc_test_data.txt", "r");
    if (file == NULL) {
        printf("Error opening file\n");
	exit(1);
    }
    printf("what\n");
    uint32_t crc = 0xFFFFFFFF; // Initial value (standard CRC-32 start)

    while (fgets(line, sizeof(line), file)) {
	if (sscanf(line, "%s %d %d", name, &byteoffset, &value) == 3) {
            values[count++] = value; 
        }
    }
    printf("Computing CRC\n"); 
    for (i=0;i<count;i++) {
	printf("Setting Num: %d: Value: %d\n",i,values[i]);
        byteval = (values[i] >> 24) & 0xFF; 
	crc = crc32_update(crc,byteval);
	printf("Byte: %d   CRC32: 0x%08X\n",byteval,crc);
        byteval = (values[i] >> 16) & 0xFF; 
	crc = crc32_update(crc,byteval);
	printf("Byte: %d   CRC32: 0x%08X\n",byteval,crc);
        byteval = (values[i] >> 8) & 0xFF; 
	crc = crc32_update(crc,byteval);
	printf("Byte: %d   CRC32: 0x%08X\n",byteval,crc);
        byteval = (values[i] >> 0 ) & 0xFF; 
	crc = crc32_update(crc,byteval);
	printf("Byte: %d   CRC32: 0x%08X\n\n",byteval,crc);
        
    }

    return 0;
}
