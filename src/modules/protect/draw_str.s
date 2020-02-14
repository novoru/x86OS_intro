draw_str:
        ;---------------------------------
        ; スタックフレームの構築
        ;---------------------------------
                                            ;     +20| 文字列のアドレス
                                            ;     +16| 色
                                            ;     +12| 行
                                            ;     + 8| 列
                                            ; -------+--------------
        push    ebp                         ;     + 4| EIP (戻り番地)
        mov     ebp, esp                    ; EBP + 0| EBP (元の値)

        ;---------------------------------
        ; レジスタの保存
        ;---------------------------------
		push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi

        ;---------------------------------
        ; 文字列の表示
        ;---------------------------------
        mov     ecx, [ebp + 8]              ; ECX = 列;
        mov     edx, [ebp + 12]             ; EDX = 行;
        movzx   ebx, word [ebp + 16]        ; EBX = 表示色;
        mov     esi, [ebp + 20]             ; ESI = 文字列のアドレス;

        cld                                 ; DF = 0;   // アドレス加算
.10L:                                       ; do
                                            ; {
        lodsb                               ;    AL = *ESI++;
        cmp     al, 0                       ;    if(0 == AL)
        je      .10E                        ;      break;

        ;---------------------------------
        ; 1文字表示
        ;---------------------------------
        cdecl   draw_char, ecx, edx, ebx, eax   ;   draw_char();

        ; 次の文字の位置を調整
        inc     ecx                         ;   ECX++;
        cmp     ecx, 80                     ;   if(80 <= ECX)
        jl      .12E                        ;   {
        mov     ecx, 0                      ;      ECX = 0;
        inc     edx                         ;      EDX++;
        cmp     edx, 30                     ;      if(30 <= EDX)
        jl      .12E                        ;      {
        mov     edx, 0                      ;         EDX = 0;
.12E:                                       ;      }
        jmp     .10L                        ;   }
.10E:                                       ; } while(1);
       
        ;---------------------------------
        ; レジスタの復帰
        ;---------------------------------
		pop		esi
		pop		edx
		pop		ecx
		pop		ebx
		pop		eax

        ;---------------------------------
        ; スタックフレームの破棄
        ;---------------------------------
        mov     esp, ebp
        pop     ebp

        ret