echo off
cls
e:\8051\plm\asm51 spin.asm
e:\8051\plm\rl51 spin.obj
e:\8051\plm\oh spin
cd ..
cd ..
cd sim
avsim51 -c0 cfle:\8051\my\tds\spin.cmd
cd ..
cd my
cd tds
