//=========================================================================
// file : signal.s
//=========================================================================
.ifndef __SIGNAL
__SIGNAL = 1

NSIG      =  32

SIGHUP    =   1
SIGINT    =   2
SIGQUIT   =   3
SIGILL    =   4
SIGTRAP   =   5
SIGABRT   =   6
SIGIOT    =   6
SIGBUS    =   7
SIGFPE    =   8
SIGKILL   =   9
SIGUSR1   =  10
SIGSEGV   =  11
SIGUSR2   =  12
SIGPIPE   =  13
SIGALRM   =  14
SIGTERM   =  15
SIGSTKFLT =  16
SIGCHLD   =  17
SIGCONT   =  18
SIGSTOP   =  19
SIGTSTP   =  20
SIGTTIN   =  21
SIGTTOU   =  22
SIGURG    =  23
SIGXCPU   =  24
SIGXFSZ   =  25
SIGVTALRM =  26
SIGPROF   =  27
SIGWINCH  =  28
SIGIO     =  29
SIGPOLL   =  SIGIO
//
SIGLOST   =  29

SIGPWR    =  30
SIGUNUSED =  31

// These should not be considered constants from userland.
SIGRTMIN  =  32
SIGRTMAX  =  31  // (NSIG-1)

SA_NOCLDSTOP    =  0x00000001
SA_NOCLDWAIT    =  0x00000002 // not supported yet
SA_SIGINFO      =  0x00000004
SA_ONSTACK      =  0x08000000
SA_RESTART      =  0x10000000
SA_NODEFER      =  0x40000000
SA_RESETHAND    =  0x80000000

SA_NOMASK       =  SA_NODEFER
SA_ONESHOT      =  SA_RESETHAND
SA_INTERRUPT    =  0x20000000 // dummy -- ignored

SA_RESTORER     =  0x04000000

// * sigaltstack controls

SS_ONSTACK      = 1
SS_DISABLE      = 2

MINSIGSTKSZ     = 2048
SIGSTKSZ        = 8192

SIG_BLOCK       = 0   // for blocking signals
SIG_UNBLOCK     = 1   // for unblocking signals
SIG_SETMASK     = 2   // for setting the signal mask

SIG_DFL         = 0   // default signal handling
SIG_IGN         = 1   // ignore signal
SIG_ERR         = -1  // error return from signal

/*
sigaltstack:
    ss_sp:          .quad   0   //
    ss_flags:       .quad   0   //
    ss_size:        .quad   0   //

sigaction:
    sa_sighandler:  .quad   0   //
    sa_mask:        .quad   0   //
    sa_flags:       .quad   0   //
    sa_restorer:    .quad   0   //
*/
.endif
