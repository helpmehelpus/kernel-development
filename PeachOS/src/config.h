#ifndef CONFIG_H
#define CONFIG_H

#define KERNEL_CODE_SELECTOR 0x08
#define KERNEL_DATA_SELECTOR 0x10


#define PEACHOS_TOTAL_INTERRUPTS 512

// In real systems, we'd need to determine available system RAM, and act accordingly
#define PEACHOS_HEAP_SIZE_BYTES 104857600 // 100MB
#define PEACHOS_HEAP_BLOCK_SIZE 4096
#define PEACHOS_HEAP_ADDRESS 0x01000000
#define PEACHOS_HEAP_TABLE_ADDRESS 0x00007E00 // There are 480.5 KiB available from 0x00007E00 to 0x0007FFFF

#endif