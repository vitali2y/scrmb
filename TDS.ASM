$debug include (PUBLIC.DEF)
;[]*****************************************************[]
;[]							[]
;[]	          Time-division  scrambler		[]
;[]	 	        Version  1.0			[]
;[]	        (c)  Ermolenko  Vitaly,  1993		[]
;[]							[]
;[]		   TDS.ASM: start-up module		[]
;[]							[]
;[]*****************************************************[]

                public  WhoAmI
		extrn	code (ScrmbTask, CycleTask, Beep, Scrambling, IdleSubr2)

;┌ External subroutines and entry points from SCRMB.ASM ┐
;│	ScrmbTask  - compaction, transmission, recieve, │
;│ unpack information (interrupt timer 0);              │
;│	Beep       - sound output;                      │
;│      Scrambling - scrambling information             │
;├ External subroutines and entry points from SYNCH.ASM ┤
;│      CycleTask  - defining of signal cycle (external │
;│ interrupt 0)                                         │
;├─────── External idle subroutine from IDLE?.PLM ──────┤
;│      IdleSubr2 - idle subroutine 2                   │
;└──────────────────────────────────────────────────────┘

;[]*****************************************************[]
;[]		       Stack  segment			[]
;[]*****************************************************[]
StackSeg	segment	idata
		rseg	StackSeg
		ds	bSIZESTACK

;[]*****************************************************[]
;[]			Code  segment			[]
;[]*****************************************************[]
CodeSeg		segment	code
		rseg	CodeSeg
		org	wCODESEG + RESET

;[]*****************************************************[]
;[]			  Cold start			[]
;[]*****************************************************[]
		ajmp	Main

%if (%nes (%MAKE,EMU))
then (
;[]*****************************************************[]
;[]		    External interrupt 0                []
;[]*****************************************************[]
		org	wCODESEG + EXTI0
		ajmp	CycleTask
     ) fi

;[]*****************************************************[]
;[]	             Interrupt timer 0			[]
;[]*****************************************************[]
		org	wCODESEG + TIMER0
		ajmp	ScrmbTask

;[]*****************************************************[]
;[]	            External interrupt 1                []
;[]*****************************************************[]
		org	wCODESEG + EXTI1
%if (%eqs (%MAKE,EMU))
then (
		ajmp	CycleTask
     )
else (
		mov	dph, 26h
		mov	dpl, 27h
		clr	a
		jmp	@a+dptr
     ) fi

;[]*****************************************************[]
;[]	      Interrupt timer 1 (not suppoted)		[]
;[]*****************************************************[]
		org	wCODESEG + TIMER1
                mov     dph, 28h
                mov     dpl, 29h
                clr     a
                jmp     @a+dptr

;[]*****************************************************[]
;[]	 	 Information  about  version		[]
;[]*****************************************************[]
		org	wCODESEG + 30h
		db	'+ -- -- -- -- -+'
%if (%eqs (%MAKE,RUN))
then (
		db	'|    TDS '
		db	%VERS
		db	'   |'
     )
else (
		db	'| TDS '
		db	%VERS
		db	' @'
%if (%eqs (%MAKE,DEB))
then (
                db      'DEB'
     ) fi
%if (%eqs (%MAKE,EMU))
then (
                db      'EMU'
     ) fi
%if (%eqs (%MAKE,SIM))
then (
                db      'SIM'
     ) fi
                db      ' |'
     ) fi
		db	'|   '
                db      %DATE
		db	'  |'
		db	'+ -- -- -- -- -+'
WhoAmI:                                                 ; point for setting value of slave or master
%if (%eqs (%STRT,HANDBOTH))
then (
		db	'@<-HANDBOTH'
     ) fi

;[]*****************************************************[]
;[]		  Body  of  main  program		[]
;[]*****************************************************[]
		db	01110100b
Main:		setb	ea				; general enable interrupts
		mov	sp, #(StackSeg - 1)
%if (%nes (%MAKE,SIM))
then (
		mov	a,  #bWRNPOWERON		; warning: switch on power
		acall	Beep
     ) fi
		acall	Scrambling
                acall   IdleSubr2
		db	01111000b

		end
