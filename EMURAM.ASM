
;	Emulating RAM for scrambler

		cseg	at 0C000h
		db	01h, 02h, 03h

		cseg	at 0C100h
		db	11h, 12h, 13h

		cseg	at 0C200h
		db	21h, 22h, 23h

		cseg	at 0C300h
		db	31h, 32h, 33h

		end
