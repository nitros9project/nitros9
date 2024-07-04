typedef struct {
 char *i_name; /* name of this menu item */
 char i_enabled; /* TRUE if this item is enabled */
 char (*i_func)(); /* pointer to function to call if this item selected */
 } ITEM;

#define MN_DSBL 0
#define MN_ENBL 1
#define MN_FUNC 1 /* call a function */
#define MN_SUBMN 2 /* sub-menu */
