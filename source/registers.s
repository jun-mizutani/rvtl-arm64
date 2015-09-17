// ------------------------------------------------------------------------
// Aliases of Arm64 Registers for ARM64
//   2015/07/30
// Copyright (C) 2015  Jun Mizutani <mizutani.jun@nifty.ne.jp>
// stdio.s may be copied under the terms of the GNU General Public License.
// ------------------------------------------------------------------------

.ifndef __REGALIAS
__REGALIAS = 1

xv1     .req   x9       // char from GetChar
xv2     .req   x10      // 行先頭アドレス
xv3     .req   x11      // next char position
xv4     .req   x12      // 変数アドレス
xv5     .req   x13      // EOL フラグ
xv6     .req   x14      // 変数スタックポインタ
xv7     .req   x15      // 未使用
xv8     .req   x16      // 未使用

wv1     .req   w9       // 32bit
wv2     .req   w10      //
wv3     .req   w11      //
wv4     .req   w12      //
wv5     .req   w13      //
wv6     .req   w14      //
wv7     .req   w15      //
wv8     .req   w16      //

rv1     .req   x20      // Input Buffer
rv2     .req   x21      // BufferSize
rv3     .req   x22      // history string ptr, FNBPointer
rv4     .req   x23      // 行末位置    (0..r21-1)
rv5     .req   x24      // current position (0..r21-1)  memory address[r20+r24]
rv6     .req   x25      // DirName
rv7     .req   x26      // FNArray ファイル名へのポインタ配列(FileCompletion)
rv8     .req   x27      // PartialName 入力バッファ内へのポインタ

xVar    .req   x29      // VarArea 先頭アドレス

xip     .req   x17      // 作業用
wip     .req   w17      // 作業用

.endif

