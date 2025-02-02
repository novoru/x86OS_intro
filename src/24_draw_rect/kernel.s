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
        
        ;---------------------------------------
        ; フォントの一覧表示
        ;---------------------------------------
        cdecl   draw_font, 63, 13               ; // フォントの一覧表示
        cdecl   draw_color_bar, 63, 4           ; // カラーバーの表示

        cdecl   draw_str, 25, 14, 0x010F, .s0

        cdecl   draw_rect, 100, 100, 200, 200, 0x03
        cdecl   draw_rect, 400, 250, 150, 150, 0x05
        cdecl   draw_rect, 350, 400, 300, 100, 0x06

        ;----------------------------------
        ; 処理の終了
        ;----------------------------------
        jmp     $                               ; while(1);     // 無限ループ

.s0:    db  " Hello, kernel!", 0

ALIGN 4, db 0
FONT_ADR:       dd  0

;************************************************
;   モジュール
;************************************************
%include  "../modules/protect/vga.s"
%include  "../modules/protect/draw_char.s"
%include  "../modules/protect/draw_font.s"
%include  "../modules/protect/draw_str.s"
%include  "../modules/protect/draw_color_bar.s"
%include  "../modules/protect/draw_pixel.s"
%include  "../modules/protect/draw_line.s"
%include  "../modules/protect/draw_rect.s"

;************************************************
;   パディング
;************************************************
        times   KERNEL_SIZE - ($ - $$)      db  0x00