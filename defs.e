OPT MODULE
OPT EXPORT
OPT PREPROCESS

#define lb(val) (val AND $000000ff)
#define hb(val) Shr(val AND $0000ff00, 8)
#define lw(val) (val AND $0000ffff)
#define hw(val) Shr(val AND $ffff0000, 16)
