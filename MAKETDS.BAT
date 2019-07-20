echo off
cls

if (%1)==() goto Usage
if %1 == D  goto Debug
if %1 == L  goto Link
if %1 == C  goto Compl
if %1 == M  goto Make

echo Невеpный паpаметp для MakeTDS.bat!

:Usage
echo *************************************************
echo     MakeTDS.bat:  файл  создания  проекта
echo Использование: MakeTDS опции
echo                MakeTDS   C SrcFile - компиляция,
echo                MakeTDS   L         - линкование,
echo                MakeTDS   M         - сделать все,
echo                MakeTDS   D         - отлаживать
echo *************************************************
goto EndBat

:Make
echo ------------ Create a project TDS -----------
echo ------------- Assembling TDS.ASM ------------
e:\8051\plm\asm51 tds.asm
echo ------------ Assembling SYNCH.ASM -----------
e:\8051\plm\asm51 synch.asm
echo ------------ Assembling SCRMB.ASM -----------
e:\8051\plm\asm51 scrmb.asm
rem echo ------------ Assembling SCALE.ASM -----------
rem e:\8051\plm\asm51 scale.asm
if %1 == M goto Link
goto Link

:Compl
echo ----------- Assembling %2.ASM -----------
e:\8051\plm\asm51 %2.asm
goto EndBat

:Link
echo ------------------ Linking ------------------
e:\8051\plm\rl51 tds.obj,idle2.cod,synch.obj,idle1.cod,scrmb.obj,idle.cod,e:\8051\plm\plm51.lib,e:\8051\plm\util51.lib
e:\8051\plm\oh tds
if %1 == L goto EndBat
if %1 == M goto EndBat

:Debug
cd ..
cd ..
cd sim
avsim51 -c0 cfle:\8051\my\tds\tds.cmd
cd ..
cd my
cd tds

:EndBat
