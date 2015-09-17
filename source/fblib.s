//-------------------------------------------------------------------------
//  file : fblib.s
//  2015/08/19 Arm64
//  Copyright (C) 2003-2015  Jun Mizutani <mizutani.jun//nifty.ne.jp>
//-------------------------------------------------------------------------

.ifndef __FBLIB
__FBLIB = 1

.ifndef __SYSCALL
.include    "syscalls.s"
.endif

.ifndef O_RDWR
O_RDWR                  = 2
.endif
.ifndef AT_FDCWD
AT_FDCWD                =  -100
.endif

PROT_READ               = 0x1     // page can be read
PROT_WRITE              = 0x2     // page can be written
MAP_SHARED              = 0x01    // Share changes

FBIOGET_VSCREENINFO     = 0x4600
FBIOPUT_VSCREENINFO     = 0x4601
FBIOGET_FSCREENINFO     = 0x4602
FBIOGETCMAP             = 0x4604
FBIOPUTCMAP             = 0x4605

//==============================================================

.text

//-------------------------------------------------------------------------
// open framebuffer device file
//-------------------------------------------------------------------------
fbdev_open:
        stp     x1, x30, [sp, #-16]!
        stp     x2, x3,  [sp, #-16]!
        mov     x0, AT_FDCWD
        adr     x1, fb_device           // open /dev/fb0
        mov     x2, #O_RDWR             // flag
        mov     x3, #0                  // mode
        mov     x8, #sys_openat
        svc     0
        adr     x1, fb_desc
        str     x0, [x1]                // save fd
        cmp     x0, #0
        ldp     x2, x3,  [sp], #16
        ldp     x1, x30, [sp], #16
        ret
fb_device:
        .asciz  "/dev/fb0"

        .align  2
//-------------------------------------------------------------------------
// close framebuffer
//-------------------------------------------------------------------------
fbdev_close:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        ldr     x0, fb_desc
        mov     x8, #sys_close
        svc     0
        tst     x0, x0
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//-------------------------------------------------------------------------
// フレームバッファの物理状態を取得
//-------------------------------------------------------------------------
fb_get_fscreen:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        ldr     x0, fb_desc
        mov     x1, #FBIOGET_FSCREENINFO
        adr     x2, fsc_info            // 保存先指定
        mov     x8, #sys_ioctl
        svc     0
        cmp     x0, #0
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//-------------------------------------------------------------------------
// 現在のフレームバッファの状態を取得
//-------------------------------------------------------------------------
fb_get_screen:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        ldr     x0, fb_desc
        mov     x1, #FBIOGET_VSCREENINFO
        adr     x2, scinfo_save         // 保存先指定
        mov     x8, #sys_ioctl
        svc     0
        cmp     x0, #0
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//-------------------------------------------------------------------------
// フレームバッファ設定を書きこむ
//-------------------------------------------------------------------------
fb_set_screen:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        ldr     x0, fb_desc
        mov     x1, FBIOPUT_VSCREENINFO
        adr     x2, scinfo_data         // 設定済みデータ
        mov     x8, #sys_ioctl
        svc     0
        cmp     x0, #0
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//-------------------------------------------------------------------------
// 保存済みのフレームバッファ設定を新規設定用にコピー
//-------------------------------------------------------------------------
fb_copy_scinfo:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        adr     x0, scinfo_save
        adr     x1, scinfo_data
        ldr     x2, fb_screeninfo_size
   1:   ldr     w3, [x0],#4             // post-indexed addressing
        str     w3, [x1],#4
        subs    x2, x2, #1
        bne     1b
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//-------------------------------------------------------------------------
// フレームバッファメモリをマッピング (3.04.1)
//-------------------------------------------------------------------------
fb_map_screen:
        stp     x1, x30, [sp, #-16]!
        stp     x2, x3,  [sp, #-16]!
        adr     x0, scinfo_save         // screen_info structure
        adr     x6, fb_addr
        ldr     w1, [x0, #+12]          // yres_virtual
        ldr     w2, [x0, #+8]           // xres_virtual
        mul     x1, x2, x1              // x * y
        ldr     w2, [x0, #+24]          // bits_per_pixel
        lsr     x2, x2, #3
        mul     x1, x2, x1              // len = x*y*depth/8
        str     w1, [x6, #+8]           // fb_len
        mov     x0, #0                  // addr
        mov     x2, #(PROT_READ|PROT_WRITE) // prot
        mov     x3, #MAP_SHARED         // flags
        ldr     x4, fb_desc
        mov     x5, #0
        mov     x8, #sys_mmap
        svc     0
        str     x0, [x6]                // fb_addr
        cmp     x0, #0
        bpl     1f
        sub     x1, xzr, x0             // if x0 < 0 then x1 = -x0
        cmp     x1, #255                // if x1 < 255 then error
    1:
        ldp     x2, x3,  [sp], #16
        ldp     x1, x30, [sp], #16
        ret

//-------------------------------------------------------------------------
// フレームバッファメモリをアンマップ
//-------------------------------------------------------------------------
fb_unmap_screen:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        adr     x2, fb_addr
        ldr     x0, [x2]                // adr
        ldr     x1, [x2, #+4]           // len
        mov     x8, #sys_munmap
        svc     0
        tst     x0, x0
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//-------------------------------------------------------------------------
// 保存済みのフレームバッファ設定を復帰
//-------------------------------------------------------------------------
fb_restore_sc:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        ldr     x0, fb_desc
        ldr     x1, =FBIOPUT_VSCREENINFO
        adr     x2, scinfo_save
        mov     x8, #sys_ioctl
        svc     0
        tst     x0, x0
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//-------------------------------------------------------------------------

                    .align   2

fb_screeninfo_size:     .quad   (scinfo_data - scinfo_save)/4

//==============================================================
.bss

fb_desc:                .quad   0
fb_addr:                .quad   0
fb_len:                 .quad   0

scinfo_save:
sis_xres:               .long   0   // visible resolution
sis_yres:               .long   0
sis_xres_virtual:       .long   0   // virtual resolution
sis_yres_virtual:       .long   0
sis_xoffset:            .long   0   // offset from virtual to visible
sis_yoffset:            .long   0   // resolution
sis_bits_per_pixel:     .long   0   // guess what
sis_grayscale:          .long   0   // != 0 Graylevels instead of colors
sis_red_offset:         .long   0   // beginning of bitfield
sis_red_length:         .long   0   // length of bitfield
sis_red_msb_right:      .long   0   // != 0 : Most significant bit is
sis_green_offset:       .long   0   // beginning of bitfield
sis_green_length:       .long   0   // length of bitfield
sis_green_msb_right:    .long   0   // != 0 : Most significant bit is
sis_blue_offset:        .long   0   // beginning of bitfield
sis_blue_length:        .long   0   // length of bitfield
sis_blue_msb_right:     .long   0   // != 0 : Most significant bit is
sis_transp_offset:      .long   0   // beginning of bitfield
sis_transp_length:      .long   0   // length of bitfield
sis_transp_msb_right:   .long   0   // != 0 : Most significant bit is
sis_nonstd:             .long   0   // != 0 Non standard pixel format
sis_activate:           .long   0   // see FB_ACTIVATE_*
sis_height:             .long   0   // height of picture in mm
sis_width:              .long   0   // width of picture in mm
sis_accel_flags:        .long   0   // acceleration flags (hints)
sis_pixclock:           .long   0   // pixel clock in ps (pico seconds)
sis_left_margin:        .long   0   // time from sync to picture
sis_right_margin:       .long   0   // time from picture to sync
sis_upper_margin:       .long   0   // time from sync to picture
sis_lower_margin:       .long   0
sis_hsync_len:          .long   0   // length of horizontal sync
sis_vsync_len:          .long   0   // length of vertical sync
sis_sync:               .long   0   // see FB_SYNC_*
sis_vmode:              .long   0   // see FB_VMODE_*
sis_reserved:           .space  24  // Reserved for future compatibility

scinfo_data:            .skip   (scinfo_data - scinfo_save)

fsc_info:
fsi_id:                 .space  16  //  0 identification string
fsi_smem_start:         .quad   0   // 16 Start of frame buffer mem
fsi_smem_len:           .long   0   // 24 Length of frame buffer mem
fsi_type:               .long   0   // 28 see FB_TYPE_*
fsi_type_aux:           .long   0   // 32 Interleave for interleaved Planes
fsi_visual:             .long   0   // 36 see FB_VISUAL_*
fsi_xpanstep:           .hword  0   // 40 zero if no hardware panning
fsi_ypanstep:           .hword  0   // 42 zero if no hardware panning
fsi_ywrapstep:          .hword  0   // 44 zero if no hardware ywrap
fsi_padding:            .hword  0   // 46 for alignment, jm 1/26/2001
fsi_line_length:        .long   0   // 48 length of a line in bytes
fsi_mmio_start:         .quad   0   // 52 Start of Memory Mapped I/O
fsi_mmio_len:           .long   0   // 60 Length of Memory Mapped I/O
fsi_accel:              .long   0   // 64 Type of acceleration available
fsi_reserved:           .space  8   // Reserved for future compatibility

.endif
