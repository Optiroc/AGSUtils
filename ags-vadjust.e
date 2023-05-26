-> Tool that writes MiSTer video adjust settings

OPT PREPROCESS
OPT OSVERSION=37

MODULE 'dos/dos'
MODULE 'dos/rdargs'

->TODO: Pocket support
->MODULE '*uname'

#define VADJUST_SIZE 1024
#define MISTER_PATH 'MiSTer:vadjust.dat'
#define TEMPLATE 'H=HSHIFT/N,V=VSHIFT/N,S=SCALE/N,JS/K/S'

ENUM
    ERR_ARGS=1,
    ERR_OPEN,
    ERR_WRITE

PROC main() HANDLE
    DEF f = NIL
    DEF rdarg: rdargs
    DEF args[4]: ARRAY OF LONG

    DEF hshift = 0
    DEF vshift = 0
    DEF scale = 0
    DEF sachs = FALSE

    DEF vadjust_dat[VADJUST_SIZE]: ARRAY OF CHAR

    IF ((wbmessage = NIL) AND (rdarg := ReadArgs(TEMPLATE, args, NIL)))
        IF args[0] THEN hshift := Long(args[0])
        IF args[1] THEN vshift := Long(args[1])
        IF args[2] THEN scale := Long(args[2])
        IF args[3] THEN sachs := TRUE
    ELSE
        PrintF('Usage: \s\n', TEMPLATE)
        Raise(ERR_ARGS)
    ENDIF

    PrintF('hshift: \d\n', hshift)
    PrintF('vshift: \d\n', vshift)
    PrintF('scale:  \d\n', scale)
    PrintF('sachs:  \d\n', sachs)

    clear(vadjust_dat)

    IF (f := Open(MISTER_PATH, MODE_NEWFILE)) = NIL THEN Raise(ERR_OPEN)
    IF Write(f, vadjust_dat, VADJUST_SIZE) <> VADJUST_SIZE THEN Raise(ERR_WRITE)

EXCEPT DO
    IF f THEN Close(f)
    IF exception THEN RETURN 21
ENDPROC 0

PROC clear(dat: PTR TO CHAR)
    DEF i
    FOR i := 0 TO VADJUST_SIZE-1
        dat[i] := 0
    ENDFOR
ENDPROC
