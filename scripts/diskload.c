/*
 * diskload.c - Bare-metal disk writer for Pico-Thing
 *
 * Receives 512-byte blocks via the virtual MC6850 ACIA ($FFC3-$FFC4)
 * and writes them to the virtual PATA drive one ATA sector at a time.
 * Intended to run standalone (no NitrOS-9) to write an OS9Boot disk image
 * from macOS via the Pico's USB serial port.
 *
 * Protocol (host -> 6809, per sector):
 *   SOH  LBA[23:16]  LBA[15:8]  LBA[7:0]  [512 bytes data]  XOR-checksum
 *   <- ACK (0x06) on success, NAK (0x15) on bad checksum or write error
 * End of transfer:
 *   EOT
 *   <- ACK
 *
 * Compile with CMOC (CoCo BASIC / standalone target):
 *   cmoc --coco-basic --org=0x0200 -o diskload.bin scripts/diskload.c
 *
 * Then generate the loader SREC:
 *   python3 scripts/mk_diskload_srec.py diskload.bin > diskload.srec
 *
 * Notes:
 *   - PTIDEBase is $FF40; update ATAREG_BASE if your board differs.
 *   - The data register (offset 0) is 16-bit; all others are 8-bit.
 *   - The virtual ACIA baud rate is ignored by the Pico firmware;
 *     actual throughput is limited by the 6809's polling loop.
 *   - Stack is set up by CMOC's startup code at the top of the binary.
 */

typedef unsigned char  byte;
typedef unsigned int   word;
typedef unsigned long  dword;

/* Virtual MC6850 ACIA */
#define ACIA_CSR  (*(volatile byte *)0xFFC3)  /* status (r) / control (w) */
#define ACIA_DR   (*(volatile byte *)0xFFC4)  /* receive (r) / transmit (w) */

#define ACIA_RDRF 0x01   /* receive data register full */
#define ACIA_TDRE 0x02   /* transmit data register empty */

/* Virtual PATA registers at PTIDEBase = $FF40 */
#define ATAREG_BASE  0xFF40
#define ATA_DATA  (*(volatile word *)(ATAREG_BASE + 0))  /* 16-bit data reg */
#define ATA_ERR   (*(volatile byte *)(ATAREG_BASE + 1))
#define ATA_SCNT  (*(volatile byte *)(ATAREG_BASE + 2))  /* sector count */
#define ATA_SNUM  (*(volatile byte *)(ATAREG_BASE + 3))  /* LBA[7:0]   */
#define ATA_CYLO  (*(volatile byte *)(ATAREG_BASE + 4))  /* LBA[15:8]  */
#define ATA_CYHI  (*(volatile byte *)(ATAREG_BASE + 5))  /* LBA[23:16] */
#define ATA_DSEL  (*(volatile byte *)(ATAREG_BASE + 6))  /* LBA[27:24] | 0xE0 */
#define ATA_STAT  (*(volatile byte *)(ATAREG_BASE + 7))  /* status (read)   */
#define ATA_CMD   (*(volatile byte *)(ATAREG_BASE + 7))  /* command (write) */

#define ATA_BSY   0x80
#define ATA_DRDY  0x40
#define ATA_DRQ   0x08
#define ATA_ERR_   0x01

/* Protocol framing */
#define SOH  0x01
#define EOT  0x04
#define ACK  0x06
#define NAK  0x15

/* Progress characters sent back to the host during transfer */
#define PROGRESS_EVERY  64   /* emit '.' every N sectors */

static byte buf[512];

/* -----------------------------------------------------------------------
 * ACIA helpers
 * ----------------------------------------------------------------------- */

static byte acia_getc(void)
{
    while (!(ACIA_CSR & ACIA_RDRF))
        ;
    return ACIA_DR;
}

static void acia_putc(byte c)
{
    while (!(ACIA_CSR & ACIA_TDRE))
        ;
    ACIA_DR = c;
}

static void acia_puts(const char *s)
{
    while (*s)
        acia_putc((byte)*s++);
}

/* -----------------------------------------------------------------------
 * ATA helpers
 * ----------------------------------------------------------------------- */

static void ata_wait_bsy(void)
{
    while (ATA_STAT & ATA_BSY)
        ;
}

/* Write one 512-byte ATA sector at the given LBA.
 * Returns 0 on success, non-zero on error. */
static byte ata_write_sector(dword lba)
{
    word i;

    ata_wait_bsy();
    /* Set up LBA addressing */
    ATA_SCNT = 1;
    ATA_SNUM = (byte)(lba);
    ATA_CYLO = (byte)(lba >> 8);
    ATA_CYHI = (byte)(lba >> 16);
    ATA_DSEL = (byte)(0xE0 | ((lba >> 24) & 0x0F));  /* LBA mode, master */
    ATA_CMD  = 0x30;  /* WRITE SECTORS (with retry) */

    /* Wait for DRQ: drive ready to accept data */
    while (!(ATA_STAT & ATA_DRQ))
        ;

    /* Write 256 16-bit words = 512 bytes */
    for (i = 0; i < 256; i++) {
        word w;
        /* Build word from two consecutive bytes (big-endian on 6809 bus) */
        w = (word)buf[i * 2] << 8 | (word)buf[i * 2 + 1];
        ATA_DATA = w;
    }

    ata_wait_bsy();
    return (ATA_STAT & ATA_ERR_) ? 1 : 0;
}

/* -----------------------------------------------------------------------
 * Main
 * ----------------------------------------------------------------------- */

int main(void)
{
    byte  c, chk, got;
    word  i;
    dword lba;
    dword sector_count = 0;

    /* Reset the ACIA: master reset then 8N1, no interrupts */
    ACIA_CSR = 0x03;
    ACIA_CSR = 0x16;  /* /64, 8N1, RTS low, no IRQ */

    acia_puts("\r\ndiskload ready - send disk image\r\n");
    acia_putc('R');   /* machine-readable ready signal */

    for (;;) {
        c = acia_getc();

        if (c == EOT) {
            acia_putc(ACK);
            acia_puts("\r\ndone\r\n");
            for (;;)   /* halt */
                ;
        }

        if (c != SOH) {
            acia_putc(NAK);
            continue;
        }

        /* Read 3-byte LBA (big-endian) */
        lba  = (dword)acia_getc() << 16;
        lba |= (dword)acia_getc() << 8;
        lba |= (dword)acia_getc();

        /* Read 512 bytes and accumulate checksum */
        chk = 0;
        for (i = 0; i < 512; i++) {
            buf[i] = acia_getc();
            chk ^= buf[i];
        }

        /* Read and verify checksum */
        got = acia_getc();
        if (got != chk) {
            acia_putc(NAK);
            continue;
        }

        /* Write to PATA */
        if (ata_write_sector(lba) != 0) {
            acia_putc(NAK);
            continue;
        }

        acia_putc(ACK);

        sector_count++;
        if (sector_count % PROGRESS_EVERY == 0)
            acia_putc('.');   /* progress dot for the human watching */
    }

    return 0;
}
