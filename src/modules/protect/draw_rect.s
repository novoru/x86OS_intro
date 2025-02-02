draw_rect:
        ;---------------------------------------
        ; スタックフレームの構築
        ;---------------------------------------
												; ------|--------
												; EBP+24| 色
												; EBP+20| Y1
												; EBP+16| X1
												; EBP+12| Y0
												; EBP+ 8| X0
												; ---------------
		push	ebp								; EBP+ 4| EIP（戻り番地）
		mov		ebp, esp						; EBP+ 0| EBP（元の値）
												; ------|--------

        ;---------------------------------------
        ; レジスタの保存
        ;---------------------------------------
        push    eax
        push    ebx
        push    ecx
        push    edx
        push    esi

		;---------------------------------------
		; 矩形を描画
		;---------------------------------------
		mov		eax, [ebp + 8]					; EAX = X0;
		mov		ebx, [ebp +12]					; EBX = Y0;
		mov		ecx, [ebp +16]					; ECX = X1;
		mov		edx, [ebp +20]					; EDX = Y1;
		mov		esi, [ebp +24]					; ESI = 色;

		;---------------------------------------
		; 座標軸の大小を確定
		;---------------------------------------
		cmp		eax, ecx						; if (X1 < X0)
		jl		.10E							; {
		xchg	eax, ecx						;   X0とX1を入れ替える;
.10E:											; }

		cmp		ebx, edx						; if (Y1 < Y0)
		jl		.20E							; {
		xchg	ebx, edx						;   Y0とY1を入れ替える;
.20E:											; }

		;---------------------------------------
		; 矩形を描画
		;---------------------------------------
		cdecl	draw_line, eax, ebx, ecx, ebx, esi	; 上線
		cdecl	draw_line, eax, ebx, eax, edx, esi	; 左線

		dec		edx									; EDX--; // 下線は1ドット上げる
		cdecl	draw_line, eax, edx, ecx, edx, esi	; 下線
		inc		edx

		dec		ecx									; ECX--; // 右線は1ドット左に移動
		cdecl	draw_line, ecx, ebx, ecx, edx, esi	; 右線

        ;---------------------------------------
        ; レジスタの復帰
        ;---------------------------------------
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        ;---------------------------------------
        ; スタックフレームの破棄
        ;---------------------------------------
        mov     esp, ebp
        pop     ebp

        ret