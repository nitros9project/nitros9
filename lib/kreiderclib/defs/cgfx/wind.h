/* Wind.h - defs for window data structure */

/* window type defs */
#define WT_NBOX 0
#define WT_FWIN 1
#define WT_FSWIN 2
#define WT_SBOX 3
#define WT_DBOX 4
#define WT_PBOX 5

#define MNENBL 1
#define MNDSBL 0
#define WINSYNC 0xc0c0

/* default menu id's */
#define MN_MOVE 1
#define MN_CLOS 2
#define MN_GROW 3
#define MN_USCRL 4
#define MN_DSCRL 5
#define MN_RSCRL 6
#define MN_LSCRL 7
#define MN_TNDY 20
#define MN_FILE 21
#define MN_EDIT 22
#define MN_STYL 23
#define MN_FONT 24

/* window - menu data structures */
typedef struct mistr {  /* menu item descriptor */
 char _mittl[15];       /* name of item */
 char _mienbl;          /* is item available? */
 char _mires[5];        /* reserved */
 } MIDSCR;              /* item descriptor */
typedef struct mnstr {
 char _mnttl[15];       /* name of menu */
 char _mnid,            /* menu id number */
      _mnxsiz,          /* width of menu */
      _mnnits,          /* number of items */
      _mnenabl;         /* is menu available? */
 char _mnres[2];        /* reserved bytes */
 struct mistr* _mnitems; /* pointer to items */
 } MNDSCR;              /* menu descriptor */
typedef struct wnstr {  /* window descriptor */
 char _wnttl[20];       /* title of window */
 char _nmens;           /* number of menus on window */
 char _wxmin,           /* min. window width */
      _wymin;           /* min. window height */
 short _wnsync;         /* synch bytes $C0C0 */
 char _wnres[7];        /* reserved */
 struct mnstr* _wnmen;  /* pointer to menu descriptor's array */
 } WNDSCR;
