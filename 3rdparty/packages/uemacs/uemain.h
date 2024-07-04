/* Main header */

#ifdef MAINTABLE
int  currow;       /* Working cursor row   */
int  curcol;       /* Working cursor column  */
int  fillcol;      /* Current fill column  */
int  thisflag;      /* Flags, this command  */
int  lastflag;      /* Flags, last command  */
int  curgoal;      /* Goal column    */
BUFFER *curbp;       /* Current buffer    */
WINDOW *curwp;       /* Current window    */
BUFFER *bheadp;      /* BUFFER listhead   */
WINDOW *wheadp;      /* WINDOW listhead   */
BUFFER *blistp;      /* Buffer list BUFFER   */
short kbdm[NKBDM] = {CTLX|')'};  /* Macro      */
short *kbdmip;      /* Input for above   */
short *kbdmop;      /* Output for above   */
char pat[NPAT];      /* Pattern     */
#else
extern int  currow;       /* Working cursor row   */
extern int  curcol;       /* Working cursor column  */
extern int  fillcol;      /* Current fill column  */
extern int  thisflag;      /* Flags, this command  */
extern int  lastflag;      /* Flags, last command  */
extern int  curgoal;      /* Goal column    */
extern BUFFER *curbp;       /* Current buffer    */
extern WINDOW *curwp;       /* Current window    */
extern BUFFER *bheadp;      /* BUFFER listhead   */
extern WINDOW *wheadp;      /* WINDOW listhead   */
extern BUFFER *blistp;      /* Buffer list BUFFER   */
extern short kbdm[];        /* Macro      */
extern short *kbdmip;      /* Input for above   */
extern short *kbdmop;      /* Output for above   */
extern char pat[];      /* Pattern     */
#endif

typedef struct {
  short k_code;     /* Key code      */
  int (*k_fp)();    /* Routine to handle it   */
}  KEYTAB;

/*
 * Command table.
 * This table is *roughly* in ASCII order, left to right across the
 * characters of the command. This expains the funny location of the
 * control-X commands.
 */
#ifdef MAINTABLE

extern      int ctrlg();                /* Abort out of things          */
extern      int quit();                 /* Quit                         */
extern      int ctlxlp();               /* Begin macro                  */
extern      int ctlxrp();               /* End macro                    */
extern     int  ctlxe();                /* Execute macro                */
extern     int  fileread();             /* Get a file, read only        */
extern     int  filevisit();            /* Get a file, read write       */
extern     int  filewrite();            /* Write a file                 */
extern     int  filesave();             /* Save current file            */
extern     int  filename();             /* Adjust file name             */
extern     int  getccol();              /* Get current column           */
extern     int  gotobol();              /* Move to start of line        */
extern     int  forwchar();             /* Move forward by characters   */
extern     int  gotoeol();              /* Move to end of line          */
extern     int  backchar();             /* Move backward by characters  */
extern     int  forwline();             /* Move forward by lines        */
extern     int  backline();             /* Move backward by lines       */
extern     int  forwpage();             /* Move forward by pages        */
extern     int  backpage();             /* Move backward by pages       */
extern     int  gotobob();              /* Move to start of buffer      */
extern     int  gotoeob();              /* Move to end of buffer        */
extern     int  setfillcol();           /* Set fill column.             */
extern     int  setmark();              /* Set mark                     */
extern     int  swapmark();             /* Swap "." and mark            */
extern     int  forwsearch();           /* Search forward               */
extern     int  backsearch();           /* Search backwards             */
extern     int  showcpos();             /* Show the cursor position     */
#ifndef OS9
extern     int  nextwind();             /* Move to the next window      */
extern     int  prevwind();             /* Move to the previous window  */
extern     int  onlywind();             /* Make current window only one */
extern     int  splitwind();            /* Split current window         */
extern     int  mvdnwind();             /* Move window down             */
extern     int  mvupwind();             /* Move window up               */
extern     int  enlargewind();          /* Enlarge display window.      */
extern     int  shrinkwind();           /* Shrink window.               */
extern     int  listbuffers();          /* Display list of buffers      */
extern     int  usebuffer();            /* Switch a window to a buffer  */
extern     int  killbuffer();           /* Make a buffer go away.       */
#endif
extern     int  reposition();           /* Reposition window            */
extern     int  refresh();              /* Refresh the screen           */
extern     int  twiddle();              /* Twiddle characters           */
extern     int  tab();                  /* Insert tab                   */
extern     int  newline();              /* Insert CR-LF                 */
extern     int  indent();               /* Insert CR-LF, then indent    */
extern     int  openline();             /* Open up a blank line         */
extern     int  deblank();              /* Delete blank lines           */
extern     int  quote();                /* Insert literal               */
extern     int  backword();             /* Backup by words              */
extern     int  forwword();             /* Advance by words             */
extern     int  forwdel();              /* Forward delete               */
extern     int  backdel();              /* Backward delete              */
extern     int  killer();               /* Kill forward                 */
extern     int  yank();                 /* Yank back from killbuffer.   */
extern     int  upperword();            /* Upper case word.             */
extern     int  lowerword();            /* Lower case word.             */
extern     int  upperregion();          /* Upper case region.           */
extern     int  lowerregion();          /* Lower case region.           */
extern     int  capword();              /* Initial capitalize word.     */
extern     int  delfword();             /* Delete forward word.         */
extern     int  delbword();             /* Delete backward word.        */
extern     int  killregion();           /* Kill region.                 */
extern     int  copyregion();           /* Copy region to kill buffer.  */
extern     int  spawncli();             /* Run CLI in a subjob.         */
extern     int  spawn();                /* Run a command in a subjob.   */
extern     int  quickexit();            /* low keystroke style exit.    */

KEYTAB keytab[] = {
  {CTRL|'@',    setmark},
  {CTRL|'A',    gotobol},
  {CTRL|'B',    backchar},
  {CTRL|'C',    spawncli},  /* Run CLI in subjob. */
  {CTRL|'D',    forwdel},
  {CTRL|'E',    gotoeol},
  {CTRL|'F',    forwchar},
  {CTRL|'G',    ctrlg},
  {CTRL|'H',    backdel},
  {CTRL|'I',    tab},
  {CTRL|'J',    indent},
  {CTRL|'K',    killer},
  {CTRL|'L',    refresh},
  {CTRL|'M',    newline},
  {CTRL|'N',    forwline},
  {CTRL|'O',    openline},
  {CTRL|'P',    backline},
  {CTRL|'Q',    quote},   /* Often unreachable */
  {CTRL|'R',    backsearch},
  {CTRL|'S',    forwsearch}, /* Often unreachable */
  {CTRL|'T',    twiddle},
  {CTRL|'V',    forwpage},
  {CTRL|'W',    killregion},
  {CTRL|'Y',    yank},
  {CTRL|'Z',    quickexit},  /* quick save and exit */
#ifndef OS9
  {CTLX|CTRL|'B',   listbuffers},
#endif
  {CTLX|CTRL|'C',   quit},   /* Hard quit.   */
  {CTLX|CTRL|'F',   filename},
  {CTLX|CTRL|'L',   lowerregion},
  {CTLX|CTRL|'O',   deblank},
#ifndef OS9
  {CTLX|CTRL|'N',   mvdnwind},
  {CTLX|CTRL|'P',   mvupwind},
#endif
  {CTLX|CTRL|'R',   fileread},
  {CTLX|CTRL|'S',   filesave},  /* Often unreachable */
  {CTLX|CTRL|'U',   upperregion},
#ifndef OS9
  {CTLX|CTRL|'V',   filevisit},
#endif
  {CTLX|CTRL|'W',   filewrite},
  {CTLX|CTRL|'X',   swapmark},
#ifndef OS9
  {CTLX|CTRL|'Z',   shrinkwind},
#endif
  {CTLX|'!',    spawn},   /* Run 1 command.  */
  {CTLX|'=',    showcpos},
  {CTLX|'(',    ctlxlp},
  {CTLX|')',    ctlxrp},
#ifndef OS9
  {CTLX|'1',    onlywind},
  {CTLX|'2',    splitwind},
  {CTLX|'B',    usebuffer},
#endif
  {CTLX|'E',    ctlxe},
  {CTLX|'F',    setfillcol},
#ifndef OS9
  {CTLX|'K',    killbuffer},
  {CTLX|'N',    nextwind},
  {CTLX|'P',    prevwind},
  {CTLX|'Z',    enlargewind},
#endif
  {META|CTRL|'H',   delbword},
  {META|'!',    reposition},
  {META|'.',    setmark},
  {META|'>',    gotoeob},
  {META|'<',    gotobob},
  {META|'B',    backword},
  {META|'C',    capword},
  {META|'D',    delfword},
  {META|'F',    forwword},
  {META|'L',    lowerword},
  {META|'U',    upperword},
  {META|'V',    backpage},
#ifndef OS9
  {META|'W',    copyregion},
#endif
  {META|0x7F,    delbword},
  {0x7F,     backdel},
  {0,        0} /* Signals end of table */
};
#else
extern KEYTAB keytab[];
#endif

#define NKEYTAB (sizeof(keytab)/sizeof(keytab[0]))

#ifdef RAINBOW

#include "rainbow.h"

/*
 * Mapping table from the LK201 function keys to the internal EMACS character.
 */

short lk_map[][2] = {
  Up_Key,       CTRL+'P',
  Down_Key,      CTRL+'N',
  Left_Key,      CTRL+'B',
  Right_Key,      CTRL+'F',
  Shift+Left_Key,     META+'B',
  Shift+Right_Key,    META+'F',
  Control+Left_Key,    CTRL+'A',
  Control+Right_Key,    CTRL+'E',
  Prev_Scr_Key,     META+'V',
  Next_Scr_Key,     CTRL+'V',
  Shift+Up_Key,     META+'<',
  Shift+Down_Key,     META+'>',
  Cancel_Key,      CTRL+'G',
  Find_Key,      CTRL+'S',
  Shift+Find_Key,     CTRL+'R',
  Insert_Key,      CTRL+'Y',
  Options_Key,     CTRL+'D',
  Shift+Options_Key,    META+'D',
  Remove_Key,      CTRL+'W',
  Shift+Remove_Key,    META+'W',
  Select_Key,      CTRL+'@',
  Shift+Select_Key,    CTLX+CTRL+'X',
  Interrupt_Key,     CTRL+'U',
  Keypad_PF2,      META+'L',
  Keypad_PF3,      META+'C',
  Keypad_PF4,      META+'U',
  Shift+Keypad_PF2,    CTLX+CTRL+'L',
  Shift+Keypad_PF4,    CTLX+CTRL+'U',
  Keypad_1,      CTLX+'1',
  Keypad_2,      CTLX+'2',
  Do_Key,       CTLX+'E',
  Keypad_4,      CTLX+CTRL+'B',
  Keypad_5,      CTLX+'B',
  Keypad_6,      CTLX+'K',
  Resume_Key,      META+'!',
  Control+Next_Scr_Key,   CTLX+'N',
  Control+Prev_Scr_Key,   CTLX+'P',
  Control+Up_Key,     CTLX+CTRL+'P',
  Control+Down_Key,    CTLX+CTRL+'N',
  Help_Key,      CTLX+'=',
  Shift+Do_Key,     CTLX+'(',
  Control+Do_Key,     CTLX+')',
  Keypad_0,      CTLX+'Z',
  Shift+Keypad_0,     CTLX+CTRL+'Z',
  Main_Scr_Key,     CTRL+'C',
  Keypad_Enter,     CTLX+'!',
  Exit_Key,      CTLX+CTRL+'C',
  Shift+Exit_Key,     CTRL+'Z'
  };

#define lk_map_size  (sizeof(lk_map)/2)

#endif

/* #define NULL 0 */

