/* Mouse.h -Defs for mouse data structures */

/* structure for reading mouse info packet */

typedef struct mousin {
 char pt_valid,  /* is info valid? */
      pt_actv,   /* active side */
      pt_totm,   /* timeout initial value */
      pt_rsrv0[2],/* reserved */
      pt_tto,    /* time till timeout */
      pt_tsst[2],/* time since start counter */
      pt_cbsa,   /* current button state button A */
      pt_cbsb,   /* current button state button B */
      pt_ccta,   /* click count button A */
      pt_cctb,   /* click count button B */
      pt_ttsa,   /* time this state button A */
      pt_ttsb,   /* time this state button B */
      pt_tlsa,   /* time last state button A */
      pt_tlsb,   /* time last state button B */ 
      pt_rsrv1[6],/* reserved */
      pt_stat,   /* window pointer location type */
      pt_res;    /* resolution */
 int  pt_acx,    /* actual x value */
      pt_acy,    /* actual y value */
      pt_wrx,    /* window relative x value */
      pt_wry;    /* window relative y value */
} MSRET;

/* window regions for mouse */

#define WR_CNTNT 0 /* content region */
#define WR_CNTRL 1 /* control region */
#define WR_OFWIN 2 /* off window */
      