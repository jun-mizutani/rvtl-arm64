//-------------------------------------------------------------------------
//  Return of the Very Tiny Language for ARM64
//  2015/07/22
//  Copyright (C) 2015 Jun Mizutani <mizutani.jun@nifty.ne.jp>
//
//  file : ext.s
//-------------------------------------------------------------------------

        stp     x0, x30, [sp, #-16]!
        bl      GetChar             //
        cmp     x0, #'j'
        beq     ext_j
        b       func_err

ext_j:
        bl      GetChar             //
        cmp     x0, #'m'
        beq     ext_jm
        b       func_err
ext_jm:
        ldp     x0, x30, [sp], #16
        ret
