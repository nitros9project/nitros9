/*
 * stdio.h - C standard I/O definitions
 *
 * Notes:
 *
 * Edt/Rev  YYYY/MM/DD  Modified by
 * Comment
 * ------------------------------------------------------------------
 *          2005/08/12  Boisy G. Pitre
 * Brought in from Carl Kreider's CLIB package.
 *
 *          2024/07/04  Boisy G. Pitre
 * Incorporated into CMOC.
 */

#ifndef _STDIO_H
#define _STDIO_H

/*
 * type lengths regardless of compiler in use: "char" for 8 bits "WORD" for
 * 16 bits "long" for 32 bits
 */

typedef short   WORD;		/* always 16 bits */

#ifdef OSK
#define BUFSIZ 256
#define _NFILE 32
#else
#ifdef OS9
#define BUFSIZ 256
#define _NFILE 16
#endif
#endif

typedef struct _iobuf
{
	char           *_ptr,	/* buffer pointer */
	               *_base,	/* buffer base address */
	               *_end;	/* buffer end address */
	WORD            _flag;	/* file status */
	WORD            _fd;	/* file path number */
	char            _save;	/* for 'ungetc' when unbuffered */
	WORD            _bufsiz;/* size of data buffer */
} FILE;

extern FILE     _iob[_NFILE];

#define _READ       1
#define _WRITE      2
#define _UNBUF      4
#define _BIGBUF     8
#define _EOF        0x10
#define _ERR        0x20
#define _SCF        0x40
#define _RBF        0x80
#define _DEVMASK    0xc0
#define _WRITTEN    0x0100	/* buffer written in update mode */
#define _INIT       0x8000	/* _iob initialized */

#define EOF (-1)
#define EOL 13
#define NULL 0

#define stdin  (&_iob[0])
#define stdout (&_iob[1])
#define stderr (&_iob[2])

#ifdef OSK
#define PMODE READ|WRITE	/* r/w for owner */
#else
#define PMODE  0xb		/* r/w for owner, r for others */
#endif

#define fgetc           getc
#define putchar(c)      putc(c,stdout)
#define getchar()       getc(stdin)
#define ferror(p)       ((p)->_flag&_ERR)
#define feof(p)         ((p)->_flag&_EOF)
#define clearerr(p)     ((p)->_flag&=~_ERR)
#define cleareof(p)     ((p)->_flag&=~_EOF)
#define fileno(p)       ((p)->_fd)

long            ftell();

#define	SEEK_SET	0	/* set file offset to offset */
#define	SEEK_CUR	1	/* set file offset to current plus offset */
#define	SEEK_END	2	/* set file offset to EOF plus offset */

int printf(const char *format, ...);
int fprintf(FILE *stream, const char *format, ...);
FILE *fopen(char *path, char *mode);
FILE *freopen(char *path, char *mode, FILE *stream);
int fread(void *ptr, int size, int nitems, FILE *stream);
int fwrite(void *ptr, int size, int nitems, FILE *stream);
int fseek(FILE *stream, int offset, int whence);
long ftell(FILE *stream);
int fclose(FILE *stream);

int sprintf(char *str, const char *format, ...);

#endif				/* _STDIO_H */
