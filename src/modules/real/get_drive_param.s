get_drive_param:
        ;----------------------------------
        ; スタックフレームの構築
        ;----------------------------------
                                            ;    + 4| パラメータバッファ
                                            ;    + 2| IP(戻り番地)
        push    bp                          ;  BP+ 0| BP(元の値)
        mov     bp, sp                      ; ------+----------

        ;----------------------------------
        ; レジスタの保存
        ;----------------------------------
        push    bx
        push    cx
        push    es
        push    si
        push    di

        ;----------------------------------
        ; 処理の開始
        ;----------------------------------
        mov     si, [bp + 4]                ; SI = バッファ;

        mov     ax, 0                       ; Disk Base Table Pointerの初期化
        mov     es, ax                      ; ES = 0;
        mov     di, ax                      ; DI = 0;

        mov     ah, 8                       ; // get drive paramters
        mov     dl, [si + drive.no]         ; DL = ドライブ番号;
        int     0x13                        ; CF = BIOS(0x13, 8);
.10Q:   jc      .10F                        ; if(0 == CF)
.10T:                                       ; {
        mov     al, cl                      ;   AX = セクタ数;
        and     ax, 0x3F                    ;   // 下位6ビットのみで有効

        shr     cl, 6                       ;   CX = シリンダ数;
        ror     cx, 8                       ;
        inc     cx                          ;

        movzx   bx, dh                      ;   BX = ヘッド数(1ベース);
        inc     bx                          ;

        mov     [si + drive.cyln], cx       ;   drive.syln = CX;    // C:シリンダ数
        mov     [si + drive.head], bx       ;   drive.head = BX;    // H:ヘッド数
        mov     [si + drive.sect], ax       ;   drive.sect = AX;    // S:シリンダ数

        jmp     .10E                        ; }
.10F:                                       ; else
                                            ; {
        mov     ax, 0                       ;   AX = 0;     // 失敗
.10E:                                       ; }

        ;----------------------------------
        ; レジスタの復帰
        ;----------------------------------
        pop     di
        pop     si
        pop     es
        pop     cx
        pop     bx

        ;----------------------------------
        ; スタックフレームの破棄
        ;----------------------------------
        mov     sp, bp
        pop     bp

        ret