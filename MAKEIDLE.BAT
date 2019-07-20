echo off
cls
e:\8051\plm\plm51 idle.plm
e:\8051\plm\plm51 idle1.plm
e:\8051\plm\plm51 idle2.plm
del *.cod
ren idle.obj  idle.cod
ren idle1.obj idle1.cod
ren idle2.obj idle2.cod
