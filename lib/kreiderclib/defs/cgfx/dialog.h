typedef struct { /* dialog structure */
 char d_type;    /* type- 0=string, 1=button */
 char d_column;  /* column position within the overlay */
 char d_row;     /* row within the overlay */
 char d_key;     /* key assocated with this button (0 for none) */
 char d_val;     /* value to return to caller */
 char *d_string; /* pointer to actual string to be placed in overlay */
} DIALOG;        /* call this type DIALOG */


/* now for some define constants for the 'd_type' field... */

#define D_TEXT 0   /* ASCII text */
#define D_KEY 1    /* key-binding */
#define D_STRING 2 /* ASCII string box (accepts text) */
#define D_BUTTON 3 /* 3-D text button */
#define D_RADIO 4  /* Radio button (where d_string should be NULL)*/
#define D_END -1   /* End marker of array */
