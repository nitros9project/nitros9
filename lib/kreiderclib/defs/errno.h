/* System call error numbers.
 * May be found in 'errno' after an error has occurred.
 *
 */

#define E_PTHFUL    0xc8 /* Path Table full */
#define E_BPNUM     0xc9 /* Bad Path Number */
#define E_POLL      0xca /* Polling Table Full */
#define E_BMODE     0xcb /* Bad Mode */
#define E_DEVOVF    0xcc /* Device Table Overflow */
#define E_BMID      0xcd /* Bad Module ID */
#define E_DIRFUL    0xce /* Module Directory Full */
#define E_MEMFUL    0xcf /* Process Memory Full */
#define E_UNKSVC    0xd0 /* Unknown Service Code */
#define E_MODBSY    0xd1 /* Module Busy */
#define E_BPADDR    0xd2 /* Bad Page Address */
#define E_EOF       0xd3 /* End of File */
#define E_NES       0xd5 /* Non-Existing Segment */
#define E_FNA       0xd6 /* File Not Accesible */
#define E_BPNAM     0xd7 /* Bad Path Name */
#define E_PNNF      0xd8 /* Path Name Not Found */
#define E_SLF       0xd9 /* Segment List Full */
#define E_CEF       0xda /* Creating Existing File */
#define E_IBA       0xdb /* Illegal Block Address */
#define E_MNF       0xdd /* Module Not Found */
#define E_DELSP     0xdf /* Deleting Stack Pointer memory */
#define E_IPRCID    0xe0 /* Illegal Process ID */
#define E_NOCHLD    0xe2 /* No Children */
#define E_ISWI      0xe3 /* Illegal SWI code */
#define E_PRCABT    0xe4 /* Process Aborted */
#define E_PRCFUL    0xe5 /* Process Table Full */
#define E_IFORKP    0xe6 /* Illegal Fork Parameter */
#define E_KWNMOD    0xe7 /* Known Module */
#define E_BMCRC     0xe8 /* Bad Module CRC */
#define E_USIGP     0xe9 /* Unprocessed Signal Pending */
#define E_NEMOD     0xea /* Non Existing Module */
#define E_BNAM      0xeb /* Bad Name */
#define E_NORAM     0xed /* No Ram Available */
#define E_BPRCID    0xee /* Bad Process ID */
#define E_NOTASK    0xef /* No available Task number */
#define E_UNIT      0xf0 /* Illegal Unit (drive) */
#define E_SECT      0xf1 /* Bad SECTor number */
#define E_WP        0xf2 /* Write Protect */
#define E_CRC       0xf3 /* Bad Check Sum */
#define E_READ      0xf4 /* Read Error */
#define E_WRITE     0xf5 /* Write Error */
#define E_NOTRDY    0xf6 /* Device Not Ready */
#define E_SEEK      0xf7 /* Seek Error */
#define E_FULL      0xf8 /* Media Full */
#define E_BTYP      0xf9 /* Bad Type (incompatable) media */
#define E_DEVBSY    0xfa /* Device Busy */
#define E_DIDC      0xfb /* Disk ID Change */
#define E_LOCK      0xfc /* Record is busy (locked out) */
#define E_SHARE     0xfd /* Non-sharable file busy */
#define E_DEADLK    0xfe /* I/O Deadlock error */

/* errors from arithmetic routines */
#define EFPOVR  40      /* floating point overflow or underflow */
#define EDIVERR 41      /* division by zero */
#define EINTERR 42      /* overflow on conversion of floating point to
                           long integer */
