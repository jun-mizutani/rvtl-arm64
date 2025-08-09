//---------------------------------------------------------------------
//   Mersenne Twister
//   file : mt19937ar.s
//     Rewritten in ARM64 Assembly by Jun Mizutani 2025/08/09.
//     From original code in C by Takuji Nishimura(mt19937ar.c).
//     SISC-V version Copyright (C) 2025 Jun Mizutani.
//---------------------------------------------------------------------

// A C-program for MT19937, with initialization improved 2002/1/26.
// Coded by Takuji Nishimura and Makoto Matsumoto.
//
//  Before using, initialize the state by using init_genrand(seed)  
// or init_by_array(init_key, key_length).
//
//  Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
// All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
//    1. Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//    2. Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//    3. The names of its contributors may not be used to endorse or promote 
//      products derived from this software without specific prior written 
//      permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//   Any feedback is very welcome.
// http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
// email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)

.include "registers.s"

.text
//---------------------------------------------------------------------
// Initialize Mersenne Twister
//   enter x0 : 32bit seed
//---------------------------------------------------------------------
sgenrand:
        stp     x0, x30,  [sp, #-16]!
        stp     x1, x2,   [sp, #-16]!
        stp     xv2, xv3, [sp, #-16]!
        stp     xv4, xv5, [sp, #-16]!
        stp     xv6, xv7, [sp, #-16]!
        adr     xv3, mt
        ldr     wv4, N
        ldr     wv5, nffffffff
        ldr     wv6, n6C078965
        str     w0, [xv3]              // mt[0]=x0
        mov     w2, #1                 // i=1
    1:
        sub     w1, w2, #1             // i-1
        add     xv7, xv3, w1, uxtw #2  // mt + 4*(i-1)
        ldr     w0, [xv7]              // w0 = mt[i-1]
        lsr     w1, w0, #30
        eor     w0, w0, w1             // w0 ^ (w0 >> 30)
        mul     w0, w0, wv6            // w0^(w0>>30)*1812433253
        add     w0, w0, w2             // w0 + i
        add     xv7, xv3, w2, uxtw #2  // mt[i] = w0
        str     w0, [xv7]
        add     w2, w2, #1
        cmp     w2, wv4
        blt     1b                     // I+1 < 624

        adr     x1, mti
        str     wv4, [x1]              // mti=N
        ldp     xv6, xv7, [sp], #16
        ldp     xv4, xv5, [sp], #16
        ldp     xv2, xv3, [sp], #16
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//---------------------------------------------------------------------
// Generate Random Number
//   return w0 : random number
//---------------------------------------------------------------------
genrand:
        stp     xv7, x30,  [sp, #-16]!
        stp     x1, x2,   [sp, #-16]!
        stp     x3, xv1,  [sp, #-16]!
        stp     xv2, xv3, [sp, #-16]!
        stp     xv4, xv5, [sp, #-16]!
        stp     xv6, xip, [sp, #-16]!
        adr     xv2, mti
        adr     xv3, mt
        ldr     wv4, N
        ldr     w0, [xv2]              // mti
        sub     w2, wv4, #1            // N-1
        cmp     w0, w2                 // mti <= 623
        ble     3f                     // from mt[]
        ldr     wv5, M
        ldr     wv6, UPPER_MASK
        ldr     wv7, LOWER_MASK
        ldr     wv8, MATRIX_A
        mov     wv1, #0                // K=0
    1:
        ldr     w0, [xv3, xv1,LSL #2]  // mt[K]
        and     w0, w0, wv6            // UPPER_MASK
        add     w3, wv1, #1            // J=K+1
        bl      rnd_common2            // return Y>>1:w0,Z:w1
        add     w2, wv1, wv5           // w2=K+397
        bl      rnd_common
        str     w1, [xv3, xv1,LSL #2]  // mt[K]=P^Q^Z
        add     wv1, wv1, #1           // K=K+1
        sub     w0, wv4, wv5           // N-M=227
        cmp     wv1, w0
        blt     1b
    2:
        ldr     w0, [xv3, xv1,LSL #2]  // mt[K]
        and     w0, w0, wv6            // UPPER_MASK
        add     w3, wv1, #1            // J=K+1
        bl      rnd_common2            // return Y>>1:w0,Z:w1
        sub     w2, wv5, wv4
        add     w2, wv1, w2            // K+(M-N)
        bl      rnd_common
        str     w1, [xv3, xv1,LSL #2]  // mt[K]=P^Q^Z
        add     wv1, wv1, #1           // K=K+1
        sub     w2, wv4, #1            // 623
        cmp     wv1, w2
        blt     2b

        ldr     w0, [xv3, xv1,LSL #2]  // mt[K]
        and     w0, w0, wv6            // UPPER_MASK
        mov     w3, #0                 // J=0
        bl      rnd_common2            // return Y>>1:w0,Z:w1
        sub     w2, wv5, #1            // 396
        bl      rnd_common
        sub     w2, wv4, #1            // 623
        str     w1, [xv3, x2,LSL #2]   // mt[623]=P^Q^Z
        mov     w0, #0
        str     w0, [xv2]              // mti=0
    3:
        ldr     wv6, TEMPERING_MASK_B
        ldr     wv7, TEMPERING_MASK_C
        ldr     w0, [xv2]              // mti
        ldr     w3, [xv3, x0,LSL #2]   // y=mt[mti]
        add     w0, w0, #1
        str     w0, [xv2]              // mti++
        lsr     w0, w3, #11            // y>>11
        eor     w3, w3, w0             // y=y^(y>>11)
        lsl     w0, w3, #7             // y << 7
        and     w0, w0, wv6            // TEMPERING_MASK_B
        eor     w3, w3, w0
        lsl     w0, w3, #15
        and     w0, w0, wv7            // TEMPERING_MASK_C
        eor     w3, w3, w0
        lsr     w0, w3, #18
        eor     w0, w3, w0
        ldp     xv6, xip, [sp], #16
        ldp     xv4, xv5, [sp], #16
        ldp     xv2, xv3, [sp], #16
        ldp     x3, xv1, [sp], #16
        ldp     x1, x2,  [sp], #16
        ldp     xv7, x30, [sp], #16
        ret

    rnd_common:
        ldr     w3, [xv3, x2,LSL #2]   // mt[x]
        eor     w3, w3, w0             // mt[x]^P
        eor     w1, w3, w1
        ret
    rnd_common2:
        ldr     w1, [xv3, x3,LSL #2]   // mt[J]
        and     w1, w1, wv7            // LOWER_MASK
        orr     w3, w0, w1             // y
        lsr     w0, w3, #1             // w0=(y>>1)
        mov     w1, #0
        tst     w3, #1
        beq     1f
        mov     w1, wv8                // MATRIX_A
    1:  ret

N:                  .long   624
M:                  .long   397
n6C078965:          .long   1812433253
nffffffff:          .long   0xffffffff
TEMPERING_MASK_B:   .long   0x9d2c5680
TEMPERING_MASK_C:   .long   0xefc60000
UPPER_MASK:         .long   0x80000000
LOWER_MASK:         .long   0x7fffffff
MATRIX_A:           .long   0x9908b0df

.data
mti:                .long   N + 1

.bss
mt:                 .skip   624 * 4
