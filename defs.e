OPT MODULE,EXPORT,PREPROCESS

#define lb(val) (val AND $000000ff)
#define hb(val) Shr(val AND $0000ff00, 8)
#define lw(val) (val AND $0000ffff)
#define hw(val) Shr(val AND $ffff0000, 16)

#define byte0(val) (val AND $000000ff)
#define byte1(val) Shr(val AND $0000ff00, 8)
#define byte2(val) Shr(val AND $00ff0000, 16)
#define byte3(val) Shr(val AND $ff000000, 24)
