/*
 * SetMap - Palette creator for ViewGIF 2.0
 * These routines are the heart of the color analysis.  They take the
 * global bitmap and, based on the dithering factor, produce a CoCo color
 * palette.
 */

#include "viewgif.h"

int		toler2(), exact();
bool	nearcolor();

/*
 * setmap() -- determine whether, given the specified dithering factor,
 * there are CLUTs for the screens we've been told to use that will let
 * us come reasonably close to representing the colors in the GIF image.
 * We change the semantics from the original version, returning FALSE
 * if not all the CLUT etnries can be fit in, or TRUE if they all work.
 *
 * Method: look for approximations to each color in use in terms of colors
 * already in the CLUTs.  If none is close enough, then add the color
 * (or some decomposition thereof, in the multiple screen case) to the
 * CLUTs.  If there's no room left to add the color, we return FALSE.
 *
 * Note: we're trying to trade space for speed in the innermost loop of
 * doline() by always leaving an end marker, avoiding double testing in
 * said loop.  We'll see how it works out.
 */
bool
setmap()
{
	rgbcolor			next;
	register int		add;
	register rgbcolor	*gcscan;
	register xlate		*trscan;
	int         		numtrans, tolrnce, x, uplim, lowlim;

	/* should be a loop if we really do change NSCREENS */
	screen[0].clutsize = screen[1].clutsize = 0;

	lowlim = low0;
	uplim = up0;

	if (dfactor > 0) {
		tolrnce = 0;
		lowlim -= dfactor;
	} else
		tolrnce = -dfactor;

	if (dfactor > (int) flicker)
		uplim += dfactor;

	for (gcscan = globclut, x = 0; x < globcolors; gcscan++, x++) {
		if (coloruse[x]) {
			numtrans = 0;
			trscan = &transtab[x][0];
			for (add = lowlim; add < uplim; add = minadd(gcscan, add)) {
				trscan->addval = add;
				addoff(&next, gcscan, add);
				if (!(*approx)(&next, trscan, tolrnce))
					return FALSE;
				if (++numtrans > 4)
					fatal("BUG: numtrans>4");
				trscan++;
			}
			/* mark end of transtab entries for this color */
			trscan->addval = BOGUSDITH;
		}
	}
	return TRUE;
}

addoff(color, color0, offset)
register BYTE	*color, *color0;
int				offset;
{
	register int	accum, x;

	for (x = 3; --x >= 0; ) {
		if ((accum = arith(*color0++) + offset) > 0xff)
			accum = 0xff;
		*color++ = accum;
	}
}

/*
 * approx1() -- the approximation seeker if there's only one screen
 */
bool
approx1(goal, trans, toler)
rgbcolor	*goal;
xlate		*trans;
int			toler;
{
	register rgbcolor	*cscan, *nearest;
	int					x, mintoler, tv;

	mintoler = toler + 1;
	nearest = NULL;
	for (cscan = screen[0].clut, x = screen[0].clutsize; --x >= 0; cscan++) {
		if ((tv = tolerval(cscan, goal)) < mintoler) {
			nearest = cscan;
			if ((mintoler = tv) == 0)
				break;
		}
	}

	if (nearest == NULL) {
		if (++screen[0].clutsize > MCCLUT)
			return FALSE;
		cscan->red   = arith(goal->red) / SCALE1;
		cscan->green = arith(goal->green) / SCALE1;
		cscan->blue  = arith(goal->blue) / SCALE1;
		nearest = cscan;
	}
	trans->clutval[0] = nearest - screen[0].clut;
	return TRUE;
}

/*
 * approx2() -- a two-screen approximator
 *
 * The general idea here takes multiple passes:
 * 1. Iterate over sums of pairs of colors taken one from each screen.
 * 2. If that fails, then for each screen, try adding something that
 *    should come close with each of the colors in the CLUT for the
 *    other screen.  (Try it with the smallest CLUT first, to save space.)
 * 3. If *that* fails, extend both CLUTs with the new color (at half
 *    intensity).
 *
 * Since in step 1, which one would think eats the most time, viewgif was
 * making repeated calls to nearcolor(), we've switched over to keeping
 * a table remembering which colors in the palettes are near as determined
 * by nearcolor().  (Donald Michie would be proud of us.)
 */

static bool	neartab[MCCLUT][MCCLUT];

#define ROW		1
#define COLUMN	2

bool
approx2(goal, trans, toler)
rgbcolor	*goal;
xlate		*trans;
int			toler;
{
	register int		c1, c0;
	rgbcolor			*scan0, *scan1, *near0, *near1;
	cocoscreen			*extend, *exam, *temp;
	int					(*tolfun)();
	char				*near_row;
	rgbcolor			scalergb;
	int					mintoler, tv;
	int					x;
	bool				found;

	scalergb.red   = arith(goal->red) / SCALE2;
	scalergb.green = arith(goal->green) / SCALE2;
	scalergb.blue  = arith(goal->blue) / SCALE2;

	if (toler > 0)
		tolfun = toler2;
	else {
		goal = &scalergb;
		tolfun = exact;
	}

	found = FALSE;
	mintoler = toler + 1;

	for (scan0 = &screen[0].clut[c0 = screen[0].clutsize];
		 scan0--, --c0 >= 0; )
	{
		near_row = neartab[c0];
		for (c1 = screen[1].clutsize; --c1 >= 0; ) {
			if (near_row[c1]) {
				scan1 = &screen[1].clut[c1];
				if ((tv = (*tolfun)(scan0, scan1, goal)) < mintoler) {
					near0 = scan0;
					near1 = scan1;
					found = TRUE;
					if ((mintoler = tv) == 0)
						goto out;
				}
			}
		}
	}

out:
	if (!found) {
		if (screen[1].clutsize < screen[0].clutsize) {
			extend = &screen[1];
			exam = &screen[0];
		} else {
			extend = &screen[0];
			exam = &screen[1];
		}
		for (x = 2; --x >= 0; ) {
			if (extend->clutsize < MCCLUT) {
				near0 = &extend->clut[extend->clutsize];
				for (scan1 = &exam->clut[c1 = exam->clutsize];
					 scan1--, --c1 >= 0; )
				{
					forcenear(near0, scan1, &scalergb);
					if ((tv = (*tolfun)(near0, scan1, goal)) < mintoler) {
						near1 = scan1;
						found = TRUE;
						if ((mintoler = tv) == 0)
							break;
					}
				}
				if (found)
					break;
			}
			temp = extend;
			extend = exam;
			exam = temp;
		}
	
		if (found) {
			if (mintoler > 0)
				forcenear(near0, near1, &scalergb);
			extend->clutsize++;
			if (extend == &screen[0])
				nearfill(ROW);
			else {
				temp = (cocoscreen *) near0;
				near0 = near1;
				near1 = (rgbcolor *) temp;
				nearfill(COLUMN);
			}
		} else {
			if (screen[0].clutsize >= MCCLUT ||
				screen[1].clutsize >= MCCLUT)
				return FALSE;
			near0 = &screen[0].clut[screen[0].clutsize++];
			near0->red   = arith(scalergb.red) / 2;
			near0->green = arith(scalergb.green) / 2;
			near0->blue  = arith(scalergb.blue) / 2;
			near1 = &screen[1].clut[screen[1].clutsize++];
			near1->red   = (arith(scalergb.red) + 1) / 2;
			near1->green = (arith(scalergb.green) + 1) / 2;
			near1->blue  = (arith(scalergb.blue) + 1) / 2;
			nearfill(ROW | COLUMN);
		}
	}
	trans->clutval[0] = near0 - screen[0].clut;
	trans->clutval[1] = near1 - screen[1].clut;
	return TRUE;
}

nearfill(section)
int	section;
{
	register int	i, j;
	rgbcolor		*newrgb;

	if (section & ROW) {
		newrgb = &screen[0].clut[j = screen[0].clutsize - 1];
		for (i = screen[1].clutsize; --i >= 0; )
			neartab[j][i] = nearcolor(newrgb, &screen[1].clut[i]);
	}
	if (section & COLUMN) {
		newrgb = &screen[1].clut[j = screen[1].clutsize - 1];
		for (i = screen[0].clutsize; --i >= 0; )
			neartab[i][j] = nearcolor(&screen[0].clut[i], newrgb);
	}
}

/*
 * nearcolor() -- tell approx2() whether two colors are close enough
 * to be considered for approximate summation to a color in the GIF CLUT.
 */
bool
nearcolor(c1, c2)
register rgbcolor	*c1, *c2;
{
	return abs(arith(c2->red)   - arith(c1->red))   < 2 &&
		   abs(arith(c2->green) - arith(c1->green)) < 2 &&
		   abs(arith(c2->blue)  - arith(c1->blue))  < 2;
}

/*
 * forcenear() -- stuff a color into a CLUT that is guaranteed to
 * pass the nearcolor test with the other fixed color (so we don't
 * have to call nearcolor() explicitly), and should come close to
 * adding to the fixed color (already in the other screen's CLUT)
 * to give a specified goal color from the GIF CLUT.
 */
forcenear(vary, fixed, goal)
register BYTE   vary[], fixed[], goal[];
{
	register int    d, x;

	for (x = 3; --x >= 0; ) {
		if ((d = arith(*vary = *goal++ - *fixed) - arith(*fixed)) < 0)
			d = -1;
		else if (d > 0)
			d = 1;
		*vary++ = *fixed++ + d;
	}
}

int
minadd(color, add)
register BYTE	*color;
int             add;
{
	int             maxval, tryadd, x;

	maxval = 0;
	for (x = 3; --x >= 0; ) {
		if ((tryadd = (arith(*color++) + add) % minmod) > maxval)
			maxval = tryadd;
	}
	return minmod - maxval + add;
}

int
tolerval(ccolor, gcolor)
register BYTE	*ccolor, *gcolor;
{
	int     x, v, mv;

	mv = 0;
	for (x = 3; --x >= 0; ) {
		v = abs(SCALE1 * *ccolor++ + SCALE1 / 2 - arith(*gcolor++)) -
			SCALE1 / 2;
		if (v > mv)
			mv = v;
	}
	return mv;
}

int
toler2(ccolor1, ccolor2, gcolor)
register BYTE	*ccolor1, *ccolor2, *gcolor;
{
	int     x, v, mv;

	mv = 0;
	for (x = 3; --x >= 0; ) {
		v = abs(SCALE2 * (*ccolor1++ + *ccolor2++) + SCALE2 / 2 -
				arith(*gcolor++)) - SCALE2 / 2;
		if (v > mv)
			mv = v;
	}
	return mv;
}

int
exact(ccolor1, ccolor2, gcolor)
register BYTE	*ccolor1, *ccolor2, *gcolor;
{
	if (arith(ccolor1[0]) + arith(ccolor2[0]) != arith(gcolor[0]))
		return 2;
	if (arith(ccolor1[1]) + arith(ccolor2[1]) != arith(gcolor[1]))
		return 2;
	if (arith(ccolor1[2]) + arith(ccolor2[2]) != arith(gcolor[2]))
		return 2;
	return 0;
}
