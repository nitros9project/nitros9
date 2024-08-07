/* Buff.h - definitions for standard get/put buffer usage */

/* buffer group numbers */
#define GRP_FONT 200 /* Font group */
#define GRP_CLIP 201 /* Clipboard group (usage not standardized) */
#define GRP_PTR 202 /* Pointer group */
#define GRP_PAT2 203 /* Two color patterns */
#define GRP_PAT4 204 /* Four color patterns */
#define GRP_PAT6 205 /* Sixteen color patterns */

/* font buffers */
#define FNT_S8X8 1 /* Standard 8x8 font (default) */
#define FNT_S6X8 2 /* Standard 6x8 font */
#define FNT_G8X8 3 /* Standard graphics character font */

/* mouse pointer buffers */
#define PTR_ARR 1 /* Arrow */
#define PTR_PEN 2 /* Pencil */
#define PTR_LCH 3 /* Large Cross Hairs */
#define PTR_SLP 4 /* Hourglass (sleep) */
#define PTR_ILL 5 /* Illegal (circle with a slash) */
#define PTR_TXT 6 /* Text */
#define PTR_SCH 7 /* Small Cross Hairs */

/* pattern buffers */
#define PAT_SLD 0 /* Solid (default) */
#define PAT_DOT 1 /* Dots */
#define PAT_VRT 2 /* Vertical lines */
#define PAT_HRZ 3 /* Horizontal lines */
#define PAT_XHTC 4 /* Crosshatch */
#define PAT_LSNT 5 /* Left slanted lines */
#define PAT_RSNT 6 /* Right slanted lines */
#define PAT_SDOT 7 /* Small dots */
#define PAT_BDOT 8 /* BIG dots */

/* logic modes */
#define LOG_NONE 0 /* no logic - just put it there (default) */
#define LOG_AND 1  /* AND the contents of the screen with the data */
#define LOG_OR 2   /* OR the contents of the screen with the data */
#define LOG_XOR 3  /* XOR the contents of the screen with the data */

/* special characters for font FNT_G8X8 */
#define CHR_RGT 0xc1 /* right arrow */
#define CHR_LFT 0xc2 /* left arrow */
#define CHR_DN 0xc3  /* down arrow */
#define CHR_UP 0xc4  /* up arrow */
#define CHR_TRI 0xc5 /* triple bar (for title bar) */
#define CHR_RSZ 0xc6 /* resize box (not used) */
#define CHR_CLZ 0xc7 /* close box */
#define CHR_MOV 0xc8 /* move box */
#define CHR_VBX 0xc9 /* vertical box (for scroll markers) */
#define CHR_HBX 0xca /* horizontal box (for scroll markers) */
#define CHR_HRG 0xcb /* hourglass (Tandy menu) */
#define CHR_TRR 0xcc /* triple bar with open right side */
#define CHR_TRL 0xcd /* triple bar with open left side */

