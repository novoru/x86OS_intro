%include "../include/define.s"
%include "../include/macro.s"

        ORG     KERNEL_LOAD

[BITS 32]
;************************************************
;   エントリポイント
;************************************************
kernel:
        ;----------------------------------
        ; フォントアドレスを取得
        ;----------------------------------
        mov     esi, BOOT_LOAD + SECT_SIZE      ; ESI = 0x7C00 + 512;
        movzx   eax, word [esi + 0]             ; EAX = [ESI + 0]; // セグメント
        movzx   ebx, word [esi + 2]             ; EBX = [ESI + 2]; // オフセット
        shl     eax, 4                          ; EAX <<= 4;
        add     eax, ebx                        ; EAX += EBX;
        mov     [FONT_ADR], eax                 ; FONT_ADR[0] = EAX;
        
        ;----------------------------------
        ; 文字の表示
        ;----------------------------------
        cdecl   draw_char, 0, 0, 0x010F, 'A'
        cdecl   draw_char, 1, 0, 0x010F, 'B'
        cdecl   draw_char, 2, 0, 0x010F, 'C'

        cdecl   draw_char, 0, 0, 0x0402, '0'
        cdecl   draw_char, 1, 0, 0x0212, '1'
        cdecl   draw_char, 2, 0, 0x0212, '_'

        ;----------------------------------
        ; 処理の終了
        ;----------------------------------
        jmp     $                               ; while(1);     // 無限ループ

ALIGN 4, db 0
FONT_ADR:       dd  0

;************************************************
;   モジュール
;************************************************
%include  "../modules/protect/vga.s"
%include  "../modules/protect/draw_char.s"

;************************************************
;   パディング
;************************************************
        times   KERNEL_SIZE - ($ - $$)      db  0x00