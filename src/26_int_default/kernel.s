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

        push    0x11223344
        pushf
        call    0x0008:int_default

        ;----------------------------------
        ; 処理の終了
        ;----------------------------------
        jmp     $                               ; while(1);     // 無限ループ

.s0:    db  " Hello, kernel! ", 0

ALIGN 4, db 0
FONT_ADR:       dd  0
RTC_TIME:       dd  0

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
%include  "../modules/protect/itoa.s"
%include  "../modules/protect/rtc.s"
%include  "../modules/protect/draw_time.s"
%include  "modules/interrupt.s"

;************************************************
;   パディング
;************************************************
        times   KERNEL_SIZE - ($ - $$)      db  0x00