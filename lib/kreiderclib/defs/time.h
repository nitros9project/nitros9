/* structure for the 'setime()' and 'getime()' calls */

struct sgtbuf {
        char    t_year,
                t_month,
                t_day,
                t_hour,
                t_minute,
                t_second;
};

/* system dependent value */
#ifdef LEVEL2
#define tps     100     /* ticks per second */
#else
#define tps     10      /* ticks per second */
#endif
