/*
 * ViewVEF 1.0 by Vaughn Cato
 * For use in displaying flicker VEF files
 */

#include <stdio.h>
#include <string.h>

int             actwin;
char           *gpbufptr;
char           *mapgpb();

main(argc, argv)
int             argc;
char           *argv[];
{
	int             winfile1, winfile2;
	int				x, groupnum, bufnum, flicker, file, scrnum, pauselen = -1;
	char            c, newname[128];

	if (argc < 2) {
		printf("Usage: viewvef <vef file> [<pause length>]");
		printf("       Displays normal or flicker VEF files\n");
		exit(1);
	}
	if (argc == 3)
		pauselen = atoi(argv[2]);
	for (scrnum = 0; scrnum <= 1; ++scrnum) {
		if (scrnum == 0) {
			if ((file = open(argv[1], 1)) == -1) {
				fprintf(stderr, "Cannot open %s\n", argv[scrnum + 1]);
				exit(errno);
			}
			winfile1 = newwin();
			groupnum = procid();
			bufnum = 1;
			getblk(groupnum, bufnum, 0, 0, 639, 1);
			flushwin();
			if ((gpbufptr = mapgpb(winfile1, groupnum, bufnum, 1)) == NULL)
				exit(errno);
		} else {
			strcpy(newname, argv[1]);
			strcat(newname, ".2");
			if ((file = open(newname, 1)) == -1)
				break;
			flicker = 1;
			winfile2 = newwin();
		}
		read(file, &c, 1);
		read(file, &c, 1);
		for (x = 0; x < 16; ++x) {
			read(file, &c, 1);
			palette(x, c);
		}
		for (x = 0; x < 8; ++x)
			read(file, gpbufptr, 160);
		for (x = 0; x < 192; ++x) {
			read(file, gpbufptr, 160);
			putblk(groupnum, bufnum, 0, x);
			flushwin();
		}
	}
	if (flicker) {
		pauselen *= 30;
		for (;;) {
			actwin = winfile1;
			select();
			flushwin();
			sleep(2);
			if (ready(winfile1)) {
				read(winfile1, &c, 1);
				if (c == 13)
					break;
			}
			actwin = winfile2;
			select();
			flushwin();
			sleep(2);
			if (ready(winfile2)) {
				read(winfile2, &c, 1);
				if (c == 13)
					break;
			}
			if (pauselen == 0)
				break;
			if (pauselen > 0)
				--pauselen;
		}
	} else {
		if (pauselen >= 0) {
			if (pauselen > 0)
				sleep(60 * pauselen);
		} else {
			do {
				read(winfile1, &c, 1);
			} while (c != 13);
		}
	}
	mapgpb(winfile1, groupnum, bufnum, 0);
	actwin = 1;
	select();
	flushwin();
	close(winfile1);
	if (flicker)
		close(winfile2);
}

sleep(ticks)
int             ticks;
{
#asm
 ldx 4,s
 os9 $0a
#endasm
}

newwin()
{
	int             winfile, windesc;

	windesc = attach("w");
	if ((winfile = open("/w", 3)) == -1)
		exit(errno);
	actwin = winfile;
	dwset(8, 0, 0, 40, 24, 0, 0, 0);
	curoff();
	select();
	flushwin();
	detach(windesc);
	return (winfile);
}

fcolor(c)
	int             c;
{
	static char     outstr[] = {0x1b, 0x32, 0};

	outstr[2] = c;
	writemem(outstr, sizeof(outstr));
}

dwset(sty, cpx, cpy, szx, szy, prn1, prn2, prn3)
	int             sty, cpx, cpy, szx, szy, prn1, prn2, prn3;
{
	static char     outstr[] = {0x1b, 0x20, 0, 0, 0, 0, 0, 0, 0, 0};
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

curoff()
{
	static char     outstr[] = {0x05, 0x20};

	writemem(outstr, sizeof(outstr));
}

writemem(str, size)
	char           *str;
	int             size;
{
	while (size-- > 0)
		writechr(*str++);
}

writestr(file, str)
	int             file;
	char           *str;
{
	writeln(file, str, strlen(str));
}

char            outbuf[256];
char           *outptr = outbuf;

writechr(c)
	char            c;
{
	if (outptr >= outbuf + sizeof(outbuf))
		flushwin();
	*outptr++ = c;
}

flushwin()
{
	write(actwin, outbuf, outptr - outbuf);
	outptr = outbuf;
}

attach(str)
	char           *str;
{
#asm
 lda #3
 ldx 4,s
 os9 $80
 bcs _atach1
 tfr u,d
 bra _atach2
_atach1:
 clra
 std errno,y
 ldd #-1
_atach2:
#endasm
}

detach(dte)
int             dte;
{
#asm
 ldu 4,s
 os9 $81
 bcs _detch1
 ldd #0
 bra _detch2
_detch1:
 clra
 std errno,y
 ldd #-1
_detch2:
#endasm
}

char           *
mapgpb(path, grp, bfn, action)
	int             path, grp, bfn, action;
{
#asm
 lda 7,s
 ldb 9,s
 tfr d,x
 lda 5,s
 ldb #$84
 pshs y
 ldy 10+2,s
 os9 $8e
 puls y
 bcc _mapgpb1
 clra
 std errno,y
 ldx #0
_mapgpb1:
 tfr x,d
#endasm
}

ready(path)
	int             path;
{
#asm
 lda 5,s
 ldb #1
 os9 $8d
 bcc _ready1
 ldd #0
 bra _ready2
_ready1:
 ldd #1
_ready2:
#endasm
}

procid()
{
#asm
 pshs y
 os9 $0c
 tfr a,b
 puls y
 clra
#endasm
}
