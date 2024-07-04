/*
 * mat.h - Matrix functions
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

#ifndef _MAT_H
#define _MAT_H

typedef struct
{
	int             m_rows,
	                m_cols;
	double          m_value[1];
}               MAT;


double          m_cofactor(), m_determinant();
MAT            *m_copy(), *m_create(), *m_invert(), *m_transpose(),
               *m_multiply(), *m_solve(), *m_add(), *m_sub(), *m_read();

#define  m_v(m, r, c)   (m->m_value[r * (m->m_cols) + c])
#define  M_NULL         ((MAT *)0)

#endif				/* _MAT_H */
