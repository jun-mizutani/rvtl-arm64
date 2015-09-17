//-------------------------------------------------------------------------
//  Debugging Macros for ARM64 assembly
//  file : debug.s
//  2015/08/06
//  Copyright (C) 2015 Jun Mizutani <mizutani.jun@nifty.ne.jp>
//  This file may be copied under the terms of the GNU General Public License.
//-------------------------------------------------------------------------

.ifndef __STDIO
.include "stdio.s"
.endif


//          +------+
//          | x30  |
//          +------+
//    sp->  | x0   | +16
//          +------+
//          | x1   | +8
//          +------+
//    sp->  | nzcv | +0
//          +======+
.macro  ENTER
        stp     x0, x30, [sp, #-16]!
        mrs     x0, nzcv
        stp     x0, x1,  [sp, #-16]!
        ldr     x0, [sp, #+16]
.endm

.macro  LEAVE
        ldp     x0,  x1, [sp], #16
        msr     nzcv, x0
        ldp     x0, x30, [sp], #16
.endm

// Print a register value (x0 - x30)
// x0 - x30, nzcv registers are unchanged.
// ex. PRINTREG x0
// x0 -4520909795638496974 13925834278071054642:C142807E61623132 21ba~.BA
.macro  PRINTREG   reg
        ENTER
        adr     x0, 998f
        bl      OutAsciiZ
        ldr     x0, [sp, #+16]
        ldr     x1, [sp, #+8]
        mov     x0, \reg
        mov     x1, #21
        bl      PrintRight
        bl      PrintRightU
        mov     x0, #':'
        bl      OutChar
        ldr     x0, [sp, #+16]
        ldr     x1, [sp, #+8]
        mov     x0, \reg
        bl      PrintHex16
        mov     x0, #' '
        bl      OutChar
        ldr     x0, [sp, #+16]
        bl      OutChar8
        bl      NewLine
        LEAVE
        b       999f
        .align  2
998:    .asciz "\reg"
        .align  2
999:
.endm

// Print ASCIIZ string from the address value in the register.
//   ex. PRINTSTR x11
.macro  PRINTSTR   reg
        ENTER
        mov     x0, \reg
        bl      OutAsciiZ
        bl      NewLine
        LEAVE
.endm

// Print ASCIIZ string from the address value in the memory
// pointed by the register.
//   ex. PRINTSTRI x11
.macro  PRINTSTRI  reg
        ENTER
        ldr     x0, [\reg]
        bl      OutAsciiZ
        bl      NewLine
        LEAVE
.endm

// Print a number.
//   ex. CHECK 99
.macro  CHECK   number
        ENTER
        mov     x0, #\number
        bl      PrintLeft
        bl      NewLine
        LEAVE
.endm

// Print NZCV flags in Hex format(4bit).
.macro  PRINTFLAGSHEX
        ENTER
        ldr     x0, [sp]
        lsr     x0, x0, #28
        mov     X1, #1
        bl      PrintHex
        bl      NewLine
        LEAVE
.endm

// Print NZCV flags such as "nzcv, NzCv".
.macro  PRINTFLAGS
        ENTER
        ldr     x1, [sp]
        lsl     x1, x1, #32
        mov     x0, #'n'
        adds    x1, x1, xzr
        b.pl    1f
        sub     x0, x0, #0x20
    1:  bl      OutChar
        lsl     x1, x1, #1
        mov     x0, #'z'
        adds    x1, x1, xzr
        b.pl    2f
        sub     x0, x0, #0x20
    2:  bl      OutChar
        lsl     x1, x1, #1
        mov     x0, #'c'
        adds    x1, x1, xzr
        b.pl    3f
        sub     x0, x0, #0x20
    3:  bl      OutChar
        lsl     x1, x1, #1
        mov     x0, #'v'
        adds    x1, x1, xzr
        b.pl    4f
        sub     x0, x0, #0x20
    4:  bl      OutChar
        bl      NewLine
        LEAVE
.endm

// Wait until key press.
.macro  PAUSE
        ENTER
        bl      InChar
        LEAVE
.endm
