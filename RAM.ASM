CodeSeg		segment code
		rseg	CodeSeg
		org	0A000h

		db	00h

		org	0C000h
sInOutArr:	db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 1
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 2
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 3
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 4
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 5
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 6
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 7
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 8
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h

		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 1
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 2
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 3
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 4
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 5
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 6
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 7
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h	; 8
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
		db	00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h

		end
