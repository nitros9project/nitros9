/*
    window.h

    Definitions of all window charactreristics required by the
    setwind() and getwind() functions.

    Copyright (c) 1991
    by Zack C. Sessions
*/

struct window_def {
    int  type;
    int  columns;
    int  rows;
    int  foreground;
    int  background;
    int  border;
    char palette[16];
    struct sgbuf options;
} ;

#define WINDOW struct window_def

WINDOW *getwind();

