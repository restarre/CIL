/* Generated by CIL v. 1.7.3 */
/* print_CIL_Input is false */

//#line  3 "testharness.h"
extern int printf(char const   *format  , ...) ;
//#line  12
extern void exit(int  ) ;
//#line  3 "inline2.c"
int main(void) 
{ 
  int x ;
  int y ;
  int z ;

  {
//#line  4
  x = 1;
//#line  4
  y = 5;
//#line  4
  z = 0;
//#line  6
  __asm__  ("movl %[in1], %[out] \n addl %[in2], %[out]": [out] "=r" (z): [in1] "m" (x),
            [in2] "m" (y));
//#line  9
  if (z != 6) {
//#line  9
    printf("Error %d\n", 1);
//#line  9
    exit(1);
  }
//#line  11
  return (0);
}
}