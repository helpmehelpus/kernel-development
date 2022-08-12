ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start: ; deal with BIOS parameter block
    jmp short start
    nop

 times 33 db 0

start:
    jmp 0:step2 ; replace cs with 0x7c0

step2:
    cli ; clear interrupts, set segment registers properly
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; enables interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32

; GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:   ; CS SHOULD POINT TO THIS
    dw 0xffff ; segment limit bits 0 to 15
    dw 0      ; base 0-15 bits
    db 0      ; base 16-23 bits
    db 0x9a   ; access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0       ; 24-31 bits

; offset 0x10
gdt_data:       ; DS, SS, ES, FS, GS
    dw 0xffff ; segment limit bits 0 to 15
    dw 0      ; base 0-15 bits
    db 0      ; base 16-23 bits
    db 0x92   ; access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0       ; 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start

[BITS 32]
load32:
    mov eax, 1 ; starting sector to load from. 0 is the boot sector
    mov ecx, 100 ; total number of sectors
    mov edi, 0x0100000 ; load address to load into
    call ata_lba_read
    jmp CODE_SEG:0x0100000

; ata driver
ata_lba_read:
    mov ebx, eax, ; backup the LBA
    ; send highest 8 bits of the lba to the hard disk controller
    shr eax, 24
    or eax, 0xE0 ; select master drive
    mov dx, 0x1F6 ; port that it expects us to write to
    out dx, al
    ; Finished sending the highes 8 bits of the lba

    ; send total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; Finished sending total sectors

    ; send more bits of the LBA
    mov eax, ebx ; Restore the backup LBA
    mov dx, 0x1F3
    out dx, al
    ; finished sending more bits of the LBA

    ; send more bits of LBA
    mov dx, 0x1F4
    mov eax, ebx ; Restor backup LBA - safety measure
    shr eax, 8
    out dx, al
    ; finished sending more bits

    ; send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx ; Restore backup LBA
    shr eax, 16
    out dx, al
    ; finished senging upper 16 bits of LBA

    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

    ; read all esctors into memory
.next_sector:
    push ecx

; Check if we need to read
.try_again:
    mov dx, 0x1F7
    in al, dx
    test al, 8
    jz .try_again

; We need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ; end of reading sectors into memory
    ret

times 510-($ - $$) db 0
dw 0xAA55
