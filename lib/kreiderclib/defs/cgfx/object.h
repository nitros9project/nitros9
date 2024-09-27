typedef struct OBJSTR {
 char group;          /* G/P group for this object */
 char buffer;         /* G/P buffer for this object */
 int xcor;            /* xcor * 32 */
 int ycor;            /* ycor * 32 */
 int deltax;          /* +/- xcor */
 int deltay;          /* +/- ycor */
 int xaccel;          /* xcor acceleration */
 int yaccel;          /* ycor acceleration */
 int (*border)();     /* function to call to check boundaries */
 struct OBJSTR *next; /* pointer to next object */
 struct OBJSTR *prev; /* pointer to previous object */
 } OBJECT;            /* call this type OBJECT */
 
extern OBJECT *Objects; /* pointer to OBJECT list */
