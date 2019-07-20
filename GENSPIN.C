#include		<stdio.h>

#define	bSIZESPIN	3
#define	bCOUNTSPIN	1

main ()
 {
  unsigned int  iI, iJ;
  unsigned char cTmp, cCarry1 = 0, cCarry2, sArr [] = {1, 2, 3 /* 0x61, 0x52, 0x43*/ };

  printf ("\nGenSpin 1.0  Генеpатоp веpтушки\n\nИсходный массив: ");
  for (iI = 0; iI < sizeof (sArr); iI++)
   {
    printf ("%X  ", sArr [iI]);
   }
  printf ("\nРезультиpующий массив: ");
  iI = 0;
  do
   {
    iJ = bSIZESPIN - 1;
    do
     {
      cCarry2 = sArr [iJ] & 1;
      sArr [iJ] >>= 1;
      if (cCarry1)  sArr [iJ] |= 0x80;
      cCarry1 = cCarry2;
     }
    while (iJ--);
   }
  while (iI-- != bSIZESPIN;);
  for (iI = 0; iI < sizeof (sArr); iI++)
   {
    printf ("%X  ", sArr [iI]);
   }
 }
