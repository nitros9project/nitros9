#ifndef _OSK

/* Our own versions of modlink() and modload() which use
   F$NMLink and F$NMLoad to load a module  --BGP  */

#include <types.h>
#include <os9.h>

#if 0
#define F_UNLOAD  0x1d
#endif

extern int errno;


int nmlink (mod, type, lang)
char *mod;
int type, lang;
{
     struct registers reg;
     int result;
     
     reg.rg_a = type | lang;
     reg.rg_x = mod;
     result = _os9 (F_NMLINK, &reg);
     errno = reg.rg_b & 0xff;
     return (result);
}



int nmload (mod, type, lang)
char *mod;
int type, lang;
{
     struct registers reg;
     int result;

     reg.rg_a = type | lang;
     reg.rg_x = mod;
     result = _os9 (F_NMLOAD, &reg);
     errno = reg.rg_b & 0xff;
     return (result);
}


/* our own munload using F$UnLoad to unlink the module --REB */

int munload (mod, typelang)
char *mod;
int typelang;
{
     struct registers reg;
     int result;

     reg.rg_a = typelang;
     reg.rg_x = mod;
     result = _os9 (F_UNLOAD, &reg);
     errno = reg.rg_b & 0xff;
     return (result);
}
#endif
