MODE6
fromAddr = &80
romNumber = &87 : REM Set to address of .sramBankNumber

PRINT'"Electron Elite (Econet version)"
PRINT"==============================="
PRINT'"Based on the Acornsoft SLG38 release"
PRINT"of Elite by Ian Bell and David Braben"
PRINT"Copyright (c) Acornsoft 1984"
PRINT'"Flicker-free routines, bug fixes,"
PRINT"enhancements and Econet conversion"
PRINT"by Mark Moxon"
PRINT'"Sideways RAM loader, routines and"
PRINT"inspiration by Wouter Hobers"

DIM code &100
PROCassemble
FOR A%=15 TO 0 STEP -1
IF FNswram(A%) THEN PROCelite(A%)
NEXT
PRINT'"Can't run: no sideways RAM detected":END
END

DEF PROCassemble
FOR P = 0 TO 2 STEP 2
P%=code
[OPT P
\ A contains bank# to check
JSR pagein
\ Change first byte
LDA &8000
EOR #&FF
STA &8000
STA tmp
\ Check if changed
LDA &8000
CMP tmp
BEQ changed
\ Unchanged, not SWRAM
.fail
JSR basic
LDA #0
RTS

.changed
\ Restore first byte
LDA tmp
EOR #&FF
STA &8000
\ Check for copyright
LDX &8007
LDY #0
.loop
LDA &8000,X
CMP copyright,Y
BNE unoccupied
INX
INY
CPY #4
BNE loop
\ Found copyright, occupied
JMP fail

.unoccupied
JSR basic
LDA #&FF
RTS

.basic
LDA #&0B
JMP sheila

.pagein
PHA
LDA #&0C
JSR sheila
PLA

.sheila
STA &F4
STA &FE05
RTS

.copyright
EQUB 0
EQUS "(C)"

.tmp
EQUB 0

.SRLOAD
LDA &F4
PHA
LDA romNumber
JSR pagein
.SR1
LDY #0
LDA (fromAddr),Y
STA toBlock+4
LDA #6
LDX #toBlock MOD256
LDY #toBlock DIV256
JSR &FFF1
INC fromAddr
INC toBlock
BNE SR1
INC fromAddr+1
INC toBlock+1
LDA toBlock+1
CMP #&C0
BNE SR1
PLA
JSR pagein
RTS

.toBlock
EQUD &8000
EQUD 0
]
NEXT
ENDPROC
:
DEF FNswram(A%)
=USR code AND &FF
ENDFN
:
DEF PROCelite(A%)
?romNumber=A% AND &FF
PRINT'"Sideways RAM detected in bank ";?romNumber;
PRINT'"Loading code into RAM bank ";?romNumber;"...";
*LOAD ELITERM 2000
!&80=&2000 : CALL SRLOAD : REM Load ROM image into the correct bank
PRINT " OK"
PRINT'"Press any key to play Elite";
A$=GET$
*FX138,0,32
CHAIN "ELITE"
ENDPROC
