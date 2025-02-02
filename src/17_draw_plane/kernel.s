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
        ; 8ビットの横線
        ;----------------------------------
        mov     ah, 0x07                        ; AH = 書き込みプレーンを指定(Bit:----IRGB)
        mov     al, 0x02                        ; AL = マップマスクレジスタ(書き込みプレーンを指定)
        mov     dx, 0x03C4                      ; DX = シーケンサ制御ポート
        out     dx, ax                          ; // ポート出力  

        mov     [0x000A_0000 + 0], byte 0xFF

        mov     ah, 0x04                        ; AH = 書き込みプレーンを指定(Bit:----IRGB)
        out     dx, ax                          ; // ポート出力

        mov     [0x000A_0000 + 1], byte 0xFF    ; 8ドットの横線

        mov     ah, 0x02                        ; AH = 書き込みプレーンを指定(Bit:----IRGB)
        out     dx, ax                          ; // ポート出力

        mov     [0x000A_0000 + 2], byte 0xFF    ; 8ドットの横線

        mov     ah, 0x01                        ; AH = 書き込みプレーンを指定(Bit:----IRGB)
        out     dx, ax                          ; // ポート出力

        mov     [0x000A_0000 + 3], byte 0xFF    ; 8ドットの横線

        ;----------------------------------
        ; 画面を横切る横線
        ;----------------------------------
        mov     ah, 0x02                        ; AH = 書き込みプレーンを指定(Bit:----IRGB)
        out     dx, ax                          ; // ポート出力

        lea     edi, [0x000A_0000 + 80]         ; EDI = VRAMアドレス
        mov     ecx, 80                         ; ECX = 繰り返し回数
        mov     al, 0xFF                        ; AL = ビットパターン
        rep stosb                               ; *EDI++ = AL;

        ;----------------------------------
        ; 2行目に8ドットの矩形
        ;----------------------------------
        mov     edi, 1                          ; EDI = 行数

        shl     edi, 8                          ; EDI *= 256;
        lea     edi, [edi * 4 + edi + 0xA_0000] ; EDI = VRAMアドレス;

        mov     [edi + (80 * 0)], word 0xFF
        mov     [edi + (80 * 1)], word 0xFF
        mov     [edi + (80 * 2)], word 0xFF
        mov     [edi + (80 * 3)], word 0xFF
        mov     [edi + (80 * 4)], word 0xFF
        mov     [edi + (80 * 5)], word 0xFF
        mov     [edi + (80 * 6)], word 0xFF
        mov     [edi + (80 * 7)], word 0xFF

        ;----------------------------------
        ; 3行目に文字を描画
        ;----------------------------------
        mov     esi, 'A'                        ; ESI = 文字コード
        shl     esi, 4                          ; ESI *= 16;
        add     esi, [FONT_ADR]                 ; ESI = FONT_ADR[文字コード];

        mov     edi, 2                          ; EDI = 行数;
        shl     edi, 8                          ; EDI *= 256;
        lea     edi, [edi * 4 + edi + 0xA_0000] ; EDI = VRAMアドレス

        mov     ecx, 16                         ; ECX = 16;
.10L:                                           ; do
                                                ; {
        movsb                                   ;    *EDI++ = *ESI++;
        add     edi, 80 - 1                     ;    EDI += 79; // 1ドット分
        loop    .10L                            ; } while(--ECX);

        ;----------------------------------
        ; 処理の終了
        ;----------------------------------
        jmp     $                               ; while(1);     // 無限ループ

ALIGN 4, db 0
FONT_ADR:       dd  0

;************************************************
;   パディング
;************************************************
        times   KERNEL_SIZE - ($ - $$)      db  0x00