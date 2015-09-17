//---------------------------------------------------------------------
//   Mersenne Twister
//   file : mt19937.s
//     Rewritten in ARM64 Assembly by Jun Mizutani 2015/08/06.
//     From original code in C by Takuji Nishimura(mt19937int.c).
//     Arm64 version Copyright (C) 2015 Jun Mizutani.
//---------------------------------------------------------------------

// A C-program for MT19937: Integer version (1999/10/28)
//  genrand() generates one pseudorandom unsigned integer (32bit)
// which is uniformly distributed among 0 to 2^32-1  for each
// call. sgenrand(seed) sets initial values to the working area
// of 624 words. Before genrand(), sgenrand(seed) must be
// called once. (seed is any 32-bit integer.)
//   Coded by Takuji Nishimura, considering the suggestions by
// Topher Cooper and Marc Rieffel in July-Aug. 1997.
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Library General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later
// version.
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU Library General Public License for more details.
// You should have received a copy of the GNU Library General
// Public License along with this library; if not, write to the
// Free Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
// 02111-1307  USA
//
// Copyright (C) 1997, 1999 Makoto Matsumoto and Takuji Nishimura.
// Any feedback is very welcome. For any question, comments,
// see http://www.math.keio.ac.jp/matumoto/emt.html or email
// matumoto//math.keio.ac.jp
//
// REFERENCE
// M. Matsumoto and T. Nishimura,
// "Mersenne Twister: A 623-Dimensionally Equidistributed Uniform
// Pseudo-Random Number Generator",
// ACM Transactions on Modeling and Computer Simulation,
// Vol. 8, No. 1, January 1998, pp 3--30.

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
        ldr     wv5, nffff0000
        ldr     wv6, n69069
        mov     w2, #0                 // I=0
    1:
        and     w1, w0, wv5            // A = seed & 0xffff0000
        mul     w0, wv6, w0            // w0 = seed * 69069
        add     w0, w0, #1             // S = R * S + 1
        and     wv2, w0, wv5           // S & 0xffff0000
        lsr     wv2, wv2, #16          // (S & 0xffff0000 >> 16)
        orr     w1, w1, wv2            // A=A|(S & 0xffff0000 >> 16)
        str     w1, [xv3, x2,LSL #2]   // mt[i]=A
        mul     w0, wv6, w0
        add     w0, w0, #1             // S = R * S + 1
        add     w2, w2, #1             // I=I+1
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
n69069:             .long   69069
nffff0000:          .long   0xffff0000
TEMPERING_MASK_B:   .long   0x9d2c5680
TEMPERING_MASK_C:   .long   0xefc60000
UPPER_MASK:         .long   0x80000000
LOWER_MASK:         .long   0x7fffffff
MATRIX_A:           .long   0x9908b0df

.data
mti:                .long   N + 1

.bss
mt:                 .skip   624 * 4
