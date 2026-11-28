/* OS-9/6809 runtime regression; build with LLVM and the fixed OS-9 C bridge.
   Requires CoWin, grfdrv and /w. Results go to /dd/maptest.result. */
#include <os.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
extern int cmoc_open(const char *, int);
extern int cmoc_creat(const char *, int);

static int report(int status, unsigned address, unsigned length)
{
    unsigned values[3];
    int fd=cmoc_creat("/dd/maptest.result",3);
    values[0]=status;values[1]=address;values[2]=length;
    if(fd<0)return 99;
    write(fd,(status==0 ? "PASS" : "FAIL"),4);
    write(fd,values,sizeof(values));close(fd);
    return status;
}

int main(void)
{
    registers_6809 regs;
    unsigned address,length;
    int fd=cmoc_open("/w",3),i;
    char *pixels;
    static char setup[]={27,32,8,0,0,40,24,0,0,0,27,33,
                         27,44,77,1,0,0,0,0,2,127,0,1};
    static char put[]={27,45,77,1,0,0,0,0};
    static char get[]={27,44,77,1,0,0,0,0,2,127,0,1};
    static char kill[]={27,42,77,1};
    if(fd<0)return report(1,0,0);
    if(write(fd,setup,sizeof(setup))!=sizeof(setup))return report(2,0,0);
    memset(&regs,0,sizeof(regs));regs.a=fd;regs.b=0x84;
    regs.x=0x4d01;regs.y=1;
    if(_os_syscall(0x8e,&regs))return report(3,0,0);
    address=regs.x;length=regs.y;
    if(length!=160)return report(4,address,length);
    /* Repeat the request with the input selector, not the returned pointer. */
    regs.x=0x4d01;regs.y=1;
    if(_os_syscall(0x8e,&regs))return report(5,0,0);
    if(regs.x!=address || regs.y!=length)return report(6,regs.x,regs.y);
    pixels=(char *)(uintptr_t)address;
    for(i=0;i<160;++i)pixels[i]=(i&1) ? 0x22 : 0x11;
    if(write(fd,put,sizeof(put))!=sizeof(put))return report(7,0,0);
    memset(pixels,0,160);
    if(write(fd,get,sizeof(get))!=sizeof(get))return report(8,0,0);
    for(i=0;i<160;++i)
        if(pixels[i]!=((i&1) ? 0x22 : 0x11))return report(9,i,pixels[i]);
    regs.x=0x4d01;regs.y=0;
    if(_os_syscall(0x8e,&regs))return report(10,0,0);
    write(fd,kill,sizeof(kill));close(fd);
    return report(0,address,length);
}
