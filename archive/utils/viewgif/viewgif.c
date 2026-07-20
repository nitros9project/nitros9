/* OS-9 ViewGIF 2.0   Copyright (C) 1989 by Vaughn Cato */

/*
 * This program was specifically written for OS-9 on the Tandy Color
 * Computer 3 as its graphics routines will only work on that system.
 * The GIF decoding routines were originally taken from the Apollo
 * workstation version of viewgif by Ben Samit.  As noted in the source
 * code provided by Ben, most of his code was taken from a GIF to
 * PostScript converter by Scott Hemphill.  Because of their consideration
 * in providing the source code with their respective programs I am doing
 * the same.
 *
 * I encourage you to send any enhancements in the Color Computer version
 * you wish to be publicly distributed to me so that I may update the
 * program and re-release it.  In this way, a standard version of the
 * program can be maintained.
 *
 * My address is:
 * Vaughn Cato
 * 1244 E. Piedmont Rd. NE
 * Marietta, Ga. 30062
 */

/*
 * Any portion of this program may be freely used in any software provided
 * the source for that program is made freely available to the public and
 * credit is given to me, Ben Samit, and Scott Hemphill.
 */

#define EXTERN	/* force a defining instance of global variables */

#include <string.h>
#include "viewgif.h"

void			showdata();
char           *mapgpb();
extern int		errno;

DIRECT int      pauselen = -1;
DIRECT bool     global;

main(argc, argv)
int             argc;
char           *argv[];
{
	register char  *p;
	register bool  *cscan;
	char            opt;
	bool            quit;
	int             x, argnum;

	dfactor  = D_DITHER;
	magfact  = D_MAG;
	britefac = D_BRITE;
	infomode = D_INFO;
	graytype = D_GRAY;
	myheight = D_HEIGHT;

	zapmap = aligned = realrand = vefon = FALSE;
	flicker = newscrn = dispon = TRUE;

	for (cscan = &coloruse[MGCLUT]; cscan > coloruse; )
		*--cscan = TRUE;

	screen[0].winpath = screen[1].winpath = -1;

	for (argnum = 1; argnum < argc; ++argnum) {
		if (argv[argnum][0] == '-') {
			p = &argv[argnum][1];
			while (opt = *p++) {
				if (*p == '=')
					++p;
				switch (opt) {
				case 'd':
					if (*p == '\0')
						dfactor = 0;
					else {
						dfactor = atoi(p);
						if (dfactor < -MAXTOL1 || dfactor > MAXDITH1)
							error("Invalid dithering factor", 1);
					}
					break;
				case 'u':
					usefname = p;
					break;
				case 'm':
					magfact = atoi(p);
					if (magfact < MINMAG || magfact > MAXMAG)
						error("Invalid magnification", 1);
					break;
				case 'x':
					startx = atoi(p);
					if (startx < MINCOORD || startx > MAXCOORD)
						error("Invalid start x coordinate", 1);
					break;
				case 'y':
					starty = atoi(p);
					if (starty < MINCOORD || starty > MAXCOORD)
						error("Invalid start y coordinate", 1);
					break;
				case 'g':
					switch (*p) {
					case '2':
						graytype = MAX_GRAY;
						break;
					case '3':
						graytype = NTSC_GRAY;
						break;
					default:
						graytype = AVG_GRAY;
					}
					break;
				case 'a':
					aligned = TRUE;
					continue;
				case 'z':
					dispon = zapmap = TRUE;
					continue;
				case 'v':
					dispon = vefon = TRUE;
					if (*p != '\0')
						vefname = p;
					break;
				case 'r':
					realrand = TRUE;
					continue;
				case 's':
					infomode = NO_INFO;
					continue;
				case 'i':
					if (newscrn)
						infomode = MUCH_INFO;
					continue;
				case 'n':
					if (vefname == NULL)
						dispon = FALSE;
					continue;
				case 'p':
					pauselen = atoi(p);
					break;
				case 'c':
					newscrn = FALSE;
					infomode = NO_INFO;
					continue;
				case 'f':
					flicker = FALSE;
					continue;
				case 'b':
					britefac = atoi(p);
					if (britefac < MINBRITE || britefac > MAXBRITE)
						error("Invalid brightness factor", 1);
					break;
				case '?':
					usage();
				default:
					fatal("Unknown option");
				}
				break;
			}
			for (x = argnum + 1; x < argc; ++x)
				argv[x - 1] = argv[x];
			--argc;
			--argnum;
		}
	}

	if (argc < 2)
		usage();

	if ((infile = fopen(argv[1], "r")) == NULL)
		error("Cannot open input file", errno);

	if (flicker) {
		maxdith = MAXDITH2;
		minmod = SCALE2;
		approx = approx2;
	} else {
		maxdith = MAXDITH1;
		minmod = SCALE1;
		approx = approx1;
	}
	if (dfactor > maxdith)
		dfactor = maxdith;
	low0 = minmod / 2;
	up0 = low0 + 1;

	checksig();
	readscrn();
	if (!realrand)
		makerand();


	quit = FALSE;
	framenum = 0;
	do {
		switch (getc(infile)) {
		case '\0':
			break;
		case ',':
			++framenum;
			readimag();
			waituser();
			break;
		case ';':
			quit = TRUE;
			break;
		case '!':
			readext();
			break;
		default:
			quit = TRUE;
			break;
		}
		if (!dispon && vefname == NULL && (usefname == NULL || !newuse))
			break;
	} while (!quit);

	if (dispon) {
		if (zapmap) {
			if ((infile = freopen(argv[1], "r+", infile)) == NULL)
				error("Cannot rewrite global map", errno);
			else
				zapglobmap();
		}
		killwind();
	}

	actwin = 1;
	select();
	flushwin();
}

makerand()
{
	register char	*rscan1, *rscan2;
	int				x, f2;
	char			temp;
	bool			oddrow, oddrc;

	f2 = maxdith / 2;

	/* initialize */
	x = 256;
	for (rscan2 = &randtab[16][0]; (rscan2 -= 16) >= &randtab[0][0]; )
		for (rscan1 = rscan2 + 16; rscan1 > rscan2; )
			*--rscan1 = (--x * f2) >> 8;

	/*
	 * permute randomly (I don't think the original made all
	 * permutations equally likely, alas)
	 */
	rscan1 = &randtab[0][0];
	for (x = 256; x > 0; x--) {
		rscan2 = rscan1 + (rand() % x);
		temp = *rscan1;
		*rscan1++ = *rscan2;
		*rscan2 = temp;
	}

	oddrow = FALSE;
	for (rscan2 = &randtab[16][0]; (rscan2 -= 16) >= &randtab[0][0]; ) {
		oddrc = oddrow = !oddrow;
		for (rscan1 = rscan2 + 16; --rscan1 >= rscan2; ) {
			if (oddrc = !oddrc)
				*rscan1 += maxdith;
			if (oddrow)
				*rscan1 += f2;
		}
	}
}

readuse()
{
	char            newname[64];
	register char  *ep;
	int             usefile;

	getusename(newname);
	if ((usefile = open(newname, 1)) == -1) {
		for (ep = &coloruse[MGCLUT]; --ep >= coloruse; )
			*ep = TRUE;
		newuse = TRUE;
	} else {
		read(usefile, coloruse, MGCLUT * sizeof(bool));
		close(usefile);
		if (infomode != NO_INFO)
			printf("Using usage file\n");
		newuse = FALSE;
	}
}

getusename(buffer)
{
	if (framenum > 1)
		sprintf(buffer, "%s%d", usefname, framenum);
	else
		strcpy(buffer, usefname);
}

writeuse()
{
	register char  *cp, *gp;
	int             usecount, usefile;
	char            newname[64];

	usecount = 0;
	for (gp = &globuse[globcolors], cp = &coloruse[globcolors];
		 --gp, --cp >= coloruse; )
	{
		if (*cp) {
			*gp = TRUE;
			++usecount;
		}
	}
	if (infomode != NO_INFO)
		printf("%d out of %d colors used.\n", usecount, globcolors);
	if (usefname != NULL) {
		getusename(newname);
		if (newuse) {
			if ((usefile = creat(newname, 3)) == -1)
				error("Cannot create usage file", errno);
			else
				write(usefile, coloruse, globcolors);
		}
		close(usefile);
	}
}

zapglobmap()
{
	register rgbcolor	*gp, *used;
	register int		i;

	for (i = 0; i < globcolors; i++) {
		if (globuse[i]) {
			used = &globclut[i];
			for (gp = &globclut[i = globcolors]; --i, --gp >= globclut; )
			{
				if (!globuse[i]) {
					gp->red   = used->red;
					gp->green = used->green;
					gp->blue  = used->blue;
				}
			}
			fseek(infile, clutpos, 0);
			fwrite(globclut, sizeof(rgbcolor), globcolors, infile);
			return;
		}
	}
}

saveimag()
{
	register cocoscreen	*sscan;
	char            	newname[64];
	int             	file, x, scrnum, scrntype = 0;

	for (scrnum = 0; scrnum <= flicker; ++scrnum) {
		sscan = &screen[scrnum];
		strcpy(newname, vefname);
		if (framenum > 1)
			sprintf(newname + strlen(newname), "%d", framenum);
		if (scrnum == 1)
			strcat(newname, ".2");
		actwin = sscan->winpath;
		select();
		flushwin();
		if ((file = creat(newname, 3)) == -1)
			error("Cannot create vef file", errno);
		else {
			write(file, &scrntype, sizeof(scrntype));
			write(file, sscan->pal, MCCLUT * sizeof(colorcode));
			for (x = 0; x < 8; ++x)
				write(file, gpbufptr, 160);
			for (x = 0; x < MROWS; ++x) {
				getblk(groupnum, bufnum, 0, x, MCOLS - 1, 1);
				flushwin();
				write(file, gpbufptr, 160);
			}
			close(file);
		}
	}
}

readext()
{
	char            buf[255];
	int				count;

	(void) getc(infile);
	while (count = getc(infile))
		fread(buf, 1, count, infile);
}

DIRECT int      real_x, real_y;
DIRECT int      x_coord, y_coord;

typedef struct {
	int		ilv_r0;		/* starting row */
	int		ilv_dr;		/* step size */
}	ilvspec;

static ilvspec	ilvdat[] = {
	{1, 2}, /* .|.|.|.|.|.|.|.|. */
	{2, 4}, /* ..|...|...|...|.. */
	{4, 8}, /* ....|.......|.... */
	{0, 8},	/* |.......|.......| */
};

readimag()
{
	BYTE				buf[9];
	unsigned        	left, top, width, height;
	bool            	local, intrlevd;
	int             	lclbits;
	int             	row, rowoffset;
	register int		n;
	int					lineread, hold, xpos, x;
	register ilvspec   *ilvscan;

	readuse();
	newwind();

	/* read header info */
	fread(buf, sizeof(BYTE), sizeof(buf) / sizeof(BYTE), infile);
	left = arith(buf[0]) | (buf[1] << 8);
	top  = arith(buf[2]) | (buf[3] << 8);
	imagwid  = width = arith(buf[4]) | (buf[5] << 8);
	imaghigh = height = arith(buf[6]) | (buf[7] << 8);

	if (infomode != NO_INFO)
		printf("gif dimensions: %d x %d pixels\n", imagwid, imaghigh);

	local = buf[8] & 0x80;
	intrlevd = buf[8] & 0x40;

	if (local) {
		char            tempbuf[3];

		lclbits = (buf[8] & 0x7) + 1;
		for (x = 1 << lclbits; --x >= 0; )
			fread(tempbuf, 3, 1, infile);
	} else if (!global)
		fatal("no CLUT present for image");

	ilevtab[MROWS] = ILEVEND;
	for (x = MROWS; --x >= 0; )
		ilevtab[x] = ILEVMISS;

	if (!aligned)
		n = myheight;
	else {
		for (n = imaghigh; n > 200; n /= 2)
			;
	}
	n *= magfact;

	rowoffset = 3 * starty * magfact;
	lineread = 0;
	if (intrlevd) {
		for (ilvscan = &ilvdat[elements(ilvdat)]; --ilvscan >= ilvdat; ) {
			for (x = ilvscan->ilv_r0; x < imaghigh; x += ilvscan->ilv_dr) {
				row = (long) x * n / imaghigh - rowoffset;
				if (row >= 0 && row < MROWS)
					ilevtab[row] = lineread;
				++lineread;
			}
		}
	} else {
		for (x = 0; x < imaghigh; ++x) {
			row = (long) x * n / imaghigh - rowoffset;
			if (row >= 0 && row < MROWS)
				ilevtab[row] = lineread;
			++lineread;
		}
	}

	x = startx * (imagwid / 64);
	hold = xpos = 0;
	while (xpos < mywidth) {
		for (hold += mywidth * magfact; hold >= imagwid; hold -= imagwid)
			xtab[xpos++] = x;
		x++;
	}

	real_x = real_y = 0;
	x_coord = y_coord = 0;

	if (dispon || (usefname != NULL && newuse)) {
		readrast(width, height);
		writeuse();
		if (vefname != NULL)
			saveimag();
	}
}

DIRECT int      datum;
DIRECT int      bits;
char            buf[255];

readrast(width, height)
unsigned        width, height;
{
	register char		   *ch;
	register codetype	   *cscan;
	int						count, code;

	datasize = getc(infile);
	codesize = datasize + 1;
	codemask = (1 << codesize) - 1;
	clear = 1 << datasize;
	eoi = clear + 1;
	bits = 16;

	/* initialize code table */
	for (cscan = &codetab[code = clear]; --cscan, --code >= 0; ) {
		cscan->prefix = (codetype *) NULL;
		cscan->first = cscan->suffix = code;
	}

	while ((count = getc(infile)) > 0) {
		fread(buf, sizeof(*buf), count, infile);
		for (ch = buf; --count >= 0; )
			addbyte(*ch++);
	}

	datum >>= bits;
	for (bits = 16 - bits; x_coord != 0 && bits >= codesize; bits -= codesize) {
		process(datum & codemask);
		datum >>= codesize;
	}
}

addbyte(c)
char            c;
{
	/*
	 *	datum += (long)(*ch & 0xff) << bits;
	 *	bits += 8;
	 *	while (bits >= codesize) {
	 *		code = datum & codemask;
	 *		datum >>= codesize;
	 *		bits -= codesize;
	 *		if (code == eoi)
	 *			goto exitloop;
	 *		process(code);
	 *	}
	 */
#asm
 ldb 5,s
 lda <bits+1
 suba #7
 bls _addb3
 sta <bits+1
 lda <datum
 sta <datum+1
 stb <datum
 lda #1
 bra _addb4
_addb3
 lda #8
_addb1
 lsrb
 ror <datum
 ror <datum+1
_addb4
 dec <bits+1
 bne _addb2
* pshs d
 tfr d,u
 ldd <codesize
 std <bits
 ldd <datum
 anda <codemask
 andb <codemask+1
 pshs d
 lbsr process
 leas 2,s
* puls d
 tfr u,d
_addb2
 deca
 bne _addb1
#endasm
}

process(code)
int             code;
{
	register codetype       *p, *cp;
	static DIRECT int		avail;
	static DIRECT codetype	*oldcp;

	if (code == clear) {
		/* clear table */
		codesize = datasize + 1;
		codemask = (1 << codesize) - 1;
		avail = clear + 2;
		oldcp = NULL;
	} else if (code < avail) {
		outcode(cp = &codetab[code]);	/* output the code */
		if (oldcp != NULL) {
			/* add new entry */
			p = &codetab[avail++];
			/* prefix is previous code, first is prefix's first */
			p->first = (p->prefix = oldcp)->first;
			p->suffix = cp->first;	/* suffix is first of current */
			if ((avail & codemask) == 0 && avail < MCODE) {
				/* increase code size */
				codesize++;
				codemask += avail;
			}
		}
		oldcp = cp;
	} else if (code == avail && oldcp != NULL) {
		/* repeat of last code */
		p = &codetab[avail++];
		/* prefix is previous code, first is prefix's first */
		p->first = (p->prefix = oldcp)->first;
		p->suffix = p->first;		/* Suffix is first of last */
		outcode(p);
		if ((avail & codemask) == 0 && avail < MCODE) {
			/* increase code size */
			codesize++;
			codemask += avail;
		}
		oldcp = &codetab[code];
	} else
		fatal("illegal code in raster data");
}

/*
 * outcode() -- we finally get the data out of the LZ decompression, and
 * fill a buffer until we get a line's worth of data.  The loop with x0
 * and x is intended to take advantage of the mostly increasing nature
 * of ilevtab[], replacing an O(n**2) loop that was there before.  Timing,
 * however, shows that the change doesn't affect display time, so the
 * performance bottleneck must be elsewhere.  Rats.
 */
outcode(p)
codetype       *p;
{
	register BYTE		*sp = &codestk[0];
	register int		x;
	static DIRECT int	x0 = 0;

	for (; p; p = p->prefix)
		*sp++ = p->suffix;

	while (--sp >= &codestk[0]) {
		coloruse[arith(*sp)] = TRUE;
		if (real_x == 0) {
			y_coord = -1;
			x = x0;
			do {
				if (++x >= myheight)
					x = 0;
				if (ilevtab[x] == real_y) {
					x0 = y_coord = x;
					break;
				}
			} while (x != x0);
		}
		if (y_coord >= 0) {
			while (xtab[x_coord] == real_x)
				linestor[x_coord++] = arith(*sp);
		}
		if (++real_x >= imagwid) {
			if (y_coord >= 0 && dispon) {
				do {
					doline();
				} while (ilevtab[++y_coord] == ILEVMISS);
			}
			real_x = x_coord = 0;
			++real_y;
		}
	}
}

DIRECT int      bitcount, pixperbyte;
DIRECT char    *byteptr;

doline()
{
	register xlate	*p;
	register char	*rrow;
	register int	x, addval, scrnum;
	cocoscreen		*sscan;

	rrow = &randtab[y_coord & 15][0];

	for (sscan = &screen[scrnum = (flicker ? 2 : 1)]; --sscan, --scrnum >= 0;)
	{
		actwin = sscan->winpath;
		bitcount = pixperbyte;
		byteptr = gpbufptr;
		if (dfactor > 0) {
			for (x = 0; x < mywidth; ++x) {
				addval = (realrand) ? rand85(y_coord + x)
									: rrow[x & 15];
				for (p = &transtab[linestor[x]][1]; p->addval <= addval; )
					p++;
				--p;
				addpixel(p->clutval[scrnum]);
			}
		} else {
			for (x = 0; x < mywidth; ++x)
				addpixel(transtab[linestor[x]][0].clutval[scrnum]);
		}
		if (flicker)
			select();
		putblk(groupnum, bufnum, 0, y_coord);
		flushwin();
	}
}

addpixel(c)
{
	/*
	 *	*byteptr = (*byteptr << (gmode ? 2 : 4)) | c;
	 *	if (--bitcount == 0) {
	 *		byteptr++;
	 *		bitcount = pixperbyte;
	 *	}
	 *
	 * (The spelling discrepancy here is due to the 6809's chopping off
	 * identifier lengths at a different point than the assembler appears to!)
	 */
#asm
 ldx <byteptr
 ldb ,x
 lda <gmode+1
 bne _addpix1
 lslb
 lslb
_addpix1
 lslb
 lslb
 orb 5,s
 stb ,x
 dec <bitcount+1
 bne _addpix2
 leax 1,x
 stx <byteptr
 lda <pixperby+1
 sta <bitcount+1
_addpix2
#endasm
}

rand85(n)
int             n;
{
	register unsigned	result;

	result = rand() % maxdith;
	if (n & 1)
		result += maxdith + 1;
	return result;
}

readscrn()
{
	char            	buf[7];
	int             	x;
	register rgbcolor	*rp;

	fread(buf, sizeof(*buf), 7, infile);
	imagwid = arith(buf[0]) | (buf[1] << 8);
	imaghigh = arith(buf[2]) | (buf[3] << 8);
	if (infomode != NO_INFO)
		printf("%d x %d screen\n", imagwid, imaghigh);
	global = (buf[4] & 0x80) != 0;
	if (global) {
		globbits = (buf[4] & 0x07) + 1;
		globcolors = 1 << globbits;
		if (infomode != NO_INFO)
			printf("global bitmap: %d colors\n", globcolors);
		clutpos = ftell(infile);
		fread(globclut, 3, globcolors, infile);
		if (infomode == MUCH_INFO) {
			for (rp = globclut, x = 0; x < globcolors; rp++, x++) {
				printf("color %d = %3d,%3d,%3d\n", x,
				       arith(rp->red), arith(rp->green), arith(rp->blue));
			}
		}
	} else
		fatal("cannot handle non-global bitmaps");
}

/*
 * newwind() -- the big banana; determine the CoCo CLUT(s) that will
 * best display the GIF image given the GIF CLUT.
 */

newwind()
{
	register cocoscreen	*sscan;
	register bool		*bscan;
	register colorcode	*cscan;
	rgbcolor			*rgbp;
	bool				first;
	char				blip;
	int					x, hival, loval, midval;

	fixgmap();

	if (infomode != NO_INFO) {
		printf("Analyzing..");
		fflush(stdout);
	}

	loval = -MAXTOL1;
	midval = hival = dfactor;

	while (loval <= hival) {
		dfactor = midval;
		if (setmap()) {
			loval = midval + 1;
			blip = '+';
		} else {
			hival = midval - 1;
			blip = '-';
		}
		if (infomode != NO_INFO) {
			putchar(blip);
			fflush(stdout);
		}
		midval = (loval + hival) / 2;
	}

	if (dfactor != hival) {
		dfactor = hival;
		setmap();
	}

	if (infomode != NO_INFO) {
		putchar('\n');
		showdata();
	}

	if (screen[0].clutsize <= 4 && !vefon) {
		gmode = TRUE;
		mywidth = 640;
		pixperbyte = 4;
	} else {
		gmode = FALSE;
		mywidth = 320;
		pixperbyte = 2;
	}

	first = TRUE;
	for (sscan = &screen[(flicker ? 2 : 1)]; --sscan >= screen; ) {
		if (dispon)
			sscan->winpath = initwin(first, sscan->winpath);
		for (cscan = &sscan->pal[x = sscan->clutsize]; --cscan, --x >= 0; ) {
			*cscan = colorval(&sscan->clut[x]);
			if (dispon)
				palette(x, *cscan);
		}
		if (dispon) {
			border(0);
			flushwin();
		}
		first = FALSE;
	}
	for (bscan = &coloruse[globcolors]; --bscan >= coloruse; )
		*bscan = FALSE;
}

/* colorval() -- encode an RGB222 value the way the GIME likes it */

colorval(color)
register rgbcolor		*color;
{
	static char		cocode[] = {'\000', '\001', '\010', '\011'};

	return  (((cocode[color->red & 3] << 1) |
			   cocode[color->green & 3]) << 1) | cocode[color->blue & 3];
}

/*
 * showdata() -- display a bunch of information on the CLUTs used
 * if it's been asked for
 */
void
showdata()
{
	register rgbcolor		*rscan;
	register cocoscreen		*sscan;
	int						x, y;

	if (dfactor > 0)
		printf("Dithering factor = %d\n", dfactor);
	else
		printf("Color tolerance = %d\n", -dfactor);
	fputs("Resulting coco CLUT: ", stdout);
	printf("%d colors", screen[0].clutsize);
	if (flicker)
		printf(" + %d colors\n", screen[1].clutsize);
	else
		putchar('\n');
	if (infomode == MUCH_INFO) {
		for (x = 0; x < (flicker ? 1 : 2); x++) {
			sscan = &screen[x];
			for (rscan = sscan->clut, y = 0; y < sscan->clutsize; y++) {
				printf("%2d:%d,%d,%d=%d\n", y,
					rscan->red, rscan->green, rscan->blue, colorval(rscan));
				rscan++;
			}
			putchar('\n');
		}
		fputs("Translation table:\n", stdout);
		for (x = 0; x < globcolors; ++x) {
			if (coloruse[x]) {
				printf("%3d:", x);
				for (y = 0; y < 4 && transtab[x][y].addval != BOGUSDITH; ++y) {
					printf(" %3d=%3d",
						transtab[x][y].addval, transtab[x][y].clutval[0]);
					if (flicker)
						printf(",%3d", transtab[x][y].clutval[1]);
				}
				putchar('\n');
			}
		}
	}
}

/*
 * fixgmap() -- scale colors in the GIF image global CLUT in accordance
 * with the brightness specification, and in passing, convert to gray
 * if requested (either using the average of the components or their
 * maximum).
 */
fixgmap()
{
	register rgbcolor	*rscan;
	int             	x, r, g, b;

	for (rscan = &globclut[x = globcolors]; --rscan, --x >= 0; ) {
		if (coloruse[x]) {
			r = arith(rscan->red);
			g = arith(rscan->green);
			b = arith(rscan->blue);
			switch (graytype) {
			case AVG_GRAY:
				r = g = b = (r + g + b) / 3;
				break;
			case NTSC_GRAY:
				r = g = b = (30 * r + 59 * g + 11 * b) / 100;
				break;
			case MAX_GRAY:
				if (g > r)
					r = g;
				if (b > r)
					r = b;
				g = b = r;
				break;
			}
			rscan->red   = (britefac * r) >> 4;
			rscan->green = (britefac * g) >> 4;
			rscan->blue  = (britefac * b) >> 4;
		}
	}
}

killwind()
{
	mapgpb(screen[flicker].winpath, groupnum, bufnum, 0);
	killbuf(groupnum, bufnum);
}

waituser()
{
	char            	c;
	int             	x;
	register cocoscreen	*sscan;

	if (dispon) {
		if (pauselen < 0) {
			for (x = 5; --x >= 0; )
				bell();
			flushwin();
		}
		if (flicker) {
			pauselen *= 30;
			do {
				for (sscan = &screen[2]; --sscan >= screen; ) {
					actwin = sscan->winpath;
					select();
					flushwin();
					sleep(2);
					if (ready(actwin)) {
						read(actwin, &c, 1);
						if (c == '\n')
							return;
					}
				}
			} while (pauselen < 0 || --pauselen >= 0);
		} else if (pauselen > 0) {
			sleep(60 * pauselen);
		} else if (pauselen < 0) {
			do {
				read(screen[0].winpath, &c, 1);
			} while (c != '\n');
		}
	}
}

ready(path)
int             path;
{
#asm
 lda 5,s
 ldb #SS.Ready
 os9 I$GetStt
 bcc _ready1
 ldd #0
 bra _ready2
_ready1
 ldd #1
_ready2
#endasm
}
