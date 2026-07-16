/*
 * viewgif.h -- common header fodder for viewgif
 */

#include <stdio.h>

#ifdef OSK
/* the OS-9/68000 C compiler knows about void now! */
#define DIRECT
typedef unsigned char	BYTE;
#define arith(byte)	(byte)
#else
typedef int		void;
#define DIRECT direct
typedef char			BYTE;
#define arith(byte)	((byte) & 0xff)
#endif

/* the canonical dodge for being sure of exactly one defining declaration */

#ifndef EXTERN
#define EXTERN extern
#endif

typedef char	bool;		/* make up for a C deficiency */

#define FALSE	(1 == 0)
#define TRUE	(!FALSE)

#define elements(array)	(sizeof(array) / sizeof(array[0]))
#define maxnum(bits)	((1 << (bits)) - 1)

/*
 * typedef to let us look at RGB colors two ways--one, as an array of
 * components; two, as a structure with nameable components.
 */

typedef union {
	BYTE	rgbarr[3];
	struct {
		BYTE	rval, gval, bval;
	}		rgbstr;
}	rgbcolor;

#define	red		rgbstr.rval
#define green	rgbstr.gval
#define blue	rgbstr.bval

/* Values and variables related to the GIF spec */

#define MGCLUT	 	256		/* maximum number of colors in a GIF picture */
#define GBITS		8		/* # of bits in each component of a GIF color */
#define MCODE		4096	/* number of 12-bit LZ codes */

typedef struct cstruct {
	struct cstruct	*prefix;
	char			first, suffix;
}		codetype;

EXTERN bool				coloruse[MGCLUT];	/* flags colors in use */
EXTERN bool				globuse[MGCLUT];	/* global usage flag */
EXTERN rgbcolor			globclut[MGCLUT];	/* RGB colors in image */
EXTERN DIRECT int		globbits;			/* # bits for global color map */
EXTERN DIRECT int		globcolors;			/* # possible colors */
EXTERN DIRECT unsigned	imagwid, imaghigh;	/* image width/height in pixels */

EXTERN codetype			codetab[MCODE];		/* LZ code table */
EXTERN BYTE				codestk[MCODE];		/* buffer for decoded bytes */
EXTERN DIRECT int		codesize;			/* LZ code size in bits */
EXTERN DIRECT int		codemask;			/* LZ code mask */
EXTERN DIRECT int		clear;				/* code for code table clear */
EXTERN DIRECT int		eoi;				/* code for end of image */
EXTERN DIRECT int		datasize;			/* ??? */

/* Now for CoCo-related stuff... */

#define MCCLUT		 16		/* max size of Color Look-Up Table on CoCo 3 */
#define CBITS		  2		/* # of bits in each component of a CoCo 3 color */
#define MROWS		192		/* max number of rows we can display */
#define MCOLS		640		/* max number of cols we can display */

#define MSCREENS	  2		/* number of screens we may cycle among */

/* type to hold the CoCo encoding of a color */

typedef BYTE	colorcode;

/*
 * type to represent the screens that will collectively contain the
 * GIF image for display--we add one to the sizes of the arrays for
 * palettes to try to speed up the search for color mappings (see
 * setmap.c functions)
 */

typedef struct {
	int			winpath;			/* path # for window to display on */
	int			clutsize;			/* colors actually used */
	rgbcolor	clut[MCCLUT];		/* their RGB values */
	colorcode	pal[MCCLUT];		/* their CoCo encodings */
}	cocoscreen;

typedef struct {
	char		addval;
	char		clutval[MSCREENS];
}	xlate;

EXTERN cocoscreen	screen[MSCREENS];		/* screens to be cycled among */
EXTERN int			ilevtab[MROWS + 1];		/* interleave table */
EXTERN int			xtab[MCOLS];			/* ??? */
EXTERN int			linestor[MCOLS];		/* ??? */
EXTERN xlate		transtab[MGCLUT][5];	/* translations of GIF colors */
EXTERN char			randtab[16][16];		/* pseudo-random table */

/* non-scan line values for ilevtab[] */
#define ILEVMISS	(-1)					/* marks scan lines missed */
											/* in readimag() scaling loops */
#define ILEVEND		(-20)					/* end marker guaranteed not */
											/* to match a valid scan line */
											/* or ILEVMISS! */

/* conversion between GIF's RGB space and the CoCo's RGB space */
#define SCALE1		(maxnum(GBITS) / maxnum(CBITS))
#define SCALE2		(SCALE1 / 2)

/* limits */

/* dithering factor */
#define MAXDITH1	(SCALE1 / 2)
#define MAXDITH2	(SCALE2 / 2)
#define BOGUSDITH	127				/* end marker for addval */
/* color tolerance (represented by negative "dithering factor") */
#define MAXTOL1		SCALE1
#define MAXTOL2		SCALE2
/* magnification factor */
#define MINMAG		  1
#define MAXMAG		 64
/* brightness */
#define MINBRITE	  1
#define MAXBRITE	 16
/* starting coordinates (units: 64ths of the image size along the axis) */
#define MINCOORD	  1
#define MAXCOORD	 64

/* some symbolic names for the values of some twistable knobs */

#define NO_INFO		  0
#define SOME_INFO	  1
#define MUCH_INFO	  2

#define NO_GRAY		  0
#define AVG_GRAY	  1
#define MAX_GRAY	  2
#define NTSC_GRAY	  3

/* default values */

#define D_INFO		SOME_INFO
#define D_GRAY		NO_GRAY
#define D_BRITE		MAXBRITE
#define D_DITHER	MAXDITH1
#define D_MAG		MINMAG
#define D_HEIGHT	MROWS

EXTERN DIRECT FILE	*infile;			/* file containing GIF image */
EXTERN DIRECT long	clutpos;			/* position of global CLUT in file */
EXTERN DIRECT int	infomode;			/* control amount of commentary */
EXTERN DIRECT int	graytype;			/* what kind of gray scale, if any */
EXTERN DIRECT int	dfactor;			/* dithering factor */
EXTERN DIRECT int	maxdith;			/* upper bound on random dither */
EXTERN DIRECT int	magfact;			/* magnification factor */
EXTERN DIRECT int	britefac;			/* brightness factor */
EXTERN DIRECT int	startx, starty;		/* coord to map to top left corner */
EXTERN DIRECT bool	realrand;			/* use random #s instead of table */
EXTERN DIRECT bool	flicker;			/* cycle among screens */
EXTERN DIRECT bool	dispon;				/* display the image */
EXTERN DIRECT bool	zapmap;				/* overwrite unused map colors */
EXTERN DIRECT bool	vefon;				/* save the image in VEF fmt */
EXTERN DIRECT bool	aligned;			/* align to pixels */
EXTERN DIRECT bool	newscrn;			/* switch to new window for display */
EXTERN DIRECT char	*usefname;			/* to name of color usage file */
EXTERN DIRECT char	*vefname;			/* to name of VEF output file */
EXTERN DIRECT int	mywidth, myheight;	/* width, height we will display */
EXTERN DIRECT int	actwin;				/* path for buffered gfx data */
EXTERN DIRECT int	groupnum, bufnum;	/* get/put buffer information */
EXTERN DIRECT int	framenum;			/* frame number--whatever that is */
EXTERN DIRECT char	*gpbufptr;			/* pointer to get/put buffer */
EXTERN DIRECT int	gmode;				/* graphics mode we're using */
EXTERN DIRECT int	newuse;				/* ??? */
EXTERN DIRECT bool	(*approx)();		/* to color approximation function */
EXTERN DIRECT int	minmod;				/* modulus for minadd() */
EXTERN DIRECT int	low0, up0;			/* default upper/lower limits for */
										/* approximation searches */
extern bool			approx1();			/* one-screen approximation */
extern bool			approx2();			/* two-screen approximation */

/* miscellanea for support routines */
#define fatal(s)	error((s), 1)		/* fatal error (no natural errno) */
