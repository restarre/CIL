/* Generated by CIL v. 1.7.3 */
/* print_CIL_Input is false */

#line 3 "combinestruct1_1.c"
struct A {
   int x ;
};
#line 8
extern struct A *connection ;
#line 11 "combinestruct1_1.c"
int foo(void) 
{ 


  {
#line 13
  return (connection->x);
}
}