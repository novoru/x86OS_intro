draw_font:
        ;----------------------------------
        ; スタックフレームの構築
        ;----------------------------------
												; EBP+12| Y（行）
												; EBP+ 8| X（列）
												; ---------------
        push    ebp								; EBP+ 4| EIP（戻り番地）
        mov     ebp, esp						; EBP+ 0| EBP（元の値）
												; ---------------

        ;----------------------------------
        ; レジスタの保存
        ;----------------------------------
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        ;----------------------------------
        ; 表示位置
        ;----------------------------------
        mov     esi, [ebp + 8]					; ESI = X（列）
        mov     edi, [ebp +12]					; EDI = Y（行）

        ;----------------------------------
        ; フォント一覧を表示
        ;----------------------------------
        mov     ecx, 0							; for (ECX = 0;
.10L:   cmp     ecx, 256						;      ECX < 256;
        jae     .10E                            ;
												;      ECX++)
												; {
												;   // 桁位置の計算
        mov     eax, ecx						;   EAX  = ECX;
        and     eax, 0x0F						;   EAX &= 0x0F
        add     eax, esi						;   EAX += X;
                                                ;
												;   // 行位置の計算
        mov     ebx, ecx						;   EBX  = ECX;
        shr     ebx, 4							;   EBX /= 16
        add     ebx, edi						;   EBX += Y;

        cdecl   draw_char, eax, ebx, 0x07, ecx	;   draw_char();

        inc     ecx								;   // for (... ECX++)
        jmp     .10L                            ;
.10E:                                           ; }



        ;----------------------------------
        ; レジスタの復帰
        ;----------------------------------
        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ;----------------------------------
        ; スタックフレームの破棄
        ;----------------------------------
        mov     esp, ebp
        pop     ebp

        ret