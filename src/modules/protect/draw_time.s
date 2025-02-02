draw_time:
        ;----------------------------------
        ; スタックフレームの構築
        ;----------------------------------

        push    ebp
        mov     ebp, esp

        ;----------------------------------
        ; レジスタの保存
        ;----------------------------------
        push    eax
        push    ebx

        ;----------------------------------
        ; 時刻の表示
        ;----------------------------------
		mov		eax, [ebp +20]					; EAX = 時刻データ;

        movzx   ebx, al                         ; EBX = 秒;
        cdecl   itoa, ebx, .sec, 2, 16, 0b0100  ; // 文字に変換

        mov     bl, ah                          ; EBX = 分;
        cdecl   itoa, ebx, .min, 2, 16, 0b0100  ; // 文字に変換

        shr     eax, 16                         ; EBX = 時;
        cdecl   itoa, eax, .hour, 2, 16, 0b0100 ; // 文字に変換

                                                ; // 時刻を表示
        cdecl   draw_str,   dword [ebp + 8], dword [ebp + 12], dword [ebp + 16], .hour

        ;----------------------------------
        ; レジスタの復帰
        ;----------------------------------
        pop     ebx
        pop     eax

        ;----------------------------------
        ; スタックフレームの破棄
        ;----------------------------------
        mov     esp, ebp
        pop     ebp

        ret

.hour:  db  "ZZ:"
.min:   db  "ZZ:"
.sec:   db  "ZZ", 0