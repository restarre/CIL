/* Generated by CIL v. 1.7.3 */
/* print_CIL_Input is false */

//#line  1 "memberofptr.c"
struct posix_header {
   char name[100] ;
   char typeflag ;
   char prefix[155] ;
};
//#line  6 "memberofptr.c"
union block {
   struct posix_header header ;
};
//#line  18 "memberofptr.c"
int read_header(void) 
{ 
  struct posix_header *h ;
  char namebuf[sizeof(h->prefix) + 1UL] ;

  {
//#line  24
  return ((int )sizeof(namebuf));
}
}
//#line  3 "../small1/testharness.h"
extern int printf(char const   *format  , ...) ;
//#line  12
extern void exit(int  ) ;
//#line  29 "memberofptr.c"
int main(void) 
{ 
  int tmp ;

  {
//#line  30
  tmp = read_header();
//#line  30
  if (tmp != 156) {
//#line  30
    printf("Error %d\n", 1);
//#line  30
    exit(1);
  }
//#line  31
  printf("Success\n");
//#line  31
  exit(0);
}
}