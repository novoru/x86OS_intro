draw_pixel:
        ;---------------------------------------
        ; スタックフレームの構築
        ;---------------------------------------
												; ------+--------
												; EBP+16| 色
												; EBP+12| Y
												; EBP+ 8| X
												; ------+--------
        push    ebp								; EBP+ 4| EIP（戻り番地）
        mov     ebp, esp						; EBP+ 0| EBP（元の値）
												; ------+--------

        ;---------------------------------------
        ; レジスタの保存
        ;---------------------------------------
        push    eax
        push    ebx
        push    ecx
        push    edi

        ;---------------------------------------
        ;
        ;---------------------------------------
        mov     edi, [ebp + 12]					; EDI  = Y座標
        shl     edi, 4							; EDI *= 16;
        lea     edi, [edi * 4 + edi + 0xA_0000]	; EDI  = 0xA00000[EDI * 4 + EDI];

		;---------------------------------------
		; X座標を1/8して加算
		;---------------------------------------
		mov		ebx, [ebp + 8]					; EBX  = X座標;
		mov		ecx, ebx						; ECX  = X座標;（一時保存）
		shr		ebx, 3							; EBX /= 8;
		add		edi, ebx						; EDI += EBX;

		;---------------------------------------
		; X座標を8で割った余りからビット位置を計算
		; (0=0x80, 1=0x40,... 7=0x01)
		;---------------------------------------
		and		ecx, 0x07						; ECX = X & 0x07;
		mov		ebx, 0x80						; EBX = 0x80;
		shr		ebx, cl							; EBX >>= ECX;

		;---------------------------------------
		; 色指定
		;---------------------------------------
		mov		ecx, [ebp +16]					; // 表示色

		;---------------------------------------
		; プレーン毎に出力
		;---------------------------------------
		cdecl	vga_set_read_plane, 0x03		; // 輝度(I)プレーンを選択
		cdecl	vga_set_write_plane, 0x08		; // 輝度(I)プレーンを選択
		cdecl	vram_bit_copy, ebx, edi, 0x08, ecx

		cdecl	vga_set_read_plane, 0x02		; // 赤(R)プレーンを選択
		cdecl	vga_set_write_plane, 0x04		; // 赤(R)プレーンを選択
		cdecl	vram_bit_copy, ebx, edi, 0x04, ecx

		cdecl	vga_set_read_plane, 0x01		; // 緑(G)プレーンを選択
		cdecl	vga_set_write_plane, 0x02		; // 緑(G)プレーンを選択
		cdecl	vram_bit_copy, ebx, edi, 0x02, ecx

		cdecl	vga_set_read_plane, 0x00		; // 青(B)プレーンを選択
		cdecl	vga_set_write_plane, 0x01		; // 青(B)プレーンを選択
		cdecl	vram_bit_copy, ebx, edi, 0x01, ecx

        ;---------------------------------------
        ; レジスタの復帰
        ;---------------------------------------
        pop     edi
        pop     ecx
        pop     ebx
        pop     eax

        ;---------------------------------------
        ; スタックフレームの破棄
        ;---------------------------------------
        mov     esp, ebp
        pop     ebp

        ret