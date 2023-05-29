-> Module for system type detection

OPT MODULE
OPT PREPROCESS

MODULE 'expansion'
MODULE '*defs'

EXPORT ENUM
    AGSUNAME_AMIGA = 1,
    AGSUNAME_UAE,
    AGSUNAME_MISTER,
    AGSUNAME_POCKET

EXPORT PROC uname()
    DEF addr, val

    -> Check MiSTer/Pocket RTG ID register
    addr := $b8010e
    val := hw(^addr)
    IF val = $5001 THEN RETURN AGSUNAME_MISTER
    IF val = $6001 THEN RETURN AGSUNAME_POCKET

    -> Check UAE device
    IF (expansionbase := OpenLibrary('expansion.library', 0))
      val := (IF FindConfigDev(NIL, 2011, -1) THEN TRUE ELSE FALSE)
      CloseLibrary(expansionbase)
    ENDIF

    RETURN (IF val THEN AGSUNAME_UAE ELSE AGSUNAME_AMIGA)
ENDPROC
