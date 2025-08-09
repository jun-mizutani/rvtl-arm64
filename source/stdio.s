// ------------------------------------------------------------------------
// Standard I/O Subroutine for ARM64
//   2025/08/09 arm64 system call
// Copyright (C) 2015-2025  Jun Mizutani <mizutani.jun@nifty.ne.jp>
// stdio.s may be copied under the terms of the GNU General Public License.
// ------------------------------------------------------------------------

// SP must be quad-word aligned.

.ifndef __STDIO
__STDIO = 1

.ifndef __SYSCALL
  .equ sys_exit,  93
  .equ sys_read,  63
  .equ sys_write, 64
.endif

.text

//------------------------------------
// exit with 0
Exit:
        mov     x0, xzr
        mov     x8, #sys_exit
        svc     #0
        ret                         // ret x30

//------------------------------------
// exit with x0
ExitN:
        mov     x8, #sys_exit
        svc     #0
        ret


//------------------------------------
// print string to stdout
// x0 : address, x1 : length
OutString:
        stp     x8, x30, [sp, #-16]!
        stp     x0,  x1, [sp, #-16]!
        stp     x2,  x3, [sp, #-16]!    // x3 : filler
        mov     x2,  x1                 // a2  length
        mov     x1,  x0                 // a1  string address
        mov     x0,  #1                 // a0  stdout
        mov     x8,  #sys_write
        svc     #0
        ldp     x2,  x3, [sp], #16
        ldp     x0,  x1, [sp], #16
        ldp     x8, x30, [sp], #16
        ret

//------------------------------------
// input  x0 : address
// output x1 : return length of strings
StrLen:
        stp     x2, x30, [sp, #-16]!
        stp     x0, x3,  [sp, #-16]!    // x3 : filler
        mov     x1, xzr                 // x1 : counter
1:      ldrb    w2, [x0], #1            // x2 = *pointer++ (1byte)
        cmp     x2, #0
        add     x1, x1, #1              // counter++
        bne     1b
        sub     x1, x1, #1              // counter++
        ldp     x0, x3, [sp], #16
        ldp     x2, x30, [sp], #16
        ret

//------------------------------------
// print asciiz string
// x0 : pointer to string
OutAsciiZ:
        stp     x1, x30, [sp, #-16]!
        bl      StrLen
        bl      OutString
        ldp     x1, x30, [sp], #16
        ret

//------------------------------------
// print pascal string to stdout
// x0 : top address
OutPString:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2, [sp, #-16]!
        ldrb    w1, [x0]
        add     x0, x0, #1
        bl      OutString
        ldp     x1, x2, [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//------------------------------------
// print 1 character to stdout
// x0 : put char
OutChar:
        stp     x8, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        stp     x0, x1, [sp, #-16]!
        mov     x1, sp                  // x1  address
        mov     x0, #1                  // x0  stdout
        mov     x2, x0                  // x2  length
        mov     x8, #sys_write
        svc     #0
        ldp     x0, x1, [sp], #16
        ldp     x1, x2,  [sp], #16
        ldp     x8, x30, [sp], #16
        ret

//------------------------------------
// print 4 printable characters in x0 to stdout
OutChar4:
        stp     x2, x30, [sp, #-16]!
        stp     x0, x1,  [sp, #-16]!
        mov     x2, #4
        b       OutCharN

//------------------------------------
// print 8 printable characters in x0 to stdout
OutChar8:
        stp     x2, x30, [sp, #-16]!
        stp     x0, x1,  [sp, #-16]!
        mov     x2, #8

OutCharN:
        mov     x1, x0
1:
        and     x0, x1, #0x7F
        cmp     x0, #0x20
        b.ge    2f
        mov     x0, #'.'
2:
        bl      OutChar
        lsr     x1, x1, #8
        subs    x2, x2, #1
        b.ne    1b
        ldp     x0, x1,  [sp], #16
        ldp     x2, x30, [sp], #16
        ret


//------------------------------------
// new line
NewLine:
        stp     x0, x30, [sp, #-16]!
        mov     x0, #10
        bl      OutChar
        ldp     x0, x30, [sp], #16
        ret


//------------------------------------
// Backspace
BackSpace:
        stp     x0, x30, [sp, #-16]!
        mov     x0, #8
        bl      OutChar
        mov     x0, #' '
        bl      OutChar
        mov     x0, #8
        bl      OutChar
        ldp     x0, x30, [sp], #16
        ret

//------------------------------------
// print binary number
//   x0 : number
//   x1 : bit
PrintBinary:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        cmp     x1, #0                  // x1 > 0 ?
        b.eq    4f                      // if x1=0 exit
        mov     x2, #64
        cmp     x1, x2
        b.le    1f
        mov     x1, x2                  // if x1>64 then x1=64
    1:  subs    x2, x2, x1
        lsl     x2, x0, x2              // discard upper 64-x1 bit
    2:  mov     x0, #'0'
        adds    x2, xzr, x2
        b.pl    3f
        add     x0, x0, #1
    3:  bl      OutChar
        lsl     x2, x2, #1
        subs    x1, x1, #1
        b.ne    2b
    4:
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//------------------------------------
// print ecx digit octal number
//   x0 : number
//   x1 : columns
PrintOctal:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        stp     x3, x6,  [sp, #-16]!
        mov     x6, sp
        sub     sp, sp, #32             // allocate buffer
        cmp     x1, #0                  // x1 > 0 ?
        beq     3f                      // if x1=0 exit
        mov     x3, x1                  // column
    1:  and     x2, x0, #7
        lsr     x0, x0, #3
        strb    w2, [x6, #-1]!
        subs    x3, x3, #1
        bne     1b
    2:  ldrb    w0, [x6], #1            // 上位桁から POP
        add     x0, x0, #'0'            // 文字コードに変更
        bl      OutChar                 // 出力
        subs    x1, x1, #1              // column--
        bne     2b
    3:
        add     sp, sp, #32
        ldp     x3, x6,  [sp], #16
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//------------------------------------
// print 2 digit hex number (lower 8 bit of x0)
//   x0 : number
PrintHex2:
        mov     x1, #2
        b       PrintHex

//------------------------------------
// print 4 digit hex number (lower 16 bit of x0)
//   x0 : number
PrintHex4:
        mov     x1, #4
        b       PrintHex

//------------------------------------
// print 8 digit hex number (x0)
//   x0 : number
PrintHex8:
        mov     x1, #8
        b       PrintHex

PrintHex16:
        mov     x1, #16

//------------------------------------
// print hex number
//   x0 : number     x1 : digit
// はじめは、未使用のスタックトップにバッファを確保したために
// サブルーチン呼び出しでバッファ内容を破壊していた。2015/07/15
PrintHex:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        stp     x3, x6,  [sp, #-16]!    // x6 : pointer for  buffer
        mov     x6, sp
        sub     sp, sp, #16             // allocate buffer
        mov     x3, x1                  // column
1:      and     x2, x0, #0x0F           //
        lsr     x0, x0, #4              //
        orr     x2, x2, #0x30
        cmp     x2, #0x39
        b.le    3f
        add     x2, x2, #0x41-0x3A      // if (x2>'9') x2+='A'-'9'
3:
        strb    w2,  [x6, #-1]!         // first in/last out
        subs    x3, x3, #1              // column--
        b.ne    1b
        mov     x3, x1                  // column
2:
        ldrb    w0, [x6], #1
        bl      OutChar
        subs    x3, x3, #1              // column--
        b.ne    2b
        add     sp, sp, #16
        ldp     x3, x6,  [sp], #16
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//------------------------------------
// Output Unsigned Number to stdout
// x0 : number
PrintLeftU:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        stp     x3, x4,  [sp, #-16]!
        stp     x5, x6,  [sp, #-16]!    // x6 : fp
        mov     x6, sp
        sub     sp, sp, #32             // allocate buffer
        mov     x2, #0                  // counter
        mov     x3, #0                  // positive flag
        b       1f

//------------------------------------
// Output Number to stdout
// x0 : number
PrintLeft:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        stp     x3, x4,  [sp, #-16]!
        stp     x5, x6,  [sp, #-16]!    // x6 : fp
        mov     x6, sp
        sub     sp, sp, #32             // allocate buffer
        mov     x2, #0                  // counter
        mov     x3, #0                  // positive flag
        cmp     x0, #0
        b.ge    1f
        mov     x3, #1                  // set negative
        sub     x0, x2, x0              // x0 = 0-x0
    1:  mov     x1, #10                 // x3 = 10
        udiv    x5, x0, x1              // division by 10
        msub    x1, x5, x1, x0
        mov     x0, x5
        add     x2, x2, #1              // counter++
        strb    w1, [x6, #-1]!          // least digit (reminder)
        cmp     x0, #0
        bne     1b                      // done ?
        cmp     x3, #0
        b.eq    2f
        mov     x0, #'-'                // if (x0<0) putchar("-")
        bl      OutChar                 // output '-'
    2:  ldrb    w0, [x6], #1            // most digit
        add     x0, x0, #'0'            // ASCII
        bl      OutChar                 // output a digit
        subs    x2, x2, #1              // counter--
        bne     2b
        add     sp, sp, #32
        ldp     x5, x6,  [sp], #16
        ldp     x3, x4,  [sp], #16
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//------------------------------------
// Output Number to stdout
// x1:column
// x0:number
PrintRight0:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        stp     x3, x4,  [sp, #-16]!
        stp     x5, x6,  [sp, #-16]!
        stp     x7, x8,  [sp, #-16]!    // x8 : fp
        mov     x8, sp
        sub     sp, sp, #32             // allocate buffer
        mov     x4, #'0'
        b       0f

//------------------------------------
// Output Unsigned Number to stdout
// x1:column
// x0:number
PrintRightU:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        stp     x3, x4,  [sp, #-16]!
        stp     x5, x6,  [sp, #-16]!
        stp     x7, x8,  [sp, #-16]!    // x8 : fp
        mov     x8, sp
        sub     sp, sp, #32             // allocate buffer
        mov     x4, #' '
    0:  mov     x5, x1
        mov     x2, #0                  // counter
        mov     x3, #0                  // positive flag
        b       1f                      // PrintRight.1

//------------------------------------
// Output Number to stdout
// x1:column
// x0:number
PrintRight:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        stp     x3, x4,  [sp, #-16]!
        stp     x5, x6,  [sp, #-16]!
        stp     x7, x8,  [sp, #-16]!    // x8 : fp
        mov     x8, sp
        sub     sp, sp, #32             // allocate buffer
        mov     x4, #' '
        mov     x5, x1
        mov     x2, xzr                 // counter=0
        mov     x3, xzr                 // positive flag
        cmp     x0, xzr
        b.ge    1f
        mov     x3, #1                  // set negative
        sub     x0, xzr, x0             // x0 = 0-x0
    1:  mov     x1, #10                 // x3 = 10
        udiv    x7, x0, x1              // division by 10
        mul     x6, x7, x1
        sub     x1, x0, x6              // x1:remainder
        mov     x0, x7                  // x0 : quotient7
        add     x2, x2, #1              // counter++
        strb    w1, [x8, #-1]!          // least digit
        cmp     x0, #0
        bne     1b                      // done ?

        cmp     x3, #0
        b.eq    5f                      // if positive
        sub     x5, x5, #1              // reserve spase for -
    5:  subs    x5, x5, x2              // x5 = no. of space
        ble     3f                      // dont write space
    2:  mov     x0, x4                  // output space or '0'
        bl      OutChar
        subs    x5, x5, #1              // nspace--
        bgt     2b

    3:  cmp     x3, #0
        b.eq    4f
        mov     x0, #'-'                // if (x0<0) putchar("-")

    3:  cmp     x3, #0
        b.eq    4f
        mov     x0, #'-'                // if (x0<0) putchar("-")
        bl      OutChar                 // output '-'
    4:  ldrb    w0, [x8], #1            // most digit
        add     x0, x0, #'0'            // ASCII
        bl      OutChar                 // output a digit
        subs    x2, x2, #1              // counter--
        b.ne    4b
        add     sp, sp, #32
        ldp     x7, x8,  [sp], #16      // x8 : filler
        ldp     x5, x6,  [sp], #16
        ldp     x3, x4,  [sp], #16
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//------------------------------------
// input 1 character from stdin
// x0 : get char
InChar:
        mov     x0, xzr                 // clear upper bits
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        stp     x8, x3,  [sp, #-16]!    // x3 : filler
        add     x1, sp, #32             // x1(stack) address
        mov     x0, #0                  // x0  stdin
        mov     x2, #1                  // x2  length
        mov     x8, #sys_read
        svc     #0
        ldp     x8, x3,  [sp], #16
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//------------------------------------
// Input Line
// x0 : BufferSize
// x1 : Buffer Address
// return       x0 : no. of char
InputLine0:
        stp     x1, x30, [sp, #-16]!
        stp     x2, x3,  [sp, #-16]!
        stp     x4, x5,  [sp, #-16]!
        mov     x4, x0                  // BufferSize
        mov     x5, x1                  // Input Buffer
        mov     x3, xzr                 // counter
    1:
        bl      InChar
        cmp     x0, #0x08               // BS ?
        bne     2f
        cmp     x3, #0
        beq     2f
        bl      BackSpace               // backspace
        sub     x3, x3, #1
        b       1b
    2:
        cmp     x0, #0x0A               // enter ?
        beq     4f                      // exit

        bl      OutChar                 // printable:
        strb    w0, [x5, x3]            // store a char into buffer
        add     x3, x3, #1
        cmp     x3, x4
        bge     3f
        b       1b
    3:
        sub     x3, x3, #1
        bl      BackSpace
        b       1b

    4:  mov     x0, #0
        strb    w0, [x5, x3]
        add     x3, x3, #1
        bl      NewLine
        mov     x0, x3
        ldp     x4, x5,  [sp], #16
        ldp     x2, x3,  [sp], #16
        ldp     x1, x30, [sp], #16
        ret

.endif
