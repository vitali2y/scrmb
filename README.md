Time Division Telephone Scrambler
================================

This software was developed in 1993 in *Assembler-51* and *PL/M-51* for embedded single-chip microcontrollers *Intel 8031/51*, and was developed for transmitting the encrypted phone audio signal through public switched telephone network (PSTN) for preventing the eavesdropping (man-in-the-middle attack, MITM).

Correspondent hardware and software has been successfully tested during PSTN phone calls (during phone call the two scrambler devices were connected between telephone set and a telephone jack on both sides), but as far as I know it was not used in production.

Conversion from original *cp866* encoding (Russian) to *utf-8* has been executed as below (except binary files):
```
for f in ./*; do iconv --from-code cp866 --to-code utf-8 $f -o $f.new && mv $f.new $f; done
```
