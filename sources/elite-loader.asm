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
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * output/ELITEDA.bin
\
\ ******************************************************************************

INCLUDE "sources/elite-header.h.asm"

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

N% = 17                 \ N% is set to the number of bytes in the VDU table, so
                        \ we can loop through them in part 2 below

LEN = 506

CODE% = &4400
LOAD% = &4400

USERV = &0200           \ The address for the user vector
BRKV = &0202            \ The address for the break vector
IRQ1V = &0204           \ The address for the interrupt vector
WRCHV = &020E           \ The address for the write character vector
RDCHV = &0210           \ The address for the read character vector
KEYV = &0228            \ The address for the keyboard vector

OSWRCH = &FFEE          \ The address for the OSWRCH routine
OSBYTE = &FFF4          \ The address for the OSBYTE routine
OSWORD = &FFF1          \ The address for the OSWORD routine
OSCLI = &FFF7           \ The address for the OSCLI routine

VIA = &FE00             \ Memory-mapped space for accessing internal hardware,
                        \ such as the video ULA, 6845 CRTC and 6522 VIAs (also
                        \ known as SHEILA)

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

 SKIP 2                 \ TRTB%(1 0) points to the keyboard translation table,
                        \ which is used to translate internal key numbers to
                        \ ASCII

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
                        \ monochrome pixels in mode 4" and "Drawing colour
                        \ pixels in mode 5" for more details)

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

.L0087

 SKIP 1                 \ ???

.L0088

 SKIP 1                 \ ???

\ ******************************************************************************
\
\ ELITE LOADER
\
\ ******************************************************************************

\ ******************************************************************************
\
\       Name: Elite loader (Part 1 of ???)
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
\     row of the monochrome mode 4 screen
\
\   * P.ELITE.bin contains the "ELITE" title across the top of the loading
\     screen, which gets moved to screen address &5B00, on the fourth character
\     row of the monochrome mode 4 screen
\
\   * P.(C)ASFT.bin contains the "(C) Acornsoft 1984" title across the bottom
\     of the loading screen, which gets moved to screen address &73A0, the
\     penultimate character row of the monochrome mode 4 screen, just above the
\     dashboard
\
\   * P.DIALS.bin contains the dashboard, which gets moved to screen address
\     &7620, which is the starting point of the dashboard at the bottom of the
\     monochrome mode 4 screen
\
\ The routine ends with a jump to the start of the loader code at ENTRY.
\
\ ******************************************************************************

ORG CODE%

PRINT "WORDS9 = ",~P%
INCBIN "output/WORDS9.bin"

ALIGN 256

PRINT "P.DIALS = ",~P%
INCBIN "binaries/P.DIALS.bin"

PRINT "P.ELITE = ",~P%
INCBIN "binaries/P.ELITE.bin"

PRINT "P.A-SOFT = ",~P%
INCBIN "binaries/P.A-SOFT.bin"

PRINT "P.(C)ASFT = ",~P%
INCBIN "binaries/P.(C)ASFT.bin"

.run

 JMP ENTRY              \ Jump to ENTRY to start the loading process

\ ******************************************************************************
\
\       Name: B%
\       Type: Variable
\   Category: Screen mode
\    Summary: VDU commands for setting the square mode 4 screen
\  Deep dive: The split-screen mode
\             Drawing monochrome pixels in mode 4
\
\ ------------------------------------------------------------------------------
\
\ This block contains the bytes that get written by OSWRCH to set up the screen
\ mode (this is equivalent to using the VDU statement in BASIC).
\
\ It defines the whole screen using a square, monochrome mode 4 configuration;
\ the mode 5 part for the dashboard is implemented in the IRQ1 routine.
\
\ The top part of Elite's screen mode is based on mode 4 but with the following
\ differences:
\
\   * 32 columns, 31 rows (256 x 248 pixels) rather than 40, 32
\
\   * The horizontal sync position is at character 45 rather than 49, which
\     pushes the screen to the right (which centres it as it's not as wide as
\     the normal screen modes)
\
\   * Screen memory goes from &6000 to &7EFF, which leaves another whole page
\     for code (i.e. 256 bytes) after the end of the screen. This is where the
\     Python ship blueprint slots in
\
\   * The text window is 1 row high and 13 columns wide, and is at (2, 16)
\
\   * The cursor is disabled
\
\ This almost-square mode 4 variant makes life a lot easier when drawing to the
\ screen, as there are 256 pixels on each row (or, to put it in screen memory
\ terms, there's one page of memory per row of pixels). For more details of the
\ screen mode, see the deep dive on "Drawing monochrome pixels in mode 4".
\
\ There is also an interrupt-driven routine that switches the bytes-per-pixel
\ setting from that of mode 4 to that of mode 5, when the raster reaches the
\ split between the space view and the dashboard. See the deep dive on "The
\ split-screen mode" for details.
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
\ FNE macro to create the four sound envelopes used in-game. Refer to chapter 30
\ of the BBC Micro User Guide for details of sound envelopes and what all the
\ parameters mean.
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

 EQUW &5456             \ ???

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

 EQUW (512-LEN)         \ The address of LEN bytes before the start of the stack

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

 CMP swine-5,X          \ ???

 LDY #&18
 STY V219+1,X           \ Set the low byte of V219(1 0) to &18 (as X = 255), so
                        \ V219(1 0) now contains &0218

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
\       Name: Elite loader (Part 2 of ???)
\       Type: Subroutine
\   Category: Loader
\    Summary: ???
\
\ ------------------------------------------------------------------------------
\
\ 4 pages from &4400-&47FF to &0400-&07FF - Text Tokens
\ 1 page from &4F00 to &5B00  - ELITE
\ 1 page from &5000 to &5960  - Acornsoft presents on row 2
\ 1 page from &5100 to &73A0  - (C) Acornsoft 1984
\ Saturn
\ Loop - Dashboard:
\     1 page from &4800 to &7620           = &7620
\     1 page from &4900 to &7720 + &40     = &7760
\     1 page from &4A00 to &7820 + 2 * &40 = &78A0
\     1 page from &4B00 to &7920 + 3 * &40 = &79E0
\     1 page from &4C00 to &7A20 + 4 * &40 = &7B20
\     1 page from &4D00 to &7B20 + 5 * &40 = &7C60
\     1 page from &4E00 to &7C20 + 6 * &40 = &7DA0
\ Standard mode 4 with &20 margin on each side, &5800 to &7FFF
\ Bottom row not used by dashboard, &7EC0 to &7FFF
\ 1 page from &5615 to &0B00
\
\ JMP &0B10 to load game at &2000 and move down to &0D00
\
\ JSR &0BC2 later, too
\
\ Then JMP (&0D08) starts game
\ &0D08 is in main game code so this jumps to &3FB6, DEATH2+2
\
\ ******************************************************************************

.ENTRY

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
 NOP
 NOP
 LDA #&60
 STA L0088
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

 LDA #&20               \ Set A to the op code for a JSR call with absolute
                        \ addressing

 NOP

.Ian1

 NOP
 NOP
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
                        \ &2C &D0 &A1, or BIT &A1D0, which does nothing apart
                        \ from affect the flags ???

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

 LDA #13                \ Call OSBYTE with A = 13, X = 2 and Y = 0 to disable
 LDX #2                 \ the "character entering keyboard buffer" event
 JSR OSB

.OS01

 LDX #&FF               \ Set the stack pointer to &01FF, which is the standard
 TXS                    \ location for the 6502 stack, so this instruction
                        \ effectively resets the stack

 INX                    \ Set X = 0, to use as a counter in the following loop
 
 LDY #0

.David3

 LDA crunchit,Y

.PROT1

 STA TRTB%+2,X
 INX
 INY
 CPY #&21
 BNE David3

 LDA #&03
 STA ZP
 LDA #&95
 BIT PROT1
 LDA #&52
 STA ZP+1
 LDY #&00

.LOOP

 LDA (ZP),Y             \ Pass the Y-th byte of the B% table to OSWRCH
 JSR OSWRCH

 INY                    \ Increment the loop counter

 CPY #N%                \ Loop back for the next byte until we have done them
 BNE LOOP               \ all (the number of bytes was set in N% above)

 LDA #1
 TAX
 TAY
 LDA abrk+1
 CMP (V219),Y

 LDA #4                 \ Call OSBYTE with A = 4, X = 1 and Y = 0 to disable
 JSR OSB                \ cursor editing, so the cursor keys return ASCII values
                        \ and can therefore be used in-game

 LDA #9                 \ Call OSBYTE with A = 9, X = 0 and Y = 0 to disable
 LDX #0                 \ flashing colours
 JSR OSB

 LDA #&6C
 NOP
 NOP
 NOP
 BIT L544F

 FNE 0                  \ Set up sound envelopes 0-3 using the FNE macro
 FNE 1
 FNE 2
 FNE 3

 LDX #&04
 STX Q
 LDA #&44
 STA ZP+1
 LDY #&00
 LDA #&18
 CMP (SC,X)
 STY ZP
 STY P
 JSR crunchit

 LDX #&01
 LDA #&4F
 STA ZP+1
 LDA #&5B
 STA Q
 LDA #&E0
 STA P
 LDY #&00
 JSR crunchit

 LDX #&01
 LDA #&50
 STA ZP+1
 LDA #&59
 STA Q
 LDA #&60
 STA P
 LDY #&00
 JSR crunchit

 LDX #&01
 LDA #&51
 STA ZP+1
 LDA #&73
 STA Q
 LDA #&A0
 STA P
 LDY #&00
 JSR crunchit

 JSR PLL1

 LDA #&48
 STA ZP+1
 LDA #&76
 STA Q
 LDY #&00
 STY ZP
 LDX #&20
 STY BLCNT
 STX P

.L540B

 LDX #&01
 JSR crunchit

 CLC
 LDA P
 ADC #&40
 STA P
 LDA Q
 ADC #&00
 STA Q
 CMP #&7E
 BCC L540B

 LDX #&01
 LDA #&56
 STA ZP+1
 LDA #&15
 STA ZP
 LDA #&0B
 STA Q
 LDY #&00
 STY P
 JSR crunchit

 JMP &0B11

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

.L544F

 NOP
 NOP
 NOP

.RAND

 EQUD &6C785349         \ The random number seed used for drawing Saturn

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

.PLL1

 JSR DORND

 JSR SQUA2

 STA ZP+1
 LDA P
 STA ZP
 JSR DORND

 STA YY
 JSR SQUA2

 TAX
 LDA P
 ADC ZP
 STA ZP
 TXA
 ADC ZP+1
 BCS PLC1

 STA ZP+1
 LDA #&01
 SBC ZP
 STA ZP
 LDA #&40
 SBC ZP+1
 STA ZP+1
 BCC PLC1

 JSR ROOT

 LDA ZP
 LSR A
 TAX
 LDA YY
 CMP #&80
 ROR A
 JSR PIX

.PLC1

 DEC CNT
 BNE PLL1

 DEC L55B8
 BNE PLL1

 LDX #&C2
 STX EXCN
 LDX #&60
 STX L0087

.PLL2

 JSR DORND

 TAX
 JSR SQUA2

 STA ZP+1
 JSR DORND

 STA YY
 JSR SQUA2

 ADC ZP+1
 CMP #&11
 BCC PLC2

 LDA YY
 JSR PIX

.PLC2

 DEC CNT2
 BNE PLL2

 DEC L55BA
 BNE PLL2

 LDX #&CA
 NOP
 STX BLPTR
 LDX #&C6
 STX BLN

.PLL3

 JSR DORND

 STA ZP
 JSR SQUA2

 STA ZP+1
 JSR DORND

 STA YY
 JSR SQUA2

 STA T
 ADC ZP+1
 STA ZP+1
 LDA ZP
 CMP #&80
 ROR A
 CMP #&80
 ROR A
 ADC YY
 TAX
 JSR SQUA2

 TAY
 ADC ZP+1
 BCS PLC3

 CMP #&50
 BCS PLC3

 CMP #&20
 BCC PLC3

 TYA
 ADC T
 CMP #&10
 BCS PL1

 LDA ZP
 BPL PLC3

.PL1

 LDA YY
 JSR PIX

.PLC3

 DEC CNT3
 BNE PLL3

 DEC L55BC
 BNE PLL3

.DORND

 LDA RAND+1
 TAX
 ADC RAND+3
 STA RAND+1
 STX RAND+3
 LDA RAND
 TAX
 ADC RAND+2
 STA RAND
 STX RAND+2
 RTS

.SQUA2

 BPL SQUA

 EOR #&FF
 CLC
 ADC #&01

.SQUA

 STA Q
 STA P
 LDA #&00
 LDY #&08
 LSR P

.SQL1

 BCC SQ1

 CLC
 ADC Q

.SQ1

 ROR A
 ROR P
 DEY
 BNE SQL1

.L5575

 RTS

.PIX

 LDY #&80
 STY ZP
 TAY
 EOR #&80
 CMP #&F8
 BCS L5575

 LSR A
 LSR A
 LSR A
 STA ZP+1
 LSR A
 ROR ZP
 LSR A
 ROR ZP
 ADC ZP+1
 ADC #&58
 STA ZP+1
 TXA
 EOR #&80
 AND #&F8
 ADC ZP
 STA ZP
 BCC L559F

 INC ZP+1

.L559F

 TYA
 AND #&07
 TAY
 TXA
 AND #&07
 TAX
 LDA L55AF,X
 ORA (ZP),Y
 STA (ZP),Y
 RTS

.L55AF

 EQUB &80

 EQUB &40, &20, &10, &08, &04, &02, &01

.CNT

 EQUB &00

.L55B8

 EQUB &05

.CNT2

 EQUB &DD

.L55BA

 EQUB &01

.CNT3

 EQUB &00

.L55BC

 EQUB &05

.ROOT

 LDY ZP+1
 LDA ZP
 STA Q
 LDX #&00
 STX ZP
 LDA #&08

.L55C9

 STA P

.LL6

 CPX ZP
 BCC LL7

 BNE LL8

 CPY #&40
 BCC LL7

.LL8

 TYA
 SBC #&40
 TAY
 TXA
 SBC ZP
 TAX

.LL7

 ROL ZP
 ASL Q
 TYA
 ROL A
 TAY
 TXA
 ROL A
 TAX
 ASL Q
 TYA
 ROL A
 TAY
 TXA
 ROL A
 TAX
 DEC P
 BNE LL6

 RTS

.crunchit

 LDA (ZP),Y
 NOP
 NOP
 NOP
 STA (P),Y
 DEY
 BNE crunchit

 INC Q
 INC ZP+1
 DEX
 BNE crunchit

 RTS

 PLA
 PLA
 LDA &0C24,Y
 PHA
 EOR &0B3D,Y
 NOP
 NOP
 NOP
 JMP (David9)

.LOADcode

 org &0B00

.LOAD

 EQUB &10, &10, &10, &10, &10, &10, &10, &10
 EQUB &10, &10, &10, &10, &10, &10, &10, &10

.L0B10

 BPL &0AB4

 INY
 LDY #&0B
 JSR OSCLI

 LDA #&03
 STA &0258
 LDA #&8C
 LDX #&0C
 LDY #&00
 JSR OSBYTE

 LDA #&8F
 LDX #&0C
 LDY #&FF
 JSR OSBYTE

 LDA #&40
 STA &0D00
 LDX #&4A
 LDY #&00
 STY ZP
 STY P
 LDA #&20
 STA ZP+1
 LDA #&0D
 STA P+1

.L0B44

 LDA (ZP),Y
 STA (P),Y
 LDA #&00
 STA (ZP),Y
 INY
 BNE L0B44

 INC ZP+1
 INC P+1
 DEX
 BPL L0B44

 SEI
 TXS
 LDA RDCHV
 STA USERV
 LDA RDCHV+1
 STA USERV+1
 LDA KEYV
 STA &0D04
 LDA KEYV+1
 STA &0D05
 LDA #&10
 STA KEYV
 LDA #&0D
 STA KEYV+1
 LDA &0D0E
 STA BRKV
 LDA &0D0F
 STA BRKV+1
 LDA &0D0A
 STA WRCHV
 LDA &0D0B
 STA WRCHV+1
 LDA IRQ1V
 STA &0D02
 LDA IRQ1V+1
 STA &0D03
 LDA &0D0C
 STA IRQ1V
 LDA &0D0D
 STA IRQ1V+1
 LDA #&FC
 JSR L0BC2

 LDA #&08
 JSR L0BC2

 LDA #&60
 STA VIA+&02
 LDA #&3F
 STA VIA+&03
 CLI
 JMP (&0D08)

.L0BC2

 STA &00F4
 STA VIA+&05
 RTS

 EQUS "LOAD EliteCo FFFF2000"

 EQUB &0D, &00, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00

COPYBLOCK LOAD, P%, LOADcode

ORG LOADcode + P% - LOAD

PRINT "S.ELITEDA ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/ELITEDA.bin", CODE%, P%, LOAD%
