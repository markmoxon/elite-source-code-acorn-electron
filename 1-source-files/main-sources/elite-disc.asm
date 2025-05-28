\ ******************************************************************************
\
\ ACORN ELECTRON ELITE DISC IMAGE SCRIPT
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
\ This source file produces an SSD disc image for Acorn Electron Elite.
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following SSD disc image:
\
\   * elite-electron-compendium.ssd
\
\ This can be loaded into an emulator or a real Electron.
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _IB_SUPERIOR           = (_VARIANT = 1)
 _IB_ACORNSOFT          = (_VARIANT = 2)

 PUTFILE "1-source-files/boot-files/$.!BOOT.bin", "!BOOT", &FFFFFF, &FFFFFF
 PUTBASIC "1-source-files/basic-programs/load-rom.bas", "ELITESR"
 PUTFILE "1-source-files/basic-programs/$.ELITE-disc.bin", "ELITE", &FF0E00, &FF8023
 PUTFILE "3-assembled-output/ELITEDA.bin", "ELITEDA", &FF4400, &FF5200
 PUTFILE "3-assembled-output/ELTROM.bin", "ELITERM", &FF8000, &FF8000
 PUTFILE "3-assembled-output/ELITECO.bin", "ELITECO", &000000, &FFFFFF
 PUTFILE "1-source-files/other-files/E.MAX.bin", "E.MAX", &000000, &000000
 PUTFILE "3-assembled-output/README.txt", "README", &FFFFFF, &FFFFFF
