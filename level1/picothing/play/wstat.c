/*
 * wstat - word statistics for a text file
 *
 * Usage:  wstat [file]
 *
 * Reads the named file, or standard input if none is given, and prints
 * the number of characters, lines, words and sentences, the longest
 * word, and a bar chart of how often each letter appears.
 *
 * Written in K&R C for the Microware OS-9 C compiler: old-style
 * function definitions, no prototypes, no void.  Try changing it -
 * see the readme in this directory for some ideas.
 */

#include <stdio.h>
#include <ctype.h>

#define MAXWORD 32              /* longest word we keep (longer are cut) */
#define BARMAX  40              /* widest bar in the letter chart */

int nchars;                     /* characters read */
int nlines;                     /* lines read */
int nwords;                     /* words seen */
int nsents;                     /* sentences: words ending in . ! or ? */
int nletters;                   /* letters in all the words */
int letters[26];                /* how often each letter appears */

char word[MAXWORD + 1];         /* the word being read */
char longest[MAXWORD + 1];      /* the longest word so far */
int longlen;                    /* and its length */

main(argc, argv)
int argc;
char **argv;
{
    register int c;
    int len;
    FILE *fp;

    fp = stdin;
    if (argc > 1) {
        fp = fopen(argv[1], "r");
        if (fp == NULL) {
            fprintf(stderr, "wstat: can't open %s\n", argv[1]);
            exit(1);
        }
    }

    len = 0;
    while ((c = getc(fp)) != EOF) {
        ++nchars;
        if (c == '\n')
            ++nlines;
        if (c == '.' || c == '!' || c == '?')
            ++nsents;
        if (isascii(c) && isalpha(c)) {
            if (isupper(c))
                c = _tolower(c);
            ++letters[c - 'a'];
            ++nletters;
            if (len < MAXWORD)
                word[len++] = c;
        } else if (len > 0) {
            endword(len);
            len = 0;
        }
    }
    if (len > 0)
        endword(len);

    report(argc > 1 ? argv[1] : "standard input");
    exit(0);
}

/*
 * endword - count the word just read and remember it if it is the
 * longest so far
 */
endword(len)
int len;
{
    register int i;

    ++nwords;
    if (len > longlen) {
        for (i = 0; i < len; ++i)
            longest[i] = word[i];
        longest[len] = '\0';
        longlen = len;
    }
}

/*
 * report - print the counts and the letter chart
 */
report(name)
char *name;
{
    register int i;
    int most, scale;

    printf("wstat: %s\n\n", name);
    printf("  characters  %5d\n", nchars);
    printf("  lines       %5d\n", nlines);
    printf("  words       %5d\n", nwords);
    printf("  sentences   %5d\n", nsents);
    if (nwords > 0)
        printf("  mean word   %5d letters\n", nletters / nwords);
    if (longlen > 0)
        printf("  longest     \"%s\" (%d letters)\n", longest, longlen);

    /* scale the bars so the most common letter is at most BARMAX long */
    most = 0;
    for (i = 0; i < 26; ++i)
        if (letters[i] > most)
            most = letters[i];
    scale = (most + BARMAX - 1) / BARMAX;
    if (scale < 1)
        scale = 1;

    printf("\n");
    for (i = 0; i < 26; ++i) {
        printf("  %c %4d ", 'a' + i, letters[i]);
        bar(letters[i] / scale);
        printf("\n");
    }
}

/*
 * bar - print n stars
 */
bar(n)
register int n;
{
    while (n-- > 0)
        putchar('*');
}
