//-------------------------------------------------------------------------
//  file : vtlsys.s
//  2015/08/30
//  Copyright (C) 2015 Jun Mizutani <mizutani.jun@nifty.ne.jp>
//-------------------------------------------------------------------------

.text

SYSCALLMAX  =   281

SystemCall: // return x0
        stp     x1, x30, [sp, #-16]!
        stp     x2, x3,  [sp, #-16]!
        stp     x4, x5,  [sp, #-16]!
        stp     x7, x8,  [sp, #-16]!
        mov     x7, #'a              // a にシステムコール番号
        ldr     x8, [x29, x7,LSL #3] // x8=システムコール番号
	cmp     x8, #SYSCALLMAX
	bgt     1f
        mov     x7, #'b              // b にシステムコール引数1
        ldr     x0, [x29, x7,LSL #3] // x0=システムコール引数1
        mov     x7, #'c              // c にシステムコール引数2
        ldr     x1, [x29, x7,LSL #3] // x1=システムコール引数2
        mov     x7, #'d              // d にシステムコール引数3
        ldr     x2, [x29, x7,LSL #3] // x2=システムコール引数3
        mov     x7, #'e              // e にシステムコール引数4
        ldr     x3, [x29, x7,LSL #3] // x3=システムコール引数4
        mov     x7, #'f              // f にシステムコール引数5
        ldr     x4, [x29, x7,LSL #3] // x4=システムコール引数5
        mov     x7, #'g              // g にシステムコール引数6
        ldr     x5, [x29, x7,LSL #3] // x5=システムコール引数6
        svc     0
    1:
        ldp     x7, x8,  [sp], #16
        ldp     x4, x5,  [sp], #16
        ldp     x2, x3,  [sp], #16
        ldp     x1, x30, [sp], #16
        ret

