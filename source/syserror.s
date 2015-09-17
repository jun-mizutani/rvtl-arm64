//-------------------------------------------------------------------------
// file    : syserror.s
//  2015/08/30
// comment : derived from linux-4.1.2/include/uapi/asm-generic/errorno.h
// Copyright (C) 2015 Jun Mizutani <mizutani.jun@nifty.ne.jp>
//-------------------------------------------------------------------------

.include        "errorno.s"

.ifndef __SYSERR_INC
__SYSERR_INC = 1

//==============================================================
.text

SysCallError:
        stp     x0, x30, [sp, #-16]!
        stp     x1, x2,  [sp, #-16]!
        stp     x3, x4,  [sp, #-16]!
        stp     x5, x6,  [sp, #-16]!
        mrs     x4, nzcv
        tst     x0, x0
        bpl     3f
        sub     x0, xzr, x0
        mov     x1, x0
        adr     x2, sys_error_end
        adr     x3, sys_error_tbl
    1:
        ldr     x5, [x3]
        cmp     x1, x5
        beq     2f
        add     x3, x3, #16
        cmp     x3, x2
        bne     1b
        b       3f
    2:
        ldr     x0, [x3, #8]
        bl      OutAsciiZ
        bl      NewLine
    3:
        msr     nzcv, x4
        ldp     x5, x6,  [sp], #16
        ldp     x3, x4,  [sp], #16
        ldp     x1, x2,  [sp], #16
        ldp     x0, x30, [sp], #16
        ret

//==============================================================
.data
        .align 3
sys_error_tbl:
        .quad   EPERM           , msg_EPERM
        .quad   ENOENT          , msg_ENOENT
        .quad   ESRCH           , msg_ESRCH
        .quad   EINTR           , msg_EINTR
        .quad   EIO             , msg_EIO
        .quad   ENXIO           , msg_ENXIO
        .quad   E2BIG           , msg_E2BIG
        .quad   ENOEXEC         , msg_ENOEXEC
        .quad   EBADF           , msg_EBADF
        .quad   ECHILD          , msg_ECHILD
        .quad   EAGAIN          , msg_EAGAIN
        .quad   ENOMEM          , msg_ENOMEM
        .quad   EACCES          , msg_EACCES
        .quad   EFAULT          , msg_EFAULT
        .quad   ENOTBLK         , msg_ENOTBLK
        .quad   EBUSY           , msg_EBUSY
        .quad   EEXIST          , msg_EEXIST
        .quad   EXDEV           , msg_EXDEV
        .quad   ENODEV          , msg_ENODEV
        .quad   ENOTDIR         , msg_ENOTDIR
        .quad   EISDIR          , msg_EISDIR
        .quad   EINVAL          , msg_EINVAL
        .quad   ENFILE          , msg_ENFILE
        .quad   EMFILE          , msg_EMFILE
        .quad   ENOTTY          , msg_ENOTTY
        .quad   ETXTBSY         , msg_ETXTBSY
        .quad   EFBIG           , msg_EFBIG
        .quad   ENOSPC          , msg_ENOSPC
        .quad   ESPIPE          , msg_ESPIPE
        .quad   EROFS           , msg_EROFS
        .quad   EMLINK          , msg_EMLINK
        .quad   EPIPE           , msg_EPIPE
        .quad   EDOM            , msg_EDOM
        .quad   ERANGE          , msg_ERANGE
        .quad   EDEADLK         , msg_EDEADLK
        .quad   ENAMETOOLONG    , msg_ENAMETOOLONG
        .quad   ENOLCK          , msg_ENOLCK
        .quad   ENOSYS          , msg_ENOSYS
        .quad   ENOTEMPTY       , msg_ENOTEMPTY
        .quad   ELOOP           , msg_ELOOP
        .quad   EWOULDBLOCK     , msg_EWOULDBLOCK
        .quad   ENOMSG          , msg_ENOMSG
        .quad   EIDRM           , msg_EIDRM
        .quad   ECHRNG          , msg_ECHRNG
        .quad   EL2NSYNC        , msg_EL2NSYNC
        .quad   EL3HLT          , msg_EL3HLT
        .quad   EL3RST          , msg_EL3RST
        .quad   ELNRNG          , msg_ELNRNG
        .quad   EUNATCH         , msg_EUNATCH
        .quad   ENOCSI          , msg_ENOCSI
        .quad   EL2HLT          , msg_EL2HLT
        .quad   EBADE           , msg_EBADE
        .quad   EBADR           , msg_EBADR
        .quad   EXFULL          , msg_EXFULL
        .quad   ENOANO          , msg_ENOANO
        .quad   EBADRQC         , msg_EBADRQC
        .quad   EBADSLT         , msg_EBADSLT
//        .quad   EDEADLOCK       , msg_EDEADLOCK
        .quad   EBFONT          , msg_EBFONT
        .quad   ENOSTR          , msg_ENOSTR
        .quad   ENODATA         , msg_ENODATA
        .quad   ETIME           , msg_ETIME
        .quad   ENOSR           , msg_ENOSR
        .quad   ENONET          , msg_ENONET
        .quad   ENOPKG          , msg_ENOPKG
        .quad   EREMOTE         , msg_EREMOTE
        .quad   ENOLINK         , msg_ENOLINK
        .quad   EADV            , msg_EADV
        .quad   ESRMNT          , msg_ESRMNT
        .quad   ECOMM           , msg_ECOMM
        .quad   EPROTO          , msg_EPROTO
        .quad   EMULTIHOP       , msg_EMULTIHOP
        .quad   EDOTDOT         , msg_EDOTDOT
        .quad   EBADMSG         , msg_EBADMSG
        .quad   EOVERFLOW       , msg_EOVERFLOW
        .quad   ENOTUNIQ        , msg_ENOTUNIQ
        .quad   EBADFD          , msg_EBADFD
        .quad   EREMCHG         , msg_EREMCHG
        .quad   ELIBACC         , msg_ELIBACC
        .quad   ELIBBAD         , msg_ELIBBAD
        .quad   ELIBSCN         , msg_ELIBSCN
        .quad   ELIBMAX         , msg_ELIBMAX
        .quad   ELIBEXEC        , msg_ELIBEXEC
        .quad   EILSEQ          , msg_EILSEQ
        .quad   ERESTART        , msg_ERESTART
        .quad   ESTRPIPE        , msg_ESTRPIPE
        .quad   EUSERS          , msg_EUSERS
        .quad   ENOTSOCK        , msg_ENOTSOCK
        .quad   EDESTADDRREQ    , msg_EDESTADDRREQ
        .quad   EMSGSIZE        , msg_EMSGSIZE
        .quad   EPROTOTYPE      , msg_EPROTOTYPE
        .quad   ENOPROTOOPT     , msg_ENOPROTOOPT
        .quad   EPROTONOSUPPORT , msg_EPROTONOSUPPORT
        .quad   ESOCKTNOSUPPORT , msg_ESOCKTNOSUPPORT
        .quad   EOPNOTSUPP      , msg_EOPNOTSUPP
        .quad   EPFNOSUPPORT    , msg_EPFNOSUPPORT
        .quad   EAFNOSUPPORT    , msg_EAFNOSUPPORT
        .quad   EADDRINUSE      , msg_EADDRINUSE
        .quad   EADDRNOTAVAIL   , msg_EADDRNOTAVAIL
        .quad   ENETDOWN        , msg_ENETDOWN
        .quad   ENETUNREACH     , msg_ENETUNREACH
        .quad   ENETRESET       , msg_ENETRESET
        .quad   ECONNABORTED    , msg_ECONNABORTED
        .quad   ECONNRESET      , msg_ECONNRESET
        .quad   ENOBUFS         , msg_ENOBUFS
        .quad   EISCONN         , msg_EISCONN
        .quad   ENOTCONN        , msg_ENOTCONN
        .quad   ESHUTDOWN       , msg_ESHUTDOWN
        .quad   ETOOMANYREFS    , msg_ETOOMANYREFS
        .quad   ETIMEDOUT       , msg_ETIMEDOUT
        .quad   ECONNREFUSED    , msg_ECONNREFUSED
        .quad   EHOSTDOWN       , msg_EHOSTDOWN
        .quad   EHOSTUNREACH    , msg_EHOSTUNREACH
        .quad   EALREADY        , msg_EALREADY
        .quad   EINPROGRESS     , msg_EINPROGRESS
        .quad   ESTALE          , msg_ESTALE
        .quad   EUCLEAN         , msg_EUCLEAN
        .quad   ENOTNAM         , msg_ENOTNAM
        .quad   ENAVAIL         , msg_ENAVAIL
        .quad   EISNAM          , msg_EISNAM
        .quad   EREMOTEIO       , msg_EREMOTEIO
        .quad   EDQUOT          , msg_EDQUOT
        .quad   ENOMEDIUM       , msg_ENOMEDIUM
        .quad   EMEDIUMTYPE     , msg_EMEDIUMTYPE
        .quad   ECANCELED       , msg_ECANCELED
        .quad   ENOKEY          , msg_ENOKEY
        .quad   EKEYEXPIRED     , msg_EKEYEXPIRED
        .quad   EKEYREVOKED     , msg_EKEYREVOKED
        .quad   EKEYREJECTED    , msg_EKEYREJECTED
        .quad   EOWNERDEAD      , msg_EOWNERDEAD
        .quad   ENOTRECOVERABLE , msg_ENOTRECOVERABLE
        .quad   ERFKILL         , msg_ERFKILL
        .quad   EHWPOISON       , msg_EHWPOISON

sys_error_end:

                     .align 3
msg_EPERM:           .asciz "[EPERM] Operation not permitted"
msg_ENOENT:          .asciz "[ENOENT] No such file or directory"
msg_ESRCH:           .asciz "[ESRCH] No such process"
msg_EINTR:           .asciz "[EINTR] Interrupted system call"
msg_EIO:             .asciz "[EIO] I/O error"
msg_ENXIO:           .asciz "[ENXIO] No such device or address"
msg_E2BIG:           .asciz "[E2BIG] Argument list too long"
msg_ENOEXEC:         .asciz "[ENOEXEC] Exec format error"
msg_EBADF:           .asciz "[EBADF] Bad file number"
msg_ECHILD:          .asciz "[ECHILD] No child processes"
msg_EAGAIN:          .asciz "[EAGAIN] Try again"
msg_ENOMEM:          .asciz "[ENOMEM] Out of memory"
msg_EACCES:          .asciz "[EACCES] Permission denied"
msg_EFAULT:          .asciz "[EFAULT] Bad address"
msg_ENOTBLK:         .asciz "[ENOTBLK] Block device required"
msg_EBUSY:           .asciz "[EBUSY] Device or resource busy"
msg_EEXIST:          .asciz "[EEXIST] File exists"
msg_EXDEV:           .asciz "[EXDEV] Cross-device link"
msg_ENODEV:          .asciz "[ENODEV] No such device"
msg_ENOTDIR:         .asciz "[ENOTDIR] Not a directory"
msg_EISDIR:          .asciz "[EISDIR] Is a directory"
msg_EINVAL:          .asciz "[EINVAL] Invalid argument"
msg_ENFILE:          .asciz "[ENFILE] File table overflow"
msg_EMFILE:          .asciz "[EMFILE] Too many open files"
msg_ENOTTY:          .asciz "[ENOTTY] Not a typewriter"
msg_ETXTBSY:         .asciz "[ETXTBSY] Text file busy"
msg_EFBIG:           .asciz "[EFBIG] File too large"
msg_ENOSPC:          .asciz "[ENOSPC] No space left on device"
msg_ESPIPE:          .asciz "[ESPIPE] Illegal seek"
msg_EROFS:           .asciz "[EROFS] Read-only file system"
msg_EMLINK:          .asciz "[EMLINK] Too many links"
msg_EPIPE:           .asciz "[EPIPE] Broken pipe"
msg_EDOM:            .asciz "[EDOM] Math argument out of domain of func"
msg_ERANGE:          .asciz "[ERANGE] Math result not representable"
msg_EDEADLK:         .asciz "[EDEADLK] Resource deadlock would occur"
msg_ENAMETOOLONG:    .asciz "[ENAMETOOLONG] File name too long"
msg_ENOLCK:          .asciz "[ENOLCK] No record locks available"
msg_ENOSYS:          .asciz "[ENOSYS] Invalid system call number"
msg_ENOTEMPTY:       .asciz "[ENOTEMPTY] Directory not empty"
msg_ELOOP:           .asciz "[ELOOP] Too many symbolic links encountered"
msg_EWOULDBLOCK:     .asciz "[EWOULDBLOCK]      // Operation would block"
msg_ENOMSG:          .asciz "[ENOMSG] No message of desired type"
msg_EIDRM:           .asciz "[EIDRM] Identifier removed"
msg_ECHRNG:          .asciz "[ECHRNG] Channel number out of range"
msg_EL2NSYNC:        .asciz "[EL2NSYNC] Level 2 not synchronized"
msg_EL3HLT:          .asciz "[EL3HLT] Level 3 halted"
msg_EL3RST:          .asciz "[EL3RST] Level 3 reset"
msg_ELNRNG:          .asciz "[ELNRNG] Link number out of range"
msg_EUNATCH:         .asciz "[EUNATCH] Protocol driver not attached"
msg_ENOCSI:          .asciz "[ENOCSI] No CSI structure available"
msg_EL2HLT:          .asciz "[EL2HLT] Level 2 halted"
msg_EBADE:           .asciz "[EBADE] Invalid exchange"
msg_EBADR:           .asciz "[EBADR] Invalid request descriptor"
msg_EXFULL:          .asciz "[EXFULL] Exchange full"
msg_ENOANO:          .asciz "[ENOANO] No anode"
msg_EBADRQC:         .asciz "[EBADRQC] Invalid request code"
msg_EBADSLT:         .asciz "[EBADSLT] Invalid slot"
msg_EBFONT:          .asciz "[EBFONT] Bad font file format"
msg_ENOSTR:          .asciz "[ENOSTR] Device not a stream"
msg_ENODATA:         .asciz "[ENODATA] No data available"
msg_ETIME:           .asciz "[ETIME] Timer expired"
msg_ENOSR:           .asciz "[ENOSR] Out of streams resources"
msg_ENONET:          .asciz "[ENONET] Machine is not on the network"
msg_ENOPKG:          .asciz "[ENOPKG] Package not installed"
msg_EREMOTE:         .asciz "[EREMOTE] Object is remote"
msg_ENOLINK:         .asciz "[ENOLINK] Link has been severed"
msg_EADV:            .asciz "[EADV] Advertise error"
msg_ESRMNT:          .asciz "[ESRMNT] Srmount error"
msg_ECOMM:           .asciz "[ECOMM] Communication error on send"
msg_EPROTO:          .asciz "[EPROTO] Protocol error"
msg_EMULTIHOP:       .asciz "[EMULTIHOP] Multihop attempted"
msg_EDOTDOT:         .asciz "[EDOTDOT] RFS specific error"
msg_EBADMSG:         .asciz "[EBADMSG] Not a data message"
msg_EOVERFLOW:       .asciz "[EOVERFLOW] Value too large for defined data type"
msg_ENOTUNIQ:        .asciz "[ENOTUNIQ] Name not unique on network"
msg_EBADFD:          .asciz "[EBADFD] File descriptor in bad state"
msg_EREMCHG:         .asciz "[EREMCHG] Remote address changed"
msg_ELIBACC:         .asciz "[ELIBACC] Can not access a needed shared library"
msg_ELIBBAD:         .asciz "[ELIBBAD] Accessing a corrupted shared library"
msg_ELIBSCN:         .asciz "[ELIBSCN] .lib section in a.out corrupted"
msg_ELIBMAX:         .asciz "[ELIBMAX] Attempting to link in too many shared libraries"
msg_ELIBEXEC:        .asciz "[ELIBEXEC] Cannot exec a shared library directly"
msg_EILSEQ:          .asciz "[EILSEQ] Illegal byte sequence"
msg_ERESTART:        .asciz "[ERESTART] Interrupted system call should be restarted"
msg_ESTRPIPE:        .asciz "[ESTRPIPE] Streams pipe error"
msg_EUSERS:          .asciz "[EUSERS] Too many users"
msg_ENOTSOCK:        .asciz "[ENOTSOCK] Socket operation on non-socket"
msg_EDESTADDRREQ:    .asciz "[EDESTADDRREQ] Destination address required"
msg_EMSGSIZE:        .asciz "[EMSGSIZE] Message too long"
msg_EPROTOTYPE:      .asciz "[EPROTOTYPE] Protocol wrong type for socket"
msg_ENOPROTOOPT:     .asciz "[ENOPROTOOPT] Protocol not available"
msg_EPROTONOSUPPORT: .asciz "[EPROTONOSUPPORT]Protocol not supported"
msg_ESOCKTNOSUPPORT: .asciz "[ESOCKTNOSUPPORT]Socket type not supported"
msg_EOPNOTSUPP:      .asciz "[EOPNOTSUPP] Operation not supported on transport endpoint"
msg_EPFNOSUPPORT:    .asciz "[EPFNOSUPPORT] Protocol family not supported"
msg_EAFNOSUPPORT:    .asciz "[EAFNOSUPPORT] Address family not supported by protocol"
msg_EADDRINUSE:      .asciz "[EADDRINUSE] Address already in use"
msg_EADDRNOTAVAIL:   .asciz "[EADDRNOTAVAIL] Cannot assign requested address"
msg_ENETDOWN:        .asciz "[ENETDOWN] Network is down"
msg_ENETUNREACH:     .asciz "[ENETUNREACH] Network is unreachable"
msg_ENETRESET:       .asciz "[ENETRESET] Network dropped connection because of reset"
msg_ECONNABORTED:    .asciz "[ECONNABORTED] Software caused connection abort"
msg_ECONNRESET:      .asciz "[ECONNRESET] Connection reset by peer"
msg_ENOBUFS:         .asciz "[ENOBUFS] No buffer space available"
msg_EISCONN:         .asciz "[EISCONN] Transport endpoint is already connected"
msg_ENOTCONN:        .asciz "[ENOTCONN] Transport endpoint is not connected"
msg_ESHUTDOWN:       .asciz "[ESHUTDOWN] Cannot send after transport endpoint shutdown"
msg_ETOOMANYREFS:    .asciz "[ETOOMANYREFS] Too many references: cannot splice"
msg_ETIMEDOUT:       .asciz "[ETIMEDOUT] Connection timed out"
msg_ECONNREFUSED:    .asciz "[ECONNREFUSED] Connection refused"
msg_EHOSTDOWN:       .asciz "[EHOSTDOWN] Host is down"
msg_EHOSTUNREACH:    .asciz "[EHOSTUNREACH] No route to host"
msg_EALREADY:        .asciz "[EALREADY] Operation already in progress"
msg_EINPROGRESS:     .asciz "[EINPROGRESS] Operation now in progress"
msg_ESTALE:          .asciz "[ESTALE] Stale file handle"
msg_EUCLEAN:         .asciz "[EUCLEAN] Structure needs cleaning"
msg_ENOTNAM:         .asciz "[ENOTNAM] Not a XENIX named type file"
msg_ENAVAIL:         .asciz "[ENAVAIL] No XENIX semaphores available"
msg_EISNAM:          .asciz "[EISNAM] Is a named type file"
msg_EREMOTEIO:       .asciz "[EREMOTEIO] Remote I/O error"
msg_EDQUOT:          .asciz "[EDQUOT] Quota exceeded"
msg_ENOMEDIUM:       .asciz "[ENOMEDIUM] No medium found"
msg_EMEDIUMTYPE:     .asciz "[EMEDIUMTYPE] Wrong medium type"
msg_ECANCELED:       .asciz "[ECANCELED] Operation Canceled"
msg_ENOKEY:          .asciz "[ENOKEY] Required key not available"
msg_EKEYEXPIRED:     .asciz "[EKEYEXPIRED] Key has expired"
msg_EKEYREVOKED:     .asciz "[EKEYREVOKED] Key has been revoked"
msg_EKEYREJECTED:    .asciz "[EKEYREJECTED] Key was rejected by service"
msg_EOWNERDEAD:      .asciz "[EOWNERDEAD] Owner died"
msg_ENOTRECOVERABLE: .asciz "[ENOTRECOVERABLE]State not recoverable"
msg_ERFKILL:         .asciz "[ERFKILL] Operation not possible due to RF-kill"
msg_EHWPOISON:       .asciz "[EHWPOISON] Memory page has hardware error"

                     .align 3
.endif
