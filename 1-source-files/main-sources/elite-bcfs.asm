\ ******************************************************************************
\
\ ACORN ELECTRON ELITE BIG CODE FILE SOURCE
\
\ Acorn Electron Elite was written by Ian Bell and David Braben and is copyright
\ Acornsoft 1984
\
\ The code in this file has been reconstructed from a disassembly of the version
\ released on Ian Bell's personal website at http://www.elitehomepage.org/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://elite.bbcelite.com/terminology
\
\ The deep dive articles referred to in this commentary can be found at
\ https://elite.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file contains code to produce the Big Code File for Acorn Electron
\ Elite. The Big Code File comprises the game code, the ship blueprints and the
\ game text.
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary files:
\
\   * ELITECO.bin
\
\ after reading in the following files:
\
\   * ELTA.bin
\   * ELTB.bin
\   * ELTC.bin
\   * ELTD.bin
\   * ELTE.bin
\   * ELTF.bin
\   * ELTG.bin
\   * SHIPS.bin
\   * WORDS9.bin
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _IB_SUPERIOR           = (_VARIANT = 1)
 _IB_ACORNSOFT          = (_VARIANT = 2)

 GUARD &5800            \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 CODE% = &0D00          \ CODE% is set to the location that the main game code
                        \ gets moved to after it is loaded

IF _DISC

 LOAD% = &2000          \ The load address of the main game code file

ELSE

 LOAD% = &0E00          \ The load address of the main game code file

ENDIF

\ ******************************************************************************
\
\ Load the compiled binaries to create the Big Code File
\
\ ******************************************************************************

 ORG CODE%              \ Set the assembly address to CODE%

.elitea

 PRINT "elitea = ", ~P%
 INCBIN "3-assembled-output/ELTA.bin"

.eliteb

 PRINT "eliteb = ", ~P%
 INCBIN "3-assembled-output/ELTB.bin"

.elitec

 PRINT "elitec = ", ~P%
 INCBIN "3-assembled-output/ELTC.bin"

.elited

 PRINT "elited = ", ~P%
 INCBIN "3-assembled-output/ELTD.bin"

.elitee

 PRINT "elitee = ", ~P%
 INCBIN "3-assembled-output/ELTE.bin"

.elitef

 PRINT "elitef = ", ~P%
 INCBIN "3-assembled-output/ELTF.bin"

.eliteg

 PRINT "eliteg = ", ~P%
 INCBIN "3-assembled-output/ELTG.bin"

.checksum0

 PRINT "checksum0 = ", ~P%

 SKIP 1                 \ We skip this byte so we can insert the checksum later
                        \ in elite-checksum.py

IF _IB_ACORNSOFT

 SKIP 1                 \ This byte appears to be unused

ENDIF

.ships

 PRINT "ships = ", ~P%
 INCBIN "3-assembled-output/SHIPS.bin"

.end

\ ******************************************************************************
\
\ Save ELITECO.unprot.bin
\
\ ******************************************************************************

 PRINT "P% = ", ~P%
 PRINT "S.ELITECO ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/ELITECO.unprot.bin", CODE%, P%, LOAD%
