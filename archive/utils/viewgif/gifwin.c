/*
 * gifwin.c - window functions for ViewGIF 2.0
 * by Vaughn Cato
 */

#include "viewgif.h"

char           *mapgpb();
extern int		errno;

checksig()
{
	char            buf[6];

	fread(buf, sizeof(*buf), 6, infile);
	if (strncmp(buf, "GIF", 3) != 0)
		fatal("file is not a GIF file");
	if (strncmp(&buf[3], "87a", 3) != 0)
		fatal("Unknown GIF version number");
}

perror(str)
char           *str;
{
	fprintf(stderr, "%s: error\n", str);
}

error(str, errnum)
char           *str;
int             errnum;
{
	fprintf(stderr, "viewgif: %s\n", str);
	exit(errnum);
}

sleep(ticks)
int		ticks;
{
#asm
 ldx 4,s
 os9 F$Sleep
#endasm
}

static char *ustext[] = {
	"OS9 ViewGIF 2.0 by Vaughn Cato\n",
	"usage: viewgif <filename> [-<option> ...]\n",
	"       displays a gif picture\n",
	"\n",
	"  options:\n",
	"       -d[[=]dfactor] Set dithering factor, default is 0\n",
	"       -a Align to pixels\n",
	"       -u[=]<filename> Create/use a color usage file\n",
	"       -m[=]<magfact> Set magnification factor (1-64)\n",
	"       -x[=]<start x> Set start x (0-64)\n",
	"       -y[=]<start y> Set start y (0-64)\n",
	"       -v[[=]<filename>] Generate vef format picture\n",
	"       -g grey scale picture (average color brite)\n",
	"       -g2 grey scale picture (max color brite)\n",
	"       -g3 grey scale picture (NTSC color brite)\n",
	"       -r Use random generator instead of table\n",
	"       -s Silent.  No info printed\n",
	"       -i Extended information\n",
	"       -n No display\n",
	"       -p[[=]seconds] Pause time (default 0)\n",
	"       -c Use current screen\n",
	"       -f Disable flicker\n",
	"       -b[=]<britefact> Set brightness (1-16)\n",
	"       -z Zap unused global color map entries\n",
	NULL
};

usage()
{
	register char	**uscan;
	
	for (uscan = ustext; *uscan != NULL; uscan++)
		fputs(*uscan, stderr);
	exit(1);
}

initwin(firstscreen, oldpath)
bool	firstscreen;
int		oldpath;
{
	register bool	newwin;

	newwin = (oldpath == -1);

	if (newwin) {
		if (!newscrn && firstscreen) {
			/* just use stdout */
			actwin = oldpath = 1;
			dwend();
		} else if ((actwin = oldpath = open("/w", 3)) == -1)
			exit(errno);
	} else {
		actwin = oldpath;
		dwend();
	}

	dwset(gmode ? 7 : 8, 0, 0, gmode ? 80 : 40, 24, 0, 0, 0);
	curoff();
	select();
	flushwin();

	if (newwin && firstscreen) {
		groupnum = getpid();
		bufnum = 1;
		getblk(groupnum, bufnum, 0, 0, 640, 1);
		flushwin();
		if ((gpbufptr = mapgpb(actwin, groupnum, bufnum, 1)) == NULL)
			exit(errno);
	} 
	
	return actwin;
}

dwset(sty, cpx, cpy, szx, szy, prn1, prn2, prn3)
int             sty, cpx, cpy, szx, szy, prn1, prn2, prn3;
{
	static char     outstr[] = {
		0x1b, 0x20, 0, 0, 0, 0, 0, 0, 0, 0
	};
	int             size;

	outstr[2] = sty;
	outstr[3] = cpx;
	outstr[4] = cpy;
	outstr[5] = szx;
	outstr[6] = szy;
	if (sty > 0 && sty <= 8) {
		outstr[7] = prn1;
		outstr[8] = prn2;
		outstr[9] = prn3;
		size = sizeof(outstr);
	} else
		size = sizeof(outstr) - 3;
	writemem(outstr, size);
}

dwend()
{
	static char     outstr[] = {0x1b, 0x24};

	writemem(outstr, sizeof(outstr));
}

select()
{
	static char     outstr[] = {0x1b, 0x21};

	writemem(outstr, sizeof(outstr));
}

bell()
{
	char            c = 7;
	writemem(&c, 1);
}

palette(prn, ctn)
{
	static char     outstr[] = {0x1b, 0x31, 0, 0};

	outstr[2] = prn;
	outstr[3] = ctn;
	writemem(outstr, sizeof(outstr));
}

point(x, y)
int             x, y;
{
	static char     outstr[] = {0x1b, 0x42, 0, 0, 0, 0};

	*(int *) &outstr[2] = x;
	*(int *) &outstr[4] = y;
	writemem(outstr, sizeof(outstr));
}

lineto(x, y)
int             x, y;
{
	static char     outstr[] = {0x1b, 0x46, 0, 0, 0, 0};

	*(int *) &outstr[2] = x;
	*(int *) &outstr[4] = y;
	writemem(outstr, sizeof(outstr));
}

fcolor(c)
int             c;
{
	static char     outstr[] = {0x1b, 0x32, 0};

	outstr[2] = c;
	writemem(outstr, sizeof(outstr));
}

border(c)
int             c;
{
	static char     outstr[] = {0x1b, 0x34, 0};

	outstr[2] = c;
	writemem(outstr, sizeof(outstr));
}

SetDPtr(x, y)
int             x, y;
{
	static char     outstr[] = {0x1b, 0x40, 0, 0, 0, 0};

	*(int *) &outstr[2] = x;
	*(int *) &outstr[4] = y;
	writemem(outstr, sizeof(outstr));
}

curoff()
{
	static char     outstr[] = {0x05, 0x20};

	writemem(outstr, sizeof(outstr));
}

getblk(grp, bfn, cpx, cpy, szx, szy)
int             grp, bfn, cpx, cpy, szx, szy;
{
	static char     outstr[] = {0x1b, 0x2c, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

	outstr[2] = grp;
	outstr[3] = bfn;
	*(int *) (&outstr[4]) = cpx;
	*(int *) (&outstr[6]) = cpy;
	*(int *) (&outstr[8]) = szx;
	*(int *) (&outstr[10]) = szy;
	writemem(outstr, sizeof(outstr));
}

putblk(grp, bfn, cpx, cpy)
int             grp, bfn, cpx, cpy;
{
	static char     outstr[] = {0x1b, 0x2d, 0, 0, 0, 0, 0, 0};

	outstr[2] = grp;
	outstr[3] = bfn;
	*(int *) (&outstr[4]) = cpx;
	*(int *) (&outstr[6]) = cpy;
	writemem(outstr, sizeof(outstr));
}

killbuf(grp, bfn)
int             grp, bfn;
{
	static char     outstr[] = {0x1b, 0x2a, 0, 0};

	outstr[2] = grp;
	outstr[3] = bfn;
	writemem(outstr, sizeof(outstr));
}

char *
mapgpb(path, grp, bfn, action)
int             path, grp, bfn, action;
{
#asm
 lda 7,s group
 ldb 9,s buffer
 tfr d,x ->X
 lda 5,s path
 ldb #$SS.MpGPB setstat code
 pshs y
 ldy 10+2,s action (1 => map, 0 => unmap)
 os9 I$SetStt
 puls y
 bcc _mapgpb1
 clra error--
 std errno,y save error code,
 ldx #0 return NULL pointer
_mapgpb1: tfr x,d move pointer into position for return
#endasm
}

static char			outbuf[256];
static DIRECT char	*outptr = outbuf;
static DIRECT int	bufleft = sizeof(outbuf);

writemem(str, size)
register char  *str;
register int    size;
{
	while (size > bufleft) {
		size -= bufleft;
		while (--bufleft >= 0)
			*outptr++ = *str++;
		flushwin();
	}
	bufleft -= size;
	while (--size >= 0)
		*outptr++ = *str++;
}

flushwin()
{
	write(actwin, outbuf, outptr - outbuf);
	outptr = outbuf;
	bufleft = sizeof(outbuf);
}
