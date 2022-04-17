/* Generated by CIL v. 1.7.3 */
/* print_CIL_Input is false */

//#line  1 "init4.c"
typedef unsigned long longtype;
//#line  3 "init4.c"
typedef longtype partidtype;
//#line  5 "init4.c"
typedef char parttype[10];
//#line  7 "init4.c"
struct Connection_Type {
   partidtype to ;
   parttype type ;
   longtype length ;
};
//#line  7 "init4.c"
typedef struct Connection_Type Connection;
//#line  13
extern void printf(char *  , ...) ;
//#line  18
int main(void) ;
//#line  18 "init4.c"
static Connection link[3]  = {      {(partidtype )1, {(char )'l', (char )'i', (char )'n', (char )'k', (char )'1',
                       (char )'\000'}, (longtype )10}, 
        {(partidtype )2, {(char )'l', (char )'i', (char )'n', (char )'k', (char )'2',
                       (char )'\000'}, (longtype )20}, 
        {(partidtype )3, {(char )'l', (char )'i', (char )'n', (char )'k', (char )'3',
                       (char )'\000'}, (longtype )30}};
//#line  31
extern int ( /* missing proto */  strcmp)() ;
//#line  17 "init4.c"
int main(void) 
{ 
  int tmp ;

  {
//#line  21
  if (sizeof(long ) == 4UL) {
//#line  22
    if (sizeof(link[0]) != 20UL) {
//#line  22
      printf((char *)"Error %d\n", 1);
//#line  22
      return (1);
    }
  } else
//#line  23
  if (sizeof(long ) == 8UL) {
//#line  24
    if (sizeof(link[0]) != 32UL) {
//#line  24
      printf((char *)"Error %d\n", 1);
//#line  24
      return (1);
    }
  }
//#line  27
  if (link[0].length != 10UL) {
//#line  27
    printf((char *)"Error %d\n", 2);
//#line  27
    return (1);
  }
//#line  29
  if (link[2].length != 30UL) {
//#line  29
    printf((char *)"Error %d\n", 3);
//#line  29
    return (1);
  }
//#line  31
  tmp = strcmp("link2", link[1].type);
//#line  31
  if (tmp) {
//#line  31
    printf((char *)"Error %d\n", 4);
//#line  31
    return (1);
  }
//#line  33
  if ((int )link[1].type[6] != 0) {
//#line  33
    printf((char *)"Error %d\n", 5);
//#line  33
    return (1);
  }
//#line  35
  printf((char *)"Success\n");
//#line  36
  return (0);
}
}