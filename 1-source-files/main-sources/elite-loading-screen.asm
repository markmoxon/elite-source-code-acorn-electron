\ ******************************************************************************
\
\ ACORN ELECTRON ELITE LOADING SCREEN SOURCE
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
\ This source file contains the loading screen for Acorn Electron Elite.
\
\ ------------------------------------------------------------------------------
\
\ This source file produces the following binary file:
\
\   * SCREEN.bin
\
\ ******************************************************************************

 INCLUDE "1-source-files/main-sources/elite-build-options.asm"

 _IB_SUPERIOR           = (_VARIANT = 1)
 _IB_ACORNSOFT          = (_VARIANT = 2)

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

 CODE% = &1000          \ The address where the code will be run (the code is
                        \ relocatable so this address doesn't have any effect)

 LOAD% = &1000          \ The address where the code will be loaded (the code is
                        \ relocatable so this address doesn't have any effect)

 OSNEWL = &FFE7         \ The address for the OSNEWL routine

 OSWRCH = &FFEE         \ The address for the OSWRCH routine

 OSBYTE = &FFF4         \ The address for the OSBYTE routine

\ ******************************************************************************
\
\       Name: ZP
\       Type: Workspace
\    Address: &0004 to &0005 and &0070 to &0082
\   Category: Workspaces
\    Summary: Important variables used by the loader
\
\ ******************************************************************************

 ORG &0004              \ Set the assembly address to &0004

.TRTB%

 SKIP 2                 \ Contains the address of the keyboard translation
                        \ table, which is used to translate internal key
                        \ numbers to ASCII

 ORG &0070              \ Set the assembly address to &0070

.S

 SKIP 1                 \ Temporary storage, used in a number of places

.ZP

 SKIP 2                 \ Stores addresses used for moving content around

.P

 SKIP 1                 \ Temporary storage, used in a number of places

.Q

 SKIP 1                 \ Temporary storage, used in a number of places

.R

 SKIP 1                 \ Temporary storage, used in a number of places

.T

 SKIP 1                 \ Temporary storage, used in a number of places

 ORG &0081              \ Set the assembly address to &0081

.SC

 SKIP 1                 \ Screen address (low byte)
                        \
                        \ Elite draws on-screen by poking bytes directly into
                        \ screen memory, and SC(1 0) is typically set to the
                        \ address of the character block containing the pixel
                        \ we want to draw

.SCH

 SKIP 1                 \ Screen address (high byte)

\ ******************************************************************************
\
\ ELITE LOADING SCREEN
\
\ ******************************************************************************

 ORG CODE%              \ Set the assembly address to CODE%

\ ******************************************************************************
\
\       Name: ECHAR
\       Type: Variable
\   Category: Loader
\    Summary: Character definitions for the Electron to mimic the graphics
\             characters of the BBC Micro's mode 7 teletext screen
\
\ ******************************************************************************

.ECHAR

 EQUB &00, &00, &00, &00, &00, &00, &00, &00
 EQUB &E0, &E0, &00, &00, &00, &00, &00, &00
 EQUB &0E, &0E, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &0E, &0E
 EQUB &E0, &E0, &00, &E0, &E0, &00, &00, &00
 EQUB &EE, &EE, &00, &E0, &E0, &00, &00, &00
 EQUB &EE, &EE, &00, &0E, &0E, &00, &00, &00
 EQUB &00, &00, &00, &00, &00, &00, &E0, &E0
 EQUB &E0, &E0, &00, &00, &00, &00, &E0, &E0
 EQUB &00, &00, &00, &E0, &E0, &00, &E0, &E0
 EQUB &E0, &E0, &00, &E0, &E0, &00, &E0, &E0
 EQUB &EE, &EE, &00, &E0, &E0, &00, &E0, &E0
 EQUB &EE, &EE, &00, &EE, &EE, &00, &E0, &E0
 EQUB &EE, &EE, &00, &00, &00, &00, &00, &00
 EQUB &00, &00, &00, &0E, &0E, &00, &0E, &0E
 EQUB &0E, &0E, &00, &0E, &0E, &00, &0E, &0E
 EQUB &EE, &EE, &00, &0E, &0E, &00, &0E, &0E
 EQUB &EE, &EE, &00, &EE, &EE, &00, &0E, &0E
 EQUB &00, &00, &00, &00, &00, &00, &EE, &EE
 EQUB &EE, &EE, &00, &00, &00, &00, &EE, &EE
 EQUB &00, &00, &00, &E0, &E0, &00, &EE, &EE
 EQUB &E0, &E0, &00, &E0, &E0, &00, &EE, &EE
 EQUB &00, &00, &00, &0E, &0E, &00, &EE, &EE
 EQUB &0E, &0E, &00, &0E, &0E, &00, &EE, &EE
 EQUB &00, &00, &00, &EE, &EE, &00, &EE, &EE
 EQUB &E0, &E0, &00, &EE, &EE, &00, &EE, &EE
 EQUB &0E, &0E, &00, &EE, &EE, &00, &EE, &EE
 EQUB &EE, &EE, &00, &EE, &EE, &00, &EE, &EE

\ ******************************************************************************
\
\       Name: LOGO
\       Type: Variable
\   Category: Loader
\    Summary: Tables containing the Acornsoft logo for the BBC Micro and Acorn
\             Electron
\
\ ******************************************************************************

.LOGO

 EQUB &A0, &A1          \ For the BBC Micro, the tables below consist of offsets
 EQUB &A2, &E0          \ into this top table, so the first three characters of
 EQUB &A5, &A7          \ the Acornsoft logo are &A0 (the &00-th entry in this
 EQUB &AB, &B0          \ table), then &FC (the &18-th entry in this table),
 EQUB &B1, &B4          \ then &B4 (the &09-th entry in this table) and so on
 EQUB &B5, &B7          \
 EQUB &BF, &A3          \ The Electron ignores this top table and just uses the
 EQUB &E8, &EA          \ values below, adding &E0 to get the number of the
 EQUB &EB, &EF          \ relevant user-defined character (so the first three
 EQUB &F0, &F3          \ characters are &E0, then &F8, then &E9 and so on)
 EQUB &F4, &F5          \
 EQUB &F8, &FA          \ The Acornsoft logo is made up of 5 rows with 38
 EQUB &FC, &FD          \ graphics characters on each row, which corresponds
 EQUB &FE, &FF          \ with the tables below

 EQUB &00, &00, &00, &18, &09, &03, &18, &18
 EQUB &07, &00, &16, &18, &14, &00, &18, &18
 EQUB &18, &07, &0E, &14, &00, &0E, &09, &16
 EQUB &18, &18, &07, &00, &1A, &1B, &09, &00
 EQUB &18, &18, &18, &18, &18, &18

 EQUB &00, &00, &17, &1B, &0A, &1B, &05, &06
 EQUB &1B, &0F, &0C, &0D, &11, &0A, &1B, &0D
 EQUB &10, &0A, &0F, &1B, &09, &0F, &0A, &1B
 EQUB &08, &06, &04, &0F, &1B, &1B, &1B, &00
 EQUB &1B, &0D, &0D, &0D, &1B, &0D

 EQUB &00, &0E, &0C, &10, &0A, &1B, &00, &00
 EQUB &00, &0F, &0A, &00, &0F, &0A, &1B, &18
 EQUB &1A, &04, &0F, &0C, &1B, &17, &0A, &06
 EQUB &1B, &19, &07, &1B, &1B, &1B, &1B, &0A
 EQUB &1B, &1B, &1B, &00, &1B, &00

 EQUB &03, &1B, &19, &1A, &0A, &1B, &07, &03
 EQUB &18, &0F, &15, &00, &17, &0A, &1B, &06
 EQUB &19, &00, &0F, &0A, &10, &1B, &0A, &12
 EQUB &00, &10, &1B, &13, &13, &13, &13, &08
 EQUB &1B, &00, &00, &00, &1B, &00

 EQUB &1A, &0B, &00, &0F, &0A, &06, &1B, &1B
 EQUB &05, &02, &11, &1B, &0C, &01, &1B, &00
 EQUB &10, &15, &0F, &0A, &00, &11, &0A, &11
 EQUB &1B, &1B, &04, &11, &1B, &1B, &1B, &04
 EQUB &1B, &00, &00, &00, &1B, &00

 SKIP 28                \ These bytes appear to be unused
 EQUB &02, &0D
 SKIP 8

\ ******************************************************************************
\
\       Name: PROT1
\       Type: Subroutine
\   Category: Loader
\    Summary: Modify the LOADSCR routine with correct JSR address operands so
\             the code will run irrespective of the address it loads at
\
\ ******************************************************************************

.PROT1

 LDA #&68               \ Poke the following routine into &0100 to &0108:
 STA &0100              \
 STA &0103              \   0100 : &68            PLA
 LDA #&85               \   0101 : &85 &71        STA ZP
 STA &0101              \   0103 : &68            PLA
 STA &0104              \   0104 : &85 &72        STA ZP+1
 LDX #&71               \   0106 : &6C &71 &00    JMP (ZP)
 STX &0107              \
 STX &0102              \ This routine pulls an address off the stack into a
 INX                    \ location in zero page, and then jumps to that address
 STX &0105
 LDA #&6C
 STA &0106
 LDA #&00
 STA &0108

.do

 JSR &0100              \ Call the subroutine at &0100, which does the
 EQUB 0                 \ following:
                        \
                        \   * The JSR puts the address of the last byte of the
                        \     JSR instruction on the stack (i.e. the address of
                        \     the &01), pushing the high byte first
                        \
                        \   * It then jumps to &0100, which pulls the address
                        \     off the stack and puts it in ZP(1 0)
                        \
                        \   * The final instruction of the routine at &0100
                        \     jumps to the address in ZP(1 0), i.e. it jumps to
                        \     the &01 of the JSR instruction. The &01 byte is
                        \     followed by a &00 byte, and &01 &00 is the opcode
                        \     for ORA (&00,X), which doesn't do anything apart
                        \     from affect the value of the accumulator
                        \
                        \ In other words, this whole routine is a complicated
                        \ way of pointing ZP(1 0) to the &01 byte in the JSR
                        \ instruction above, i.e. to do + 2
                        \
                        \ We can then use ZP(1 0) to convert the addresses in
                        \ LOADSCR from being relative to PROT1 to absolute
                        \ addresses, which lets the code run at any address

 LDA ZP                 \ Set ZP(1 0) = ZP(1 0) - (2 + do - PROT1)
 SEC                    \             = do + 2 - 2 - do + PROT1
 SBC #(2 + do - PROT1)  \             = PROT1
 STA ZP
 LDA ZP+1
 SBC #&00
 STA ZP+1

 LDY #(TABLE - PROT1)   \ We're now going to loop through the words in TABLE, so
                        \ set Y as an index we can add to PROT1 (i.e. ZP) to
                        \ reach TABLE

.PROT1a

 LDA (ZP),Y             \ Set SC(1 0) = ZP(1 0) + Y-th word from TABLE
 CLC                    \
 ADC ZP                 \ so, for example, the first entry in TABLE does this:
 STA SC                 \
 INY                    \   SC(1 0) = ZP + first word from TABLE
 LDA (ZP),Y             \           = PROT1 + jsr1 + 1 - PROT1
 ADC ZP+1               \           = jsr1 + 1
 STA SC+1               \
                        \ which is the address of the destination address in the
                        \ JSR instruction at jsr1

 LDX #0                 \ Add ZP(1 0), i.e. PROT1, to the word at SC(1 0),
 LDA (SC,X)             \ starting with the low bytes
 CLC
 ADC ZP
 STA (SC,X)

 INC SC                 \ And then adding the high bytes
 BNE P%+4               \
 INC SC+1               \ So, for example, the first entry in TABLE modifies the
 LDA (SC,X)             \ destination address of the JSR at jsr1 by adding PROT1
 ADC ZP+1               \ to it, so the address now points to prstr
 STA (SC,X)             \
                        \ This modification converts the addresses in LOADSCR
                        \ from being relative to PROT1 to absolute addresses,
                        \ which lets the code run at any address

 INY                    \ Increment Y to point to the next word in TABLE

 CPY #&7D               \ Loop until we have done them all
 BNE PROT1a

 BEQ LOADSCR            \ Jump to LOADSCR (this BEQ is effectively a JMP as we
                        \ didn't take the BNE branch)

.TABLE

 EQUW jsr1 + 1 - PROT1  \ Offsets within PROT1 of JSR destination addresses that
 EQUW jsr2 + 1 - PROT1  \ we modify with the code above
 EQUW jsr3 + 1 - PROT1
 EQUW jsr4 + 1 - PROT1
 EQUW jsr5 + 1 - PROT1
 EQUW jsr6 + 1 - PROT1
 EQUW jsr7 + 1 - PROT1

 SKIP 12                \ These bytes appear to be unused

\ ******************************************************************************
\
\       Name: LOADSCR
\       Type: Subroutine
\   Category: Loader
\    Summary: Show the mode 7 Acornsoft loading screen
\
\ ******************************************************************************

.LOADSCR

 LDA ZP                 \ Set ZP(1 0) = ZP(1 0) - (PROT1 - ECHAR)
 SEC                    \             = PROT1 - PROT1 + ECHAR
 SBC #LO(PROT1 - ECHAR) \             = ECHAR
 STA ZP
 LDA ZP+1
 SBC #HI(PROT1 - ECHAR)
 STA ZP+1

 LDX #0                 \ Set S = 0, to use as a flag denoting whether this is a
 STX S                  \ BBC Micro (0) or an Electron (&FF)

 LDY #&FF               \ Call OSBYTE with A = 129, X = 0 and Y = &FF to detect
 LDA #129               \ the machine type, which returns the following:
 JSR OSBYTE             \
                        \   * X = 1 if this is an Electron

 CPX #1                 \ If X <> 1 then this is not an Electron, so jump to bbc
 BNE bbc                \ to skip the following

 DEC S                  \ Decrement S to &FF, to denote that this is an Acorn
                        \ Electron

                        \ We now define a character set consisting of "fake"
                        \ mode 7 graphics characters so the Electron can print
                        \ its own version of the Acornsoft loading screen
                        \ despite not having the BBC Micro's teletext mode 7
                        \
                        \ The command to define a character is as follows:
                        \
                        \   VDU 23, n, b0, b1, b2, b3, b4, b5, b6, b7
                        \
                        \ where n is the character number and b0 through b7 are
                        \ the bytes for each pixel row in the character (there
                        \ are 8 rows of 8 pixels in a character)
                        \
                        \ So in the following, we perform the above command
                        \ for each character using the values from the ECHAR
                        \ table

 LDY #0                 \ Set Y to act as an index into the table at ECHAR

.eloop

 LDX #7                 \ Set a counter in X for the 8 bytes we need to print
                        \ from the table for each character definition (one byte
                        \ per pixel row)

 LDA #23                \ Print character 23 (i.e. VDU 23)
 JSR OSWRCH

 TYA                    \ We will increase Y by 8 for each character, so this
 LSR A                  \ sets A = Y / 8 to give the character number, starting
 LSR A                  \ from 0 and counting up by 1 for each new character
 LSR A

 ORA #&E0               \ This adds &E0 to A, so our new character set starts
                        \ with character number &E0, then character number &E1,
                        \ and so on

 JSR OSWRCH             \ Print the character number (so we have now done the
                        \ VDU 23, n part of the command)

.vloop

 LDA (ZP),Y             \ Print the Y-th byte from the ECHAR table (we set ZP to
 JSR OSWRCH             \ point to ECHAR above)

 INY                    \ Increment the index to point to the next byte in the
                        \ table

 DEX                    \ Decrement the byte counter

 BPL vloop              \ Loop back until we have printed 8 characters

 CPY #224               \ Loop back to do the next VDU 23 command until we have
 BNE eloop              \ printed out the whole table

.bbc

                        \ We now print the Acornsoft loading screen background
                        \ using mode 7 graphics (for the BBC Micro) or the
                        \ "fake" characters we just defined (for the Electron
                        \ version)

 LDA ZP                 \ Set ZP(1 0) = ZP(1 0) + LOGO - ECHAR
 CLC                    \             = ECHAR + LOGO - ECHAR
 ADC #(LOGO - ECHAR)    \             = LOGO
 STA ZP
 BCC P%+4
 INC ZP+1

 LDA #22                \ Switch to mode 7 using a VDU 22, 7 command
 JSR OSWRCH
 LDA #7
 JSR OSWRCH

.jsr1

 JSR prstr - PROT1      \ Call prstr to print the following characters,
                        \ restarting from the NOP instruction (this destination
                        \ address is modified by the code above that adds PROT1
                        \ to the address)

 EQUB 23, 0, 10, 32     \ Set 6845 register R10 = %00100000 = 32
 EQUB 0, 0, 0           \
 EQUB 0, 0, 0           \ This is the "cursor start" register, and bits 5 and 6
                        \ define the "cursor display mode", as follows:
                        \
                        \   * %00 = steady, non-blinking cursor
                        \
                        \   * %01 = do not display a cursor
                        \
                        \   * %10 = fast blinking cursor (blink at 1/16 of the
                        \           field rate)
                        \
                        \   * %11 = slow blinking cursor (blink at 1/32 of the
                        \           field rate)
                        \
                        \ We can therefore turn off the cursor completely by
                        \ setting cursor display mode %01, with bit 6 of R10
                        \ clear and bit 5 of R10 set

 NOP                    \ Marks the end of the VDU block

 LDA #145               \ Set T to teletext control code 145 (Red graphics) to
 STA T                  \ specify that the first Acornsoft is red

.jsr2

 JSR jsr6 - PROT1       \ Call jsr6, which calls jsr7, which calls LOGOS (this
                        \ destination address is modified by the code above that
                        \ adds PROT1 to the address)

 BIT S                  \ If bit 7 of S is set (this is an Electron), jump to
 BMI jsr4               \ jsr4

.jsr3

                        \ If we get here then this is a BBC Micro, so we can
                        \ show the game's name in the mode 7 screen

 JSR prstr - PROT1      \ Call prstr to print the following characters,
                        \ restarting from the NOP instruction (this destination
                        \ address is modified by the code above that adds PROT1
                        \ to the address)

 EQUB 28                \ Define a text window as follows:
 EQUB 15, 13, 23, 10    \
                        \   * Left = 15
                        \   * Right = 23
                        \   * Top = 10
                        \   * Bottom = 13
                        \
                        \ i.e. 3 rows high, 8 columns wide at (15, 10)

 EQUB 12                \ Clear the text area

 EQUB 10                \ Move the cursor down one row

 EQUB 135               \ Teletext control code 135 (Select white text)

 EQUB 141               \ Teletext control code 141 (Double height)

 EQUS "ELITE"           \ The top half of the game's name

 EQUB 140               \ Teletext control code 140 (Turn off double height)

 EQUB 146               \ Teletext control code 146 (Select green graphics)

 EQUB 135               \ Teletext control code 135 (Select white text)

 EQUB 141               \ Teletext control code 141 (Double height)

 EQUS "ELITE"           \ The bottom half of the game's name

 EQUB 28                \ Define a text window as follows:
 EQUB 9, 23, 31, 20    \
                        \   * Left = 9
                        \   * Right = 31
                        \   * Top = 20
                        \   * Bottom = 23
                        \
                        \ i.e. 3 rows high, 22 columns wide at (9, 20)

 EQUB 135               \ Teletext control code 135 (Select white text)

 EQUB 13                \ Move the cursor down one row
 EQUB 10

 EQUB 8                 \ Backspace cursor one character

 EQUB 148               \ Teletext control code 148 (Select blue graphics)

 EQUB 135               \ Teletext control code 135 (Select white text)

 EQUB 13                \ Move the cursor down one row
 EQUB 10

 EQUB 8                 \ Backspace cursor one character

 EQUB 148               \ Teletext control code 148 (Select blue graphics)

 EQUB 135               \ Teletext control code 135 (Select white text)

 EQUB 8                 \ Backspace cursor one character

 EQUB 8                 \ Backspace cursor one character

 EQUB 10                \ Move the cursor down one row

 EQUB 148               \ Teletext control code 148 (Select blue graphics)

 EQUB 28                \ Define a text window as follows:
 EQUB 10, 22, 30, 20    \
                        \   * Left = 10
                        \   * Right = 30
                        \   * Top = 20
                        \   * Bottom = 22
                        \
                        \ i.e. 2 rows high, 20 columns wide at (10, 20)

 EQUB 12                \ Clear the text area to create a window for the loading
                        \ progress

 NOP                    \ Marks the end of the VDU block

 RTS                    \ Return from the PROT1 subroutine

.jsr4

                        \ If we get here then this is a BBC Micro, so we can
                        \ show the game's name in the mode 7 screen

 JSR prstr - PROT1      \ Call prstr to print the following characters,
                        \ restarting from the NOP instruction (this destination
                        \ address is modified by the code above that adds PROT1
                        \ to the address)

                        \ --- Mod: Code removed for Econet: ------------------->

\EQUB 28                \ Define a text window as follows:
\EQUB 15, 12, 23, 10    \
\                       \   * Left = 15
\                       \   * Right = 23
\                       \   * Top = 10
\                       \   * Bottom = 12
\                       \
\                       \ i.e. 2 rows high, 8 columns wide at (15, 10)

                        \ --- And replaced by: -------------------------------->

 EQUB 28                \ Define a text window as follows:
 EQUB 9, 12, 29, 10     \
                        \   * Left = 9
                        \   * Right = 29
                        \   * Top = 10
                        \   * Bottom = 12
                        \
                        \ i.e. 2 rows high, 20 columns wide at (9, 10)

                        \ --- End of replacement ------------------------------>

 EQUB 12                \ Clear text area

 EQUB 26                \ Restore default windows

                        \ --- Mod: Code removed for Econet: ------------------->

\EQUB 31, 17, 11        \ Move text cursor to (17, 11)
\
\EQUS "ELITE"           \ The game name

                        \ --- And replaced by: -------------------------------->

 EQUB 31, 11, 11        \ Move text cursor to (11, 11)

 EQUS "ELITE over "     \ The game name
 EQUS "Econet"

                        \ --- End of replacement ------------------------------>

 NOP                    \ Marks the end of the VDU block

.jsr5

                        \ If we get here then this is an Electron

 JSR prstr - PROT1      \ Call prstr to print the following characters,
                        \ restarting from the NOP instruction (this destination
                        \ address is modified by the code above that adds PROT1
                        \ to the address)

 EQUB 28                \ Define a text window as follows:
 EQUB 10, 22, 30, 20    \
                        \   * Left = 10
                        \   * Right = 30
                        \   * Top = 20
                        \   * Bottom = 22
                        \
                        \ i.e. 2 rows high, 20 columns wide at (10, 20)

IF _DISC

 EQUB 0                 \ If this is the disc version then do nothing, so we
                        \ don't show a window for the loading progress

ELSE

 EQUB 12                \ If this is the cassette version then clear the text
                        \ area to create a window for the loading progress

ENDIF

 NOP                    \ Marks the end of the VDU block

 RTS                    \ Return from the PROT1 subroutine

.jsr6

 JSR jsr7 - PROT1       \ Call jsr7 (this destination address is modified by the
                        \ code above that adds PROT1 to the address). This calls
                        \ the LOGOS routine twice to print two Acornsoft logos,
                        \ with a newline between then

 JSR OSNEWL             \ Print two newlines
 JSR OSNEWL

.jsr7

 JSR LOGOS - PROT1      \ Call LOGOS (this destination address is modified by
                        \ the code above that adds PROT1 to the address). This
                        \ prints a third Acornsoft logo

 JSR OSNEWL             \ Print a newline

                        \ Fall through into LOGOS to print a fourth Acornsoft
                        \ logo and return from the subroutine using a tail call

\ ******************************************************************************
\
\       Name: LOGOS
\       Type: Subroutine
\   Category: Loader
\    Summary: Print a large Acornsoft logo as part of the loading screen
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   T                   The logo colour as a teletext control code for graphics
\                       colour
\
\   ZP(1 0)             The address of the Acornsoft logo character table at
\                       LOGO
\
\ ******************************************************************************

.LOGOS

 LDY #28                \ Set Y = 28 as an index to the first row of logo
                        \ characters in the table at LOGO, after the 28 bytes of
                        \ lookup data in the first part of the table

.aloop

 LDX #38                \ Each row of the Acornsoft logo consists of 38 teletext
                        \ graphics characters, so set a counter in X to count
                        \ through the characters

 BIT S                  \ If bit 7 of S is set (this is an Electron), jump to
 BMI eskip1             \ eskip1 to skip the teletext colour codes (as the
                        \ Electron loading screen is monochrome)

 LDA T                  \ Print the character in T, which starts with teletext
 JSR OSWRCH             \ control code 145 (Red graphics) and increments through
                        \ the colours, so this sets the correct colour for the
                        \ current Acornsoft logo

 LDA #154               \ Print teletext control code 154 (Separated graphics)
 JSR OSWRCH

 CLC                    \ Skip the next two instructions
 BCC P%+7

.eskip1

 LDA #' '               \ Print a space (on the Electron only)
 JSR OSWRCH

.cloop

 LDA (ZP),Y             \ Fetch the Y-th character from ZP into A, so A contains
                        \ the next byte from LOGO, which is the user-defined
                        \ character we want to print (in the case of the
                        \ Electron), or the index into the first section of the
                        \ LOGO table for the teletext graphics character we want
                        \ to print (in the case of the BBC Micro)

 BIT S                  \ If bit 7 of S is set (this is an Electron), jump to
 BMI eskip2             \ eskip2

 STY P                  \ Store Y so we can retrieve it below

 TAY                    \ This is a BBC Micro, so the number in A is the index
 LDA (ZP),Y             \ into the first section of the LOGO table for the
                        \ teletext graphics character we want to print, so we
                        \ now fetch that character

 LDY P                  \ Retrieve the value of Y we stored above

 BNE P%+4               \ Skip the next instruction (this BNE is effectively a
                        \ JMP as Y is never zero)

.eskip2

 ORA #&E0               \ Add &E0 to the character number (on the Electron only)

 JSR OSWRCH             \ Print the character in A

 INY                    \ Increment Y to point to the next byte in the table

 CPY #255               \ If Y = 255 then we are done printing all 5 rows of the
 BEQ adone              \ logo, so jump to adone to finish off

 DEX                    \ Otherwise decrement the character counter in X

 BNE cloop              \ Loop back to print the next character until we have
                        \ done all 38 in this row

 BIT S                  \ If bit 7 of S is clear (this is a BBC Micro), skip the
 BPL P%+7               \ next two instructions

 LDA #' '               \ Print a space (on the Electron only)
 JSR OSWRCH

 CLC                    \ Jump back to aloop to print the next row in the logo
 BCC aloop

.adone

 INC T                  \ Increment the colour in T, which started with teletext
                        \ control code 145 (Red graphics) and increments through
                        \ 146 (green), 147 (yellow) and 148 (blue) with each new
                        \ call to the LOGOS routine

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: prstr
\       Type: Subroutine
\   Category: Loader
\    Summary: Print the NOP-terminated string immediately following the JSR
\             instruction that called the routine
\
\ ******************************************************************************

.prstr

 PLA                    \ We call prstr with a JSR, so pull the return address
 STA Q                  \ off the stack into Q(1 0), which actually points to
 PLA                    \ the last byte of the JSR prstr instruction
 STA Q+1

.p1

 INC Q                  \ Increment Q(1 0) to point to the next byte (so the
 BNE P%+4               \ first time we call prstr, Q points to the first byte
 INC Q+1                \ of the string we want to print)

 LDY #0                 \ Fetch the byte at Q(1 0) into A
 LDA (Q),Y

 CMP #&EA               \ If we just fetched a NOP instruction (opcode &EA),
 BEQ p2                 \ then we have reached the end of the string, so jump to
                        \ p2 to return from the subroutine

 JSR OSWRCH             \ Print the byte we just fetched

 CLC                    \ Loop back to p1 to fetch the next byte to print
 BCC p1

.p2

 JMP (Q)                \ Jump to the address in Q(1 0) - i.e. to the NOP that
                        \ we just fetched, so execution continues from the end
                        \ of the string we just printed

\ ******************************************************************************
\
\ Save SCREEN.bin
\
\ ******************************************************************************

 PRINT "S.SCREEN ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
 SAVE "3-assembled-output/SCREEN.bin", CODE%, P%, LOAD%
