-> Tool that detects the system type and prints the result to stdout

OPT PREPROCESS
OPT OSVERSION=33

MODULE '*uname'

PROC main()
    DEF name
    name := uname()

    SELECT name
    CASE AGSUNAME_AMIGA
        PrintF('amiga')
    CASE AGSUNAME_UAE
        PrintF('uae')
    CASE AGSUNAME_MISTER
        PrintF('mister')
    CASE AGSUNAME_POCKET
        PrintF('pocket')
    ENDSELECT

ENDPROC name
