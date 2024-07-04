/*
 * types.h - Portable scalar type definitions
 *
 * Notes:
 *
 * Edt/Rev  YYYY/MM/DD  Modified by
 * Comment
 * ------------------------------------------------------------------
 *          2005/08/14  Boisy G. Pitre
 * Created.
 *
 *          2024/07/04  Boisy G. Pitre
 * Incorporated into CMOC.
 */

#ifndef _TYPES_H
#define _TYPES_H

#define _CHAR8_T
typedef	char				char8_t;
typedef	unsigned char		u_char_t;
typedef	unsigned char		uchar8_t;

#define _INT8_T
typedef	char				int8_t;
typedef	unsigned char		u_int8_t;
typedef	unsigned char		uint8_t;

#define _INT16_T
typedef	int					int16_t;
typedef	unsigned short		u_int16_t;
typedef	unsigned short		uint16_t;

#define _INT32_T
typedef	long				int32_t;
typedef	unsigned long		u_int32_t;
typedef	unsigned long		uint32_t;

#endif				/* _TYPES_H */
