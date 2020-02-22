    BOOT_LOAD       equ     0x7C00
    BOOT_END        equ     (BOOT_LOAD + BOOT_SIZE)

    BOOT_SIZE       equ     (1024 * 8)
    SECT_SIZE       equ     (512)
    BOOT_SECT       equ     (BOOT_SIZE / SECT_SIZE)

    E820_RECORD_SIZE    equ     20

    KERNEL_LOAD     equ     0x0010_1000
    KERNEL_SIZE     equ     (1024 * 8)      ; カーネルサイズ
    KERNEL_SECT     equ     (KERNEL_SIZE / SECT_SIZE)

    VECT_BASE       equ     0x0010_0000     ; 0010_0000:0010_07FF