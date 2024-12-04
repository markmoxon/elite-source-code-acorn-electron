\ ******************************************************************************
\
\ ACORN ELECTRON ELITE README
\
\ Acorn Electron Elite was written by Ian Bell and David Braben and is copyright
\ Acornsoft 1984
\
\ The code on this site has been reconstructed from a disassembly of the version
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
\ This source file produces a README file for Acorn Electron Elite.
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * README.txt
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _IB_SUPERIOR           = (_VARIANT = 1)
 _IB_ACORNSOFT          = (_VARIANT = 2)

.readme

 EQUB 10, 13
 EQUS "---------------------------------------"
 EQUB 10, 13
 EQUS "Acornsoft Elite"
 EQUB 10, 13
 EQUB 10, 13
 EQUS "Version: Acorn Electron"
 EQUB 10, 13

IF _IB_ACORNSOFT

 EQUS "Variant: Ian Bell's Acornsoft UEF"
 EQUB 10, 13
 EQUS "Product: Acornsoft SLG38 (TBC)"
 EQUB 10, 13

ELIF _IB_SUPERIOR

 EQUS "Variant: Ian Bell's Superior UEF"
 EQUB 10, 13
 EQUS "Product: Superior Software (TBC)"
 EQUB 10, 13

ENDIF

 EQUB 10, 13
 EQUS "See www.bbcelite.com for details"
 EQUB 10, 13
 EQUS "---------------------------------------"
 EQUB 10, 13

 SAVE "3-assembled-output/README.txt", readme, P%

