;************************************************
;   マクロ
;************************************************
%include    "../include/define.s"
%include    "../include/macro.s"

    ORG     BOOT_LOAD                   ; ロードアドレスをアセンブラに指示

;************************************************
;   エントリポイント
;************************************************
entry:
        jmp ipl                             ; IPLへジャンプ

        ;----------------------------------
        ;  BPB(BIOS Parameter Block)
        ;----------------------------------
        times   90 - ($ - $$) db 0x90       ;

        ;----------------------------------
        ;  IPL(Intial Program Loader)
        ;----------------------------------
ipl:
        cli                                 ; // 割り込み禁止

        mov     ax, 0x0000                  ; AX = 0x0000;
        mov     ds, ax                      ; DS = 0x0000;
        mov     es, ax                      ; ES = 0x0000;
        mov     ss, ax                      ; SS = 0x0000;
        mov     sp, BOOT_LOAD               ; SP = 0x7C00;

        sti                                 ; // 割り込み許可

        mov     [BOOT + drive.no], dl       ; ブートドライブを保持

        ;----------------------------------
        ;  文字列を表示
        ;----------------------------------
        cdecl   puts, .s0                   ; puts(.s0)

        ;----------------------------------
        ;  残りのセクタをすべて読み込む
        ;----------------------------------
        mov     bx, BOOT_SECT - 1           ; BX = 残りのブートセクタ数;
        mov     cx, BOOT_LOAD + SECT_SIZE   ; CX = 次のロードアドレス;

        cdecl   read_chs, BOOT, bx, cx      ; AX = read_chr(.chs, bx, cx);

        cmp     ax, bx                      ; if(AX != 残りのセクタ数)
.10Q:   jnc     .10E                        ; {
.10T:   cdecl   puts, .e0                   ;    puts(.e0);
        call    reboot                      ;    reboot();      // 再起動
.10E:                                       ; }

        ;----------------------------------
        ;  次のステージへ以降
        ;----------------------------------
        jmp     stage_2

        ;----------------------------------
        ;  データ
        ;----------------------------------
.s0     db  "Booting...", 0x0A, 0x0D, 0
.e0     db  "Error:sector read", 0

;************************************************
;   ブートドライブに関する情報
;************************************************
ALIGN 2, db 0
BOOT:                                           ; ブートドライブに関する情報
        istruc  drive
            at  drive.no,       dw 0            ; ドライブ番号
            at  drive.cyln,     dw 0            ; C: シリンダ
            at  drive.head,     dw 0            ; H: ヘッド
            at  drive.sect,     dw 2            ; S: セクタ
        iend

;************************************************
;   モジュール
;************************************************
%include "../modules/real/puts.s"
%include "../modules/real/reboot.s"
%include "../modules/real/read_chs.s"

;************************************************
;   ブートフラグ(先頭512バイトの終了)
;************************************************
    times   510 - ($ - $$) db 0x00
    db  0x55, 0xAA

;************************************************
;   モジュール(先頭512バイト以降に配置)
;************************************************
%include "../modules/real/itoa.s"
%include "../modules/real/get_drive_param.s"

;************************************************
;   ブート処理の第2ステージ
;************************************************
stage_2:
        ;----------------------------------
        ;  文字列を表示
        ;----------------------------------
        cdecl   puts, .s0                       ; puts(.s0);
        
        ;----------------------------------
        ;  ドライブ情報を取得
        ;----------------------------------
        cdecl   get_drive_param, BOOT           ; get_drive_param(DX, BOOT.CYLN);
        cmp     ax, 0                           ; if(0 == AX)
.10Q:   jne     .10E                            ; {
.10T:   cdecl   puts, .e0                       ;   puts(.e0);
        call    reboot                          ;   reboot();   // 再起動
.10E:                                           ; }
        
        ;----------------------------------
        ;  ドライブ情報を表示
        ;----------------------------------
        mov     ax, [BOOT + drive.no]           ; AX = ブートドライブ;
        cdecl   itoa, ax, .p1, 2, 16, 0b0100    ;
        mov     ax, [BOOT + drive.cyln]         ;
        cdecl   itoa, ax, .p2, 4, 16, 0b0100    ;
        mov     ax, [BOOT + drive.head]         ; AX = ヘッド数;
        cdecl   itoa, ax, .p3, 2, 16, 0b0100    ;
        mov     ax, [BOOT + drive.sect]         ; AX = トラック当たりのセクタ数;
        cdecl   itoa, ax, .p4, 2, 16, 0b0100    ;
        cdecl   puts, .s1

        ;----------------------------------
        ;  処理の終了
        ;----------------------------------
        jmp     $                               ; while(1);     // 無限ループ

        ;----------------------------------
        ;  データ
        ;----------------------------------
.s0     db  "2nd stege...", 0x0A, 0x0D, 0

.s1     db  " Drive:0x"
.p1     db  "  , C:0x"
.p2     db  "    , H:0x"
.p3     db  "  , S:0x"
.p4     db  "  ", 0x0A, 0x0D, 0

.e0     db  "Can't get drive parameter.", 0

;************************************************
;   パディング
;************************************************
        times BOOT_SIZE - ($ - $$)     db  0   ; パディング