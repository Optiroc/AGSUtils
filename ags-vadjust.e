-> Tool that writes MiSTer video adjust settings

OPT PREPROCESS
OPT OSVERSION=37

MODULE 'dos/dos'
MODULE 'dos/rdargs'
MODULE '*defs'

->TODO: Destination path as parameter
->TODO: Pocket support

#define MISTER_PATH 'MiSTer:vadjust.dat'
#define TEMPLATE 'H=HSHIFT/N,V=VSHIFT/N,S=SCALE/N,JS/K/S'

CONST VADJUST_SIZE = 1024

ENUM
    ERR_ARGS=1,
    ERR_OPEN,
    ERR_WRITE

OBJECT config
    hshift: LONG
    vshift: LONG
    scale: LONG
    sachs: LONG
ENDOBJECT

CONST BASE_L = 152
CONST BASE_R = 76
CONST PAL4_L = 12
CONST PAL4_R = 0
CONST SACHS_L = 20
CONST SACHS_R = 0

PROC set(data: PTR TO CHAR, index, id, ntsc, laced, hshift, vshift, scale, sachs)
    DEF offset
    DEF l, r, t, b

    -> base values
    IF ntsc
        scale := Bounds(scale, 5, 6)
        SELECT scale
        CASE 5
            l := BASE_L
            r := BASE_R
            t := 16
            b := 10
        CASE 6
            l := BASE_L
            r := BASE_R
            t := 16
            b := 46
        ENDSELECT
    ELSE
        scale := Bounds(scale, 4, 6)
        SELECT scale
        CASE 4
            l := PAL4_L
            r := PAL4_R
            t := 11
            b := 6
        CASE 5
            l := BASE_L
            r := BASE_R
            t := 11
            b := 60
        CASE 6
            l := BASE_L
            r := BASE_R
            t := 11
            b := 96
        ENDSELECT
    ENDIF

    IF (sachs AND (scale = 5))
        l := SACHS_L
        r := SACHS_R
    ENDIF

    -> adjust for interlace
    IF laced
        b := b - 1
    ENDIF

    -> negate right and bottom
    r := 4096 - r
    b := 4096 - b

    -> adjust vertical shift
    IF vshift <> 0
        IF t + vshift < 0 THEN vshift := -t
        IF b + vshift > 4095 THEN vshift := 4095 - b
        t := t + vshift
        b := b + vshift
    ENDIF

    -> TODO: adjust horizontal shift

    -> write values
    offset := Shl(index, 4)
    data[offset + 0] := byte0(id)
    data[offset + 1] := byte1(id)
    data[offset + 2] := byte2(id)
    data[offset + 3] := byte3(id)
    data[offset + 4] := byte0(r)
    data[offset + 5] := byte1(r)
    data[offset + 6] := byte0(l)
    data[offset + 7] := byte1(l)
    data[offset + 8] := byte0(b)
    data[offset + 9] := byte1(b)
    data[offset + 10] := byte0(t)
    data[offset + 11] := byte1(t)
ENDPROC

PROC clear(data: PTR TO CHAR)
    DEF i
    FOR i := 0 TO VADJUST_SIZE-1
        data[i] := 0
    ENDFOR
ENDPROC

PROC argparse(conf:PTR TO config) HANDLE
    DEF args: rdargs
    DEF argv[4]: ARRAY OF LONG
    IF ((wbmessage = NIL) AND (args := ReadArgs(TEMPLATE, argv, NIL)))
        conf.hshift := IF argv[0] THEN Long(argv[0]) ELSE 0
        conf.vshift := IF argv[1] THEN Long(argv[1]) ELSE 0
        conf.scale := IF argv[2] THEN Long(argv[2]) ELSE 0
        conf.sachs := IF argv[3] THEN TRUE ELSE FALSE
    ELSE
        Raise(ERR_ARGS)
    ENDIF
EXCEPT DO
    IF args THEN FreeArgs(args)
    ReThrow()
ENDPROC

PROC main() HANDLE
    DEF conf: config
    DEF data[VADJUST_SIZE]: ARRAY OF CHAR
    DEF f = NIL

    argparse(conf)
    clear(data)

    set(data,  0, $000F25E4, TRUE, FALSE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC LowRes"
    set(data,  1, $000F15E4, TRUE, FALSE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC LowRes--"
    set(data,  2, $010F25E4, TRUE, FALSE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC HiRes"
    set(data,  3, $000F15E4, TRUE, FALSE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC HiRes--"
    set(data,  4, $020F25E4, TRUE, FALSE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC SuperHiRes"
    set(data,  5, $020F15E4, TRUE, FALSE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC SuperHiRes--"
    set(data,  6, $001E35E4, TRUE, TRUE,   conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC LowRes Laced"
    set(data,  7, $001E25E4, TRUE, TRUE,   conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC LowRes Laced--"
    set(data,  8, $011E35E4, TRUE, TRUE,   conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC HiRes Laced"
    set(data,  9, $011E25E4, TRUE, TRUE,   conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC HiRes Laced--"
    set(data, 10, $021E35E4, TRUE, TRUE,   conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC SuperHiRes Laced"
    set(data, 11, $021E25E4, TRUE, TRUE,   conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "NTSC SuperHiRes Laced--"
    set(data, 12, $0011F5E4, FALSE, FALSE, conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL LowRes"
    set(data, 13, $0011E5E4, FALSE, FALSE, conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL LowRes--"
    set(data, 14, $0111F5E4, FALSE, FALSE, conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL HiRes"
    set(data, 15, $0111E5E4, FALSE, FALSE, conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL HiRes--"
    set(data, 16, $0211F5E4, FALSE, FALSE, conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL SuperHiRes"
    set(data, 17, $0211E5E4, FALSE, FALSE, conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL SuperHiRes--"
    set(data, 18, $0023D5E4, FALSE, TRUE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL LowRes Laced"
    set(data, 19, $0023C5E4, FALSE, TRUE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL LowRes Laced--"
    set(data, 20, $0123D5E4, FALSE, TRUE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL HiRes Laced"
    set(data, 21, $0123C5E4, FALSE, TRUE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL HiRes Laced--"
    set(data, 22, $0223D5E4, FALSE, TRUE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL SuperHiRes Laced"
    set(data, 23, $0223C5E4, FALSE, TRUE,  conf.hshift, conf.vshift, conf.scale, conf.sachs) -> "PAL SuperHiRes Laced--"

    IF (f := Open(MISTER_PATH, MODE_NEWFILE)) = NIL THEN Raise(ERR_OPEN)
    IF Write(f, data, VADJUST_SIZE) <> VADJUST_SIZE THEN Raise(ERR_WRITE)
EXCEPT DO
    IF f THEN Close(f)
    IF exception = ERR_ARGS THEN PrintF('error: wrong parameters\nusage: \s\n', TEMPLATE)
    IF exception THEN RETURN 21
ENDPROC 0
