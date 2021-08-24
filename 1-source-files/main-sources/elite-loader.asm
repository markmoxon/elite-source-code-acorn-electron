\ ******************************************************************************
\
\ ELECTRON ELITE LOADER SOURCE
\
\ Electron Elite was written by Ian Bell and David Braben and is copyright
\ Acornsoft 1984
\
\ The code on this site has been disassembled from the version released on Ian
\ Bell's personal website at http://www.elitehomepage.org/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
\
\ The deep dive articles referred to in this commentary can be found at
\ https://www.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * ELITEDA.bin
\
\ ******************************************************************************

INCLUDE "1-source-files/main-sources/elite-header.h.asm"

GUARD &5800             \ Guard against assembling over screen memory

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

N% = 17                 \ N% is set to the number of bytes in the VDU table, so
                        \ we can loop through them in part 2 below

USERV = &0200           \ The address of the user vector
BRKV = &0202            \ The address of the break vector
IRQ1V = &0204           \ The address of the interrupt vector
WRCHV = &020E           \ The address of the write character vector
RDCHV = &0210           \ The address of the read character vector
KEYV = &0228            \ The address of the keyboard vector

LE% = &0B00             \ LE% is the address to which the code from UU% onwards
                        \ is copied in part 3

C% = &0D00              \ C% is set to the location that the main game code gets
                        \ moved to after it is loaded

L% = &2000              \ L% is the load address of the main game code file

S% = C%                 \ S% points to the entry point for the main game code

VIA = &FE00             \ Memory-mapped space for accessing internal hardware,
                        \ such as the video ULA, 6845 CRTC and 6522 VIAs (also
                        \ known as SHEILA)

OSWRCH = &FFEE          \ The address for the OSWRCH routine
OSBYTE = &FFF4          \ The address for the OSBYTE routine
OSWORD = &FFF1          \ The address for the OSWORD routine
OSCLI = &FFF7           \ The address for the OSCLI routine

\ ******************************************************************************
\
\       Name: ZP
\       Type: Workspace
\    Address: &0004 to &0005 and &0070 to &0086
\   Category: Workspaces
\    Summary: Important variables used by the loader
\
\ ******************************************************************************

ORG &0004

.TRTB%

 SKIP 2                 \ Contains the address of the keyboard translation
                        \ table, which is used to translate internal key
                        \ numbers to ASCII

ORG &0070

.ZP

 SKIP 2                 \ Stores addresses used for moving content around

.P

 SKIP 1                 \ Temporary storage, used in a number of places

.Q

 SKIP 1                 \ Temporary storage, used in a number of places

.YY

 SKIP 1                 \ Temporary storage, used in a number of places

.T

 SKIP 1                 \ Temporary storage, used in a number of places

.SC

 SKIP 1                 \ Screen address (low byte)
                        \
                        \ Elite draws on-screen by poking bytes directly into
                        \ screen memory, and SC(1 0) is typically set to the
                        \ address of the character block containing the pixel
                        \ we want to draw (see the deep dives on "Drawing
                        \ monochrome pixels in mode 4" and "Drawing pixels
                        \ in the Electron version" for more details)

.SCH

 SKIP 1                 \ Screen address (high byte)

.BLPTR

 SKIP 2                 \ Gets set to &03CA as part of the obfuscation code

.V219

 SKIP 2                 \ Gets set to &0218 as part of the obfuscation code

 SKIP 4                 \ These bytes appear to be unused

.K3

 SKIP 1                 \ Temporary storage, used in a number of places

.BLCNT

 SKIP 2                 \ Stores the tape loader block count as part of the copy
                        \ protection code in IRQ1

.BLN

 SKIP 2                 \ Gets set to &03C6 as part of the obfuscation code

.EXCN

 SKIP 2                 \ Gets set to &03C2 as part of the obfuscation code

\ ******************************************************************************
\
\ ELITE LOADER
\
\ ******************************************************************************

CODE% = &4400
LOAD% = &4400

ORG CODE%

\ ******************************************************************************
\
\       Name: Elite loader (Part 1 of 5)
\       Type: Subroutine
\   Category: Loader
\    Summary: Include binaries for recursive tokens and images
\
\ ------------------------------------------------------------------------------
\
\ The loader bundles a number of binary files in with the loader code, and moves
\ them to their correct memory locations in part 3 below.
\
\ There is one file containing code:
\
\   * WORDS9.bin contains the recursive token table, which is moved to &0400
\     before the main game is loaded
\
\ and four files containing images, which are all moved into screen memory by
\ the loader:
\
\   * P.A-SOFT.bin contains the "ACORNSOFT" title across the top of the loading
\     screen, which gets moved to screen address &5960, on the second character
\     row of the space view
\
\   * P.ELITE.bin contains the "ELITE" title across the top of the loading
\     screen, which gets moved to screen address &5B00, on the fourth character
\     row of the space view
\
\   * P.(C)ASFT.bin contains the "(C) Acornsoft 1984" title across the bottom
\     of the loading screen, which gets moved to screen address &73A0, the
\     penultimate character row of the space view, just above the dashboard
\
\   * P.DIALS.bin contains the dashboard, which gets moved to screen address
\     &7620, which is the starting point of the dashboard, just below the space
\     view
\
\ The routine ends with a jump to the start of the loader code at ENTRY.
\
\ ******************************************************************************

PRINT "WORDS9 = ",~P%
INCBIN "3-assembled-output/WORDS9.bin"

ALIGN 256

PRINT "P.DIALS = ",~P%
INCBIN "1-source-files/images/P.DIALS.bin"

PRINT "P.ELITE = ",~P%
INCBIN "1-source-files/images/P.ELITE.bin"

PRINT "P.A-SOFT = ",~P%
INCBIN "1-source-files/images/P.A-SOFT.bin"

PRINT "P.(C)ASFT = ",~P%
INCBIN "1-source-files/images/P.(C)ASFT.bin"

.run

 JMP ENTRY              \ Jump to ENTRY to start the loading process

\ ******************************************************************************
\
\       Name: B%
\       Type: Variable
\   Category: Screen mode
\    Summary: VDU commands for changing to a standard mode 4 screen
\
\ ------------------------------------------------------------------------------
\
\ This block contains the bytes that get written by OSWRCH to set up the screen
\ mode (this is equivalent to using the VDU statement in BASIC).
\
\ The Electron version of Elite is unique in that it uses a standard mode 4
\ screen, rather than the custom square mode used in the BBC versions. This is
\ because the Electron lacks the 6845 CRTC chip, which the BBC versions use to
\ customise the mode.
\
\ To make the Electron screen appear square like the BBC versions, there is a
\ blank 32-byte (&20-byte) margin on each end of each character row, so each
\ character row consists of 32 blank bytes on the left, then a page (256 bytes)
\ of screen memory containing the game display, then another 32 blank bytes on
\ the right. Screen memory is from &5800 to &7FFF, and the bottom row from &7EC0
\ to &7FFF is left blank, again to be consistent with look of the BBC version.
\ This means the screen takes up more memory on the Electron version than on the
\ BBC versions, despite showing the same amount of content.
\
\ On top of this, the Electron also lacks the Video ULA of the BBC Micro, so the
\ famous split-screen mode of the BBC versions can't be implemented in the
\ Electron version, as the BBC versions reprogram the ULA to create the coloured
\ dashboard. As a result, not only does the Electron suffer from the bigger
\ memory footprint of the screen, it also has to stick to the same palette for
\ the whole screen, so while the space view is the same monochrome mode 4 view
\ as in the BBC versions, the dashboard has to be in the same screen mode, so
\ it's also monochrome (though it has twice the number of horizontal pixels as
\ the four-colour mode 5 dashboard of the BBC versions, so it is noticeably
\ sharper, at least).
\
\ The following are also set up:
\
\   * The text window is 9 rows high and 15 columns wide, and is at (8, 10)
\
\   * The cursor is disabled
\
\ ******************************************************************************

.B%

 EQUB 22, 4             \ Switch to screen mode 4

 EQUB 28                \ Define a text window as follows:
 EQUB 8, 19, 23, 10     \
                        \   * Left = 8
                        \   * Right = 23
                        \   * Top = 10
                        \   * Bottom = 19
                        \
                        \ i.e. 9 rows high, 15 columns wide at (8, 10)

 EQUB 23, 1, 0, 0       \ Disable the cursor
 EQUB 0, 0, 0
 EQUB 0, 0, 0

\ ******************************************************************************
\
\       Name: E%
\       Type: Variable
\   Category: Sound
\    Summary: Sound envelope definitions
\
\ ------------------------------------------------------------------------------
\
\ This table contains the sound envelope data, which is passed to OSWORD by the
\ FNE macro to create the four sound envelopes used in-game. Refer to chapter 22
\ of the Acorn Electron User Guide for details of sound envelopes and what all
\ the parameters mean.
\
\ The envelopes are as follows:
\
\   * Envelope 1 is the sound of our own laser firing
\
\   * Envelope 2 is the sound of lasers hitting us, or hyperspace
\
\   * Envelope 3 is the first sound in the two-part sound of us dying, or the
\     second sound in the two-part sound of us making hitting or killing an
\     enemy ship
\
\   * Envelope 4 is the sound of E.C.M. firing
\
\ ******************************************************************************

.E%

 EQUB 1, 1, 0, 111, -8, 4, 1, 8, 126, 0, 0, -126, 126, 126
 EQUB 2, 1, 14, -18, -1, 44, 32, 50, 6, 1, 0, -2, 120, 126
 EQUB 3, 1, 1, -1, -3, 17, 32, 128, 1, 0, 0, -1, 1, 1
 EQUB 4, 1, 4, -8, 44, 4, 6, 8, 22, 0, 0, -127, 126, 0

\ ******************************************************************************
\
\       Name: swine
\       Type: Subroutine
\   Category: Copy protection
\    Summary: Resets the machine if the copy protection detects a problem
\
\ ******************************************************************************

.swine

 JMP (&FFFC)            \ Jump to the address in &FFFC to reset the machine

\ ******************************************************************************
\
\       Name: OSB
\       Type: Subroutine
\   Category: Utility routines
\    Summary: A convenience routine for calling OSBYTE with Y = 0
\
\ ******************************************************************************

.OSB

 LDY #0                 \ Call OSBYTE with Y = 0, returning from the subroutine
 JMP OSBYTE             \ using a tail call (so we can call OSB to call OSBYTE
                        \ for when we know we want Y set to 0)

\ ******************************************************************************
\
\       Name: Authors' names
\       Type: Variable
\   Category: Copy protection
\    Summary: The authors' names, buried in the code
\
\ ------------------------------------------------------------------------------
\
\ Contains the authors' names, plus an unused OS command string that would
\ *RUN the main game code, which isn't what actually happens (so presumably
\ this is to throw the crackers off the scent).
\
\ ******************************************************************************

 EQUS "RUN ELITEcode"
 EQUB 13

 EQUS "By D.Braben/I.Bell"
 EQUB 13

 EQUB &B0

\ ******************************************************************************
\
\       Name: oscliv
\       Type: Variable
\   Category: Utility routines
\    Summary: Contains the address of OSCLIV, for executing OS commands
\
\ ******************************************************************************

.oscliv

 EQUW &FFF7             \ Address of OSCLIV, for executing OS commands
                        \ (specifically the *LOAD that loads the main game code)

\ ******************************************************************************
\
\       Name: David9
\       Type: Variable
\   Category: Copy protection
\    Summary: Address used as part of the stack-based decryption loop
\
\ ------------------------------------------------------------------------------
\
\ This address is used in the decryption loop starting at David2 in part 4, and
\ is used to jump back into the loop at David5.
\
\ ******************************************************************************

.David9

 EQUW David5            \ The address of David5

 CLD                    \ This instruction is not used

\ ******************************************************************************
\
\       Name: David23
\       Type: Variable
\   Category: Copy protection
\    Summary: Address pointer to the start of the 6502 stack
\
\ ------------------------------------------------------------------------------
\
\ This two-byte address points to the start of the 6502 stack, which descends
\ from the end of page 2, less LEN bytes, which comes out as &01DF. So when we
\ push 33 bytes onto the stack (LEN being 33), this address will point to the
\ start of those bytes, which means we can push executable code onto the stack
\ and run it by calling this address with a JMP (David23) instruction. Sneaky
\ stuff!
\
\ ******************************************************************************

.David23

 EQUW 6                 \ This value is not used in this unprotected version of
                        \ the loader, though why the crackers set it to 6 is a
                        \ mystery

\ ******************************************************************************
\
\       Name: doPROT1
\       Type: Subroutine
\   Category: Copy protection
\    Summary: Routine to self-modify the loader code
\
\ ------------------------------------------------------------------------------
\
\ This routine modifies various bits of code in-place as part of the copy
\ protection mechanism. It is called with A = &48 and X = 255.
\
\ ******************************************************************************

.doPROT1

 LDY #&DB               \ Store &EFDB in TRTB%(1 0) to point to the keyboard
 STY TRTB%              \ translation table for OS 0.1 (which we will overwrite
 LDY #&EF               \ with a call to OSBYTE later)
 STY TRTB%+1

 LDY #2                 \ Set the high byte of V219(1 0) to 2
 STY V219+1

 CMP swine-5,X          \ This part of the loader has been disabled by the
                        \ crackers, by changing an STA to a CMP (as this is an
                        \ unprotected version)

 LDY #&18               \ Set the low byte of V219(1 0) to &18 (as X = 255), so
 STY V219+1,X           \ V219(1 0) now contains &0218

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MHCA
\       Type: Variable
\   Category: Copy protection
\    Summary: Used to set one of the vectors in the copy protection code
\
\ ------------------------------------------------------------------------------
\
\ This value is used to set the low byte of BLPTR(1 0), when it's set in PLL1
\ as part of the copy protection.
\
\ ******************************************************************************

.MHCA

 EQUB &CA               \ The low byte of BLPTR(1 0)

\ ******************************************************************************
\
\       Name: David7
\       Type: Subroutine
\   Category: Copy protection
\    Summary: Part of the multi-jump obfuscation code in PROT1
\
\ ------------------------------------------------------------------------------
\
\ This instruction is part of the multi-jump obfuscation in PROT1 (see part 2 of
\ the loader), which does the following jumps:
\
\   David8 -> FRED1 -> David7 -> Ian1 -> David3
\
\ ******************************************************************************

.David7

 BCC Ian1               \ This instruction is part of the multi-jump obfuscation
                        \ in PROT1

\ ******************************************************************************
\
\       Name: FNE
\       Type: Macro
\   Category: Sound
\    Summary: Macro definition for defining a sound envelope
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used to define the four sound envelopes used in the
\ game. It uses OSWORD 8 to create an envelope using the 14 parameters in the
\ the I%-th block of 14 bytes at location E%. This OSWORD call is the same as
\ BBC BASIC's ENVELOPE command.
\
\ See variable E% for more details of the envelopes themselves.
\
\ ******************************************************************************

MACRO FNE I%

  LDX #LO(E%+I%*14)     \ Set (Y X) to point to the I%-th set of envelope data
  LDY #HI(E%+I%*14)     \ in E%

  LDA #8                \ Call OSWORD with A = 8 to set up sound envelope I%
  JSR OSWORD

ENDMACRO

\ ******************************************************************************
\
\       Name: Elite loader (Part 2 of 5)
\       Type: Subroutine
\   Category: Loader
\    Summary: Perform a number of OS calls, set up sound, push routines on stack
\
\ ------------------------------------------------------------------------------
\
\ This part of the loader does a number of calls to OS routines, sets up the
\ sound envelopes, and pushes 33 bytes onto the stack. A lot of the code in this
\ routine has been removed or hobbled to remove the protection; for a full
\ picture of the protection that's missing, see the source code for the BBC
\ Micro cassette version, which contains almost exactly the same protection code
\ as the original Electron version.
\
\ ******************************************************************************

.ENTRY

 NOP                    \ This part of the loader has been disabled by the
 NOP                    \ crackers, as this is an unprotected version NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP

 LDA #&60               \ This appears to be a lone instruction left over from
 STA &0088              \ the unprotected code, as this value is never used

 NOP                    \ This part of the loader has been disabled by the
 NOP                    \ crackers, as this is an unprotected version
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP

 LDA #&20               \ Set A to the op code for a JSR call with absolute
                        \ addressing

 NOP                    \ This part of the loader has been disabled by the
                        \ crackers, as this is an unprotected version

.Ian1

 NOP                    \ This part of the loader has been disabled by the
 NOP                    \ crackers, as this is an unprotected version
 NOP
 NOP
 NOP

 LSR A                  \ Set A = 16

 LDX #3                 \ Set the high bytes of BLPTR(1 0), BLN(1 0) and
 STX BLPTR+1            \ EXCN(1 0) to &3. We will fill in the high bytes in
 STX BLN+1              \ the PLL1 routine, and will then use these values in
 STX EXCN+1             \ the IRQ1 handler

 LDX #0                 \ Call OSBYTE with A = 16 and X = 0 to set the joystick
 LDY #0                 \ port to sample 0 channels (i.e. disable it)
 JSR OSBYTE

 LDX #255               \ Call doPROT1 to change an instruction in the PROT1
 LDA #&95               \ routine and set up another couple of variables
 JSR doPROT1

 LDA #144               \ Call OSBYTE with A = 144, X = 255 and Y = 0 to move
 JSR OSB                \ the screen down one line and turn screen interlace on

 EQUB &2C               \ Skip the next instruction by turning it into
                        \ &2C &D0 &92, or BIT &92D0, which does nothing apart
                        \ from affect the flags

.FRED1

 BNE David7             \ This instruction is skipped if we came from above,
                        \ otherwise this is part of the multi-jump obfuscation
                        \ in PROT1

 LDA #247               \ Call OSBYTE with A = 247 and X = Y = 0 to disable the
 LDX #0                 \ BREAK intercept code by poking 0 into the first value
 JSR OSB

 LDA #143               \ Call OSBYTE 143 to issue a paged ROM service call of
 LDX #&C                \ type &C with argument &FF, which is the "NMI claim"
 LDY #&FF               \ service call that asks the current user of the NMI
 JSR OSBYTE             \ space to clear it out

 LDA #13                \ Set A = 13 for the next OSBYTE call

.abrk

 LDX #0                 \ Call OSBYTE with A = 13, X = 0 and Y = 0 to disable
 JSR OSB                \ the "output buffer empty" event

 LDA #225               \ Call OSBYTE with A = 225, X = 128 and Y = 0 to set
 LDX #128               \ the function keys to return ASCII codes for SHIFT-fn
 JSR OSB                \ keys (i.e. add 128)

 LDA #172               \ Call OSBYTE 172 to read the address of the MOS
 LDX #0                 \ keyboard translation table into (Y X)
 LDY #255
 JSR OSBYTE

 STX TRTB%              \ Store the address of the keyboard translation table in
 STY TRTB%+1            \ TRTB%(1 0)

 NOP                    \ This part of the loader has been disabled by the
 NOP                    \ crackers, as this is an unprotected version
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP

 LDA #13                \ Call OSBYTE with A = 13, X = 2 and Y = 0 to disable
 LDX #2                 \ the "character entering keyboard buffer" event
 JSR OSB

.OS01

 LDX #&FF               \ Set the stack pointer to &01FF, which is the standard
 TXS                    \ location for the 6502 stack, so this instruction
                        \ effectively resets the stack

 INX                    \ Set X = 0, to use as a counter in the following loop

                        \ The following loop copies the crunchit routine into
                        \ zero page, though this unprotected version of the
                        \ loader doesn't call it there, so this has no effect

 LDY #0                 \ Set a counter in Y for the copy

.David3

 LDA crunchit,Y         \ Copy the Y-th byte of crunchit

.PROT1

 STA TRTB%+2,X          \ And store it in the X-th byte of zero page after the
                        \ TRTB%(1 0) variable

 INX                    \ Increment both byte counters
 INY

 CPY #33                \ Loop back to copy the next byte until we have copied
 BNE David3             \ all 33 bytes

 LDA #LO(B%)            \ Set the low byte of ZP(1 0) to point to the VDU code
 STA ZP                 \ table at B%

 LDA #&95               \ This part of the loader has been disabled by the
 BIT PROT1              \ crackers, as this is an unprotected version (the BIT
                        \ instruction is an STA instruction in the full version,
                        \ but it has been hobbled here)

 LDA #HI(B%)            \ Set the high byte of ZP(1 0) to point to the VDU code
 STA ZP+1               \ table at B%

 LDY #0                 \ We are now going to send the N% VDU bytes in the table
                        \ at B% to OSWRCH to set up the screen mode

.LOOP

 LDA (ZP),Y             \ Pass the Y-th byte of the B% table to OSWRCH
 JSR OSWRCH

 INY                    \ Increment the loop counter

 CPY #N%                \ Loop back for the next byte until we have done them
 BNE LOOP               \ all (the number of bytes was set in N% above)

 LDA #1                 \ This part of the loader has been disabled by the
 TAX                    \ crackers, as this is an unprotected version (the CMP
 TAY                    \ instruction is an STA instruction in the full version,
 LDA abrk+1             \ but it has been hobbled here)
 CMP (V219),Y

 LDA #4                 \ Call OSBYTE with A = 4, X = 1 and Y = 0 to disable
 JSR OSB                \ cursor editing, so the cursor keys return ASCII values
                        \ and can therefore be used in-game

 LDA #9                 \ Call OSBYTE with A = 9, X = 0 and Y = 0 to disable
 LDX #0                 \ flashing colours
 JSR OSB

 LDA #&6C               \ This part of the loader has been disabled by the
 NOP                    \ crackers, as this is an unprotected version (the BIT
 NOP                    \ instruction is an STA instruction in the full version,
 NOP                    \ but it has been hobbled here)
 BIT &544F

 FNE 0                  \ Set up sound envelopes 0-3 using the FNE macro
 FNE 1
 FNE 2
 FNE 3

\ ******************************************************************************
\
\       Name: Elite loader (Part 3 of 5)
\       Type: Subroutine
\   Category: Loader
\    Summary: Move recursive tokens and images
\
\ ------------------------------------------------------------------------------
\
\ Move the following memory blocks:
\
\   * WORDS9: move 4 pages (1024 bytes) from &4400 (CODE%) to &0400
\
\   * P.ELITE: move 1 page (256 bytes) from &4F00 (CODE% + &0B00) to &5BE0
\
\   * P.A-SOFT: move 1 page (256 bytes) from &5000 (CODE% + &0C00) to &5960
\
\   * P.(C)ASFT: move 1 page (256 bytes) from &5100 (CODE% + &0D00) to &73A0
\
\   * P.DIALS: move 7 pages (1792 bytes) from &4800 (CODE% + &0400) to &7620
\
\   * Move 1 page (256 bytes) from &5615 (UU%) to &0B00-&0BFF
\
\ and call the routine to draw Saturn between P.(C)ASFT and P.DIALS.
\
\ The dashboard image (P.DIALS) is moved into screen memory one page at a time,
\ but not in a contiguous manner - it has to take into account the &20 bytes of
\ blank margin at each edge of the screen (see the description of the screen
\ mode in B% above). So the seven rows of the dashboard are actually moved into
\ screen memory like this:
\
\     1 page from &4800 to &7620           = &7620
\     1 page from &4900 to &7720 + &40     = &7760
\     1 page from &4A00 to &7820 + 2 * &40 = &78A0
\     1 page from &4B00 to &7920 + 3 * &40 = &79E0
\     1 page from &4C00 to &7A20 + 4 * &40 = &7B20
\     1 page from &4D00 to &7B20 + 5 * &40 = &7C60
\     1 page from &4E00 to &7C20 + 6 * &40 = &7DA0
\
\ See part 1 above for more details on the above files and the locations that
\ they are moved to.
\
\ The code at UU% (see below) forms part of the loader code and is moved before
\ being run, so it's tucked away safely while the main game code is loaded and
\ decrypted.
\
\ In the unprotected version of the loader, the images are encrypted and this
\ part also decrypts them, but this is an unprotected version of the game, so
\ the encryption part of the crunchit routine is disabled.
\
\ ******************************************************************************

 LDX #4                 \ Set the following:
 STX P+1                \
 LDA #HI(CODE%)         \   P(1 0) = &0400
 STA ZP+1               \   ZP(1 0) = CODE%
 LDY #0                 \   (X Y) = &400 = 1024
 LDA #256-232           \
 CMP (V219-4,X)         \ The CMP instruction is an STA instruction in the
 STY ZP                 \ protected version of the loader, but this version has
 STY P                  \ been hacked to remove the protection, and the crackers
                        \ just switched the STA to a CMP to disable this bit of
                        \ the protection code

 JSR crunchit           \ Call crunchit to move &400 bytes from CODE% to &0400.
                        \ We loaded WORDS9.bin to CODE% in part 1, so this moves
                        \ WORDS9

 LDX #1                 \ Set the following:
 LDA #(HI(CODE%)+&B)    \
 STA ZP+1               \   P(1 0) = &5BE0
 LDA #&5B               \   ZP(1 0) = CODE% + &B
 STA P+1                \   (X Y) = &100 = 256
 LDA #&E0
 STA P
 LDY #0

 JSR crunchit           \ Call crunchit to move &100 bytes from CODE% + &B to
                        \ &5BE0, so this moves P.ELITE

 LDX #1                 \ Set the following:
 LDA #(HI(CODE%)+&C)    \
 STA ZP+1               \   P(1 0) = &5960
 LDA #&59               \   ZP(1 0) = CODE% + &C
 STA P+1                \   (X Y) = &100 = 256
 LDA #&60
 STA P
 LDY #0

 JSR crunchit           \ Call crunchit to move &100 bytes from CODE% + &C to
                        \ &5960, so this moves P.A-SOFT

 LDX #1                 \ Set the following:
 LDA #(HI(CODE%)+&D)    \
 STA ZP+1               \   P(1 0) = &73A0
 LDA #&73               \   ZP(1 0) = CODE% + &D
 STA P+1                \   (X Y) = &100 = 256
 LDA #&A0
 STA P
 LDY #0

 JSR crunchit           \ Call crunchit to move &100 bytes from CODE% + &D to
                        \ &73A0, so this moves P.(C)ASFT

 JSR PLL1               \ Call PLL1 to draw Saturn

 LDA #(HI(CODE%)+4)     \ Set the following:
 STA ZP+1               \
 LDA #&76               \   P(1 0) = &7620
 STA P+1                \   ZP(1 0) = CODE% + &4
 LDY #0                 \   Y = 0
 STY ZP                 \
 LDX #&20               \ Also set BLCNT = 0
 STY BLCNT
 STX P

.dialsL

 LDX #1                 \ Set (X Y) = &100 = 256

 JSR crunchit           \ Call crunchit to move &100 bytes from ZP(1 0) to
                        \ P(1 0), so this moves P.DIALS one row at a time

 CLC                    \ Set P(1 0) = P(1 0) + &40 to skip the screen margins
 LDA P
 ADC #&40
 STA P
 LDA P+1
 ADC #0
 STA P+1

 CMP #&7E               \ Loop back to copy the next row of the dashboard until
 BCC dialsL             \ we have poked the last one into screen memory

 LDX #1                 \ Set the following:
 LDA #HI(UU%)           \
 STA ZP+1               \   P(1 0) = LE%
 LDA #LO(UU%)           \   ZP(1 0) = UU%
 STA ZP                 \   (X Y) = &100 = 256
 LDA #HI(LE%)
 STA P+1
 LDY #0
 STY P

 JSR crunchit           \ Call crunchit to move &100 bytes from UU% to LE%

\ ******************************************************************************
\
\       Name: Elite loader (Part 4 of 5)
\       Type: Subroutine
\   Category: Loader
\    Summary: Call part 5 of the loader now that is has been relocated
\
\ ------------------------------------------------------------------------------
\
\ In the protected version of the loader, this part copies more code onto the
\ stack and decrypts a chunk of loader code before calling part 5, but in the
\ unprotected version it's mostly NOPs.
\
\ ******************************************************************************

 JMP &0B11              \ Call relocated UU% routine to load the main game code
                        \ at &2000, move it down to &0D00 and run it

 NOP                    \ This part of the loader has been disabled by the
 NOP                    \ crackers, as this is an unprotected version
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP

.RAND

 EQUD &6C785349         \ The random number seed used for drawing Saturn

.David5

 NOP                    \ This part of the loader has been disabled by the
 NOP                    \ crackers, as this is an unprotected version
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP
 NOP

\ ******************************************************************************
\
\       Name: PLL1
\       Type: Subroutine
\   Category: Drawing planets
\    Summary: Draw Saturn on the loading screen
\  Deep dive: Drawing Saturn on the loading screen
\
\ ******************************************************************************

.PLL1

                        \ The following loop iterates CNT(1 0) times, i.e. &500
                        \ or 1280 times, and draws the planet part of the
                        \ loading screen's Saturn

 JSR DORND              \ Set A and X to random numbers, say A = r1

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r1^2

 STA ZP+1               \ Set ZP(1 0) = (A P)
 LDA P                  \             = r1^2
 STA ZP

 JSR DORND              \ Set A and X to random numbers, say A = r2

 STA YY                 \ Set YY = A
                        \        = r2

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r2^2

 TAX                    \ Set (X P) = (A P)
                        \           = r2^2

 LDA P                  \ Set (A ZP) = (X P) + ZP(1 0)
 ADC ZP                 \
 STA ZP                 \ first adding the low bytes

 TXA                    \ And then adding the high bytes
 ADC ZP+1

 BCS PLC1               \ If the addition overflowed, jump down to PLC1 to skip
                        \ to the next pixel

 STA ZP+1               \ Set ZP(1 0) = (A ZP)
                        \             = r1^2 + r2^2

 LDA #1                 \ Set ZP(1 0) = &4001 - ZP(1 0) - (1 - C)
 SBC ZP                 \             = 128^2 - ZP(1 0)
 STA ZP                 \
                        \ (as the C flag is clear), first subtracting the low
                        \ bytes

 LDA #&40               \ And then subtracting the high bytes
 SBC ZP+1
 STA ZP+1

 BCC PLC1               \ If the subtraction underflowed, jump down to PLC1 to
                        \ skip to the next pixel

                        \ If we get here, then both calculations fitted into
                        \ 16 bits, and we have:
                        \
                        \   ZP(1 0) = 128^2 - (r1^2 + r2^2)
                        \
                        \ where ZP(1 0) >= 0

 JSR ROOT               \ Set ZP = SQRT(ZP(1 0))

 LDA ZP                 \ Set X = ZP >> 1
 LSR A                  \       = SQRT(128^2 - (a^2 + b^2)) / 2
 TAX

 LDA YY                 \ Set A = YY
                        \       = r2

 CMP #128               \ If YY >= 128, set the C flag (so the C flag is now set
                        \ to bit 7 of A)

 ROR A                  \ Rotate A and set the sign bit to the C flag, so bits
                        \ 6 and 7 are now the same, i.e. A is a random number in
                        \ one of these ranges:
                        \
                        \   %00000000 - %00111111  = 0 to 63    (r2 = 0 - 127)
                        \   %11000000 - %11111111  = 192 to 255 (r2 = 128 - 255)
                        \
                        \ The PIX routine flips bit 7 of A before drawing, and
                        \ that makes -A in these ranges:
                        \
                        \   %10000000 - %10111111  = 128-191
                        \   %01000000 - %01111111  = 64-127
                        \
                        \ so that's in the range 64 to 191

 JSR PIX                \ Draw a pixel at screen coordinate (X, -A), i.e. at
                        \
                        \   (ZP / 2, -A)
                        \
                        \ where ZP = SQRT(128^2 - (r1^2 + r2^2))
                        \
                        \ So this is the same as plotting at (x, y) where:
                        \
                        \   r1 = random number from 0 to 255
                        \   r1 = random number from 0 to 255
                        \   (r1^2 + r1^2) < 128^2
                        \
                        \   y = r2, squished into 64 to 191 by negation
                        \
                        \   x = SQRT(128^2 - (r1^2 + r1^2)) / 2
                        \
                        \ which is what we want

.PLC1

 DEC CNT                \ Decrement the counter in CNT (the low byte)

 BNE PLL1               \ Loop back to PLL1 until CNT = 0

 DEC CNT+1              \ Decrement the counter in CNT+1 (the high byte)

 BNE PLL1               \ Loop back to PLL1 until CNT+1 = 0

 LDX #&C2               \ Set the low byte of EXCN(1 0) to &C2, so we now have
 STX EXCN               \ EXCN(1 0) = &03C2, which we will use in the IRQ1
                        \ handler (this has nothing to do with drawing Saturn,
                        \ it's all part of the copy protection)

 LDX #&60               \ This is normally part of the copy protection, but it's
 STX &0087              \ been disabled in this unprotected version so this has
                        \ no effect (though the crackers presumably thought they
                        \ might as well still set the value just in case)

                        \ The following loop iterates CNT2(1 0) times, i.e. &1DD
                        \ or 477 times, and draws the background stars on the
                        \ loading screen

.PLL2

 JSR DORND              \ Set A and X to random numbers, say A = r3

 TAX                    \ Set X = A
                        \       = r3

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r3^2

 STA ZP+1               \ Set ZP+1 = A
                        \          = r3^2 / 256

 JSR DORND              \ Set A and X to random numbers, say A = r4

 STA YY                 \ Set YY = r4

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r4^2

 ADC ZP+1               \ Set A = A + r3^2 / 256
                        \       = r4^2 / 256 + r3^2 / 256
                        \       = (r3^2 + r4^2) / 256

 CMP #&11               \ If A < 17, jump down to PLC2 to skip to the next pixel
 BCC PLC2

 LDA YY                 \ Set A = r4

 JSR PIX                \ Draw a pixel at screen coordinate (X, -A), i.e. at
                        \ (r3, -r4), where (r3^2 + r4^2) / 256 >= 17
                        \
                        \ Negating a random number from 0 to 255 still gives a
                        \ random number from 0 to 255, so this is the same as
                        \ plotting at (x, y) where:
                        \
                        \   x = random number from 0 to 255
                        \   y = random number from 0 to 255
                        \   (x^2 + y^2) div 256 >= 17
                        \
                        \ which is what we want

.PLC2

 DEC CNT2               \ Decrement the counter in CNT2 (the low byte)

 BNE PLL2               \ Loop back to PLL2 until CNT2 = 0

 DEC CNT2+1             \ Decrement the counter in CNT2+1 (the high byte)

 BNE PLL2               \ Loop back to PLL2 until CNT2+1 = 0

 LDX #&CA               \ This is normally part of the copy protection, but it's
 NOP                    \ been disabled in this unprotected version so this has
 STX BLPTR              \ no effect (though the crackers presumably thought they
 LDX #&C6               \ might as well still set the values just in case)
 STX BLN

                        \ The following loop iterates CNT3(1 0) times, i.e. &500
                        \ or 1280 times, and draws the rings around the loading
                        \ screen's Saturn

.PLL3

 JSR DORND              \ Set A and X to random numbers, say A = r5

 STA ZP                 \ Set ZP = r5

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r5^2

 STA ZP+1               \ Set ZP+1 = A
                        \          = r5^2 / 256

 JSR DORND              \ Set A and X to random numbers, say A = r6

 STA YY                 \ Set YY = r6

 JSR SQUA2              \ Set (A P) = A * A
                        \           = r6^2

 STA T                  \ Set T = A
                        \       = r6^2 / 256

 ADC ZP+1               \ Set ZP+1 = A + r5^2 / 256
 STA ZP+1               \          = r6^2 / 256 + r5^2 / 256
                        \          = (r5^2 + r6^2) / 256

 LDA ZP                 \ Set A = ZP
                        \       = r5

 CMP #128               \ If A >= 128, set the C flag (so the C flag is now set
                        \ to bit 7 of ZP, i.e. bit 7 of A)

 ROR A                  \ Rotate A and set the sign bit to the C flag, so bits
                        \ 6 and 7 are now the same

 CMP #128               \ If A >= 128, set the C flag (so again, the C flag is
                        \ set to bit 7 of A)

 ROR A                  \ Rotate A and set the sign bit to the C flag, so bits
                        \ 5-7 are now the same, i.e. A is a random number in one
                        \ of these ranges:
                        \
                        \   %00000000 - %00011111  = 0-31
                        \   %11100000 - %11111111  = 224-255
                        \
                        \ In terms of signed 8-bit integers, this is a random
                        \ number from -32 to 31. Let's call it r7

 ADC YY                 \ Set X = A + YY
 TAX                    \       = r7 + r6

 JSR SQUA2              \ Set (A P) = r7 * r7

 TAY                    \ Set Y = A
                        \       = r7 * r7 / 256

 ADC ZP+1               \ Set A = A + ZP+1
                        \       = r7^2 / 256 + (r5^2 + r6^2) / 256
                        \       = (r5^2 + r6^2 + r7^2) / 256

 BCS PLC3               \ If the addition overflowed, jump down to PLC3 to skip
                        \ to the next pixel

 CMP #80                \ If A >= 80, jump down to PLC3 to skip to the next
 BCS PLC3               \ pixel

 CMP #32                \ If A < 32, jump down to PLC3 to skip to the next pixel
 BCC PLC3

 TYA                    \ Set A = Y + T
 ADC T                  \       = r7^2 / 256 + r6^2 / 256
                        \       = (r6^2 + r7^2) / 256

 CMP #16                \ If A > 16, skip to PL1 to plot the pixel
 BCS PL1

 LDA ZP                 \ If ZP is positive (50% chance), jump down to PLC3 to
 BPL PLC3               \ skip to the next pixel

.PL1

 LDA YY                 \ Set A = YY
                        \       = r6

 JSR PIX                \ Draw a pixel at screen coordinate (X, -A), where:
                        \
                        \   X = (random -32 to 31) + r6
                        \   A = r6
                        \
                        \ Negating a random number from 0 to 255 still gives a
                        \ random number from 0 to 255, so this is the same as
                        \ plotting at (x, y) where:
                        \
                        \   r5 = random number from 0 to 255
                        \   r6 = random number from 0 to 255
                        \   r7 = r5, squashed into -32 to 31
                        \
                        \   x = r5 + r7
                        \   y = r5
                        \
                        \   32 <= (r5^2 + r6^2 + r7^2) / 256 <= 79
                        \   Draw 50% fewer pixels when (r6^2 + r7^2) / 256 <= 16
                        \
                        \ which is what we want

.PLC3

 DEC CNT3               \ Decrement the counter in CNT3 (the low byte)

 BNE PLL3               \ Loop back to PLL3 until CNT3 = 0

 DEC CNT3+1             \ Decrement the counter in CNT3+1 (the high byte)

 BNE PLL3               \ Loop back to PLL3 until CNT3+1 = 0

\ ******************************************************************************
\
\       Name: DORND
\       Type: Subroutine
\   Category: Utility routines
\    Summary: Generate random numbers
\  Deep dive: Generating random numbers
\
\ ------------------------------------------------------------------------------
\
\ Set A and X to random numbers (though note that X is set to the random number
\ that was returned in A the last time DORND was called).
\
\ The C and V flags are also set randomly.
\
\ This is a simplified version of the DORND routine in the main game code. It
\ swaps the two calculations around and omits the ROL A instruction, but is
\ otherwise very similar. See the DORND routine in the main game code for more
\ details.
\
\ ******************************************************************************

.DORND

 LDA RAND+1             \ r1´ = r1 + r3 + C
 TAX                    \ r3´ = r1
 ADC RAND+3
 STA RAND+1
 STX RAND+3

 LDA RAND               \ X = r2´ = r0
 TAX                    \ A = r0´ = r0 + r2
 ADC RAND+2
 STA RAND
 STX RAND+2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: SQUA2
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (A P) = A * A
\
\ ------------------------------------------------------------------------------
\
\ Do the following multiplication of unsigned 8-bit numbers:
\
\   (A P) = A * A
\
\ This uses the same approach as routine SQUA2 in the main game code, which
\ itself uses the MU11 routine to do the multiplication. See those routines for
\ more details.
\
\ ******************************************************************************

.SQUA2

 BPL SQUA               \ If A > 0, jump to SQUA

 EOR #&FF               \ Otherwise we need to negate A for the SQUA algorithm
 CLC                    \ to work, so we do this using two's complement, by
 ADC #1                 \ setting A = ~A + 1

.SQUA

 STA Q                  \ Set Q = A and P = A

 STA P                  \ Set P = A

 LDA #0                 \ Set A = 0 so we can start building the answer in A

 LDY #8                 \ Set up a counter in Y to count the 8 bits in P

 LSR P                  \ Set P = P >> 1
                        \ and C flag = bit 0 of P

.SQL1

 BCC SQ1                \ If C (i.e. the next bit from P) is set, do the
 CLC                    \ addition for this bit of P:
 ADC Q                  \
                        \   A = A + Q

.SQ1

 ROR A                  \ Shift A right to catch the next digit of our result,
                        \ which the next ROR sticks into the left end of P while
                        \ also extracting the next bit of P

 ROR P                  \ Add the overspill from shifting A to the right onto
                        \ the start of P, and shift P right to fetch the next
                        \ bit for the calculation into the C flag

 DEY                    \ Decrement the loop counter

 BNE SQL1               \ Loop back for the next bit until P has been rotated
                        \ all the way

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: PIX
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a single pixel at a specific coordinate
\  Deep dive: Drawing pixels in the Electron version
\
\ ------------------------------------------------------------------------------
\
\ Draw a pixel at screen coordinate (X, -A). The sign bit of A gets flipped
\ before drawing, and then the routine uses the same approach as the PIXEL
\ routine in the main game code, except it plots a single pixel from TWOS
\ instead of a two pixel dash from TWOS2. This applies to the top part of the
\ screen (the space view).
\
\ See the PIXEL routine in the main game code for more details.
\
\ Arguments:
\
\   X                   The screen x-coordinate of the pixel to draw
\
\   A                   The screen y-coordinate of the pixel to draw, negated
\
\ Other entry points:
\
\   PIX-1               Contains an RTS
\
\ ******************************************************************************

.PIX

 LDY #128               \ Set ZP = 128 for use in the calculation below
 STY ZP

 TAY                    \ Copy A into Y, for use later

 EOR #%10000000         \ Flip the sign of A

 CMP #248               \ If the y-coordinate in A >= 248, then this is the
 BCS PIX-1              \ bottom row of the screen, which we want to leave blank
                        \ as it's below the bottom of the dashboard, so return
                        \ from the subroutine (as PIX-1 contains an RTS)

                        \ We now calculate the address of the character block
                        \ containing the pixel (x, y) and put it in ZP(1 0), as
                        \ follows:
                        \
                        \   ZP = &5800 + (y div 8 * 256) + (y div 8 * 64) + 32
                        \
                        \ See the deep dive on "Drawing pixels in the Electron
                        \ version" for details

 LSR A                  \ Set A = A >> 3
 LSR A                  \       = y div 8
 LSR A                  \       = character row number

                        \ Also, as ZP = 128, we have:
                        \
                        \   (A ZP) = (A 128)
                        \          = (A * 256) + 128
                        \          = 4 * ((A * 64) + 32)
                        \          = 4 * ((char row * 64) + 32)

 STA ZP+1               \ Set ZP+1 = A, so (ZP+1 0) = A * 256
                        \                           = char row * 256

 LSR A                  \ Set (A ZP) = (A ZP) / 4
 ROR ZP                 \            = (4 * ((char row * 64) + 32)) / 4
 LSR A                  \            = char row * 64 + 32
 ROR ZP

 ADC ZP+1               \ Set ZP(1 0) = (A ZP) + (ZP+1 0) + &5800
 ADC #&58               \             = (char row * 64 + 32)
 STA ZP+1               \               + char row * 256
                        \               + &5800
                        \
                        \ which is what we want, so ZP(1 0) contains the address
                        \ of the first visible pixel on the character row
                        \ containing the point (x, y)

 TXA                    \ To get the address of the character block on this row
 EOR #%10000000         \ that contains (x, y):
 AND #%11111000         \
 ADC ZP                 \   ZP(1 0) = ZP(1 0) + (X >> 3) * 8
 STA ZP

 BCC P%+4               \ If the addition of the low bytes overflowed, increment
 INC ZP+1               \ the high byte

                        \ So ZP(1 0) now contains the address of the first pixel
                        \ in the character block containing the (x, y), taking
                        \ the screen borders into consideration

 TYA                    \ Set Y = Y AND %111
 AND #%00000111
 TAY

 TXA                    \ Set X = X AND %111
 AND #%00000111
 TAX

 LDA TWOS,X             \ Fetch a pixel from TWOS and OR it into ZP+Y
 ORA (ZP),Y
 STA (ZP),Y

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TWOS
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made single-pixel character row bytes for mode 4
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting one-pixel points in mode 4 (the top part of the
\ split screen). See the PIX routine for details.
\
\ ******************************************************************************

.TWOS

 EQUB %10000000
 EQUB %01000000
 EQUB %00100000
 EQUB %00010000
 EQUB %00001000
 EQUB %00000100
 EQUB %00000010
 EQUB %00000001

\ ******************************************************************************
\
\       Name: CNT
\       Type: Variable
\   Category: Drawing planets
\    Summary: A counter for use in drawing Saturn's planetary body
\
\ ------------------------------------------------------------------------------
\
\ Defines the number of iterations of the PLL1 loop, which draws the planet part
\ of the loading screen's Saturn.
\
\ ******************************************************************************

.CNT

 EQUW &0500             \ The number of iterations of the PLL1 loop (1280)

\ ******************************************************************************
\
\       Name: CNT2
\       Type: Variable
\   Category: Drawing planets
\    Summary: A counter for use in drawing Saturn's background stars
\
\ ------------------------------------------------------------------------------
\
\ Defines the number of iterations of the PLL2 loop, which draws the background
\ stars on the loading screen.
\
\ ******************************************************************************

.CNT2

 EQUW &01DD             \ The number of iterations of the PLL2 loop (477)

\ ******************************************************************************
\
\       Name: CNT3
\       Type: Variable
\   Category: Drawing planets
\    Summary: A counter for use in drawing Saturn's rings
\
\ ------------------------------------------------------------------------------
\
\ Defines the number of iterations of the PLL3 loop, which draws the rings
\ around the loading screen's Saturn.
\
\ ******************************************************************************

.CNT3

 EQUW &0500             \ The number of iterations of the PLL3 loop (1280)

\ ******************************************************************************
\
\       Name: ROOT
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate ZP = SQRT(ZP(1 0))
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following square root:
\
\   ZP = SQRT(ZP(1 0))
\
\ This routine is identical to LL5 in the main game code - it even has the same
\ label names. The only difference is that LL5 calculates Q = SQRT(R Q), but
\ apart from the variables used, the instructions are identical, so see the LL5
\ routine in the main game code for more details on the algorithm used here.
\
\ ******************************************************************************

.ROOT

 LDY ZP+1               \ Set (Y Q) = ZP(1 0)
 LDA ZP
 STA Q

                        \ So now to calculate ZP = SQRT(Y Q)

 LDX #0                 \ Set X = 0, to hold the remainder

 STX ZP                 \ Set ZP = 0, to hold the result

 LDA #8                 \ Set P = 8, to use as a loop counter
 STA P

.LL6

 CPX ZP                 \ If X < ZP, jump to LL7
 BCC LL7

 BNE LL8                \ If X > ZP, jump to LL8

 CPY #64                \ If Y < 64, jump to LL7 with the C flag clear,
 BCC LL7                \ otherwise fall through into LL8 with the C flag set

.LL8

 TYA                    \ Set Y = Y - 64
 SBC #64                \
 TAY                    \ This subtraction will work as we know C is set from
                        \ the BCC above, and the result will not underflow as we
                        \ already checked that Y >= 64, so the C flag is also
                        \ set for the next subtraction

 TXA                    \ Set X = X - ZP
 SBC ZP
 TAX

.LL7

 ROL ZP                 \ Shift the result in Q to the left, shifting the C flag
                        \ into bit 0 and bit 7 into the C flag

 ASL Q                  \ Shift the dividend in (Y S) to the left, inserting
 TYA                    \ bit 7 from above into bit 0
 ROL A
 TAY

 TXA                    \ Shift the remainder in X to the left
 ROL A
 TAX

 ASL Q                  \ Shift the dividend in (Y S) to the left
 TYA
 ROL A
 TAY

 TXA                    \ Shift the remainder in X to the left
 ROL A
 TAX

 DEC P                  \ Decrement the loop counter

 BNE LL6                \ Loop back to LL6 until we have done 8 loops

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: crunchit
\       Type: Subroutine
\   Category: Copy protection
\    Summary: Multi-byte decryption and copying routine
\
\ ------------------------------------------------------------------------------
\
\ In the unprotected version of the loader on this site, this routine just moves
\ data frommone location to another. In the protected version, it also decrypts
\ the data as it is moved, but that part is disabled in the following.
\
\ Arguments:
\
\   (X Y)               The number of bytes to copy
\
\   ZP(1 0)             The source address
\
\   P(1 0)              The destination address
\
\ ******************************************************************************

.crunchit

 LDA (ZP),Y             \ Copy the Y-th byte of ZP(1 0) to the Y-th byte of
 NOP                    \ P(1 0), without any decryption (hence the NOPs)
 NOP
 NOP
 STA (P),Y

 DEY                    \ Decrement the byte counter

 BNE crunchit           \ Loop back to crunchit to copy the next byte until we
                        \ have done a whole page

 INC P+1                \ Increment the high bytes of the source and destination
 INC ZP+1               \ addresses so we can copy the next page

 DEX                    \ Decrement the page counter

 BNE crunchit           \ Loop back to crunchit to copy the next page until we
                        \ have done X pages

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: BEGIN%
\       Type: Subroutine
\   Category: Copy protection
\    Summary: Single-byte decryption and copying routine, run on the stack
\
\ ------------------------------------------------------------------------------
\
\ This code is not run in the unprotected version of the loader. In the full
\ version it is stored with the instructions reversed so it can be copied onto
\ the stack to be run, and it doesn't contain any NOPs, so this is presumably a
\ remnant of the cracking process.
\
\ ******************************************************************************

 PLA
 PLA
 LDA &0C24,Y
 PHA
 EOR &0B3D,Y
 NOP
 NOP
 NOP
 JMP (David9)

\ ******************************************************************************
\
\       Name: UU%
\       Type: Workspace
\    Address: &0B00
\   Category: Workspaces
\    Summary: Marker for a block that is moved as part of the obfuscation
\
\ ------------------------------------------------------------------------------
\
\ The code from here to the end of the file gets copied to &0B00 (LE%) by part
\ 3. It is called from part 4.
\
\ ******************************************************************************

.UU%

Q% = P% - LE%

ORG LE%

\ ******************************************************************************
\
\       Name: Elite loader (Part 5 of 5)
\       Type: Subroutine
\   Category: Loader
\    Summary: Set up interrupt vectors, calculate checksums, run main game code
\
\ ------------------------------------------------------------------------------
\
\ This is the final part of the loader. It sets up some of the main game's
\ interrupt vectors and calculates various checksums, before finally handing
\ over to the main game.
\
\ ******************************************************************************

 EQUD &10101010         \ This data appears to be unused
 EQUD &10101010
 EQUD &10101010
 EQUD &10101010
 EQUB &10

.ENTRY2

 LDX #LO(MESS1)         \ Set (Y X) to point to MESS1 ("LOAD EliteCo FFFF2000")
 LDY #HI(MESS1)

 JSR OSCLI              \ Call OSCLI to run the OS command in MESS1, which loads
                        \ the maon game code at location &2000

 LDA #3                 \ Directly update &0258, the memory location associated
 STA &0258              \ with OSBYTE 200, so this is the same as calling OSBYTE
                        \ with A = 200, X = 3 and Y = 0 to disable the ESCAPE
                        \ key and clear memory if the BREAK key is pressed

 LDA #140               \ Call OSBYTE with A = 140 and X = 12 to select the
 LDX #12                \ tape filing system (i.e. do a *TAPE command)
 LDY #0
 JSR OSBYTE

 LDA #143               \ Call OSBYTE 143 to issue a paged ROM service call of
 LDX #&C                \ type &C with argument &FF, which is the "NMI claim"
 LDY #&FF               \ service call that asks the current user of the NMI
 JSR OSBYTE             \ space to clear it out

 LDA #&40               \ Set S% to an RTI instruction (opcode &40), so we can
 STA S%                 \ claim the NMI workspace at &0D00 (the RTI makes sure
                        \ we return from any spurious NMIs that still call this
                        \ workspace)

 LDX #&4A               \ Set X = &4A, as we want to copy the &4A pages of main
                        \ game code from where we just loaded it at &2000, down
                        \ to &0D00 where we will run it

 LDY #0                 \ Set the source and destination addresses for the copy:
 STY ZP                 \
 STY P                  \   ZP(1 0) = L% = &2000
 LDA #HI(L%)            \   P(1 0) = C% = &0D00
 STA ZP+1               \
 LDA #HI(C%)            \ and set Y = 0 to act as a byte counter in the
 STA P+1                \ following loop

.MVDL

 LDA (ZP),Y             \ Copy the Y-th byte from the source to the Y-th byte of
 STA (P),Y              \ the destination

 LDA #0                 \ Zero the source byte we just copied, so that this loop
 STA (ZP),Y             \ moves the memory block rather than copying it

 INY                    \ Increment the byte counter

 BNE MVDL               \ Loop back until we have copied a whole page of bytes

 INC ZP+1               \ Increment the high bytes of ZP(1 0) and P(1 0) so we
 INC P+1                \ copy bytes from the next page in memory

 DEX                    \ Decrement the page counter in X

 BPL MVDL               \ Loop back to move the next page of bytes until we have
                        \ moved the number of pages in X (this also sets X to
                        \ &FF)

 SEI                    \ Disable all interrupts

 TXS                    \ Set the stack pointer to &01FF, which is the standard
                        \ location for the 6502 stack, so this instruction
                        \ effectively resets the stack

 LDA RDCHV              \ Set the user vector USERV to the same value as the
 STA USERV              \ read character vector RDCHV
 LDA RDCHV+1
 STA USERV+1

 LDA KEYV               \ Store the current value of the keyboard vector KEYV
 STA S%+4               \ in S%+4
 LDA KEYV+1
 STA S%+5

 LDA #LO(S%+16)         \ Point the keyboard vector KEYV to S%+16 in the main
 STA KEYV               \ game code
 LDA #HI(S%+16)
 STA KEYV+1

 LDA S%+14              \ Point the break vector BRKV to the address stored in
 STA BRKV               \ S%+14 in the main game code
 LDA S%+15
 STA BRKV+1

 LDA S%+10              \ Point the write character vector WRCHV to the address
 STA WRCHV              \ stored in S%+10 in the main game code
 LDA S%+11
 STA WRCHV+1

 LDA IRQ1V              \ Store the current value of the interrupt vector IRQ1V
 STA S%+2               \ in S%+2
 LDA IRQ1V+1
 STA S%+3

 LDA S%+12              \ Point the interrupt vector IRQ1V to the address stored
 STA IRQ1V              \ in S%+12 in the main game code
 LDA S%+13
 STA IRQ1V+1

 LDA #%11111100         \ Clear all interrupts (bits 4-7) and de-select the
 JSR VIA05              \ BASIC ROM (bit 3) by setting the interrupt clear and
                        \ paging register at SHEILA &05

 LDA #%00001000         \ Select ROM 8 (the keyboard) by setting the interrupt
 JSR VIA05              \ clear and paging register at SHEILA &05

 LDA #&60               \ Set the screen start address registers at SHEILA &02
 STA VIA+&02            \ and SHEILA &03 so screen memory starts at &7EC0. This
 LDA #&3F               \ gives us a blank line at the top of the screen (for
 STA VIA+&03            \ the screen memory between &7EC0 and &7FFF, as one row
                        \ of mode 4 is &140 bytes), and then the rest of the
                        \ screen memory from &5800 to &7EBF cover the second
                        \ row and down

 CLI                    \ Re-enable interrupts

 JMP (S%+8)             \ Jump to the address in S%+8 in the main game code,
                        \ which points to TT170, so this starts the game

.VIA05

 STA &00F4              \ Store A in &00F4

 STA VIA+&05            \ Set the value of the interrupt clear and paging
                        \ register at SHEILA &05 to A

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MESS1
\       Type: Variable
\   Category: Utility routines
\    Summary: Contains an OS command string for loading the main game code
\
\ ******************************************************************************

.MESS1

 EQUS "LOAD EliteCo FFFF2000"
 EQUB 13

 SKIP 13                \ These bytes appear to be unused

\ ******************************************************************************
\
\ Save ELITE.unprot.bin
\
\ ******************************************************************************

COPYBLOCK LE%, P%, UU%  \ Copy the block that we assembled at LE% to UU%, which
                        \ is where it will actually run

PRINT "S.ELITEDA ", ~CODE%, " ", ~UU% + (P% - LE%), " ", ~run, " ", ~CODE%
SAVE "3-assembled-output/ELITEDA.bin", CODE%, UU% + (P% - LE%), run, CODE%
