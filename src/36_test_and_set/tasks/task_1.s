task_1:
        ;----------------------------------
        ; 文字列の表示
        ;----------------------------------
        cdecl   draw_str, 63, 0, 0x07, .s0

.10L:

        ;----------------------------------
        ; 時刻の表示
        ;----------------------------------
        mov     eax, [RTC_TIME]
        cdecl   draw_time, 72, 0, 0x0700, eax

        jmp     .10L

        ;----------------------------------
        ; データ
        ;----------------------------------
.s0     db  "Task-1", 0