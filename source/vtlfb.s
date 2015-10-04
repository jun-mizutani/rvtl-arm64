//-------------------------------------------------------------------------
//  Return of the Very Tiny Language (ARM)
//  Copyright (C) 2003 - 2015 Jun Mizutani <mizutani.jun//nifty.ne.jp>
//  file : vtlfb.s  frame buffer extention
//  2015/09/25
//-------------------------------------------------------------------------

        stp     x0, x30, [sp, #-16]!
        bl      GetChar                //
        cmp     xv1, #'b
        beq     1f
        b       pop2_and_Error
    1:  bl      GetChar                //
        cmp     xv1, #'o
        beq     func_fbo               // fb open
        cmp     xv1, #'c
        beq     func_fbc               // fb close
        cmp     xv1, #'d
        beq     func_fbd               // fb dot
        cmp     xv1, #'f
        beq     func_fbf               // fb fill
        cmp     xv1, #'l
        beq     func_fbl               // fb line
        cmp     xv1, #'m
        beq     func_fbm               // fb mem_copy
        cmp     xv1, #'p
        beq     func_fbp               // fb put
        cmp     xv1, #'q
        beq     func_fbq               // fb put with mask
        cmp     xv1, #'r
        beq     func_fbr               // fb fill pattern
        cmp     xv1, #'s
        beq     func_fbs               // fb set_screen
        cmp     xv1, #'t
        beq     func_fbt               // fb put2
        b       pop2_and_Error

func_fbo:
        bl      fbdev_open
fb_error:
        bmi     pop_and_SYS_Error
        bl      fb_get_fscreen
        bmi     fb_error
        bl      fb_get_screen
        bmi     fb_error
        bl      fb_copy_scinfo
        bl      fb_map_screen
        bmi     pop_and_SYS_Error
        mov     x3, #'f
        str     x0, [x29, x3,LSL #3]
        mov     x3, #'g
        adr     x0, scinfo_data
        str     x0, [x29, x3,LSL #3]
        ldp     x0, x30, [sp], #16
        ret
func_fbf:
        bl      FrameBufferFill
        ldp     x0, x30, [sp], #16
        ret
func_fbd:
        bl      Dot
        ldp     x0, x30, [sp], #16
        ret
func_fbc:
        bl      fb_restore_sc          // 保存済みの設定を復帰
        bl      fb_unmap_screen
        bl      fbdev_close
        bmi     pop_and_SYS_Error
        ldp     x0, x30, [sp], #16
        ret
func_fbl:
        bl      LineDraw
        ldp     x0, x30, [sp], #16
        ret
func_fbm:
        bl      MemCopy
        ldp     x0, x30, [sp], #16
        ret
func_fbp:
        bl      PatternTransfer
        ldp     x0, x30, [sp], #16
        ret
func_fbq:
        bl      MPatternTransfer
        ldp     x0, x30, [sp], #16
        ret
func_fbr:
        bl      PatternFill
        ldp     x0, x30, [sp], #16
        ret
func_fbs:
        bl      fb_set_screen
        ldp     x0, x30, [sp], #16
        ret
func_fbt:
        bl      PatternTransfer2
        ldp     x0, x30, [sp], #16
        ret

//---------------------------------------------------------------------------
// 点の描画 16bit
//   d;0; = addr   [xv7,  #0] 転送先アドレス
//   d[2] = x      [xv7,  #8] 転送先のX座標
//   d[3] = y      [xv7, #12] 転送先のY座標
//   d[4] = Color  [xv7, #16] 色
//   d[5] = ScrX   [xv7, #20] 転送先X方向のバイト数
//   d[6] = Depth  [xv7, #24] 1ピクセルのビット数
Dot:
        stp     xv7, x30, [sp, #-16]!
        mov     x3, #'d'               // 引数は d[0] - d[5]
        ldr     xv7, [x29, x3,LSL #3]  // xv7 : argument top
        ldr     w3, [xv7, #20]         // ScrX
        ldr     x2, [xv7]              // buffer address (mem or fb)
        ldr     w1, [xv7, #12]         // Y
        mul     x0, x1, x3             // Y * ScrX
        ldr     w3, [xv7, #8]          // X
        ldr     w4, [xv7, #24]         // depth
        cmp     w4, #32
        beq     1f
        add     x1, x0, x3,LSL #1      // X * 2 + Y * ScrX
        ldr     w0, [xv7, #16]         // color
        strh    w0, [x2, x1]           // 16bit/pixel
        b       2f
    1:  add     x1, x0, x3,LSL #2      // X * 4 + Y * ScrX
        ldr     w0, [xv7, #16]         // color
        str     w0, [x2, x1]           // 32bit/pixel
    2:  ldp     xv7, x30, [sp], #16
        ret

//---------------------------------------------------------------------------
// x0 : Y  color
// x1 : width(bytes/line)
// xv6 : addr
StartPoint:
        stp     x2, x30, [sp, #-16]!
        mul     x2, x1, x0             // Y * width
        ldr     w0, [xv7, #+ 8]        // X
        add     x0, x2, x0,LSL #2      // Y * width + X*4
        add     xv6, xv6, x0           // xv6=addr+Y * width + X
        ldr     w0, [xv7, #+24]        // color
        ldp     x2, x30, [sp], #16
        ret

//---------------------------------------------------------------------------
// ライン描画
// l;0; = addr   [xv7, #+ 0]
// l[2] = x1     [xv7, #+ 8]      // l[3] = y1     [xv7, #+12]
// l[4] = x2     [xv7, #+16]      // l[5] = y2     [xv7, #+20]
// l[6] = color  [xv7, #+24]
// l[7] = ScrX   [xv7, #+28]
// l[8] = Depth  [xv7, #+32]      // 1ピクセルのビット数
// l[9] = incx1  [xv7, #+36]
// l[10] = incx2 [xv7, #+40]
// xv6 : framebuffer
// x1 (ebx) ScrX
// x2
LineDraw:
        stp     x3,  x30, [sp, #-16]!
        stp     xv4, xv5, [sp, #-16]!
        stp     xv6, xv7, [sp, #-16]!
        mov     x3, #'l'               // 引数は l[0] - l[9]
        ldr     xv7, [x29, x3,LSL #3]  // xv7 : argument top
        ldr     xv6, [xv7]             // buffer address (mem or fb)
        ldr     w1, [xv7, #+28]        // ScrX
        ldr     w2, [xv7, #+16]        // x2 = delta X (X2 - X1)
        ldr     w0, [xv7, #+ 8]
        subs    x2, x2, x0             // x2 = X2 - X1
        beq     VertLine               // if (delta X=0) Vertical
        bpl     1f                     // JUMP IF X2 > X1

        sub     x2, xzr, x2            // deltaX = - deltaX
        ldr     w0, [xv7, #+16]        // swap X1  X2
        add     xip, xv7, #8           // X1
        ldr     w3, [xip]
        str     w0, [xip]
        str     w3, [xv7, #+16]        // X2

        ldr     w0, [xv7, #+20]        // Y2
        add     xip, xv7, #12          // [xv7, #+12]
        ldr     w3, [xip]              // w3 = Y1
        str     w0, [xip]              // Y2 --> Y1
        str     w3, [xv7, #+20]        // Y1 --> Y2

    1:  ldr     w0, [xv7, #+20]        // x0 = Y2-Y1
        ldr     w3, [xv7, #+12]
        subs    x0, x0, x3
        bne     SlopeLine

HolizLine:
        add     x2, x2, #1             // DELTA X + 1 : # OF POINTS
        ldr     w0, [xv7, #+12]        // Y1
        bl      StartPoint             // xv6=addr + X + Y * width
    2:
        lsl     xip, x2, #2            // xip = x2, lsl #2
        str     w0, [xv6, xip]         //
        subs    x2, x2, #1
        bne     2b
        b       5f                     // finished

VertLine:
        ldr     w0, [xv7, #+12]        // Y1
        ldr     w3, [xv7, #+20]        // Y2
        mov     x2, x3
        subs    x2, x2, x0             // Y2 - Y1
        bge     3f
        sub     x2, xzr, x2            // neg x2
        mov     x0, x3
    3:  add     x2, x2, #1             // DELTA Y + 1 : # OF POINTS
        bl      StartPoint             // xv6=addr + X + Y * width
    4:
        str     w0, [xv6]
        add     xv6, xv6, x1           // x1:width
        subs    x2, x2, #1
        bne     4b
    5:
        ldp     xv6, xv7, [sp], #16
        ldp     xv4, xv5, [sp], #16
        ldp     x3,  x30, [sp], #16
        ret

    //-------------------------------------------------
    // ENTRY : x0 = DY    x1 = width (bytes/line)
    //         x2 = DX
    //         v4 = incx1, v5 = incx2

SlopeLine:
        bpl     1f                     // JUMP IF (Y2 > Y1)
        sub     x0, xzr, x0            // - DELTA Y
        sub     x1, xzr, x1            // - BYTES/LINE
    1:
        stp     x0, x2, [sp, #-16]!    // save x0:DY, x2:DX
        cmp     x0, x2                 // DELTA Y - DELTA X
        ble     2f                     // JUMP IF DY <= dx ( SLOPE <= 1)
        mov     xip, x0                // swap x0, x2
        mov     x0, x2
        mov     x2, xip

    2:
        lsl     x0, x0, #1             // eax = 2 * DY
        mov     xv4, x0                // incx1 = 2 * DY
        sub     x0, x0, x2
        mov     x3, x0                 // x3 = D = 2 * DY - dx
        sub     x0, x0, x2
        mov     xv5, x0                // incx2 = D = 2 * (DY - dx)

        ldr     w0, [xv7, #+12]        // Y1
        adds    xip, x1, xzr
        bpl     3f
        sub     x1, xzr, x1
    3:  bl      StartPoint             // xv6=addr + X + Y * width
        mov     x1, xip
        ldp     x0, x2, [sp], #16      // restore x0:DY, x2:DX

        cmp     x0, x2                 // DELTA Y - DELTA X
        bgt     HiSlopeLine            // JUMP IF DY > dx ( SLOPE > 1)

LoSlopeLine:
        add     x2, x2, #1
        ldr     w0, [xv7, #+24]        // color

    1:  str     w0, [xv6], #4
        tbz     x3, #63, 2f            // if x3>=0 then goto 2f
        // tst     x3, x3
        // bpl     2f
        add     x3, x3, xv4            // incx1
        subs    x2, x2, #1
        bne     1b
        b       9f

    2:
        add     x3, x3, xv5            // incx2
        add     xv6, xv6, x1           // ebx=(+/-)width
        subs    x2, x2, #1
        bne     1b
        b       9f

HiSlopeLine:
        add     x2, x0, #1             // x2=DELTA Y + 1
        ldr     w0, [xv7, #+24]        // color

    1:  str     w0, [xv6], #4
        add     xv6, xv6, x1           // xv6=(+/-)width
        tbz     x3, #63, 2f            // if x3>=0 then goto 2f
        // tst     x3, x3
        // bpl     2f
        add     x3, x3, xv4            // incx1
        sub     xv6, xv6, #4
        subs    x2, x2, #1
        bne     1b
        b       9f

    2:  add     x3, x3, xv5            // incx2
        subs    x2, x2, #1
        bne     1b

    9:  ldp     xv6, xv7, [sp], #16
        ldp     xv4, xv5, [sp], #16
        ldp     x3,  x30, [sp], #16
        ret

//---------------------------------------------------------------------------
// 引数関連共通処理
// entry  : x3=配列変数名, xv7=配列変数アドレス
// return : xv6=バッファ先頭, xv5=パターン先頭, x1=スクリーン幅(byte)
//          x3=bits/pixel
PatternSize:
        ldr     xv7, [x29, x3,LSL #3]  // xv7 : argument top
        ldr     xv6, [xv7]             // buffer address (mem or fb)
        ldr     xv5, [xv7, #+24]       // pattern address
        ldr     w3,  [xv7, #+36]       // Depth
        ldr     w2,  [xv7, #+32]       // ScrX
        ldr     w0,  [xv7, #+12]       // Y
        mul     x0,  x2, x0            // Y * ScrX
        ldr     w1,  [xv7, #+ 8]       // X
        lsl     x1, x1, #1             // X * 2
        cmp     w3,  #32               // depth 32bit ?
        bne     1f                     // depth 16bit
        lsl     x1, x1, #1             // X * 4
    1:  add     x0,  x0, x1            // X * 4 + Y * ScrX
        add     xv6, xv6, x0           // xv6 = addr + x0
        mov     x1,  x2                // x1 = ScrX (bytes/line)
        ldr     wv3, [xv7, #+16]       // PatW
        ldr     w2,  [xv7, #+20]       // PatH
        ret

//---------------------------------------------------------------------------
// パターン転送 32bit
//   p;0; = addr   [xv7, #+ 0] 転送先アドレス
//   p[2] = x      [xv7, #+ 8] 転送先のX座標
//   p[3] = y      [xv7, #+12] 転送先のY座標
//   p[4] = PatW   [xv7, #+16] パターンの幅
//   p[5] = PatH   [xv7, #+20] パターンの高さ
//   p;3; = mem    [xv7, #+24] パターンの格納アドレス
//   p[8] = ScrX   [xv7, #+32] 転送先X方向のバイト数
//   p[9] = Depth  [xv7, #+36] 1ピクセルのビット数

PatternTransfer:
        stp     xv3, x30, [sp, #-16]!
        stp     xv4, xv5, [sp, #-16]!
        stp     xv6, xv7, [sp, #-16]!
        mov     x3, #'p'               // 引数
        bl      PatternSize
    1:  mov     x3, xv3                // PatW
        mov     xv4, xv6
    2:  ldr     w0, [xv5], #4          // パターンから(32bit)
        str     w0, [xv6], #4          // フレームバッファへ
        subs    x3, x3, #1
        bne     2b                     // next X
        add     xv6, xv4, x1           // next Y
        subs    x2, x2, #1             // PatH
        bne     1b
        b       pt_exit                // return

//---------------------------------------------------------------------------
// パターン転送2 16bit
//   t;0; = addr   [xv7, #+ 0] 転送先アドレス
//   t[2] = x      [xv7, #+ 8] 転送先のX座標
//   t[3] = y      [xv7, #+12] 転送先のY座標
//   t[4] = PatW   [xv7, #+16] パターンの幅
//   t[5] = PatH   [xv7, #+20] パターンの高さ
//   t;3; = mem    [xv7, #+24] パターンの格納アドレス先頭
//   t[8] = ScrX   [xv7, #+32] 転送先のX方向のバイト数
//   t[9] = Depth  [xv7, #+36] 1ピクセルのbit数
//   t[10]= x2     [xv7, #+40] 転送元のX座標
//   t[11]= y2     [xv7, #+44] 転送元のY座標
//   t[12]= ScrX2  [xv7, #+48] 転送元のX方向のバイト数

PatternTransfer2:
        stp     xv3, x30, [sp, #-16]!
        stp     xv4, xv5, [sp, #-16]!
        stp     xv6, xv7, [sp, #-16]!
        mov     x3, #'t                // 引数
        bl      PatternSize
        ldr     w0, [xv7, #+48]        // ScrX2
        ldr     wv4, [xv7, #+44]       // Y2
        mul     xv4, x0, xv4           // Y2 * ScrX2
        ldr     w0, [xv7, #+40]        // X2
        add     w0, wv4, w0,LSL #2     // X2 * 4 + Y2 * ScrX2
        add     xv4, xv5, x0           // xv4 = mem + xv1
        ldr     w0, [xv7, #+48]        // ScrX2
    1:  mov     x3, xv3                // PatW
        stp     xv4, xv6, [sp, #-16]!
    2:  ldr     wip, [xv4], #4
        str     wip, [xv6], #4
        subs    x3, x3, #1             // PatW
        bne     2b                     // next X
        ldp     xv4, xv6, [sp], #16
        add     xv6, xv6, x1           // y++
        add     xv4, xv4, x0           // y2++
        subs    x2, x2, #1             // PatH
        bne     1b
        b       pt_exit                // return

//---------------------------------------------------------------------------
// マスク付きパターン転送 16&32bit
//   q;0; = addr   [xv7, #+ 0] 転送先アドレス
//   q[2] = x      [xv7, #+ 8] 転送先のX座標
//   q[3] = y      [xv7, #+12] 転送先のY座標
//   q[4] = PatW   [xv7, #+16] パターンの幅
//   q[5] = PatH   [xv7, #+20] パターンの高さ
//   q;3; = mem    [xv7, #+24] パターンの格納アドレス
//   q[8] = ScrX   [xv7, #+32] X方向のバイト数
//   q[9] = Depth  [xv7, #+36] 1ピクセルのビット数
//   q[10]= Mask   [xv7, #+40] マスク色
MPatternTransfer:
        stp     xv3, x30, [sp, #-16]!
        stp     xv4, xv5, [sp, #-16]!
        stp     xv6, xv7, [sp, #-16]!
        mov     x3, #'q                // 引数
        bl      PatternSize
        ldr     wv4, [xv7, #+40]       // マスク色なら書込まない
    1:  mov     x3, xv3                // PatW
        mov     xip, xv6
    2:  ldr     w0, [xv5], #4          // 32bit
        cmp     x0, xv4                // マスク色なら書込まない
        beq     3f
        str     w0, [xv6]
    3:  add     xv6, xv6, #4           // 常に転送先を更新
        subs    x3, x3, #1             // PatW
        bne     2b                     // next X
        add     xv6, xip, x1
        subs    x2, x2, #1             // PatH
        bne     1b                     // next Y
pt_exit:
        ldp     xv6, xv7, [sp], #16
        ldp     xv4, xv5, [sp], #16
        ldp     xv3, x30, [sp], #16
        ret

//---------------------------------------------------------------------------
// パターンフィル 16&32bit
//   r;0; = addr   [xv7, #+ 0] 転送先アドレス
//   r[2] = x      [xv7, #+ 8] 転送先のX座標
//   r[3] = y      [xv7, #+12] 転送先のY座標
//   r[4] = PatW   [xv7, #+16] パターンの幅
//   r[5] = PatH   [xv7, #+20] パターンの高さ
//   r[6] = Color  [xv7, #+24] パターンの色
//   r[7] = ScrX   [xv7, #+28] X方向のバイト数
//   r[8] = Depth  [xv7, #+32] 1ピクセルのビット数

PatternFill:
        stp     xv5, x30, [sp, #-16]!
        stp     xv6, xv7, [sp, #-16]!
        mov     x3, #'r                // 引数
        ldr     xv7, [x29, x3,LSL #3]  // xv7 : argument top
        ldr     xv6, [xv7]             // buffer address (mem or fb)
        ldr     wv5, [xv7, #+24]       // color
        ldr     w2,  [xv7, #+28]       // ScrX
        ldr     w0,  [xv7, #+12]       // Y
        mul     x0,  x2, x0            // Y * ScrX
        ldr     w1,  [xv7, #+ 8]       // X
        add     x0,  x0, x1, LSL #2    // X * 4 + Y * ScrX
        add     xv6, xv6, x0           // xv6 = addr + x0
        mov     x1,  x2                // x1 = Screen Width(bytes)
        ldr     w2,  [xv7, #+20]       // PatH
    1:  ldr     w3, [xv7, #+16]        // PatW
        mov     xip, xv6               // save xv6
    2:  str     wv5, [xv6], #4         // フレームバッファへ
        subs    x3, x3, #1
        bne     2b                     // next X
        add     xv6, xip, x1           // next Y
        subs    x2, x2, #1             // PatH
        bne     1b
        ldp     xv6, xv7, [sp], #16
        ldp     xv5, x30, [sp], #16
        ret

//---------------------------------------------------------------------------
// メモリフィル 8&16&32bit
//  m;0; = addr   [xv7, #+ 0] メモリフィル先頭アドレス
//  m[2] = offset [xv7, #+ 8] オフセット
//  m[3] = length [xv7, #+12] 長さ(ピクセル単位)
//  m[4] = color  [xv7, #+16] 色
//  m[5] = Depth  [xv7, #+20] bits/pixel

FrameBufferFill:
        stp     xv5, x30, [sp, #-16]!
        stp     xv6, xv7, [sp, #-16]!
        mov     x3, #'m                // 引数は a[0] - a[4]
        ldr     xv7, [x29, x3,LSL #3]
        ldr     xv6, [xv7]
        ldr     w0, [xv7, #+ 8]        // offset
        add     xv6, xv6, x0
        ldr     w2, [xv7, #+12]        // length (pixel)
        ldr     w0, [xv7, #+16]        // color
        ldr     w1, [xv7, #+20]        // bits/pixel
        lsr     x1, x1, #4
        cbnz    x1, 2f                 // status
    1:  strb    w0, [xv6], #1          // フレームバッファへ byte
        subs    x2, x2, #1
        bne     1b
        b       5f                     // exit
    2:  lsr     x1, x1, #1
        cbnz    x1, 4f                 // status
    3:  strh    w0, [xv6], #2          // フレームバッファへ hword
        subs    x2, x2, #1
        bne     1b
        b       5f
    4:  str     x0, [xv6], #4          // フレームバッファへ word
        subs    x2, x2, #1
        bne     4b                     // exit
    5:
        ldp     xv6, xv7, [sp], #16
        ldp     x3,  x30, [sp], #16
        ret

//---------------------------------------------------------------------------
// メモリコピー
//  c;0; = source [xv7, #+ 0] 転送元先頭アドレス
//  c;1; = dest   [xv7, #+ 8] 転送先先頭アドレス
//  c[4] = length [xv7, #+ 16] 転送バイト数
MemCopy:
        stp     x3,  x30, [sp, #-16]!
        stp     xv6, xv7, [sp, #-16]!
        mov     x3, #'c                // 引数は c[0] - c[2]
        ldr     xv7, [x29, x3,LSL #3]
        ldr     x3, [xv7]              // 転送元アドレス
        ldr     x2, [xv7, #+ 8]        // 転送先アドレス
        ldr     w1, [xv7, #+ 16]       // 転送バイト数
        sub     x0, x2, x3             // x0 = 転送先 - 転送元
        bgt     2f                     // 転送先 >= 転送元
        sub     xip, x1, #1
        add     x3, x3, xip
        add     x2, x2, xip
    1:  ldrb    w0, [x3], #-1
        strb    w0, [x2], #-1
        subs    x1, x1, #1
        bne     1b                     //
        b       3f

    2:  ldrb    w0, [x3], #1
        strb    w0, [x2], #1
        subs    x1, x1, #1
        bne     2b                     //
    3:
        ldp     xv6, xv7, [sp], #16
        ldp     x3,  x30, [sp], #16
        ret

