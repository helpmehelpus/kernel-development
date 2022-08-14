[BITS 32]

global _start
extern kernel_main

CODE_SEQ equ 0x08
DATA_SEG equ 0x10

_start:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; Enable the A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Remap the master PIC
    mov al, 00010001b ; put PIC in init mode
    out 0x20, al ; Tell master PIC

    mov al, 0x20 ; Interrupt 0x20 is where master ISR should start
    out 0x21, al

    mov al, 00000001b
    out 0x21, al
    ; End remap master PIC

    ; Enable the interrupts. When the PIC generates interrupts, the processor will ignore them unless we enable them
    sti ; If run into problems, go to enable create interrupts function lecture

    call kernel_main

    jmp $

times 512-($ - $$) db 0