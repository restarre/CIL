/* Generated by CIL v. 1.7.3 */
/* print_CIL_Input is false */

//#line  3 "testharness.h"
extern int printf(char const   *format  , ...) ;
//#line  12
extern void exit(int  ) ;
//#line  3 "const14.c"
long z  ;
//#line  4 "const14.c"
int zz  ;
//#line  6 "const14.c"
int main(void) 
{ 
  long x1 ;
  long x2 ;
  long x3 ;
  long x4 ;

  {
//#line  8
  x1 = 0L;
//#line  9
  x2 = 0L;
//#line  10
  x3 = 0L;
//#line  11
  x4 = 0L;
//#line  13
  printf("%ld\n", x1);
//#line  14
  printf("%ld\n", x2);
//#line  15
  printf("%ld\n", x3);
//#line  16
  printf("%ld\n", x4);
//#line  17
  if (x1 != 0L) {
//#line  17
    printf("Error %d\n", 1);
//#line  17
    exit(1);
  }
//#line  18
  if (x2 != 0L) {
//#line  18
    printf("Error %d\n", 2);
//#line  18
    exit(2);
  }
//#line  19
  if (x3 != 0L) {
//#line  19
    printf("Error %d\n", 3);
//#line  19
    exit(3);
  }
//#line  20
  if (x4 != 0L) {
//#line  20
    printf("Error %d\n", 4);
//#line  20
    exit(4);
  }
//#line  22
  printf("Success\n");
//#line  22
  exit(0);
}
}