$debug include (PUBLIC.DEF)
;[]*****************************************************[]
;[]							[]
;[]	          Time-division  scrambler		[]
;[]	 	        Version  1.0			[]
;[]	        (c)  Ermolenko  Vitaly,  1993		[]
;[]							[]
;[]	SCRMB.ASM: module of scrambling information	[]
;[]							[]
;[]*****************************************************[]

		public	Beep, Scrambling, ScrmbTask, Fork
		public	bCount, bCountDelay
		public	biWho, biGnrtSync, aPTRMAXSINE, bSYNCHOK
		extrn	code (?P0026, ?P0040, setbx0, Synchro)
		extrn	code (IdleSubr1, IdleSubr2, IdleSubr3, IdleSubr5)

;┌─────────────── External PLM51.LIB subroutines ───────┐
;│	?P0026 - decrement words;			│
;│	?P0040 - delay subroutine (n * 100 mcs)		│
;├─────────── External UTIL51.LIB subroutines ──────────┤
;│	setbx0 - clear array in external memory of data │
;├───────── External subroutines from SYNCH.ASM ────────┤
;│	Synchro - synchronization of scramblers         │
;├────── External idle subroutines from IDLE?.PLM ──────┤
;│      IdleSubr1 - idle subroutine 1;                  │
;│      IdleSubr2 - idle subroutine 2;                  │
;│      IdleSubr3 - idle subroutine 3;                  │
;│      IdleSubr5 - idle subroutine 5                   │
;└──────────────────────────────────────────────────────┘

;[]*****************************************************[]
;[]			 Used  bits			[]
;[]*****************************************************[]
BitSeg		segment	bit
		rseg	BitSeg
biWho:		dbit	1				; master or slave
biRstLink:	dbit	1				; flag reset link for recieve information
biUpdTransmPtr:	dbit	1				; flag next updating pointers aPtrOutLink & aPtrInPhone
biPassTransm:	dbit	1				; number transmission pass
biPassReciev:	dbit	1				; number reciever pass
biGnrtSync:	dbit	1				; flag generating synchro in cycle III

;[]*****************************************************[]
;[]		    Used  external  data		[]
;[]*****************************************************[]
		xseg	at wDATA1SEG
sInOutArr0	equ	$ 				; arrays for work with phone/link information
sInOutArr1	equ	sInOutArr0 + 100h
sInOutArr2	equ	sInOutArr1 + 100h
sInOutArr3	equ	sInOutArr2 + 100h

;[]*****************************************************[]
;[]		    Used  internal  data		[]
;[]*****************************************************[]
DataSeg		segment	data
		rseg	DataSeg
aPtrOutLink:	ds	2				; current pointer for output in link
aPtrInLink:	ds	2				; current pointer for input from link
aPtrInPhone:	ds	2				; current pointer for input from phone
aPtrOutPhone:	ds	2				; current pointer for output in phone
bCount:		ds	1				; count bytes
bCountDelay:	ds	1				; calculating value of delay in link
bTicks:		ds	1                               ; count of ticks during scrambling
bMeanVal:       ds      1                               ; mean value from link

;[]*****************************************************[]
;[]			Code  segment			[]
;[]*****************************************************[]
CodeSeg		segment	code
		rseg	CodeSeg
		using	0

;[]*****************************************************[]
;[]    	  Sine:  receipt  current  value  of  sine	[]
;[]		Input:  r7  - angle			[]
;[]		Output: acc - sine of angle		[]
;[]*****************************************************[]
CorrSine:	sjmp	NoUpdSine
                db      10010101b
Sine:		cjne	r7, #bSIZESINE, NoRstAngle	; angle greater 360°?
		mov	r7, #00h
NoRstAngle:	mov	a, r7
		add	a, #(EndDiff - BegDiff)		; correction for receipt sine
		cjne	a, #(bSIZESINE / 2) + (EndDiff - BegDiff), VrfAngle
VrfAngle:	jc	Less180				; angle less 180°?
		subb	a, #(bSIZESINE / 2)
Less180:        movc	a, @a+pc			; receipt value sine
BegDiff		equ	$
		cjne	r7, #(bSIZESINE / 2), VrfSine
VrfSine:	jc	CorrSine
		cpl	a				; invert value for angle greater 180°
NoUpdSine:	ret
EndDiff		equ	$

;[]*****************************************************[]
;[]		Sine  table  (half  of  cycle)		[]
;[]*****************************************************[]
		;	 18°   54°
		db	09Ah, 0C7h
aPTRMAXSINE	equ	$
		;	 90°
		db	0D9h				; max. value during sine generating
		;	126°  162°
		db	0C7h, 09Ah

;[]*****************************************************[]
;[] ScrmbTask: compaction, transmission, recieve, unpack[]
;[]                      information                    []
;[]                                                     []
;[]     Initiating timer 0 interrupt with frequency     []
;[]    (1 / bDGTZCYCLE) * 10 Hz (T = bDGTZCYCLE mcs)    []
;[]*****************************************************[]
ScrmbTask:

;┌─────────────────────────────────────────────────────────────────────────────────────────────────────
;│                                           M  A  S  T  E  R
;└───────┬─────────┬─┬─────────┬───────┬─────────┬─┬─────────┬───────┬─────────┬─┬─────────┬───────┬───
;        │    II   III    I    │   IV  │    II   III    I    │   IV  │    II   III    I    │   IV  │ ->
;   II   ├─────────┼─┴─────────┴───────┴─────────┼─┴─────────┴───────┴─────────┼─┴─────────┴───────┴───
;        │OutPhone┌│>           OutPhone        ┌┼>           OutPhone        ┌┼>        OutPhone
; phase  ├────────┼┴─┬──────────────────────────┼┴─┬──────────────────────────┼┴─┬─────────────────────
;        │  InPhon│e │           InPhone        │  │           InPhone        │  │        InPhone
;synchron├────────┴┬┬┼─────────┬───────┬────────┴┬┬┼─────────┬───────┬────────┴┬┬┼─────────┬───────┬───
;        │ InLink  │└┼>OutLink │  Wait │ InLink  │└┼>OutLink │  Wait │ InLink  │└┼>OutLink │  Wait │
;────────┴─────────┴─┴─────────┴───────┴─────────┴─┴─────────┴───────┴─────────┴─┴─────────┴───────┴───
;      / /  Slave  /   \  Master \<-w->/  Slave  /   \  Master \<-w->/  Slave  /   \  Master \<-w->/
; Start /   to    /<-s->\    to   \   /   to    /<-s->\    to   \   /   to    /<-s->\    to   \   /
;     \/ Master  /       \  Slave  \ / Master  /       \  Slave  \ / Master  /       \  Slave  \ /
;─────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬───────
;     │ OutLink │ Subsync │ InLink┌─┼>OutLink │ Subsync │ InLink┌─┼>OutLink │ Subsync │ InLink┌─┼> ...
;  II ├─────────┴─────────┴───────┴┬┼─────────┴─────────┴───────┴┬┼─────────┴─────────┴───────┴┬┼───────
;     │            InPhone         ││            InPhone         ││            InPhone         ││  ...
;phase├────────────────────────────┼┼────────────────────────────┼┼────────────────────────────┼┼───────
;     │            OutPhone        └┼>           OutPhone        └┼>           OutPhone        └┼> ...
;synch├─────────┬─────────┬─────────┼─────────┬─────────┬─────────┼─────────┬─────────┬─────────┼───────
;     │     I   │   III   │    II   │     I   │   III   │    II   │     I   │   III   │    II   │─time─>
;┌────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴───────
;│                                             S  L  A  V  E
;└──────────────────────────────────────────────────────────────────────────────────────────────────────
;┌─────┬───┬──────┬─────────────────────────┬───────────┐	┌──────────────────────────────────┐
;│Cycle│   │  r5  │          Cycles         │   bCount  │       │              Note:               │
;├─────┼───┼──────┼─────────────────────────┼───────────┤	│                                  │
;│     │   │      │                         │ bSIZEBLOCK│	│   s = bSIZEBLOCK - bCountDelay   │
;│   I │   │   1  │    Transmission cycle   │    ...    │	│   w = bCountDelay                │
;│     │M  │      │                         │    01h    │	└──────────────────────────────────┘
;│     │  e│      ├─────────────────────────┼───────────┤
;│     │a  │      │                         │bCountDelay│
;│  IV │  v│   4  │ Wait cycle (for master) │    ...    │
;│     │s  │      │                         │    01h    │
;│     │  a│      ├─────────────────────────┼───────────┤
;│     │t  │      │                         │ bSIZEBLOCK│
;│  II │  l│   2  │      Recieve cycle      │    ...    │
;│     │e  │      │                         │    01h    │
;│     │  S│      ├─────────────────────────┼───────────┤
;│     │r  │      │                         │bSIZEBLOCK-│
;│ III │   │   3  │ Subsynchronization cycle│bCountDelay│
;│     │   │      │                         │  ... 01h  │
;├─────┴─┬─┴──────┴─────────────────────────┴───────────┤
;│ Cycle │               Arrays allocation              │
;├───────┼───────[0]───────[1]──────[2]──────[3]────────┤
;│    I  │     OutLink      -    InPhone   OutPhone     │
;│   IV  │      Wait      Wait   InPhone   OutPhone     │
;│   II  │        -      InLink  InPhone   OutPhone     │
;│  III  │     Subsync  Subsync  InPhone   OutPhone     │
;└───────┴──────────────────────────────────────────────┘

%if (%eqs (%MAKE,DEB) or %eqs (%MAKE,EMU))
then (
		setb	biCtrl1				; control strobe
     ) fi
                inc     bTicks                          ; increment count of ticks
NoEndOutPhone:	cjne	r6,   #bPHASE_II,  NoInPhone	; get information from phone?
		mov	dptr, #WADCDACSEG
%if (%nes (%MAKE,SIM))
then (
                jb      biPhonAdcRdy, $
     ) fi
		movx	a, @dptr			; reading value from phone ADC
                %StopPhonADC
		mov	dph, aPtrInPhone
		mov	dpl, aPtrInPhone + 01h
		movx	@dptr, a			; save amplitude of signal
		inc	aPtrInPhone + 01h
NoInPhone:      jnb	biRstLink, CycleDispatch	; reset link for recieve information?
 		mov	a, bMeanVal
	 	%OutByt (ToLink)       			; transmission null byte to link
		clr	biRstLink
CycleDispatch:	cjne	r5,   #bCYCLE_II, NoCycleII

;[]+++++++++++++++++++++ Cycle II +++++++++++++ Begin +[]
                cjne	@r1, #01h, InFromLink           ; reseting values from link?
		mov	a,   bMeanVal
		mov	r3,  #(bRSTCOUNTS * 2)
		mov	dph, aPtrInLink
		mov	dpl, #(bRSTCOUNTS - 1)
LoopRst:	movx	@dptr, a			; reset byte (ўoverlay counts of master and slave)
		dec	dpl
		djnz	r3,        LoopRst
                ajmp    VrfIOPhone
                db      00100000b
                acall   IdleSubr5
InFromLink:     mov	dptr, #wADCDACSEG
		setb	biDam				; DAM: let pass signal
		inc	aPtrInLink + 01h                ; increment pointer aPtrInLink
                nop
                push    acc
                pop     acc
                nop
		clr	biDam				; DAM: fix signal
                %RunLinkADC
%if (%nes (%MAKE,SIM))
then (
		jb	biLinkAdcRdy, $			; wait measuring value
     ) fi
		movx	a, @dptr			; reading value
                %StopLinkADC
                mov	dph, aPtrInLink
		mov	dpl, aPtrInLink + 01h
		movx	@dptr, a
                ajmp    VrfIOPhone
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

		db	11011001b
		acall	IdleSubr3
NoCycleII:	cjne	r5, #bCYCLE_I,  NoCycleI

;[]+++++++++++++++++++++ Cycle I ++++++++++++++ Begin +[]
		jnb	biUpdTransmPtr, Out2Link	; update pointers?
		jb	biPassTransm, TransmPass0	; transmission pass 1?
		mov	aPtrInPhone,       #high (sInOutArr0)
		mov	aPtrInPhone + 01h, #low  (sInOutArr0)
		mov	aPtrOutLink,       #high (sInOutArr2)
		mov	aPtrOutLink + 01h, #low  (sInOutArr2)
		sjmp	SetPassTransm
TransmPass0:	mov	aPtrInPhone,       #high (sInOutArr2)
		mov	aPtrInPhone + 01h, #low  (sInOutArr2)
		mov	aPtrOutLink,       #high (sInOutArr0)
		mov	aPtrOutLink + 01h, #low  (sInOutArr0)
SetPassTransm:	cpl	biPassTransm			; change pass
		clr	biUpdTransmPtr			; clear flag updating transmission pointers
Out2Link:	mov	dph, aPtrOutLink
		mov	dpl, aPtrOutLink + 01h
		movx	a, @dptr
		%OutByt	(ToLink)			; transmission current byte in link
		inc	aPtrOutLink + 01h		; increment pointer aPtrOutLink
		cjne	@r1, #01h, VrfIOPhone		; update pointers (bCount = 01h)?
		setb	biUpdTransmPtr			; in future - updating pointers
		setb	biRstLink			; before recieve information - reset link
		jb	biWho,     VrfIOPhone		; for slave - will not prepare IV cycle
                clr     c
                mov     a,  #%bSIZEBLOCK
                subb    a, bCountDelay
                inc     a
		mov	bCount, a         		; prepare for delay
		mov	r5, #(bCYCLE_III + 1)		; next cycle - IV (delay for master)
		sjmp	VrfIOPhone
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

		db	11000101b, 11110110b
NoCycleI:       cjne	r5, #bCYCLE_III, VrfIOPhone     ; NoCycleIII

;[]++++++++++++++++++++ Cycle III +++++++++++++ Begin +[]
VrfGnrtSync:	jnb	biGnrtSync, VrfFalseOut         ; generate synchro signals?
		acall	Sine
		inc	r7				; toward next value angle
		%OutByt (ToLink)                        ; transmission current value of sine to link
		sjmp	VrfEndCycle                     ; !!! VrfIOPhone
VrfFalseOut:

;[]++++++ Output of false values on III cycle + Begin +[]
%if (%eqs (%ANTI,GNRT))
then (
                jb      biWho, NoOutFalseVal            ; random values will generate master only!
                mov     a, bCountDelay
                cjne    a, (BSIZEBLOCK / 2 - bFALSEZONE / 2), VrfMinZone
VrfMinZone:     jc      NoOutFalseVal
                cjne    a, (BSIZEBLOCK / 2 + bFALSEZONE / 2), VrfMaxZone
VrfMaxZone:     jnc     NoOutFalseVal
                mov	dph, aPtrInPhone
		mov	dpl, aPtrInPhone + 01h
		movx	a, @dptr
                and     a, #00011111b                   ; was from phone great value?
                jz      VrfNextFalsVal
                sjmp    CodingVal
                db      100001001b
VrfNextFalsVal: mov	dph, aPtrInLink
		mov	dpl, aPtrInLink + 01h
		movx	a, @dptr
                and     a, #00011111b                   ; was from link great value?
                jz      NoOutFalseVal
CodingVal:      xrl     a, tl1
                xrl     a, th1                          ; generating of random value
                %OutByt (ToLink)
     ) fi
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

NoOutFalseVal:
%if (%eqs (%MAKE,SIM))
then (
                movx    a, @r0
     ) fi
                cjne	@r1, #%bSIZEBLOCK, VrfIOPhone	; begin of III cycle?
		jb	biWho,             VrfIOPhone	; for master will prepare delay?
		mov	bCount, bCountDelay             ; prepare cycle III as "short" cycle
VrfIOPhone:	mov	dph, aPtrOutPhone
		mov	dpl, aPtrOutPhone + 01h
		movx	a, @dptr			; load amplitude of signal

;┌──────────── Phases i/o of phone ──────────┐
;│                  ┌─────────┬─┐  ┌──────── │
;│ Output to phone  │         | |  │         │
;│                  ┴──────┴──┴─┴──┴───────┴ │
;│      Phases         I      II      III    │
;│                  ───┬─┐  ┌─────────────── │
;│ Input from phone    | |  │                │
;│                  ┴──┴─┴─┴┴──────┴───────┴ │
;└───────────────────────────────────────────┘

		cjne	r6, #bPHASE_I, NoIVal

;[]++++++++++++++ First phase i/o of phone ++++ Begin +[]
                %RunPhonADC
		sjmp	NextPhase
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

		db	10010000b
NoIVal:		cjne	r6, #bPHASE_II, NoIIVal

;[]+++++++++++++++ Second phase i/o of phone ++ Begin +[]
                %OutByt	(ToPhone)			; transmission current byte to phone
		sjmp	NextPhase
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

;[]++++++++++ Third (last) phase i/o of phone + Begin +[]
NoIIVal:        mov	r6, #(bPHASE_I - 1)

; !!!		jnb	biGnrtSync, EndIIIPhase		; generated synchro signals?
; !!!		dec	aPtrInPhone  + 01h
; !!!		sjmp	OutVal2Link
; !!!EndIIIPhase:

		inc	aPtrOutPhone + 01h		; increment pointer aPtrOutPhone
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

NextPhase:	inc	r6				; towards next phase
VrfEndCycle:	djnz	bCount, ExitScrmbTask   	; goto towards next cycles?
		mov	bCount, #%bSIZEBLOCK
		mov	r6,     #00h			; init first phase for output to phone
		cjne	r5, #02h, VrfIVCycle
		jb	biPassReciev, RecievPass0	; reciever pass 1?
		mov	aPtrOutPhone,       #high (sInOutArr1)
		mov	aPtrOutPhone + 01h, #low  (sInOutArr1)
		mov	aPtrInLink,         #high (sInOutArr3)
		mov	aPtrInLink   + 01h, #low  (sInOutArr3 - 1)
		sjmp	SetPassReciev
		db	01110101b
RecievPass0:	mov	aPtrOutPhone,       #high (sInOutArr3)
		mov	aPtrOutPhone + 01h, #low  (sInOutArr3)
		mov	aPtrInLink,         #high (sInOutArr1)
		mov	aPtrInLink   + 01h, #low  (sInOutArr1 - 1)
SetPassReciev:	cpl	biPassReciev
VrfIVCycle:	cjne	r5, #(bCYCLE_III + 1), ChngCycle; now is cycle IV?
		mov	r5, #bCYCLE_II			; after IV cycle will be II cycle
                reti
		db	11000010b
ChngCycle:	jb	biWho, ChngSlave		; master or slave?
		inc	r5				; change cycle for master
		cjne	r5, #(bCYCLE_III + 1), ExitScrmbTask
		mov	r5, #bCYCLE_I
                reti
ChngSlave:	dec	r5				; change cycle for slave
		cjne	r5, #(bCYCLE_I - 1),   ExitScrmbTask
		mov	r5, #bCYCLE_III
ExitScrmbTask:	reti
		db	01110101b
		acall	IdleSubr2

;[]*****************************************************[]
;[]		OutPhone:  output  to  phone		[]
;[]		 Input:  acc - byte for output		[]
;[]		 Output: none				[]
;[]*****************************************************[]
OutPhone:	%OutByt	(ToPhone)
		ret

;[]*****************************************************[]
;[]	    Scrambling:  scrambling  information	[]
;[]	Input:  none					[]
;[]	Output: acc = 00h - normal execution (hung up	[]
;[]		          the receiver);		[]
;[]             acc = 01h - absence of synchronization;	[]
;[]		acc = 02h - information gap;		[]
;[]		acc = 03h - pressed key CANCEL		[]
;[]*****************************************************[]
Scrambling:	

;[]+++++++++++++ Hardware initialization ++++++ Begin +[]
                mov	th0,  #(0FFh - %bDGTZCYCLE)	; init counter for timer 0
%if (%eqs (%MAKE,EMU))
then (
                setb	it1				; negative-going slope (1 -> 0) for ext. int. 1
     )
else (
                setb	it0				; negative-going slope for ext. int. 0
     ) fi

;┌─────────┬───────────────────────────────────┬────────────────────────────┐
;│  Timers │        Programming regime         │             Use            │
;├─────────┼───────────────────────────────────┼────────────────────────────┤
;│    0    │ Regime 2 (8 bit autoload counter) │ Cycle of scrambling        │
;│    1    │ Regime 1 (16 bit counter)         │ Used for calculating cycle │
;└─────────┴───────────────────────────────────┴────────────────────────────┘

		anl	tmod, #00000010b     		; init regimes
		orl	tmod, #00010010b
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

;[]+++++++++ Analysing of mean value in link ++ Begin +[]
;               mov     r0,   #bAVERAGESIZE
;               mov     dptr, #sInOutArr0
;LoopAnalys:    push    dph
;               mov	dph,  #high (wADCDACSEG)
;               setb	biDam				; DAM: let pass signal
;               nop
;               push    acc
;               nop
;               pop     acc
;               nop
;		clr	biDam				; DAM: fix signal
;               RunLinkADC
;if (nes (MAKE,SIM))
;then (
;		jb	biLinkAdcRdy, $			; wait measuring value
;     ) fi
;		movx	a, @dptr			; reading value
;               StopLinkADC
;               pop     dph
;               movx    @dptr, a                        ; save value from link
;               inc     dptr
;               djnz    r0, LoopAnalys

;               .       .       .

;               mov     bMeanVal, a                     ; saving mean value
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

;[]++++++++ Formation arrays for start squeak + Begin +[]
%if (%nes (%MAKE,SIM))
then (
                mov     r0,   #%bSIZEBLOCK
                mov     dptr, #sInOutArr0
                mov     a,    #(bNULLPOT - 20h)
ContFill:       mov     r1,   #04h
FillArrs:       movx    @dptr, a
                inc     dptr
                djnz    r1, FillArrs
                cpl     a
                djnz    r0, ContFill
     ) fi
;[]+++++++++++++++++++++++++++++++++++++++++++++ End ++[]

		acall	Synchro				; process synchronization of scramblers
BegFalseCode	equ	$
		jnb	biGnrtSync, Scrambling
		acall	IdleSubr1
		ret
EternLoop:	sjmp	$				; eternal loop
		db	01010001b
		acall	IdleSubr3
bSYNCHOK	equ	$ - BegFalseCode
		cjne	a,  #bSYNCHOK, SyncAbsence	; scramblers was synchronize?
		push	ar1
		ret
		push	acc
SyncAbsence:	mov	a,  #low  (EternLoop)
		push	acc
		mov	a,  #high (EternLoop)
		push	acc
		mov	a,  #bWRNSYNCABSNC		; error: scramblers don't synchronize

;[]*****************************************************[]
;[]		     Beep:  sound  output		[]
;[]	         Input:  acc - count of squeaks		[]
;[]		 Output: none				[]
;[]     Frequency - ў 1.6 kHz,  duration - ў 0.2 s	[]
;[]*****************************************************[]
Beep:		push	acc
		mov	r6, #10
LoopBeep1:	mov	a,  #200
		acall	?P0040
		djnz	r6, LoopBeep1			; delay - 0.2 s
		mov	r6, #high (wDURATIONSOUND)
		mov	r7, #low  (wDURATIONSOUND)
LoopBeep2:	cjne	r6, #00h, DecrBeep
		cjne	r7, #00h, DecrBeep
		pop	acc
		djnz	acc, Beep
		ret
DecrBeep:	mov	r0, #06h			; r0 - pointer on r6
		acall	?P0026				; decrement counter
		mov	a, #(bNULLPOT - 20h)
		acall	OutPhone
		mov	a, #03h
		acall	?P0040				; delay - 300 mcs
		mov	a, #(bNULLPOT + 20h)
		acall	OutPhone
		mov	a, #03h
		acall	?P0040				; delay - 300 mcs
		sjmp	LoopBeep2
		db	00110001b

;[]*****************************************************[]
;[]	        Fork:  start  a  new  process		[]
;[]	Input:  r5 - number of start cycle:		[]
;[]		bCYCLE_I   - start slave;		[]
;[]		bCYCLE_II  - start master;		[]
;[]		bCYCLE_III - generate synchro	        []
;[]	Output: none					[]
;[]*****************************************************[]
Fork:		clr	biPassReciev			; reciever pass     - 0
		clr	biPassTransm			; transmission pass - 0
		setb	biRstLink			; set flag reset of link
		setb	biUpdTransmPtr			; will update transmission pointers
		setb	et0				; enable task
		mov	tl0,    #0FFh
		mov	r1,     #bCount			; r1 - address of bCount
		mov	r6,     #bPHASE_I		; begin from first phase i/o of phone
                mov     bTicks, #00h
		cjne	r5, #bCYCLE_II, VrfTaskSlave	; start master?
%if (%eqs (%ANTI,GNRT))
then (
                setb	tr1				; start timer 1 for generating of false values to link
     ) fi
		sjmp	InitPointers
VrfTaskSlave:	cjne	r5, #bCYCLE_I,  VrfOthers	; start slave?
InitPointers:	mov	r6,              #00h		; begin first phase output to phone
		mov	aPtrOutLink,     #high (sInOutArr0)
		mov	aPtrOutLink + 1, #low  (sInOutArr0)
		mov	aPtrInLink,      #high (sInOutArr1)
		mov	aPtrInLink  + 1, #low  (sInOutArr1 - 1)
		mov	bCount,          #%bSIZEBLOCK
		jb	biWho, InitSlave		; slave will initialize?
		mov	aPtrInPhone,      #high (sInOutArr2 + %bSIZEBLOCK / 3)
		mov	aPtrInPhone  + 1, #low  (sInOutArr2 + %bSIZEBLOCK / 3)
		mov	aPtrOutPhone,     #high (sInOutArr3 + 2 * %bSIZEBLOCK / 3)
		mov	aPtrOutPhone + 1, #low  (sInOutArr3 + 2 * %bSIZEBLOCK / 3)
		sjmp	StrtMstrSlave
InitSlave:	mov	aPtrInPhone,      #high (sInOutArr2)
                mov	aPtrInPhone  + 1, #low  (sInOutArr2)
		mov	aPtrOutPhone,     #high (sInOutArr3)
		mov	aPtrOutPhone + 1, #low  (sInOutArr3)
StrtMstrSlave:	setb	tr0				; start scrambler task
%if (%eqs (%MAKE,DEB) or %eqs (%MAKE,EMU))
then (
StartLoop:      clr     biCtrl1
                sjmp    StartLoop
     )
else (
		sjmp	$				; eternal loop (now only!)
     ) fi
		db	01110100b
IdleGoto:	acall	IdleSubr5
                acall   IdleSubr1
		sjmp    StrtOthers
		db	10111101b
VrfOthers:	cjne	r5, #bCYCLE_III, IdleGoto
		mov	bCount, #bDURATIONSYNC
		mov	r7,     #00h			; init angle
		mov	aPtrInPhone,      #high (sInOutArr2)   ; !!!
		mov	aPtrInPhone  + 1, #low  (sInOutArr2)   ; !!!
		mov	aPtrOutPhone,     #high (sInOutArr2)   ; !!!
		mov	aPtrOutPhone + 1, #low  (sInOutArr2)   ; !!!
		setb	biGnrtSync			; set flag generating synchro signals
StrtOthers:	setb	tr0				; start task
		cjne    @r1, #%bSIZEBLOCK, $		; wait of ending the task
		clr	et0				; disable task
		clr	tr0				; stop task
		clr	biGnrtSync			; clear flag generating synchro signals
		ret
		db	00010001b

		end
