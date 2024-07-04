/* StdMenu.h - standard menu definitions */


/* Default Tandy Menu */
#ifndef MAIN
 extern
#endif
MIDSCR _tanitms[]
#ifdef MAIN
 = {
    {{'C','a','l','c'},1},
    {{'C','l','o','c','k'},1},
    {{'C','a','l','e','n','d','a','r'},1},
    {{'C','o','n','t','r','o','l'},1},
    {{'P','r','i','n','t','e','r'},1},
    {{'P','o','r','t'},1},
    {{'H','e','l','p'},1},
    {{'S','h','e','l','l'},1},
    {{'C','l','i','p','b','o','a','r','d'},0}
}
#endif
;

/* Default Files Menu */
#ifndef MAIN
 extern
#endif
 MIDSCR _filitms[]
#ifdef MAIN
  = {
    {{'N','e','w'},1},
    {{'O','p','e','n'},1},
    {{'S','a','v','e'},1},
    {{'S','a','v','e',' ','A','s','.','.','.'},1},
    {{'A','b','o','r','t'},1},
    {{'P','r','i','n','t'},1},
    {{'Q','u','i','t'},1}
}
#endif
;

/* Default Edit Menu */
#ifndef MAIN
 extern
#endif
MIDSCR _edtitms[]
#ifdef MAIN
 = {
    {{'U','n','d','o'},1},
    {{'C','u','t'},1},
    {{'C','o','p','y'},1},
    {{'P','a','s','t','e'},1},
    {{'C','l','e','a','r'},1}
}
#endif
;

#define TNDY_MN  {'T','a','n','d','y'},MN_TNDY,10,sizeof(_tanitms)/sizeof(_tanitms[0]),1,0,0,_tanitms

#define FILE_MN {'F','i','l','e','s'},MN_FILE,10,sizeof(_filitms)/sizeof(_filitms[0]),1,0,0,_filitms

#define EDIT_MN {'E','d','i','t'},MN_EDIT,6,sizeof(_edtitms)/sizeof(_edtitms[0]),0,0,0,_edtitms


