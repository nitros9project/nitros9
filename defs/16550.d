* UART Register Definitions for 16550/16650/16750 UARTs

                    org       0
UART_TRHB           rmb       1         transmit/receive hold buffer
UART_DLL            equ       UART_TRHB divisor latch low byte
UART_IER            rmb       1         interrupt enable register
UART_DLH            equ       UART_IER  divisor latch high byte
UART_FCR            rmb       1         FIFO control register
UART_IIR            equ       UART_FCR  interrupt identification register
UART_LCR            rmb       1         line control register
UART_MCR            rmb       1         modem control register
UART_LSR            rmb       1         line status register
UART_MSR            rmb       1         modem status register
UART_SR             rmb       1         scratch register

* FCR register definitions
FCR_RXT_5           equ       0x00
FCR_RXT_6           equ       0x40
FCR_RXT_7           equ       0x80
FCR_RXT_8           equ       0xC0
FCR_FIFO64          equ       0x20
FCR_TXR             equ       0x04
FCR_RXR             equ       0x02
FCR_FIFOE           equ       0x01
FCR_RXT_MASK        equ       0xC0      RX trigger level bits

* Interrupt enable flags
UINT_LOW_POWER      equ       0x20      enable low power mode (16750)
UINT_SLEEP_MODE     equ       0x10      enable sleep mode (16750)
UINT_MODEM_STATUS   equ       0x08      enable modem status interrupt
UINT_LINE_STATUS    equ       0x04      enable receiver line status interrupt
UINT_THR_EMPTY      equ       0x02      enable transmit holding register empty interrupt
UINT_DATA_AVAIL     equ       0x01      enable receive data available interrupt

* Interrupt identification register codes
IIR_FIFO_ENABLED    equ       0x80      FIFO is enabled
IIR_FIFO_NONFUNC    equ       0x40      FIFO is not functioning
IIR_FIFO_64BYTE     equ       0x20      64 byte FIFO enabled (16750)
IIR_TIMEOUT         equ       0x0C      time-out interrupt (16550 and later)
IIR_MODEM_STATUS    equ       0x08      line status interrupt
IIR_DATA_AVAIL      equ       0x04      data available interrupt
IIR_THR_EMPTY       equ       0x02      transmit holding register empty interrupt
IIR_INTERRUPT_PENDING equ       0x01      interrupt pending flag (0 = interrupt pending, 1 = no interrupt)
IIR_INTID_MASK      equ   0x0E          bits 3..1 = interrupt ID

* Line control register codes
LCR_DLB             equ       0x80      divisor latch access bit
LCR_SBE             equ       0x60      set break enable

LCR_PARITY_NONE     equ       0x00      parity: none
LCR_PARITY_ODD      equ       0x08      parity: odd
LCR_PARITY_EVEN     equ       0x18      parity: even
LCR_PARITY_MARK     equ       0x28      parity: mark
LCR_PARITY_SPACE    equ       0x38      parity: space
LCR_PARITY_MASK     equ       0x38

LCR_STOPBIT_1       equ       0x00      one stop bit
LCR_STOPBIT_2       equ       0x04      1.5 or 2 stop bits

LCR_DATABITS_5      equ       0x00      data bits: 5
LCR_DATABITS_6      equ       0x01      data bits: 6
LCR_DATABITS_7      equ       0x02      data bits: 7
LCR_DATABITS_8      equ       0x03      data bits: 8
LCR_DATABITS_MASK   equ       0x03

LSR_ERR_RECEIVE     equ       0x80      error in received fifo
LSR_XMIT_DONE       equ       0x40      all data has been transmitted
LSR_XMIT_EMPTY      equ       0x20      empty transmit holding register
LSR_BREAK_INT       equ       0x10      break interrupt
LSR_ERR_FRAME       equ       0x08      framing error
LSR_ERR_PARITY      equ       0x04      parity error
LSR_ERR_OVERRUN     equ       0x02      overrun error
LSR_DATA_AVAIL      equ       0x01      data is ready in the receive buffer
LSR_ERR_MASK        equ       0x1E      any RX error
LSR_TX_MASK         equ       0x60      THRE + TEMT

* Modem Control Register bit positions 
MCR_DTR	equ %00000001 data terminal ready bit
MCR_RTS	equ %00000010 request to send bit
MCR_OUT1 equ %00000100 output 1 
MCR_OUT2 equ %00001000 output 2
* OUT2 is commonly used in PC Modems to enable interrupts
MCR_LOOP equ %00010000 loopback mode bit
MCR_ACTS equ %00100000 auto CTS flow control enable
MCR_ACTSRTS equ	%00100010 automatic CTS/RTS	

* Modem Status Register bits
MSR_DCTS            equ   0x01     CTS changed
MSR_DDSR            equ   0x02     DSR changed
MSR_TERI            equ   0x04     trailing edge ring indicator
MSR_DDCD            equ   0x08     carrier detect changed
MSR_CTS             equ   0x10     CTS state
MSR_DSR             equ   0x20     DSR state
MSR_RI              equ   0x40     ring indicator state
MSR_CD              equ   0x80     carrier detect state

* Error bits
UERR_OE	equ	%00000010 overrun error
UERR_PE	equ	%00000100 parity error
UERR_FE	equ	%00001000 framing error
UERR_BI	equ	%00010000 break interrupt
UERR_THRE equ %00100000 transmitter holding register empty
UERR_TEMT equ %01000000 transmitter empty
UERR_FDE equ %10000000 FIFO data error

