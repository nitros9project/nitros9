struct registers {
    char rg_cc,rg_a,rg_b,rg_dp;
    unsigned rg_x,rg_y,rg_u;
    } ;

#define F_LINK      0x00 /* Link to Module */
#define F_LOAD      0x01 /* Load Module from File */
#define F_UNLINK    0x02 /* Unlink Module */
#define F_FORK      0x03 /* Start New Process */
#define F_WAIT      0x04 /* Wait for Child Process to Die */
#define F_CHAIN     0x05 /* Chain Process to New Module */
#define F_EXIT      0x06 /* Terminate Process */
#define F_MEM       0x07 /* Set Memory Size */
#define F_SEND      0x08 /* Send Signal to Process */
#define F_ICPT      0x09 /* Set Signal Intercept */
#define F_SLEEP     0x0a /* Suspend Process */
#define F_SSPD      0x0b /* Suspend Process */
#define F_ID        0x0c /* Return Process ID */
#define F_SPRIOR    0x0d /* Set Process Priority */
#define F_SSWI      0x0e /* Set Software Interrupt */
#define F_PERR      0x0f /* Print Error */
#define F_PRSNAM    0x10 /* Parse Pathlist Name */
#define F_CMPNAM    0x11 /* Compare Two Names */
#define F_SCHBIT    0x12 /* Search Bit Map */
#define F_ALLBIT    0x13 /* Allocate in Bit Map */
#define F_DELBIT    0x14 /* Deallocate in Bit Map */
#define F_TIME      0x15 /* Get Current Time */
#define F_STIME     0x16 /* Set Current Time */
#define F_CRC       0x17 /* Generate CRC */
#define F_GPRDSC    0x18 /* get Process Descriptor copy */
#define F_GBLKMP    0x19 /* get System Block Map copy */
#define F_GMODDR    0x1a /* get Module Directory copy */
#define F_CPYMEM    0x1b /* Copy External Memory */
#define F_SUSER     0x1c /* Set User ID number */
#define F_UNLOAD    0x1d /* Unlink Module by name */
#define F_SRQMEM    0x28 /* System Memory Request */
#define F_SRTMEM    0x29 /* System Memory Return */
#define F_IRQ       0x2a /* Enter IRQ Polling Table */
#define F_IOQU      0x2b /* Enter I/O Queue */
#define F_APROC     0x2c /* Enter Active Process Queue */
#define F_NPROC     0x2d /* Start Next Process */
#define F_VMODUL    0x2e /* Validate Module */
#define F_FIND64    0x2f /* Find Process/Path Descriptor */
#define F_ALL64     0x30 /* Allocate Process/Path Descriptor */
#define F_RET64     0x31 /* Return Process/Path Descriptor */
#define F_SSVC      0x32 /* Service Request Table Initialization */
#define F_IODEL     0x33 /* Delete I/O Module */
#define F_SLINK     0x34 /* System Link */
#define F_BOOT      0x35 /* Bootstrap System */
#define F_BTMEM     0x36 /* Bootstrap Memory Request */
#define F_GPROCP    0x37 /* Get Process ptr */
#define F_MOVE      0x38 /* Move Data (low bound first) */
#define F_ALLRAM    0x39 /* Allocate RAM blocks */
#define F_ALLIMG    0x3a /* Allocate Image RAM blocks */
#define F_DELIMG    0x3b /* Deallocate Image RAM blocks */
#define F_SETIMG    0x3c /* Set Process DAT Image */
#define F_FREELB    0x3d /* Get Free Low Block */
#define F_FREEHB    0x3e /* Get Free High Block */
#define F_ALLTSK    0x3f /* Allocate Process Task number */
#define F_DELTSK    0x40 /* Deallocate Process Task number */
#define F_SETTSK    0x41 /* Set Process Task DAT registers */
#define F_RESTSK    0x42 /* Reserve Task number */
#define F_RELTSK    0x43 /* Release Task number */
#define F_DATLOG    0x44 /* Convert DAT Block/Offset to Logical */
#define F_DATTMP    0x45 /* Make temporary DAT image */
#define F_LDAXY     0x46 /* Load A [X,[Y]] */
#define F_LDAXYP    0x47 /* Load A [X+,[Y]] */
#define F_LDDDXY    0x48 /* Load D [D+X,[Y]] */
#define F_LDABX     0x49 /* Load A from 0,X in task B */
#define F_STABX     0x4a /* Store A at 0,X in task B */
#define F_ALLPRC    0x4b /* Allocate Process Descriptor */
#define F_DELPRC    0x4c /* Deallocate Process Descriptor */
#define F_ELINK     0x4d /* Link using Module Directory Entry */
#define F_FMODUL    0x4e /* Find Module Directory Entry */
#define F_MAPBLK    0x4f /* Map Specific Block */
#define F_CLRBLK    0x50 /* Clear Specific Block */
#define F_DELRAM    0x51 /* Deallocate RAM blocks */

#define I_ATTACH    0x80 /* Attach I/O Device */
#define I_DETACH    0x81 /* Detach I/O Device */
#define I_DUP       0x82 /* Duplicate Path */
#define I_CREATE    0x83 /* Create New File */
#define I_OPEN      0x84 /* Open Existing File */
#define I_MAKDIR    0x85 /* Make Directory File */
#define I_CHGDIR    0x86 /* Change Default Directory */
#define I_DELETE    0x87 /* Delete File */
#define I_SEEK      0x88 /* Change Current Position */
#define I_READ      0x89 /* Read Data */
#define I_WRITE     0x8a /* Write Data */
#define I_READLN    0x8b /* Read Line of ASCII Data */
#define I_WRITLN    0x8c /* Write Line of ASCII Data */
#define I_GETSTT    0x8d /* Get Path Status */
#define I_SETSTT    0x8e /* Set Path Status */
#define I_CLOSE     0x8f /* Close Path */
#define I_DELETX    0x90 /* Delete from current exec dir */

#define SS_OPT      0x00 /* Read/Write PD Options */
#define SS_READY    0x01 /* Check for Device Ready */
#define SS_SIZE     0x02 /* Read/Write File Size */
#define SS_RESET    0x03 /* Device Restore */
#define SS_WTRK     0x04 /* Device Write Track */
#define SS_POS      0x05 /* Get File Current Position */
#define SS_EOF      0x06 /* Test for End of File */
#define SS_LINK     0x07 /* Link to Status routines */
#define SS_ULINK    0x08 /* Unlink Status routines */
#define SS_FEED     0x09 /* issue form feed */
#define SS_FRZ      0x0a /* Freeze DD_ information */
#define SS_SPT      0x0b /* Set DD_TKS to given value */
#define SS_SQD      0x0c /* Sequence down hard disk */
#define SS_DCMD     0x0d /* Send direct command to disk */
#define SS_DEVNM    0x0e /* Return Device name (32-bytes at [X]) */
#define SS_FD       0x0f /* Return File Descriptor (Y-bytes at [X]) */
#define SS_TICKS    0x10 /* Set Lockout honor duration */
#define SS_LOCK     0x11 /* Lock/Release record */
#define SS_DSTAT    0x12 /* Return Display Status (CoCo) */
#define SS_JOY      0x13 /* Return Joystick Value (CoCo) */
#define SS_BLKRD    0x14 /* Block Read */
#define SS_BLKWR    0x15 /* Block Write */
#define SS_RETEN    0x16 /* Retension cycle */
#define SS_WFM      0x17 /* Write File Mark */
#define SS_RFM      0x18 /* Read past File Mark */
#define SS_ELOG     0x19 /* Read Error Log */
#define SS_SSIG     0x1a /* Send signal on data ready */
#define SS_RELEA    0x1b /* Release device */
