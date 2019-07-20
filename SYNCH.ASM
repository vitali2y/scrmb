$debug include (PUBLIC.DEF)
;[]*****************************************************[]
;[]							[]
;[]	          Time-division  scrambler		[]
;[]	 	        Version  1.0			[]
;[]	        (c)  Ermolenko  Vitaly,  1993		[]
;[]							[]
;[]	      SYNCH.ASM: synchronization module 	[]
;[]							[]
;[]*****************************************************[]

		public	Synchro, CycleTask
		extrn	bit    (biWho)
		extrn	number (bSYNCHOK, WhoAmI)
		extrn	data   (bCount, bCountDelay)
		extrn	code   (?P0007, ?P0026, ?P0040, ?P0041, Fork)
		extrn	code   (IdleSubr3, IdleSubr4)
     		
;┌──────────── External PLM51.LIB subroutines ──────────┐
;│      ?P0007 - subtract word and word;		│
;│	?P0026 - decrement words;			│
;│	?P0040 - delay subroutine (n * 100 mcs);	│
;│	?P0041 - division words				│
;├───────── External subroutines from SCRMB.ASM ────────┤
;│      Fork - start a new process                      │
;├────── External idle subroutines from IDLE?.PLM ──────┤
;│      IdleSubr3 - idle subroutine 3;                  │
;│      IdleSubr4 - idle subroutine 4                   │
;└──────────────────────────────────────────────────────┘

;[]*****************************************************[]
;[]			 Used  bits			[]
;[]*****************************************************[]
BitSeg		segment	bit
		rseg	BitSeg
biDtctSynch:	dbit	1				; flag: synchro was detect
biRepeatCycles:	dbit	1				; flag: stop or non-stop synchro cycles

;[]*****************************************************[]
;[]                       Macros                        []
;[]*****************************************************[]
%*define        (StartDtctSync)                         %' start calculating duration of cycle
(
%if (%eqs (%MAKE,EMU))
then (
		setb	ex1				; start cycle task (ext. int. 1)
     )
else (
		setb	ex0				; start cycle task (ext. int. 0)
     ) fi
		setb	tr1				; start timer 1
)
%*define        (StopDtctSync)                          %' stop calculating duration of cycle
(
%if (%eqs (%MAKE,EMU))
then (
		clr	ex1				; stop cycle task
     )
else (
		clr	ex0				; stop cycle task
     ) fi
		clr	tr1				; stop timer 1
)
%*define        (ResetDtctSync)                         %' clear flag detection synchro signals
(
                clr	biDtctSynch			
)
%*define        (SetDtctSync)                           %' set flag detection synchro signals
(
                setb	biDtctSynch			
)

;[]*****************************************************[]
;[]			Code  segment			[]
;[]*****************************************************[]
CodeSeg		segment	code
		rseg	CodeSeg
		using	0

;[]*****************************************************[]
;[]       CycleTask:  defining  of  signal  cycle	[]
;[]                                                     []
;[]  Generating external interrupt 0 (1 - for emulator) []
;[]	  after each negative-going slope (1 -> 0)	[]
;[]   Duration of signal cycle calculating in timer 1	[]
;[]  If synchro cycles detected, then set biDtctSynch	[]
;[]*****************************************************[]
CycleTask:	clr	tr1				; disable cycle task
		push	acc

;[]++++++++++++++++++++ Spy at cycle ++++++++++ Begin +[]
		mov	a, th1
		cjne	a, #high (wMINSYNCHCYCLE), VrfMinSyncCycle
		mov	a, tl1
		cjne	a, #low  (wMINSYNCHCYCLE), VrfMinSyncCycle
VrfMinSyncCycle:jc	ExitNoRepeat			; calculating cycle greater min. synchro cycle?
		mov	a, th1
		cjne	a, #high (wMAXSYNCHCYCLE), VrfMaxSyncCycle
		mov	a, tl1
		cjne	a, #low  (wMAXSYNCHCYCLE), VrfMaxSyncCycle
VrfMaxSyncCycle:jnc	ExitNoRepeat			; calculating cycle less or equal min. synchro cycle?
		jb	biRepeatCycles, VrfRepeat	; non-stop synchro cycles?
		mov	ar4, r3				; r3 - count of synchro cycles (for polling)
VrfRepeat:	djnz	r4, ExitRepeat
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

%if (%eqs (%MAKE,EMU))
then (
		clr	ex1				; stop cycle task
     )
else (
		clr	ex0				; stop cycle task
     ) fi
		%SetDtctSync                            ; set flag detection synchro signals
ExitNoRepeat:	clr	biRepeatCycles
		sjmp	ExitCycleTask
ExitRepeat:	setb	biRepeatCycles			; set flag - non-stop synchro cycles
ExitCycleTask:
%if (%eqs (%MAKE,DEB) or %eqs (%MAKE,EMU))
then (
		cpl     biCtrl1				; control strobe
     ) fi
		pop	acc
		mov	tl1, #00h			; reset counter of timer 0
		mov	th1, #00h
%if (%eqs (%MAKE,DEB) or %eqs (%MAKE,EMU))
then (
                setb    f0                              ; set flag for detecting strobe
		cpl	biCtrl1
     ) fi
		setb	tr1				; enable cycle task
		reti
		db	10010000b
		acall	IdleSubr3

;[]*****************************************************[]
;[]      Synchro:  synchronization  of  scramblers  	[]
;[]	Input:  none					[]
;[]	Output: acc  = bSYNCHOK - o'key;		[]
;[]	        acc != bSYNCHOK - don't synchronized	[]
;[]     Frequency of synchro sine signals - 1000 Hz	[]
;[]   After subroutine (if acc = bSYNCHOK) scramblers	[]
;[]                  will be synchronizate		[]
;[]*****************************************************[]
Synchro:        %IAmSlave				; initial setup: I am slave
                %ResetDtctSync  			; clear flag detection synchro signals
%if (%eqs (%STRT,HANDBOTH))
then (
                clr     a
                mov     dptr, #WhoAmI
                movc    a, @a+dptr                      ; get value: master or slave
                jb      acc.0, PhaseI
                %IAmMaster
     ) fi

;[]+++++++++++++++ Phase I synchronization ++++ Begin +[]
PhaseI:         clr	biRepeatCycles			; clear flag: non-stop synchro cycles
                mov	r3,  #bSYNCHCYCLES		; init counter of waiting synchro signals
		mov	th1, #00h
		mov	tl1, #00h
%if (%eqs (%MAKE,DEB) or %eqs (%MAKE,EMU))
then (
                cpl     biCtrl2                         ; control strobe
     ) fi
%if (%nes (%MAKE,RUN))
then (

;┌─── State of pin biRegSync during run in DEB regime ──┐
;│       biRegSync = 1  -  hand synchronization for     │
;│                    both scramblers.                  │
;│     Both scramblers will wait pressing on any cont-  │
;│ rol button:  scrambler with pressed button will mas- │
;│ ter, another - slave.                                │
;│        biRegSync = 0  - auto start of scrambler.     │
;│     This scrambler start myself after pressed button │
;│ as master.                                           │
;└──────────────────────────────────────────────────────┘

                jb      biRegSync, HandSynch		; hand debug regime?
		jmp	AutoStrtRegime
		db	01110100b

;[]++++++++++++++++ Hand synchronization ++++++ Begin +[]
HandSynch:	clr     f0                              ; reset flag detecting strobe in link

;[]+++++++ Waiting of end turn-on transient +++ Begin +[]
%if (%nes (%MAKE,SIM))
then (
                mov     a, #40
Delay1Sec:      push    acc
		mov	a, #250
		acall	?P0040
                pop     acc
                djnz    acc, Delay1Sec                  ; delay ў 1 sec
     ) fi
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

%if (%nes (%STRT,HANDBOTH))
then (
                %StartDtctSync                          ; start calculating duration of cycle
     ) fi
RstrtHand:      mov     dptr, #0FFFFh
WaitHandSynch:  jnb     biWaitButton, DtctHandMaster    ; was press control button?
%if (%nes (%STRT,HANDBOTH))
then (
                jb      f0,           DtctHandSlave     ; was detect hand strobe in link?
     ) fi
                djnz    dpl,          WaitHandSynch
                djnz    dph,          WaitHandSynch
%if (%eqs (%MAKE,DEB) or %eqs (%MAKE,EMU))
then (
                cpl     biCtrl2                         ; generating large control strobe
     ) fi
                sjmp    RstrtHand
                db      00100000b
DtctHandSlave:  %IAmSlave                               ; I am slave after detecting strobe in link
                ajmp    EntryPoint
DtctHandMaster:	
%if (%nes (%STRT,HANDBOTH))
then (
		%IAmMaster				; I am master after pressing button
                mov	a, #(bNULLPOT - 50h)
                %OutByt (ToLink)
%if (%nes (%MAKE,SIM))
then (
		mov	a, #75
                djnz    acc, $				; duration of hand strobe - 150 mcs
		mov	a, #(bNULLPOT + 50h)
		%OutByt (ToLink)
		mov	a, #75
                djnz    acc, $				; duration of hand strobe - 150 mcs
		mov	a, #bNULLPOT
		%OutByt (ToLink)
     ) fi
		mov	dptr, #30000
WaitHandStrobe:
%if (%nes (%MAKE,SIM))
then (
                mov     a,    #20
WaitOwnStrobe:  jb      f0,  GetOwnStrobe               ; waiting own strobe
%if (%eqs (%MAKE,DEB) or %eqs (%MAKE,EMU))
then (
		cpl     biCtrl2                         ; generating short control strobe
     ) fi
                djnz    acc, WaitOwnStrobe
		djnz	dpl, WaitHandStrobe		; if own strobe absence, then wait ў 3 sec
		djnz	dph, WaitHandStrobe
     ) fi
GetOwnStrobe:   %StopDtctSync
     ) fi
                sjmp    EntryPoint
                db      11010101b
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

     ) fi
AutoStrtRegime: mov	a,   #10
                %StartDtctSync                          ; start calculating duration of cycle

%if (%nes (%MAKE,SIM))
then (
WaitSync:	push	acc
		mov	a,   #bDURATIONWAIT
		acall	?P0040				; waiting synchro signals bDURATIONWAIT ms
		pop	acc
		djnz	acc, WaitSync
     ) fi
                %StopDtctSync                           ; stop calculating duration of cycle
		jnb	biDtctSynch,  SendSync	        ; detected synchro signals?
		jnb	biWho,        PhaseII           ; master: go towards phase II?
SendSync:       mov	r5,  #bCYCLE_III
FalseJmp:	acall	Fork				; generate synchro signals
                jnb     biDtctSynch,  AssignMaster
		jb	biWho,        PhaseII           ; slave: go towards phase II?
AssignMaster:	%IAmMaster				; I am master now
%if (%eqs (%MAKE,DEB) or %eqs (%MAKE,EMU))
then (
                jnb     biWaitButton, EntryPoint        ; pressed control button (master auto start)?
     ) fi
                jmp     PhaseI
		db	00100000b
		acall	IdleSubr4
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

;[]++++++++++++++ Phase II synchronization ++++ Begin +[]
PhaseII:	%ResetDtctSync  			; clear flag detection synchro signals
		clr	biRepeatCycles			; clear flag: non-stop synchro cycles
		mov	tl1, #00h
		mov	th1, #00h
		jb	biWho, SlaveWaitSync
		mov	a,   #50
		djnz	acc, $				; delay 100 mcs for master
SlaveGnrtSync:	mov	r5,  #bCYCLE_III
		acall	Fork				; first master generate synchro signals
		jb	biWho, CalcDiff                 ; slave don't detect duration of cycle
SlaveWaitSync:  mov	r3,  #bSYNCHCYCLES
                %StartDtctSync                          ; start calculating duration of cycle
WaitDtct:
%if (%eqs (%MAKE,DEB) or %eqs (%MAKE,EMU))
then (
                cpl     biCtrl2                         ; control strobe
     ) fi
%if (%nes (%MAKE,SIM))
then (
		jnb	biDtctSynch, WaitDtct		; waiting detecting of synchro signals
     ) fi
                %StopDtctSync                           ; stop calculating duration
		jb	biWho, SlaveGnrtSync
CalcDiff:	mov	r4, #high (bSYNCHCYCLES * bSIZESINE * %bDGTZCYCLE)
		mov	r5, #low  (bSYNCHCYCLES * bSIZESINE * %bDGTZCYCLE)
		mov	r6, th1
		mov	r7, tl1
		acall	?P0007				; subtract duration of generating
		mov	ar4, r6
		mov	ar5, r7

;[]+++++++++++++ Entry point to scrambling ++++++++++++[]
EntryPoint:	pop	dph
                mov     r3, dph
		pop	dpl
		mov	r7,  #%bDGTZCYCLE
		acall	?P0041				; calculating delay (in cycles)
		mov	r3,  #low (FalseJmp)
		push	ar3

;┌────────────┬────────────────┐
;│     r5     │  Distance, km  │
;├────────────┼────────────────┤
;│     00h    │       ...      │
;│     ...    │       ...      │
;│bSIZEBLOCK-1│       ...      │
;└────────────┴────────────────┘

		mov	r5,  #00h		        ; !!! debug regime !!!
                clr     c
                mov     a,   #%bSIZEBLOCK
                subb    a, r5
		mov	bCountDelay, a			; save calculating value of delay in link (for master only!)
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

		mov	r1, #high (FalseJmp)

;┌─────────────┬─────────┬────────────────┬───────────┐
;│             │  biWho  │Start cycle (r5)│ Direction │
;├─────────────┼─────────┼────────────────┼───────────┤
;│ M A S T E R │    0    │       II       │    +1     │
;├─────────────┼─────────┼────────────────┼───────────┤
;│  S L A V E  │    1    │        I       │    -1     │
;└─────────────┴─────────┴────────────────┴───────────┘

%if (%eqs (%MAKE,DEB) or %eqs (%MAKE,EMU))
then (
                mov     c, biWho
                mov     biCtrl2, c                      ; control signal: master or slave
     ) fi
		mov	r5, #bCYCLE_I			; init start cycle for slave
		jb	biWho, NoMaster
                mov	r5, #bCYCLE_II    		; init start cycle for master
NoMaster:	mov	a,  #bSYNCHOK
		jmp	@a+dptr				; return from subroutine
		db      01110111b

		end
