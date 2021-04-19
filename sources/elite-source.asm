\ ******************************************************************************
\
\ ELECTRON ELITE GAME SOURCE
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
\ This source file produces the following binary files:
\
\   * output/ELTA.bin
\   * output/ELTB.bin
\   * output/ELTC.bin
\   * output/ELTD.bin
\   * output/ELTE.bin
\   * output/ELTF.bin
\   * output/ELTG.bin
\   * output/SHIPS.bin
\   * output/WORDS9.bin
\
\ ******************************************************************************

INCLUDE "sources/elite-header.h.asm"

\ ******************************************************************************
\
\ Configuration variables
\
\ ******************************************************************************

Q% = _REMOVE_CHECKSUMS  \ Set Q% to TRUE to max out the default commander, FALSE
                        \ for the standard default commander (this is set to
                        \ TRUE if checksums are disabled, just for convenience)

NOST = 10               \ The number of stardust particles in normal space

NOSH = 12               \ The maximum number of ships in our local bubble of
                        \ universe

NTY = 11                \ The number of different ship types

COPS = 2                \ Ship type for a Viper
CYL = 6                 \ Ship type for a Cobra Mk III (trader)
SST = 7                 \ Ship type for the space station
MSL = 8                 \ Ship type for a missile
AST = 9                 \ Ship type for an asteroid
OIL = 10                \ Ship type for a cargo canister
ESC = 11                \ Ship type for an escape pod

POW = 15                \ Pulse laser power

NI% = 36                \ The number of bytes in each ship's data block (as
                        \ stored in INWK and K%)

OSBYTE = &FFF4          \ The address for the OSBYTE routine
OSWORD = &FFF1          \ The address for the OSWORD routine
OSRDCH = &FFE0          \ The address for the OSRDCH routine
OSFILE = &FFDD          \ The address for the OSFILE routine

VIA = &FE00             \ Memory-mapped space for accessing internal hardware,
                        \ such as the video ULA, 6845 CRTC and 6522 VIAs (also
                        \ known as SHEILA)

X = 128                 \ The centre x-coordinate of the 256 x 192 space view
Y = 96                  \ The centre y-coordinate of the 256 x 192 space view

f0 = &B0                \ Internal key number for red key f0 (Launch, Front)
f1 = &B1                \ Internal key number for red key f1 (Buy Cargo, Rear)
f2 = &91                \ Internal key number for red key f2 (Sell Cargo, Left)
f3 = &92                \ Internal key number for red key f3 (Equip Ship, Right)
f4 = &93                \ Internal key number for red key f4 (Long-range Chart)
f5 = &B4                \ Internal key number for red key f5 (Short-range Chart)
f6 = &A4                \ Internal key number for red key f6 (Data on System)
f7 = &95                \ Internal key number for red key f7 (Market Price)
f8 = &A6                \ Internal key number for red key f8 (Status Mode)
f9 = &A7                \ Internal key number for red key f9 (Inventory)

\ ******************************************************************************
\
\       Name: ZP
\       Type: Workspace
\    Address: &0000 to &00B0
\   Category: Workspaces
\    Summary: Lots of important variables are stored in the zero page workspace
\             as it is quicker and more space-efficient to access memory here
\
\ ******************************************************************************

ORG &0000

.ZP

 SKIP 0                 \ The start of the zero page workspace

.RAND

 SKIP 4                 \ Four 8-bit seeds for the random number generation
                        \ system implemented in the DORND routine

.TRTB%

 SKIP 2                 \ TRTB%(1 0) points to the keyboard translation table,
                        \ which is used to translate internal key numbers to
                        \ ASCII

.T1

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

.XX16

 SKIP 18                \ Temporary storage for a block of values, used in a
                        \ number of places

.P

 SKIP 3                 \ Temporary storage, used in a number of places

.XX0

 SKIP 2                 \ Temporary storage, used to store the address of a ship
                        \ blueprint. For example, it is used when we add a new
                        \ ship to the local bubble in routine NWSHP, and it
                        \ contains the address of the current ship's blueprint
                        \ as we loop through all the nearby ships in the main
                        \ flight loop

.INF

 SKIP 2                 \ Temporary storage, typically used for storing the
                        \ address of a ship's data block, so it can be copied
                        \ to and from the internal workspace at INWK

.V

 SKIP 2                 \ Temporary storage, typically used for storing an
                        \ address pointer

.XX

 SKIP 2                 \ Temporary storage, typically used for storing a 16-bit
                        \ x-coordinate

.YY

 SKIP 2                 \ Temporary storage, typically used for storing a 16-bit
                        \ y-coordinate

.SUNX

 SKIP 2                 \ The 16-bit x-coordinate of the vertical centre axis
                        \ of the sun (which might be off-screen)

.BETA

 SKIP 1                 \ The current pitch angle beta, which is reduced from
                        \ JSTY to a sign-magnitude value between -8 and +8
                        \
                        \ This describes how fast we are pitching our ship, and
                        \ determines how fast the universe pitches around us
                        \
                        \ The sign bit is also stored in BET2, while the
                        \ opposite sign is stored in BET2+1

.BET1

 SKIP 1                 \ The magnitude of the pitch angle beta, i.e. |beta|,
                        \ which is a positive value between 0 and 8

.XC

 SKIP 1                 \ The x-coordinate of the text cursor (i.e. the text
                        \ column), which can be from 0 to 32
                        \
                        \ A value of 0 denotes the leftmost column and 32 the
                        \ rightmost column, but because the top part of the
                        \ screen (the space view) has a white border that
                        \ clashes with columns 0 and 32, text is only shown
                        \ in columns 1-31

.YC

 SKIP 1                 \ The y-coordinate of the text cursor (i.e. the text
                        \ row), which can be from 0 to 23
                        \
                        \ The screen actually has 31 character rows if you
                        \ include the dashboard, but the text printing routines
                        \ only work on the top part (the space view), so the
                        \ text cursor only goes up to a maximum of 23, the row
                        \ just before the screen splits
                        \
                        \ A value of 0 denotes the top row, but because the
                        \ top part of the screen has a white border that clashes
                        \ with row 0, text is always shown at row 1 or greater

.QQ22

 SKIP 2                 \ The two hyperspace countdown counters
                        \
                        \ Before a hyperspace jump, both QQ22 and QQ22+1 are
                        \ set to 15
                        \
                        \ QQ22 is an internal counter that counts down by 1
                        \ each time TT102 is called, which happens every
                        \ iteration of the main game loop. When it reaches
                        \ zero, the on-screen counter in QQ22+1 gets
                        \ decremented, and QQ22 gets set to 5 and the countdown
                        \ continues (so the first tick of the hyperspace counter
                        \ takes 15 iterations to happen, but subsequent ticks
                        \ take 5 iterations each)
                        \
                        \ QQ22+1 contains the number that's shown on-screen
                        \ during the countdown. It counts down from 15 to 1, and
                        \ when it hits 0, the hyperspace engines kick in

.ECMA

 SKIP 1                 \ The E.C.M. countdown timer, which determines whether
                        \ an E.C.M. system is currently operating:
                        \
                        \   * 0 = E.C.M. is off
                        \
                        \   * Non-zero = E.C.M. is on and is counting down
                        \
                        \ The counter starts at 32 when an E.C.M. is activated,
                        \ either by us or by an opponent, and it decreases by 1
                        \ in each iteration of the main flight loop until it
                        \ reaches zero, at which point the E.C.M. switches off.
                        \ Only one E.C.M. can be active at any one time, so
                        \ there is only one counter

.XX15

 SKIP 0                 \ Temporary storage, typically used for storing screen
                        \ coordinates in line-drawing routines
                        \
                        \ There are six bytes of storage, from XX15 TO XX15+5.
                        \ The first four bytes have the following aliases:
                        \
                        \   X1 = XX15
                        \   Y1 = XX15+1
                        \   X2 = XX15+2
                        \   Y2 = XX15+3
                        \
                        \ These are typically used for describing lines in terms
                        \ of screen coordinates, i.e. (X1, Y1) to (X2, Y2)
                        \
                        \ The last two bytes of XX15 do not have aliases

.X1

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.Y1

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

.X2

 SKIP 1                 \ Temporary storage, typically used for x-coordinates in
                        \ line-drawing routines

.Y2

 SKIP 1                 \ Temporary storage, typically used for y-coordinates in
                        \ line-drawing routines

 SKIP 2                 \ The last two bytes of the XX15 block

.XX12

 SKIP 6                 \ Temporary storage for a block of values, used in a
                        \ number of places

.K

 SKIP 4                 \ Temporary storage, used in a number of places

.KL

 SKIP 1                 \ The following bytes implement a key logger that
                        \ enables Elite to scan for concurrent key presses of
                        \ the primary flight keys, plus a secondary flight key
                        \
                        \ See the deep dive on "The key logger" for more details
                        \
                        \ If a key is being pressed that is not in the keyboard
                        \ table at KYTB, it can be stored here (as seen in
                        \ routine DK4, for example)

.KY1

 SKIP 1                 \ "?" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY2

 SKIP 1                 \ Space is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY3

 SKIP 1                 \ "<" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY4

 SKIP 1                 \ ">" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY5

 SKIP 1                 \ "X" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY6

 SKIP 1                 \ "S" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY7

 SKIP 1                 \ "A" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes
                        \
                        \ This is also set when the joystick fire button has
                        \ been pressed

.KY12

 SKIP 1                 \ TAB is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY13

 SKIP 1                 \ ESCAPE is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY14

 SKIP 1                 \ "T" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY15

 SKIP 1                 \ "U" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY16

 SKIP 1                 \ "M" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY17

 SKIP 1                 \ "E" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY18

 SKIP 1                 \ "J" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.KY19

 SKIP 1                 \ "C" is being pressed
                        \
                        \   * 0 = no
                        \
                        \   * Non-zero = yes

.LAS

 SKIP 1                 \ Contains the laser power of the laser fitted to the
                        \ current space view (or 0 if there is no laser fitted
                        \ to the current view)
                        \
                        \ This gets set to bits 0-6 of the laser power byte from
                        \ the commander data block, which contains the laser's
                        \ power (bit 7 doesn't denote laser power, just whether
                        \ or not the laser pulses, so that is not stored here)

.MSTG

 SKIP 1                 \ The current missile lock target
                        \
                        \   * &FF = no target
                        \
                        \   * 1-13 = the slot number of the ship that our
                        \            missile is locked onto

.XX1

 SKIP 0                 \ This is an alias for INWK that is used in the main
                        \ ship-drawing routine at LL9

.INWK

 SKIP 33                \ The zero-page internal workspace for the current ship
                        \ data block
                        \
                        \ As operations on zero page locations are faster and
                        \ have smaller opcodes than operations on the rest of
                        \ the addressable memory, Elite tends to store oft-used
                        \ data here. A lot of the routines in Elite need to
                        \ access and manipulate ship data, so to make this an
                        \ efficient exercise, the ship data is first copied from
                        \ the ship data blocks at K% into INWK (or, when new
                        \ ships are spawned, from the blueprints at XX21). See
                        \ the deep dive on "Ship data blocks" for details of
                        \ what each of the bytes in the INWK data block
                        \ represents

.XX19

 SKIP NI% - 33          \ XX19(1 0) shares its location with INWK(34 33), which
                        \ contains the address of the ship line heap

.LSP

 SKIP 1                 \ The ball line heap pointer, which contains the number
                        \ of the first free byte after the end of the LSX2 and
                        \ LSY2 heaps (see the deep dive on "The ball line heap"
                        \ for details)

.QQ15

 SKIP 6                 \ The three 16-bit seeds for the selected system, i.e.
                        \ the one in the crosshairs in the Short-range Chart
                        \
                        \ See the deep dives on "Galaxy and system seeds" and
                        \ "Twisting the system seeds" for more details

.K5

 SKIP 0                 \ Temporary storage used to store segment coordinates
                        \ across successive calls to BLINE, the ball line
                        \ routine

.XX18

 SKIP 0                 \ Temporary storage used to store coordinates in the
                        \ LL9 ship-drawing routine

.QQ17

 SKIP 1                 \ Contains a number of flags that affect how text tokens
                        \ are printed, particularly capitalisation:
                        \
                        \   * If all bits are set (255) then text printing is
                        \     disabled
                        \
                        \   * Bit 7: 0 = ALL CAPS
                        \            1 = Sentence Case, bit 6 determines the
                        \                case of the next letter to print
                        \
                        \   * Bit 6: 0 = print the next letter in upper case
                        \            1 = print the next letter in lower case
                        \
                        \   * Bits 0-5: If any of bits 0-5 are set, print in
                        \               lower case
                        \
                        \ So:
                        \
                        \   * QQ17 = 0 means case is set to ALL CAPS
                        \
                        \   * QQ17 = %10000000 means Sentence Case, currently
                        \            printing upper case
                        \
                        \   * QQ17 = %11000000 means Sentence Case, currently
                        \            printing lower case
                        \
                        \   * QQ17 = %11111111 means printing is disabled

.QQ19

 SKIP 3                 \ Temporary storage, used in a number of places

.K6

 SKIP 5                 \ Temporary storage, typically used for storing
                        \ coordinates during vector calculations

.ALP1

 SKIP 1                 \ Magnitude of the roll angle alpha, i.e. |alpha|,
                        \ which is a positive value between 0 and 31

.ALP2

 SKIP 2                 \ Bit 7 of ALP2 = sign of the roll angle in ALPHA
                        \
                        \ Bit 7 of ALP2+1 = opposite sign to ALP2 and ALPHA

.BET2

 SKIP 2                 \ Bit 7 of BET2 = sign of the pitch angle in BETA
                        \
                        \ Bit 7 of BET2+1 = opposite sign to BET2 and BETA

.DELTA

 SKIP 1                 \ Our current speed, in the range 1-40

.DELT4

 SKIP 2                 \ Our current speed * 64 as a 16-bit value
                        \
                        \ This is stored as DELT4(1 0), so the high byte in
                        \ DELT4+1 therefore contains our current speed / 4

.U

 SKIP 1                 \ Temporary storage, used in a number of places

 SKIP 16                \ ???

.Q

 SKIP 1                 \ Temporary storage, used in a number of places

.R

 SKIP 1                 \ Temporary storage, used in a number of places

.S

 SKIP 1                 \ Temporary storage, used in a number of places

.XSAV

 SKIP 1                 \ Temporary storage for saving the value of the X
                        \ register, used in a number of places

.YSAV

 SKIP 1                 \ Temporary storage for saving the value of the Y
                        \ register, used in a number of places

.XX17

 SKIP 1                 \ Temporary storage, used in BPRNT to store the number
                        \ of characters to print, and as the edge counter in the
                        \ main ship-drawing routine

.QQ11

 SKIP 1                 \ The number of the current view:
                        \
                        \   0   = Space view
                        \   1   = Title screen
                        \         Get commander name ("@", save/load commander)
                        \         In-system jump just arrived ("J")
                        \         Data on System screen (red key f6)
                        \         Buy Cargo screen (red key f1)
                        \         Mis-jump just arrived (witchspace)
                        \   4   = Sell Cargo screen (red key f2)
                        \   6   = Death screen
                        \   8   = Status Mode screen (red key f8)
                        \         Inventory screen (red key f9)
                        \   16  = Market Price screen (red key f7)
                        \   32  = Equip Ship screen (red key f3)
                        \   64  = Long-range Chart (red key f4)
                        \   128 = Short-range Chart (red key f5)
                        \
                        \ This value is typically set by calling routine TT66

.ZZ

 SKIP 1                 \ Temporary storage, typically used for distance values

.XX13

 SKIP 1                 \ Temporary storage, typically used in the line-drawing
                        \ routines

.MCNT

 SKIP 1                 \ The main loop counter
                        \
                        \ This counter determines how often certain actions are
                        \ performed within the main loop. See the deep dive on
                        \ "Scheduling tasks with the main loop counter" for more
                        \ details

.DL

 SKIP 1                 \ Vertical sync flag
                        \
                        \ DL gets set to 30 every time we reach vertical sync on
                        \ the video system, which happens 50 times a second
                        \ (50Hz). The WSCAN routine uses this to pause until the
                        \ vertical sync, by setting DL to 0 and then monitoring
                        \ its value until it changes to 30

.TYPE

 SKIP 1                 \ The current ship type
                        \
                        \ This is where we store the current ship type for when
                        \ we are iterating through the ships in the local bubble
                        \ as part of the main flight loop. See the table at XX21
                        \ for information about ship types

.JSTX

 SKIP 1                 \ Our current roll rate
                        \
                        \ This value is shown in the dashboard's RL indicator,
                        \ and determines the rate at which we are rolling
                        \
                        \ The value ranges from from 1 to 255 with 128 as the
                        \ centre point, so 1 means roll is decreasing at the
                        \ maximum rate, 128 means roll is not changing, and
                        \ 255 means roll is increasing at the maximum rate
                        \
                        \ This value is updated by "<" and ">" key presses, or
                        \ if joysticks are enabled, from the joystick. If
                        \ keyboard damping is enabled (which it is by default),
                        \ the value is slowly moved towards the centre value of
                        \ 128 (no roll) if there are no key presses or joystick
                        \ movement

.JSTY

 SKIP 1                 \ Our current pitch rate
                        \
                        \ This value is shown in the dashboard's DC indicator,
                        \ and determines the rate at which we are pitching
                        \
                        \ The value ranges from from 1 to 255 with 128 as the
                        \ centre point, so 1 means pitch is decreasing at the
                        \ maximum rate, 128 means pitch is not changing, and
                        \ 255 means pitch is increasing at the maximum rate
                        \
                        \ This value is updated by "S" and "X" key presses, or
                        \ if joysticks are enabled, from the joystick. If
                        \ keyboard damping is enabled (which it is by default),
                        \ the value is slowly moved towards the centre value of
                        \ 128 (no pitch) if there are no key presses or joystick
                        \ movement

.ALPHA

 SKIP 1                 \ The current roll angle alpha, which is reduced from
                        \ JSTX to a sign-magnitude value between -31 and +31
                        \
                        \ This describes how fast we are rolling our ship, and
                        \ determines how fast the universe rolls around us
                        \
                        \ The sign bit is also stored in ALP2, while the
                        \ opposite sign is stored in ALP2+1

.QQ12

 SKIP 1                 \ Our "docked" status
                        \
                        \   * 0 = we are not docked
                        \
                        \   * &FF = we are docked

.TGT

 SKIP 1                 \ Temporary storage, typically used as a target value
                        \ for counters when drawing explosion clouds and partial
                        \ circles

.SWAP

 SKIP 1                 \ Temporary storage, used to store a flag that records
                        \ whether or not we had to swap a line's start and end
                        \ coordinates around when clipping the line in routine
                        \ LL145 (the flag is used in places like BLINE to swap
                        \ them back)

.COL

 SKIP 1                 \ Temporary storage, used to store colour information
                        \ when drawing pixels in the dashboard

.FLAG

 SKIP 1                 \ A flag that's used to define whether this is the first
                        \ call to the ball line routine in BLINE, so it knows
                        \ whether to wait for the second call before storing
                        \ segment data in the ball line heap

.CNT

 SKIP 1                 \ Temporary storage, typically used for storing the
                        \ number of iterations required when looping

.CNT2

 SKIP 1                 \ Temporary storage, used in the planet-drawing routine
                        \ to store the segment number where the arc of a partial
                        \ circle should start

.STP

 SKIP 1                 \ The step size for drawing circles
                        \
                        \ Circles in Elite are split up into 64 points, and the
                        \ step size determines how many points to skip with each
                        \ straight-line segment, so the smaller the step size,
                        \ the smoother the circle. The values used are:
                        \
                        \   * 2 for big planets and the circles on the charts
                        \   * 4 for medium planets and the launch tunnel
                        \   * 8 for small planets and the hyperspace tunnel
                        \
                        \ As the step size increases we move from smoother
                        \ circles at the top to more polygonal at the bottom.
                        \ See the CIRCLE2 routine for more details

.XX4

 SKIP 1                 \ Temporary storage, used in a number of places

.XX20

 SKIP 1                 \ Temporary storage, used in a number of places

.XX14

 SKIP 1                 \ This byte appears to be unused

.RAT

 SKIP 1                 \ Used to store different signs depending on the current
                        \ space view, for use in calculating stardust movement

.RAT2

 SKIP 1                 \ Temporary storage, used to store the pitch and roll
                        \ signs when moving objects and stardust

.K2

 SKIP 4                 \ Temporary storage, used in a number of places

ORG &00D1

.T

 SKIP 1                 \ Temporary storage, used in a number of places

.K3

 SKIP 0                 \ Temporary storage, used in a number of places

.XX2

 SKIP 14                \ Temporary storage, used to store the visibility of the
                        \ ship's faces during the ship-drawing routine at LL9

.K4

 SKIP 2                 \ Temporary storage, used in a number of places

PRINT "Zero page variables from ", ~ZP, " to ", ~P%

\ ******************************************************************************
\
\       Name: XX3
\       Type: Workspace
\    Address: &0100 to the top of the descending stack
\   Category: Workspaces
\    Summary: Temporary storage space for complex calculations
\
\ ------------------------------------------------------------------------------
\
\ Used as heap space for storing temporary data during calculations. Shared with
\ the descending 6502 stack, which works down from &01FF.
\
\ ******************************************************************************

ORG &0100

.XX3

 SKIP 0                 \ Temporary storage, typically used for storing tables
                        \ of values such as screen coordinates or ship data

\ ******************************************************************************
\
\       Name: T%
\       Type: Workspace
\    Address: &0300 to &035F
\   Category: Workspaces
\    Summary: Current commander data and stardust data blocks
\
\ ------------------------------------------------------------------------------
\
\ Contains the current commander data (NT% bytes at location TP), and the
\ stardust data blocks (NOST bytes at location SX)
\
\ ******************************************************************************

ORG &0300

.T%

 SKIP 0                 \ The start of the T% workspace

.TP

 SKIP 1                 \ The current mission status, which is always 0 for the
                        \ cassette version of Elite as there are no missions

.QQ0

 SKIP 1                 \ The current system's galactic x-coordinate (0-256)

.QQ1

 SKIP 1                 \ The current system's galactic y-coordinate (0-256)

.QQ21

 SKIP 6                 \ The three 16-bit seeds for the current galaxy
                        \
                        \ These seeds define system 0 in the current galaxy, so
                        \ they can be used as a starting point to generate all
                        \ 256 systems in the galaxy
                        \
                        \ Using a galactic hyperdrive rotates each byte to the
                        \ left (rolling each byte within itself) to get the
                        \ seeds for the next galaxy, so after eight galactic
                        \ jumps, the seeds roll around to the first galaxy again
                        \
                        \ See the deep dives on "Galaxy and system seeds" and
                        \ "Twisting the system seeds" for more details
.CASH

 SKIP 4                 \ Our current cash pot
                        \
                        \ The cash stash is stored as a 32-bit unsigned integer,
                        \ with the most significant byte in CASH and the least
                        \ significant in CASH+3. This is big-endian, which is
                        \ the opposite way round to most of the numbers used in
                        \ Elite - to use our notation for multi-byte numbers,
                        \ the amount of cash is CASH(0 1 2 3)

.QQ14

 SKIP 1                 \ Our current fuel level (0-70)
                        \
                        \ The fuel level is stored as the number of light years
                        \ multiplied by 10, so QQ14 = 1 represents 0.1 light
                        \ years, and the maximum possible value is 70, for 7.0
                        \ light years

.COK

 SKIP 1                 \ Flags used to generate the competition code
                        \
                        \ See the deep dive on "The competition code" for
                        \ details of these flags and how they are used in
                        \ generating and decoding the competition code

.GCNT

 SKIP 1                 \ The number of the current galaxy (0-7)
                        \
                        \ When this is displayed in-game, 1 is added to the
                        \ number, so we start in galaxy 1 in-game, but it's
                        \ stored as galaxy 0 internally
                        \
                        \ The galaxy number increases by one every time a
                        \ galactic hyperdrive is used, and wraps back round to
                        \ the start after eight galaxies

.LASER

 SKIP 4                 \ The specifications of the lasers fitted to each of the
                        \ four space views:
                        \
                        \   * Byte #0 = front view (red key f0)
                        \   * Byte #1 = rear view (red key f1)
                        \   * Byte #2 = left view (red key f2)
                        \   * Byte #3 = right view (red key f3)
                        \
                        \ For each of the views:
                        \
                        \   * 0 = no laser is fitted to this view
                        \
                        \   * Non-zero = a laser is fitted to this view, with
                        \     the following specification:
                        \
                        \     * Bits 0-6 contain the laser's power
                        \
                        \     * Bit 7 determines whether or not the laser pulses
                        \       (0 = pulse laser) or is always on (1 = beam
                        \       laser)

 SKIP 2                 \ These bytes appear to be unused (they were originally
                        \ used for up/down lasers, but they were dropped)

.CRGO

 SKIP 1                 \ Our ship's cargo capacity
                        \
                        \   * 22 = standard cargo bay of 20 tonnes
                        \
                        \   * 37 = large cargo bay of 35 tonnes
                        \
                        \ The value is two greater than the actual capacity to
                        \ male the maths in tnpr slightly more efficient

.QQ20

 SKIP 17                \ The contents of our cargo hold
                        \
                        \ The amount of market item X that we have in our hold
                        \ can be found in the X-th byte of QQ20. For example:
                        \
                        \   * QQ20 contains the amount of food (item 0)
                        \
                        \   * QQ20+7 contains the amount of computers (item 7)
                        \
                        \ See QQ23 for a list of market item numbers and their
                        \ storage units

.ECM

 SKIP 1                 \ E.C.M. system
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.BST

 SKIP 1                 \ Fuel scoops (BST stands for "barrel status")
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.BOMB

 SKIP 1                 \ Energy bomb
                        \
                        \   * 0 = not fitted
                        \
                        \   * &7F = fitted

.ENGY

 SKIP 1                 \ Energy unit
                        \
                        \   * 0 = not fitted
                        \
                        \   * 1 = fitted

.DKCMP

 SKIP 1                 \ Docking computer
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.GHYP

 SKIP 1                 \ Galactic hyperdrive
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

.ESCP

 SKIP 1                 \ Escape pod
                        \
                        \   * 0 = not fitted
                        \
                        \   * &FF = fitted

 SKIP 4                 \ These bytes appear to be unused

.NOMSL

 SKIP 1                 \ The number of missiles we have fitted (0-4)

.FIST

 SKIP 1                 \ Our legal status (FIST stands for "fugitive/innocent
                        \ status"):
                        \
                        \   * 0 = Clean
                        \
                        \   * 1-49 = Offender
                        \
                        \   * 50+ = Fugitive
                        \
                        \ You get 64 points if you kill a cop, so that's a fast
                        \ ticket to fugitive status

.AVL

 SKIP 17                \ Market availability in the current system
                        \
                        \ The available amount of market item X is stored in
                        \ the X-th byte of AVL, so for example:
                        \
                        \   * AVL contains the amount of food (item 0)
                        \
                        \   * AVL+7 contains the amount of computers (item 7)
                        \
                        \ See QQ23 for a list of market item numbers and their
                        \ storage units, and the deep dive on "Market item
                        \ prices and availability" for details of the algorithm
                        \ used for calculating each item's availability

.QQ26

 SKIP 1                 \ A random value used to randomise market data
                        \
                        \ This value is set to a new random number for each
                        \ change of system, so we can add a random factor into
                        \ the calculations for market prices (for details of how
                        \ this is used, see the deep dive on "Market prices")

.TALLY

 SKIP 2                 \ Our combat rank
                        \
                        \ The combat rank is stored as the number of kills, in a
                        \ 16-bit number TALLY(1 0) - so the high byte is in
                        \ TALLY+1 and the low byte in TALLY
                        \
                        \ If the high byte in TALLY+1 is 0 then we have between
                        \ 0 and 255 kills, so our rank is Harmless, Mostly
                        \ Harmless, Poor, Average or Above Average, according to
                        \ the value of the low byte in TALLY:
                        \
                        \   Harmless        = %00000000 to %00000011 = 0 to 3
                        \   Mostly Harmless = %00000100 to %00000111 = 4 to 7
                        \   Poor            = %00001000 to %00001111 = 8 to 15
                        \   Average         = %00010000 to %00011111 = 16 to 31
                        \   Above Average   = %00100000 to %11111111 = 32 to 255
                        \
                        \ If the high byte in TALLY+1 is non-zero then we are
                        \ Competent, Dangerous, Deadly or Elite, according to
                        \ the high byte in TALLY+1:
                        \
                        \   Competent       = 1           = 256 to 511 kills
                        \   Dangerous       = 2 to 9      = 512 to 2559 kills
                        \   Deadly          = 10 to 24    = 2560 to 6399 kills
                        \   Elite           = 25 and up   = 6400 kills and up
                        \
                        \ You can see the rating calculation in STATUS

.SVC

 SKIP 1                 \ The save count
                        \
                        \ When a new commander is created, the save count gets
                        \ set to 128. This value gets halved each time the
                        \ commander file is saved, but it is otherwise unused.
                        \ It is presumably part of the security system for the
                        \ competition, possibly another flag to catch out
                        \ entries with manually altered commander files

 SKIP 2                 \ The commander file checksum
                        \
                        \ These two bytes are reserved for the commander file
                        \ checksum, so when the current commander block is
                        \ copied from here to the last saved commander block at
                        \ NA%, CHK and CHK2 get overwritten

NT% = SVC + 2 - TP      \ This sets the variable NT% to the size of the current
                        \ commander data block, which starts at TP and ends at
                        \ SVC+2 (inclusive)

.SX

 SKIP NOST + 1          \ This is where we store the x_hi coordinates for all
                        \ the stardust particles

.SXL

 SKIP NOST + 1          \ This is where we store the x_lo coordinates for all
                        \ the stardust particles

.SY

 SKIP NOST + 1          \ This is where we store the y_hi coordinates for all
                        \ the stardust particles

PRINT "T% workspace from  ", ~T%, " to ", ~P%

\ ******************************************************************************
\
\ ELITE RECURSIVE TEXT TOKEN FILE
\
\ Produces the binary file WORDS9.bin that gets loaded by elite-loader.asm.
\
\ The recursive token table is loaded at &4400 and is moved down to &0400 as
\ part of elite-loader.asm, so it ends up at &0400 to &07FF.
\
\ ******************************************************************************

CODE_WORDS% = &0400
LOAD_WORDS% = &4400

ORG CODE_WORDS%

\ ******************************************************************************
\
\       Name: CHAR
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for characters in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   CHAR 'x'            Insert ASCII character "x"
\
\ To include an apostrophe, use a backtick character, as in i.e. CHAR '`'.
\
\ See the deep dive on "Printing text tokens" for details on how characters are
\ stored in the recursive token table.
\
\ Arguments:
\
\   'x'                 The character to insert into the table
\
\ ******************************************************************************

MACRO CHAR x

  IF x = '`'
    EQUB 39 EOR 35
  ELSE
    EQUB x EOR 35
  ENDIF

ENDMACRO

\ ******************************************************************************
\
\       Name: TWOK
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for two-letter tokens in the token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   TWOK 'x', 'y'       Insert two-letter token "xy"
\
\ See the deep dive on "Printing text tokens" for details on how two-letter
\ tokens are stored in the recursive token table.
\
\ Arguments:
\
\   'x'                 The first letter of the two-letter token to insert into
\                       the table
\
\   'y'                 The second letter of the two-letter token to insert into
\                       the table
\
\ ******************************************************************************

MACRO TWOK t, k

  IF t = 'A' AND k = 'L' : EQUB 128 EOR 35 : ENDIF
  IF t = 'L' AND k = 'E' : EQUB 129 EOR 35 : ENDIF
  IF t = 'X' AND k = 'E' : EQUB 130 EOR 35 : ENDIF
  IF t = 'G' AND k = 'E' : EQUB 131 EOR 35 : ENDIF
  IF t = 'Z' AND k = 'A' : EQUB 132 EOR 35 : ENDIF
  IF t = 'C' AND k = 'E' : EQUB 133 EOR 35 : ENDIF
  IF t = 'B' AND k = 'I' : EQUB 134 EOR 35 : ENDIF
  IF t = 'S' AND k = 'O' : EQUB 135 EOR 35 : ENDIF
  IF t = 'U' AND k = 'S' : EQUB 136 EOR 35 : ENDIF
  IF t = 'E' AND k = 'S' : EQUB 137 EOR 35 : ENDIF
  IF t = 'A' AND k = 'R' : EQUB 138 EOR 35 : ENDIF
  IF t = 'M' AND k = 'A' : EQUB 139 EOR 35 : ENDIF
  IF t = 'I' AND k = 'N' : EQUB 140 EOR 35 : ENDIF
  IF t = 'D' AND k = 'I' : EQUB 141 EOR 35 : ENDIF
  IF t = 'R' AND k = 'E' : EQUB 142 EOR 35 : ENDIF
  IF t = 'A' AND k = '?' : EQUB 143 EOR 35 : ENDIF
  IF t = 'E' AND k = 'R' : EQUB 144 EOR 35 : ENDIF
  IF t = 'A' AND k = 'T' : EQUB 145 EOR 35 : ENDIF
  IF t = 'E' AND k = 'N' : EQUB 146 EOR 35 : ENDIF
  IF t = 'B' AND k = 'E' : EQUB 147 EOR 35 : ENDIF
  IF t = 'R' AND k = 'A' : EQUB 148 EOR 35 : ENDIF
  IF t = 'L' AND k = 'A' : EQUB 149 EOR 35 : ENDIF
  IF t = 'V' AND k = 'E' : EQUB 150 EOR 35 : ENDIF
  IF t = 'T' AND k = 'I' : EQUB 151 EOR 35 : ENDIF
  IF t = 'E' AND k = 'D' : EQUB 152 EOR 35 : ENDIF
  IF t = 'O' AND k = 'R' : EQUB 153 EOR 35 : ENDIF
  IF t = 'Q' AND k = 'U' : EQUB 154 EOR 35 : ENDIF
  IF t = 'A' AND k = 'N' : EQUB 155 EOR 35 : ENDIF
  IF t = 'T' AND k = 'E' : EQUB 156 EOR 35 : ENDIF
  IF t = 'I' AND k = 'S' : EQUB 157 EOR 35 : ENDIF
  IF t = 'R' AND k = 'I' : EQUB 158 EOR 35 : ENDIF
  IF t = 'O' AND k = 'N' : EQUB 159 EOR 35 : ENDIF

ENDMACRO

\ ******************************************************************************
\
\       Name: CONT
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for control codes in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   CONT n              Insert control code token {n}
\
\ See the deep dive on "Printing text tokens" for details on how characters are
\ stored in the recursive token table.
\
\ Arguments:
\
\   n                   The control code to insert into the table
\
\ ******************************************************************************

MACRO CONT n

  EQUB n EOR 35

ENDMACRO

\ ******************************************************************************
\
\       Name: RTOK
\       Type: Macro
\   Category: Text
\    Summary: Macro definition for recursive tokens in the recursive token table
\  Deep dive: Printing text tokens
\
\ ------------------------------------------------------------------------------
\
\ The following macro is used when building the recursive token table:
\
\   RTOK n              Insert recursive token [n]
\
\                         * Tokens 0-95 get stored as n + 160
\
\                         * Tokens 128-145 get stored as n - 114
\
\                         * Tokens 96-127 get stored as n
\
\ See the deep dive on "Printing text tokens" for details on how recursive
\ tokens are stored in the recursive token table.
\
\ Arguments:
\
\   n                   The number of the recursive token to insert into the
\                       table, in the range 0 to 145
\
\ ******************************************************************************

MACRO RTOK n

  IF n >= 0 AND n <= 95
    t = n + 160
  ELIF n >= 128
    t = n - 114
  ELSE
    t = n
  ENDIF

  EQUB t EOR 35

ENDMACRO

\ ******************************************************************************
\
\       Name: QQ18
\       Type: Variable
\   Category: Text
\    Summary: The recursive token table for tokens 0-148
\  Deep dive: Printing text tokens
\
\ ******************************************************************************

.QQ18

 EQUB &FF EOR 35        \ Token 0 is unused in the Electron version of Elite,
 EQUB 0                 \ and it just contains &FF (plus the standard token
                        \ obfuscation EOR) as filler

 CHAR ' '               \ Token 1:      " CHART"
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   " CH<138>T"
 TWOK 'A', 'R'
 CHAR 'T'
 EQUB 0

 CHAR 'G'               \ Token 2:      "GOVERNMENT"
 CHAR 'O'               \
 TWOK 'V', 'E'          \ Encoded as:   "GO<150>RNM<146>T"
 CHAR 'R'
 CHAR 'N'
 CHAR 'M'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               \ Token 3:      "DATA ON {selected system name}"
 TWOK 'A', 'T'          \
 CHAR 'A'               \ Encoded as:   "D<145>A[131]{3}"
 RTOK 131
 CONT 3
 EQUB 0

 TWOK 'I', 'N'          \ Token 4:      "INVENTORY{crlf}
 TWOK 'V', 'E'          \               "
 CHAR 'N'               \
 CHAR 'T'               \ Encoded as:   "<140><150>NT<153>Y{13}"
 TWOK 'O', 'R'
 CHAR 'Y'
 CONT 13
 EQUB 0

 CHAR 'S'               \ Token 5:      "SYSTEM"
 CHAR 'Y'               \
 CHAR 'S'               \ Encoded as:   "SYS<156>M"
 TWOK 'T', 'E'
 CHAR 'M'
 EQUB 0

 CHAR 'P'               \ Token 6:      "PRICE"
 TWOK 'R', 'I'          \
 TWOK 'C', 'E'          \ Encoded as:   "P<158><133>"
 EQUB 0

 CONT 2                 \ Token 7:      "{current system name} MARKET PRICES"
 CHAR ' '               \
 TWOK 'M', 'A'          \ Encoded as:   "{2} <139>RKET [6]S"
 CHAR 'R'
 CHAR 'K'
 CHAR 'E'
 CHAR 'T'
 CHAR ' '
 RTOK 6
 CHAR 'S'
 EQUB 0

 TWOK 'I', 'N'          \ Token 8:      "INDUSTRIAL"
 CHAR 'D'               \
 TWOK 'U', 'S'          \ Encoded as:   "<140>D<136>T<158><128>"
 CHAR 'T'
 TWOK 'R', 'I'
 TWOK 'A', 'L'
 EQUB 0

 CHAR 'A'               \ Token 9:      "AGRICULTURAL"
 CHAR 'G'               \
 TWOK 'R', 'I'          \ Encoded as:   "AG<158>CULTU<148>L"
 CHAR 'C'
 CHAR 'U'
 CHAR 'L'
 CHAR 'T'
 CHAR 'U'
 TWOK 'R', 'A'
 CHAR 'L'
 EQUB 0

 TWOK 'R', 'I'          \ Token 10:     "RICH "
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   "<158>CH "
 CHAR ' '
 EQUB 0

 CHAR 'A'               \ Token 11:     "AVERAGE "
 TWOK 'V', 'E'          \
 TWOK 'R', 'A'          \ Encoded as:   "A<150><148><131> "
 TWOK 'G', 'E'
 CHAR ' '
 EQUB 0

 CHAR 'P'               \ Token 12:     "POOR "
 CHAR 'O'               \
 TWOK 'O', 'R'          \ Encoded as:   "PO<153> "
 CHAR ' '
 EQUB 0

 TWOK 'M', 'A'          \ Token 13:     "MAINLY "
 TWOK 'I', 'N'          \
 CHAR 'L'               \ Encoded as:   "<139><140>LY "
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'U'               \ Token 14:     "UNIT"
 CHAR 'N'               \
 CHAR 'I'               \ Encoded as:   "UNIT"
 CHAR 'T'
 EQUB 0

 CHAR 'V'               \ Token 15:     "VIEW "
 CHAR 'I'               \
 CHAR 'E'               \ Encoded as:   "VIEW "
 CHAR 'W'
 CHAR ' '
 EQUB 0

 TWOK 'Q', 'U'          \ Token 16:     "QUANTITY"
 TWOK 'A', 'N'          \
 TWOK 'T', 'I'          \ Encoded as:   "<154><155><151>TY"
 CHAR 'T'
 CHAR 'Y'
 EQUB 0

 TWOK 'A', 'N'          \ Token 17:     "ANARCHY"
 TWOK 'A', 'R'          \
 CHAR 'C'               \ Encoded as:   "<155><138>CHY"
 CHAR 'H'
 CHAR 'Y'
 EQUB 0

 CHAR 'F'               \ Token 18:     "FEUDAL"
 CHAR 'E'               \
 CHAR 'U'               \ Encoded as:   "FEUD<128>"
 CHAR 'D'
 TWOK 'A', 'L'
 EQUB 0

 CHAR 'M'               \ Token 19:     "MULTI-GOVERNMENT"
 CHAR 'U'               \
 CHAR 'L'               \ Encoded as:   "MUL<151>-[2]"
 TWOK 'T', 'I'
 CHAR '-'
 RTOK 2
 EQUB 0

 TWOK 'D', 'I'          \ Token 20:     "DICTATORSHIP"
 CHAR 'C'               \
 CHAR 'T'               \ Encoded as:   "<141>CT<145><153>[25]"
 TWOK 'A', 'T'
 TWOK 'O', 'R'
 RTOK 25
 EQUB 0

 RTOK 91                \ Token 21:     "COMMUNIST"
 CHAR 'M'               \
 CHAR 'U'               \ Encoded as:   "[91]MUN<157>T"
 CHAR 'N'
 TWOK 'I', 'S'
 CHAR 'T'
 EQUB 0

 CHAR 'C'               \ Token 22:     "CONFEDERACY"
 TWOK 'O', 'N'          \
 CHAR 'F'               \ Encoded as:   "C<159>F<152><144>ACY"
 TWOK 'E', 'D'
 TWOK 'E', 'R'
 CHAR 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'D'               \ Token 23:     "DEMOCRACY"
 CHAR 'E'               \
 CHAR 'M'               \ Encoded as:   "DEMOC<148>CY"
 CHAR 'O'
 CHAR 'C'
 TWOK 'R', 'A'
 CHAR 'C'
 CHAR 'Y'
 EQUB 0

 CHAR 'C'               \ Token 24:     "CORPORATE STATE"
 TWOK 'O', 'R'          \
 CHAR 'P'               \ Encoded as:   "C<153>P<153><145>E [43]<145>E"
 TWOK 'O', 'R'
 TWOK 'A', 'T'
 CHAR 'E'
 CHAR ' '
 RTOK 43
 TWOK 'A', 'T'
 CHAR 'E'
 EQUB 0

 CHAR 'S'               \ Token 25:     "SHIP"
 CHAR 'H'               \
 CHAR 'I'               \ Encoded as:   "SHIP"
 CHAR 'P'
 EQUB 0

 CHAR 'P'               \ Token 26:     "PRODUCT"
 CHAR 'R'               \
 CHAR 'O'               \ Encoded as:   "PRODUCT"
 CHAR 'D'
 CHAR 'U'
 CHAR 'C'
 CHAR 'T'
 EQUB 0

 CHAR ' '               \ Token 27:     " LASER"
 TWOK 'L', 'A'          \
 CHAR 'S'               \ Encoded as:   " <149>S<144>"
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'H'               \ Token 28:     "HUMAN COLONIAL"
 CHAR 'U'               \
 CHAR 'M'               \ Encoded as:   "HUM<155> COL<159>I<128>"
 TWOK 'A', 'N'
 CHAR ' '
 CHAR 'C'
 CHAR 'O'
 CHAR 'L'
 TWOK 'O', 'N'
 CHAR 'I'
 TWOK 'A', 'L'
 EQUB 0

 CHAR 'H'               \ Token 29:     "HYPERSPACE "
 CHAR 'Y'               \
 CHAR 'P'               \ Encoded as:   "HYP<144>SPA<133> "
 TWOK 'E', 'R'
 CHAR 'S'
 CHAR 'P'
 CHAR 'A'
 TWOK 'C', 'E'
 CHAR ' '
 EQUB 0

 CHAR 'S'               \ Token 30:     "SHORT RANGE CHART"
 CHAR 'H'               \
 TWOK 'O', 'R'          \ Encoded as:   "SH<153>T [42][1]"
 CHAR 'T'
 CHAR ' '
 RTOK 42
 RTOK 1
 EQUB 0

 TWOK 'D', 'I'          \ Token 31:     "DISTANCE"
 RTOK 43                \
 TWOK 'A', 'N'          \ Encoded as:   "<141>[43]<155><133>"
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'P'               \ Token 32:     "POPULATION"
 CHAR 'O'               \
 CHAR 'P'               \ Encoded as:   "POPUL<145>I<159>"
 CHAR 'U'
 CHAR 'L'
 TWOK 'A', 'T'
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 CHAR 'G'               \ Token 33:     "GROSS PRODUCTIVITY"
 CHAR 'R'               \
 CHAR 'O'               \ Encoded as:   "GROSS [26]IVITY"
 CHAR 'S'
 CHAR 'S'
 CHAR ' '
 RTOK 26
 CHAR 'I'
 CHAR 'V'
 CHAR 'I'
 CHAR 'T'
 CHAR 'Y'
 EQUB 0

 CHAR 'E'               \ Token 34:     "ECONOMY"
 CHAR 'C'               \
 TWOK 'O', 'N'          \ Encoded as:   "EC<159>OMY"
 CHAR 'O'
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR ' '               \ Token 35:     " LIGHT YEARS"
 CHAR 'L'               \
 CHAR 'I'               \ Encoded as:   " LIGHT YE<138>S"
 CHAR 'G'
 CHAR 'H'
 CHAR 'T'
 CHAR ' '
 CHAR 'Y'
 CHAR 'E'
 TWOK 'A', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'T', 'E'          \ Token 36:     "TECH.LEVEL"
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   "<156>CH.<129><150>L"
 CHAR '.'
 TWOK 'L', 'E'
 TWOK 'V', 'E'
 CHAR 'L'
 EQUB 0

 CHAR 'C'               \ Token 37:     "CASH"
 CHAR 'A'               \
 CHAR 'S'               \ Encoded as:   "CASH"
 CHAR 'H'
 EQUB 0

 CHAR ' '               \ Token 38:     " BILLION"
 TWOK 'B', 'I'          \
 RTOK 118               \ Encoded as:   " <134>[118]I<159>"
 CHAR 'I'
 TWOK 'O', 'N'
 EQUB 0

 RTOK 122               \ Token 39:     "GALACTIC CHART{galaxy number}"
 RTOK 1                 \
 CONT 1                 \ Encoded as:   "[122][1]{1}"
 EQUB 0

 CHAR 'T'               \ Token 40:     "TARGET LOST"
 TWOK 'A', 'R'          \
 TWOK 'G', 'E'          \ Encoded as:   "T<138><131>T LO[43]"
 CHAR 'T'
 CHAR ' '
 CHAR 'L'
 CHAR 'O'
 RTOK 43
 EQUB 0

 RTOK 106               \ Token 41:     "MISSILE JAMMED"
 CHAR ' '               \
 CHAR 'J'               \ Encoded as:   "[106] JAMM<152>"
 CHAR 'A'
 CHAR 'M'
 CHAR 'M'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'R'               \ Token 42:     "RANGE"
 TWOK 'A', 'N'          \
 TWOK 'G', 'E'          \ Encoded as:   "R<155><131>"
 EQUB 0

 CHAR 'S'               \ Token 43:     "ST"
 CHAR 'T'               \
 EQUB 0                 \ Encoded as:   "ST"

 RTOK 16                \ Token 44:     "QUANTITY OF "
 CHAR ' '               \
 CHAR 'O'               \ Encoded as:   "[16] OF "
 CHAR 'F'
 CHAR ' '
 EQUB 0

 CHAR 'S'               \ Token 45:     "SELL"
 CHAR 'E'               \
 RTOK 118               \ Encoded as:   "SE[118]"
 EQUB 0

 CHAR ' '               \ Token 46:     " CARGO{sentence case}"
 CHAR 'C'               \
 TWOK 'A', 'R'          \ Encoded as:   " C<138>GO{6}"
 CHAR 'G'
 CHAR 'O'
 CONT 6
 EQUB 0

 CHAR 'E'               \ Token 47:     "EQUIP"
 TWOK 'Q', 'U'          \
 CHAR 'I'               \ Encoded as:   "E<154>IP"
 CHAR 'P'
 EQUB 0

 CHAR 'F'               \ Token 48:     "FOOD"
 CHAR 'O'               \
 CHAR 'O'               \ Encoded as:   "FOOD"
 CHAR 'D'
 EQUB 0

 TWOK 'T', 'E'          \ Token 49:     "TEXTILES"
 CHAR 'X'               \
 TWOK 'T', 'I'          \ Encoded as:   "<156>X<151>L<137>"
 CHAR 'L'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'R', 'A'          \ Token 50:     "RADIOACTIVES"
 TWOK 'D', 'I'          \
 CHAR 'O'               \ Encoded as:   "<148><141>OAC<151><150>S"
 CHAR 'A'
 CHAR 'C'
 TWOK 'T', 'I'
 TWOK 'V', 'E'
 CHAR 'S'
 EQUB 0

 CHAR 'S'               \ Token 51:     "SLAVES"
 TWOK 'L', 'A'          \
 TWOK 'V', 'E'          \ Encoded as:   "S<149><150>S"
 CHAR 'S'
 EQUB 0

 CHAR 'L'               \ Token 52:     "LIQUOR/WINES"
 CHAR 'I'               \
 TWOK 'Q', 'U'          \ Encoded as:   "LI<154><153>/W<140><137>"
 TWOK 'O', 'R'
 CHAR '/'
 CHAR 'W'
 TWOK 'I', 'N'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'L'               \ Token 53:     "LUXURIES"
 CHAR 'U'               \
 CHAR 'X'               \ Encoded as:   "LUXU<158><137>"
 CHAR 'U'
 TWOK 'R', 'I'
 TWOK 'E', 'S'
 EQUB 0

 CHAR 'N'               \ Token 54:     "NARCOTICS"
 TWOK 'A', 'R'          \
 CHAR 'C'               \ Encoded as:   "N<138>CO<151>CS"
 CHAR 'O'
 TWOK 'T', 'I'
 CHAR 'C'
 CHAR 'S'
 EQUB 0

 RTOK 91                \ Token 55:     "COMPUTERS"
 CHAR 'P'               \
 CHAR 'U'               \ Encoded as:   "[91]PUT<144>S"
 CHAR 'T'
 TWOK 'E', 'R'
 CHAR 'S'
 EQUB 0

 TWOK 'M', 'A'          \ Token 56:     "MACHINERY"
 CHAR 'C'               \
 CHAR 'H'               \ Encoded as:   "<139>CH<140><144>Y"
 TWOK 'I', 'N'
 TWOK 'E', 'R'
 CHAR 'Y'
 EQUB 0

 RTOK 117               \ Token 57:     "ALLOYS"
 CHAR 'O'               \
 CHAR 'Y'               \ Encoded as:   "[117]OYS"
 CHAR 'S'
 EQUB 0

 CHAR 'F'               \ Token 58:     "FIREARMS"
 CHAR 'I'               \
 TWOK 'R', 'E'          \ Encoded as:   "FI<142><138>MS"
 TWOK 'A', 'R'
 CHAR 'M'
 CHAR 'S'
 EQUB 0

 CHAR 'F'               \ Token 59:     "FURS"
 CHAR 'U'               \
 CHAR 'R'               \ Encoded as:   "FURS"
 CHAR 'S'
 EQUB 0

 CHAR 'M'               \ Token 60:     "MINERALS"
 TWOK 'I', 'N'          \
 TWOK 'E', 'R'          \ Encoded as:   "M<140><144><128>S"
 TWOK 'A', 'L'
 CHAR 'S'
 EQUB 0

 CHAR 'G'               \ Token 61:     "GOLD"
 CHAR 'O'               \
 CHAR 'L'               \ Encoded as:   "GOLD"
 CHAR 'D'
 EQUB 0

 CHAR 'P'               \ Token 62:     "PLATINUM"
 CHAR 'L'               \
 TWOK 'A', 'T'          \ Encoded as:   "PL<145><140>UM"
 TWOK 'I', 'N'
 CHAR 'U'
 CHAR 'M'
 EQUB 0

 TWOK 'G', 'E'          \ Token 63:     "GEM-STONES"
 CHAR 'M'               \
 CHAR '-'               \ Encoded as:   "<131>M-[43]<159><137>"
 RTOK 43
 TWOK 'O', 'N'
 TWOK 'E', 'S'
 EQUB 0

 TWOK 'A', 'L'          \ Token 64:     "ALIEN ITEMS"
 CHAR 'I'               \
 TWOK 'E', 'N'          \ Encoded as:   "<128>I<146> [127]S"
 CHAR ' '
 RTOK 127
 CHAR 'S'
 EQUB 0

 CHAR '('               \ Token 65:     "(Y/N)?"
 CHAR 'Y'               \
 CHAR '/'               \ Encoded as:   "(Y/N)?"
 CHAR 'N'
 CHAR ')'
 CHAR '?'
 EQUB 0

 CHAR ' '               \ Token 66:     " CR"
 CHAR 'C'               \
 CHAR 'R'               \ Encoded as:   " CR"
 EQUB 0

 CHAR 'L'               \ Token 67:     "LARGE"
 TWOK 'A', 'R'          \
 TWOK 'G', 'E'          \ Encoded as:   "L<138><131>"
 EQUB 0

 CHAR 'F'               \ Token 68:     "FIERCE"
 CHAR 'I'               \
 TWOK 'E', 'R'          \ Encoded as:   "FI<144><133>"
 TWOK 'C', 'E'
 EQUB 0

 CHAR 'S'               \ Token 69:     "SMALL"
 TWOK 'M', 'A'          \
 RTOK 118               \ Encoded as:   "S<139>[118]"
 EQUB 0

 CHAR 'G'               \ Token 70:     "GREEN"
 TWOK 'R', 'E'          \
 TWOK 'E', 'N'          \ Encoded as:   "G<142><146>"
 EQUB 0

 CHAR 'R'               \ Token 71:     "RED"
 TWOK 'E', 'D'          \
 EQUB 0                 \ Encoded as:   "R<152>"

 CHAR 'Y'               \ Token 72:     "YELLOW"
 CHAR 'E'               \
 RTOK 118               \ Encoded as:   "YE[118]OW"
 CHAR 'O'
 CHAR 'W'
 EQUB 0

 CHAR 'B'               \ Token 73:     "BLUE"
 CHAR 'L'               \
 CHAR 'U'               \ Encoded as:   "BLUE"
 CHAR 'E'
 EQUB 0

 CHAR 'B'               \ Token 74:     "BLACK"
 TWOK 'L', 'A'          \
 CHAR 'C'               \ Encoded as:   "B<149>CK"
 CHAR 'K'
 EQUB 0

 RTOK 136               \ Token 75:     "HARMLESS"
 EQUB 0                 \
                        \ Encoded as:   "[136]"

 CHAR 'S'               \ Token 76:     "SLIMY"
 CHAR 'L'               \
 CHAR 'I'               \ Encoded as:   "SLIMY"
 CHAR 'M'
 CHAR 'Y'
 EQUB 0

 CHAR 'B'               \ Token 77:     "BUG-EYED"
 CHAR 'U'               \
 CHAR 'G'               \ Encoded as:   "BUG-EY<152>"
 CHAR '-'
 CHAR 'E'
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'H'               \ Token 78:     "HORNED"
 TWOK 'O', 'R'          \
 CHAR 'N'               \ Encoded as:   "H<153>N<152>"
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'B'               \ Token 79:     "BONY"
 TWOK 'O', 'N'          \
 CHAR 'Y'               \ Encoded as:   "B<159>Y"
 EQUB 0

 CHAR 'F'               \ Token 80:     "FAT"
 TWOK 'A', 'T'          \
 EQUB 0                 \ Encoded as:   "F<145>"

 CHAR 'F'               \ Token 81:     "FURRY"
 CHAR 'U'               \
 CHAR 'R'               \ Encoded as:   "FURRY"
 CHAR 'R'
 CHAR 'Y'
 EQUB 0

 CHAR 'R'               \ Token 82:     "RODENT"
 CHAR 'O'               \
 CHAR 'D'               \ Encoded as:   "ROD<146>T"
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'F'               \ Token 83:     "FROG"
 CHAR 'R'               \
 CHAR 'O'               \ Encoded as:   "FROG"
 CHAR 'G'
 EQUB 0

 CHAR 'L'               \ Token 84:     "LIZARD"
 CHAR 'I'               \
 TWOK 'Z', 'A'          \ Encoded as:   "LI<132>RD"
 CHAR 'R'
 CHAR 'D'
 EQUB 0

 CHAR 'L'               \ Token 85:     "LOBSTER"
 CHAR 'O'               \
 CHAR 'B'               \ Encoded as:   "LOB[43]<144>"
 RTOK 43
 TWOK 'E', 'R'
 EQUB 0

 TWOK 'B', 'I'          \ Token 86:     "BIRD"
 CHAR 'R'               \
 CHAR 'D'               \ Encoded as:   "<134>RD"
 EQUB 0

 CHAR 'H'               \ Token 87:     "HUMANOID"
 CHAR 'U'               \
 CHAR 'M'               \ Encoded as:   "HUM<155>OID"
 TWOK 'A', 'N'
 CHAR 'O'
 CHAR 'I'
 CHAR 'D'
 EQUB 0

 CHAR 'F'               \ Token 88:     "FELINE"
 CHAR 'E'               \
 CHAR 'L'               \ Encoded as:   "FEL<140>E"
 TWOK 'I', 'N'
 CHAR 'E'
 EQUB 0

 TWOK 'I', 'N'          \ Token 89:     "INSECT"
 CHAR 'S'               \
 CHAR 'E'               \ Encoded as:   "<140>SECT"
 CHAR 'C'
 CHAR 'T'
 EQUB 0

 RTOK 11                \ Token 90:     "AVERAGE RADIUS"
 TWOK 'R', 'A'          \
 TWOK 'D', 'I'          \ Encoded as:   "[11]<148><141><136>"
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'C'               \ Token 91:     "COM"
 CHAR 'O'               \
 CHAR 'M'               \ Encoded as:   "COM"
 EQUB 0

 RTOK 91                \ Token 92:     "COMMANDER"
 CHAR 'M'               \
 TWOK 'A', 'N'          \ Encoded as:   "[91]M<155>D<144>"
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR ' '               \ Token 93:     " DESTROYED"
 CHAR 'D'               \
 TWOK 'E', 'S'          \ Encoded as:   " D<137>TROY<152>"
 CHAR 'T'
 CHAR 'R'
 CHAR 'O'
 CHAR 'Y'
 TWOK 'E', 'D'
 EQUB 0

 CHAR 'B'               \ Token 94:     "BY D.BRABEN & I.BELL"
 CHAR 'Y'               \
 CHAR ' '               \ Encoded as:   "BY D.B<148><147>N & I.<147>[118]"
 CHAR 'D'
 CHAR '.'
 CHAR 'B'
 TWOK 'R', 'A'
 TWOK 'B', 'E'
 CHAR 'N'
 CHAR ' '
 CHAR '&'
 CHAR ' '
 CHAR 'I'
 CHAR '.'
 TWOK 'B', 'E'
 RTOK 118
 EQUB 0

 RTOK 14                \ Token 95:     "UNIT  QUANTITY{crlf}
 CHAR ' '               \                 PRODUCT   UNIT PRICE FOR SALE{crlf}
 CHAR ' '               \                                              {lf}"
 RTOK 16                \
 CONT 13                \ Encoded as:   "[14]  [16]{13} [26]   [14] [6] F<153>
 CHAR ' '               \                 SA<129>{13}{10}"
 RTOK 26
 CHAR ' '
 CHAR ' '
 CHAR ' '
 RTOK 14
 CHAR ' '
 RTOK 6
 CHAR ' '
 CHAR 'F'
 TWOK 'O', 'R'
 CHAR ' '
 CHAR 'S'
 CHAR 'A'
 TWOK 'L', 'E'
 CONT 13
 CONT 10
 EQUB 0

 CHAR 'F'               \ Token 96:     "FRONT"
 CHAR 'R'               \
 TWOK 'O', 'N'          \ Encoded as:   "FR<159>T"
 CHAR 'T'
 EQUB 0

 TWOK 'R', 'E'          \ Token 97:     "REAR"
 TWOK 'A', 'R'          \
 EQUB 0                 \ Encoded as:   "<142><138>"

 TWOK 'L', 'E'          \ Token 98:     "LEFT"
 CHAR 'F'               \
 CHAR 'T'               \ Encoded as:   "<129>FT"
 EQUB 0

 TWOK 'R', 'I'          \ Token 99:     "RIGHT"
 CHAR 'G'               \
 CHAR 'H'               \ Encoded as:   "<158>GHT"
 CHAR 'T'
 EQUB 0

 RTOK 121               \ Token 100:    "ENERGY LOW{beep}"
 CHAR 'L'               \
 CHAR 'O'               \ Encoded as:   "[121]LOW{7}"
 CHAR 'W'
 CONT 7
 EQUB 0

 RTOK 99                \ Token 101:    "RIGHT ON COMMANDER!"
 RTOK 131               \
 RTOK 92                \ Encoded as:   "[99][131][92]!"
 CHAR '!'
 EQUB 0

 CHAR 'E'               \ Token 102:    "EXTRA "
 CHAR 'X'               \
 CHAR 'T'               \ Encoded as:   "EXT<148> "
 TWOK 'R', 'A'
 CHAR ' '
 EQUB 0

 CHAR 'P'               \ Token 103:    "PULSE LASER"
 CHAR 'U'               \
 CHAR 'L'               \ Encoded as:   "PULSE[27]"
 CHAR 'S'
 CHAR 'E'
 RTOK 27
 EQUB 0

 TWOK 'B', 'E'          \ Token 104:    "BEAM LASER"
 CHAR 'A'               \
 CHAR 'M'               \ Encoded as:   "<147>AM[27]"
 RTOK 27
 EQUB 0

 CHAR 'F'               \ Token 105:    "FUEL"
 CHAR 'U'               \
 CHAR 'E'               \ Encoded as:   "FUEL"
 CHAR 'L'
 EQUB 0

 CHAR 'M'               \ Token 106:    "MISSILE"
 TWOK 'I', 'S'          \
 CHAR 'S'               \ Encoded as:   "M<157>SI<129>"
 CHAR 'I'
 TWOK 'L', 'E'
 EQUB 0

 RTOK 67                \ Token 107:    "LARGE CARGO{sentence case} BAY"
 RTOK 46                \
 CHAR ' '               \ Encoded as:   "[67][46] BAY"
 CHAR 'B'
 CHAR 'A'
 CHAR 'Y'
 EQUB 0

 CHAR 'E'               \ Token 108:    "E.C.M.SYSTEM"
 CHAR '.'               \
 CHAR 'C'               \ Encoded as:   "E.C.M.[5]"
 CHAR '.'
 CHAR 'M'
 CHAR '.'
 RTOK 5
 EQUB 0

 RTOK 102               \ Token 109:    "EXTRA PULSE LASERS"
 RTOK 103               \
 CHAR 'S'               \ Encoded as:   "[102][103]S"
 EQUB 0

 RTOK 102               \ Token 110:    "EXTRA BEAM LASERS"
 RTOK 104               \
 CHAR 'S'               \ Encoded as:   "[102][104]S"
 EQUB 0

 RTOK 105               \ Token 111:    "FUEL SCOOPS"
 CHAR ' '               \
 CHAR 'S'               \ Encoded as:   "[105] SCOOPS"
 CHAR 'C'
 CHAR 'O'
 CHAR 'O'
 CHAR 'P'
 CHAR 'S'
 EQUB 0

 TWOK 'E', 'S'          \ Token 112:    "ESCAPE CAPSULE"
 CHAR 'C'               \
 CHAR 'A'               \ Encoded as:   "<137>CAPE CAPSULE"
 CHAR 'P'
 CHAR 'E'
 CHAR ' '
 CHAR 'C'
 CHAR 'A'
 CHAR 'P'
 CHAR 'S'
 CHAR 'U'
 TWOK 'L', 'E'
 EQUB 0

 RTOK 121               \ Token 113:    "ENERGY BOMB"
 CHAR 'B'               \
 CHAR 'O'               \ Encoded as:   "[121]BOMB"
 CHAR 'M'
 CHAR 'B'
 EQUB 0

 RTOK 121               \ Token 114:    "ENERGY UNIT"
 RTOK 14                \
 EQUB 0                 \ Encoded as:   "[121][14]"

 RTOK 124               \ Token 115:    "DOCKING COMPUTERS"
 TWOK 'I', 'N'          \
 CHAR 'G'               \ Encoded as:   "[124]<140>G [55]"
 CHAR ' '
 RTOK 55
 EQUB 0

 RTOK 122               \ Token 116:    "GALACTIC HYPERSPACE "
 CHAR ' '               \
 RTOK 29                \ Encoded as:   "[122] [29]"
 EQUB 0

 CHAR 'A'               \ Token 117:    "ALL"
 RTOK 118               \
 EQUB 0                 \ Encoded as:   "A[118]"

 CHAR 'L'               \ Token 118:    "LL"
 CHAR 'L'               \
 EQUB 0                 \ Encoded as:   "LL"

 RTOK 37                \ Token 119:    "CASH:{cash} CR{crlf}
 CHAR ':'               \               "
 CONT 0                 \
 EQUB 0                 \ Encoded as:   "[37]:{0}"

 TWOK 'I', 'N'          \ Token 120:    "INCOMING MISSILE"
 RTOK 91                \
 TWOK 'I', 'N'          \ Encoded as:   "<140>[91]<140>G [106]"
 CHAR 'G'
 CHAR ' '
 RTOK 106
 EQUB 0

 TWOK 'E', 'N'          \ Token 121:    "ENERGY "
 TWOK 'E', 'R'          \
 CHAR 'G'               \ Encoded as:   "<146><144>GY "
 CHAR 'Y'
 CHAR ' '
 EQUB 0

 CHAR 'G'               \ Token 122:    "GALACTIC"
 CHAR 'A'               \
 TWOK 'L', 'A'          \ Encoded as:   "GA<149>C<151>C"
 CHAR 'C'
 TWOK 'T', 'I'
 CHAR 'C'
 EQUB 0

 CONT 13                \ Token 123:    "{crlf}
 RTOK 92                \                COMMANDER'S NAME? "
 CHAR '`'               \
 CHAR 'S'               \ Encoded as:   "{13}[92]'S NAME? "
 CHAR ' '
 CHAR 'N'
 CHAR 'A'
 CHAR 'M'
 CHAR 'E'
 CHAR '?'
 CHAR ' '
 EQUB 0

 CHAR 'D'               \ Token 124:    "DOCK"
 CHAR 'O'               \
 CHAR 'C'               \ Encoded as:   "DOCK"
 CHAR 'K'
 EQUB 0

 CONT 5                 \ Token 125:    "FUEL: {fuel level} LIGHT YEARS{crlf}
 TWOK 'L', 'E'          \                CASH:{cash} CR{crlf}
 CHAR 'G'               \                LEGAL STATUS:"
 TWOK 'A', 'L'          \
 CHAR ' '               \ Encoded as:   "{5}<129>G<128> [43]<145><136>:"
 RTOK 43
 TWOK 'A', 'T'
 TWOK 'U', 'S'
 CHAR ':'
 EQUB 0

 RTOK 92                \ Token 126:    "COMMANDER {commander name}{crlf}
 CHAR ' '               \                {crlf}
 CONT 4                 \                {crlf}
 CONT 13                \                {sentence case}PRESENT SYSTEM{tab to
 CONT 13                \                column 21}:{current system name}{crlf}
 CONT 13                \                HYPERSPACE SYSTEM{tab to column 21}:
 CONT 6                 \                {selected system name}{crlf}
 RTOK 145               \                CONDITION{tab to column 21}:"
 CHAR ' '               \
 RTOK 5                 \ Encoded as:   "[92] {4}{13}{13}{13}{6}[145] [5]{9}{2}
 CONT 9                 \                {13}[29][5]{9}{3}{13}C<159><141><151>
 CONT 2                 \                <159>{9}"
 CONT 13
 RTOK 29
 RTOK 5
 CONT 9
 CONT 3
 CONT 13
 CHAR 'C'
 TWOK 'O', 'N'
 TWOK 'D', 'I'
 TWOK 'T', 'I'
 TWOK 'O', 'N'
 CONT 9
 EQUB 0

 CHAR 'I'               \ Token 127:    "ITEM"
 TWOK 'T', 'E'          \
 CHAR 'M'               \ Encoded as:   "I<156>M"
 EQUB 0

 CHAR ' '               \ Token 128:    "  LOAD NEW COMMANDER (Y/N)?{crlf}
 CHAR ' '               \                {crlf}
 CHAR 'L'               \               "
 CHAR 'O'               \
 CHAR 'A'               \ Encoded as:   "  LOAD NEW [92] [65]{13}{13}"
 CHAR 'D'
 CHAR ' '
 CHAR 'N'
 CHAR 'E'
 CHAR 'W'
 CHAR ' '
 RTOK 92
 CHAR ' '
 RTOK 65
 CONT 13
 CONT 13
 EQUB 0

 CONT 6                 \ Token 129:    "{sentence case}DOCKED"
 RTOK 124               \
 TWOK 'E', 'D'          \ Encoded as:   "{6}[124]<152>"
 EQUB 0

 TWOK 'R', 'A'          \ Token 130:    "RATING:"
 TWOK 'T', 'I'          \
 CHAR 'N'               \ Encoded as:   "<148><151>NG:"
 CHAR 'G'
 CHAR ':'
 EQUB 0

 CHAR ' '               \ Token 131:    " ON "
 TWOK 'O', 'N'          \
 CHAR ' '               \ Encoded as:   " <159> "
 EQUB 0

 CONT 13                \ Token 132:    "{crlf}
 CONT 8                 \                {all caps}EQUIPMENT: {sentence case}"
 RTOK 47                \
 CHAR 'M'               \ Encoded as:   "{13}{8}[47]M<146>T:{6}"
 TWOK 'E', 'N'
 CHAR 'T'
 CHAR ':'
 CONT 6
 EQUB 0

 CHAR 'C'               \ Token 133:    "CLEAN"
 TWOK 'L', 'E'          \
 TWOK 'A', 'N'          \ Encoded as:   "C<129><155>"
 EQUB 0

 CHAR 'O'               \ Token 134:    "OFFENDER"
 CHAR 'F'               \
 CHAR 'F'               \ Encoded as:   "OFF<146>D<144>"
 TWOK 'E', 'N'
 CHAR 'D'
 TWOK 'E', 'R'
 EQUB 0

 CHAR 'F'               \ Token 135:    "FUGITIVE"
 CHAR 'U'               \
 CHAR 'G'               \ Encoded as:   "FUGI<151><150>"
 CHAR 'I'
 TWOK 'T', 'I'
 TWOK 'V', 'E'
 EQUB 0

 CHAR 'H'               \ Token 136:    "HARMLESS"
 TWOK 'A', 'R'          \
 CHAR 'M'               \ Encoded as:   "H<138>M<129>SS"
 TWOK 'L', 'E'
 CHAR 'S'
 CHAR 'S'
 EQUB 0

 CHAR 'M'               \ Token 137:    "MOSTLY HARMLESS"
 CHAR 'O'               \
 RTOK 43                \ Encoded as:   "MO[43]LY [136]"
 CHAR 'L'
 CHAR 'Y'
 CHAR ' '
 RTOK 136
 EQUB 0

 RTOK 12                \ Token 138:    "POOR "
 EQUB 0                 \
                        \ Encoded as:   "[12]"

 RTOK 11                \ Token 139:    "AVERAGE "
 EQUB 0                 \
                        \ Encoded as:   "[11]"

 CHAR 'A'               \ Token 140:    "ABOVE AVERAGE "
 CHAR 'B'               \
 CHAR 'O'               \ Encoded as:   "ABO<150> [11]"
 TWOK 'V', 'E'
 CHAR ' '
 RTOK 11
 EQUB 0

 RTOK 91                \ Token 141:    "COMPETENT"
 CHAR 'P'               \
 CHAR 'E'               \ Encoded as:   "[91]PET<146>T"
 CHAR 'T'
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CHAR 'D'               \ Token 142:    "DANGEROUS"
 TWOK 'A', 'N'          \
 TWOK 'G', 'E'          \ Encoded as:   "D<155><131>RO<136>"
 CHAR 'R'
 CHAR 'O'
 TWOK 'U', 'S'
 EQUB 0

 CHAR 'D'               \ Token 143:    "DEADLY"
 CHAR 'E'               \
 CHAR 'A'               \ Encoded as:   "DEADLY"
 CHAR 'D'
 CHAR 'L'
 CHAR 'Y'
 EQUB 0

 CHAR '-'               \ Token 144:    "---- E L I T E ----"
 CHAR '-'               \
 CHAR '-'               \ Encoded as:   "---- E L I T E ----"
 CHAR '-'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR 'L'
 CHAR ' '
 CHAR 'I'
 CHAR ' '
 CHAR 'T'
 CHAR ' '
 CHAR 'E'
 CHAR ' '
 CHAR '-'
 CHAR '-'
 CHAR '-'
 CHAR '-'
 EQUB 0

 CHAR 'P'               \ Token 145:    "PRESENT"
 TWOK 'R', 'E'          \
 CHAR 'S'               \ Encoded as:   "P<142>S<146>T"
 TWOK 'E', 'N'
 CHAR 'T'
 EQUB 0

 CONT 8                 \ Token 146:    "{all caps}GAME OVER"
 CHAR 'G'               \
 CHAR 'A'               \ Encoded as:   "{8}GAME O<150>R"
 CHAR 'M'
 CHAR 'E'
 CHAR ' '
 CHAR 'O'
 TWOK 'V', 'E'
 CHAR 'R'
 EQUB 0

 CHAR 'P'               \ Token 147:    "PRESS FIRE OR SPACE,COMMANDER.{crlf}
 CHAR 'R'               \                {crlf}
 TWOK 'E', 'S'          \               "
 CHAR 'S'               \
 CHAR ' '               \ Encoded as:   "PR<137>S FI<142> <153> SPA<133>,[92].
 CHAR 'F'               \                {13}{13}"
 CHAR 'I'
 TWOK 'R', 'E'
 CHAR ' '
 TWOK 'O', 'R'
 CHAR ' '
 CHAR 'S'
 CHAR 'P'
 CHAR 'A'
 TWOK 'C', 'E'
 CHAR ','
 RTOK 92
 CHAR '.'
 CONT 13
 CONT 13
 EQUB 0

 CHAR '('               \ Token 148:    "(C) ACORNSOFT 1984"
 CHAR 'C'               \
 CHAR ')'               \ Encoded as:   "(C) AC<153>N<135>FT 1984"
 CHAR ' '
 CHAR 'A'
 CHAR 'C'
 TWOK 'O', 'R'
 CHAR 'N'
 TWOK 'S', 'O'
 CHAR 'F'
 CHAR 'T'
 CHAR ' '
 CHAR '1'
 CHAR '9'
 CHAR '8'
 CHAR '4'
 EQUB 0

\ ******************************************************************************
\
\ Save output/WORDS9.bin
\
\ ******************************************************************************

PRINT "WORDS9"
PRINT "Assembled at ", ~CODE_WORDS%
PRINT "Ends at ", ~P%
PRINT "Code size is ", ~(P% - CODE_WORDS%)
PRINT "Execute at ", ~LOAD_WORDS%
PRINT "Reload at ", ~LOAD_WORDS%

PRINT "S.WORDS9 ",~CODE_WORDS%," ",~P%," ",~LOAD_WORDS%," ",~LOAD_WORDS%
SAVE "output/WORDS9.bin", CODE_WORDS%, P%, LOAD_WORDS%

\ ******************************************************************************
\
\       Name: K%
\       Type: Workspace
\    Address: &0900 to &0D3F
\   Category: Workspaces
\    Summary: Ship data blocks and ship line heaps
\  Deep dive: Ship data blocks
\             The local bubble of universe
\
\ ------------------------------------------------------------------------------
\
\ Contains ship data for all the ships, planets, suns and space stations in our
\ local bubble of universe, along with their corresponding ship line heaps.
\
\ The blocks are pointed to by the lookup table at location UNIV. The first 432
\ bytes of the K% workspace hold ship data on up to 12 ships, with 36 (NI%)
\ bytes per ship, and the ship line heap grows downwards from WP at the end of
\ the K% workspace.
\
\ See the deep dive on "Ship data blocks" for details on ship data blocks, and
\ the deep dive on "The local bubble of universe" for details of how Elite
\ stores the local universe in K%, FRIN and UNIV.
\
\ ******************************************************************************

ORG &0900

.K%

 SKIP 0                 \ Ship data blocks and ship line heap

\ ******************************************************************************
\
\       Name: WP
\       Type: Workspace
\    Address: &0BE0 to &0CF3
\   Category: Workspaces
\    Summary: Ship slots, variables
\
\ ******************************************************************************

ORG &0BE0

.WP

 SKIP 0                 \ The start of the WP workspace

.FRIN

 SKIP NOSH + 1          \ Slots for the ships in the local bubble of universe
                        \
                        \ There are #NOSH + 1 slots, but the ship-spawning
                        \ routine at NWSHP only populates #NOSH of them, so
                        \ there are 13 slots but only 12 are used for ships
                        \ (the last slot is effectively used as a null
                        \ terminator when shuffling the slots down in the
                        \ KILLSHP routine)
                        \
                        \ See the deep dive on "The local bubble of universe"
                        \ for details of how Elite stores the local universe in
                        \ FRIN, UNIV and K%

.CABTMP

 SKIP 0                 \ Cabin temperature
                        \
                        \ The ambient cabin temperature in deep space is 30,
                        \ which is displayed as one notch on the dashboard bar
                        \
                        \ We get higher temperatures closer to the sun
                        \
                        \ CABTMP shares a location with MANY, but that's OK as
                        \ MANY+0 would contain the number of ships of type 0,
                        \ and as there is no ship type 0 (they start at 1), the
                        \ byte at MANY+0 is not used for storing a ship type
                        \ and can be used for the cabin temperature instead

.LAS2

 SKIP 0                 \ Laser power for the current laser
                        \
                        \   * Bits 0-6 contain the laser power of the current
                        \     space view
                        \
                        \   * Bit 7 denotes whether or not the laser pulses:
                        \
                        \     * 0 = pulsing laser
                        \
                        \     * 1 = beam laser (i.e. always on)

.MANY

 SKIP SST               \ The number of ships of each type in the local bubble
                        \ of universe
                        \
                        \ The number of ships of type X in the local bubble is
                        \ stored at MANY+X, so the number of Sidewinders is at
                        \ MANY+1, the number of Mambas is at MANY+2, and so on
                        \
                        \ See the deep dive on "Ship blueprints" for a list of
                        \ ship types

.SSPR

 SKIP NTY + 1 - SST     \ "Space station present" flag
                        \
                        \   * Non-zero if we are inside the space station's safe
                        \     zone
                        \
                        \   * 0 if we aren't (in which case we can show the sun)
                        \
                        \ This flag is at MANY+SST, which is no coincidence, as
                        \ MANY+SST is a count of how many space stations there
                        \ are in our local bubble, which is the same as saying
                        \ "space station present"

 SKIP 2                 \ ???

.L0BFB

 SKIP 2                 \ ???

.L0BFD

 SKIP 2                 \ ???

.ECMP

 SKIP 1                 \ Our E.C.M. status
                        \
                        \   * 0 = E.C.M. is off
                        \
                        \   * Non-zero = E.C.M. is on

.MSAR

 SKIP 1                 \ The targeting state of our leftmost missile
                        \
                        \   * 0 = missile is not looking for a target, or it
                        \     already has a target lock (indicator is not
                        \     yellow/white)
                        \
                        \   * Non-zero = missile is currently looking for a
                        \     target (indicator is yellow/white)

.VIEW

 SKIP 1                 \ The number of the current space view
                        \
                        \   * 0 = front
                        \   * 1 = rear
                        \   * 2 = left
                        \   * 3 = right

.LASCT

 SKIP 1                 \ The laser pulse count for the current laser
                        \
                        \ This is a counter that defines the gap between the
                        \ pulses of a pulse laser. It is set as follows:
                        \
                        \   * 0 for a beam laser
                        \
                        \   * 10 for a pulse laser
                        \
                        \ It gets decremented every vertical sync (in the LINSCN
                        \ routine, which is called 50 times a second) and is set
                        \ to a non-zero value for pulse lasers only
                        \
                        \ The laser only fires when the value of LASCT hits
                        \ zero, so for pulse lasers with a value of 10, that
                        \ means the laser fires once every 10 vertical syncs (or
                        \ 5 times a second)
                        \
                        \ In comparison, beam lasers fire continuously as the
                        \ value of LASCT is always 0

.GNTMP

 SKIP 1                 \ Laser temperature (or "gun temperature")
                        \
                        \ If the laser temperature exceeds 242 then the laser
                        \ overheats and cannot be fired again until it has
                        \ cooled down

.HFX

 SKIP 1                 \ A flag that toggles the hyperspace colour effect
                        \
                        \   * 0 = no colour effect
                        \
                        \   * Non-zero = hyperspace colour effect enabled
                        \
                        \ When HFS is set to 1, the mode 4 screen that makes
                        \ up the top part of the display is temporarily switched
                        \ to mode 5 (the same screen mode as the dashboard),
                        \ which has the effect of blurring and colouring the
                        \ hyperspace rings in the top part of the screen. The
                        \ code to do this is in the LINSCN routine, which is
                        \ called as part of the screen mode routine at IRQ1.
                        \ It's in LINSCN that HFX is checked, and if it is
                        \ non-zero, the top part of the screen is not switched
                        \ to mode 4, thus leaving the top part of the screen in
                        \ the more colourful mode 5

.EV

 SKIP 1                 \ The "extra vessels" spawning counter
                        \
                        \ This counter is set to 0 on arrival in a system and
                        \ following an in-system jump, and is bumped up when we
                        \ spawn bounty hunters or pirates (i.e. "extra vessels")
                        \
                        \ It decreases by 1 each time we consider spawning more
                        \ "extra vessels" in part 4 of the main game loop, so
                        \ increasing the value of EV has the effect of delaying
                        \ the spawning of more vessels
                        \
                        \ In other words, this counter stops bounty hunters and
                        \ pirates from continually appearing, and ensures that
                        \ there's a delay between spawnings

.DLY

 SKIP 1                 \ In-flight message delay
                        \
                        \ This counter is used to keep an in-flight message up
                        \ for a specified time before it gets removed. The value
                        \ in DLY is decremented each time we start another
                        \ iteration of the main game loop at TT100

.de

 SKIP 1                 \ Equipment destruction flag
                        \
                        \   * Bit 1 denotes whether or not the in-flight message
                        \     about to be shown by the MESS routine is about
                        \     destroyed equipment:
                        \
                        \     * 0 = the message is shown normally
                        \
                        \     * 1 = the string " DESTROYED" gets added to the
                        \       end of the message

.LSX

 SKIP 0                 \ LSX is an alias that points to the first byte of the
                        \ sun line heap at LSO
                        \
                        \   * &FF indicates the sun line heap is empty
                        \
                        \   * Otherwise the LSO heap contains the line data for
                        \     the sun

.LSO

 SKIP 86                \ Thhis is the ship line heap for the space station
                        \ (see NWSPS for details)

.LSX2

 SKIP 40                \ The ball line heap for storing x-coordinates (see the
                        \ deep dive on "The ball line heap" for details)

.LSY2

 SKIP 40                \ The ball line heap for storing y-coordinates (see the
                        \ deep dive on "The ball line heap" for details)

.SYL

 SKIP NOST + 1          \ This is where we store the y_lo coordinates for all
                        \ the stardust particles

.SZ

 SKIP NOST + 1          \ This is where we store the z_hi coordinates for all
                        \ the stardust particles

.SZL

 SKIP NOST + 1          \ This is where we store the z_lo coordinates for all
                        \ the stardust particles

.XSAV2

 SKIP 1                 \ Temporary storage, used for storing the value of the X
                        \ register in the TT26 routine

.YSAV2

 SKIP 1                 \ Temporary storage, used for storing the value of the Y
                        \ register in the TT26 routine

.MCH

 SKIP 1                 \ The text token number of the in-flight message that is
                        \ currently being shown, and which will be removed by
                        \ the me2 routine when the counter in DLY reaches zero

.FSH

 SKIP 1                 \ Forward shield status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.ASH

 SKIP 1                 \ Aft shield status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.ENERGY

 SKIP 1                 \ Energy bank status
                        \
                        \   * 0 = empty
                        \
                        \   * &FF = full

.LASX

 SKIP 1                 \ The x-coordinate of the tip of the laser line

.LASY

 SKIP 1                 \ The y-coordinate of the tip of the laser line

.COMX

 SKIP 1                 \ The x-coordinate of the compass dot

.COMY

 SKIP 1                 \ The y-coordinate of the compass dot

.QQ24

 SKIP 1                 \ Temporary storage, used to store the current market
                        \ item's price in routine TT151

.QQ25

 SKIP 1                 \ Temporary storage, used to store the current market
                        \ item's availability in routine TT151

.QQ28

 SKIP 1                 \ Temporary storage, used to store the economy byte of
                        \ the current system in routine var

.QQ29

 SKIP 1                 \ Temporary storage, used in a number of places

.gov

 SKIP 1                 \ The current system's government type (0-7)
                        \
                        \ See the deep dive on "Generating system data" for
                        \ details of the various government types

.tek

 SKIP 1                 \ The current system's tech level (0-14)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ information on tech levels

.SLSP

 SKIP 2                 \ The address of the bottom of the ship line heap
                        \
                        \ The ship line heap is a descending block of memory
                        \ that starts at WP and descends down to SLSP. It can be
                        \ extended downwards by the NWSHP routine when adding
                        \ new ships (and their associated ship line heaps), in
                        \ which case SLSP is lowered to provide more heap space,
                        \ assuming there is enough free memory to do so

.XX24

 SKIP 1                 \ This byte appears to be unused

.ALTIT

 SKIP 1                 \ Our altitude above the surface of the planet or sun
                        \
                        \   * 255 = we are a long way above the surface
                        \
                        \   * 1-254 = our altitude as the square root of:
                        \
                        \       x_hi^2 + y_hi^2 + z_hi^2 - 6^2
                        \
                        \     where our ship is at the origin, the centre of the
                        \     planet/sun is at (x_hi, y_hi, z_hi), and the
                        \     radius of the planet is 6
                        \
                        \   * 0 = we have crashed into the surface

.QQ2

 SKIP 6                 \ The three 16-bit seeds for the current system, i.e.
                        \ the one we are currently in
                        \
                        \ See the deep dives on "Galaxy and system seeds" and
                        \ "Twisting the system seeds" for more details

.QQ3

 SKIP 1                 \ The selected system's economy (0-7)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ information on economies

.QQ4

 SKIP 1                 \ The selected system's government (0-7)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ details of the various government types

.QQ5

 SKIP 1                 \ The selected system's tech level (0-14)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ information on tech levels

.QQ6

 SKIP 2                 \ The selected system's population in billions * 10
                        \ (1-71), so the maximum population is 7.1 billion
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ details on population levels

.QQ7

 SKIP 2                 \ The selected system's productivity in M CR (96-62480)
                        \
                        \ See the deep dive on "Generating system data" for more
                        \ details about productivity levels

.QQ8

 SKIP 2                 \ The distance from the current system to the selected
                        \ system in light years * 10, stored as a 16-bit number
                        \
                        \ The distance will be 0 if the selected sysyem is the
                        \ current system
                        \
                        \ The galaxy chart is 102.4 light years wide and 51.2
                        \ light years tall (see the intra-system distance
                        \ calculations in routine TT111 for details), which
                        \ equates to 1024 x 512 in terms of QQ8

.QQ9

 SKIP 1                 \ The galactic x-coordinate of the crosshairs in the
                        \ galaxy chart (and, most of the time, the selected
                        \ system's galactic x-coordinate)

.QQ10

 SKIP 1                 \ The galactic y-coordinate of the crosshairs in the
                        \ galaxy chart (and, most of the time, the selected
                        \ system's galactic y-coordinate)

PRINT "WP workspace from  ", ~WP," to ", ~P%

\ ******************************************************************************
\
\ ELITE A FILE
\
\ Produces the binary file ELTA.bin that gets loaded by elite-bcfs.asm.
\
\ ******************************************************************************

CODE% = &0D00
LOAD% = &2000

ORG CODE%

LOAD_A% = LOAD%

\ ******************************************************************************
\
\       Name: S%
\       Type: Workspace
\    Address: &0D00 to &0D24
\   Category: Workspaces
\    Summary: Vector addresses, compass colour and configuration settings
\
\ ------------------------------------------------------------------------------
\
\ Contains addresses that are used by the loader to set up vectors, the current
\ compass colour, and the game's configuration settings.
\
\ ******************************************************************************

.S%

 EQUB &40               \ This gets set to &40 by elite-loader.asm ???

.L0D01

 EQUB 0                 \ ???

 EQUW 0                 \ Gets set to the original value of IRQ1V by
                        \ elite-loader.asm

 EQUW 0                 \ Gets set to the original value of KEYV by
                        \ elite-loader.asm

.L0D06

 EQUW 0                 \ ???

 EQUW TT170             \ The entry point for the main game; once the main code
                        \ has been loaded, decrypted and moved to the right
                        \ place by elite-loader.asm, the game is started by a
                        \ JMP (S%+8) instruction, which jumps to the main entry
                        \ point at TT170 via this location

 EQUW TT26              \ WRCHV is set to point here by elite-loader.asm

 EQUW IRQ1              \ IRQ1V is set to point here by elite-loader.asm

 EQUW BR1               \ BRKV is set to point here by elite-loader.asm

.KEY1

 PHP                    \ KEYV jumps here, as set by elite-loader.asm ???

 BIT &0D01
 BMI P%+4
 PLP
 RTS

 PLP

 JMP (S%+4)             \ Jump to the original value of KEYV to process the key
                        \ press as normal

.COMC

 SKIP 1                 \ The colour of the dot on the compass
                        \
                        \   * &F0 = the object in the compass is in front of us,
                        \     so the dot is yellow/white
                        \
                        \   * &FF = the object in the compass is behind us, so
                        \     the dot is green/cyan

.DNOIZ

 SKIP 1                 \ Sound on/off configuration setting
                        \
                        \   * 0 = sound is on (default)
                        \
                        \   * Non-zero = sound is off
                        \
                        \ Toggled by pressing "S" when paused, see the DK4
                        \ routine for details

.DAMP

 SKIP 1                 \ Keyboard damping configuration setting
                        \
                        \   * 0 = damping is enabled (default)
                        \
                        \   * &FF = damping is disabled
                        \
                        \ Toggled by pressing CAPS LOCK when paused, see the
                        \ DKS3 routine for details

.DJD

 SKIP 1                 \ Keyboard auto-recentre configuration setting
                        \
                        \   * 0 = auto-recentre is enabled (default)
                        \
                        \   * &FF = auto-recentre is disabled
                        \
                        \ Toggled by pressing "A" when paused, see the DKS3
                        \ routine for details

.PATG

 SKIP 1                 \ Configuration setting to show the author names on the
                        \ start-up screen and enable manual hyperspace mis-jumps
                        \
                        \   * 0 = no author names or manual mis-jumps (default)
                        \
                        \   * &FF = show author names and allow manual mis-jumps
                        \
                        \ Toggled by pressing "X" when paused, see the DKS3
                        \ routine for details
                        \
                        \ This needs to be turned on for manual mis-jumps to be
                        \ possible. To do a manual mis-jump, first toggle the
                        \ author display by pausing the game (COPY) and pressing
                        \ "X", and during the next hyperspace, hold down CTRL to
                        \ force a mis-jump. See routine ee5 for the "AND PATG"
                        \ instruction that implements this logic

.FLH

 SKIP 1                 \ Flashing console bars configuration setting
                        \
                        \   * 0 = static bars (default)
                        \
                        \   * &FF = flashing bars
                        \
                        \ Toggled by pressing "F" when paused, see the DKS3
                        \ routine for details

.JSTGY

 SKIP 1                 \ Reverse joystick Y-channel configuration setting
                        \
                        \   * 0 = standard Y-channel (default)
                        \
                        \   * &FF = reversed Y-channel
                        \
                        \ Toggled by pressing "Y" when paused, see the DKS3
                        \ routine for details

.JSTE

 SKIP 1                 \ Reverse both joystick channels configuration setting
                        \
                        \   * 0 = standard channels (default)
                        \
                        \   * &FF = reversed channels
                        \
                        \ Toggled by pressing "J" when paused, see the DKS3
                        \ routine for details

.JSTK

 SKIP 1                 \ Keyboard or joystick configuration setting
                        \
                        \   * 0 = keyboard (default)
                        \
                        \   * &FF = joystick
                        \
                        \ Toggled by pressing "K" when paused, see the DKS3
                        \ routine for details

.IRQ1

 LDA L0D06
 EOR #&FF
 STA L0D06
 ORA L0D01
 BMI L0D3D

 LDA VIA+&05
 ORA #&20
 STA VIA+&05
 LDA &00FC
 RTI

.L0D3D

 JMP (S%+2)             \ Jump to the original value of IRQ1V to process the
                        \ interrupt as normal

\ ******************************************************************************
\
\       Name: Main flight loop (Part 1 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: Seed the random number generator
\  Deep dive: Program flow of the main game loop
\             Generating random numbers
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Seed the random number generator
\
\ Other entry points:
\
\   M%                  The entry point for the main flight loop
\
\ ******************************************************************************

.M%

 LDA K%                 \ We want to seed the random number generator with a
                        \ pretty random number, so fetch the contents of K%,
                        \ which is the x_lo coordinate of the planet. This value
                        \ will be fairly unpredictable, so it's a pretty good
                        \ candidate

 STA RAND               \ Store the seed in the first byte of the four-byte
                        \ random number seed that's stored in RAND

 LDA #0                 \ ???
 LDX #1

.L0D49

 DEC L0BFD,X
 BPL L0D54

 STA L0BFD,X
 STA L0BFB,X

.L0D54

 DEX
 BPL L0D49

\ ******************************************************************************
\
\       Name: Main flight loop (Part 2 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: Calculate the alpha and beta angles from the current pitch and
\             roll of our ship
\  Deep dive: Program flow of the main game loop
\             Pitching and rolling
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Calculate the alpha and beta angles from the current pitch and roll
\
\ Here we take the current rate of pitch and roll, as set by the joystick or
\ keyboard, and convert them into alpha and beta angles that we can use in the
\ matrix functions to rotate space around our ship. The alpha angle covers
\ roll, while the beta angle covers pitch (there is no yaw in this version of
\ Elite). The angles are in radians, which allows us to use the small angle
\ approximation when moving objects in the sky (see the MVEIT routine for more
\ on this). Also, the signs of the two angles are stored separately, in both
\ the sign and the flipped sign, as this makes calculations easier.
\
\ ******************************************************************************

 LDX JSTX               \ Set X to the current rate of roll in JSTX, and
 JSR cntr               \ apply keyboard damping twice (if enabled) so the roll
 JSR cntr               \ rate in X creeps towards the centre by 2

                        \ The roll rate in JSTX increases if we press ">" (and
                        \ the RL indicator on the dashboard goes to the right).
                        \ This rolls our ship to the right (clockwise), but we
                        \ actually implement this by rolling everything else
                        \ to the left (anticlockwise), so a positive roll rate
                        \ in JSTX translates to a negative roll angle alpha

 TXA                    \ Set A and Y to the roll rate but with the sign bit
 EOR #%10000000         \ flipped (i.e. set them to the sign we want for alpha)
 TAY

 AND #%10000000         \ Extract the flipped sign of the roll rate

 JMP P%+11              \ ???

 EQUB &A1, &BB
 EQUB &80, &00
 EQUB &90, &01
 EQUB &D6, &F1

 STA ALP2               \ Store the flipped sign of the roll rate in ALP2 (so
                        \ ALP2 contains the sign of the roll angle alpha)

 STX JSTX               \ Update JSTX with the damped value that's still in X

 EOR #%10000000         \ Extract the correct sign of the roll rate and store
 STA ALP2+1             \ in ALP2+1 (so ALP2+1 contains the flipped sign of the
                        \ roll angle alpha)

 TYA                    \ Set A to the roll rate but with the sign bit flipped

 BPL P%+7               \ If the value of A is positive, skip the following
                        \ three instructions

 EOR #%11111111         \ A is negative, so change the sign of A using two's
 CLC                    \ complement so that A is now positive and contains
 ADC #1                 \ the absolute value of the roll rate, i.e. |JSTX|

 LSR A                  \ Divide the (positive) roll rate in A by 4
 LSR A

 CMP #8                 \ If A >= 8, skip the following two instructions
 BCS P%+4

 LSR A                  \ A < 8, so halve A again

 CLC                    \ This instruction has no effect, as we only get here
                        \ if the C flag is clear (if it is set, we skip this
                        \ instruction)

 STA ALP1               \ Store A in ALP1, so we now have:
                        \
                        \   ALP1 = |JSTX| / 8    if |JSTX| < 32
                        \
                        \   ALP1 = |JSTX| / 4    if |JSTX| >= 32
                        \
                        \ This means that at lower roll rates, the roll angle is
                        \ reduced closer to zero than at higher roll rates,
                        \ which gives us finer control over the ship's roll at
                        \ lower roll rates
                        \
                        \ Because JSTX is in the range -127 to +127, ALP1 is
                        \ in the range 0 to 31

 ORA ALP2               \ Store A in ALPHA, but with the sign set to ALP2 (so
 STA ALPHA              \ ALPHA has a different sign to the actual roll rate)

 LDX JSTY               \ Set X to the current rate of pitch in JSTY, and
 JSR cntr               \ apply keyboard damping so the pitch rate in X creeps
                        \ towards the centre by 1

 TXA                    \ Set A and Y to the pitch rate but with the sign bit
 EOR #%10000000         \ flipped
 TAY

 AND #%10000000         \ Extract the flipped sign of the pitch rate into A

 STX JSTY               \ Update JSTY with the damped value that's still in X

 STA BET2+1             \ Store the flipped sign of the pitch rate in BET2+1

 EOR #%10000000         \ Extract the correct sign of the pitch rate and store
 STA BET2               \ it in BET2

 TYA                    \ Set A to the pitch rate but with the sign bit flipped

 BPL P%+4               \ If the value of A is positive, skip the following
                        \ instruction

 EOR #%11111111         \ A is negative, so flip the bits

 ADC #4                 \ Add 4 to the (positive) pitch rate, so the maximum
                        \ value is now up to 131 (rather than 127)

 LSR A                  \ Divide the (positive) pitch rate in A by 16
 LSR A
 LSR A
 LSR A

 CMP #3                 \ If A >= 3, skip the following instruction
 BCS P%+3

 LSR A                  \ A < 3, so halve A again

 STA BET1               \ Store A in BET1, so we now have:
                        \
                        \   BET1 = |JSTY| / 32    if |JSTY| < 48
                        \
                        \   BET1 = |JSTY| / 16    if |JSTY| >= 48
                        \
                        \ This means that at lower pitch rates, the pitch angle
                        \ is reduced closer to zero than at higher pitch rates,
                        \ which gives us finer control over the ship's pitch at
                        \ lower pitch rates
                        \
                        \ Because JSTY is in the range -131 to +131, BET1 is in
                        \ the range 0 to 8

 ORA BET2               \ Store A in BETA, but with the sign set to BET2 (so
 STA BETA               \ BETA has the same sign as the actual pitch rate)

\ ******************************************************************************
\
\       Name: Main flight loop (Part 3 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: Scan for flight keys and process the results
\  Deep dive: Program flow of the main game loop
\             The key logger
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Scan for flight keys and process the results
\
\ Flight keys are logged in the key logger at location KY1 onwards, with a
\ non-zero value in the relevant location indicating a key press. See the deep
\ dive on "The key logger" for more details.
\
\ The key presses that are processed are as follows:
\
\   * Space and "?" to speed up and slow down
\   * "U", "T" and "M" to disarm, arm and fire missiles
\   * TAB to fire an energy bomb
\   * ESCAPE to launch an escape pod
\   * "J" to initiate an in-system jump
\   * "E" to deploy E.C.M. anti-missile countermeasures
\   * "C" to use the docking computer
\   * "A" to fire lasers
\
\ ******************************************************************************

 LDA KY2                \ If Space is being pressed, keep going, otherwise jump
 BEQ MA17               \ down to MA17 to skip the following

 LDA DELTA              \ The "go faster" key is being pressed, so first we
 CMP #40                \ fetch the current speed from DELTA into A, and if
 BCS MA17               \ A >= 40, we are already going at full pelt, so jump
                        \ down to MA17 to skip the following

 INC DELTA              \ We can go a bit faster, so increment the speed in
                        \ location DELTA

.MA17

 LDA KY1                \ If "?" is being pressed, keep going, otherwise jump
 BEQ MA4                \ down to MA4 to skip the following

 DEC DELTA              \ The "slow down" key is being pressed, so we decrement
                        \ the current ship speed in DELTA

 BNE MA4                \ If the speed is still greater than zero, jump to MA4

 INC DELTA              \ Otherwise we just braked a little too hard, so bump
                        \ the speed back up to the minimum value of 1

.MA4

 LDA KY15               \ If "U" is being pressed and the number of missiles
 AND NOMSL              \ in NOMSL is non-zero, keep going, otherwise jump down
 BEQ MA20               \ to MA20 to skip the following

 JSR L3903              \ ???

 LDA #40                \ Call the NOISE routine with A = 40 to make a low,
 JSR NOISE              \ long beep to indicate the missile is now disarmed

.MA31

 LDA #0                 \ Set MSAR to 0 to indicate that no missiles are
 STA MSAR               \ currently armed

.MA20

 LDA MSTG               \ If MSTG is positive (i.e. it does not have bit 7 set),
 BPL MA25               \ then it indicates we already have a missile locked on
                        \ a target (in which case MSTG contains the ship number
                        \ of the target), so jump to MA25 to skip targeting. Or
                        \ to put it another way, if MSTG = &FF, which means
                        \ there is no current target lock, keep going

 LDA KY14               \ If "T" is being pressed, keep going, otherwise jump
 BEQ MA25               \ down to MA25 to skip the following

 LDX NOMSL              \ If the number of missiles in NOMSL is zero, jump down
 BEQ MA25               \ to MA25 to skip the following

 STA MSAR               \ The "target missile" key is being pressed and we have
                        \ at least one missile, so set MSAR = &FF to denote that
                        \ our missile is currently armed (we know A has the
                        \ value &FF, as we just loaded it from MSTG and checked
                        \ that it was negative)

 LDY #&0D               \ Change the leftmost missile indicator to yellow/white
 JSR MSBAR              \ on the missile bar (this call changes the leftmost
                        \ indicator because we set X to the number of missiles
                        \ in NOMSL above, and the indicators are numbered from
                        \ right to left, so X is the number of the leftmost
                        \ indicator) ???

.MA25

 LDA KY16               \ If "M" is being pressed, keep going, otherwise jump
 BEQ MA24               \ down to MA24 to skip the following

 LDA MSTG               \ If MSTG = &FF then there is no target lock, so jump to
 BMI MA64               \ MA64 to skip the following (also skipping the checks
                        \ for TAB, ESCAPE, "J" and "E")

 JSR FRMIS              \ The "fire missile" key is being pressed and we have
                        \ a missile lock, so call the FRMIS routine to fire
                        \ the missile

.MA24

 LDA KY12               \ If TAB is being pressed, keep going, otherwise jump
 BEQ MA76               \ jump down to MA76 to skip the following

 ASL BOMB               \ The "energy bomb" key is being pressed, so double
                        \ the value in BOMB. If we have an energy bomb fitted,
                        \ BOMB will contain &7F (%01111111) before this shift
                        \ and will contain &FE (%11111110) after the shift; if
                        \ we don't have an energy bomb fitted, BOMB will still
                        \ contain 0. The bomb explosion is dealt with in the
                        \ MAL1 routine below - this just registers the fact that
                        \ we've set the bomb ticking

.MA76

 LDA KY13               \ If ESCAPE is being pressed and we have an escape pod
 AND ESCP               \ fitted, keep going, otherwise skip the next
 BEQ P%+5               \ instruction

 JMP ESCAPE             \ The "launch escape pod" button is being pressed and
                        \ we have an escape pod fitted, so jump to ESCAPE to
                        \ launch it, and exit the main flight loop using a tail
                        \ call

 LDA KY18               \ If "J" is being pressed, keep going, otherwise skip
 BEQ P%+5               \ the next instruction

 JSR WARP               \ Call the WARP routine to do an in-system jump

 LDA KY17               \ If "E" is being pressed and we have an E.C.M. fitted,
 AND ECM                \ keep going, otherwise jump down to MA64 to skip the
 BEQ MA64               \ following

 LDA ECMA               \ If ECMA is non-zero, that means an E.C.M. is already
 BNE MA64               \ operating and is counting down (this can be either
                        \ our E.C.M. or an opponent's), so jump down to MA64 to
                        \ skip the following (as we can't have two E.C.M.
                        \ systems operating at the same time)

 DEC ECMP               \ The "E.C.M." button is being pressed and nobody else
                        \ is operating their E.C.M., so decrease the value of
                        \ ECMP to make it non-zero, to denote that our E.C.M.
                        \ is now on

 JSR ECBLB2             \ Call ECBLB2 to light up the E.C.M. indicator bulb on
                        \ the dashboard, set the E.C.M. countdown timer to 32,
                        \ and start making the E.C.M. sound

.MA64

 LDA KY19               \ If "C" is being pressed, and we have a docking
 AND DKCMP              \ computer fitted, and we are inside the space station's
 AND SSPR               \ safe zone, keep going, otherwise jump down to MA68 to
 BEQ MA68               \ skip the following

 LDA K%+NI%+32          \ Fetch the AI counter (byte #32) of the second ship
 BMI MA68               \ from the ship data workspace at K%, which is reserved
                        \ for the sun or the space station (in this case it's
                        \ the latter as we are in the safe zone). If byte #32 is
                        \ negative, meaning the station is hostile, then jump
                        \ down to MA68 to skip the following (so we can't use
                        \ the docking computer to dock at a station that has
                        \ turned against us)

 JMP GOIN               \ The "docking computer" button has been pressed and
                        \ we are allowed to dock at the station, so jump to
                        \ GOIN to dock (or "go in"), and exit the main flight
                        \ loop using a tail call

.MA68

 LDA #0                 \ Set LAS = 0, to switch the laser off while we do the
 STA LAS                \ following logic

 STA DELT4              \ Take the 16-bit value (DELTA 0) - i.e. a two-byte
 LDA DELTA              \ number with DELTA as the high byte and 0 as the low
 LSR A                  \ byte - and divide it by 4, storing the 16-bit result
 ROR DELT4              \ in DELT4(1 0). This has the effect of storing the
 LSR A                  \ current speed * 64 in the 16-bit location DELT4(1 0)
 ROR DELT4
 STA DELT4+1

 LDA LASCT              \ If LASCT is zero, keep going, otherwise the laser is
 BNE MA3                \ a pulse laser that is between pulses, so jump down to
                        \ MA3 to skip the following

 LDA KY7                \ If "A" is being pressed, keep going, otherwise jump
 BEQ MA3                \ down to MA3 to skip the following

 LDA GNTMP              \ If the laser temperature >= 242 then the laser has
 CMP #242               \ overheated, so jump down to MA3 to skip the following
 BCS MA3

 LDX VIEW               \ If the current space view has a laser fitted (i.e. the
 LDA LASER,X            \ laser power for this view is greater than zero), then
 BEQ MA3                \ keep going, otherwise jump down to MA3 to skip the
                        \ following

                        \ If we get here, then the "fire" button is being
                        \ pressed, our laser hasn't overheated and isn't already
                        \ being fired, and we actually have a laser fitted to
                        \ the current space view, so it's time to hit me with
                        \ those laser beams

 PHA                    \ Store the current view's laser power on the stack

 AND #%01111111         \ Set LAS and LAS2 to bits 0-6 of the laser power
 STA LAS
 STA LAS2

 LDA #0                 \ Call the NOISE routine with A = 0 to make the sound
 JSR NOISE              \ of our laser firing

 JSR LASLI              \ Call LASLI to draw the laser lines

 PLA                    \ Restore the current view's laser power into A

 BPL ma1                \ If the laser power has bit 7 set, then it's an "always
                        \ on" laser rather than a pulsing laser, so keep going,
                        \ otherwise jump down to ma1 to skip the following
                        \ instruction

 LDA #0                 \ This is an "always on" laser (i.e. a beam laser,
                        \ as the cassette version of Elite doesn't have military
                        \ lasers), so set A = 0, which will be stored in LASCT
                        \ to denote that this is not a pulsing laser

.ma1

 AND #%11111010         \ LASCT will be set to 0 for beam lasers, and to the
 STA LASCT              \ laser power AND %11111010 for pulse lasers, which
                        \ comes to 10 (as pulse lasers have a power of 15). See
                        \ MA23 below for more on laser pulsing and LASCT

\ ******************************************************************************
\
\       Name: Main flight loop (Part 4 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: For each nearby ship: Copy the ship's data block from K% to the
\             zero-page workspace at INWK
\  Deep dive: Program flow of the main game loop
\             Ship data blocks
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Start looping through all the ships in the local bubble, and for each
\     one:
\
\     * Copy the ship's data block from K% to INWK
\
\     * Set XX0 to point to the ship's blueprint (if this is a ship)
\
\ Other entry points:
\
\   MAL1                Marks the beginning of the ship analysis loop, so we
\                       can jump back here from part 12 of the main flight loop
\                       to work our way through each ship in the local bubble.
\                       We also jump back here when a ship is removed from the
\                       bubble, so we can continue processing from the next ship
\
\ ******************************************************************************

.MA3

 LDX #0                 \ We're about to work our way through all the ships in
                        \ our local bubble of universe, so set a counter in X,
                        \ starting from 0, to refer to each ship slot in turn

.MAL1

 STX XSAV               \ Store the current slot number in XSAV

 LDA FRIN,X             \ Fetch the contents of this slot into A. If it is 0
 BNE P%+5               \ then this slot is empty and we have no more ships to
 JMP MA18               \ process, so jump to MA18 below, otherwise A contains
                        \ the type of ship that's in this slot, so skip over the
                        \ JMP MA18 instruction and keep going

 STA TYPE               \ Store the ship type in TYPE

 JSR GINF               \ Call GINF to fetch the address of the ship data block
                        \ for the ship in slot X and store it in INF. The data
                        \ block is in the K% workspace, which is where all the
                        \ ship data blocks are stored

                        \ Next we want to copy the ship data block from INF to
                        \ the zero-page workspace at INWK, so we can process it
                        \ more efficiently

 LDY #NI%-1             \ There are NI% bytes in each ship data block (and in
                        \ the INWK workspace, so we set a counter in Y so we can
                        \ loop through them

.MAL2

 LDA (INF),Y            \ Load the Y-th byte of INF and store it in the Y-th
 STA INWK,Y             \ byte of INWK

 DEY                    \ Decrement the loop counter

 BPL MAL2               \ Loop back for the next byte until we have copied the
                        \ last byte from INF to INWK

 LDA TYPE               \ If the ship type is negative then this indicates a
 BMI MA21               \ planet or sun, so jump down to MA21, as the next bit
                        \ sets up a pointer to the ship blueprint, and then
                        \ checks for energy bomb damage, and neither of these
                        \ apply to planets and suns

 ASL A                  \ Set Y = ship type * 2
 TAY

 LDA XX21-2,Y           \ The ship blueprints at XX21 start with a lookup
 STA XX0                \ table that points to the individual ship blueprints,
                        \ so this fetches the low byte of this particular ship
                        \ type's blueprint and stores it in XX0

 LDA XX21-1,Y           \ Fetch the high byte of this particular ship type's
 STA XX0+1              \ blueprint and store it in XX0+1

\ ******************************************************************************
\
\       Name: Main flight loop (Part 5 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: For each nearby ship: If an energy bomb has been set off,
\             potentially kill this ship
\  Deep dive: Program flow of the main game loop
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Continue looping through all the ships in the local bubble, and for each
\     one:
\
\     * If an energy bomb has been set off and this ship can be killed, kill it
\       and increase the kill tally
\
\ ******************************************************************************

 LDA BOMB               \ If we set off our energy bomb by pressing TAB (see
 BPL MA21               \ MA24 above), then BOMB is now negative, so this skips
                        \ to MA21 if our energy bomb is not going off

 CPY #2*SST             \ If the ship in Y is the space station, jump to BA21
 BEQ MA21               \ as energy bombs are useless against space stations

 LDA INWK+31            \ If the ship we are checking has bit 5 set in its ship
 AND #%00100000         \ byte #31, then it is already exploding, so jump to
 BNE MA21               \ BA21 as ships can't explode more than once

 LDA INWK+31            \ The energy bomb is killing this ship, so set bit 7 of
 ORA #%10000000         \ the ship byte #31 to indicate that it has now been
 STA INWK+31            \ killed

 JSR EXNO2              \ Call EXNO2 to process the fact that we have killed a
                        \ ship (so increase the kill tally, make an explosion
                        \ sound and possibly display "RIGHT ON COMMANDER!")

\ ******************************************************************************
\
\       Name: Main flight loop (Part 6 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: For each nearby ship: Move the ship in space and copy the updated
\             INWK data block back to K%
\  Deep dive: Program flow of the main game loop
\             Program flow of the ship-moving routine
\             Ship data blocks
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Continue looping through all the ships in the local bubble, and for each
\     one:
\
\     * Move the ship in space
\
\     * Copy the updated ship's data block from INWK back to K%
\
\ ******************************************************************************

.MA21

 JSR MVEIT              \ Call MVEIT to move the ship we are processing in space

                        \ Now that we are done processing this ship, we need to
                        \ copy the ship data back from INWK to the correct place
                        \ in the K% workspace. We already set INF in part 4 to
                        \ point to the ship's data block in K%, so we can simply
                        \ do the reverse of the copy we did before, this time
                        \ copying from INWK to INF

 LDY #(NI%-1)           \ Set a counter in Y so we can loop through the NI%
                        \ bytes in the ship data block

.MAL3

 LDA INWK,Y             \ Load the Y-th byte of INWK and store it in the Y-th
 STA (INF),Y            \ byte of INF

 DEY                    \ Decrement the loop counter

 BPL MAL3               \ Loop back for the next byte, until we have copied the
                        \ last byte from INWK back to INF

\ ******************************************************************************
\
\       Name: Main flight loop (Part 7 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: For each nearby ship: Check whether we are docking, scooping or
\             colliding with it
\  Deep dive: Program flow of the main game loop
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Continue looping through all the ships in the local bubble, and for each
\     one:
\
\     * Check how close we are to this ship and work out if we are docking,
\       scooping or colliding with it
\
\ ******************************************************************************

 LDA INWK+31            \ Fetch the status of this ship from bits 5 (is ship
 AND #%10100000         \ exploding?) and bit 7 (has ship been killed?) from
                        \ ship byte #31 into A

 JSR MAS4               \ Or this value with x_hi, y_hi and z_hi

 BNE MA65               \ If this value is non-zero, then either the ship is
                        \ far away (i.e. has a non-zero high byte in at least
                        \ one of the three axes), or it is already exploding,
                        \ or has been flagged as being killed - in which case
                        \ jump to MA65 to skip the following, as we can't dock
                        \ scoop or collide with it

 LDA INWK               \ Set A = (x_lo OR y_lo OR z_lo), and if bit 7 of the
 ORA INWK+3             \ result is set, the ship is still a fair distance
 ORA INWK+6             \ away (further than 127 in at least one axis), so jump
 BMI MA65               \ to MA65 to skip the following, as it's too far away to
                        \ dock, scoop or collide with

 LDX TYPE               \ If the current ship type is negative then it's either
 BMI MA65               \ a planet or a sun, so jump down to MA65 to skip the
                        \ following, as we can't dock with it or scoop it

 CPX #SST               \ If this ship is the space station, jump to ISDK to
 BEQ ISDK               \ check whether we are docking with it

 AND #%11000000         \ If bit 6 of (x_lo OR y_lo OR z_lo) is set, then the
 BNE MA65               \ ship is still a reasonable distance away (further than
                        \ 63 in at least one axis), so jump to MA65 to skip the
                        \ following, as it's too far away to dock, scoop or
                        \ collide with

 CPX #MSL               \ If this ship is a missile, jump down to MA65 to skip
 BEQ MA65               \ the following, as we can't scoop or dock with a
                        \ missile, and it has its own dedicated collision
                        \ checks in the TACTICS routine

 CPX #OIL               \ If ship type >= OIL (i.e. it's a cargo canister,
 BCS P%+5               \ Thargon or escape pod), skip the JMP instruction and
 JMP MA58               \ continue on, otherwise jump to MA58 to process a
                        \ potential collision

 LDA BST                \ If we have fuel scoops fitted then BST will be &FF,
                        \ otherwise it will be 0

 AND INWK+5             \ Ship byte #5 contains the y_sign of this ship, so a
                        \ negative value here means the canister is below us,
                        \ which means the result of the AND will be negative if
                        \ the canister is below us and we have a fuel scoop
                        \ fitted

 BPL MA58               \ If the result is positive, then we either have no
                        \ scoop or the canister is above us, and in both cases
                        \ this means we can't scoop the item, so jump to MA58
                        \ to process a collision

\ ******************************************************************************
\
\       Name: Main flight loop (Part 8 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: For each nearby ship: Process us potentially scooping this item
\  Deep dive: Program flow of the main game loop
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Continue looping through all the ships in the local bubble, and for each
\     one:
\
\     * Process us potentially scooping this item
\
\ ******************************************************************************

 LDA #3                 \ Set A to 3 to denote we may be scooping an escape pod

 CPX #ESC               \ ???
 BNE oily

 BEQ slvy2

.oily

 JSR DORND              \ Set A and X to random numbers and reduce A to a
 AND #7                 \ random number in the range 0-7

.slvy2

                        \ By the time we get here, we are scooping, and A
                        \ contains the type of item we are scooping (a random
                        \ number 0-7 if we are scooping a cargo canister, 3 if
                        \ we are scooping an escape pod, or 16 if we are
                        \ scooping a Thargon). These numbers correspond to the
                        \ relevant market items (see QQ23 for a list), so a
                        \ cargo canister can contain anything from food to
                        \ computers, while escape pods contain slaves, and
                        \ Thargons become alien items when scooped

 STA QQ29               \ Call tnpr with the scooped cargo type stored in QQ29
 LDA #1                 \ and A set to 1, to work out whether we have room in
 JSR tnpr               \ the hold for the scooped item (A is preserved by this
                        \ call, and the C flag contains the result)

 LDY #78                \ This instruction has no effect, so presumably it used
                        \ to do something, but didn't get removed

 BCS MA59               \ If the C flag is set then we have no room in the hold
                        \ for the scooped item, so jump down to MA59 make a
                        \ sound to indicate failure, before destroying the
                        \ canister

 LDY QQ29               \ Scooping was successful, so set Y to the type of
                        \ item we just scooped, which we stored in QQ29 above

 ADC QQ20,Y             \ Add A (which we set to 1 above) to the number of items
 STA QQ20,Y             \ of type Y in the cargo hold, as we just successfully
                        \ scooped one canister of type Y

 TYA                    \ Print recursive token 48 + A as an in-flight token,
 ADC #208               \ which will be in the range 48 ("FOOD") to 64 ("ALIEN
 JSR MESS               \ ITEMS"), so this prints the scooped item's name

 JMP MA60               \ We are done scooping, so jump down to MA60 to set the
                        \ kill flag on the canister, as it no longer exists in
                        \ the local bubble

.MA65

 JMP MA26               \ If we get here, then the ship we are processing was
                        \ too far away to be scooped, docked or collided with,
                        \ so jump to MA26 to skip over the collision routines
                        \ and move on to missile targeting

\ ******************************************************************************
\
\       Name: Main flight loop (Part 9 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: For each nearby ship: If it is a space station, check whether we
\             are successfully docking with it
\  Deep dive: Program flow of the main game loop
\             Docking checks
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Process docking with a space station
\
\ For details on the various docking checks in this routine, see the deep dive
\ on "Docking checks".
\
\ Other entry points:
\
\   GOIN                We jump here from part 3 of the main flight loop if the
\                       docking computer is activated by pressing "C"
\
\ ******************************************************************************

.ISDK

 LDA K%+NI%+32          \ 1. Fetch the AI counter (byte #32) of the second ship
 BMI MA62               \ in the ship data workspace at K%, which is reserved
                        \ for the sun or the space station (in this case it's
                        \ the latter), and if it's negative, i.e. bit 7 is set,
                        \ meaning the station is hostile, jump down to MA62 to
                        \ fail docking (so trying to dock at a station that we
                        \ have annoyed does not end well)

 LDA INWK+14            \ 2. If nosev_z_hi < 214, jump down to MA62 to fail
 CMP #214               \ docking, as the angle of approach is greater than 26
 BCC MA62               \ degrees

 JSR SPS4               \ Call SPS4 to get the vector to the space station
                        \ into XX15

 LDA XX15+2             \ 3. Check the sign of the z-axis (bit 7 of XX15+2) and
 BMI MA62               \ if it is negative, we are facing away from the
                        \ station, so jump to MA62 to fail docking

 CMP #89                \ 4. If z-axis < 89, jump to MA62 to fail docking, as
 BCC MA62               \ we are not in the 22.0 degree safe cone of approach

 LDA INWK+16            \ 5. If |roofv_x_hi| < 80, jump to MA62 to fail docking,
 AND #%01111111         \ as the slot is more than 36.6 degrees from horizontal
 CMP #80
 BCC MA62

.GOIN

                        \ If we arrive here, either the docking computer has
                        \ been activated, or we just docked successfully

 LDA #0                 \ Set the on-screen hyperspace counter to 0
 STA QQ22+1

 LDA #8                 \ This instruction has no effect, so presumably it used
                        \ to do something, and didn't get removed

 JSR LAUN               \ Show the space station launch tunnel

 JSR RES4               \ Reset the shields and energy banks, stardust and INWK
                        \ workspace

 JMP BAY                \ Go to the docking bay (i.e. show the Status Mode
                        \ screen)

.MA62

                        \ If we arrive here, docking has just failed

 LDA DELTA              \ If the ship's speed is < 5, jump to MA67 to register
 CMP #5                 \ some damage, but not a huge amount
 BCC MA67

 JMP DEATH              \ Otherwise we have just crashed into the station, so
                        \ process our death

\ ******************************************************************************
\
\       Name: Main flight loop (Part 10 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: For each nearby ship: Remove if scooped, or process collisions
\  Deep dive: Program flow of the main game loop
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Continue looping through all the ships in the local bubble, and for each
\     one:
\
\     * Remove scooped item after both successful and failed scoopings
\
\     * Process collisions
\
\ ******************************************************************************

.MA59

                        \ If we get here then scooping failed

 JSR EXNO3              \ Make the sound of the cargo canister being destroyed
                        \ and fall through into MA60 to remove the canister
                        \ from our local bubble

.MA60

                        \ If we get here then scooping was successful

 ASL INWK+31            \ Set bit 7 of the scooped or destroyed item, to denote
 SEC                    \ that it has been killed and should be removed from
 ROR INWK+31            \ the local bubble

.MA61                   \ This label is not used but is in the original source

 BNE MA26               \ Jump to MA26 to skip over the collision routines and
                        \ to move on to missile targeting (this BNE is
                        \ effectively a JMP as A will never be zero)

.MA67

                        \ If we get here then we have collided with something,
                        \ but not fatally

 LDA #1                 \ Set the speed in DELTA to 1 (i.e. a sudden stop)
 STA DELTA

 LDA #5                 \ Set the amount of damage in A to 5 (a small dent) and
 BNE MA63               \ jump down to MA63 to process the damage (this BNE is
                        \ effectively a JMP as A will never be zero)

.MA58

                        \ If we get here, we have collided with something in a
                        \ potentially fatal way

 ASL INWK+31            \ Set bit 7 of the ship we just collided with, to
 SEC                    \ denote that it has been killed and should be removed
 ROR INWK+31            \ from the local bubble

 LDA INWK+35            \ Load A with the energy level of the ship we just hit

 SEC                    \ Set the amount of damage in A to 128 + A / 2, so
 ROR A                  \ this is quite a big dent, and colliding with higher
                        \ energy ships will cause more damage

.MA63

 JSR OOPS               \ The amount of damage is in A, so call OOPS to reduce
                        \ our shields, and if the shields are gone, there's a
                        \ a chance of cargo loss or even death

 JSR EXNO3              \ Make the sound of colliding with the other ship and
                        \ fall through into MA26 to try targeting a missile

\ ******************************************************************************
\
\       Name: Main flight loop (Part 11 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: For each nearby ship: Process missile lock and firing our laser
\  Deep dive: Program flow of the main game loop
\             Flipping axes between space views
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Continue looping through all the ships in the local bubble, and for each
\     one:
\
\     * If this is not the front space view, flip the axes of the ship's
\        coordinates in INWK
\
\     * Process missile lock
\
\     * Process our laser firing
\
\ ******************************************************************************

.MA26

 LDA QQ11               \ If this is not a space view, jump to MA15 to skip
 BNE MA15               \ missile and laser locking

 JSR PLUT               \ Call PLUT to update the geometric axes in INWK to
                        \ match the view (front, rear, left, right)

 JSR HITCH              \ Call HITCH to see if this ship is in the crosshairs,
 BCC MA8                \ in which case the C flag will be set (so if there is
                        \ no missile or laser lock, we jump to MA8 to skip the
                        \ following)

 LDA MSAR               \ We have missile lock, so check whether the leftmost
 BEQ MA47               \ missile is currently armed, and if not, jump to MA47
                        \ to process laser fire, as we can't lock an unarmed
                        \ missile

 JSR BEEP               \ We have missile lock and an armed missile, so call
                        \ the BEEP subroutine to make a short, high beep

 LDX XSAV               \ Call ABORT2 to store the details of this missile
 LDY #&11               \ lock, with the targeted ship's slot number in X
 JSR ABORT2             \ (which we stored in XSAV at the start of this ship's
                        \ loop at MAL1), and set the colour of the missile
                        \ indicator to the colour in Y (red = &0E) ???

.MA47

                        \ If we get here then the ship is in our sights, but
                        \ we didn't lock a missile, so let's see if we're
                        \ firing the laser

 LDA LAS                \ If we are firing the laser then LAS will contain the
 BEQ MA8                \ laser power (which we set in MA68 above), so if this
                        \ is zero, jump down to MA8 to skip the following

 LDX #15                \ We are firing our laser and the ship in INWK is in
 JSR EXNO               \ the crosshairs, so call EXNO to make the sound of
                        \ us making a laser strike on another ship

 LDA INWK+35            \ Fetch the hit ship's energy from byte #35 and subtract
 SEC                    \ our current laser power, and if the result is greater
 SBC LAS                \ than zero, the other ship has survived the hit, so
 BCS MA14               \ jump down to MA14

 LDA TYPE               \ Did we just hit the space station? If so, jump to
 CMP #SST               \ MA14+2 to make the station hostile, skipping the
 BEQ MA14+2             \ following as we can't destroy a space station

 LDA INWK+31            \ Set bit 7 of the enemy ship's byte #31, to indicate
 ORA #%10000000         \ that it has been killed
 STA INWK+31

 BCS MA8                \ If the enemy ship type is >= SST (i.e. missile,
                        \ asteroid, canister, Thargon or escape pod) then
                        \ jump down to MA8

 JSR DORND              \ Fetch a random number, and jump to oh if it is
 BPL oh                 \ positive (50% chance)

 LDY #0                 \ Fetch the first byte of the hit ship's blueprint,
 AND (XX0),Y            \ which determines the maximum number of bits of
                        \ debris shown when the ship is destroyed, and AND
                        \ with the random number we just fetched

 STA CNT                \ Store the result in CNT, so CNT contains a random
                        \ number between 0 and the maximum number of bits of
                        \ debris that this ship will release when destroyed

.um

 BEQ oh                 \ We're going to go round a loop using CNT as a counter
                        \ so this checks whether the counter is zero and jumps
                        \ to oh when it gets there (which might be straight
                        \ away)

 LDX #OIL               \ Call SFS1 to spawn a cargo canister from the now
 LDA #0                 \ deceased parent ship, giving the spawned canister an
 JSR SFS1               \ AI flag of 0 (no AI, no E.C.M., non-hostile)

 DEC CNT                \ Decrease the loop counter

 BPL um                 \ Jump back up to um (this BPL is effectively a JMP as
                        \ CNT will never be negative)

.oh

 JSR EXNO2              \ Call EXNO2 to process the fact that we have killed a
                        \ ship (so increase the kill tally, make an explosion
                        \ sound and so on)

.MA14

 STA INWK+35            \ Store the hit ship's updated energy in ship byte #35

 LDA TYPE               \ Call ANGRY to make this ship hostile, now that we
 JSR ANGRY              \ have hit it

\ ******************************************************************************
\
\       Name: Main flight loop (Part 12 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: For each nearby ship: Draw the ship, remove if killed, loop back
\  Deep dive: Program flow of the main game loop
\             Drawing ships
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Continue looping through all the ships in the local bubble, and for each
\     one:
\
\     * Draw the ship
\
\     * Process removal of killed ships
\
\   * Loop back up to MAL1 to move onto the next ship in the local bubble
\
\ ******************************************************************************

.MA8

 JSR LL9                \ Call LL9 to draw the ship we're processing on-screen

.MA15

 LDY #35                \ Fetch the ship's energy from byte #35 and copy it to
 LDA INWK+35            \ byte #35 in INF (so the ship's data in K% gets
 STA (INF),Y            \ updated)

 LDA INWK+31            \ If bit 7 of the ship's byte #31 is clear, then the
 BPL MAC1               \ ship hasn't been killed by energy bomb, collision or
                        \ laser fire, so jump to MAC1 to skip the following

 AND #%00100000         \ If bit 5 of the ship's byte #31 is clear then the
 BEQ NBOUN              \ ship is no longer exploding, so jump to NBOUN to skip
                        \ the following

 LDA TYPE               \ If the ship we just destroyed was a cop, keep going,
 CMP #COPS              \ otherwise jump to q2 to skip the following
 BNE q2

 LDA FIST               \ We shot the sheriff, so update our FIST flag
 ORA #64                \ ("fugitive/innocent status") to at least 64, which
 STA FIST               \ will instantly make us a fugitive

.q2

 LDA DLY                \ ???
 BNE KS1S

 LDY #10                \ Fetch byte #10 of the ship's blueprint, which is the
 LDA (XX0),Y            \ low byte of the bounty awarded when this ship is
 BEQ KS1S               \ killed (in Cr * 10), and if it's zero jump to KS1S as
                        \ there is no on-screen bounty to display

 TAX                    \ Put the low byte of the bounty into X

 INY                    \ Fetch byte #11 of the ship's blueprint, which is the
 LDA (XX0),Y            \ high byte of the bounty awarded (in Cr * 10), and put
 TAY                    \ it into Y

 JSR MCASH              \ Call MCASH to add (Y X) to the cash pot

 LDA #0                 \ Print control code 0 (current cash, right-aligned to
 JSR MESS               \ width 9, then " CR", newline) as an in-flight message

.KS1S

 JMP KS1                \ Process the killing of this ship (which removes this
                        \ ship from its slot and shuffles all the other ships
                        \ down to close up the gap)

.NBOUN

.MAC1

 LDA TYPE               \ If the ship we are processing is a planet or sun,
 BMI MA27               \ jump to MA27 to skip the following two instructions

 JSR FAROF              \ If the ship we are processing is a long way away (its
 BCC KS1S               \ distance in any one direction is > 224, jump to KS1S
                        \ to remove the ship from our local bubble, as it's just
                        \ left the building

.MA27

 LDY #31                \ Fetch the ship's explosion/killed state from byte #31
 LDA INWK+31            \ and copy it to byte #31 in INF (so the ship's data in
 STA (INF),Y            \ K% gets updated)

 LDX XSAV               \ We're done processing this ship, so fetch the ship's
                        \ slot number, which we saved in XSAV back at the start
                        \ of the loop

 INX                    \ Increment the slot number to move on to the next slot

 JMP MAL1               \ And jump back up to the beginning of the loop to get
                        \ the next ship in the local bubble for processing

\ ******************************************************************************
\
\       Name: Main flight loop (Part 13 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: Show energy bomb effect, charge shields and energy banks
\  Deep dive: Program flow of the main game loop
\             Scheduling tasks with the main loop counter
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Show energy bomb effect (if applicable)
\
\   * Charge shields and energy banks (every 7 iterations of the main loop)
\
\ ******************************************************************************

.MA18

 LDA BOMB               \ If we set off our energy bomb by pressing TAB (see
 BPL MA77               \ MA24 above), then BOMB is now negative, so this skips
                        \ to MA77 if our energy bomb is not going off

 ASL BOMB               \ We set off our energy bomb, so rotate BOMB to the
                        \ left by one place. BOMB was rotated left once already
                        \ during this iteration of the main loop, back at MA24,
                        \ so if this is the first pass it will already be
                        \ %11111110, and this will shift it to %11111100 - so
                        \ if we set off an energy bomb, it stays activated
                        \ (BOMB > 0) for four iterations of the main loop

.MA77

 LDA MCNT               \ Fetch the main loop counter and calculate MCNT mod 7,
 AND #7                 \ jumping to MA22 if it is non-zero (so the following
 BNE MA22               \ code only runs every 8 iterations of the main loop)

 LDX ENERGY             \ Fetch our ship's energy levels and skip to b if bit 7
 BPL b                  \ is not set, i.e. only charge the shields from the
                        \ energy banks if they are at more than 50% charge

 LDX ASH                \ Call SHD to recharge our aft shield and update the
 JSR SHD                \ shield status in ASH
 STX ASH

 LDX FSH                \ Call SHD to recharge our forward shield and update
 JSR SHD                \ the shield status in FSH
 STX FSH

.b

 SEC                    \ Set A = ENERGY + ENGY + 1, so our ship's energy
 LDA ENGY               \ level goes up by 2 if we have an energy unit fitted,
 ADC ENERGY             \ otherwise it goes up by 1

 BCS P%+5               \ If the value of A did not overflow (the maximum
 STA ENERGY             \ energy level is &FF), then store A in ENERGY

\ ******************************************************************************
\
\       Name: Main flight loop (Part 14 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: Spawn a space station if we are close enough to the planet
\  Deep dive: Program flow of the main game loop
\             Scheduling tasks with the main loop counter
\             Ship data blocks
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Spawn a space station if we are close enough to the planet (every 32
\     iterations of the main loop)
\
\ ******************************************************************************

 LDA MCNT               \ Fetch the main loop counter and calculate MCNT mod 32,
 AND #31                \ jumping to MA93 if it is on-zero (so the following
 BNE MA93               \ code only runs every 32 iterations of the main loop

 LDA SSPR               \ If we are inside the space station safe zone, jump to
 BNE MA23S              \ MA23S to skip the following, as we already have a
                        \ space station and don't need another

 TAY                    \ Set Y = A = 0 (A is 0 as we didn't branch with the
                        \ previous BNE instruction)

 JSR MAS2               \ Call MAS2 to calculate the largest distance to the
 BNE MA23S              \ planet in any of the three axes, and if it's
                        \ non-zero, jump to MA23S to skip the following, as we
                        \ are too far from the planet to bump into a space
                        \ station

                        \ We now want to spawn a space station, so first we
                        \ need to set up a ship data block for the station in
                        \ INWK that we can then pass to NWSPS to add a new
                        \ station to our bubble of universe. We do this by
                        \ copying the planet data block from K% to INWK so we
                        \ can work on it, but we only need the first 29 bytes,
                        \ as we don't need to worry about bytes #29 to #35
                        \ for planets (as they don't have rotation counters,
                        \ AI, explosions, missiles, a ship line heap or energy
                        \ levels)

 LDX #28                \ So we set a counter in X to copy 29 bytes from K%+0
                        \ to K%+28

.MAL4

 LDA K%,X               \ Load the X-th byte of K% and store in the X-th byte
 STA INWK,X             \ of the INWK workspace

 DEX                    \ Decrement the loop counter

 BPL MAL4               \ Loop back for the next byte until we have copied the
                        \ first 28 bytes of K% to INWK

                        \ We now check the distance from our ship (at the
                        \ origin) towards the planet's surface, by adding the
                        \ planet's nosev vector to the planet's centre at
                        \ (x, y, z) and checking our distance to the end
                        \ point along the relevant axis

 INX                    \ Set X = 0 (as we ended the above loop with X as &FF)

 LDY #9                 \ Call MAS1 with X = 0, Y = 9 to do the following:
 JSR MAS1               \
                        \   (x_sign x_hi x_lo) += (nosev_x_hi nosev_x_lo) * 2
                        \
                        \   A = |x_hi|

 BNE MA23S              \ If A > 0, jump to MA23S to skip the following, as we
                        \ are too far from the planet in the x-direction to
                        \ bump into a space station

 LDX #3                 \ Call MAS1 with X = 3, Y = 11 to do the following:
 LDY #11                \
 JSR MAS1               \   (y_sign y_hi y_lo) += (nosev_y_hi nosev_y_lo) * 2
                        \
                        \   A = |y_hi|

 BNE MA23S              \ If A > 0, jump to MA23S to skip the following, as we
                        \ are too far from the planet in the y-direction to
                        \ bump into a space station

 LDX #6                 \ Call MAS1 with X = 6, Y = 13 to do the following:
 LDY #13                \
 JSR MAS1               \   (z_sign z_hi z_lo) += (nosev_z_hi nosev_z_lo) * 2
                        \
                        \   A = |z_hi|

 BNE MA23S              \ If A > 0, jump to MA23S to skip the following, as we
                        \ are too far from the planet in the z-direction to
                        \ bump into a space station

 LDA #192               \ Call FAROF2 to compare x_hi, y_hi and z_hi with 192,
 JSR FAROF2             \ which will set the C flag if all three are < 192, or
                        \ clear the C flag if any of them are >= 192

 BCC MA23S              \ Jump to MA23S if any one of x_hi, y_hi or z_hi are
                        \ >= 192 (i.e. they must all be < 192 for us to be near
                        \ enough to the planet to bump into a space station)

 JSR NWSPS              \ Add a new space station to our local bubble of
                        \ universe

.MA23S

 JMP MA23               \ Jump to MA23 to skip the following planet and sun
                        \ altitude checks

\ ******************************************************************************
\
\       Name: Main flight loop (Part 15 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: Perform altitude checks with planet and sun, process fuel scooping
\  Deep dive: Program flow of the main game loop
\             Scheduling tasks with the main loop counter
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Perform an altitude check with the planet (every 32 iterations of the main
\     loop, on iteration 10 of each 32)
\
\   * Perform an an altitude check with the sun and process fuel scooping (every
\     32 iterations of the main loop, on iteration 20 of each 32)
\
\ ******************************************************************************

.MA22

 LDA MCNT               \ Fetch the main loop counter and calculate MCNT mod 32,
 AND #31                \ which tells us the position of this loop in each block
                        \ of 32 iterations

.MA93

 CMP #10                \ If this is the tenth iteration in this block of 32,
 BNE MA29               \ do the following, otherwise jump to MA29 to skip the
                        \ planet altitude check and move on to the sun distance
                        \ check

 LDA #50                \ If our energy bank status in ENERGY is >= 50, skip
 CMP ENERGY             \ printing the following message (so the message is
 BCC P%+6               \ only shown if our energy is low)

 ASL A                  \ Print recursive token 100 ("ENERGY LOW{beep}") as an
 JSR MESS               \ in-flight message

 LDY #&FF               \ Set our altitude in ALTIT to &FF, the maximum
 STY ALTIT

 INY                    \ Set Y = 0

 JSR m                  \ Call m to calculate the maximum distance to the
                        \ planet in any of the three axes, returned in A

 BNE MA23               \ If A > 0 then we are a fair distance away from the
                        \ planet in at least one axis, so jump to MA23 to skip
                        \ the rest of the altitude check

 JSR MAS3               \ Set A = x_hi^2 + y_hi^2 + z_hi^2, so using Pythagoras
                        \ we now know that A now contains the square of the
                        \ distance between our ship (at the origin) and the
                        \ centre of the planet at (x_hi, y_hi, z_hi)

 BCS MA23               \ If the C flag was set by MAS3, then the result
                        \ overflowed (was greater than &FF) and we are still a
                        \ fair distance from the planet, so jump to MA23 as we
                        \ haven't crashed into the planet

 SBC #36                \ Subtract 36 from x_hi^2 + y_hi^2 + z_hi^2. The radius
                        \ of the planet is defined as 6 units and 6^2 = 36, so
                        \ A now contains the high byte of our altitude above
                        \ the planet surface, squared

 BCC MA28               \ If A < 0 then jump to MA28 as we have crashed into
                        \ the planet

 STA R                  \ We are getting close to the planet, so we need to
 JSR LL5                \ work out how close. We know from the above that A
                        \ contains our altitude squared, so we store A in R
                        \ and call LL5 to calculate:
                        \
                        \   Q = SQRT(R Q) = SQRT(A Q)
                        \
                        \ Interestingly, Q doesn't appear to be set to 0 for
                        \ this calculation, so presumably this doesn't make a
                        \ difference

 LDA Q                  \ Store the result in ALTIT, our altitude
 STA ALTIT

 BNE MA23               \ If our altitude is non-zero then we haven't crashed,
                        \ so jump to MA23 to skip to the next section

.MA28

 JMP DEATH              \ If we get here then we just crashed into the planet
                        \ or got too close to the sun, so call DEATH to start
                        \ the funeral preparations

.MA29

\ ******************************************************************************
\
\       Name: Main flight loop (Part 16 of 16)
\       Type: Subroutine
\   Category: Main loop
\    Summary: Process laser pulsing, E.C.M. energy drain, call stardust routine
\  Deep dive: Program flow of the main game loop
\
\ ------------------------------------------------------------------------------
\
\ The main flight loop covers most of the flight-specific aspects of Elite. This
\ section covers the following:
\
\   * Process laser pulsing
\
\   * Process E.C.M. energy drain
\
\   * Jump to the stardust routine if we are in a space view
\
\   * Return from the main flight loop
\
\ ******************************************************************************

.MA23

 LDA LAS2               \ If the current view has no laser, jump to MA16 to skip
 BEQ MA16               \ the following

 LDA LASCT              \ If LASCT >= 8, jump to MA16 to skip the following, so
 CMP #8                 \ for a pulse laser with a LASCT between 8 and 10, the
 BCS MA16               \ the laser stays on, but for a LASCT of 7 or less it
                        \ gets turned off and stays off until LASCT reaches zero
                        \ and the next pulse can start (if the fire button is
                        \ still being pressed)
                        \
                        \ For pulse lasers, LASCT gets set to 10 in ma1 above,
                        \ and it decrements every vertical sync (50 times a
                        \ second), so this means it pulses five times a second,
                        \ with the laser being on for the first 3/10 of each
                        \ pulse and off for the rest of the pulse
                        \
                        \ If this is a beam laser, LASCT is 0 so we always keep
                        \ going here. This means the laser doesn't pulse, but it
                        \ does get drawn and removed every cycle, in a slightly
                        \ different place each time, so the beams still flicker
                        \ around the screen

 JSR LASLI2             \ Redraw the existing laser lines, which has the effect
                        \ of removing them from the screen

 LDA #0                 \ Set LAS2 to 0 so if this is a pulse laser, it will
 STA LAS2               \ skip over the above until the next pulse (this has no
                        \ effect if this is a beam laser)

.MA16

 LDA ECMP               \ If our E.C.M is not on, skip to MA69, otherwise keep
 BEQ MA69               \ going to drain some energy

 JSR DENGY              \ Call DENGY to deplete our energy banks by 1

 BEQ MA70               \ If we have no energy left, jump to MA70 to turn our
                        \ E.C.M. off

.MA69

 LDA ECMA               \ If an E.C.M is going off (our's or an opponent's) then
 BEQ MA66               \ keep going, otherwise skip to MA66

 DEC ECMA               \ ???
 DEC ECMA               \ Decrement the E.C.M. countdown timer, and if it has
 BNE MA66               \ reached zero, keep going, otherwise skip to MA66

.MA70

 JSR ECMOF              \ If we get here then either we have either run out of
                        \ energy, or the E.C.M. timer has run down, so switch
                        \ off the E.C.M.

.MA66

 LDA QQ11               \ If this is not a space view (i.e. QQ11 is non-zero)
 BNE MA9                \ then jump to MA9 to return from the main flight loop
                        \ (as MA9 is an RTS)

 JMP STARS              \ This is a space view, so jump to the STARS routine to
                        \ process the stardust, and return from the main flight
                        \ loop using a tail call

\ ******************************************************************************
\
\       Name: MAS1
\       Type: Subroutine
\   Category: Maths (Geometry)
\    Summary: Add an orientation vector coordinate to an INWK coordinate
\
\ ------------------------------------------------------------------------------
\
\ Add a doubled nosev vector coordinate, e.g. (nosev_y_hi nosev_y_lo) * 2, to
\ an INWK coordinate, e.g. (x_sign x_hi x_lo), storing the result in the INWK
\ coordinate. The axes used in each side of the addition are specified by the
\ arguments X and Y.
\
\ In the comments below, we document the routine as if we are doing the
\ following, i.e. if X = 0 and Y = 11:
\
\   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (nosev_y_hi nosev_y_lo) * 2
\
\ as that way the variable names in the comments contain "x" and "y" to match
\ the registers that specify the vector axis to use.
\
\ Arguments:
\
\   X                   The coordinate to add, as follows:
\
\                         * If X = 0, add (x_sign x_hi x_lo)
\                         * If X = 3, add (y_sign y_hi y_lo)
\                         * If X = 6, add (z_sign z_hi z_lo)
\
\   Y                   The vector to add, as follows:
\
\                         * If Y = 9,  add (nosev_x_hi nosev_x_lo)
\                         * If Y = 11, add (nosev_y_hi nosev_y_lo)
\                         * If Y = 13, add (nosev_z_hi nosev_z_lo)
\
\ Returns:
\
\   A                   The high byte of the result with the sign cleared (e.g.
\                       |x_hi| if X = 0, etc.)
\
\ Other entry points:
\
\   MA9                 Contains an RTS
\
\ ******************************************************************************

.MAS1

 LDA INWK,Y             \ Set K(2 1) = (nosev_y_hi nosev_y_lo) * 2
 ASL A
 STA K+1
 LDA INWK+1,Y
 ROL A
 STA K+2

 LDA #0                 \ Set K+3 bit 7 to the C flag, so the sign bit of the
 ROR A                  \ above result goes into K+3
 STA K+3

 JSR MVT3               \ Add (x_sign x_hi x_lo) to K(3 2 1)

 STA INWK+2,X           \ Store the sign of the result in x_sign

 LDY K+1                \ Store K(2 1) in (x_hi x_lo)
 STY INWK,X
 LDY K+2
 STY INWK+1,X

 AND #%01111111         \ Set A to the sign byte with the sign cleared

.MA9

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MAS2
\       Type: Subroutine
\   Category: Maths (Geometry)
\    Summary: Calculate a cap on the maximum distance to the planet or sun
\
\ ------------------------------------------------------------------------------
\
\ Given a value in Y that points to the start of a ship data block as an offset
\ from K%, calculate the following:
\
\   A = A OR x_sign OR y_sign OR z_sign
\
\ and clear the sign bit of the result. The K% workspace contains the ship data
\ blocks, so the offset in Y must be 0 or a multiple of NI% (as each block in
\ K% contains NI% bytes).
\
\ The result effectively contains a maximum cap of the three values (though it
\ might not be one of the three input values - it's just guaranteed to be
\ larger than all of them).
\
\ If Y = 0 and A = 0, then this calculates the maximum cap of the highest byte
\ containing the distance to the planet, as K%+2 = x_sign, K%+5 = y_sign and
\ K%+8 = z_sign (the first slot in the K% workspace represents the planet).
\
\ Arguments:
\
\   Y                   The offset from K% for the start of the ship data block
\                       to use
\
\ Returns:
\
\   A                   A OR K%+2+Y OR K%+5+Y OR K%+8+Y, with bit 7 cleared
\
\ Other entry points:
\
\   m                   Do not include A in the calculation
\
\ ******************************************************************************

.m

 LDA #0                 \ Set A = 0 and fall through into MAS2 to calculate the
                        \ OR of the three bytes at K%+2+Y, K%+5+Y and K%+8+Y

.MAS2

 ORA K%+2,Y             \ Set A = A OR x_sign OR y_sign OR z_sign
 ORA K%+5,Y
 ORA K%+8,Y

 AND #%01111111         \ Clear bit 7 in A

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MAS3
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate A = x_hi^2 + y_hi^2 + z_hi^2 in the K% block
\
\ ------------------------------------------------------------------------------
\
\ Given a value in Y that points to the start of a ship data block as an offset
\ from K%, calculate the following:
\
\   A = x_hi^2 + y_hi^2 + z_hi^2
\
\ returning A = &FF if the calculation overflows a one-byte result. The K%
\ workspace contains the ship data blocks, so the offset in Y must be 0 or a
\ multiple of NI% (as each block in K% contains NI% bytes).
\
\ Arguments:
\
\   Y                   The offset from K% for the start of the ship data block
\                       to use
\
\ Returns
\
\   A                   A = x_hi^2 + y_hi^2 + z_hi^2
\
\                       A = &FF if the calculation overflows a one-byte result
\
\ ******************************************************************************

.MAS3

 LDA K%+1,Y             \ Set (A P) = x_hi * x_hi
 JSR SQUA2

 STA R                  \ Store A (high byte of result) in R

 LDA K%+4,Y             \ Set (A P) = y_hi * y_hi
 JSR SQUA2

 ADC R                  \ Add A (high byte of second result) to R

 BCS MA30               \ If the addition of the two high bytes caused a carry
                        \ (i.e. they overflowed), jump to MA30 to return A = &FF

 STA R                  \ Store A (sum of the two high bytes) in R

 LDA K%+7,Y             \ Set (A P) = z_hi * z_hi
 JSR SQUA2

 ADC R                  \ Add A (high byte of third result) to R, so R now
                        \ contains the sum of x_hi^2 + y_hi^2 + z_hi^2

 BCC P%+4               \ If there is no carry, skip the following instruction
                        \ to return straight from the subroutine

.MA30

 LDA #&FF               \ The calculation has overflowed, so set A = &FF

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MVEIT (Part 1 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Tidy the orientation vectors
\  Deep dive: Program flow of the ship-moving routine
\             Scheduling tasks with the main loop counter
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Tidy the orientation vectors for one of the ship slots
\
\ Arguments:
\
\   INWK                The current ship/planet/sun's data block
\
\   XSAV                The slot number of the current ship/planet/sun
\
\   TYPE                The type of the current ship/planet/sun
\
\ ******************************************************************************

.MVEIT

 LDA INWK+31            \ If bits 5 or 7 of ship byte #31 are set, jump to MV30
 AND #%10100000         \ as the ship is either exploding or has been killed, so
 BNE MV30               \ we don't need to tidy its orientation vectors or apply
                        \ tactics

 LDA MCNT               \ Fetch the main loop counter

 EOR XSAV               \ Fetch the slot number of the ship we are moving, EOR
 AND #15                \ with the loop counter and apply mod 15 to the result.
 BNE MV3                \ The result will be zero when "counter mod 15" matches
                        \ the slot number, so this makes sure we call TIDY 12
                        \ times every 16 main loop iterations, like this:
                        \
                        \   Iteration 0, tidy the ship in slot 0
                        \   Iteration 1, tidy the ship in slot 1
                        \   Iteration 2, tidy the ship in slot 2
                        \     ...
                        \   Iteration 11, tidy the ship in slot 11
                        \   Iteration 12, do nothing
                        \   Iteration 13, do nothing
                        \   Iteration 14, do nothing
                        \   Iteration 15, do nothing
                        \   Iteration 16, tidy the ship in slot 0
                        \     ...
                        \
                        \ and so on

 JSR TIDY               \ Call TIDY to tidy up the orientation vectors, to
                        \ prevent the ship from getting elongated and out of
                        \ shape due to the imprecise nature of trigonometry
                        \ in assembly language

\ ******************************************************************************
\
\       Name: MVEIT (Part 2 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Call tactics routine, remove ship from scanner
\  Deep dive: Scheduling tasks with the main loop counter
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Apply tactics to ships with AI enabled (by calling the TACTICS routine)
\
\   * Remove the ship from the scanner, so we can move it
\
\ ******************************************************************************

.MV3

 LDX TYPE               \ If the type of the ship we are moving is positive,
 BPL P%+5               \ i.e. it is not a planet (types 128 and 130) or sun
                        \ (type 129), then skip the following instruction

 JMP MV40               \ This item is the planet or sun, so jump to MV40 to
                        \ move it, which ends by jumping back into this routine
                        \ at MV45 (after all the rotation, tactics and scanner
                        \ code, which we don't need to apply to planets or suns)

 LDA INWK+32            \ Fetch the ship's byte #32 (AI flag) into A

 BPL MV30               \ If bit 7 of the AI flag is clear, then if this is a
                        \ ship or missile it is dumb and has no AI, and if this
                        \ is the space station it is not hostile, so in both
                        \ cases skip the following as it has no tactics

 CPX #MSL               \ If the ship is a missile, skip straight to MV26 to
 BEQ MV26               \ call the TACTICS routine, as we do this every
                        \ iteration of the main loop for missiles only

 LDA MCNT               \ Fetch the main loop counter

 EOR XSAV               \ Fetch the slot number of the ship we are moving, EOR
 AND #7                 \ with the loop counter and apply mod 8 to the result.
 BNE MV30               \ The result will be zero when "counter mod 8" matches
                        \ the slot number mod 8, so this makes sure we call
                        \ TACTICS 12 times every 8 main loop iterations, like
                        \ this:
                        \
                        \   Iteration 0, apply tactics to slots 0 and 8
                        \   Iteration 1, apply tactics to slots 1 and 9
                        \   Iteration 2, apply tactics to slots 2 and 10
                        \   Iteration 3, apply tactics to slots 3 and 11
                        \   Iteration 4, apply tactics to slot 4
                        \   Iteration 5, apply tactics to slot 5
                        \   Iteration 6, apply tactics to slot 6
                        \   Iteration 7, apply tactics to slot 7
                        \   Iteration 8, apply tactics to slots 0 and 8
                        \     ...
                        \
                        \ and so on

.MV26

 JSR TACTICS            \ Call TACTICS to apply AI tactics to this ship

.MV30

 JSR SCAN               \ Draw the ship on the scanner, which has the effect of
                        \ removing it, as it's already at this point and hasn't
                        \ yet moved

\ ******************************************************************************
\
\       Name: MVEIT (Part 3 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Move ship forward according to its speed
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Move the ship forward (along the vector pointing in the direction of
\     travel) according to its speed:
\
\     (x, y, z) += nosev_hi * speed / 64
\
\ ******************************************************************************

 LDA INWK+27            \ Set Q = the ship's speed byte #27 * 4
 ASL A
 ASL A
 STA Q

 LDA INWK+10            \ Set A = |nosev_x_hi|
 AND #%01111111

 JSR FMLTU              \ Set R = A * Q / 256
 STA R                  \       = |nosev_x_hi| * speed / 64

 LDA INWK+10            \ If nosev_x_hi is positive, then:
 LDX #0                 \
 JSR MVT1-2             \   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + R
                        \
                        \ If nosev_x_hi is negative, then:
                        \
                        \   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) - R
                        \
                        \ So in effect, this does:
                        \
                        \   (x_sign x_hi x_lo) += nosev_x_hi * speed / 64

 LDA INWK+12            \ Set A = |nosev_y_hi|
 AND #%01111111

 JSR FMLTU              \ Set R = A * Q / 256
 STA R                  \       = |nosev_y_hi| * speed / 64

 LDA INWK+12            \ If nosev_y_hi is positive, then:
 LDX #3                 \
 JSR MVT1-2             \   (y_sign y_hi y_lo) = (y_sign y_hi y_lo) + R
                        \
                        \ If nosev_y_hi is negative, then:
                        \
                        \   (y_sign y_hi y_lo) = (y_sign y_hi y_lo) - R
                        \
                        \ So in effect, this does:
                        \
                        \   (y_sign y_hi y_lo) += nosev_y_hi * speed / 64

 LDA INWK+14            \ Set A = |nosev_z_hi|
 AND #%01111111

 JSR FMLTU              \ Set R = A * Q / 256
 STA R                  \       = |nosev_z_hi| * speed / 64

 LDA INWK+14            \ If nosev_y_hi is positive, then:
 LDX #6                 \
 JSR MVT1-2             \   (z_sign z_hi z_lo) = (z_sign z_hi z_lo) + R
                        \
                        \ If nosev_z_hi is negative, then:
                        \
                        \   (z_sign z_hi z_lo) = (z_sign z_hi z_lo) - R
                        \
                        \ So in effect, this does:
                        \
                        \   (z_sign z_hi z_lo) += nosev_z_hi * speed / 64

\ ******************************************************************************
\
\       Name: MVEIT (Part 4 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Apply acceleration to ship's speed as a one-off
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Apply acceleration to the ship's speed (if acceleration is non-zero),
\     and then zero the acceleration as it's a one-off change
\
\ ******************************************************************************

 LDA INWK+27            \ Set A = the ship's speed in byte #24 + the ship's
 CLC                    \ acceleration in byte #28
 ADC INWK+28

 BPL P%+4               \ If the result is positive, skip the following
                        \ instruction

 LDA #0                 \ Set A to 0 to stop the speed from going negative

 LDY #15                \ Fetch byte #15 from the ship's blueprint, which
                        \ contains the ship's maximum speed

 CMP (XX0),Y            \ If A < the ship's maximum speed, skip the following
 BCC P%+4               \ instruction

 LDA (XX0),Y            \ Set A to the ship's maximum speed

 STA INWK+27            \ We have now calculated the new ship's speed after
                        \ accelerating and keeping the speed within the ship's
                        \ limits, so store the updated speed in byte #27

 LDA #0                 \ We have added the ship's acceleration, so we now set
 STA INWK+28            \ it back to 0 in byte #28, as it's a one-off change

\ ******************************************************************************
\
\       Name: MVEIT (Part 5 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Rotate ship's location by our pitch and roll
\  Deep dive: Rotating the universe
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Rotate the ship's location in space by the amount of pitch and roll of
\     our ship. See below for a deeper explanation of this routine
\
\ ******************************************************************************

 LDX ALP1               \ Fetch the magnitude of the current roll into X, so
                        \ if the roll angle is alpha, X contains |alpha|

 LDA INWK               \ Set P = ~x_lo (i.e. with all its bits flipped) so that
 EOR #%11111111         \ we can pass x_lo to MLTU2 below)
 STA P

 LDA INWK+1             \ Set A = x_hi

 JSR MLTU2-2            \ Set (A P+1 P) = (A ~P) * X
                        \               = (x_hi x_lo) * alpha

 STA P+2                \ Store the high byte of the result in P+2, so we now
                        \ have:
                        \
                        \ P(2 1 0) = (x_hi x_lo) * alpha

 LDA ALP2+1             \ Fetch the flipped sign of the current roll angle alpha
 EOR INWK+2             \ from ALP2+1 and EOR with byte #2 (x_sign), so if the
                        \ flipped roll angle and x_sign have the same sign, A
                        \ will be positive, else it will be negative. So A will
                        \ contain the sign bit of x_sign * flipped alpha sign,
                        \ which is the opposite to the sign of the above result,
                        \ so we now have:
                        \
                        \ (A P+2 P+1) = - (x_sign x_hi x_lo) * alpha / 256

 LDX #3                 \ Set (A P+2 P+1) = (y_sign y_hi y_lo) + (A P+2 P+1)
 JSR MVT6               \                 = y - x * alpha / 256

 STA K2+3               \ Set K2(3) = A = the sign of the result

 LDA P+1                \ Set K2(1) = P+1, the low byte of the result
 STA K2+1

 EOR #%11111111         \ Set P = ~K2+1 (i.e. with all its bits flipped) so
 STA P                  \ that we can pass K2+1 to MLTU2 below)

 LDA P+2                \ Set K2(2) = A = P+2
 STA K2+2

                        \ So we now have result 1 above:
                        \
                        \ K2(3 2 1) = (A P+2 P+1)
                        \           = y - x * alpha / 256

 LDX BET1               \ Fetch the magnitude of the current pitch into X, so
                        \ if the pitch angle is beta, X contains |beta|

 JSR MLTU2-2            \ Set (A P+1 P) = (A ~P) * X
                        \               = K2(2 1) * beta

 STA P+2                \ Store the high byte of the result in P+2, so we now
                        \ have:
                        \
                        \ P(2 1 0) = K2(2 1) * beta

 LDA K2+3               \ Fetch the sign of the above result in K(3 2 1) from
 EOR BET2               \ K2+3 and EOR with BET2, the sign of the current pitch
                        \ rate, so if the pitch and K(3 2 1) have the same sign,
                        \ A will be positive, else it will be negative. So A
                        \ will contain the sign bit of K(3 2 1) * beta, which is
                        \ the same as the sign of the above result, so we now
                        \ have:
                        \
                        \ (A P+2 P+1) = K2(3 2 1) * beta / 256

 LDX #6                 \ Set (A P+2 P+1) = (z_sign z_hi z_lo) + (A P+2 P+1)
 JSR MVT6               \                 = z + K2 * beta / 256

 STA INWK+8             \ Set z_sign = A = the sign of the result

 LDA P+1                \ Set z_lo = P+1, the low byte of the result
 STA INWK+6

 EOR #%11111111         \ Set P = ~z_lo (i.e. with all its bits flipped) so that
 STA P                  \ we can pass z_lo to MLTU2 below)

 LDA P+2                \ Set z_hi = P+2
 STA INWK+7

                        \ So we now have result 2 above:
                        \
                        \ (z_sign z_hi z_lo) = (A P+2 P+1)
                        \                    = z + K2 * beta / 256

 JSR MLTU2              \ MLTU2 doesn't change Q, and Q was set to beta in
                        \ the previous call to MLTU2, so this call does:
                        \
                        \ (A P+1 P) = (A ~P) * Q
                        \           = (z_hi z_lo) * beta

 STA P+2                \ Set P+2 = A = the high byte of the result, so we
                        \ now have:
                        \
                        \ P(2 1 0) = (z_hi z_lo) * beta

 LDA K2+3               \ Set y_sign = K2+3
 STA INWK+5

 EOR BET2               \ EOR y_sign with BET2, the sign of the current pitch
 EOR INWK+8             \ rate, and z_sign. If the result is positive jump to
 BPL MV43               \ MV43, otherwise this means beta * z and y have
                        \ different signs, i.e. P(2 1) and K2(3 2 1) have
                        \ different signs, so we need to add them in order to
                        \ calculate K2(2 1) - P(2 1)

 LDA P+1                \ Set (y_hi y_lo) = K2(2 1) + P(2 1)
 ADC K2+1
 STA INWK+3
 LDA P+2
 ADC K2+2
 STA INWK+4

 JMP MV44               \ Jump to MV44 to continue the calculation

.MV43

 LDA K2+1               \ Reversing the logic above, we need to subtract P(2 1)
 SBC P+1                \ and K2(3 2 1) to calculate K2(2 1) - P(2 1), so this
 STA INWK+3             \ sets (y_hi y_lo) = K2(2 1) - P(2 1)
 LDA K2+2
 SBC P+2
 STA INWK+4

 BCS MV44               \ If the above subtraction did not underflow, then
                        \ jump to MV44, otherwise we need to negate the result

 LDA #1                 \ Negate (y_sign y_hi y_lo) using two's complement,
 SBC INWK+3             \ first doing the low bytes:
 STA INWK+3             \
                        \ y_lo = 1 - y_lo

 LDA #0                 \ Then the high bytes:
 SBC INWK+4             \
 STA INWK+4             \ y_hi = 0 - y_hi

 LDA INWK+5             \ And finally flip the sign in y_sign
 EOR #%10000000
 STA INWK+5

.MV44

                        \ So we now have result 3 above:
                        \
                        \ (y_sign y_hi y_lo) = K2(2 1) - P(2 1)
                        \                    = K2 - beta * z

 LDX ALP1               \ Fetch the magnitude of the current roll into X, so
                        \ if the roll angle is alpha, X contains |alpha|

 LDA INWK+3             \ Set P = ~y_lo (i.e. with all its bits flipped) so that
 EOR #&FF               \ we can pass y_lo to MLTU2 below)
 STA P

 LDA INWK+4             \ Set A = y_hi

 JSR MLTU2-2            \ Set (A P+1 P) = (A ~P) * X
                        \               = (y_hi y_lo) * alpha

 STA P+2                \ Store the high byte of the result in P+2, so we now
                        \ have:
                        \
                        \ P(2 1 0) = (y_hi y_lo) * alpha

 LDA ALP2               \ Fetch the correct sign of the current roll angle alpha
 EOR INWK+5             \ from ALP2 and EOR with byte #5 (y_sign), so if the
                        \ correct roll angle and y_sign have the same sign, A
                        \ will be positive, else it will be negative. So A will
                        \ contain the sign bit of x_sign * correct alpha sign,
                        \ which is the same as the sign of the above result,
                        \ so we now have:
                        \
                        \ (A P+2 P+1) = (y_sign y_hi y_lo) * alpha / 256

 LDX #0                 \ Set (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1)
 JSR MVT6               \                 = x + y * alpha / 256

 STA INWK+2             \ Set x_sign = A = the sign of the result

 LDA P+2                \ Set x_hi = P+2, the high byte of the result
 STA INWK+1

 LDA P+1                \ Set x_lo = P+1, the low byte of the result
 STA INWK

                        \ So we now have result 4 above:
                        \
                        \ x = x + alpha * y
                        \
                        \ and the rotation of (x, y, z) is done

\ ******************************************************************************
\
\       Name: MVEIT (Part 6 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Move the ship in space according to our speed
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Move the ship in space according to our speed (we already moved it
\     according to its own speed in part 3).
\
\ We do this by subtracting our speed (i.e. the distance we travel in this
\ iteration of the loop) from the other ship's z-coordinate. We subtract because
\ they appear to be "moving" in the opposite direction to us, and the whole
\ MVEIT routine is about moving the other ships rather than us (even though we
\ are the one doing the moving).
\
\ Other entry points:
\
\   MV45                Rejoin the MVEIT routine after the rotation, tactics and
\                       scanner code
\
\ ******************************************************************************

.MV45

 LDA DELTA              \ Set R to our speed in DELTA
 STA R

 LDA #%10000000         \ Set A to zeroes but with bit 7 set, so that (A R) is
                        \ a 16-bit number containing -R, or -speed

 LDX #6                 \ Set X to the z-axis so the call to MVT1 does this:
 JSR MVT1               \
                        \ (z_sign z_hi z_lo) = (z_sign z_hi z_lo) + (A R)
                        \                    = (z_sign z_hi z_lo) - speed

\ ******************************************************************************
\
\       Name: MVEIT (Part 7 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Rotate ship's orientation vectors by pitch/roll
\  Deep dive: Orientation vectors
\             Pitching and rolling
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * Rotate the ship's orientation vectors according to our pitch and roll
\
\ As with the previous step, this is all about moving the other ships rather
\ than us (even though we are the one doing the moving). So we rotate the
\ current ship's orientation vectors (which defines its orientation in space),
\ by the angles we are "moving" the rest of the sky through (alpha and beta, our
\ roll and pitch), so the ship appears to us to be stationary while we rotate.
\
\ ******************************************************************************

 LDY #9                 \ Apply our pitch and roll rotations to the current
 JSR MVS4               \ ship's nosev vector

 LDY #15                \ Apply our pitch and roll rotations to the current
 JSR MVS4               \ ship's roofv vector

 LDY #21                \ Apply our pitch and roll rotations to the current
 JSR MVS4               \ ship's sidev vector

\ ******************************************************************************
\
\       Name: MVEIT (Part 8 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Rotate ship about itself by its own pitch/roll
\  Deep dive: Orientation vectors
\             Pitching and rolling by a fixed angle
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * If the ship we are processing is rolling or pitching itself, rotate it and
\     apply damping if required
\
\ ******************************************************************************

 LDA INWK+30            \ Fetch the ship's pitch counter and extract the sign
 AND #%10000000         \ into RAT2
 STA RAT2

 LDA INWK+30            \ Fetch the ship's pitch counter and extract the value
 AND #%01111111         \ without the sign bit into A

 BEQ MV8                \ If the pitch counter is 0, then jump to MV8 to skip
                        \ the following, as the ship is not pitching

 CMP #%01111111         \ If bits 0-6 are set in the pitch counter (i.e. the
                        \ ship's pitch is not damping down), then the C flag
                        \ will be set by this instruction

 SBC #0                 \ Set A = A - 0 - (1 - C), so if we are damping then we
                        \ reduce A by 1, otherwise it is unchanged

 ORA RAT2               \ Change bit 7 of A to the sign we saved in RAT2, so
                        \ the updated pitch counter in A retains its sign

 STA INWK+30            \ Store the updated pitch counter in byte #30

 LDX #15                \ Rotate (roofv_x, nosev_x) by a small angle (pitch)
 LDY #9
 JSR MVS5

 LDX #17                \ Rotate (roofv_y, nosev_y) by a small angle (pitch)
 LDY #11
 JSR MVS5

 LDX #19                \ Rotate (roofv_z, nosev_z) by a small angle (pitch)
 LDY #13
 JSR MVS5

.MV8

 LDA INWK+29            \ Fetch the ship's roll counter and extract the sign
 AND #%10000000         \ into RAT2
 STA RAT2

 LDA INWK+29            \ Fetch the ship's roll counter and extract the value
 AND #%01111111         \ without the sign bit into A

 BEQ MV5                \ If the roll counter is 0, then jump to MV5 to skip the
                        \ following, as the ship is not rolling

 CMP #%01111111         \ If bits 0-6 are set in the roll counter (i.e. the
                        \ ship's roll is not damping down), then the C flag
                        \ will be set by this instruction

 SBC #0                 \ Set A = A - 0 - (1 - C), so if we are damping then we
                        \ reduce A by 1, otherwise it is unchanged

 ORA RAT2               \ Change bit 7 of A to the sign we saved in RAT2, so
                        \ the updated roll counter in A retains its sign

 STA INWK+29            \ Store the updated pitch counter in byte #29

 LDX #15                \ Rotate (roofv_x, sidev_x) by a small angle (roll)
 LDY #21
 JSR MVS5

 LDX #17                \ Rotate (roofv_y, sidev_y) by a small angle (roll)
 LDY #23
 JSR MVS5

 LDX #19                \ Rotate (roofv_z, sidev_z) by a small angle (roll)
 LDY #25
 JSR MVS5

\ ******************************************************************************
\
\       Name: MVEIT (Part 9 of 9)
\       Type: Subroutine
\   Category: Moving
\    Summary: Move current ship: Redraw on scanner, if it hasn't been destroyed
\
\ ------------------------------------------------------------------------------
\
\ This routine has multiple stages. This stage does the following:
\
\   * If the ship is exploding or being removed, hide it on the scanner
\
\   * Otherwise redraw the ship on the scanner, now that it's been moved
\
\ ******************************************************************************

.MV5

 LDA INWK+31            \ Fetch the ship's exploding/killed state from byte #31

 AND #%10100000         \ If we are exploding or removing this ship then jump to
 BNE MVD1               \ MVD1 to remove it from the scanner permanently

 LDA INWK+31            \ Set bit 4 to keep the ship visible on the scanner
 ORA #%00010000
 STA INWK+31

 JMP SCAN               \ Display the ship on the scanner, returning from the
                        \ subroutine using a tail call

.MVD1

 LDA INWK+31            \ Clear bit 4 to hide the ship on the scanner
 AND #%11101111
 STA INWK+31

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MVT1
\       Type: Subroutine
\   Category: Moving
\    Summary: Calculate (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (A R)
\
\ ------------------------------------------------------------------------------
\
\ Add the signed delta (A R) to a ship's coordinate, along the axis given in X.
\ Mathematically speaking, this routine translates the ship along a single axis
\ by a signed delta. Taking the example of X = 0, the x-axis, it does the
\ following:
\
\   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (A R)
\
\ (In practice, MVT1 is only ever called directly with A = 0 or 128, otherwise
\ it is always called via MVT-2, which clears A apart from the sign bit. The
\ routine is written to cope with a non-zero delta_hi, so it supports a full
\ 16-bit delta, but it appears that delta_hi is only ever used to hold the
\ sign of the delta.)
\
\ The comments below assume we are adding delta to the x-axis, though the axis
\ is determined by the value of X.
\
\ Arguments:
\
\   (A R)               The signed delta, so A = delta_hi and R = delta_lo
\
\   X                   Determines which coordinate axis of INWK to change:
\
\                         * X = 0 adds the delta to (x_lo, x_hi, x_sign)
\
\                         * X = 3 adds the delta to (y_lo, y_hi, y_sign)
\
\                         * X = 6 adds the delta to (z_lo, z_hi, z_sign)
\
\ Other entry points:
\
\   MVT1-2              Clear bits 0-6 of A before entering MVT1
\
\ ******************************************************************************

 AND #%10000000         \ Clear bits 0-6 of A

.MVT1

 ASL A                  \ Set the C flag to the sign bit of the delta, leaving
                        \ delta_hi << 1 in A

 STA S                  \ Set S = delta_hi << 1
                        \
                        \ This also clears bit 0 of S

 LDA #0                 \ Set T = just the sign bit of delta (in bit 7)
 ROR A
 STA T

 LSR S                  \ Set S = delta_hi >> 1
                        \       = |delta_hi|
                        \
                        \ This also clear the C flag, as we know that bit 0 of
                        \ S was clear before the LSR

 EOR INWK+2,X           \ If T EOR x_sign has bit 7 set, then x_sign and delta
 BMI MV10               \ have different signs, so jump to MV10

                        \ At this point, we know x_sign and delta have the same
                        \ sign, that sign is in T, and S contains |delta_hi|,
                        \ so now we want to do:
                        \
                        \   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) + (S R)
                        \
                        \ and then set the sign of the result to the same sign
                        \ as x_sign and delta

 LDA R                  \ First we add the low bytes, so:
 ADC INWK,X             \
 STA INWK,X             \   x_lo = x_lo + R

 LDA S                  \ Then we add the high bytes:
 ADC INWK+1,X           \
 STA INWK+1,X           \   x_hi = x_hi + S

 LDA INWK+2,X           \ And finally we add any carry into x_sign, and if the
 ADC #0                 \ sign of x_sign and delta in T is negative, make sure
 ORA T                  \ the result is negative (by OR'ing with T)
 STA INWK+2,X

 RTS                    \ Return from the subroutine

.MV10

                        \ If we get here, we know x_sign and delta have
                        \ different signs, with delta's sign in T, and
                        \ |delta_hi| in S, so now we want to do:
                        \
                        \   (x_sign x_hi x_lo) = (x_sign x_hi x_lo) - (S R)
                        \
                        \ and then set the sign of the result according to
                        \ the signs of x_sign and delta

 LDA INWK,X             \ First we subtract the low bytes, so:
 SEC                    \
 SBC R                  \   x_lo = x_lo - R
 STA INWK,X

 LDA INWK+1,X           \ Then we subtract the high bytes:
 SBC S                  \
 STA INWK+1,X           \   x_hi = x_hi - S

 LDA INWK+2,X           \ And finally we subtract any borrow from bits 0-6 of
 AND #%01111111         \ x_sign, and give the result the opposite sign bit to T
 SBC #0                 \ (i.e. give it the sign of the original x_sign)
 ORA #%10000000
 EOR T
 STA INWK+2,X

 BCS MV11               \ If the C flag is set by the above SBC, then our sum
                        \ above didn't underflow and is correct - to put it
                        \ another way, (x_sign x_hi x_lo) >= (S R) so the result
                        \ should indeed have the same sign as x_sign, so jump to
                        \ MV11 to return from the subroutine

                        \ Otherwise our subtraction underflowed because
                        \ (x_sign x_hi x_lo) < (S R), so we now need to flip the
                        \ subtraction around by using two's complement to this:
                        \
                        \   (S R) - (x_sign x_hi x_lo)
                        \
                        \ and then we need to give the result the same sign as
                        \ (S R), the delta, as that's the dominant figure in the
                        \ sum

 LDA #1                 \ First we subtract the low bytes, so:
 SBC INWK,X             \
 STA INWK,X             \   x_lo = 1 - x_lo

 LDA #0                 \ Then we subtract the high bytes:
 SBC INWK+1,X           \
 STA INWK+1,X           \   x_hi = 0 - x_hi

 LDA #0                 \ And then we subtract the sign bytes:
 SBC INWK+2,X           \
                        \   x_sign = 0 - x_sign

 AND #%01111111         \ Finally, we set the sign bit to the sign in T, the
 ORA T                  \ sign of the original delta, as the delta is the
 STA INWK+2,X           \ dominant figure in the sum

.MV11

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MVT3
\       Type: Subroutine
\   Category: Moving
\    Summary: Calculate K(3 2 1) = (x_sign x_hi x_lo) + K(3 2 1)
\
\ ------------------------------------------------------------------------------
\
\ Add an INWK position coordinate - i.e. x, y or z - to K(3 2 1), like this:
\
\   K(3 2 1) = (x_sign x_hi x_lo) + K(3 2 1)
\
\ The INWK coordinate to add to K(3 2 1) is specified by X.
\
\ Arguments:
\
\   X                   The coordinate to add to K(3 2 1), as follows:
\
\                         * If X = 0, add (x_sign x_hi x_lo)
\
\                         * If X = 3, add (y_sign y_hi y_lo)
\
\                         * If X = 6, add (z_sign z_hi z_lo)
\
\ Returns:
\
\   A                   Contains a copy of the high byte of the result, K+3
\
\   X                   X is preserved
\
\ ******************************************************************************

.MVT3

 LDA K+3                \ Set S = K+3
 STA S

 AND #%10000000         \ Set T = sign bit of K(3 2 1)
 STA T

 EOR INWK+2,X           \ If x_sign has a different sign to K(3 2 1), jump to
 BMI MV13               \ MV13 to process the addition as a subtraction

 LDA K+1                \ Set K(3 2 1) = K(3 2 1) + (x_sign x_hi x_lo)
 CLC                    \ starting with the low bytes
 ADC INWK,X
 STA K+1

 LDA K+2                \ Then the middle bytes
 ADC INWK+1,X
 STA K+2

 LDA K+3                \ And finally the high bytes
 ADC INWK+2,X

 AND #%01111111         \ Setting the sign bit of K+3 to T, the original sign
 ORA T                  \ of K(3 2 1)
 STA K+3

 RTS                    \ Return from the subroutine

.MV13

 LDA S                  \ Set S = |K+3| (i.e. K+3 with the sign bit cleared)
 AND #%01111111
 STA S

 LDA INWK,X             \ Set K(3 2 1) = (x_sign x_hi x_lo) - K(3 2 1)
 SEC                    \ starting with the low bytes
 SBC K+1
 STA K+1

 LDA INWK+1,X           \ Then the middle bytes
 SBC K+2
 STA K+2

 LDA INWK+2,X           \ And finally the high bytes, doing A = |x_sign| - |K+3|
 AND #%01111111         \ and setting the C flag for testing below
 SBC S

 ORA #%10000000         \ Set the sign bit of K+3 to the opposite sign of T,
 EOR T                  \ i.e. the opposite sign to the original K(3 2 1)
 STA K+3

 BCS MV14               \ If the C flag is set, i.e. |x_sign| >= |K+3|, then
                        \ the sign of K(3 2 1). In this case, we want the
                        \ result to have the same sign as the largest argument,
                        \ which is (x_sign x_hi x_lo), which we know has the
                        \ opposite sign to K(3 2 1), and that's what we just set
                        \ the sign of K(3 2 1) to... so we can jump to MV14 to
                        \ return from the subroutine

 LDA #1                 \ We need to swap the sign of the result in K(3 2 1),
 SBC K+1                \ which we do by calculating 0 - K(3 2 1), which we can
 STA K+1                \ do with 1 - C - K(3 2 1), as we know the C flag is
                        \ clear. We start with the low bytes

 LDA #0                 \ Then the middle bytes
 SBC K+2
 STA K+2

 LDA #0                 \ And finally the high bytes
 SBC K+3

 AND #%01111111         \ Set the sign bit of K+3 to the same sign as T,
 ORA T                  \ i.e. the same sign as the original K(3 2 1), as
 STA K+3                \ that's the largest argument

.MV14

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MVS4
\       Type: Subroutine
\   Category: Moving
\    Summary: Apply pitch and roll to an orientation vector
\  Deep dive: Orientation vectors
\             Pitching and rolling
\
\ ------------------------------------------------------------------------------
\
\ Apply pitch and roll angles alpha and beta to the orientation vector in Y.
\
\ Specifically, this routine rotates a point (x, y, z) around the origin by
\ pitch alpha and roll beta, using the small angle approximation to make the
\ maths easier, and incorporating the Minsky circle algorithm to make the
\ rotation more stable (though more elliptic).
\
\ If that paragraph makes sense to you, then you should probably be writing
\ this commentary! For the rest of us, there's a detailed explanation of all
\ this in the deep dive on "Pitching and rolling".
\
\ Arguments:
\
\   Y                   Determines which of the INWK orientation vectors to
\                       transform:
\
\                         * Y = 9 rotates nosev: (nosev_x, nosev_y, nosev_z)
\
\                         * Y = 15 rotates roofv: (roofv_x, roofv_y, roofv_z)
\
\                         * Y = 21 rotates sidev: (sidev_x, sidev_y, sidev_z)
\
\ ******************************************************************************

.MVS4

 LDA ALPHA              \ Set Q = alpha (the roll angle to rotate through)
 STA Q

 LDX INWK+2,Y           \ Set (S R) = nosev_y
 STX R
 LDX INWK+3,Y
 STX S

 LDX INWK,Y             \ These instructions have no effect as MAD overwrites
 STX P                  \ X and P when called, but they set X = P = nosev_x_lo

 LDA INWK+1,Y           \ Set A = -nosev_x_hi
 EOR #%10000000

 JSR MAD                \ Set (A X) = Q * A + (S R)
 STA INWK+3,Y           \           = alpha * -nosev_x_hi + nosev_y
 STX INWK+2,Y           \
                        \ and store (A X) in nosev_y, so this does:
                        \
                        \ nosev_y = nosev_y - alpha * nosev_x_hi

 STX P                  \ This instruction has no effect as MAD overwrites P,
                        \ but it sets P = nosev_y_lo

 LDX INWK,Y             \ Set (S R) = nosev_x
 STX R
 LDX INWK+1,Y
 STX S

 LDA INWK+3,Y           \ Set A = nosev_y_hi

 JSR MAD                \ Set (A X) = Q * A + (S R)
 STA INWK+1,Y           \           = alpha * nosev_y_hi + nosev_x
 STX INWK,Y             \
                        \ and store (A X) in nosev_x, so this does:
                        \
                        \ nosev_x = nosev_x + alpha * nosev_y_hi

 STX P                  \ This instruction has no effect as MAD overwrites P,
                        \ but it sets P = nosev_x_lo

 LDA BETA               \ Set Q = beta (the pitch angle to rotate through)
 STA Q

 LDX INWK+2,Y           \ Set (S R) = nosev_y
 STX R
 LDX INWK+3,Y
 STX S
 LDX INWK+4,Y

 STX P                  \ This instruction has no effect as MAD overwrites P,
                        \ but it sets P = nosev_y

 LDA INWK+5,Y           \ Set A = -nosev_z_hi
 EOR #%10000000

 JSR MAD                \ Set (A X) = Q * A + (S R)
 STA INWK+3,Y           \           = beta * -nosev_z_hi + nosev_y
 STX INWK+2,Y           \
                        \ and store (A X) in nosev_y, so this does:
                        \
                        \ nosev_y = nosev_y - beta * nosev_z_hi

 STX P                  \ This instruction has no effect as MAD overwrites P,
                        \ but it sets P = nosev_y_lo

 LDX INWK+4,Y           \ Set (S R) = nosev_z
 STX R
 LDX INWK+5,Y
 STX S

 LDA INWK+3,Y           \ Set A = nosev_y_hi

 JSR MAD                \ Set (A X) = Q * A + (S R)
 STA INWK+5,Y           \           = beta * nosev_y_hi + nosev_z
 STX INWK+4,Y           \
                        \ and store (A X) in nosev_z, so this does:
                        \
                        \ nosev_z = nosev_z + beta * nosev_y_hi

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MVS5
\       Type: Subroutine
\   Category: Moving
\    Summary: Apply a 3.6 degree pitch or roll to an orientation vector
\  Deep dive: Orientation vectors
\             Pitching and rolling by a fixed angle
\
\ ------------------------------------------------------------------------------
\
\ Pitch or roll a ship by a small, fixed amount (1/16 radians, or 3.6 degrees),
\ in a specified direction, by rotating the orientation vectors. The vectors to
\ rotate are given in X and Y, and the direction of the rotation is given in
\ RAT2. The calculation is as follows:
\
\   * If the direction is positive:
\
\     X = X * (1 - 1/512) + Y / 16
\     Y = Y * (1 - 1/512) - X / 16
\
\   * If the direction is negative:
\
\     X = X * (1 - 1/512) - Y / 16
\     Y = Y * (1 - 1/512) + X / 16
\
\ So if X = 15 (roofv_x), Y = 21 (sidev_x) and RAT2 is positive, it does this:
\
\   roofv_x = roofv_x * (1 - 1/512)  + sidev_x / 16
\   sidev_x = sidev_x * (1 - 1/512)  - roofv_x / 16
\
\ Arguments:
\
\   X                   The first vector to rotate:
\
\                         * If X = 15, rotate roofv_x
\
\                         * If X = 17, rotate roofv_y
\
\                         * If X = 19, rotate roofv_z
\
\                         * If X = 21, rotate sidev_x
\
\                         * If X = 23, rotate sidev_y
\
\                         * If X = 25, rotate sidev_z
\
\   Y                   The second vector to rotate:
\
\                         * If Y = 9,  rotate nosev_x
\
\                         * If Y = 11, rotate nosev_y
\
\                         * If Y = 13, rotate nosev_z
\
\                         * If Y = 21, rotate sidev_x
\
\                         * If Y = 23, rotate sidev_y
\
\                         * If Y = 25, rotate sidev_z
\
\   RAT2                The direction of the pitch or roll to perform, positive
\                       or negative (i.e. the sign of the roll or pitch counter
\                       in bit 7)
\
\ ******************************************************************************

.MVS5

 LDA INWK+1,X           \ Fetch roofv_x_hi, clear the sign bit, divide by 2 and
 AND #%01111111         \ store in T, so:
 LSR A                  \
 STA T                  \ T = |roofv_x_hi| / 2
                        \   = |roofv_x| / 512
                        \
                        \ The above is true because:
                        \
                        \ |roofv_x| = |roofv_x_hi| * 256 + roofv_x_lo
                        \
                        \ so:
                        \
                        \ |roofv_x| / 512 = |roofv_x_hi| * 256 / 512
                        \                    + roofv_x_lo / 512
                        \                  = |roofv_x_hi| / 2

 LDA INWK,X             \ Now we do the following subtraction:
 SEC                    \
 SBC T                  \ (S R) = (roofv_x_hi roofv_x_lo) - |roofv_x| / 512
 STA R                  \       = (1 - 1/512) * roofv_x
                        \
                        \ by doing the low bytes first

 LDA INWK+1,X           \ And then the high bytes (the high byte of the right
 SBC #0                 \ side of the subtraction being 0)
 STA S

 LDA INWK,Y             \ Set P = nosev_x_lo
 STA P

 LDA INWK+1,Y           \ Fetch the sign of nosev_x_hi (bit 7) and store in T
 AND #%10000000
 STA T

 LDA INWK+1,Y           \ Fetch nosev_x_hi into A and clear the sign bit, so
 AND #%01111111         \ A = |nosev_x_hi|

 LSR A                  \ Set (A P) = (A P) / 16
 ROR P                  \           = |nosev_x_hi nosev_x_lo| / 16
 LSR A                  \           = |nosev_x| / 16
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P

 ORA T                  \ Set the sign of A to the sign in T (i.e. the sign of
                        \ the original nosev_x), so now:
                        \
                        \ (A P) = nosev_x / 16

 EOR RAT2               \ Give it the sign as if we multiplied by the direction
                        \ by the pitch or roll direction

 STX Q                  \ Store the value of X so it can be restored after the
                        \ call to ADD

 JSR ADD                \ (A X) = (A P) + (S R)
                        \       = +/-nosev_x / 16 + (1 - 1/512) * roofv_x

 STA K+1                \ Set K(1 0) = (1 - 1/512) * roofv_x +/- nosev_x / 16
 STX K

 LDX Q                  \ Restore the value of X from before the call to ADD

 LDA INWK+1,Y           \ Fetch nosev_x_hi, clear the sign bit, divide by 2 and
 AND #%01111111         \ store in T, so:
 LSR A                  \
 STA T                  \ T = |nosev_x_hi| / 2
                        \   = |nosev_x| / 512

 LDA INWK,Y             \ Now we do the following subtraction:
 SEC                    \
 SBC T                  \ (S R) = (nosev_x_hi nosev_x_lo) - |nosev_x| / 512
 STA R                  \       = (1 - 1/512) * nosev_x
                        \
                        \ by doing the low bytes first

 LDA INWK+1,Y           \ And then the high bytes (the high byte of the right
 SBC #0                 \ side of the subtraction being 0)
 STA S

 LDA INWK,X             \ Set P = roofv_x_lo
 STA P

 LDA INWK+1,X           \ Fetch the sign of roofv_x_hi (bit 7) and store in T
 AND #%10000000
 STA T

 LDA INWK+1,X           \ Fetch roofv_x_hi into A and clear the sign bit, so
 AND #%01111111         \ A = |roofv_x_hi|

 LSR A                  \ Set (A P) = (A P) / 16
 ROR P                  \           = |roofv_x_hi roofv_x_lo| / 16
 LSR A                  \           = |roofv_x| / 16
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P

 ORA T                  \ Set the sign of A to the opposite sign to T (i.e. the
 EOR #%10000000         \ sign of the original -roofv_x), so now:
                        \
                        \ (A P) = -roofv_x / 16

 EOR RAT2               \ Give it the sign as if we multiplied by the direction
                        \ by the pitch or roll direction

 STX Q                  \ Store the value of X so it can be restored after the
                        \ call to ADD

 JSR ADD                \ (A X) = (A P) + (S R)
                        \       = -/+roofv_x / 16 + (1 - 1/512) * nosev_x

 STA INWK+1,Y           \ Set nosev_x = (1-1/512) * nosev_x -/+ roofv_x / 16
 STX INWK,Y

 LDX Q                  \ Restore the value of X from before the call to ADD

 LDA K                  \ Set roofv_x = K(1 0)
 STA INWK,X             \              = (1-1/512) * roofv_x +/- nosev_x / 16
 LDA K+1
 STA INWK+1,X

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MVT6
\       Type: Subroutine
\   Category: Moving
\    Summary: Calculate (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1)
\
\ ------------------------------------------------------------------------------
\
\ Do the following calculation, for the coordinate given by X (so this is what
\ it does for the x-coordinate):
\
\   (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1)
\
\ A is a sign bit and is not included in the calculation, but bits 0-6 of A are
\ preserved. Bit 7 is set to the sign of the result.
\
\ Arguments:
\
\   A                   The sign of P(2 1) in bit 7
\
\   P(2 1)              The 16-bit value we want to add the coordinate to
\
\   X                   The coordinate to add, as follows:
\
\                         * If X = 0, add to (x_sign x_hi x_lo)
\
\                         * If X = 3, add to (y_sign y_hi y_lo)
\
\                         * If X = 6, add to (z_sign z_hi z_lo)
\
\ Returns:
\
\   A                   The sign of the result (in bit 7)
\
\ ******************************************************************************

.MVT6

 TAY                    \ Store argument A into Y, for later use

 EOR INWK+2,X           \ Set A = A EOR x_sign

 BMI MV50               \ If the sign is negative, i.e. A and x_sign have
                        \ different signs, jump to MV50

                        \ The signs are the same, so we can add the two
                        \ arguments and keep the sign to get the result

 LDA P+1                \ First we add the low bytes:
 CLC                    \
 ADC INWK,X             \   P+1 = P+1 + x_lo
 STA P+1

 LDA P+2                \ And then the high bytes:
 ADC INWK+1,X           \
 STA P+2                \   P+2 = P+2 + x_hi

 TYA                    \ Restore the original A argument that we stored earlier
                        \ so that we keep the original sign

 RTS                    \ Return from the subroutine

.MV50

 LDA INWK,X             \ First we subtract the low bytes:
 SEC                    \
 SBC P+1                \   P+1 = x_lo - P+1
 STA P+1

 LDA INWK+1,X           \ And then the high bytes:
 SBC P+2                \
 STA P+2                \   P+2 = x_hi - P+2

 BCC MV51               \ If the last subtraction underflowed, then the C flag
                        \ will be clear and x_hi < P+2, so jump to MV51 to
                        \ negate the result

 TYA                    \ Restore the original A argument that we stored earlier
 EOR #%10000000         \ but flip bit 7, which flips the sign. We do this
                        \ because x_hi >= P+2 so we want the result to have the
                        \ same sign as x_hi (as it's the dominant side in this
                        \ calculation). The sign of x_hi is x_sign, and x_sign
                        \ has the opposite sign to A, so we flip the sign in A
                        \ to return the correct result

 RTS                    \ Return from the subroutine

.MV51

 LDA #1                 \ Our subtraction underflowed, so we negate the result
 SBC P+1                \ using two's complement, first with the low byte:
 STA P+1                \
                        \   P+1 = 1 - P+1

 LDA #0                 \ And then the high byte:
 SBC P+2                \
 STA P+2                \   P+2 = 0 - P+2

 TYA                    \ Restore the original A argument that we stored earlier
                        \ as this is the correct sign for the result. This is
                        \ because x_hi < P+2, so we want to return the same sign
                        \ as P+2, the dominant side

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MV40
\       Type: Subroutine
\   Category: Moving
\    Summary: Rotate the planet or sun by our ship's pitch and roll
\
\ ------------------------------------------------------------------------------
\
\ Rotate the planet or sun's location in space by the amount of pitch and roll
\ of our ship.
\
\ We implement this using the same equations as in part 5 of MVEIT, where we
\ rotated the current ship's location by our pitch and roll. Specifically, the
\ calculation is as follows:
\
\   1. K2 = y - alpha * x
\   2. z = z + beta * K2
\   3. y = K2 - beta * z
\   4. x = x + alpha * y
\
\ See the deep dive on "Rotating the universe" for more details on the above.
\
\ ******************************************************************************

.MV40

 TXA                    \ ???
 LSR A
 BCS MV40-1

 LDA ALPHA              \ Set Q = -ALPHA, so Q contains the angle we want to
 EOR #%10000000         \ roll the planet through (i.e. in the opposite
 STA Q                  \ direction to our ship's roll angle alpha)

 LDA INWK               \ Set P(1 0) = (x_hi x_lo)
 STA P
 LDA INWK+1
 STA P+1

 LDA INWK+2             \ Set A = x_sign

 JSR MULT3              \ Set K(3 2 1 0) = (A P+1 P) * Q
                        \
                        \ which also means:
                        \
                        \   K(3 2 1) = (A P+1 P) * Q / 256
                        \            = x * -alpha / 256
                        \            = - alpha * x / 256

 LDX #3                 \ Set K(3 2 1) = (y_sign y_hi y_lo) + K(3 2 1)
 JSR MVT3               \              = y - alpha * x / 256

 LDA K+1                \ Set K2(2 1) = P(1 0) = K(2 1)
 STA K2+1
 STA P

 LDA K+2                \ Set K2+2 = K+2
 STA K2+2

 STA P+1                \ Set P+1 = K+2

 LDA BETA               \ Set Q = beta, the pitch angle of our ship
 STA Q

 LDA K+3                \ Set K+3 to K2+3, so now we have result 1 above:
 STA K2+3               \
                        \   K2(3 2 1) = K(3 2 1)
                        \             = y - alpha * x / 256

                        \ We also have:
                        \
                        \   A = K+3
                        \
                        \   P(1 0) = K(2 1)
                        \
                        \ so combined, these mean:
                        \
                        \   (A P+1 P) = K(3 2 1)
                        \             = K2(3 2 1)

 JSR MULT3              \ Set K(3 2 1 0) = (A P+1 P) * Q
                        \
                        \ which also means:
                        \
                        \   K(3 2 1) = (A P+1 P) * Q / 256
                        \            = K2(3 2 1) * beta / 256
                        \            = beta * K2 / 256

 LDX #6                 \ K(3 2 1) = (z_sign z_hi z_lo) + K(3 2 1)
 JSR MVT3               \          = z + beta * K2 / 256

 LDA K+1                \ Set P = K+1
 STA P

 STA INWK+6             \ Set z_lo = K+1

 LDA K+2                \ Set P+1 = K+2
 STA P+1

 STA INWK+7             \ Set z_hi = K+2

 LDA K+3                \ Set A = z_sign = K+3, so now we have:
 STA INWK+8             \
                        \   (z_sign z_hi z_lo) = K(3 2 1)
                        \                      = z + beta * K2 / 256

                        \ So we now have result 2 above:
                        \
                        \   z = z + beta * K2

 EOR #%10000000         \ Flip the sign bit of A to give A = -z_sign

 JSR MULT3              \ Set K(3 2 1 0) = (A P+1 P) * Q
                        \                = (-z_sign z_hi z_lo) * beta
                        \                = -z * beta

 LDA K+3                \ Set T to the sign bit of K(3 2 1 0), i.e. to the sign
 AND #%10000000         \ bit of -z * beta
 STA T

 EOR K2+3               \ If K2(3 2 1 0) has a different sign to K(3 2 1 0),
 BMI MV1                \ then EOR'ing them will produce a 1 in bit 7, so jump
                        \ to MV1 to take this into account

                        \ If we get here, K and K2 have the same sign, so we can
                        \ add them together to get the result we're after, and
                        \ then set the sign afterwards

 LDA K                  \ We now do the following sum:
\CLC                    \
 ADC K2                 \   (A y_hi y_lo -) = K(3 2 1 0) + K2(3 2 1 0)
                        \
                        \ starting with the low bytes (which we don't keep)
                        \
                        \ The CLC instruction is commented out in the original
                        \ source. It isn't needed because MULT3 clears the C
                        \ flag, so this is an example of the authors finding
                        \ one more precious byte to save

 LDA K+1                \ We then do the middle bytes, which go into y_lo
 ADC K2+1
 STA INWK+3

 LDA K+2                \ And then the high bytes, which go into y_hi
 ADC K2+2
 STA INWK+4

 LDA K+3                \ And then the sign bytes into A, so overall we have the
 ADC K2+3               \ following, if we drop the low bytes from the result:
                        \
                        \   (A y_hi y_lo) = (K + K2) / 256

 JMP MV2                \ Jump to MV2 to skip the calculation for when K and K2
                        \ have different signs

.MV1

 LDA K                  \ If we get here then K2 and K have different signs, so
 SEC                    \ instead of adding, we need to subtract to get the
 SBC K2                 \ result we want, like this:
                        \
                        \   (A y_hi y_lo -) = K(3 2 1 0) - K2(3 2 1 0)
                        \
                        \ starting with the low bytes (which we don't keep)

 LDA K+1                \ We then do the middle bytes, which go into y_lo
 SBC K2+1
 STA INWK+3

 LDA K+2                \ And then the high bytes, which go into y_hi
 SBC K2+2
 STA INWK+4

 LDA K2+3               \ Now for the sign bytes, so first we extract the sign
 AND #%01111111         \ byte from K2 without the sign bit, so P = |K2+3|
 STA P

 LDA K+3                \ And then we extract the sign byte from K without the
 AND #%01111111         \ sign bit, so A = |K+3|

 SBC P                  \ And finally we subtract the sign bytes, so P = A - P
 STA P

                        \ By now we have the following, if we drop the low bytes
                        \ from the result:
                        \
                        \   (A y_hi y_lo) = (K - K2) / 256
                        \
                        \ so now we just need to make sure the sign of the
                        \ result is correct

 BCS MV2                \ If the C flag is set, then the last subtraction above
                        \ didn't underflow and the result is correct, so jump to
                        \ MV2 as we are done with this particular stage

 LDA #1                 \ Otherwise the subtraction above underflowed, as K2 is
 SBC INWK+3             \ the dominant part of the subtraction, so we need to
 STA INWK+3             \ negate the result using two's complement, starting
                        \ with the low bytes:
                        \
                        \   y_lo = 1 - y_lo

 LDA #0                 \ And then the high bytes:
 SBC INWK+4             \
 STA INWK+4             \   y_hi = 0 - y_hi

 LDA #0                 \ And finally the sign bytes:
 SBC P                  \
                        \   A = 0 - P

 ORA #%10000000         \ We now force the sign bit to be negative, so that the
                        \ final result below gets the opposite sign to K, which
                        \ we want as K2 is the dominant part of the sum

.MV2

 EOR T                  \ T contains the sign bit of K, so if K is negative,
                        \ this flips the sign of A

 STA INWK+5             \ Store A in y_sign

                        \ So we now have result 3 above:
                        \
                        \   y = K2 + K
                        \     = K2 - beta * z

 LDA ALPHA              \ Set A = alpha
 STA Q

 LDA INWK+3             \ Set P(1 0) = (y_hi y_lo)
 STA P
 LDA INWK+4
 STA P+1

 LDA INWK+5             \ Set A = y_sign

 JSR MULT3              \ Set K(3 2 1 0) = (A P+1 P) * Q
                        \                = (y_sign y_hi y_lo) * alpha
                        \                = y * alpha

 LDX #0                 \ Set K(3 2 1) = (x_sign x_hi x_lo) + K(3 2 1)
 JSR MVT3               \              = x + y * alpha / 256

 LDA K+1                \ Set (x_sign x_hi x_lo) = K(3 2 1)
 STA INWK               \                        = x + y * alpha / 256
 LDA K+2
 STA INWK+1
 LDA K+3
 STA INWK+2

                        \ So we now have result 4 above:
                        \
                        \   x = x + y * alpha

 JMP MV45               \ We have now finished rotating the planet or sun by
                        \ our pitch and roll, so jump back into the MVEIT
                        \ routine at MV45 to apply all the other movements

\ ******************************************************************************
\
\ Save output/ELTA.bin
\
\ ******************************************************************************

PRINT "ELITE A"
PRINT "Assembled at ", ~CODE%
PRINT "Ends at ", ~P%
PRINT "Code size is ", ~(P% - CODE%)
PRINT "Execute at ", ~LOAD%
PRINT "Reload at ", ~LOAD_A%

PRINT "S.ELTA ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD_A%
SAVE "output/ELTA.bin", CODE%, P%, LOAD%

\ ******************************************************************************
\
\ ELITE B FILE
\
\ Produces the binary file ELTB.bin that gets loaded by elite-bcfs.asm.
\
\ ******************************************************************************

CODE_B% = P%
LOAD_B% = LOAD% + P% - CODE%

\ ******************************************************************************
\
\       Name: NA%
\       Type: Variable
\   Category: Save and load
\    Summary: The data block for the last saved commander
\  Deep dive: Commander save files
\             The competition code
\
\ ------------------------------------------------------------------------------
\
\ Contains the last saved commander data, with the name at NA% and the data at
\ NA%+8 onwards. The size of the data block is given in NT% (which also includes
\ the two checksum bytes that follow this block). This block is initially set up
\ with the default commander, which can be maxed out for testing purposes by
\ setting Q% to TRUE.
\
\ The commander's name is stored at NA%, and can be up to 7 characters long
\ (the DFS filename limit). It is terminated with a carriage return character,
\ ASCII 13.
\
\ The offset of each byte within a saved commander file is also shown as #0, #1
\ and so on, so the kill tally, for example, is in bytes #71 and #72 of the
\ saved file. The related variable name from the current commander block is
\ also shown.
\
\ ******************************************************************************

.NA%

 EQUS "JAMESON"         \ The current commander name, which defaults to JAMESON
 EQUB 13                \
                        \ The commander name can be up to 7 characters (the DFS
                        \ limit for file names), and is terminated by a carriage
                        \ return

                        \ NA%+8 is the start of the commander data block
                        \
                        \ This block contains the last saved commander data
                        \ block. As the game is played it uses an identical
                        \ block at location TP to store the current commander
                        \ state, and that block is copied here when the game is
                        \ saved. Conversely, when the game starts up, the block
                        \ here is copied to TP, which restores the last saved
                        \ commander when we die
                        \
                        \ The initial state of this block defines the default
                        \ commander. Q% can be set to TRUE to give the default
                        \ commander lots of credits and equipment

 EQUB 0                 \ TP = Mission status, #0

 EQUB 20                \ QQ0 = Current system X-coordinate (Lave), #1
 EQUB 173               \ QQ1 = Current system Y-coordinate (Lave), #2

 EQUW &5A4A             \ QQ21 = Seed s0 for system 0, galaxy 0 (Tibedied), #3-4
 EQUW &0248             \ QQ21 = Seed s1 for system 0, galaxy 0 (Tibedied), #5-6
 EQUW &B753             \ QQ21 = Seed s2 for system 0, galaxy 0 (Tibedied), #7-8

IF Q%
 EQUD &00CA9A3B         \ CASH = Amount of cash (100,000,000 Cr), #9-12
ELSE
 EQUD &E8030000         \ CASH = Amount of cash (100 Cr), #9-12
ENDIF

 EQUB 70                \ QQ14 = Fuel level, #13

 EQUB 0                 \ COK = Competition flags, #14

 EQUB 0                 \ GCNT = Galaxy number, 0-7, #15

 EQUB POW+(128 AND Q%)  \ LASER = Front laser, #16

 EQUB (POW+128) AND Q%  \ LASER+1 = Rear laser, #17

 EQUB 0                 \ LASER+2 = Left laser, #18

 EQUB 0                 \ LASER+3 = Right laser, #19

 EQUW 0                 \ These bytes appear to be unused (they were originally
                        \ used for up/down lasers, but they were dropped),
                        \ #20-21

 EQUB 22+(15 AND Q%)    \ CRGO = Cargo capacity, #22

 EQUB 0                 \ QQ20+0  = Amount of Food in cargo hold, #23
 EQUB 0                 \ QQ20+1  = Amount of Textiles in cargo hold, #24
 EQUB 0                 \ QQ20+2  = Amount of Radioactives in cargo hold, #25
 EQUB 0                 \ QQ20+3  = Amount of Slaves in cargo hold, #26
 EQUB 0                 \ QQ20+4  = Amount of Liquor/Wines in cargo hold, #27
 EQUB 0                 \ QQ20+5  = Amount of Luxuries in cargo hold, #28
 EQUB 0                 \ QQ20+6  = Amount of Narcotics in cargo hold, #29
 EQUB 0                 \ QQ20+7  = Amount of Computers in cargo hold, #30
 EQUB 0                 \ QQ20+8  = Amount of Machinery in cargo hold, #31
 EQUB 0                 \ QQ20+9  = Amount of Alloys in cargo hold, #32
 EQUB 0                 \ QQ20+10 = Amount of Firearms in cargo hold, #33
 EQUB 0                 \ QQ20+11 = Amount of Furs in cargo hold, #34
 EQUB 0                 \ QQ20+12 = Amount of Minerals in cargo hold, #35
 EQUB 0                 \ QQ20+13 = Amount of Gold in cargo hold, #36
 EQUB 0                 \ QQ20+14 = Amount of Platinum in cargo hold, #37
 EQUB 0                 \ QQ20+15 = Amount of Gem-Stones in cargo hold, #38
 EQUB 0                 \ QQ20+16 = Amount of Alien Items in cargo hold, #39

 EQUB Q%                \ ECM = E.C.M., #40

 EQUB Q%                \ BST = Fuel scoops ("barrel status"), #41

 EQUB Q% AND 127        \ BOMB = Energy bomb, #42

 EQUB Q% AND 1          \ ENGY = Energy/shield level, #43

 EQUB Q%                \ DKCMP = Docking computer, #44

 EQUB Q%                \ GHYP = Galactic hyperdrive, #45

 EQUB Q%                \ ESCP = Escape pod, #46

 EQUD 0                 \ These four bytes appear to be unused, #47-50

 EQUB 3+(Q% AND 1)      \ NOMSL = Number of missiles, #51

 EQUB 0                 \ FIST = Legal status ("fugitive/innocent status"), #52

 EQUB 16                \ AVL+0  = Market availability of Food, #53
 EQUB 15                \ AVL+1  = Market availability of Textiles, #54
 EQUB 17                \ AVL+2  = Market availability of Radioactives, #55
 EQUB 0                 \ AVL+3  = Market availability of Slaves, #56
 EQUB 3                 \ AVL+4  = Market availability of Liquor/Wines, #57
 EQUB 28                \ AVL+5  = Market availability of Luxuries, #58
 EQUB 14                \ AVL+6  = Market availability of Narcotics, #59
 EQUB 0                 \ AVL+7  = Market availability of Computers, #60
 EQUB 0                 \ AVL+8  = Market availability of Machinery, #61
 EQUB 10                \ AVL+9  = Market availability of Alloys, #62
 EQUB 0                 \ AVL+10 = Market availability of Firearms, #63
 EQUB 17                \ AVL+11 = Market availability of Furs, #64
 EQUB 58                \ AVL+12 = Market availability of Minerals, #65
 EQUB 7                 \ AVL+13 = Market availability of Gold, #66
 EQUB 9                 \ AVL+14 = Market availability of Platinum, #67
 EQUB 8                 \ AVL+15 = Market availability of Gem-Stones, #68
 EQUB 0                 \ AVL+16 = Market availability of Alien Items, #69

 EQUB 0                 \ QQ26 = Random byte that changes for each visit to a
                        \ system, for randomising market prices, #70

 EQUW 0                 \ TALLY = Number of kills, #71-72

 EQUB 128               \ SVC = Save count, #73

\ ******************************************************************************
\
\       Name: CHK2
\       Type: Variable
\   Category: Save and load
\    Summary: Second checksum byte for the saved commander data file
\  Deep dive: Commander save files
\             The competition code
\
\ ------------------------------------------------------------------------------
\
\ Second commander checksum byte. If the default commander is changed, a new
\ checksum will be calculated and inserted by the elite-checksum.py script.
\
\ The offset of this byte within a saved commander file is also shown (it's at
\ byte #74).
\
\ ******************************************************************************

.CHK2

 EQUB &03 EOR &A9       \ The checksum value for the default commander, EOR'd
                        \ with &A9 to make it harder to tamper with the checksum
                        \ byte, #74

\ ******************************************************************************
\
\       Name: CHK
\       Type: Variable
\   Category: Save and load
\    Summary: First checksum byte for the saved commander data file
\  Deep dive: Commander save files
\             The competition code
\
\ ------------------------------------------------------------------------------
\
\ Commander checksum byte. If the default commander is changed, a new checksum
\ will be calculated and inserted by the elite-checksum.py script.
\
\ The offset of this byte within a saved commander file is also shown (it's at
\ byte #75).
\
\ ******************************************************************************

.CHK

 EQUB &03               \ The checksum value for the default commander, #75

\ ******************************************************************************
\
\       Name: UNIV
\       Type: Variable
\   Category: Universe
\    Summary: Table of pointers to the local universe's ship data blocks
\  Deep dive: The local bubble of universe
\
\ ------------------------------------------------------------------------------
\
\ See the deep dive on "Ship data blocks" for details on ship data blocks, and
\ the deep dive on "The local bubble of universe" for details of how Elite
\ stores the local universe in K%, FRIN and UNIV.
\
\ ******************************************************************************

.UNIV

FOR I%, 0, NOSH
  EQUW K% + I% * NI%    \ Address of block no. I%, of size NI%, in workspace K%
NEXT

\ ******************************************************************************
\
\       Name: TWOS
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made single-pixel character row bytes for mode 4
\  Deep dive: Drawing colour pixels in mode 4
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting one-pixel points in mode 4 (the top part of the
\ split screen). See the PIXEL routine for details.
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
 EQUB %10000000
 EQUB %01000000

\ ******************************************************************************
\
\       Name: CTWOS
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made double-pixel character row bytes for the mode 4
\             dashboard
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting two-pixel points in the mode 4 dashboard (the
\ bottom part of the screen).
\
\ ******************************************************************************

.CTWOS

 EQUB %11000000
 EQUB %00110000
 EQUB %00001100
 EQUB %00000011

\ ******************************************************************************
\
\       Name: TWOS2
\       Type: Variable
\   Category: Drawing pixels
\    Summary: Ready-made double-pixel character row bytes for mode 4
\  Deep dive: Drawing colour pixels in mode 4
\
\ ------------------------------------------------------------------------------
\
\ Ready-made bytes for plotting two-pixel dashes in mode 4 (the top part of the
\ split screen). See the PIXEL routine for details.
\
\ ******************************************************************************

.TWOS2

 EQUB %11000000
 EQUB %11000000
 EQUB %01100000
 EQUB %00110000
 EQUB %00011000
 EQUB %00001100
 EQUB %00000110
 EQUB %00000011

\ ******************************************************************************
\
\       Name: LOIN (Part 1 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a line: Calculate the line gradient in the form of deltas
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ This stage calculates the line deltas.
\
\ Arguments:
\
\   X1                  The screen x-coordinate of the start of the line
\
\   Y1                  The screen y-coordinate of the start of the line
\
\   X2                  The screen x-coordinate of the end of the line
\
\   Y2                  The screen y-coordinate of the end of the line
\
\ Returns:
\
\   Y                   Y is preserved
\
\ Other entry points:
\
\   LL30                LL30 is a synonym for LOIN and draws a line from
\                       (X1, Y1) to (X2, Y2)
\
\   HL6                 Contains an RTS
\
\ ******************************************************************************

.LL30

 SKIP 0                 \ LL30 is a synomym for LOIN
                        \
                        \ In the cassette and disc versions of Elite, LL30 and
                        \ LOIN are synonyms for the same routine, presumably
                        \ because the two developers each had their own line
                        \ routines to start with, and then chose one of them for
                        \ the final game

.LOIN

 STY YSAV               \ Store Y into YSAV, so we can preserve it across the
                        \ call to this subroutine

 LDA #128               \ Set S = 128, which is the starting point for the
 STA S                  \ slope error (representing half a pixel)

 STA SC                 \ ???

 ASL A                  \ Set SWAP = 0, as %10000000 << 1 = 0
 STA SWAP

 LDA X2                 \ Set A = X2 - X1
 SBC X1                 \       = delta_x
                        \
                        \ This subtraction works as the ASL A above sets the C
                        \ flag

 BCS LI1                \ If X2 > X1 then A is already positive and we can skip
                        \ the next three instructions

 EOR #%11111111         \ Negate the result in A by flipping all the bits and
 ADC #1                 \ adding 1, i.e. using two's complement to make it
                        \ positive

.LI1

 STA P                  \ Store A in P, so P = |X2 - X1|, or |delta_x|

 SEC                    \ ???

 LDA Y2                 \ Set A = Y2 - Y1
 SBC Y1                 \       = delta_y
                        \
                        \ This subtraction works as we either set the C flag
                        \ above, or we skipped that SEC instruction with a BCS

 BCS LI2                \ If Y2 > Y1 then A is already positive and we can skip
                        \ the next two instructions

 EOR #%11111111         \ Negate the result in A by flipping all the bits and
 ADC #1                 \ adding 1, i.e. using two's complement to make it
                        \ positive

.LI2

 STA Q                  \ Store A in Q, so Q = |Y2 - Y1|, or |delta_y|

 CMP P                  \ If Q < P, jump to STPX to step along the x-axis, as
 BCC STPX               \ the line is closer to being horizontal than vertical

 JMP STPY               \ Otherwise Q >= P so jump to STPY to step along the
                        \ y-axis, as the line is closer to being vertical than
                        \ horizontal

\ ******************************************************************************
\
\       Name: LOIN (Part 2 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a line: Line has a shallow gradient, step right along x-axis
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * |delta_y| < |delta_x|
\
\   * The line is closer to being horizontal than vertical
\
\   * We are going to step right along the x-axis
\
\   * We potentially swap coordinates to make sure X1 < X2
\
\ ******************************************************************************

.STPX

 LDX X1                 \ Set X = X1

 CPX X2                 \ If X1 < X2, jump down to LI3, as the coordinates are
 BCC LI3                \ already in the order that we want

 DEC SWAP               \ Otherwise decrement SWAP from 0 to &FF, to denote that
                        \ we are swapping the coordinates around

 LDA X2                 \ Swap the values of X1 and X2
 STA X1
 STX X2

 TAX                    \ Set X = X1

 LDA Y2                 \ Swap the values of Y1 and Y2
 LDY Y1
 STA Y1
 STY Y2

.LI3

                        \ By this point we know the line is horizontal-ish and
                        \ X1 < X2, so we're going from left to right as we go
                        \ from X1 to X2

 LDA Y1                 \ Set A = Y1 / 8, so A now contains the character row
 LSR A                  \ that will contain our horizontal line
 LSR A
 LSR A

 STA SCH                \ ???
 LSR A
 ROR SC
 LSR A
 ROR SC
 ADC SCH
 ADC #&58
 STA SCH
 TXA
 AND #&F8
 ADC SC
 STA SC
 BCC L1681

 INC SCH

.L1681

 LDA Y1                 \ Set Y = Y1 mod 8, which is the pixel row within the
 AND #7                 \ character block at which we want to draw the start of
 TAY                    \ our line (as each character block has 8 rows)

 TXA                    \ Set X = X1 mod 8, which is the horizontal pixel number
 AND #7                 \ within the character block where the line starts (as
 TAX                    \ each pixel line in the character block is 8 pixels
                        \ wide)

 LDA TWOS,X             \ Fetch a 1-pixel byte from TWOS where pixel X is set,
 STA R                  \ and store it in R

                        \ The following calculates:
                        \
                        \   Q = Q / P
                        \     = |delta_y| / |delta_x|
                        \
                        \ using the same shift-and-subtract algorithm that's
                        \ documented in TIS2

 LDA Q                  \ Set A = |delta_y|

 LDX #%11111110         \ Set Q to have bits 1-7 set, so we can rotate through 7
 STX Q                  \ loop iterations, getting a 1 each time, and then
                        \ getting a 0 on the 8th iteration... and we can also
                        \ use Q to catch our result bits into bit 0 each time

.LIL1

 ASL A                  \ Shift A to the left

 BCS LI4                \ If bit 7 of A was set, then jump straight to the
                        \ subtraction

 CMP P                  \ If A < P, skip the following subtraction
 BCC LI5

.LI4

 SBC P                  \ A >= P, so set A = A - P

 SEC                    \ Set the C flag to rotate into the result in Q

.LI5

 ROL Q                  \ Rotate the counter in Q to the left, and catch the
                        \ result bit into bit 0 (which will be a 0 if we didn't
                        \ do the subtraction, or 1 if we did)

 BCS LIL1               \ If we still have set bits in Q, loop back to TIL2 to
                        \ do the next iteration of 7

                        \ We now have:
                        \
                        \   Q = A / P
                        \     = |delta_y| / |delta_x|
                        \
                        \ and the C flag is clear

 LDX P                  \ Set X = P + 1
 INX                    \       = |delta_x| + 1
                        \
                        \ We add 1 so we can skip the first pixel plot if the
                        \ line is being drawn with swapped coordinates

 LDA Y2                 \ Set A = Y2 - Y1 - 1 (as the C flag is clear following
 SBC Y1                 \ the above division)

 BCS DOWN               \ If Y2 >= Y1 - 1 then jump to DOWN, as we need to draw
                        \ the line to the right and down

\ ******************************************************************************
\
\       Name: LOIN (Part 3 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a shallow line going right and up or left and down
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going right and up (no swap) or left and down (swap)
\
\   * X1 < X2 and Y1-1 > Y2
\
\   * Draw from (X1, Y1) at bottom left to (X2, Y2) at top right
\
\ ******************************************************************************

 LDA SWAP               \ If SWAP > 0 then we swapped the coordinates above, so
 BNE LI6                \ jump down to LI6 to skip plotting the first pixel

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

.LIL2

                        \ We now loop along the line from left to right, using X
                        \ as a decreasing counter, and at each count we plot a
                        \ single pixel using the pixel mask in R

 LDA R                  \ Fetch the pixel byte from R

 EOR (SC),Y             \ Store R into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

.LI6

 LSR R                  \ Shift the single pixel in R to the right to step along
                        \ the x-axis, so the next pixel we plot will be at the
                        \ next x-coordinate along

 BCC LI7                \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI7

 ROR R                  \ Otherwise we need to move over to the next character
                        \ block, so first rotate R right so the set C flag goes
                        \ back into the left end, giving %10000000

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #8                 \ character along to the right
 STA SC

 BCC LI7                \ ???

 INC SCH

.LI7

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LIC2               \ If the addition didn't overflow, jump to LIC2

 DEY                    \ Otherwise we just overflowed, so decrement Y to move
                        \ to the pixel line above

 BPL LIC2               \ If Y is positive we are still within the same
                        \ character block, so skip to LIC2

 LDA SC                 \ ???
 SBC #&40
 STA SC
 LDA SCH
 SBC #&01
 STA SCH
 LDY #7

.LIC2

 DEX                    \ Decrement the counter in X

 BNE LIL2               \ If we haven't yet reached the right end of the line,
                        \ loop back to LIL2 to plot the next pixel along

 LDY YSAV               \ Restore Y from YSAV, so that it's preserved

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: LOIN (Part 4 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a shallow line going right and down or left and up
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going right and down (no swap) or left and up (swap)
\
\   * X1 < X2 and Y1-1 <= Y2
\
\   * Draw from (X1, Y1) at top left to (X2, Y2) at bottom right
\
\ ******************************************************************************

.DOWN

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI9                \ so jump down to LI9 to skip plotting the first pixel

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

.LIL3

                        \ We now loop along the line from left to right, using X
                        \ as a decreasing counter, and at each count we plot a
                        \ single pixel using the pixel mask in R

 LDA R                  \ Fetch the pixel byte from R

 EOR (SC),Y             \ Store R into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

.LI9

 LSR R                  \ Shift the single pixel in R to the right to step along
                        \ the x-axis, so the next pixel we plot will be at the
                        \ next x-coordinate along

 BCC LI10               \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LI10

 ROR R                  \ Otherwise we need to move over to the next character
                        \ block, so first rotate R right so the set C flag goes
                        \ back into the left end, giving %10000000

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #8                 \ character along to the right
 STA SC

 BCC LI10               \ ???

 INC SCH

.LI10

 LDA S                  \ Set S = S + Q to update the slope error
 ADC Q
 STA S

 BCC LIC3               \ If the addition didn't overflow, jump to LIC3

 INY                    \ Otherwise we just overflowed, so increment Y to move
                        \ to the pixel line below

 CPY #8                 \ If Y < 8 we are still within the same character block,
 BNE LIC3               \ so skip to LIC3

 LDA SC                 \ ???
 ADC #&3F
 STA SC
 LDA SCH
 ADC #&01
 STA SCH
 LDY #&00

.LIC3

 DEX                    \ Decrement the counter in X

 BNE LIL3               \ If we haven't yet reached the right end of the line,
                        \ loop back to LIL3 to plot the next pixel along

 LDY YSAV               \ Restore Y from YSAV, so that it's preserved

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: LOIN (Part 5 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a line: Line has a steep gradient, step up along y-axis
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * |delta_y| >= |delta_x|
\
\   * The line is closer to being vertical than horizontal
\
\   * We are going to step up along the y-axis
\
\   * We potentially swap coordinates to make sure Y1 >= Y2
\
\ ******************************************************************************

.STPY

 LDY Y1                 \ Set A = Y = Y1
 TYA

 LDX X1                 \ Set X = X1

 CPY Y2                 \ If Y1 >= Y2, jump down to LI15, as the coordinates are
 BCS LI15               \ already in the order that we want

 DEC SWAP               \ Otherwise decrement SWAP from 0 to &FF, to denote that
                        \ we are swapping the coordinates around

 LDA X2                 \ Swap the values of X1 and X2
 STA X1
 STX X2

 TAX                    \ Set X = X1

 LDA Y2                 \ Swap the values of Y1 and Y2
 STA Y1
 STY Y2

 TAY                    \ Set Y = A = Y1

.LI15

                        \ By this point we know the line is vertical-ish and
                        \ Y1 >= Y2, so we're going from top to bottom as we go
                        \ from Y1 to Y2

 LSR A                  \ Set A = Y1 / 8, so A now contains the character row
 LSR A                  \ that will contain our horizontal line
 LSR A

 STA SCH
 LSR A
 ROR SC
 LSR A
 ROR SC
 ADC SCH
 ADC #&58
 STA SCH
 TXA
 AND #&F8
 ADC SC
 STA SC
 BCC L1757

 INC SCH

.L1757

 LDA Y1                 \ Set Y = Y1 mod 8, which is the pixel row within the
 AND #7                 \ character block at which we want to draw the start of
 TAY                    \ our line (as each character block has 8 rows)

                        \ The following calculates:
                        \
                        \   P = P / Q
                        \     = |delta_x| / |delta_y|
                        \
                        \ using the same shift-and-subtract algorithm
                        \ documented in TIS2

 TXA                    \ ???
 AND #&07
 TAX
 LDA TWOS,X
 STA R

 LDA P                  \ Set A = |delta_x|

 LDX #1                 \ Set Q to have bits 1-7 clear, so we can rotate through
 STX P                  \ 7 loop iterations, getting a 1 each time, and then
                        \ getting a 1 on the 8th iteration... and we can also
                        \ use P to catch our result bits into bit 0 each time

.LIL4

 ASL A                  \ Shift A to the left

 BCS LI13               \ If bit 7 of A was set, then jump straight to the
                        \ subtraction

 CMP Q                  \ If A < Q, skip the following subtraction
 BCC LI14

.LI13

 SBC Q                  \ A >= Q, so set A = A - Q

 SEC                    \ Set the C flag to rotate into the result in Q

.LI14

 ROL P                  \ Rotate the counter in P to the left, and catch the
                        \ result bit into bit 0 (which will be a 0 if we didn't
                        \ do the subtraction, or 1 if we did)

 BCC LIL4               \ If we still have set bits in P, loop back to TIL2 to
                        \ do the next iteration of 7

                        \ We now have:
                        \
                        \   P = A / Q
                        \     = |delta_x| / |delta_y|
                        \
                        \ and the C flag is set

 LDX Q                  \ Set X = Q + 1
 INX                    \       = |delta_y| + 1
                        \
                        \ We add 1 so we can skip the first pixel plot if the
                        \ line is being drawn with swapped coordinates

 LDA X2                 \ Set A = X2 - X1 (the C flag is set as we didn't take
 SBC X1                 \ the above BCC)

 BCC LFT                \ If X2 < X1 then jump to LFT, as we need to draw the
                        \ line to the left and down

\ ******************************************************************************
\
\       Name: LOIN (Part 6 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a steep line going up and left or down and right
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going up and left (no swap) or down and right (swap)
\
\   * X1 < X2 and Y1 >= Y2
\
\   * Draw from (X1, Y1) at top left to (X2, Y2) at bottom right
\
\ ******************************************************************************

 CLC                    \ Clear the C flag

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI17               \ so jump down to LI17 to skip plotting the first pixel

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

.LIL5

                        \ We now loop along the line from left to right, using X
                        \ as a decreasing counter, and at each count we plot a
                        \ single pixel using the pixel mask in R

 LDA R                  \ Fetch the pixel byte from R

 EOR (SC),Y             \ Store R into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

.LI17

 DEY                    \ Decrement Y to step up along the y-axis

 BPL LI16               \ If Y is positive we are still within the same
                        \ character block, so skip to LI16

 LDA SC                 \ ???
 SBC #&3F
 STA SC
 LDA SCH
 SBC #&01
 STA SCH
 LDY #7

.LI16

 LDA S                  \ Set S = S + Q to update the slope error
 ADC P
 STA S

 BCC LIC5               \ If the addition didn't overflow, jump to LIC5

 LSR R                  \ Otherwise we just overflowed, so shift the single
                        \ pixel in R to the right, so the next pixel we plot
                        \ will be at the next x-coordinate along

 BCC LIC5               \ If the pixel didn't fall out of the right end of R
                        \ into the C flag, then jump to LIC5

 ROR R                  \ Otherwise we need to move over to the next character
                        \ block, so first rotate R right so the set C flag goes
                        \ back into the left end, giving %10000000

 LDA SC                 \ Add 8 to SC, so SC(1 0) now points to the next
 ADC #8                 \ character along to the right
 STA SC

 BCC LIC5               \ ???

 INC SCH
 CLC

.LIC5

 DEX                    \ Decrement the counter in X

 BNE LIL5               \ If we haven't yet reached the right end of the line,
                        \ loop back to LIL5 to plot the next pixel along

 LDY YSAV               \ Restore Y from YSAV, so that it's preserved

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: LOIN (Part 7 of 7)
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a steep line going up and right or down and left
\  Deep dive: Bresenham's line algorithm
\
\ ------------------------------------------------------------------------------
\
\ This routine draws a line from (X1, Y1) to (X2, Y2). It has multiple stages.
\ If we get here, then:
\
\   * The line is going up and right (no swap) or down and left (swap)
\
\   * X1 >= X2 and Y1 >= Y2
\
\   * Draw from (X1, Y1) at bottom left to (X2, Y2) at top right
\
\ ******************************************************************************

.LFT

 LDA SWAP               \ If SWAP = 0 then we didn't swap the coordinates above,
 BEQ LI18               \ jump down to LI18 to skip plotting the first pixel

 DEX                    \ Decrement the counter in X because we're about to plot
                        \ the first pixel

.LIL6

 LDA R                  \ Fetch the pixel byte from R

 EOR (SC),Y             \ Store R into screen memory at SC(1 0), using EOR
 STA (SC),Y             \ logic so it merges with whatever is already on-screen

.LI18

 DEY                    \ Decrement Y to step up along the y-axis

 BPL LI19               \ If Y is positive we are still within the same
                        \ character block, so skip to LI19

 LDA SC                 \ ???
 SBC #&3F
 STA SC
 LDA SCH
 SBC #&01
 STA SCH
 LDY #7

.LI19

 LDA S                  \ Set S = S + P to update the slope error
 ADC P
 STA S

 BCC LIC6               \ If the addition didn't overflow, jump to LIC6

 ASL R                  \ Otherwise we just overflowed, so shift the single
                        \ pixel in R to the left, so the next pixel we plot
                        \ will be at the previous x-coordinate

 BCC LIC6               \ If the pixel didn't fall out of the left end of R
                        \ into the C flag, then jump to LIC6

 ROL R                  \ Otherwise we need to move over to the next character
                        \ block, so first rotate R left so the set C flag goes
                        \ back into the right end, giving %0000001

 LDA SC                 \ Subtract 7 from SC, so SC(1 0) now points to the
 SBC #7                 \ previous character along to the left
 STA SC

 BCS L17F2              \ ???

 DEC SCH

.L17F2

 CLC                    \ Clear the C flag so it doesn't affect the additions
                        \ below

.LIC6

 DEX                    \ Decrement the counter in X

 BNE LIL6               \ If we haven't yet reached the left end of the line,
                        \ loop back to LIL6 to plot the next pixel along

 LDY YSAV               \ Restore Y from YSAV, so that it's preserved

.HL6

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: FLKB
\       Type: Subroutine
\   Category: Keyboard
\    Summary: Flush the keyboard buffer
\
\ ******************************************************************************

.FLKB

 LDA #15                \ Call OSBYTE with A = 15 and Y <> 0 to flush the input
 TAX                    \ buffers (i.e. flush the operating system's keyboard
 JMP OSBYTE             \ buffer) and return from the subroutine using a tail
                        \ call

\ ******************************************************************************
\
\       Name: NLIN3
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Print a title and a horizontal line at row 19 to box it in
\
\ ------------------------------------------------------------------------------
\
\ This routine print a text token at the cursor position and draws a horizontal
\ line at pixel row 19. It is used for the Status Mode screen, the Short-range
\ Chart, the Market Price screen and the Equip Ship screen.
\
\ ******************************************************************************

.NLIN3

 JSR TT27               \ Print the text token in A

                        \ Fall through into NLIN4 to draw a horizontal line at
                        \ pixel row 19

\ ******************************************************************************
\
\       Name: NLIN4
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a horizontal line at pixel row 19 to box in a title
\
\ ------------------------------------------------------------------------------
\
\ This routine is used on the Inventory screen to draw a horizontal line at
\ pixel row 19 to box in the title.
\
\ ******************************************************************************

.NLIN4

 LDA #19                \ Jump to NLIN2 to draw a horizontal line at pixel row
 BNE NLIN2              \ 19, returning from the subroutine with using a tail
                        \ call (this BNE is effectively a JMP as A will never
                        \ be zero)

\ ******************************************************************************
\
\       Name: NLIN
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a horizontal line at pixel row 23 to box in a title
\
\ ------------------------------------------------------------------------------
\
\ Draw a horizontal line at pixel row 23 and move the text cursor down one
\ line.
\
\ ******************************************************************************

.NLIN

 LDA #23                \ Set A = 23 so NLIN2 below draws a horizontal line at
                        \ pixel row 23

 INC YC                 \ Move the text cursor down one line

                        \ Fall through into NLIN2 to draw the horizontal line
                        \ at row 23

\ ******************************************************************************
\
\       Name: NLIN2
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a screen-wide horizontal line at the pixel row in A
\
\ ------------------------------------------------------------------------------
\
\ This draws a line from (2, A) to (254, A), which is almost screen-wide and
\ fits in nicely between the white borders without clashing with it.
\
\ Arguments:
\
\   A                   The pixel row on which to draw the horizontal line
\
\ ******************************************************************************

.NLIN2

 STA Y1                 \ Set Y1 = A

 LDX #2                 \ Set X1 = 2, so (X1, Y1) = (2, A)
 STX X1

 LDX #254               \ Set X2 = 254, so (X2, Y2) = (254, A)
 STX X2

                        \ Fall through into HLOIN to draw a horizontal line from
                        \ (2, A) to (254, A) and return from the subroutine

\ ******************************************************************************
\
\       Name: HLOIN
\       Type: Subroutine
\   Category: Drawing lines
\    Summary: Draw a horizontal line from (X1, Y1) to (X2, Y1)
\
\ ------------------------------------------------------------------------------
\
\ We do not draw a pixel at the end point (X2, X1).
\
\ To understand how this routine works, you might find it helpful to read the
\ deep dive on "Drawing monochrome pixels in mode 4".
\
\ Returns:
\
\   Y                   Y is preserved
\
\ ******************************************************************************

.HLOIN

 LDX Y1                 \ ???
 STX Y2

.HL1

 JMP LL30               \ ???

\ ******************************************************************************
\
\       Name: PIX1
\       Type: Subroutine
\   Category: Maths (Arithmetic)
\    Summary: Calculate (YY+1 SYL+Y) = (A P) + (S R) and draw stardust particle
\
\ ------------------------------------------------------------------------------
\
\ Calculate the following:
\
\   (YY+1 SYL+Y) = (A P) + (S R)
\
\ and draw a stardust particle at (X1,Y1) with distance ZZ.
\
\ Arguments:
\
\   (A P)               A is the angle ALPHA or BETA, P is always 0
\
\   (S R)               YY(1 0) or YY(1 0) + Q * A
\
\   Y                   Stardust particle number
\
\   X1                  The x-coordinate offset
\
\   Y1                  The y-coordinate offset
\
\   ZZ                  The distance of the point (further away = smaller point)
\
\ ******************************************************************************

.PIX1

 JSR ADD                \ Set (A X) = (A P) + (S R)

 STA YY+1               \ Set YY+1 to A, the high byte of the result

 TXA                    \ Set SYL+Y to X, the low byte of the result
 STA SYL,Y

                        \ Fall through into PIX1 to draw the stardust particle
                        \ at (X1,Y1)

\ ******************************************************************************
\
\       Name: PIXEL2
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a stardust particle relative to the screen centre
\
\ ------------------------------------------------------------------------------
\
\ Draw a point (X1, Y1) from the middle of the screen with a size determined by
\ a distance value. Used to draw stardust particles.
\
\ Arguments:
\
\   X1                  The x-coordinate offset
\
\   Y1                  The y-coordinate offset (positive means up the screen
\                       from the centre, negative means down the screen)
\
\   ZZ                  The distance of the point (further away = smaller point)
\
\ ******************************************************************************

.PIXEL2

 LDA X1                 \ Fetch the x-coordinate offset into A

 BPL PX1                \ If the x-coordinate offset is positive, jump to PX1
                        \ to skip the following negation

 EOR #%01111111         \ The x-coordinate offset is negative, so flip all the
 CLC                    \ bits apart from the sign bit and add 1, to negate
 ADC #1                 \ it to a positive number, i.e. A is now |X1|

.PX1

 EOR #%10000000         \ Set X = -|A|
 TAX                    \       = -|X1|

 LDA Y1                 \ Fetch the y-coordinate offset into A and clear the
 AND #%01111111         \ sign bit, so A = |Y1|

 CMP #96                \ If |Y1| >= 96 then it's off the screen (as 96 is half
 BCS PX4                \ the screen height), so return from the subroutine (as
                        \ PX4 contains an RTS)

 LDA Y1                 \ Fetch the y-coordinate offset into A

 BPL PX2                \ If the y-coordinate offset is positive, jump to PX2
                        \ to skip the following negation

 EOR #%01111111         \ The y-coordinate offset is negative, so flip all the
 ADC #1                 \ bits apart from the sign bit and subtract 1, to negate
                        \ it to a positive number, i.e. A is now |Y1|

.PX2

 STA T                  \ Set A = 97 - A
 LDA #97                \       = 97 - |Y1|
 SBC T                  \
                        \ so if Y is positive we display the point up from the
                        \ centre, while a negative Y means down from the centre

                        \ Fall through into PIXEL to draw the stardust at the
                        \ screen coordinates in (X, A)

\ ******************************************************************************
\
\       Name: PIXEL
\       Type: Subroutine
\   Category: Drawing pixels
\    Summary: Draw a 1-pixel dot, 2-pixel dash or 4-pixel square
\  Deep dive: Drawing monochrome pixels in mode 4
\
\ ------------------------------------------------------------------------------
\
\ Draw a point at screen coordinate (X, A) with the point size determined by the
\ distance in ZZ. This applies to the top part of the screen (the space view).
\
\ Arguments:
\
\   X                   The screen x-coordinate of the point to draw
\
\   A                   The screen y-coordinate of the point to draw
\
\   ZZ                  The distance of the point (further away = smaller point)
\
\ Returns:
\
\   Y                   Y is preserved
\
\ Other entry points:
\
\   PX4                 Contains an RTS
\
\ ******************************************************************************

.PIXEL

 STY T1                 \ ???
 LDY #&80
 STY SC
 TAY
 LSR A
 LSR A
 LSR A
 STA SCH
 LSR A
 ROR SC
 LSR A
 ROR SC
 ADC SCH
 ADC #&58
 STA SCH
 TXA
 AND #&F8
 ADC SC
 STA SC
 BCC L1869

 INC SCH

.L1869

 TYA                    \ Set Y = Y AND %111
 AND #%00000111
 TAY

 TXA                    \ Set X = X AND %111
 AND #%00000111
 TAX

 LDA ZZ                 \ If distance in ZZ >= 144, then this point is a very
 CMP #144               \ long way away, so jump to PX14 to ???
 BCS PX14

 LDA TWOS2,X            \ Otherwise fetch a 2-pixel dash from TWOS2 and EOR it
 EOR (SC),Y             \ into SC+Y
 STA (SC),Y

 LDA ZZ                 \ If distance in ZZ >= 80, then this point is a medium
 CMP #80                \ distance away, so jump to PX13 to stop drawing, as a
 BCS PX13               \ 2-pixel dash is enough

                        \ Otherwise we keep going to draw another 2 pixel point
                        \ either above or below the one we just drew, to make a
                        \ 4-pixel square

 DEY                    \ Reduce Y by 1 to point to the pixel row above the one
 BPL PX14               \ we just plotted, and if it is still positive, jump to
                        \ PX14 to draw our second 2-pixel dash

 LDY #1                 \ Reducing Y by 1 made it negative, which means Y was
                        \ 0 before we did the DEY above, so set Y to 1 to point
                        \ to the pixel row after the one we just plotted

.PX14

 LDA TWOS2,X            \ Fetch a 2-pixel dash from TWOS2 and EOR it into this
 EOR (SC),Y             \ second row to make a 4-pixel square
 STA (SC),Y

.PX13

 LDY T1                 \ Restore Y from T1, so Y is preserved by the routine

.PX4

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: BLINE
\       Type: Subroutine
\   Category: Drawing circles
\    Summary: Draw a circle segment and add it to the ball line heap
\  Deep dive: The ball line heap
\             Drawing circles
\
\ ------------------------------------------------------------------------------
\
\ Draw a single segment of a circle, adding the point to the ball line heap.
\
\ Arguments:
\
\   CNT                 The number of this segment
\
\   STP                 The step size for the circle
\
\   K6(1 0)             The x-coordinate of the new point on the circle, as
\                       a screen coordinate
\
\   (T X)               The y-coordinate of the new point on the circle, as
\                       an offset from the centre of the circle
\
\   FLAG                Set to &FF for the first call, so it sets up the first
\                       point in the heap but waits until the second call before
\                       drawing anything (as we need two points, i.e. two calls,
\                       before we can draw a line)
\
\   K                   The circle's radius
\
\   K3(1 0)             Pixel x-coordinate of the centre of the circle
\
\   K4(1 0)             Pixel y-coordinate of the centre of the circle
\
\   SWAP                If non-zero, we swap (X1, Y1) and (X2, Y2)
\
\ Returns:
\
\   CNT                 CNT is updated to CNT + STP
\
\   A                   The new value of CNT
\
\   FLAG                Set to 0
\
\ ******************************************************************************

.BLINE

 TXA                    \ Set K6(3 2) = (T X) + K4(1 0)
 ADC K4                 \             = y-coord of centre + y-coord of new point
 STA K6+2               \
 LDA K4+1               \ so K6(3 2) now contains the y-coordinate of the new
 ADC T                  \ point on the circle but as a screen coordinate, to go
 STA K6+3               \ along with the screen y-coordinate in K6(1 0)

 LDA FLAG               \ If FLAG = 0, jump down to BL1
 BEQ BL1

 INC FLAG               \ Flag is &FF so this is the first call to BLINE, so
                        \ increment FLAG to set it to 0, as then the next time
                        \ we call BLINE it can draw the first line, from this
                        \ point to the next

.BL5

                        \ The following inserts a &FF marker into the LSY2 line
                        \ heap to indicate that the next call to BLINE should
                        \ store both the (X1, Y1) and (X2, Y2) points. We do
                        \ this on the very first call to BLINE (when FLAG is
                        \ &FF), and on subsequent calls if the segment does not
                        \ fit on-screen, in which case we don't draw or store
                        \ that segment, and we start a new segment with the next
                        \ call to BLINE that does fit on-screen

 LDY LSP                \ If byte LSP-1 of LSY2 = &FF, jump to BL7 to tidy up
 LDA #&FF               \ and return from the subroutine, as the point that has
 CMP LSY2-1,Y           \ been passed to BLINE is the start of a segment, so all
 BEQ BL7                \ we need to do is save the coordinate in K5, without
                        \ moving the pointer in LSP

 STA LSY2,Y             \ Otherwise we just tried to plot a segment but it
                        \ didn't fit on-screen, so put the &FF marker into the
                        \ heap for this point, so the next call to BLINE starts
                        \ a new segment

 INC LSP                \ Increment LSP to point to the next point in the heap

 BNE BL7                \ Jump to BL7 to tidy up and return from the subroutine
                        \ (this BNE is effectively a JMP, as LSP will never be
                        \ zero)

.BL1

 LDA K5                 \ Set XX15 = K5 = x_lo of previous point
 STA XX15

 LDA K5+1               \ Set XX15+1 = K5+1 = x_hi of previous point
 STA XX15+1

 LDA K5+2               \ Set XX15+2 = K5+2 = y_lo of previous point
 STA XX15+2

 LDA K5+3               \ Set XX15+3 = K5+3 = y_hi of previous point
 STA XX15+3

 LDA K6                 \ Set XX15+4 = x_lo of new point
 STA XX15+4

 LDA K6+1               \ Set XX15+5 = x_hi of new point
 STA XX15+5

 LDA K6+2               \ Set XX12 = y_lo of new point
 STA XX12

 LDA K6+3               \ Set XX12+1 = y_hi of new point
 STA XX12+1

 JSR LL145              \ Call LL145 to see if the new line segment needs to be
                        \ clipped to fit on-screen, returning the clipped line's
                        \ end-points in (X1, Y1) and (X2, Y2)

 BCS BL5                \ If the C flag is set then the line is not visible on
                        \ screen anyway, so jump to BL5, to avoid drawing and
                        \ storing this line

 LDA SWAP               \ If SWAP = 0, then we didn't have to swap the line
 BEQ BL9                \ coordinates around during the clipping process, so
                        \ jump to BL9 to skip the following swap

 LDA X1                 \ Otherwise the coordinates were swapped by the call to
 LDY X2                 \ LL145 above, so we swap (X1, Y1) and (X2, Y2) back
 STA X2                 \ again
 STY X1
 LDA Y1
 LDY Y2
 STA Y2
 STY Y1

.BL9

 LDY LSP                \ Set Y = LSP

 LDA LSY2-1,Y           \ If byte LSP-1 of LSY2 is not &FF, jump down to BL8
 CMP #&FF               \ to skip the following (X1, Y1) code
 BNE BL8

                        \ Byte LSP-1 of LSY2 is &FF, which indicates that we
                        \ need to store (X1, Y1) in the heap

 LDA X1                 \ Store X1 in the LSP-th byte of LSX2
 STA LSX2,Y

 LDA Y1                 \ Store Y1 in the LSP-th byte of LSY2
 STA LSY2,Y

 INY                    \ Increment Y to point to the next byte in LSX2/LSY2

.BL8

 LDA X2                 \ Store X2 in the LSP-th byte of LSX2
 STA LSX2,Y

 LDA Y2                 \ Store Y2 in the LSP-th byte of LSX2
 STA LSY2,Y

 INY                    \ Increment Y to point to the next byte in LSX2/LSY2

 STY LSP                \ Update LSP to point to the same as Y

 JSR LOIN               \ Draw a line from (X1, Y1) to (X2, Y2)

 LDA XX13               \ If XX13 is non-zero, jump up to BL5 to add a &FF
 BNE BL5                \ marker to the end of the line heap. XX13 is non-zero
                        \ after the call to the clipping routine LL145 above if
                        \ the end of the line was clipped, meaning the next line
                        \ sent to BLINE can't join onto the end but has to start
                        \ a new segment, and that's what inserting the &FF
                        \ marker does

.BL7

 LDA K6                 \ Copy the data for this step point from K6(3 2 1 0)
 STA K5                 \ into K5(3 2 1 0), for use in the next call to BLINE:
 LDA K6+1               \
 STA K5+1               \   * K5(1 0) = screen x-coordinate of this point
 LDA K6+2               \
 STA K5+2               \   * K5(3 2) = screen y-coordinate of this point
 LDA K6+3               \
 STA K5+3               \ They now become the "previous point" in the next call

 LDA CNT                \ Set CNT = CNT + STP
 CLC
 ADC STP
 STA CNT

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: FLIP
\       Type: Subroutine
\   Category: Stardust
\    Summary: Reflect the stardust particles in the screen diagonal
\
\ ------------------------------------------------------------------------------
\
\ Swap the x- and y-coordinates of all the stardust particles and draw the new
\ set of particles. Called by LOOK1 when we switch views.
\
\ This is a quick way of making the stardust field in the new view feel
\ different without having to generate a whole new field. If you look carefully
\ at the stardust field when you switch views, you can just about see that the
\ new field is a reflection of the previous field in the screen diagonal, i.e.
\ in the line from bottom left to top right. This is the line where x = y when
\ the origin is in the middle of the screen, and positive x and y are right and
\ up, which is the coordinate system we use for stardust).
\
\ ******************************************************************************

.FLIP

\LDA MJ                 \ These instructions are commented out in the original
\BNE FLIP-1             \ source. They would have the effect of not swapping the
                        \ stardust if we had mis-jumped into witchspace

 LDY #NOST              \ Set Y to the number of stardust particles, so we can
                        \ use it as a counter through all the stardust

.FLL1

 LDX SY,Y               \ Copy the Y-th particle's y-coordinate from SY+Y into X

 LDA SX,Y               \ Copy the Y-th particle's x-coordinate from SX+Y into
 STA Y1                 \ both Y1 and the particle's y-coordinate
 STA SY,Y

 TXA                    \ Copy the Y-th particle's original y-coordinate into
 STA X1                 \ both X1 and the particle's x-coordinate, so the x- and
 STA SX,Y               \ y-coordinates are now swapped and (X1, Y1) contains
                        \ the particle's new coordinates

 LDA SZ,Y               \ Fetch the Y-th particle's distance from SZ+Y into ZZ
 STA ZZ

 JSR PIXEL2             \ Draw a stardust particle at (X1,Y1) with distance ZZ

 DEY                    \ Decrement the counter to point to the next particle of
                        \ stardust

 BNE FLL1               \ Loop back to FLL1 until we have moved all the stardust
                        \ particles

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: STARS
\       Type: Subroutine
\   Category: Stardust
\    Summary: The main routine for processing the stardust
\
\ ------------------------------------------------------------------------------
\
\ Called at the very end of the main flight loop.
\
\ ******************************************************************************

.STARS

\LDA #&FF               \ These instructions are commented out in the original
\STA COL                \ source, but they would set the stardust colour to
                        \ white. That said, COL is only used when updating the
                        \ dashboard, so this would have no effect - perhaps it's
                        \ left over from experiments with a colour top part of
                        \ the screen? Who knows...

 LDX VIEW               \ Load the current view into X:
                        \
                        \   0 = front
                        \   1 = rear
                        \   2 = left
                        \   3 = right

 BEQ STARS1             \ If this 0, jump to STARS1 to process the stardust for
                        \ the front view

 DEX                    \ If this is view 2 or 3, jump to STARS2 (via ST11) to
 BNE ST11               \ process the stardust for the left or right views

 JMP STARS6             \ Otherwise this is the rear view, so jump to STARS6 to
                        \ process the stardust for the rear view

.ST11

 JMP STARS2             \ Jump to STARS2 for the left or right views, as it's
                        \ too far for the branch instruction above

\ ******************************************************************************
\
\       Name: STARS1
\       Type: Subroutine
\   Category: Stardust
\    Summary: Process the stardust for the front view
\  Deep dive: Stardust in the front view
\
\ ------------------------------------------------------------------------------
\
\ This moves the stardust towards us according to our speed (so the dust rushes
\ past us), and applies our current pitch and roll to each particle of dust, so
\ the stardust moves correctly when we steer our ship.
\
\ When a stardust particle rushes past us and falls off the side of the screen,
\ its memory is recycled as a new particle that's positioned randomly on-screen.
\
\ ******************************************************************************

.STARS1

 LDY #NOST              \ Set Y to the number of stardust particles, so we can
                        \ use it as a counter through all the stardust

                        \ In the following, we're going to refer to the 16-bit
                        \ space coordinates of the current particle of stardust
                        \ (i.e. the Y-th particle) like this:
                        \
                        \   x = (x_hi x_lo)
                        \   y = (y_hi y_lo)
                        \   z = (z_hi z_lo)
                        \
                        \ These values are stored in (SX+Y SXL+Y), (SY+Y SYL+Y)
                        \ and (SZ+Y SZL+Y) respectively

.STL1

 JSR DV42               \ Call DV42 to set the following:
                        \
                        \   (P R) = 256 * DELTA / z_hi
                        \         = 256 * speed / z_hi
                        \
                        \ The maximum value returned is P = 2 and R = 128 (see
                        \ DV42 for an explanation)

 LDA R                  \ Set A = R, so now:
                        \
                        \   (P A) = 256 * speed / z_hi

 LSR P                  \ Rotate (P A) right by 2 places, which sets P = 0 (as P
 ROR A                  \ has a maximum value of 2) and leaves:
 LSR P                  \
 ROR A                  \   A = 64 * speed / z_hi

 ORA #1                 \ Make sure A is at least 1, and store it in Q, so we
 STA Q                  \ now have result 1 above:
                        \
                        \   Q = 64 * speed / z_hi

 LDA SZL,Y              \ We now calculate the following:
 SBC DELT4              \
 STA SZL,Y              \  (z_hi z_lo) = (z_hi z_lo) - DELT4(1 0)
                        \
                        \ starting with the low bytes

 LDA SZ,Y               \ And then we do the high bytes
 STA ZZ                 \
 SBC DELT4+1            \ We also set ZZ to the original value of z_hi, which we
 STA SZ,Y               \ use below to remove the existing particle
                        \
                        \ So now we have result 2 above:
                        \
                        \   z = z - DELT4(1 0)
                        \     = z - speed * 64

 JSR MLU1               \ Call MLU1 to set:
                        \
                        \   Y1 = y_hi
                        \
                        \   (A P) = |y_hi| * Q
                        \
                        \ So Y1 contains the original value of y_hi, which we
                        \ use below to remove the existing particle

                        \ We now calculate:
                        \
                        \   (S R) = YY(1 0) = (A P) + y

 STA YY+1               \ First we do the low bytes with:
 LDA P                  \
 ADC SYL,Y              \   YY+1 = A
 STA YY                 \   R = YY = P + y_lo
 STA R                  \
                        \ so we get this:
                        \
                        \   (? R) = YY(1 0) = (A P) + y_lo

 LDA Y1                 \ And then we do the high bytes with:
 ADC YY+1               \
 STA YY+1               \   S = YY+1 = y_hi + YY+1
 STA S                  \
                        \ so we get our result:
                        \
                        \   (S R) = YY(1 0) = (A P) + (y_hi y_lo)
                        \                   = |y_hi| * Q + y
                        \
                        \ which is result 3 above, and (S R) is set to the new
                        \ value of y

 LDA SX,Y               \ Set X1 = A = x_hi
 STA X1                 \
                        \ So X1 contains the original value of x_hi, which we
                        \ use below to remove the existing particle

 JSR MLU2               \ Set (A P) = |x_hi| * Q

                        \ We now calculate:
                        \
                        \   XX(1 0) = (A P) + x

 STA XX+1               \ First we do the low bytes:
 LDA P                  \
 ADC SXL,Y              \   XX(1 0) = (A P) + x_lo
 STA XX

 LDA X1                 \ And then we do the high bytes:
 ADC XX+1               \
 STA XX+1               \   XX(1 0) = XX(1 0) + (x_hi 0)
                        \
                        \ so we get our result:
                        \
                        \   XX(1 0) = (A P) + x
                        \           = |x_hi| * Q + x
                        \
                        \ which is result 4 above, and we also have:
                        \
                        \   A = XX+1 = (|x_hi| * Q + x) / 256
                        \
                        \ i.e. A is the new value of x, divided by 256

 EOR ALP2+1             \ EOR with the flipped sign of the roll angle alpha, so
                        \ A has the opposite sign to the flipped roll angle
                        \ alpha, i.e. it gets the same sign as alpha

 JSR MLS1               \ Call MLS1 to calculate:
                        \
                        \   (A P) = A * ALP1
                        \         = (x / 256) * alpha

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = (x / 256) * alpha + y
                        \         = y + alpha * x / 256

 STA YY+1               \ Set YY(1 0) = (A X) to give:
 STX YY                 \
                        \   YY(1 0) = y + alpha * x / 256
                        \
                        \ which is result 5 above, and we also have:
                        \
                        \   A = YY+1 = y + alpha * x / 256
                        \
                        \ i.e. A is the new value of y, divided by 256

 EOR ALP2               \ EOR A with the correct sign of the roll angle alpha,
                        \ so A has the opposite sign to the roll angle alpha

 JSR MLS2               \ Call MLS2 to calculate:
                        \
                        \   (S R) = XX(1 0)
                        \         = x
                        \
                        \   (A P) = A * ALP1
                        \         = -y / 256 * alpha

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = -y / 256 * alpha + x

 STA XX+1               \ Set XX(1 0) = (A X), which gives us result 6 above:
 STX XX                 \
                        \   x = x - alpha * y / 256

 LDX BET1               \ Fetch the pitch magnitude into X

 LDA YY+1               \ Set A to y_hi and set it to the flipped sign of beta
 EOR BET2+1

 JSR MULTS-2            \ Call MULTS-2 to calculate:
                        \
                        \   (A P) = X * A
                        \         = -beta * y_hi

 STA Q                  \ Store the high byte of the result in Q, so:
                        \
                        \   Q = -beta * y_hi / 256

 JSR MUT2               \ Call MUT2 to calculate:
                        \
                        \   (S R) = XX(1 0) = x
                        \
                        \   (A P) = Q * A
                        \         = (-beta * y_hi / 256) * (-beta * y_hi / 256)
                        \         = (beta * y / 256) ^ 2

 ASL P                  \ Double (A P), store the top byte in A and set the C
 ROL A                  \ flag to bit 7 of the original A, so this does:
 STA T                  \
                        \   (T P) = (A P) << 1
                        \         = 2 * (beta * y / 256) ^ 2

 LDA #0                 \ Set bit 7 in A to the sign bit from the A in the
 ROR A                  \ calculation above and apply it to T, so we now have:
 ORA T                  \
                        \   (A P) = (A P) * 2
                        \         = 2 * (beta * y / 256) ^ 2
                        \
                        \ with the doubling retaining the sign of (A P)

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = 2 * (beta * y / 256) ^ 2 + x

 STA XX+1               \ Store the high byte A in XX+1

 TXA
 STA SXL,Y              \ Store the low byte X in x_lo

                        \ So (XX+1 x_lo) now contains:
                        \
                        \   x = x + 2 * (beta * y / 256) ^ 2
                        \
                        \ which is result 7 above

 LDA YY                 \ Set (S R) = YY(1 0) = y
 STA R
 LDA YY+1
\JSR MAD                \ These instructions are commented out in the original
\STA S                  \ source
\STX R
 STA S

 LDA #0                 \ Set P = 0
 STA P

 LDA BETA               \ Set A = -beta, so:
 EOR #%10000000         \
                        \   (A P) = (-beta 0)
                        \         = -beta * 256

 JSR PIX1               \ Call PIX1 to calculate the following:
                        \
                        \   (YY+1 y_lo) = (A P) + (S R)
                        \               = -beta * 256 + y
                        \
                        \ i.e. y = y - beta * 256, which is result 8 above
                        \
                        \ PIX1 also draws a particle at (X1, Y1) with distance
                        \ ZZ, which will remove the old stardust particle, as we
                        \ set X1, Y1 and ZZ to the original values for this
                        \ particle during the calculations above

                        \ We now have our newly moved stardust particle at
                        \ x-coordinate (XX+1 x_lo) and y-coordinate (YY+1 y_lo)
                        \ and distance z_hi, so we draw it if it's still on
                        \ screen, otherwise we recycle it as a new bit of
                        \ stardust and draw that

 LDA XX+1               \ Set X1 and x_hi to the high byte of XX in XX+1, so
 STA X1                 \ the new x-coordinate is in (x_hi x_lo) and the high
 STA SX,Y               \ byte is in X1

 AND #%01111111         \ If |x_hi| >= 120 then jump to KILL1 to recycle this
 CMP #120               \ particle, as it's gone off the side of the screen,
 BCS KILL1              \ and re-join at STC1 with the new particle

 LDA YY+1               \ Set Y1 and y_hi to the high byte of YY in YY+1, so
 STA SY,Y               \ the new x-coordinate is in (y_hi y_lo) and the high
 STA Y1                 \ byte is in Y1

 AND #%01111111         \ If |y_hi| >= 120 then jump to KILL1 to recycle this
 CMP #120               \ particle, as it's gone off the top or bottom of the
 BCS KILL1              \ screen, and re-join at STC1 with the new particle

 LDA SZ,Y               \ If z_hi < 16 then jump to KILL1 to recycle this
 CMP #16                \ particle, as it's so close that it's effectively gone
 BCC KILL1              \ past us, and re-join at STC1 with the new particle

 STA ZZ                 \ Set ZZ to the z-coordinate in z_hi

.STC1

 JSR PIXEL2             \ Draw a stardust particle at (X1,Y1) with distance ZZ,
                        \ i.e. draw the newly moved particle at (x_hi, y_hi)
                        \ with distance z_hi

 DEY                    \ Decrement the loop counter to point to the next
                        \ stardust particle

 BEQ P%+5               \ If we have just done the last particle, skip the next
                        \ instruction to return from the subroutine

 JMP STL1               \ We have more stardust to process, so jump back up to
                        \ STL1 for the next particle

 RTS                    \ Return from the subroutine

.KILL1

                        \ Our particle of stardust just flew past us, so let's
                        \ recycle that particle, starting it at a random
                        \ position that isn't too close to the centre point

 JSR DORND              \ Set A and X to random numbers

 ORA #4                 \ Make sure A is at least 4 and store it in Y1 and y_hi,
 STA Y1                 \ so the new particle starts at least 4 pixels above or
 STA SY,Y               \ below the centre of the screen

 JSR DORND              \ Set A and X to random numbers

 ORA #8                 \ Make sure A is at least 8 and store it in X1 and x_hi,
 STA X1                 \ so the new particle starts at least 8 pixels either
 STA SX,Y               \ side of the centre of the screen

 JSR DORND              \ Set A and X to random numbers

 ORA #144               \ Make sure A is at least 144 and store it in ZZ and
 STA SZ,Y               \ z_hi so the new particle starts in the far distance
 STA ZZ

 LDA Y1                 \ Set A to the new value of y_hi. This has no effect as
                        \ STC1 starts with a jump to PIXEL2, which starts with a
                        \ LDA instruction

 JMP STC1               \ Jump up to STC1 to draw this new particle

\ ******************************************************************************
\
\       Name: STARS6
\       Type: Subroutine
\   Category: Stardust
\    Summary: Process the stardust for the rear view
\
\ ------------------------------------------------------------------------------
\
\ This routine is very similar to STARS1, which processes stardust for the front
\ view. The main difference is that the direction of travel is reversed, so the
\ signs in the calculations are different, as well as the order of the first
\ batch of calculations.
\
\ When a stardust particle falls away into the far distance, it is removed from
\ the screen and its memory is recycled as a new particle, positioned randomly
\ along one of the four edges of the screen.
\
\ See STARS1 for an explanation of the maths used in this routine. The
\ calculations are as follows:
\
\   1. q = 64 * speed / z_hi
\   2. x = x - |x_hi| * q
\   3. y = y - |y_hi| * q
\   4. z = z + speed * 64
\
\   5. y = y - alpha * x / 256
\   6. x = x + alpha * y / 256
\
\   7. x = x - 2 * (beta * y / 256) ^ 2
\   8. y = y + beta * 256
\
\ ******************************************************************************

.STARS6

 LDY #NOST              \ Set Y to the number of stardust particles, so we can
                        \ use it as a counter through all the stardust

.STL6

 JSR DV42               \ Call DV42 to set the following:
                        \
                        \   (P R) = 256 * DELTA / z_hi
                        \         = 256 * speed / z_hi
                        \
                        \ The maximum value returned is P = 2 and R = 128 (see
                        \ DV42 for an explanation)

 LDA R                  \ Set A = R, so now:
                        \
                        \   (P A) = 256 * speed / z_hi

 LSR P                  \ Rotate (P A) right by 2 places, which sets P = 0 (as P
 ROR A                  \ has a maximum value of 2) and leaves:
 LSR P                  \
 ROR A                  \   A = 64 * speed / z_hi

 ORA #1                 \ Make sure A is at least 1, and store it in Q, so we
 STA Q                  \ now have result 1 above:
                        \
                        \   Q = 64 * speed / z_hi

 LDA SX,Y               \ Set X1 = A = x_hi
 STA X1                 \
                        \ So X1 contains the original value of x_hi, which we
                        \ use below to remove the existing particle

 JSR MLU2               \ Set (A P) = |x_hi| * Q

                        \ We now calculate:
                        \
                        \   XX(1 0) = x - (A P)

 STA XX+1               \ First we do the low bytes:
 LDA SXL,Y              \
 SBC P                  \   XX(1 0) = x_lo - (A P)
 STA XX

 LDA X1                 \ And then we do the high bytes:
 SBC XX+1               \
 STA XX+1               \   XX(1 0) = (x_hi 0) - XX(1 0)
                        \
                        \ so we get our result:
                        \
                        \   XX(1 0) = x - (A P)
                        \           = x - |x_hi| * Q
                        \
                        \ which is result 2 above, and we also have:

 JSR MLU1               \ Call MLU1 to set:
                        \
                        \   Y1 = y_hi
                        \
                        \   (A P) = |y_hi| * Q
                        \
                        \ So Y1 contains the original value of y_hi, which we
                        \ use below to remove the existing particle

                        \ We now calculate:
                        \
                        \   (S R) = YY(1 0) = y - (A P)

 STA YY+1               \ First we do the low bytes with:
 LDA SYL,Y              \
 SBC P                  \   YY+1 = A
 STA YY                 \   R = YY = y_lo - P
 STA R                  \
                        \ so we get this:
                        \
                        \   (? R) = YY(1 0) = y_lo - (A P)

 LDA Y1                 \ And then we do the high bytes with:
 SBC YY+1               \
 STA YY+1               \   S = YY+1 = y_hi - YY+1
 STA S                  \
                        \ so we get our result:
                        \
                        \   (S R) = YY(1 0) = (y_hi y_lo) - (A P)
                        \                   = y - |y_hi| * Q
                        \
                        \ which is result 3 above, and (S R) is set to the new
                        \ value of y

 LDA SZL,Y              \ We now calculate the following:
 ADC DELT4              \
 STA SZL,Y              \  (z_hi z_lo) = (z_hi z_lo) + DELT4(1 0)
                        \
                        \ starting with the low bytes

 LDA SZ,Y               \ And then we do the high bytes
 STA ZZ                 \
 ADC DELT4+1            \ We also set ZZ to the original value of z_hi, which we
 STA SZ,Y               \ use below to remove the existing particle
                        \
                        \ So now we have result 4 above:
                        \
                        \   z = z + DELT4(1 0)
                        \     = z + speed * 64

 LDA XX+1               \ EOR x with the correct sign of the roll angle alpha,
 EOR ALP2               \ so A has the opposite sign to the roll angle alpha

 JSR MLS1               \ Call MLS1 to calculate:
                        \
                        \   (A P) = A * ALP1
                        \         = (-x / 256) * alpha

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = (-x / 256) * alpha + y
                        \         = y - alpha * x / 256

 STA YY+1               \ Set YY(1 0) = (A X) to give:
 STX YY                 \
                        \   YY(1 0) = y - alpha * x / 256
                        \
                        \ which is result 5 above, and we also have:
                        \
                        \   A = YY+1 = y - alpha * x / 256
                        \
                        \ i.e. A is the new value of y, divided by 256

 EOR ALP2+1             \ EOR with the flipped sign of the roll angle alpha, so
                        \ A has the opposite sign to the flipped roll angle
                        \ alpha, i.e. it gets the same sign as alpha

 JSR MLS2               \ Call MLS2 to calculate:
                        \
                        \   (S R) = XX(1 0)
                        \         = x
                        \
                        \   (A P) = A * ALP1
                        \         = y / 256 * alpha

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = y / 256 * alpha + x

 STA XX+1               \ Set XX(1 0) = (A X), which gives us result 6 above:
 STX XX                 \
                        \   x = x + alpha * y / 256

 LDA YY+1               \ Set A to y_hi and set it to the flipped sign of beta
 EOR BET2+1

 LDX BET1               \ Fetch the pitch magnitude into X

 JSR MULTS-2            \ Call MULTS-2 to calculate:
                        \
                        \   (A P) = X * A
                        \         = beta * y_hi

 STA Q                  \ Store the high byte of the result in Q, so:
                        \
                        \   Q = beta * y_hi / 256

 LDA XX+1               \ Set S = x_hi
 STA S

 EOR #%10000000         \ Flip the sign of A, so A now contains -x

 JSR MUT1               \ Call MUT1 to calculate:
                        \
                        \   R = XX = x_lo
                        \
                        \   (A P) = Q * A
                        \         = (beta * y_hi / 256) * (-beta * y_hi / 256)
                        \         = (-beta * y / 256) ^ 2

 ASL P                  \ Double (A P), store the top byte in A and set the C
 ROL A                  \ flag to bit 7 of the original A, so this does:
 STA T                  \
                        \   (T P) = (A P) << 1
                        \         = 2 * (-beta * y / 256) ^ 2

 LDA #0                 \ Set bit 7 in A to the sign bit from the A in the
 ROR A                  \ calculation above and apply it to T, so we now have:
 ORA T                  \
                        \   (A P) = -2 * (beta * y / 256) ^ 2
                        \
                        \ with the doubling retaining the sign of (A P)

 JSR ADD                \ Call ADD to calculate:
                        \
                        \   (A X) = (A P) + (S R)
                        \         = -2 * (beta * y / 256) ^ 2 + x

 STA XX+1               \ Store the high byte A in XX+1

 TXA
 STA SXL,Y              \ Store the low byte X in x_lo

                        \ So (XX+1 x_lo) now contains:
                        \
                        \   x = x - 2 * (beta * y / 256) ^ 2
                        \
                        \ which is result 7 above

 LDA YY                 \ Set (S R) = YY(1 0) = y
 STA R
 LDA YY+1
 STA S

\EOR #128               \ These instructions are commented out in the original
\JSR MAD                \ source
\STA S
\STX R

 LDA #0                 \ Set P = 0
 STA P

 LDA BETA               \ Set A = beta, so (A P) = (beta 0) = beta * 256

 JSR PIX1               \ Call PIX1 to calculate the following:
                        \
                        \   (YY+1 y_lo) = (A P) + (S R)
                        \               = beta * 256 + y
                        \
                        \ i.e. y = y + beta * 256, which is result 8 above
                        \
                        \ PIX1 also draws a particle at (X1, Y1) with distance
                        \ ZZ, which will remove the old stardust particle, as we
                        \ set X1, Y1 and ZZ to the original values for this
                        \ particle during the calculations above

                        \ We now have our newly moved stardust particle at
                        \ x-coordinate (XX+1 x_lo) and y-coordinate (YY+1 y_lo)
                        \ and distance z_hi, so we draw it if it's still on
                        \ screen, otherwise we recycle it as a new bit of
                        \ stardust and draw that

 LDA XX+1               \ Set X1 and x_hi to the high byte of XX in XX+1, so
 STA X1                 \ the new x-coordinate is in (x_hi x_lo) and the high
 STA SX,Y               \ byte is in X1

 LDA YY+1               \ Set Y1 and y_hi to the high byte of YY in YY+1, so
 STA SY,Y               \ the new x-coordinate is in (y_hi y_lo) and the high
 STA Y1                 \ byte is in Y1

 AND #%01111111         \ If |y_hi| >= 110 then jump to KILL6 to recycle this
 CMP #110               \ particle, as it's gone off the top or bottom of the
 BCS KILL6              \ screen, and re-join at STC6 with the new particle

 LDA SZ,Y               \ If z_hi >= 160 then jump to KILL6 to recycle this
 CMP #160               \ particle, as it's so far away that it's too far to
 BCS KILL6              \ see, and re-join at STC1 with the new particle

 STA ZZ                 \ Set ZZ to the z-coordinate in z_hi

.STC6

 JSR PIXEL2             \ Draw a stardust particle at (X1,Y1) with distance ZZ,
                        \ i.e. draw the newly moved particle at (x_hi, y_hi)
                        \ with distance z_hi

 DEY                    \ Decrement the loop counter to point to the next
                        \ stardust particle

 BEQ ST3                \ If we have just done the last particle, skip the next
                        \ instruction to return from the subroutine

 JMP STL6               \ We have more stardust to process, so jump back up to
                        \ STL6 for the next particle

.ST3

 RTS                    \ Return from the subroutine

.KILL6

 JSR DORND              \ Set A and X to random numbers

 AND #%01111111         \ Clear the sign bit of A to get |A|

 ADC #10                \ Make sure A is at least 10 and store it in z_hi and
 STA SZ,Y               \ ZZ, so the new particle starts close to us
 STA ZZ

 LSR A                  \ Divide A by 2 and randomly set the C flag

 BCS ST4                \ Jump to ST4 half the time

 LSR A                  \ Randomly set the C flag again

 LDA #252               \ Set A to either +126 or -126 (252 >> 1) depending on
 ROR A                  \ the C flag, as this is a sign-magnitude number with
                        \ the C flag rotated into its sign bit

 STA X1                 \ Set x_hi and X1 to A, so this particle starts on
 STA SX,Y               \ either the left or right edge of the screen

 JSR DORND              \ Set A and X to random numbers

 STA Y1                 \ Set y_hi and Y1 to random numbers, so the particle
 STA SY,Y               \ starts anywhere along either the left or right edge

 JMP STC6               \ Jump up to STC6 to draw this new particle

.ST4

 JSR DORND              \ Set A and X to random numbers

 STA X1                 \ Set x_hi and X1 to random numbers, so the particle
 STA SX,Y               \ starts anywhere along the x-axis

 LSR A                  \ Randomly set the C flag

 LDA #230               \ Set A to either +115 or -115 (230 >> 1) depending on
 ROR A                  \ the C flag, as this is a sign-magnitude number with
                        \ the C flag rotated into its sign bit

 STA Y1                 \ Set y_hi and Y1 to A, so the particle starts anywhere
 STA SY,Y               \ along either the top or bottom edge of the screen

 BNE STC6               \ Jump up to STC6 to draw this new particle (this BNE is
                        \ effectively a JMP as A will never be zero)

\ ******************************************************************************
\
\       Name: PRXS
\       Type: Variable
\   Category: Equipment
\    Summary: Equipment prices
\
\ ------------------------------------------------------------------------------
\
\ Equipment prices are stored as 10 * the actual value, so we can support prices
\ with fractions of credits (0.1 Cr). This is used for the price of fuel only.
\
\ ******************************************************************************

.PRXS

 EQUW 1                 \ 0  Fuel, calculated in EQSHP  140.0 Cr (full tank)
 EQUW 300               \ 1  Missile                     30.0 Cr
 EQUW 4000              \ 2  Large Cargo Bay            400.0 Cr
 EQUW 6000              \ 3  E.C.M. System              600.0 Cr
 EQUW 4000              \ 4  Extra Pulse Lasers         400.0 Cr
 EQUW 10000             \ 5  Extra Beam Lasers         1000.0 Cr
 EQUW 5250              \ 6  Fuel Scoops                525.0 Cr
 EQUW 10000             \ 7  Escape Pod                1000.0 Cr
 EQUW 9000              \ 8  Energy Bomb                900.0 Cr
 EQUW 15000             \ 9  Energy Unit               1500.0 Cr
 EQUW 10000             \ 10 Docking Computer          1000.0 Cr
 EQUW 50000             \ 11 Galactic Hyperspace       5000.0 Cr

\ ******************************************************************************
\
\       Name: STATUS
\       Type: Subroutine
\   Category: Status
\    Summary: Show the Status Mode screen (red key f8)
\  Deep dive: Combat rank
\
\ ******************************************************************************

.st4

                        \ We call this from st5 below with the high byte of the
                        \ kill tally in A, which is non-zero, and want to return
                        \ with the following in X, depending on our rating:
                        \
                        \   Competent = 6
                        \   Dangerous = 7
                        \   Deadly    = 8
                        \   Elite     = 9
                        \
                        \ The high bytes of the top tier ratings are as follows,
                        \ so this a relatively simple calculation:
                        \
                        \   Competent       = 1 to 2
                        \   Dangerous       = 2 to 9
                        \   Deadly          = 10 to 24
                        \   Elite           = 25 and up

 LDX #9                 \ Set X to 9 for an Elite rating

 CMP #25                \ If A >= 25, jump to st3 to print out our rating, as we
 BCS st3                \ are Elite

 DEX                    \ Decrement X to 8 for a Deadly rating

 CMP #10                \ If A >= 10, jump to st3 to print out our rating, as we
 BCS st3                \ are Deadly

 DEX                    \ Decrement X to 7 for a Dangerous rating

 CMP #2                 \ If A >= 2, jump to st3 to print out our rating, as we
 BCS st3                \ are Dangerous

 DEX                    \ Decrement X to 6 for a Competent rating

 BNE st3                \ Jump to st3 to print out our rating, as we are
                        \ Competent (this BNE is effectively a JMP as A will
                        \ never be zero)

.STATUS

 LDA #8                 \ Clear the top part of the screen, draw a white border,
 JSR TT66               \ and set the current view type in QQ11 to 8 (Status
                        \ Mode screen)

 JSR TT111              \ Select the system closest to galactic coordinates
                        \ (QQ9, QQ10)

 LDA #7                 \ Move the text cursor to column 7
 STA XC

 LDA #126               \ Print recursive token 126, which prints the top
 JSR NLIN3              \ four lines of the Status Mode screen:
                        \
                        \         COMMANDER {commander name}
                        \
                        \
                        \   Present System      : {current system name}
                        \   Hyperspace System   : {selected system name}
                        \   Condition           :
                        \
                        \ and draw a horizontal line at pixel row 19 to box
                        \ in the title

 LDA #15                \ Set A to token 129 ("{sentence case}DOCKED")

 LDY QQ12               \ Fetch the docked status from QQ12, and if we are
 BNE st6                \ docked, jump to st6 to print "Docked" for our
                        \ ship's condition

 LDA #230               \ Otherwise we are in space, so start off by setting A
                        \ to token 70 ("GREEN")

 LDY MANY+AST           \ Set Y to the number of asteroids in our local bubble
                        \ of universe

 LDX FRIN+2,Y           \ The ship slots at FRIN are ordered with the first two
                        \ slots reserved for the planet and sun/space station,
                        \ and then any ships, so if the slot at FRIN+2+Y is not
                        \ empty (i.e is non-zero), then that means the number of
                        \ non-asteroids in the vicinity is at least 1

 BEQ st6                \ So if X = 0, there are no ships in the vicinity, so
                        \ jump to st6 to print "Green" for our ship's condition

 LDY ENERGY             \ Otherwise we have ships in the vicinity, so we load
                        \ our energy levels into Y

 CPY #128               \ Set the C flag if Y >= 128, so C is set if we have
                        \ more than half of our energy banks charged

 ADC #1                 \ Add 1 + C to A, so if C is not set (i.e. we have low
                        \ energy levels) then A is set to token 231 ("RED"),
                        \ and if C is set (i.e. we have healthy energy levels)
                        \ then A is set to token 232 ("YELLOW")

.st6

 JSR plf                \ Print the text token in A (which contains our ship's
                        \ condition) followed by a newline

 LDA #125               \ Print recursive token 125, which prints the next
 JSR spc                \ three lines of the Status Mode screen:
                        \
                        \   Fuel: {fuel level} Light Years
                        \   Cash: {cash} Cr
                        \   Legal Status:
                        \
                        \ followed by a space

 LDA #19                \ Set A to token 133 ("CLEAN")

 LDY FIST               \ Fetch our legal status, and if it is 0, we are clean,
 BEQ st5                \ so jump to st5 to print "Clean"

 CPY #50                \ Set the C flag if Y >= 50, so C is set if we have
                        \ a legal status of 50+ (i.e. we are a fugitive)

 ADC #1                 \ Add 1 + C to A, so if C is not set (i.e. we have a
                        \ legal status between 1 and 49) then A is set to token
                        \ 134 ("OFFENDER"), and if C is set (i.e. we have a
                        \ legal status of 50+) then A is set to token 135
                        \ ("FUGITIVE")

.st5

 JSR plf                \ Print the text token in A (which contains our legal
                        \ status) followed by a newline

 LDA #16                \ Print recursive token 130 ("RATING:")
 JSR spc

 LDA TALLY+1            \ Fetch the high byte of the kill tally, and if it is
 BNE st4                \ not zero, then we have more than 256 kills, so jump
                        \ to st4 to work out whether we are Competent,
                        \ Dangerous, Deadly or Elite

                        \ Otherwise we have fewer than 256 kills, so we are one
                        \ of Harmless, Mostly Harmless, Poor, Average or Above
                        \ Average

 TAX                    \ Set X to 0 (as A is 0)

 LDA TALLY              \ Set A = lower byte of tally / 4
 LSR A
 LSR A

.st5L

                        \ We now loop through bits 2 to 7, shifting each of them
                        \ off the end of A until there are no set bits left, and
                        \ incrementing X for each shift, so at the end of the
                        \ process, X contains the position of the leftmost 1 in
                        \ A. Looking at the rank values in TALLY:
                        \
                        \   Harmless        = %00000000 to %00000011
                        \   Mostly Harmless = %00000100 to %00000111
                        \   Poor            = %00001000 to %00001111
                        \   Average         = %00010000 to %00011111
                        \   Above Average   = %00100000 to %11111111
                        \
                        \ we can see that the values returned by this process
                        \ are:
                        \
                        \   Harmless        = 1
                        \   Mostly Harmless = 2
                        \   Poor            = 3
                        \   Average         = 4
                        \   Above Average   = 5

 INX                    \ Increment X for each shift

 LSR A                  \ Shift A to the right

 BNE st5L               \ Keep looping around until A = 0, which means there are
                        \ no set bits left in A

.st3

 TXA                    \ A now contains our rating as a value of 1 to 9, so
                        \ transfer X to A, so we can print it out

 CLC                    \ Print recursive token 135 + A, which will be in the
 ADC #21                \ range 136 ("HARMLESS") to 144 ("---- E L I T E ----")
 JSR plf                \ followed by a newline

 LDA #18                \ Print recursive token 132, which prints the next bit
 JSR plf2               \ of the Status Mode screen:
                        \
                        \   EQUIPMENT:
                        \
                        \ followed by a newline and an indent of 6 characters

 LDA ESCP               \ If we don't have an escape pod fitted (i.e. ESCP is
 BEQ P%+7               \ zero), skip the following two instructions

 LDA #112               \ We do have an escape pod fitted, so print recursive
 JSR plf2               \ token 112 ("ESCAPE CAPSULE"), followed by a newline
                        \ and an indent of 6 characters

 LDA BST                \ If we don't have fuel scoops fitted, skip the
 BEQ P%+7               \ following two instructions

 LDA #111               \ We do have a fuel scoops fitted, so print recursive
 JSR plf2               \ token 111 ("FUEL SCOOPS"), followed by a newline and
                        \ an indent of 6 characters

 LDA ECM                \ If we don't have an E.C.M. fitted, skip the following
 BEQ P%+7               \ two instructions

 LDA #108               \ We do have an E.C.M. fitted, so print recursive token
 JSR plf2               \ 108 ("E.C.M.SYSTEM"), followed by a newline and an
                        \ indent of 6 characters

 LDA #113               \ We now cover the four pieces of equipment whose flags
 STA XX4                \ are stored in BOMB through BOMB+3, and whose names
                        \ correspond with text tokens 113 through 116:
                        \
                        \   BOMB+0 = BOMB  = token 113 = Energy bomb
                        \   BOMB+1 = ENGY  = token 114 = Energy unit
                        \   BOMB+2 = DKCMP = token 115 = Docking computer
                        \   BOMB+3 = GHYP  = token 116 = Galactic hyperdrive
                        \
                        \ We can print these out using a loop, so we set XX4 to
                        \ 113 as a counter (and we also set A as well, to pass
                        \ through to plf2)

.stqv

 TAY                    \ Fetch byte BOMB+0 through BOMB+4 for values of XX4
 LDX BOMB-113,Y         \ from 113 through 117

 BEQ P%+5               \ If it is zero then we do not own that piece of
                        \ equipment, so skip the next instruction

 JSR plf2               \ Print the recursive token in A from 113 ("ENERGY
                        \ BOMB") through 116 ("GALACTIC HYPERSPACE "), followed
                        \ by a newline and an indent of 6 characters

 INC XX4                \ Increment the counter (and A as well)
 LDA XX4

 CMP #117               \ If A < 117, loop back up to stqv to print the next
 BCC stqv               \ piece of equipment

 LDX #0                 \ Now to print our ship's lasers, so set a counter in X
                        \ to count through the four views (0 = front, 1 = rear,
                        \ 2 = left, 3 = right)

.st

 STX CNT                \ Store the view number in CNT

 LDY LASER,X            \ Fetch the laser power for view X, and if we do not
 BEQ st1                \ have a laser fitted to that view, jump to st1 to move
                        \ on to the next one

 TXA                    \ Print recursive token 96 + X, which will print from 96
 CLC                    \ ("FRONT") through to 99 ("RIGHT"), followed by a space
 ADC #96
 JSR spc

 LDA #103               \ Set A to token 103 ("PULSE LASER")

 LDX CNT                \ If the laser power for view X has bit 7 clear, then it
 LDY LASER,X            \ is a pulse laser, so skip the following instruction
 BPL P%+4

 LDA #104               \ Set A to token 104 ("BEAM LASER")

 JSR plf2               \ Print the text token in A (which contains our legal
                        \ status) followed by a newline and an indent of 6
                        \ characters

.st1

 LDX CNT                \ Increment the counter in X and CNT to point to the
 INX                    \ next view

 CPX #4                 \ If this isn't the last of the four views, jump back up
 BCC st                 \ to st to print out the next one

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: plf2
\       Type: Subroutine
\   Category: Text
\    Summary: Print text followed by a newline and indent of 6 characters
\
\ ------------------------------------------------------------------------------
\
\ Print a text token followed by a newline, and indent the next line to text
\ column 6.
\
\ Arguments:
\
\   A                   The text token to be printed
\
\ ******************************************************************************

.plf2

 JSR plf                \ Print the text token in A followed by a newline

 LDX #6                 \ Move the text cursor to column 6
 STX XC

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: TENS
\       Type: Variable
\   Category: Text
\    Summary: A constant used when printing large numbers in BPRNT
\  Deep dive: Printing decimal numbers
\
\ ------------------------------------------------------------------------------
\
\ Contains the four low bytes of the value 100,000,000,000 (100 billion).
\
\ The maximum number of digits that we can print with the BPRNT routine is 11,
\ so the biggest number we can print is 99,999,999,999. This maximum number
\ plus 1 is 100,000,000,000, which in hexadecimal is:
\
\   & 17 48 76 E8 00
\
\ The TENS variable contains the lowest four bytes in this number, with the
\ most significant byte first, i.e. 48 76 E8 00. This value is used in the
\ BPRNT routine when working out which decimal digits to print when printing a
\ number.
\
\ ******************************************************************************

.TENS

 EQUD &00E87648

\ ******************************************************************************
\
\       Name: pr2
\       Type: Subroutine
\   Category: Text
\    Summary: Print an 8-bit number, left-padded to 3 digits, and optional point
\
\ ------------------------------------------------------------------------------
\
\ Print the 8-bit number in X to 3 digits, left-padding with spaces for numbers
\ with fewer than 3 digits (so numbers < 100 are right-aligned). Optionally
\ include a decimal point.
\
\ Arguments:
\
\   X                   The number to print
\
\   C flag              If set, include a decimal point
\
\ Other entry points:
\
\   pr2+2               Print the 8-bit number in X to the number of digits in A
\
\ ******************************************************************************

.pr2

 LDA #3                 \ Set A to the number of digits (3)

 LDY #0                 \ Zero the Y register, so we can fall through into TT11
                        \ to print the 16-bit number (Y X) to 3 digits, which
                        \ effectively prints X to 3 digits as the high byte is
                        \ zero

\ ******************************************************************************
\
\       Name: TT11
\       Type: Subroutine
\   Category: Text
\    Summary: Print a 16-bit number, left-padded to n digits, and optional point
\
\ ------------------------------------------------------------------------------
\
\ Print the 16-bit number in (Y X) to a specific number of digits, left-padding
\ with spaces for numbers with fewer digits (so lower numbers will be right-
\ aligned). Optionally include a decimal point.
\
\ Arguments:
\
\   X                   The low byte of the number to print
\
\   Y                   The high byte of the number to print
\
\   A                   The number of digits
\
\   C flag              If set, include a decimal point
\
\ ******************************************************************************

.TT11

 STA U                  \ We are going to use the BPRNT routine (below) to
                        \ print this number, so we store the number of digits
                        \ in U, as that's what BPRNT takes as an argument

 LDA #0                 \ BPRNT takes a 32-bit number in K to K+3, with the
 STA K                  \ most significant byte first (big-endian), so we set
 STA K+1                \ the two most significant bytes to zero (K and K+1)
 STY K+2                \ and store (Y X) in the least two significant bytes
 STX K+3                \ (K+2 and K+3), so we are going to print the 32-bit
                        \ number (0 0 Y X)

                        \ Finally we fall through into BPRNT to print out the
                        \ number in K to K+3, which now contains (Y X), to 3
                        \ digits (as U = 3), using the same C flag as when pr2
                        \ was called to control the decimal point

\ ******************************************************************************
\
\       Name: BPRNT
\       Type: Subroutine
\   Category: Text
\    Summary: Print a 32-bit number, left-padded to a specific number of digits,
\             with an optional decimal point
\  Deep dive: Printing decimal numbers
\
\ ------------------------------------------------------------------------------
\
\ Print the 32-bit number stored in K(0 1 2 3) to a specific number of digits,
\ left-padding with spaces for numbers with fewer digits (so lower numbers are
\ right-aligned). Optionally include a decimal point.
\
\ See the deep dive on "Printing decimal numbers" for details of the algorithm
\ used in this routine.
\
\ Arguments:
\
\   K(0 1 2 3)          The number to print, stored with the most significant
\                       byte in K and the least significant in K+3 (i.e. as a
\                       big-endian number, which is the opposite way to how the
\                       6502 assembler stores addresses, for example)
\
\   U                   The maximum number of digits to print, including the
\                       decimal point (spaces will be used on the left to pad
\                       out the result to this width, so the number is right-
\                       aligned to this width). U must be 11 or less
\
\   C flag              If set, include a decimal point followed by one
\                       fractional digit (i.e. show the number to 1 decimal
\                       place). In this case, the number in K(0 1 2 3) contains
\                       10 * the number we end up printing, so to print 123.4,
\                       we would pass 1234 in K(0 1 2 3) and would set the C
\                       flag to include the decimal point
\
\ ******************************************************************************

.BPRNT

 LDX #11                \ Set T to the maximum number of digits allowed (11
 STX T                  \ characters, which is the number of digits in 10
                        \ billion). We will use this as a flag when printing
                        \ characters in TT37 below

 PHP                    \ Make a copy of the status register (in particular
                        \ the C flag) so we can retrieve it later

 BCC TT30               \ If the C flag is clear, we do not want to print a
                        \ decimal point, so skip the next two instructions

 DEC T                  \ As we are going to show a decimal point, decrement
 DEC U                  \ both the number of characters and the number of
                        \ digits (as one of them is now a decimal point)

.TT30

 LDA #11                \ Set A to 11, the maximum number of digits allowed

 SEC                    \ Set the C flag so we can do subtraction without the
                        \ C flag affecting the result

 STA XX17               \ Store the maximum number of digits allowed (11) in
                        \ XX17

 SBC U                  \ Set U = 11 - U + 1, so U now contains the maximum
 STA U                  \ number of digits minus the number of digits we want
 INC U                  \ to display, plus 1 (so this is the number of digits
                        \ we should skip before starting to print the number
                        \ itself, and the plus 1 is there to ensure we print at
                        \ least one digit)

 LDY #0                 \ In the main loop below, we use Y to count the number
                        \ of times we subtract 10 billion to get the leftmost
                        \ digit, so set this to zero

 STY S                  \ In the main loop below, we use location S as an
                        \ 8-bit overflow for the 32-bit calculations, so
                        \ we need to set this to 0 before joining the loop

 JMP TT36               \ Jump to TT36 to start the process of printing this
                        \ number's digits

.TT35

                        \ This subroutine multiplies K(S 0 1 2 3) by 10 and
                        \ stores the result back in K(S 0 1 2 3), using the fact
                        \ that K * 10 = (K * 2) + (K * 2 * 2 * 2)

 ASL K+3                \ Set K(S 0 1 2 3) = K(S 0 1 2 3) * 2 by rotating left
 ROL K+2
 ROL K+1
 ROL K
 ROL S

 LDX #3                 \ Now we want to make a copy of the newly doubled K in
                        \ XX15, so we can use it for the first (K * 2) in the
                        \ equation above, so set up a counter in X for copying
                        \ four bytes, starting with the last byte in memory
                        \ (i.e. the least significant)

.tt35

 LDA K,X                \ Copy the X-th byte of K(0 1 2 3) to the X-th byte of
 STA XX15,X             \ XX15(0 1 2 3), so that XX15 will contain a copy of
                        \ K(0 1 2 3) once we've copied all four bytes

 DEX                    \ Decrement the loop counter

 BPL tt35               \ Loop back to copy the next byte until we have copied
                        \ all four

 LDA S                  \ Store the value of location S, our overflow byte, in
 STA XX15+4             \ XX15+4, so now XX15(4 0 1 2 3) contains a copy of
                        \ K(S 0 1 2 3), which is the value of (K * 2) that we
                        \ want to use in our calculation

 ASL K+3                \ Now to calculate the (K * 2 * 2 * 2) part. We still
 ROL K+2                \ have (K * 2) in K(S 0 1 2 3), so we just need to shift
 ROL K+1                \ it twice. This is the first one, so we do this:
 ROL K                  \
 ROL S                  \   K(S 0 1 2 3) = K(S 0 1 2 3) * 2 = K * 4

 ASL K+3                \ And then we do it again, so that means:
 ROL K+2                \
 ROL K+1                \   K(S 0 1 2 3) = K(S 0 1 2 3) * 2 = K * 8
 ROL K
 ROL S

 CLC                    \ Clear the C flag so we can do addition without the
                        \ C flag affecting the result

 LDX #3                 \ By now we've got (K * 2) in XX15(4 0 1 2 3) and
                        \ (K * 8) in K(S 0 1 2 3), so the final step is to add
                        \ these two 32-bit numbers together to get K * 10.
                        \ So we set a counter in X for four bytes, starting
                        \ with the last byte in memory (i.e. the least
                        \ significant)

.tt36

 LDA K,X                \ Fetch the X-th byte of K into A

 ADC XX15,X             \ Add the X-th byte of XX15 to A, with carry

 STA K,X                \ Store the result in the X-th byte of K

 DEX                    \ Decrement the loop counter

 BPL tt36               \ Loop back to add the next byte, moving from the least
                        \ significant byte to the most significant, until we
                        \ have added all four

 LDA XX15+4             \ Finally, fetch the overflow byte from XX15(4 0 1 2 3)

 ADC S                  \ And add it to the overflow byte from K(S 0 1 2 3),
                        \ with carry

 STA S                  \ And store the result in the overflow byte from
                        \ K(S 0 1 2 3), so now we have our desired result, i.e.
                        \
                        \   K(S 0 1 2 3) = K(S 0 1 2 3) * 10

 LDY #0                 \ In the main loop below, we use Y to count the number
                        \ of times we subtract 10 billion to get the leftmost
                        \ digit, so set this to zero so we can rejoin the main
                        \ loop for another subtraction process

.TT36

                        \ This is the main loop of our digit-printing routine.
                        \ In the following loop, we are going to count the
                        \ number of times that we can subtract 10 million and
                        \ store that count in Y, which we have already set to 0

 LDX #3                 \ Our first calculation concerns 32-bit numbers, so
                        \ set up a counter for a four-byte loop

 SEC                    \ Set the C flag so we can do subtraction without the
                        \ C flag affecting the result

.tt37

                        \ We now loop through each byte in turn to do this:
                        \
                        \   XX15(4 0 1 2 3) = K(S 0 1 2 3) - 100,000,000,000

 LDA K,X                \ Subtract the X-th byte of TENS (i.e. 10 billion) from
 SBC TENS,X             \ the X-th byte of K

 STA XX15,X             \ Store the result in the X-th byte of XX15

 DEX                    \ Decrement the loop counter

 BPL tt37               \ Loop back to subtract the next byte, moving from the
                        \ least significant byte to the most significant, until
                        \ we have subtracted all four

 LDA S                  \ Subtract the fifth byte of 10 billion (i.e. &17) from
 SBC #&17               \ the fifth (overflow) byte of K, which is S

 STA XX15+4             \ Store the result in the overflow byte of XX15

 BCC TT37               \ If subtracting 10 billion took us below zero, jump to
                        \ TT37 to print out this digit, which is now in Y

 LDX #3                 \ We now want to copy XX15(4 0 1 2 3) back into
                        \ K(S 0 1 2 3), so we can loop back up to do the next
                        \ subtraction, so set up a counter for a four-byte loop

.tt38

 LDA XX15,X             \ Copy the X-th byte of XX15(0 1 2 3) to the X-th byte
 STA K,X                \ of K(0 1 2 3), so that K(0 1 2 3) will contain a copy
                        \ of XX15(0 1 2 3) once we've copied all four bytes

 DEX                    \ Decrement the loop counter

 BPL tt38               \ Loop back to copy the next byte, until we have copied
                        \ all four

 LDA XX15+4             \ Store the value of location XX15+4, our overflow
 STA S                  \ byte in S, so now K(S 0 1 2 3) contains a copy of
                        \ XX15(4 0 1 2 3)

 INY                    \ We have now managed to subtract 10 billion from our
                        \ number, so increment Y, which is where we are keeping
                        \ a count of the number of subtractions so far

 JMP TT36               \ Jump back to TT36 to subtract the next 10 billion

.TT37

 TYA                    \ If we get here then Y contains the digit that we want
                        \ to print (as Y has now counted the total number of
                        \ subtractions of 10 billion), so transfer Y into A

 BNE TT32               \ If the digit is non-zero, jump to TT32 to print it

 LDA T                  \ Otherwise the digit is zero. If we are already
                        \ printing the number then we will want to print a 0,
                        \ but if we haven't started printing the number yet,
                        \ then we probably don't, as we don't want to print
                        \ leading zeroes unless this is the only digit before
                        \ the decimal point
                        \
                        \ To help with this, we are going to use T as a flag
                        \ that tells us whether we have already started
                        \ printing digits:
                        \
                        \   * If T <> 0 we haven't printed anything yet
                        \
                        \   * If T = 0 then we have started printing digits
                        \
                        \ We initially set T above to the maximum number of
                        \ characters allowed, less 1 if we are printing a
                        \ decimal point, so the first time we enter the digit
                        \ printing routine at TT37, it is definitely non-zero

 BEQ TT32               \ If T = 0, jump straight to the print routine at TT32,
                        \ as we have already started printing the number, so we
                        \ definitely want to print this digit too

 DEC U                  \ We initially set U to the number of digits we want to
 BPL TT34               \ skip before starting to print the number. If we get
                        \ here then we haven't printed any digits yet, so
                        \ decrement U to see if we have reached the point where
                        \ we should start printing the number, and if not, jump
                        \ to TT34 to set up things for the next digit

 LDA #' '               \ We haven't started printing any digits yet, but we
 BNE tt34               \ have reached the point where we should start printing
                        \ our number, so call TT26 (via tt34) to print a space
                        \ so that the number is left-padded with spaces (this
                        \ BNE is effectively a JMP as A will never be zero)

.TT32

 LDY #0                 \ We are printing an actual digit, so first set T to 0,
 STY T                  \ to denote that we have now started printing digits as
                        \ opposed to spaces

 CLC                    \ The digit value is in A, so add ASCII "0" to get the
 ADC #'0'               \ ASCII character number to print

.tt34

 JSR TT26               \ Call TT26 to print the character in A and fall through
                        \ into TT34 to get things ready for the next digit

.TT34

 DEC T                  \ Decrement T but keep T >= 0 (by incrementing it
 BPL P%+4               \ again if the above decrement made T negative)
 INC T

 DEC XX17               \ Decrement the total number of characters left to
                        \ print, which we stored in XX17

 BMI rT10               \ If the result is negative, we have printed all the
                        \ characters, so jump down to rT10 to return from the
                        \ subroutine

 BNE P%+10              \ If the result is positive (> 0) then we still have
                        \ characters left to print, so loop back to TT35 (via
                        \ the JMP TT35 instruction below) to print the next
                        \ digit

 PLP                    \ If we get here then we have printed the exact number
                        \ of digits that we wanted to, so restore the C flag
                        \ that we stored at the start of the routine

 BCC P%+7               \ If the C flag is clear, we don't want a decimal point,
                        \ so loop back to TT35 (via the JMP TT35 instruction
                        \ below) to print the next digit

 LDA #'.'               \ Otherwise the C flag is set, so print the decimal
 JSR TT26               \ point

 JMP TT35               \ Loop back to TT35 to print the next digit

.rT10

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: BELL
\       Type: Subroutine
\   Category: Sound
\    Summary: Make a standard system beep
\
\ ------------------------------------------------------------------------------
\
\ This is the standard system beep as made by the VDU 7 statement in BBC BASIC.
\
\ ******************************************************************************

.BELL

 LDA #7                 \ Control code 7 makes a beep, so load this into A

                        \ Fall through into the TT26 print routine to
                        \ actually make the sound

\ ******************************************************************************
\
\       Name: TT26
\       Type: Subroutine
\   Category: Text
\    Summary: Print a character at the text cursor by poking into screen memory
\  Deep dive: Drawing text
\
\ ------------------------------------------------------------------------------
\
\ Print a character at the text cursor (XC, YC), do a beep, print a newline,
\ or delete left (backspace).
\
\ WRCHV is set to point here by the loading process.
\
\ Arguments:
\
\   A                   The character to be printed. Can be one of the
\                       following:
\
\                         * 7 (beep)
\
\                         * 10-13 (line feeds and carriage returns)
\
\                         * 32-95 (ASCII capital letters, numbers and
\                           punctuation)
\
\                         * 127 (delete the character to the left of the text
\                           cursor and move the cursor to the left)
\
\   XC                  Contains the text column to print at (the x-coordinate)
\
\   YC                  Contains the line number to print on (the y-coordinate)
\
\ Returns:
\
\   A                   A is preserved
\
\   X                   X is preserved
\
\   Y                   Y is preserved
\
\   C flag              The C flag is cleared
\
\ Other entry points:
\
\   RR3+1               Contains an RTS
\
\   RREN                Prints the character definition pointed to by P(2 1) at
\                       the screen address pointed to by (A SC). Used by the
\                       BULB routine
\
\   rT9                 Contains an RTS
\
\ ******************************************************************************

.TT26

 STA K3                 \ Store the A, X and Y registers, so we can restore
 STY YSAV2              \ them at the end (so they don't get changed by this
 STX XSAV2              \ routine)

 LDY QQ17               \ Load the QQ17 flag, which contains the text printing
                        \ flags

 CPY #255               \ If QQ17 = 255 then printing is disabled, so jump to
 BEQ RR4                \ RR4, which doesn't print anything, it just restores
                        \ the registers and returns from the subroutine

 CMP #7                 \ If this is a beep character (A = 7), jump to R5,
 BEQ R5                 \ which will emit the beep, restore the registers and
                        \ return from the subroutine

 CMP #32                \ If this is an ASCII character (A >= 32), jump to RR1
 BCS RR1                \ below, which will print the character, restore the
                        \ registers and return from the subroutine

 CMP #10                \ If this is control code 10 (line feed) then jump to
 BEQ RRX1               \ RRX1, which will move down a line, restore the
                        \ registers and return from the subroutine

 LDX #1                 \ If we get here, then this is control code 11-13, of
 STX XC                 \ which only 13 is used. This code prints a newline,
                        \ which we can achieve by moving the text cursor
                        \ to the start of the line (carriage return) and down
                        \ one line (line feed). These two lines do the first
                        \ bit by setting XC = 1, and we then fall through into
                        \ the line feed routine that's used by control code 10

.RRX1

 INC YC                 \ Print a line feed, simply by incrementing the row
                        \ number (y-coordinate) of the text cursor, which is
                        \ stored in YC

 BNE RR4                \ Jump to RR4 to restore the registers and return from
                        \ the subroutine (this BNE is effectively a JMP as Y
                        \ will never be zero)

.RR1

                        \ If we get here, then the character to print is an
                        \ ASCII character in the range 32-95. The quickest way
                        \ to display text on-screen is to poke the character
                        \ pixel by pixel, directly into screen memory, so
                        \ that's what the rest of this routine does
                        \
                        \ The first step, then, is to get hold of the bitmap
                        \ definition for the character we want to draw on the
                        \ screen (i.e. we need the pixel shape of this
                        \ character). The MOS ROM contains bitmap definitions
                        \ of the BBC's ASCII characters, starting from &C000
                        \ for space (ASCII 32) and ending with the £ symbol
                        \ (ASCII 126)
                        \
                        \ There are definitions for 32 characters in each of the
                        \ three pages of MOS memory, as each definition takes up
                        \ 8 bytes (8 rows of 8 pixels) and 32 * 8 = 256 bytes =
                        \ 1 page. So:
                        \
                        \   ASCII 32-63  are defined in &C000-&C0FF (page 0)
                        \   ASCII 64-95  are defined in &C100-&C1FF (page 1)
                        \   ASCII 96-126 are defined in &C200-&C2F0 (page 2)
                        \
                        \ The following code reads the relevant character
                        \ bitmap from the above locations in ROM and pokes
                        \ those values into the correct position in screen
                        \ memory, thus printing the character on-screen
                        \
                        \ It's a long way from 10 PRINT "Hello world!":GOTO 10

 TAY                    \ Copy the character number from A to Y, as we are
                        \ about to pull A apart to work out where this
                        \ character definition lives in memory

                        \ Now we want to set X to point to the relevant page
                        \ number for this character - i.e. &C0, &C1 or &C2.

                        \ The following logic is easier to follow if we look
                        \ at the three character number ranges in binary:
                        \
                        \   Bit #  76543210
                        \
                        \   32  = %00100000     Page 0 of bitmap definitions
                        \   63  = %00111111
                        \
                        \   64  = %01000000     Page 1 of bitmap definitions
                        \   95  = %01011111
                        \
                        \   96  = %01100000     Page 2 of bitmap definitions
                        \   125 = %01111101
                        \
                        \ We'll refer to this below

 LDX #&BF               \ Set X to point to the first font page in ROM minus 1,
                        \ which is &C0 - 1, or &BF

 ASL A                  \ If bit 6 of the character is clear (A is 32-63)
 ASL A                  \ then skip the following instruction
 BCC P%+4

 LDX #&C1               \ A is 64-126, so set X to point to page &C1

 ASL A                  \ If bit 5 of the character is clear (A is 64-95)
 BCC P%+3               \ then skip the following instruction

 INX                    \ Increment X
                        \
                        \ By this point, we started with X = &BF, and then
                        \ we did the following:
                        \
                        \   If A = 32-63:   skip    then INX  so X = &C0
                        \   If A = 64-95:   X = &C1 then skip so X = &C1
                        \   If A = 96-126:  X = &C1 then INX  so X = &C2
                        \
                        \ In other words, X points to the relevant page. But
                        \ what about the value of A? That gets shifted to the
                        \ left three times during the above code, which
                        \ multiplies the number by 8 but also drops bits 7, 6
                        \ and 5 in the process. Look at the above binary
                        \ figures and you can see that if we cleared bits 5-7,
                        \ then that would change 32-53 to 0-31... but it would
                        \ do exactly the same to 64-95 and 96-125. And because
                        \ we also multiply this figure by 8, A now points to
                        \ the start of the character's definition within its
                        \ page (because there are 8 bytes per character
                        \ definition)
                        \
                        \ Or, to put it another way, X contains the high byte
                        \ (the page) of the address of the definition that we
                        \ want, while A contains the low byte (the offset into
                        \ the page) of the address

 STA P+1                \ Store the address of this character's definition in
 STX P+2                \ P(2 1)

 LDA #&80               \ ???
 STA SC
 LDA YC
 CMP #&18
 BCC L1D3B

 JSR TTX66

 JMP RR4

.L1D3B

 LSR A
 ROR SC
 LSR A
 ROR SC
 ADC YC
 ADC #&58
 STA SCH

 LDA XC                 \ Fetch XC, the x-coordinate (column) of the text cursor
                        \ into A

 ASL A                  \ Multiply A by 8, and store in SC. As each character is
 ASL A                  \ 8 pixels wide, and the special screen mode Elite uses
 ASL A                  \ for the top part of the screen is 256 pixels across
 ADC SC                 \ ???
 STA SC                 \ with one bit per pixel, this value is not only the
                        \ screen address offset of the text cursor from the left
                        \ side of the screen, it's also the least significant
                        \ byte of the screen address where we want to print this
                        \ character, as each row of on-screen pixels corresponds
                        \ to one page. To put this more explicitly, the screen
                        \ starts at &6000, so the text rows are stored in screen
                        \ memory like this:
                        \
                        \   Row 1: &6000 - &60FF    YC = 1, XC = 0 to 31
                        \   Row 2: &6100 - &61FF    YC = 2, XC = 0 to 31
                        \   Row 3: &6200 - &62FF    YC = 3, XC = 0 to 31
                        \
                        \ and so on

 BCC L1D54              \ ???

 INC SCH

.L1D54

 CPY #127               \ If the character number (which is in Y) <> 127, then
 BNE RR2                \ skip to RR2 to print that character, otherwise this is
                        \ the delete character, so continue on

 DEC XC                 \ We want to delete the character to the left of the
                        \ text cursor and move the cursor back one, so let's
                        \ do that by decrementing YC. Note that this doesn't
                        \ have anything to do with the actual deletion below,
                        \ we're just updating the cursor so it's in the right
                        \ position following the deletion

 DEC SCH                \ ???

                        \ Because YC starts at 0 for the first text row, this
                        \ means that X will be &5F for row 0, &60 for row 1 and
                        \ so on. In other words, X is now set to the page number
                        \ for the row before the one containing the text cursor,
                        \ and given that we set SC above to point to the offset
                        \ in memory of the text cursor within the row's page,
                        \ this means that (X SC) now points to the character
                        \ above the text cursor

 LDY #&F8               \ Set Y = &F8, so the following call to ZES2 will count
                        \ Y upwards from &F8 to &FF

 JSR ZES2               \ Call ZES2, which zero-fills from address (X SC) + Y to
                        \ (X SC) + &FF. (X SC) points to the character above the
                        \ text cursor, and adding &FF to this would point to the
                        \ cursor, so adding &F8 points to the character before
                        \ the cursor, which is the one we want to delete. So
                        \ this call zero-fills the character to the left of the
                        \ cursor, which erases it from the screen

 BEQ RR4                \ We are done deleting, so restore the registers and
                        \ return from the subroutine (this BNE is effectively
                        \ a JMP as ZES2 always returns with the Z flag set)

.RR2

                        \ Now to actually print the character

 INC XC                 \ Once we print the character, we want to move the text
                        \ cursor to the right, so we do this by incrementing
                        \ XC. Note that this doesn't have anything to do
                        \ with the actual printing below, we're just updating
                        \ the cursor so it's in the right position following
                        \ the print

 EQUB &2C               \ ???

.RR3

                        \ A contains the value of YC - the screen row where we
                        \ want to print this character - so now we need to
                        \ convert this into a screen address, so we can poke
                        \ the character data to the right place in screen
                        \ memory

.RREN

 STA SC+1               \ Store the page number of the destination screen
                        \ location in SC+1, so SC now points to the full screen
                        \ location where this character should go

 LDY #7                 \ We want to print the 8 bytes of character data to the
                        \ screen (one byte per row), so set up a counter in Y
                        \ to count these bytes

.RRL1

 LDA (P+1),Y            \ The character definition is at P(2 1) - we set this up
                        \ above - so load the Y-th byte from P(2 1), which will
                        \ contain the bitmap for the Y-th row of the character

 EOR (SC),Y             \ If we EOR this value with the existing screen
                        \ contents, then it's reversible (so reprinting the
                        \ same character in the same place will revert the
                        \ screen to what it looked like before we printed
                        \ anything); this means that printing a white pixel on
                        \ onto a white background results in a black pixel, but
                        \ that's a small price to pay for easily erasable text

 STA (SC),Y             \ Store the Y-th byte at the screen address for this
                        \ character location

 DEY                    \ Decrement the loop counter

 BPL RRL1               \ Loop back for the next byte to print to the screen

.RR4

 LDY YSAV2              \ We're done printing, so restore the values of the
 LDX XSAV2              \ A, X and Y registers that we saved above and clear
 LDA K3                 \ the C flag, so everything is back to how it was
 CLC

.rT9

 RTS                    \ Return from the subroutine

.R5

 JSR BEEP               \ Call the BEEP subroutine to make a short, high beep

 JMP RR4                \ Jump to RR4 to restore the registers and return from
                        \ the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DIALS (Part 1 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: speed indicator
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ This routine updates the dashboard. First we draw all the indicators in the
\ right part of the dashboard, from top (speed) to bottom (energy banks), and
\ then we move on to the left part, again drawing from top (forward shield) to
\ bottom (altitude).
\
\ This first section starts us off with the speedometer in the top right.
\
\ ******************************************************************************

.DIALS

 LDA #&F0               \ ???
 STA SC
 LDA #&76
 STA SC+1

 LDA DELTA              \ Fetch our ship's speed into A, in the range 0-40

 JSR DIL                \ ???

\ ******************************************************************************
\
\       Name: DIALS (Part 2 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: pitch and roll indicators
\  Deep dive: The dashboard indicators
\
\ ******************************************************************************

 LDA #0                 \ Set R = P = 0 for the low bytes in the call to the ADD
 STA R                  \ routine below
 STA P

 LDA #8                 \ Set S = 8, which is the value of the centre of the
 STA S                  \ roll indicator

 LDA ALP1               \ Fetch the roll angle alpha as a value between 0 and
 LSR A                  \ 31, and divide by 4 to get a value of 0 to 7
 LSR A

 ORA ALP2               \ Apply the roll sign to the value, and flip the sign,
 EOR #%10000000         \ so it's now in the range -7 to +7, with a positive
                        \ roll angle alpha giving a negative value in A

 JSR ADD                \ We now add A to S to give us a value in the range 1 to
                        \ 15, which we can pass to DIL2 to draw the vertical
                        \ bar on the indicator at this position. We use the ADD
                        \ routine like this:
                        \
                        \ (A X) = (A 0) + (S 0)
                        \
                        \ and just take the high byte of the result. We use ADD
                        \ rather than a normal ADC because ADD separates out the
                        \ sign bit and does the arithmetic using absolute values
                        \ and separate sign bits, which we want here rather than
                        \ the two's complement that ADC uses

 JSR DIL2               \ Draw a vertical bar on the roll indicator at offset A
                        \ and increment SC to point to the next indicator (the
                        \ pitch indicator)

 LDA BETA               \ Fetch the pitch angle beta as a value between -8 and
                        \ +8

 LDX BET1               \ Fetch the magnitude of the pitch angle beta, and if it
 BEQ P%+4               \ is 0 (i.e. we are not pitching), skip the next
                        \ instruction

 SBC #1                 \ The pitch angle beta is non-zero, so set A = A - 1
                        \ (the C flag is set by the call to DIL2 above, so we
                        \ don't need to do a SEC). This gives us a value of A
                        \ from -7 to +7 because these are magnitude-based
                        \ numbers with sign bits, rather than two's complement
                        \ numbers

 JSR ADD                \ We now add A to S to give us a value in the range 1 to
                        \ 15, which we can pass to DIL2 to draw the vertical
                        \ bar on the indicator at this position (see the JSR ADD
                        \ above for more on this)

 JSR DIL2               \ Draw a vertical bar on the pitch indicator at offset A
                        \ and increment SC to point to the next indicator (the
                        \ four energy banks)

\ ******************************************************************************
\
\       Name: DIALS (Part 3 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: four energy banks
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ This and the next section only run once every four iterations of the main
\ loop, so while the speed, pitch and roll indicators update every iteration,
\ the other indicators update less often.
\
\ ******************************************************************************

 LDA MCNT               \ Fetch the main loop counter and calculate MCNT mod 4,
 AND #3                 \ jumping to rT9 if it is non-zero. rT9 contains an RTS,
 BNE rT9                \ so the following code only runs every 4 iterations of
                        \ the main loop, otherwise we return from the subroutine

 LDY #0                 \ Set Y = 0, for use in various places below

 LDX #3                 \ Set up a counter in X so we can zero the four bytes at
                        \ XX12, so we can then calculate each of the four energy
                        \ banks' values before drawing them later

.DLL23

 STY XX12,X             \ Set the X-th byte of XX12 to 0

 DEX                    \ Decrement the counter

 BPL DLL23              \ Loop back for the next byte until the four bytes at
                        \ XX12 are all zeroed

 LDX #3                 \ Set up a counter in X to loop through the 4 energy
                        \ bank indicators, so we can calculate each of the four
                        \ energy banks' values and store them in XX12

 LDA ENERGY             \ ???
 LSR A

 STA Q                  \ Set Q to A, so we can use Q to hold the remaining
                        \ energy as we work our way through each bank, from the
                        \ full ones at the bottom to the empty ones at the top

.DLL24

 SEC                    \ Set A = A - 32 to reduce the energy count by a full
 SBC #32                \ bank

 BCC DLL26              \ If the C flag is clear then A < 16, so this bank is
                        \ not full to the brim, and is therefore the last one
                        \ with any energy in it, so jump to DLL26

 STA Q                  \ This bank is full, so update Q with the energy of the
                        \ remaining banks

 LDA #32                \ Store this bank's level in XX12 as 32, as it is full,
 STA XX12,X             \ with XX12+3 for the bottom bank and XX12+0 for the top

 LDA Q                  \ Set A to the remaining energy level again

 DEX                    \ Decrement X to point to the next bank, i.e. the one
                        \ above the bank we just processed

 BPL DLL24              \ Loop back to DLL24 until we have either processed all
                        \ four banks, or jumped out early to DLL26 if the top
                        \ banks have no charge

 BMI DLL9               \ Jump to DLL9 as we have processed all four banks (this
                        \ BMI is effectively a JMP as A will never be positive)

.DLL26

 LDA Q                  \ If we get here then the bank we just checked is not
 STA XX12,X             \ fully charged, so store its value in XX12 (using Q,
                        \ which contains the energy of the remaining banks -
                        \ i.e. this one)

                        \ Now that we have the four energy bank values in XX12,
                        \ we can draw them, starting with the top bank in XX12
                        \ and looping down to the bottom bank in XX12+3, using Y
                        \ as a loop counter, which was set to 0 above

.DLL9

 LDA XX12,Y             \ Fetch the value of the Y-th indicator, starting from
                        \ the top

 STY P                  \ Store the indicator number in P for retrieval later

 JSR DIL                \ Draw the energy bank using a range of 0-15, and
                        \ increment SC to point to the next indicator (the
                        \ next energy bank down)

 LDY P                  \ Restore the indicator number into Y

 INY                    \ Increment the indicator number

 CPY #4                 \ Check to see if we have drawn the last energy bank

 BNE DLL9               \ Loop back to DLL9 if we have more banks to draw,
                        \ otherwise we are done

\ ******************************************************************************
\
\       Name: DIALS (Part 4 of 4)
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the dashboard: shields, fuel, laser & cabin temp, altitude
\  Deep dive: The dashboard indicators
\
\ ******************************************************************************

 LDA #&76               \ Set SC(1 0) = &7630, which is the screen address for
 STA SC+1               \ the character block containing the left end of the
 LDA #&30               \ top indicator in the left part of the dashboard, the
 STA SC                 \ one showing the forward shield

 LDA FSH                \ Draw the forward shield indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the aft shield)

 LDA ASH                \ Draw the aft shield indicator using a range of 0-255,
 JSR DILX               \ and increment SC to point to the next indicator (the
                        \ fuel level)

 LDA QQ14               \ Draw the fuel level indicator using a range of 0-63,
 JSR DILX+2             \ and increment SC to point to the next indicator (the
                        \ cabin temperature)

 SEC                    \ ???
 JSR L293D

 LDA GNTMP              \ Draw the laser temperature indicator using a range of
 JSR DILX               \ 0-255, and increment SC to point to the next indicator
                        \ (the altitude)

 LDA #240               \ Set T1 to 240, the threshold at which we change the
 STA T1                 \ altitude indicator's colour. As the altitude has a
                        \ range of 0-255, pixel 16 will not be filled in, and
                        \ 240 would change the colour when moving between pixels
                        \ 15 and 16, so this effectively switches off the colour
                        \ change for the altitude indicator

 STA K+1                \ Set K+1 (the colour we should show for low values) to
                        \ 240, or &F0 (dashboard colour 2, yellow/white), so the
                        \ altitude indicator always shows in this colour

 LDA ALTIT              \ Draw the altitude indicator using a range of 0-255
 JSR DILX

 JMP COMPAS             \ We have now drawn all the indicators, so jump to
                        \ COMPAS to draw the compass, returning from the
                        \ subroutine using a tail call

\ ******************************************************************************
\
\       Name: DILX
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update a bar-based indicator on the dashboard
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ The range of values shown on the indicator depends on which entry point is
\ called. For the default entry point of DILX, the range is 0-255 (as the value
\ passed in A is one byte). The other entry points are shown below.
\
\ Arguments:
\
\   A                   The value to be shown on the indicator (so the larger
\                       the value, the longer the bar)
\
\
\   SC(1 0)             The screen address of the first character block in the
\                       indicator
\
\ Other entry points:
\
\   DIL-1               The range of the indicator is 0-32 (for the speed
\                       indicator)
\
\   DIL                 The range of the indicator is 0-16 (for the energy
\                       banks)
\
\ ******************************************************************************

.DILX

 LSR A                  \ If we call DILX, we set A = A / 16, so A is 0-15
 LSR A

 LSR A                  \ If we call DIL-1, we set A = A / 2, so A is 0-15

.DIL

                        \ If we call DIL, we leave A alone, so A is 0-15

 STA Q                  \ Store the indicator value in Q, now reduced to 0-15,
                        \ which is the length of the indicator to draw in pixels

 LDX #&FF               \ Set R = &FF, to use as a mask for drawing each row of
 STX R                  \ each character block of the bar, starting with a full
                        \ character's width of 4 pixels

 LDY #2                 \ We want to start drawing the indicator on the third
                        \ line in this character row, so set Y to point to that
                        \ row's offset

 LDX #3                 \ Set up a counter in X for the width of the indicator,
                        \ which is 4 characters (each of which is 4 pixels wide,
                        \ to give a total width of 16 pixels)

.DL1

 LDA Q                  \ Fetch the indicator value (0-15) from Q into A

 CMP #8                 \ If Q < 8, then we need to draw the end cap of the
 BCC DL2                \ indicator, which is less than a full character's
                        \ width, so jump down to DL2 to do this

 SBC #8                 \ Otherwise we can draw an 8-pixel wide block, so
 STA Q                  \ subtract 8 from Q so it contains the amount of the
                        \ indicator that's left to draw after this character

 LDA R                  \ Fetch the shape of the indicator row that we need to
                        \ display from R, so we can use it as a mask when
                        \ painting the indicator. It will be &FF at this point
                        \ (i.e. a full 4-pixel row)

.DL5

 STA (SC),Y             \ Draw the shape of the mask on pixel row Y of the
                        \ character block we are processing

 INY                    \ Draw the next pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the third pixel row, incrementing Y
 STA (SC),Y

 TYA                    \ ???
 CLC
 ADC #&06
 BCC L1E4E

 INC SCH

.L1E4E

 TAY

 DEX                    \ Decrement the loop counter for the next character
                        \ block along in the indicator

 BMI DL6                \ If we just drew the last character block then we are
                        \ done drawing, so jump down to DL6 to finish off

 BPL DL1                \ Loop back to DL1 to draw the next character block of
                        \ the indicator (this BPL is effectively a JMP as A will
                        \ never be negative following the previous BMI)

.DL2

 EOR #7                 \ If we get here then we are drawing the indicator's
 STA Q                  \ end cap, so Q is < 8, and this EOR flips the bits, so
                        \ instead of containing the number of indicator columns
                        \ we need to fill in on the left side of the cap's
                        \ character block, Q now contains the number of blank
                        \ columns there should be on the right side of the cap's
                        \ character block

 LDA R                  \ Fetch the current mask from R, which will be &FF at
                        \ this point, so we need to turn Q of the columns on the
                        \ right side of the mask to black to get the correct end
                        \ cap shape for the indicator

.DL3

 ASL A                  \ ???

 DEC Q                  \ Decrement the counter for the number of columns to
                        \ blank out

 BPL DL3                \ If we still have columns to blank out in the mask,
                        \ loop back to DL3 until the mask is correct for the
                        \ end cap

 PHA                    \ Store the mask byte on the stack while we use the
                        \ accumulator for a bit

 LDA #0                 \ Change the mask so no bits are set, so the characters
 STA R                  \ after the one we're about to draw will be all blank

 LDA #99                \ Set Q to a high number (99, why not) so we will keep
 STA Q                  \ drawing blank characters until we reach the end of
                        \ the indicator row

 PLA                    \ Restore the mask byte from the stack so we can use it
                        \ to draw the end cap of the indicator

 JMP DL5                \ Jump back up to DL5 to draw the mask byte on-screen

.DL6

 SEC                    \ ???
 JMP L293D

\ ******************************************************************************
\
\       Name: DIL2
\       Type: Subroutine
\   Category: Dashboard
\    Summary: Update the roll or pitch indicator on the dashboard
\  Deep dive: The dashboard indicators
\
\ ------------------------------------------------------------------------------
\
\ The indicator can show a vertical bar in 16 positions, with a value of 8
\ showing the bar in the middle of the indicator.
\
\ In practice this routine is only ever called with A in the range 1 to 15, so
\ the vertical bar never appears in the leftmost position (though it does appear
\ in the rightmost).
\
\ Arguments:
\
\   A                   The offset of the vertical bar to show in the indicator,
\                       from 0 at the far left, to 8 in the middle, and 15 at
\                       the far right
\
\ Returns:
\
\   C flag              The C flag is set
\
\ ******************************************************************************

.DIL2

 LDY #1                 \ We want to start drawing the vertical indicator bar on
                        \ the second line in the indicator's character block, so
                        \ set Y to point to that row's offset

 STA Q                  \ Store the offset of the vertical bar to draw in Q

                        \ We are now going to work our way along the indicator
                        \ on the dashboard, from left to right, working our way
                        \ along one character block at a time. Y will be used as
                        \ a pixel row counter to work our way through the
                        \ character blocks, so each time we draw a character
                        \ block, we will increment Y by 8 to move on to the next
                        \ block (as each character block contains 8 rows)

.DLL10

 SEC                    \ Set A = Q - 4, so that A contains the offset of the
 LDA Q                  \ vertical bar from the start of this character block
 SBC #4

 BCS DLL11              \ If Q >= 4 then the character block we are drawing does
                        \ not contain the vertical indicator bar, so jump to
                        \ DLL11 to draw a blank character block

 LDA #&FF               \ Set A to a high number (and &FF is as high as they go)

 LDX Q                  \ Set X to the offset of the vertical bar, which we know
                        \ is within this character block

 STA Q                  \ Set Q to a high number (&FF, why not) so we will keep
                        \ drawing blank characters after this one until we reach
                        \ the end of the indicator row

 LDA CTWOS,X            \ CTWOS is a table of ready-made 1-pixel mode 5 bytes,
                        \ just like the TWOS and TWOS2 tables for mode 4 (see
                        \ the PIXEL routine for details of how they work). This
                        \ fetches a mode 5 1-pixel byte with the pixel position
                        \ at X, so the pixel is at the offset that we want for
                        \ our vertical bar

 BNE DLL12              \ Jump to DLL12 to skip the code for drawing a blank,
                        \ and move on to drawing the indicator (this BNE is
                        \ effectively a JMP as A is always non-zero)

.DLL11

                        \ If we get here then we want to draw a blank for this
                        \ character block

 STA Q                  \ Update Q with the new offset of the vertical bar, so
                        \ it becomes the offset after the character block we
                        \ are about to draw

 LDA #0                 \ Change the mask so no bits are set, so all of the
                        \ character blocks we display from now on will be blank
.DLL12

 STA (SC),Y             \ Draw the shape of the mask on pixel row Y of the
                        \ character block we are processing

 INY                    \ Draw the next pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the third pixel row, incrementing Y
 STA (SC),Y

 INY                    \ And draw the fourth pixel row, incrementing Y
 STA (SC),Y

 TYA                    \ Add 5 to Y, so Y is now 8 more than when we started
 CLC                    \ this loop iteration, so Y now points to the address
 ADC #5                 \ of the first line of the indicator bar in the next
 TAY                    \ character block (as each character is 8 bytes of
                        \ screen memory)

 CPY #30                \ If Y < 30 then we still have some more character
 BCC DLL10              \ blocks to draw, so loop back to DLL10 to display the
                        \ next one along

 JMP L293D

\ ******************************************************************************
\
\       Name: ESCAPE
\       Type: Subroutine
\   Category: Flight
\    Summary: Launch our escape pod
\
\ ------------------------------------------------------------------------------
\
\ This routine displays our doomed Cobra Mk III disappearing off into the ether
\ before arranging our replacement ship. Called when we press ESCAPE during
\ flight and have an escape pod fitted.
\
\ ******************************************************************************

.ESCAPE

 JSR RES2               \ Reset a number of flight variables and workspaces

.ESL1

 JSR RESET              \ Call RESET to reset our ship and various controls

 LDA #0                 \ Set A = 0 so we can use it to zero the contents of
                        \ the cargo hold

 LDX #16                \ We lose all our cargo when using our escape pod, so
                        \ up a counter in X so we can zero the 17 cargo slots
                        \ in QQ20

.ESL2

 STA QQ20,X             \ Set the X-th byte of QQ20 to zero (as we know A = 0
                        \ from the BEQ above), so we no longer have any of item
                        \ type X in the cargo hold

 DEX                    \ Decrement the counter

 BPL ESL2               \ Loop back to ESL2 until we have emptied the entire
                        \ cargo hold

 STA FIST               \ Launching an escape pod also clears our criminal
                        \ record, so set our legal status in FIST to 0 ("clean")

 STA ESCP               \ The escape pod is a one-use item, so set ESCP to 0 so
                        \ we no longer have one fitted

 LDA #70                \ Our replacement ship is delivered with a full tank of
 STA QQ14               \ fuel, so set the current fuel level in QQ14 to 70, or
                        \ 7.0 light years

 JMP BAY                \ Go to the docking bay (i.e. show the Status Mode
                        \ screen) and return from the subroutine with a tail
                        \ call

\ ******************************************************************************
\
\ Save output/ELTB.bin
\
\ ******************************************************************************

PRINT "ELITE B"
PRINT "Assembled at ", ~CODE_B%
PRINT "Ends at ", ~P%
PRINT "Code size is ", ~(P% - CODE_B%)
PRINT "Execute at ", ~LOAD%
PRINT "Reload at ", ~LOAD_B%

PRINT "S.ELTB ", ~CODE_B%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD_B%
SAVE "output/ELTB.bin", CODE_B%, P%, LOAD%

\ ******************************************************************************
\
\ ELITE C FILE
\
\ Produces the binary file ELTC.bin that gets loaded by elite-bcfs.asm.
\
\ ******************************************************************************

CODE_C% = P%
LOAD_C% = LOAD% +P% - CODE%

.TA34

 LDA #&00
 JSR MAS4

 BEQ L1EC9

 JMP TA21

.L1EC9

 JSR L1F2B

 JSR EXNO3

 LDA #&FA
 JMP OOPS

.TA18

 LDA ECMA
 BNE TA35

 LDA INWK+32
 ASL A
 BMI TA34

 LSR A
 TAX
 LDA UNIV,X
 STA V
 LDA UNIV+1,X
 STA V+1
 LDY #&02
 JSR TAS1

 LDY #&05
 JSR TAS1

 LDY #&08
 JSR TAS1

 LDA K3+2
 ORA K3+5
 ORA K3+8
 AND #&7F
 ORA K3+1
 ORA K3+4
 ORA K3+7
 BNE TA64

 LDA INWK+32
 CMP #&82
 BEQ TA35

 LDY #&1F
 LDA (V),Y
 BIT L1F39
 BNE TA35

 ORA #&80
 STA (V),Y

.TA35

 LDA INWK
 ORA INWK+3
 ORA INWK+6
 BNE TA87

 LDA #&50
 JSR OOPS

.TA87

 JSR EXNO2

.L1F2B

 ASL INWK+31
 SEC
 ROR INWK+31

.TA1

 RTS

.TA64

 JSR DORND

 CMP #&10
 BCS TA19

.M32

 LDY #&20
L1F39 = M32+1
 LDA (V),Y
 LSR A
 BCC TA19

 JMP ECBLB2

.TACTICS

 CPX #&08
 BEQ TA18

 CPX #&0B
 BNE L1F50

 JSR SPS1

 JMP TA15

.L1F50

 CPX #&07
 BNE TA13

 JSR DORND

 CMP #&8C
 BCC TA1

 LDA MANY+2
 CMP #&03
 BCS TA1

 LDX #&02
 LDA #&E1
 JMP SFS1

.TA13

 CPX #&06
 BCS TA62

 CPX #&02
 BEQ TA62

 LDA SSPR
 BEQ TA62

 LDA INWK+32
 AND #&81
 STA INWK+32

.TA62

 LDY #&0E
 LDA INWK+35
 CMP (XX0),Y
 BCS TA21

 INC INWK+35

.TA21

 LDX #&08

.TAL1

 LDA INWK,X
 STA K3,X
 DEX
 BPL TAL1

.TA19

 JSR TAS2

 LDY #&0A
 JSR TAS3

 STA CNT
 LDA TYPE
 CMP #&08
 BNE L1FA2

 JMP TA20

.L1FA2

 JSR DORND

 CMP #&FA
 BCC TA7

 JSR DORND

 ORA #&68
 STA INWK+29

.TA7

 LDY #&0E
 LDA (XX0),Y
 LSR A
 CMP INWK+35
 BCC TA3

 LSR A
 LSR A
 CMP INWK+35
 BCC ta3

 JSR DORND

 CMP #&E6
 BCC ta3

 LDA #&00
 STA INWK+32
 JMP SESCP

.ta3

 LDA INWK+31
 AND #&07
 BEQ TA3

 STA T
 JSR DORND

 AND #&1F
 CMP T
 BCS TA3

 LDA ECMA
 BNE TA3

 DEC INWK+31
 LDA TYPE
 JMP SFRMIS

.TA3

 LDA #&00
 JSR MAS4

 AND #&E0
 BNE TA4

 LDX CNT
 CPX #&A0
 BCC TA4

 LDA INWK+31
 ORA #&40
 STA INWK+31
 CPX #&A3
 BCC TA4

 LDY #&13
 LDA (XX0),Y
 LSR A
 JSR OOPS

 DEC INWK+28
 LDA ECMA
 BNE TA10

 LDA #&08
 JMP NOISE

.TA4

 LDA INWK+7
 CMP #&03
 BCS TA5

 LDA INWK+1
 ORA INWK+4
 AND #&FE
 BEQ TA15

.TA5

 JSR DORND

 ORA #&80
 CMP INWK+32
 BCS TA15

.TA20

 LDA XX15
 EOR #&80
 STA XX15
 LDA Y1
 EOR #&80
 STA Y1
 LDA X2
 EOR #&80
 STA X2
 LDA CNT
 EOR #&80
 STA CNT

.TA15

 LDY #&10
 JSR TAS3

 EOR #&80
 AND #&80
 ORA #&03
 STA INWK+30
 LDA INWK+29
 AND #&7F
 CMP #&10
 BCS TA6

 LDY #&16
 JSR TAS3

 EOR INWK+30
 AND #&80
 EOR #&85
 STA INWK+29

.TA6

 LDA CNT
 BMI TA9

 CMP #&16
 BCC TA9

 LDA #&03
 STA INWK+28
 RTS

.TA9

 AND #&7F
 CMP #&12
 BCC TA10

 LDA #&FF
 LDX TYPE
 CPX #&08
 BNE L2082

 ASL A

.L2082

 STA INWK+28

.TA10

 RTS

.TAS1

 LDA (V),Y
 EOR #&80
 STA K+3
 DEY
 LDA (V),Y
 STA K+2
 DEY
 LDA (V),Y
 STA K+1
 STY U
 LDX U
 JSR MVT3

 LDY U
 STA K3+2,X
 LDA K+2
 STA K3+1,X
 LDA K+1
 STA K3,X
 RTS

.HITCH

 CLC
 LDA INWK+8
 BNE HI1

 LDA TYPE
 BMI HI1

 LDA INWK+31
 AND #&20
 ORA INWK+1
 ORA INWK+4
 BNE HI1

 LDA INWK
 JSR SQUA2

 STA S
 LDA P
 STA R
 LDA INWK+3
 JSR SQUA2

 TAX
 LDA P
 ADC R
 STA R
 TXA
 ADC S
 BCS L2157

 STA S
 LDY #&02
 LDA (XX0),Y
 CMP S
 BNE HI1

 DEY
 LDA (XX0),Y
 CMP R

.HI1

 RTS

.FRS1

 JSR ZINF

 LDA #&1C
 STA INWK+3
 LSR A
 STA INWK+6
 LDA #&80
 STA INWK+5
 LDA MSTG
 ASL A
 ORA #&80
 STA INWK+32

.fq1

 LDA #&60
 STA INWK+14
 ORA #&80
 STA INWK+22
 LDA DELTA
 ROL A
 STA INWK+27
 TXA
 JMP NWSHP

.FRMIS

 LDX #&08
 JSR FRS1

 BCC FR1

 LDX MSTG
 JSR GINF

 LDA FRIN,X
 JSR ANGRY

 LDY #&04
 JSR ABORT

 DEC NOMSL
 LDA #&30
 JMP NOISE

.ANGRY

 CMP #&07
 BEQ AN2

 BCS HI1

 CMP #&06
 BNE L213A

 JSR AN2

.L213A

 LDY #&20
 LDA (INF),Y
 BEQ HI1

 ORA #&80
 STA (INF),Y
 LDY #&1C
 LDA #&02
 STA (INF),Y
 ASL A
 LDY #&1E
 STA (INF),Y
 RTS

.AN2

 ASL K%+&44
 SEC
 ROR K%+&44

.L2157

 CLC
 RTS

.FR1

 LDA #&C9
 JMP MESS

.SESCP

 LDX #&0B

.L2160

 LDA #&FE

.SFS1

 STA T1
 LDA XX0
 PHA
 LDA XX0+1
 PHA
 LDA INF
 PHA
 LDA INF+1
 PHA
 LDY #&23

.FRL2

 LDA INWK,Y
 STA XX3,Y
 LDA (INF),Y
 STA INWK,Y
 DEY
 BPL FRL2

 LDA TYPE
 CMP #&07
 BNE rx

 TXA
 PHA
 LDA #&20
 STA INWK+27
 LDX #&00
 LDA INWK+10
 JSR SFS2

 LDX #&03
 LDA INWK+12
 JSR SFS2

 LDX #&06
 LDA INWK+14
 JSR SFS2

 PLA
 TAX

.rx

 LDA T1
 STA INWK+32
 LSR INWK+29
 ASL INWK+29
 TXA
 CMP #&0A
 BNE NOIL

 JSR DORND

 ASL A
 STA INWK+30
 TXA
 AND #&0F
 STA INWK+27
 LDA #&FF
 ROR A
 STA INWK+29
 LDA #&0A

.NOIL

 JSR NWSHP

 PLA
 STA INF+1
 PLA
 STA INF
 LDX #&23

.FRL3

 LDA XX3,X
 STA INWK,X
 DEX
 BPL FRL3

 PLA
 STA XX0+1
 PLA
 STA XX0
 RTS

.SFS2

 ASL A
 STA R
 LDA #&00
 ROR A
 JMP MVT1

.LL164

 LDA #&38
 JSR NOISE

 LDA #&01
 STA HFX
 LDA #&04
 JSR HFS2

 DEC HFX
 RTS

.LAUN

 LDA #&30
 JSR NOISE

 LDA #&08

.HFS2

 STA STP
 JSR TTX66

 JSR HFS1

.HFS1

 LDA #&80
 STA K3
 LDX #&60
 STX K4
 ASL A
 STA XX4
 STA K3+1
 STA K4+1

.HFL5

 JSR HFL1

 INC XX4
 LDX XX4
 CPX #&08
 BNE HFL5

 RTS

.HFL1

 LDA XX4
 AND #&07
 CLC
 ADC #&08
 STA K

.HFL2

 LDA #&01
 STA LSP
 JSR CIRCLE2

 ASL K
 BCS HF8

 LDA K
 CMP #&A0
 BCC HFL2

.HF8

 RTS

.STARS2

 LDA #&00
 CPX #&02
 ROR A
 STA RAT
 EOR #&80
 STA RAT2
 JSR ST2

 LDY #&0A

.STL2

 LDA SZ,Y
 STA ZZ
 LSR A
 LSR A
 LSR A
 JSR DV41

 LDA P
 EOR RAT2
 STA S
 LDA SXL,Y
 STA P
 LDA SX,Y
 STA XX15
 JSR ADD

 STA S
 STX R
 LDA SY,Y
 STA Y1
 EOR BET2
 LDX BET1
 JSR MULTS-2

 JSR ADD

 STX XX
 STA XX+1
 LDX SYL,Y
 STX R
 LDX Y1
 STX S
 LDX BET1
 EOR BET2+1
 JSR MULTS-2

 JSR ADD

 STX YY
 STA YY+1
 LDX ALP1
 EOR ALP2
 JSR MULTS-2

 STA Q
 LDA XX
 STA R
 LDA XX+1
 STA S
 EOR #&80
 JSR MAD

 STA XX+1
 TXA
 STA SXL,Y
 LDA YY
 STA R
 LDA YY+1
 STA S
 JSR MAD

 STA S
 STX R
 LDA #&00
 STA P
 LDA ALPHA
 JSR PIX1

 LDA XX+1
 STA SX,Y
 STA XX15
 AND #&7F
 CMP #&74
 BCS KILL2

 LDA YY+1
 STA SY,Y
 STA Y1
 AND #&7F
 CMP #&74
 BCS L231E

.STC2

 JSR PIXEL2

 DEY
 BEQ ST2

 JMP STL2

.ST2

 LDA ALPHA
 EOR RAT
 STA ALPHA
 LDA ALP2
 EOR RAT
 STA ALP2
 EOR #&80
 STA ALP2+1
 LDA BET2
 EOR RAT
 STA BET2
 EOR #&80
 STA BET2+1
 RTS

.KILL2

 JSR DORND

 STA Y1
 STA SY,Y
 LDA #&73
 ORA RAT
 STA XX15
 STA SX,Y
 BNE STF1

.L231E

 JSR DORND

 STA XX15
 STA SX,Y
 LDA #&6E
 ORA ALP2+1
 STA Y1
 STA SY,Y

.STF1

 JSR DORND

 ORA #&08
 STA ZZ
 STA SZ,Y
 BNE STC2

.L233B

 EQUB &00

 EQUB &19, &32, &4A, &62, &79, &8E, &A2, &B5
 EQUB &C6, &D5, &E2, &ED, &F5, &FB, &FF, &FF
 EQUB &FF, &FB, &F5, &ED, &E2, &D5, &C6, &B5
 EQUB &A2, &8E, &79, &62, &4A, &32, &19

.MU5

 STA K
 STA K+1
 STA K+2
 STA K+3
 CLC
 RTS

.MULT3

 STA R
 AND #&7F
 STA K+2
 LDA Q
 AND #&7F
 BEQ MU5

 SEC
 SBC #&01
 STA T
 LDA P+1
 LSR K+2
 ROR A
 STA K+1
 LDA P
 ROR A
 STA K
 LDA #&00
 LDX #&18

.MUL2

 BCC L238A

 ADC T

.L238A

 ROR A
 ROR K+2
 ROR K+1
 ROR K
 DEX
 BNE MUL2

 STA T
 LDA R
 EOR Q
 AND #&80
 ORA T
 STA K+3
 RTS

.MLS2

 LDX XX
 STX R
 LDX XX+1
 STX S

.MLS1

 LDX ALP1

 STX P

.MULTS

 TAX
 AND #&80
 STA T
 TXA
 AND #&7F
 BEQ MU6

 TAX
 DEX
 STX T1
 LDA #&00
 LSR P
 BCC L23C3

 ADC T1

.L23C3

 ROR A
 ROR P
 BCC L23CA

 ADC T1

.L23CA

 ROR A
 ROR P
 BCC L23D1

 ADC T1

.L23D1

 ROR A
 ROR P
 BCC L23D8

 ADC T1

.L23D8

 ROR A
 ROR P
 BCC L23DF

 ADC T1

.L23DF

 ROR A
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P
 LSR A
 ROR P
 ORA T
 RTS

.SQUA

 AND #&7F

.SQUA2

 STA P
 TAX
 BNE MU11

.MU1

 CLC
 STX P
 TXA
 RTS

.MLU1

 LDA SY,Y
 STA Y1

.MLU2

 AND #&7F
 STA P

.MULTU

 LDX Q
 BEQ MU1

.MU11

 DEX
 STX T
 LDA #&00
 LDX #&08
 LSR P

.MUL6

 BCC L2414

 ADC T

.L2414

 ROR A
 ROR P
 DEX
 BNE MUL6

 RTS

.MU6

 STA P+1
 STA P
 RTS

.FMLTU2

 AND #&1F
 TAX
 LDA L233B,X
 STA Q
 LDA K

.FMLTU

 EOR #&FF
 SEC
 ROR A
 STA P
 LDA #&00

.MUL3

 BCS MU7

 ADC Q
 ROR A
 LSR P
 BNE MUL3

 RTS

.MU7

 LSR A
 LSR P
 BNE MUL3

 RTS

 LDX Q
 BEQ MU1

 DEX
 STX T
 LDA #&00
 LDX #&08
 LSR P

.L244F

 BCC L2453

 ADC T

.L2453

 ROR A
 ROR P
 DEX
 BNE L244F

 RTS

.L245A

 STX Q

.MLTU2

 EOR #&FF
 LSR A
 STA P+1
 LDA #&00
 LDX #&10
 ROR P

.MUL7

 BCS MU21

 ADC Q
 ROR A
 ROR P+1
 ROR P
 DEX
 BNE MUL7

 RTS

.MU21

 LSR A
 ROR P+1
 ROR P
 DEX
 BNE MUL7

 RTS

 LDX ALP1
 STX P

.MUT2

 LDX XX+1
 STX S

.MUT1

 LDX XX
 STX R

.MULT1

 TAX
 AND #&7F
 LSR A
 STA P
 TXA
 EOR Q
 AND #&80
 STA T
 LDA Q
 AND #&7F
 BEQ mu10

 TAX
 DEX
 STX T1
 LDA #&00
 LDX #&07

.MUL4

 BCC L24A8

 ADC T1

.L24A8

 ROR A
 ROR P
 DEX
 BNE MUL4

 LSR A
 ROR P
 ORA T
 RTS

.mu10

 STA P
 RTS

.MULT12

 JSR MULT1

 STA S
 LDA P
 STA R
 RTS

.TAS3

 LDX INWK,Y
 STX Q
 LDA XX15
 JSR MULT12

 LDX INWK+2,Y
 STX Q
 LDA Y1
 JSR MAD

 STA S
 STX R
 LDX INWK+4,Y
 STX Q
 LDA X2

.MAD

 JSR MULT1

.ADD

 STA T1
 AND #&80
 STA T
 EOR S
 BMI MU8

 LDA R
 CLC
 ADC P
 TAX
 LDA S
 ADC T1
 ORA T
 RTS

.MU8

 LDA S
 AND #&7F
 STA U
 LDA P
 SEC
 SBC R
 TAX
 LDA T1
 AND #&7F
 SBC U
 BCS MU9

 STA U
 TXA
 EOR #&FF
 ADC #&01
 TAX
 LDA #&00
 SBC U
 ORA #&80

.MU9

 EOR T
 RTS

.TIS1

 STX Q
 EOR #&80
 JSR MAD

 TAX
 AND #&80
 STA T
 TXA
 AND #&7F
 LDX #&FE
 STX T1

.DVL3

 ASL A
 CMP #&60
 BCC DV4

 SBC #&60

.DV4

 ROL T1
 BCS DVL3

 LDA T1
 ORA T
 RTS

.DV42

 LDA SZ,Y

.DV41

 STA Q
 LDA DELTA

.DVID4

 LDX #&08
 ASL A
 STA P
 LDA #&00

.DVL4

 ROL A
 BCS DV8

 CMP Q
 BCC DV5

.DV8

 SBC Q
 SEC

.DV5

 ROL P
 DEX
 BNE DVL4

 JMP L4630

.DVID3B2

 STA P+2
 LDA INWK+6
 STA Q
 LDA INWK+7
 STA R
 LDA INWK+8
 STA S
 LDA P
 ORA #&01
 STA P
 LDA P+2
 EOR S
 AND #&80
 STA T
 LDY #&00
 LDA P+2
 AND #&7F

.DVL9

 CMP #&40
 BCS DV14

 ASL P
 ROL P+1
 ROL A
 INY
 BNE DVL9

.DV14

 STA P+2
 LDA S
 AND #&7F
 BMI DV9

.DVL6

 DEY
 ASL Q
 ROL R
 ROL A
 BPL DVL6

.DV9

 STA Q
 LDA #&FE
 STA R
 LDA P+2
 JSR LL31

 LDA #&00
 STA K+1
 STA K+2
 STA K+3
 TYA
 BPL DV12

 LDA R

.DVL8

 ASL A
 ROL K+1
 ROL K+2
 ROL K+3
 INY
 BNE DVL8

 STA K
 LDA K+3
 ORA T
 STA K+3
 RTS

.DV13

 LDA R
 STA K
 LDA T
 STA K+3
 RTS

.DV12

 BEQ DV13

 LDA R

.DVL10

 LSR A
 DEY
 BNE DVL10

 STA K
 LDA T
 STA K+3
 RTS

.cntr

 LDA DAMP
 BNE RE1

 TXA
 BPL BUMP

 DEX
 BMI RE1

.BUMP

 INX
 BNE RE1

 DEX
 BEQ BUMP

.RE1

 RTS

.BUMP2

 STA T
 TXA
 CLC
 ADC T
 TAX
 BCC RE2

 LDX #&FF

.RE2

 BPL L260F

.L25FF

 LDA T
 RTS

.REDU2

 STA T
 TXA
 SEC
 SBC T
 TAX
 BCS RE3

 LDX #&01

.RE3

 BPL L25FF

.L260F

 LDA DJD
 BNE L25FF

 LDX #&80
 BMI L25FF

 LDA P
 EOR Q
 STA T1
 LDA Q
 BEQ AR2

 ASL A
 STA Q
 LDA P
 ASL A
 CMP Q
 BCS AR1

 JSR ARS1

 SEC

.AR4

 LDX T1
 BMI AR3

 RTS

.AR1

 LDX Q
 STA Q
 STX P
 TXA
 JSR ARS1

 STA T
 LDA #&40
 SBC T
 BCS AR4

.AR2

 LDA #&3F
 RTS

.AR3

 STA T
 LDA #&80
 SBC T
 RTS

.ARS1

 JSR LL28

 LDA R
 LSR A
 LSR A
 LSR A
 TAX
 LDA L265E,X
 RTS

.L265E

 EQUB &00

 EQUB &01, &03, &04, &05, &06, &08, &09, &0A
 EQUB &0B, &0C, &0D, &0F, &10, &11, &12, &13
 EQUB &14, &15, &16, &17, &18, &19, &19, &1A
 EQUB &1B, &1C, &1D, &1D, &1E, &1F, &1F

.WARP

 LDA MANY+9
 CLC
 ADC MANY+11
 CLC
 ADC MANY+10
 TAX
 LDA FRIN+2,X
 ORA SSPR
 BNE WA1

 LDY K%+8
 BMI WA3

 TAY
 JSR MAS2

 CMP #&02
 BCC WA1

.WA3

 LDY K%+&2C
 BMI WA2

 LDY #&24
 JSR m

 CMP #&02
 BCC WA1

.WA2

 LDA #&81
 STA S
 STA R
 STA P
 LDA K%+8
 JSR ADD

 STA K%+8
 LDA K%+&2C
 JSR ADD

 STA K%+&2C
 LDA #&01
 STA QQ11
 STA MCNT
 LSR A
 STA EV
 LDX VIEW
 JMP LOOK1

.WA1

 LDA #&28
 JMP NOISE

.LASLI

 JSR DORND

 AND #&07
 ADC #&5C
 STA LASY
 JSR DORND

 AND #&07
 ADC #&7C
 STA LASX
 LDA GNTMP
 ADC #&08
 STA GNTMP
 JSR DENGY

.LASLI2

 LDA QQ11
 BNE L2735

 LDA #&20
 LDY #&E0
 JSR L270A

 LDA #&30
 LDY #&D0

.L270A

 STA X2
 LDA LASX
 STA XX15
 LDA LASY
 STA Y1
 LDA #&BF
 STA Y2
 JSR LL30

 LDA LASX
 STA XX15
 LDA LASY
 STA Y1
 STY X2
 LDA #&BF
 STA Y2
 JMP LL30

.PLUT

 LDX VIEW
 BNE PU1

.L2735

 RTS

.PU1

 DEX
 BNE PU2

 LDA INWK+2
 EOR #&80
 STA INWK+2
 LDA INWK+8
 EOR #&80
 STA INWK+8
 LDA INWK+10
 EOR #&80
 STA INWK+10
 LDA INWK+14
 EOR #&80
 STA INWK+14
 LDA INWK+16
 EOR #&80
 STA INWK+16
 LDA INWK+20
 EOR #&80
 STA INWK+20
 LDA INWK+22
 EOR #&80
 STA INWK+22
 LDA INWK+26
 EOR #&80
 STA INWK+26
 RTS

.PU2

 LDA #&00
 CPX #&02
 ROR A
 STA RAT2
 EOR #&80
 STA RAT
 LDA INWK
 LDX INWK+6
 STA INWK+6
 STX INWK
 LDA INWK+1
 LDX INWK+7
 STA INWK+7
 STX INWK+1
 LDA INWK+2
 EOR RAT
 TAX
 LDA INWK+8
 EOR RAT2
 STA INWK+2
 STX INWK+8
 LDY #&09
 JSR PUS1

 LDY #&0F
 JSR PUS1

 LDY #&15

.PUS1

 LDA INWK,Y
 LDX INWK+4,Y
 STA INWK+4,Y
 STX INWK,Y
 LDA INWK+1,Y
 EOR RAT
 TAX
 LDA INWK+5,Y
 EOR RAT2
 STA INWK+1,Y
 STX INWK+5,Y

.LO2

 RTS

.LQ

 STX VIEW
 JSR TT66

 JSR SIGHT

 JMP NWSTARS

.LOOK1

 LDA #&00
 LDY QQ11
 BNE LQ

 CPX VIEW
 BEQ LO2

 STX VIEW
 JSR TT66

 JSR FLIP

 JSR WPSHPS

.SIGHT

 LDY VIEW
 LDA LASER,Y
 BEQ LO2

 LDA #&80
 STA QQ19
 LDA #&48
 STA QQ19+1
 LDA #&14
 STA QQ19+2
 JSR TT15

 LDA #&0A
 STA QQ19+2
 JMP TT15

.L27FA

 LDA #&01

.TT66

 STA QQ11

.TTX66

 LDA #&80
 STA QQ17
 ASL A
 STA MANY
 STA DLY
 STA de
 LDX #&58
 JSR LYN

 LDX QQ22+1
 BEQ BOX

 JSR L304B

.BOX

 LDY #&01
 STY YC
 LDA QQ11
 BNE tt66

 LDY #&0B
 STY XC
 LDA VIEW
 ORA #&60
 JSR TT27

 JSR TT162

 LDA #&AF
 JSR TT27

.tt66

 LDX #&00
 STX QQ17

.L2838

 LDX #&00
 STX XX15
 STX Y1
 DEX
 STX X2
 JSR HLOIN

 LDA #&02
 STA XX15
 STA X2
 JSR BOS2

.BOS2

 JSR BOS1

.BOS1

 LDA #&00
 STA Y1
 LDA #&BF
 STA Y2
 DEC XX15
 DEC X2
 JMP LL30

.L285F

 LDY #&01
 EQUB &2C

.DEL8

 LDY #&1E

.DELAY

 TXA
 LDX #&00

.L2867

 EQUB &2C

.L2868

 BNE L2867

 EQUB &2C

.L286B

 BNE L2868

 DEX
 BNE L286B

 TAX
 DEY
 BNE DELAY

 RTS

.hm

 JSR TT103

 JSR TT111

 JSR TT103

 LDA QQ11
 BEQ SC5

.CLYNS

 JSR L2838

 LDX #&71
 JSR LYN

 JSR L2838

 LDA #&14
 STA YC
 JSR TT67

 LDY #&01
 STY XC
 DEY
 TYA

.SC5

 RTS

.LYN

 JSR ZES1

 INX
 CPX #&76
 BNE LYN

 RTS

.SCAN

 LDA INWK+31
 AND #&10
 BEQ SC5

 LDA TYPE
 BMI SC5

 LDA INWK+1
 ORA INWK+4
 ORA INWK+7
 AND #&C0
 BNE SC5

 LDA INWK+1
 CLC
 LDX INWK+2
 BPL SC2

 EOR #&FF
 ADC #&01

.SC2

 ADC #&7B
 STA XX15
 LDA INWK+7
 LSR A
 LSR A
 CLC
 LDX INWK+8
 BPL SC3

 EOR #&FF
 SEC

.SC3

 ADC #&23
 EOR #&FF
 STA SC
 LDA INWK+4
 LSR A
 CLC
 LDX INWK+5
 BMI SCD6

 EOR #&FF
 SEC

.SCD6

 ADC SC
 BPL ld246

 CMP #&C2
 BCS L28EE

 LDA #&C2

.L28EE

 CMP #&F7
 BCC L28F4

.ld246

 LDA #&F6

.L28F4

 STA Y1
 SEC
 SBC SC
 PHP
 PHA
 JSR CPIX4

 LDA TWOS,X
 STA XX15
 PLA
 PLP
 TAX
 BEQ RTS

 BCC L2926

.VLL1

 DEY
 BPL VL1

 LDY #&07
 LDA SC
 SEC
 SBC #&40
 STA SC
 LDA SCH
 SBC #&01
 STA SCH

.VL1

 LDA XX15
 EOR (SC),Y
 STA (SC),Y
 DEX
 BNE VLL1

.RTS

 RTS

.L2926

 JSR L2936

.L2929

 JSR L2936

 LDA XX15
 EOR (SC),Y
 STA (SC),Y
 INX
 BNE L2929

 RTS

.L2936

 INY
 CPY #&08
 BNE RTS

 LDY #&00

.L293D

 LDA SC
 ADC #&3F
 STA SC
 LDA SCH
 ADC #&01
 STA SCH
 RTS

.tnpr

 PHA
 LDX #&0C
 CPX QQ29
 BCC kg

.Tml

 ADC QQ20,X
 DEX
 BPL Tml

 CMP CRGO
 PLA
 RTS

.kg

 LDY QQ29
 ADC QQ20,Y
 CMP #&C8
 PLA
 RTS

.TT20

 JSR L296A

.L296A

 JSR TT54

.TT54

 LDA QQ15
 CLC
 ADC QQ15+2
 TAX
 LDA QQ15+1
 ADC QQ15+3
 TAY
 LDA QQ15+2
 STA QQ15
 LDA QQ15+3
 STA QQ15+1
 LDA QQ15+5
 STA QQ15+3
 LDA QQ15+4
 STA QQ15+2
 CLC
 TXA
 ADC QQ15+2
 STA QQ15+4
 TYA
 ADC QQ15+3
 STA QQ15+5
 RTS

.TT146

 LDA QQ8
 ORA QQ8+1
 BNE TT63

 INC YC
 RTS

.TT63

 LDA #&BF
 JSR TT68

 LDX QQ8
 LDY QQ8+1
 SEC
 JSR pr5

 LDA #&C3

.TT60

 JSR TT27

.TTX69

 INC YC

.TT69

 LDA #&80
 STA QQ17

.TT67

 LDA #&0D
 JMP TT27

.TT70

 LDA #&AD
 JSR TT27

 JMP TT72

.spc

 JSR TT27

 JMP TT162

.TT25

 JSR L27FA

 LDA #&09
 STA XC
 LDA #&A3
 JSR TT27

 JSR NLIN

 JSR TTX69

 INC YC
 JSR TT146

 LDA #&C2
 JSR TT68

 LDA QQ3
 CLC
 ADC #&01
 LSR A
 CMP #&02
 BEQ TT70

 LDA QQ3
 BCC TT71

 SBC #&05
 CLC

.TT71

 ADC #&AA
 JSR TT27

.TT72

 LDA QQ3
 LSR A
 LSR A
 CLC
 ADC #&A8
 JSR TT60

 LDA #&A2
 JSR TT68

 LDA QQ4
 CLC
 ADC #&B1
 JSR TT60

 LDA #&C4
 JSR TT68

 LDX QQ5
 INX
 CLC
 JSR pr2

 JSR TTX69

 LDA #&C0
 JSR TT68

 SEC
 LDX QQ6
 JSR pr2

 LDA #&C6
 JSR TT60

 LDA #&28
 JSR TT27

 LDA QQ15+4
 BMI TT75

 LDA #&BC
 JSR TT27

 JMP TT76

.TT75

 LDA QQ15+5
 LSR A
 LSR A
 PHA
 AND #&07
 CMP #&03
 BCS TT205

 ADC #&E3
 JSR spc

.TT205

 PLA
 LSR A
 LSR A
 LSR A
 CMP #&06
 BCS TT206

 ADC #&E6
 JSR spc

.TT206

 LDA QQ15+3
 EOR QQ15+1
 AND #&07
 STA QQ19
 CMP #&06
 BCS TT207

 ADC #&EC
 JSR spc

.TT207

 LDA QQ15+5
 AND #&03
 CLC
 ADC QQ19
 AND #&07
 ADC #&F2
 JSR TT27

.TT76

 LDA #&53
 JSR TT27

 LDA #&29
 JSR TT60

 LDA #&C1
 JSR TT68

 LDX QQ7
 LDY QQ7+1
 JSR pr6

 JSR TT162

 LDA #&00
 STA QQ17
 LDA #&4D
 JSR TT27

 LDA #&E2
 JSR TT60

 LDA #&FA
 JSR TT68

 LDA QQ15+5
 LDX QQ15+3
 AND #&0F
 CLC
 ADC #&0B
 TAY
 JSR pr5

 JSR TT162

 LDA #&6B
 JSR TT26

 LDA #&6D
 JMP TT26

.TT24

 LDA QQ15+1
 AND #&07
 STA QQ3
 LDA QQ15+2
 LSR A
 LSR A
 LSR A
 AND #&07
 STA QQ4
 LSR A
 BNE TT77

 LDA QQ3
 ORA #&02
 STA QQ3

.TT77

 LDA QQ3
 EOR #&07
 CLC
 STA QQ5
 LDA QQ15+3
 AND #&03
 ADC QQ5
 STA QQ5
 LDA QQ4
 LSR A
 ADC QQ5
 STA QQ5
 ASL A
 ASL A
 ADC QQ3
 ADC QQ4
 ADC #&01
 STA QQ6
 LDA QQ3
 EOR #&07
 ADC #&03
 STA P
 LDA QQ4
 ADC #&04
 STA Q
 JSR MULTU

 LDA QQ6
 STA Q
 JSR MULTU

 ASL P
 ROL A
 ASL P
 ROL A
 ASL P
 ROL A
 STA QQ7+1
 LDA P
 STA QQ7
 RTS

.TT22

 LDA #&40
 JSR TT66

 LDA #&07
 STA XC
 JSR TT81

 LDA #&C7
 JSR TT27

 JSR NLIN

 LDA #&98
 JSR NLIN2

 JSR TT14

 LDX #&00

.TT83

 STX XSAV
 LDX QQ15+3
 LDY QQ15+4
 TYA
 ORA #&50
 STA ZZ
 LDA QQ15+1
 LSR A
 CLC
 ADC #&18
 STA Y1
 JSR PIXEL

 JSR TT20

 LDX XSAV
 INX
 BNE TT83

 LDA QQ9
 STA QQ19
 LDA QQ10
 LSR A
 STA QQ19+1
 LDA #&04
 STA QQ19+2

.TT15

 LDA #&18
 LDX QQ11
 BPL L2B95

 LDA #&00

.L2B95

 STA QQ19+5
 LDA QQ19
 SEC
 SBC QQ19+2
 BCS TT84

 LDA #&00

.TT84

 STA XX15
 LDA QQ19
 CLC
 ADC QQ19+2
 BCC L2BAB

 LDA #&FF

.L2BAB

 STA X2
 LDA QQ19+1
 CLC
 ADC QQ19+5
 STA Y1
 JSR HLOIN

 LDA QQ19+1
 SEC
 SBC QQ19+2
 BCS TT86

 LDA #&00

.TT86

 CLC
 ADC QQ19+5
 STA Y1
 LDA QQ19+1
 CLC
 ADC QQ19+2
 ADC QQ19+5
 CMP #&98
 BCC TT87

 LDX QQ11
 BMI TT87

 LDA #&97

.TT87

 STA Y2
 LDA QQ19
 STA XX15
 STA X2
 JMP LL30

.TT126

 LDA #&68
 STA QQ19
 LDA #&5A
 STA QQ19+1
 LDA #&10
 STA QQ19+2
 JSR TT15

 LDA QQ14
 STA K
 JMP TT128

.TT14

 LDA QQ11
 BMI TT126

 LDA QQ14
 LSR A
 LSR A
 STA K
 LDA QQ0
 STA QQ19
 LDA QQ1
 LSR A
 STA QQ19+1
 LDA #&07
 STA QQ19+2
 JSR TT15

 LDA QQ19+1
 CLC
 ADC #&18
 STA QQ19+1

.TT128

 LDA QQ19
 STA K3
 LDA QQ19+1
 STA K4
 LDX #&00
 STX K4+1
 STX K3+1
 INX
 STX LSP
 LDX #&02
 STX STP
 JSR CIRCLE2

 RTS

.TT219

 JSR L27FA

 JSR TT163

 LDA #&80
 STA QQ17
 LDA #&00
 STA QQ29

.L2C44

 JSR TT151

 LDA QQ25
 BNE TT224

 JMP TT222

.TQ4

 LDY #&B0

.Tc

 JSR TT162

 TYA
 JSR prq

 JSR dn2

.TT224

 JSR CLYNS

 LDA #&CC
 JSR TT27

 LDA QQ29
 CLC
 ADC #&D0
 JSR TT27

 LDA #&2F
 JSR TT27

 JSR TT152

 LDA #&3F
 JSR TT27

 JSR TT67

 LDX #&00
 STX R
 LDX #&0C
 STX T1
 JSR gnum

 BCS TQ4

 STA P
 JSR tnpr

 LDY #&CE
 BCS Tc

 LDA QQ24
 STA Q
 JSR GCASH

 JSR LCASH

 LDY #&C5
 BCC Tc

 LDY QQ29
 LDA R
 PHA
 CLC
 ADC QQ20,Y
 STA QQ20,Y
 LDA AVL,Y
 SEC
 SBC R
 STA AVL,Y
 PLA
 BEQ TT222

 JSR dn

.TT222

 LDA QQ29
 CLC
 ADC #&05
 STA YC
 LDA #&00
 STA XC
 INC QQ29
 LDA QQ29
 CMP #&11
 BCS BAY2

 JMP L2C44

.BAY2

 LDA #&A7
 JMP FRCE

.gnum

 LDX #&00
 STX R
 LDX #&0C
 STX T1

.TT223

 JSR TT217

 STA Q
 SEC
 SBC #&30
 BCC OUT

 CMP #&0A
 BCS BAY2

 STA S
 LDA R
 CMP #&1A
 BCS OUT

 ASL A
 STA T
 ASL A
 ASL A
 ADC T
 ADC S
 STA R
 CMP QQ25
 BEQ TT226

 BCS OUT

.TT226

 LDA Q
 JSR TT26

 DEC T1
 BNE TT223

.OUT

 LDA R
 RTS

.TT208

 LDA #&04
 JSR TT66

 LDA #&04
 STA YC
 STA XC
 LDA #&CD
 JSR TT27

 LDA #&CE
 JSR TT68

.TT210

 LDY #&00

.TT211

 STY QQ29
 LDX QQ20,Y
 BEQ TT212

 TYA
 ASL A
 ASL A
 TAY
 LDA L4457,Y
 STA QQ19+1
 TXA
 PHA
 JSR TT69

 CLC
 LDA QQ29
 ADC #&D0
 JSR TT27

 LDA #&0E
 STA XC
 PLA
 TAX
 CLC
 JSR pr2

 JSR TT152

 LDA QQ11
 CMP #&04
 BNE TT212

 LDA #&CD
 JSR TT214

 BCC TT212

 LDA QQ29
 LDX #&FF
 STX QQ17
 JSR TT151

 LDY QQ29
 LDA QQ20,Y
 STA P
 LDA QQ24
 STA Q
 JSR GCASH

 JSR MCASH

 LDA #&00
 LDY QQ29
 STA QQ20,Y
 STA QQ17

.TT212

 LDY QQ29
 INY
 CPY #&11
 BCS L2D99

 JMP TT211

.L2D99

 LDA QQ11
 CMP #&04
 BNE L2DA5

 JSR dn2

 JMP BAY2

.L2DA5

 RTS

.TT213

 LDA #&08
 JSR TT66

 LDA #&0B
 STA XC
 LDA #&A4
 JSR TT60

 JSR NLIN4

 JSR fwl

 LDA CRGO
 CMP #&1A
 BCC L2DC6

 LDA #&6B
 JSR TT27

.L2DC6

 JMP TT210

.TT214

 PHA
 JSR TT162

 PLA
 JSR TT27

 LDA #&E1
 JSR TT27

 JSR TT217

 ORA #&20
 CMP #&79
 BEQ TT218

 LDA #&6E
 JMP TT26

.TT218

 JSR TT26

 SEC
 RTS

.TT16

 TXA
 PHA
 DEY
 TYA
 EOR #&FF
 PHA
 JSR TT103

 PLA
 STA K6
 LDA QQ10
 JSR TT123

 LDA QQ19+4
 STA QQ10
 STA QQ19+1
 PLA
 STA K6
 LDA QQ9
 JSR TT123

 LDA QQ19+4
 STA QQ9
 STA QQ19

.TT103

 LDA QQ11
 BEQ TT180

 BMI TT105

 LDA QQ9
 STA QQ19
 LDA QQ10
 LSR A
 STA QQ19+1
 LDA #&04
 STA QQ19+2
 JMP TT15

.TT123

 STA QQ19+4
 CLC
 ADC K6
 LDX K6
 BMI TT124

 BCC TT125

 RTS

.TT124

 BCC TT180

.TT125

 STA QQ19+4

.TT180

 RTS

.TT105

 LDA QQ9
 SEC
 SBC QQ0
 CMP #&26
 BCC TT179

 CMP #&E6
 BCC TT180

.TT179

 ASL A
 ASL A
 CLC
 ADC #&68
 STA QQ19
 LDA QQ10
 SEC
 SBC QQ1
 CMP #&26
 BCC L2E61

 CMP #&DC
 BCC TT180

.L2E61

 ASL A
 CLC
 ADC #&5A
 STA QQ19+1
 LDA #&08
 STA QQ19+2
 JMP TT15

.TT23

 LDA #&80
 JSR TT66

 LDA #&07
 STA XC
 LDA #&BE
 JSR NLIN3

 JSR TT14

 JSR TT103

 JSR TT81

 LDA #&00
 STA XX20
 LDX #&18

.EE3

 STA INWK,X
 DEX
 BPL EE3

.TT182

 LDA QQ15+3
 SEC
 SBC QQ0
 BCS TT184

 EOR #&FF
 ADC #&01

.TT184

 CMP #&14
 BCS TT187

 LDA QQ15+1
 SEC
 SBC QQ1
 BCS TT186

 EOR #&FF
 ADC #&01

.TT186

 CMP #&26
 BCS TT187

 LDA QQ15+3
 SEC
 SBC QQ0
 ASL A
 ASL A
 ADC #&68
 STA XX12
 LSR A
 LSR A
 LSR A
 STA XC
 INC XC
 LDA QQ15+1
 SEC
 SBC QQ1
 ASL A
 ADC #&5A
 STA Y1
 LSR A
 LSR A
 LSR A
 TAY
 LDX INWK,Y
 BEQ EE4

 INY
 LDX INWK,Y
 BEQ EE4

 DEY
 DEY
 LDX INWK,Y
 BNE ee1

.EE4

 STY YC
 CPY #&03
 BCC TT187

 DEX
 STX INWK,Y
 LDA #&80
 STA QQ17
 JSR cpl

.ee1

 LDA XX12
 STA XX15
 JSR CPIX4

.TT187

 JSR TT20

 INC XX20
 BEQ L2F0C

 JMP TT182

.TT81

 LDX #&05

.L2F04

 LDA QQ21,X
 STA QQ15,X
 DEX
 BPL L2F04

.L2F0C

 RTS

.TT111

 JSR TT81

 LDY #&7F
 STY T
 LDA #&00
 STA U

.TT130

 LDA QQ15+3
 SEC
 SBC QQ9
 BCS TT132

 EOR #&FF
 ADC #&01

.TT132

 LSR A
 STA S
 LDA QQ15+1
 SEC
 SBC QQ10
 BCS TT134

 EOR #&FF
 ADC #&01

.TT134

 LSR A
 CLC
 ADC S
 CMP T
 BCS TT135

 STA T
 LDX #&05

.TT136

 LDA QQ15,X
 STA QQ19,X
 DEX
 BPL TT136

.TT135

 JSR TT20

 INC U
 BNE TT130

 LDX #&05

.TT137

 LDA QQ19,X
 STA QQ15,X
 DEX
 BPL TT137

 LDA QQ15+1
 STA QQ10
 LDA QQ15+3
 STA QQ9
 SEC
 SBC QQ0
 BCS TT139

 EOR #&FF
 ADC #&01

.TT139

 JSR SQUA2

 STA K+1
 LDA P
 STA K
 LDA QQ10
 SEC
 SBC QQ1
 BCS TT141

 EOR #&FF
 ADC #&01

.TT141

 LSR A
 JSR SQUA2

 PHA
 LDA P
 CLC
 ADC K
 STA Q
 PLA
 ADC K+1
 STA R
 JSR LL5

 LDA Q
 ASL A
 LDX #&00
 STX QQ8+1
 ROL QQ8+1
 ASL A
 ROL QQ8+1
 STA QQ8
 JMP TT24

.hy6

 JSR CLYNS

 LDA #&0F
 STA XC
 JMP TT27

.hyp

 LDA QQ12
 BNE hy6

 LDA QQ22+1
 BNE hy5

 LDX #&01
 JSR CTRL

 BMI Ghy

 JSR hm

 LDA QQ8
 ORA QQ8+1
 BEQ hy5

 LDA #&07
 STA XC
 LDA #&17
 STA YC
 LDA #&00
 STA QQ17
 LDA #&BD
 JSR TT27

 LDA QQ8+1
 BNE TT147

 LDA QQ14
 CMP QQ8
 BCC TT147

 LDA #&2D
 JSR TT27

 JSR cpl

.wW

 LDA #&0F
 STA QQ22+1
 STA QQ22
 TAX
 JMP L304B

.Ghy

 LDX GHYP
 BEQ hy5

 INX
 STX GHYP
 STX FIST
 JSR wW

 LDX #&05
 INC GCNT
 LDA GCNT
 AND #&07
 STA GCNT

.G1

 LDA QQ21,X
 ASL A
 ROL QQ21,X
 DEX
 BPL G1

.L3023

 LDA #&60
hy5 = L3023+1
 STA QQ9
 STA QQ10
 JSR TT110

 JSR TT111

 LDX #&00
 STX QQ8
 STX QQ8+1
 LDA #&74
 JSR MESS

.jmp

 LDA QQ9
 STA QQ0
 LDA QQ10
 STA QQ1
 RTS

.L304B

 LDY #&01
 STY YC
 DEY
 STY XC

.pr6

 CLC

.pr5

 LDA #&05
 JMP TT11

.TT147

 LDA #&CA

.prq

 JSR TT27

 LDA #&3F
 JMP TT27

.TT151

 PHA
 STA QQ19+4
 ASL A
 ASL A
 STA QQ19
 LDA #&01
 STA XC
 PLA
 ADC #&D0
 JSR TT27

 LDA #&0E
 STA XC
 LDX QQ19
 LDA L4457,X
 STA QQ19+1
 LDA QQ26
 AND L4459,X
 CLC
 ADC QQ23,X
 STA QQ24
 JSR TT152

 JSR var

 LDA QQ19+1
 BMI TT155

 LDA QQ24
 ADC K6
 JMP TT156

.TT155

 LDA QQ24
 SEC
 SBC K6

.TT156

 STA QQ24
 STA P
 LDA #&00
 JSR GC2

 SEC
 JSR pr5

 LDY QQ19+4
 LDA #&05
 LDX AVL,Y
 STX QQ25
 CLC
 BEQ TT172

 JSR pr2+2

 JMP TT152

.TT172

 LDA XC
 ADC #&04
 STA XC
 LDA #&2D
 BNE L30DD

.TT152

 LDA QQ19+1
 AND #&60
 BEQ TT160

 CMP #&20
 BEQ TT161

 JSR TT16a

.TT162

 LDA #&20

.L30DD

 JMP TT27

.TT160

 LDA #&74
 JSR TT26

 BCC TT162

.TT161

 LDA #&6B
 JSR TT26

.TT16a

 LDA #&67
 JMP TT26

.TT163

 LDA #&11
 STA XC
 LDA #&FF
 BNE L30DD

.TT167

 LDA #&10
 JSR TT66

 LDA #&05
 STA XC
 LDA #&A7
 JSR NLIN3

 LDA #&03
 STA YC
 JSR TT163

 LDA #&00
 STA QQ29

.TT168

 LDX #&80
 STX QQ17
 JSR TT151

 INC YC
 INC QQ29
 LDA QQ29
 CMP #&11
 BCC TT168

 RTS

.var

 LDA QQ19+1
 AND #&1F
 LDY QQ28
 STA QQ19+2
 CLC
 LDA #&00
 STA AVL+16

.TT153

 DEY
 BMI TT154

 ADC QQ19+2
 JMP TT153

.TT154

 STA K6
 RTS

.hyp1

 JSR TT111

 JSR jmp

 LDX #&05

.TT112

 LDA QQ15,X
 STA QQ2,X
 DEX
 BPL TT112

 INX
 STX EV
 LDA QQ3
 STA QQ28
 LDA QQ5
 STA tek
 LDA QQ4
 STA gov
 RTS

.GVL

 JSR DORND

 STA QQ26
 LDX #&00
 STX XX4

.hy9

 LDA L4457,X
 STA QQ19+1
 JSR var

 LDA L4459,X
 AND QQ26
 CLC
 ADC L4458,X
 LDY QQ19+1
 BMI TT157

 SEC
 SBC K6
 JMP TT158

.TT157

 CLC
 ADC K6

.TT158

 BPL TT159

 LDA #&00

.TT159

 LDY XX4
 AND #&3F
 STA AVL,Y
 INY
 TYA
 STA XX4
 ASL A
 ASL A
 TAX
 CMP #&3F
 BCC hy9

.hyR

 RTS

.TT18

 LDA QQ14
 SEC
 SBC QQ8
 STA QQ14
 LDA QQ11
 BNE ee5

 JSR TT66

 JSR LL164

.ee5

 JSR hyp1

 JSR GVL

 JSR RES2

 JSR SOLAR

 LDA QQ11
 AND #&3F
 BNE hyR

 JSR TTX66

 LDA QQ11
 BNE TT114

 INC QQ11

.TT110

 LDX QQ12
 BEQ NLUNCH

 JSR LAUN

 JSR RES2

 JSR TT111

 INC INWK+8
 JSR SOS1

 LDA #&80
 STA INWK+8
 INC INWK+7
 JSR NWSPS

 LDA #&0C
 STA DELTA
 JSR BAD

 ORA FIST
 STA FIST

.NLUNCH

 LDX #&00
 STX QQ12
 JMP LOOK1

.TT114

 BMI TT115

 JMP TT22

.TT115

 JMP TT23

.LCASH

 STX T1
 LDA CASH+3
 SEC
 SBC T1
 STA CASH+3
 STY T1
 LDA CASH+2
 SBC T1
 STA CASH+2
 LDA CASH+1
 SBC #&00
 STA CASH+1
 LDA CASH
 SBC #&00
 STA CASH
 BCS TT113

.MCASH

 TXA
 CLC
 ADC CASH+3
 STA CASH+3
 TYA
 ADC CASH+2
 STA CASH+2
 LDA CASH+1
 ADC #&00
 STA CASH+1
 LDA CASH
 ADC #&00
 STA CASH
 CLC

.TT113

 RTS

.GCASH

 JSR MULTU

.GC2

 ASL P
 ROL A
 ASL P
 ROL A
 TAY
 LDX P
 RTS

.bay

 JMP BAY

.EQSHP

 JSR DIALS

 LDA #&20
 JSR TT66

 LDA #&0C
 STA XC
 LDA #&CF
 JSR spc

 LDA #&B9
 JSR NLIN3

 LDA #&80
 STA QQ17
 INC YC
 LDA tek
 CLC
 ADC #&03
 CMP #&0C
 BCC L328E

 LDA #&0C

.L328E

 STA Q
 STA QQ25
 INC Q
 LDA #&46
 SEC
 SBC QQ14
 ASL A
 STA PRXS
 LDX #&01

.EQL1

 STX XX13
 JSR TT67

 LDX XX13
 CLC
 JSR pr2

 JSR TT162

 LDA XX13
 CLC
 ADC #&68
 JSR TT27

 LDA XX13
 JSR L33EC

 SEC
 LDA #&19
 STA XC
 LDA #&06
 JSR TT11

 LDX XX13
 INX
 CPX Q
 BCC EQL1

 JSR CLYNS

 LDA #&7F
 JSR prq

 JSR gnum

 BEQ bay

 BCS bay

 SBC #&00
 LDX #&02
 STX XC
 INC YC
 PHA
 JSR eq

 PLA
 BNE et0

 STA MCNT
 LDX #&46
 STX QQ14

.et0

 CMP #&01
 BNE et1

 LDX NOMSL
 INX
 LDY #&75
 CPX #&05
 BCS pres

 STX NOMSL
 JSR msblob

.et1

 LDY #&6B
 CMP #&02
 BNE et2

 LDX #&25
 CPX CRGO
 BEQ pres

 STX CRGO

.et2

 CMP #&03
 BNE et3

 INY
 LDX ECM
 BNE pres

 DEC ECM

.et3

 CMP #&04
 BNE et4

 JSR qv

 LDA #&04
 LDY LASER,X
 BEQ ed4

.ed7

 LDY #&BB
 BNE pres

.ed4

 LDA #&0F
 STA LASER,X
 LDA #&04

.et4

 CMP #&05
 BNE et5

 JSR qv

 STX T1
 LDA #&05
 LDY LASER,X
 BEQ ed5

 BMI ed7

 LDA #&04
 JSR prx

 JSR MCASH

.ed5

 LDA #&8F
 LDX T1
 STA LASER,X

.et5

 LDY #&6F
 CMP #&06
 BNE et6

 LDX BST
 BEQ ed9

.pres

 STY K
 JSR prx

 JSR MCASH

 LDA K
 JSR spc

 LDA #&1F
 JSR TT27

.err

 JSR dn2

 JMP BAY

.ed9

 DEC BST

.et6

 INY
 CMP #&07
 BNE et7

 LDX ESCP
 BNE pres

 DEC ESCP

.et7

 INY
 CMP #&08
 BNE et8

 LDX BOMB
 BNE pres

 LDX #&7F
 STX BOMB

.et8

 INY
 CMP #&09
 BNE etA

 LDX ENGY
 BNE pres

 INC ENGY

.etA

 INY
 CMP #&0A
 BNE etB

 LDX DKCMP
 BNE pres

 DEC DKCMP

.etB

 INY
 CMP #&0B
 BNE et9

 LDX GHYP
 BNE pres

 DEC GHYP

.et9

 JSR dn

 JMP EQSHP

.dn

 JSR TT162

 LDA #&77
 JSR spc

.dn2

 JSR BEEP

 LDY #&C8
 JMP DELAY

.eq

 JSR prx

 JSR LCASH

 BCS c

 LDA #&C5
 JSR prq

 JMP err

.L33EC

 SEC
 SBC #&01

.prx

 ASL A
 TAY
 LDX PRXS,Y
 LDA PRXS+1,Y
 TAY

.c

 RTS

.qv

 LDY #&10
 STY YC

.qv1

 LDX #&0C
 STX XC
 TYA
 CLC
 ADC #&20
 JSR spc

 LDA YC
 CLC
 ADC #&50
 JSR TT27

 INC YC
 LDY YC
 CPY #&14
 BCC qv1

.qv3

 JSR CLYNS

 LDA #&AF
 JSR prq

 JSR TT217

 SEC
 SBC #&30
 CMP #&04
 BCS qv3

 TAX
 RTS

 EQUB &8C

 EQUB &E7, &8D, &E6, &C1, &C8, &C8, &E6, &D6
 EQUB &C5, &C6, &C1, &CA, &83, &9C, &90

.cpl

 LDX #&05

.TT53

 LDA QQ15,X
 STA QQ19,X
 DEX
 BPL TT53

 LDY #&03
 BIT QQ15
 BVS L344C

 DEY

.L344C

 STY T

.TT55

 LDA QQ15+5
 AND #&1F
 BEQ L3459

 ORA #&80
 JSR TT27

.L3459

 JSR TT54

 DEC T
 BPL TT55

 LDX #&05

.TT56

 LDA QQ19,X
 STA QQ15,X
 DEX
 BPL TT56

 RTS

.cmn

 LDY #&00

.QUL4

 LDA NA%,Y
 CMP #&0D
 BEQ L3479

 JSR TT26

 INY
 BNE QUL4

.L3479

 RTS

.ypl

 JSR TT62

 JSR cpl

.TT62

 LDX #&05

.TT78

 LDA QQ15,X
 LDY QQ2,X
 STA QQ2,X
 STY QQ15,X
 DEX
 BPL TT78

 RTS

.tal

 CLC
 LDX GCNT
 INX
 JMP pr2

.fwl

 LDA #&69
 JSR TT68

 LDX QQ14
 SEC
 JSR pr2

 LDA #&C3
 JSR plf

 LDA #&77
 BNE TT27

.csh

 LDX #&03

.pc1

 LDA CASH,X
 STA K,X
 DEX
 BPL pc1

 LDA #&09
 STA U
 SEC
 JSR BPRNT

 LDA #&E2

.plf

 JSR TT27

 JMP TT67

.TT68

 JSR TT27

.TT73

 LDA #&3A

.TT27

 TAX
 BEQ csh

 BMI TT43

 DEX
 BEQ tal

 DEX
 BEQ ypl

 DEX
 BNE L34DD

 JMP cpl

.L34DD

 DEX
 BEQ cmn

 DEX
 BEQ fwl

 DEX
 BNE L34EB

 LDA #&80
 STA QQ17
 RTS

.L34EB

 DEX
 DEX
 BNE L34F2

 STX QQ17
 RTS

.L34F2

 DEX
 BEQ crlf

 CMP #&60
 BCS ex

 CMP #&0E
 BCC L3501

 CMP #&20
 BCC qw

.L3501

 LDX QQ17
 BEQ TT74

 BMI TT41

 BIT QQ17
 BVS TT46

.TT42

 CMP #&41
 BCC TT44

 CMP #&5B
 BCS TT44

 ADC #&20

.TT44

 JMP TT26

.TT41

 BIT QQ17
 BVS TT45

 CMP #&41
 BCC TT74

 PHA
 TXA
 ORA #&40
 STA QQ17
 PLA
 BNE TT44

.qw

 ADC #&72
 BNE ex

.crlf

 LDA #&15
 STA XC
 BNE TT73

.TT45

 CPX #&FF
 BEQ TT48

 CMP #&41
 BCS TT42

.TT46

 PHA
 TXA
 AND #&BF
 STA QQ17
 PLA

.TT74

 JMP TT26

.TT43

 CMP #&A0
 BCS TT47

 AND #&7F
 ASL A
 TAY
 LDA L4416,Y
 JSR TT27

 LDA L4417,Y
 CMP #&3F
 BEQ TT48

 JMP TT27

.TT47

 SBC #&A0

.ex

 TAX
 LDA #&00
 STA V
 LDA #&04
 STA V+1
 LDY #&00
 TXA
 BEQ TT50

.TT51

 LDA (V),Y
 BEQ TT49

 INY
 BNE TT51

 INC V+1
 BNE TT51

.TT49

 INY
 BNE TT59

 INC V+1

.TT59

 DEX
 BNE TT51

.TT50

 TYA
 PHA
 LDA V+1
 PHA
 LDA (V),Y
 EOR #&23
 JSR TT27

 PLA
 STA V+1
 PLA
 TAY
 INY
 BNE L3596

 INC V+1

.L3596

 LDA (V),Y
 BNE TT50

.TT48

 RTS

.EX2

 LDA INWK+31
 ORA #&A0
 STA INWK+31
 RTS

.DOEXP

 LDA INWK+31
 AND #&40
 BEQ L35AB

 JSR PTCLS

.L35AB

 LDA INWK+6
 STA T
 LDA INWK+7
 CMP #&20
 BCC L35B9

 LDA #&FE
 BNE L35C1

.L35B9

 ASL T
 ROL A
 ASL T
 ROL A
 SEC
 ROL A

.L35C1

 STA Q
 LDY #&01
 LDA (XX19),Y
 ADC #&04
 BCS EX2

 STA (XX19),Y
 JSR DVID4

 LDA P
 CMP #&1C
 BCC L35DA

 LDA #&FE
 BNE LABEL_1

.L35DA

 ASL R
 ROL A
 ASL R
 ROL A
 ASL R
 ROL A

.LABEL_1

 DEY
 STA (XX19),Y
 LDA INWK+31
 AND #&BF
 STA INWK+31
 AND #&08
 BEQ TT48

 LDY #&02
 LDA (XX19),Y
 TAY

.EXL1

 LDA XX3-7,Y
 STA (XX19),Y
 DEY
 CPY #&06
 BNE EXL1

 LDA INWK+31
 ORA #&40
 STA INWK+31

.PTCLS

 LDY #&00
 LDA (XX19),Y
 STA Q
 INY
 LDA (XX19),Y
 BPL L3612

 EOR #&FF

.L3612

 LSR A
 LSR A
 LSR A
 LSR A
 ORA #&01
 STA U
 INY
 LDA (XX19),Y
 STA TGT
 LDA RAND+1
 PHA
 LDY #&06

.EXL5

 LDX #&03

.EXL3

 INY
 LDA (XX19),Y
 STA K3,X
 DEX
 BPL EXL3

 STY CNT
 LDY #&02

.EXL2

 INY
 LDA (XX19),Y
 EOR CNT
 STA &FFFD,Y
 CPY #&06
 BNE EXL2

 LDY U

.EXL4

 JSR DORND2

 STA ZZ
 LDA K3+1
 STA R
 LDA K3
 JSR EXS1

 BNE EX11

 CPX #&BF
 BCS EX11

 STX Y1
 LDA K3+3
 STA R
 LDA K3+2
 JSR EXS1

 BNE EX4

 LDA Y1
 JSR PIXEL

.EX4

 DEY
 BPL EXL4

 LDY CNT
 CPY TGT
 BCC EXL5

 PLA
 STA RAND+1
 LDA K%+6
 STA RAND+3
 RTS

.EX11

 JSR DORND2

 JMP EX4

.EXS1

 STA S
 JSR DORND2

 ROL A
 BCS EX5

 JSR FMLTU

 ADC R
 TAX
 LDA S
 ADC #&00
 RTS

.EX5

 JSR FMLTU

 STA T
 LDA R
 SBC T
 TAX
 LDA S
 SBC #&00
 RTS

.SOS1

 JSR msblob

 LDA #&7F
 STA INWK+29
 STA INWK+30
 LDA tek
 AND #&02
 ORA #&80
 JMP NWSHP

.SOLAR

 LSR FIST
 JSR ZINF

 LDA QQ15+1
 AND #&07
 ADC #&06
 LSR A
 STA INWK+8
 ROR A
 STA INWK+2
 STA INWK+5
 JSR SOS1

 LDA #&81
 JSR NWSHP

.NWSTARS

 LDA QQ11
 BNE WPSHPS

.nWq

 LDY #&0A

.SAL4

 JSR DORND

 ORA #&08
 STA SZ,Y
 STA ZZ
 JSR DORND

 STA SX,Y
 STA XX15
 JSR DORND

 STA SY,Y
 STA Y1
 JSR PIXEL2

 DEY
 BNE SAL4

.WPSHPS

 LDX #&00

.WSL1

 LDA FRIN,X
 BEQ WS2

 BMI WS1

 STA TYPE
 JSR GINF

 LDY #&1F

.WAL2

 LDA (INF),Y
 STA INWK,Y
 DEY
 BPL WAL2

 STX XSAV
 JSR SCAN

 LDX XSAV
 LDY #&1F
 LDA (INF),Y
 AND #&A7
 STA (INF),Y

.WS1

 INX
 BNE WSL1

.WS2

 LDX #&FF
 STX LSX2
 STX LSY2

.L3727

 DEX
 RTS

.SHD

 INX
 BEQ L3727

.DENGY

 DEC ENERGY
 PHP
 BNE L3735

 INC ENERGY

.L3735

 PLP
 RTS

.COMPAS

 JSR DOT

 LDA SSPR
 BNE SP1

 JSR SPS1

 JMP SP2

.SPS2

 ASL A
 TAX
 LDA #&00
 ROR A
 TAY
 LDA #&14
 STA Q
 TXA
 JSR DVID4

 LDX P
 TYA
 BMI LL163

 LDY #&00
 RTS

.LL163

 LDY #&FF
 TXA
 EOR #&FF
 TAX
 INX
 RTS

.SPS4

 LDX #&08

.SPL1

 LDA K%+&24,X
 STA K3,X
 DEX
 BPL SPL1

 JMP TAS2

.SP1

 JSR SPS4

.SP2

 LDA XX15
 JSR SPS2

 TXA
 ADC #&C1
 STA COMX
 LDA Y1
 JSR SPS2

 STX T
 LDA #&CC
 SBC T
 STA COMY
 LDA #&F0
 LDX X2
 BPL L3794

 LDA #&FF

.L3794

 STA COMC

.DOT

 LDA COMY
 STA Y1
 LDA COMX
 STA XX15
 LDA COMC
 CMP #&F0
 BNE CPIX2

.CPIX4

 JSR CPIX2

 DEC Y1

.CPIX2

 LDY #&80
 STY SC
 LDA Y1
 LSR A
 LSR A
 LSR A
 STA SCH
 LSR A
 ROR SC
 LSR A
 ROR SC
 ADC SCH
 ADC #&58
 STA SCH
 LDA XX15
 AND #&F8
 ADC SC
 STA SC
 BCC L37D0

 INC SCH

.L37D0

 LDA Y1
 AND #&07
 TAY
 LDA XX15
 AND #&07
 TAX
 LDA TWOS,X
 EOR (SC),Y
 STA (SC),Y
 JSR L37E4

.L37E4

 INX
 LDA TWOS,X
 BPL CP1

 LDA SC
 CLC
 ADC #&08
 STA SC
 BCC L37F5

 INC SCH

.L37F5

 LDA TWOS,X

.CP1

 EOR (SC),Y
 STA (SC),Y
 RTS

.OOPS

 STA T
 LDY #&08
 LDX #&00
 LDA (INF),Y
 BMI OO1

 LDA FSH
 SBC T
 BCC OO2

 STA FSH
 RTS

.OO2

 STX FSH
 BCC OO3

.OO1

 LDA ASH
 SBC T
 BCC OO5

 STA ASH
 RTS

.OO5

 STX ASH

.OO3

 ADC ENERGY
 STA ENERGY
 BEQ L382F

 BCS L3832

.L382F

 JMP DEATH

.L3832

 JSR EXNO3

 JMP OUCH

.SPS3

 LDA K%+1,X
 STA K3,X
 LDA K%+2,X
 TAY
 AND #&7F
 STA K3+1,X
 TYA
 AND #&80
 STA K3+2,X
 RTS

.GINF

 TXA
 ASL A
 TAY
 LDA UNIV,Y
 STA INF
 LDA UNIV+1,Y
 STA INF+1
 RTS

.NWSPS

 JSR SPBLB

 LDX #&01
 STX INWK+32
 DEX
 STX INWK+30
 STX FRIN+1
 DEX
 STX INWK+29
 LDX #&0A
 JSR NwS1

 JSR NwS1

 JSR NwS1

 LDA #&08
 STA XX19
 LDA #&0C
 STA INWK+34
 LDA #&07

.NWSHP

 STA T
 LDX #&00

.NWL1

 LDA FRIN,X
 BEQ NW1

 INX
 CPX #&0C
 BCC NWL1

 CLC

.L388D

 RTS

.NW1

 JSR GINF

 LDA T
 BMI NW2

 ASL A
 TAY
 LDA L4ED2,Y
 STA XX0
 LDA L4ED3,Y
 STA XX0+1
 CPY #&0E
 BEQ NW6

 LDY #&05
 LDA (XX0),Y
 STA T1
 LDA SLSP
 SEC
 SBC T1
 STA XX19
 LDA SLSP+1
 SBC #&00
 STA INWK+34
 LDA XX19
 SBC INF
 TAY
 LDA INWK+34
 SBC INF+1
 BCC L388D

 BNE NW4

 CPY #&24
 BCC L388D

.NW4

 LDA XX19
 STA SLSP
 LDA INWK+34
 STA SLSP+1

.NW6

 LDY #&0E
 LDA (XX0),Y
 STA INWK+35
 LDY #&13
 LDA (XX0),Y
 AND #&07
 STA INWK+31
 LDA T

.NW2

 STA FRIN,X
 TAX
 BMI L38EE

 INC MANY,X

.L38EE

 LDY #&23

.NWL3

 LDA INWK,Y
 STA (INF),Y
 DEY
 BPL NWL3

 SEC
 RTS

.NwS1

 LDA INWK,X
 EOR #&80
 STA INWK,X
 INX
 INX
 RTS

.L3903

 LDY #&09

.ABORT

 LDX #&FF

.ABORT2

 STX MSTG
 LDX NOMSL
 JSR MSBAR

 STY MSAR
 RTS

.ECBLB2

 LDA #&20
 STA ECMA
 ASL A
 JSR NOISE

.ECBLB

 LDA #&98
 LDX #&35
 LDY #&7C
 BNE BULB

.SPBLB

 LDA #&20
 LDX #&38
 LDY #&7D

.BULB

 STA SC
 STX P+1
 LDX #&39
 STX P+2
 TYA
 JMP RREN

.L3935

 EQUB &FE

 EQUB &FE, &E0

 EQUB &FE, &FE, &E0, &FE, &FE, &0E, &FE, &FE

.MSBAR

 TXA
 PHA
 ASL A
 ASL A
 ASL A
 STA T
 LDA #&D1
 SBC T
 STA SC
 LDA #&7D
 STA SCH
 TYA
 TAX
 LDY #&05

.MBL1

 LDA L3961,X
 STA (SC),Y
 DEX
 DEY
 BNE MBL1

 PLA
 TAX
 RTS

.L3961

 EQUB &00

 EQUB &00, &00, &00, &00, &FC, &FC, &FC, &FC
 EQUB &FC, &84, &B4, &84, &FC, &C4, &EC, &EC
 EQUB &FC

.PROJ

 LDA INWK
 STA P
 LDA INWK+1
 STA P+1
 LDA INWK+2
 JSR PLS6

 BCS RTS2

 LDA K
 ADC #&80
 STA K3
 TXA
 ADC #&00
 STA K3+1
 LDA INWK+3
 STA P
 LDA INWK+4
 STA P+1
 LDA INWK+5
 EOR #&80
 JSR PLS6

 BCS RTS2

 LDA K
 ADC #&60
 STA K4
 TXA
 ADC #&00
 STA K4+1
 CLC

.RTS2

 RTS

.PL2

 JMP WPLS2

.PLANET

 LDA TYPE
 LSR A
 BCS RTS2

 LDA INWK+8
 BMI PL2

 CMP #&30
 BCS PL2

 ORA INWK+7
 BEQ PL2

 JSR PROJ

 BCS PL2

 LDA #&60
 STA P+1
 LDA #&00
 STA P
 JSR DVID3B2

 LDA K+1
 BEQ PL82

 LDA #&F8
 STA K

.PL82

 JSR WPLS2

 JMP CIRCLE

.CIRCLE

 JSR CHKON

 BCS RTS2

 LDA #&00
 STA LSX2
 LDX K
 LDA #&08
 CPX #&09
 BCC PL89

 LSR A

.PL89

 STA STP

.CIRCLE2

 LDX #&FF
 STX FLAG
 INX
 STX CNT

.PLL3

 LDA CNT
 JSR FMLTU2

 LDX #&00
 STX T
 LDX CNT
 CPX #&21
 BCC PL37

 EOR #&FF
 ADC #&00
 TAX
 LDA #&FF
 ADC #&00
 STA T
 TXA
 CLC

.PL37

 ADC K3
 STA K6
 LDA K3+1
 ADC T
 STA QQ19+4
 LDA CNT
 CLC
 ADC #&10
 JSR FMLTU2

 TAX
 LDA #&00
 STA T
 LDA CNT
 ADC #&0F
 AND #&3F
 CMP #&21
 BCC PL38

 TXA
 EOR #&FF
 ADC #&00
 TAX
 LDA #&FF
 ADC #&00
 STA T
 CLC

.PL38

 JSR BLINE

 CMP #&41
 BCS L3A4D

 JMP PLL3

.L3A4D

 CLC
 RTS

.WPLS2

 LDY LSX2
 BNE WP1

.WPL1

 CPY LSP
 BCS WP1

 LDA LSY2,Y
 CMP #&FF
 BEQ WP2

 STA Y2
 LDA LSX2,Y
 STA X2
 JSR LL30

 INY
 LDA SWAP
 BNE WPL1

 LDA X2
 STA XX15
 LDA Y2
 STA Y1
 JMP WPL1

.WP2

 INY
 LDA LSX2,Y
 STA XX15
 LDA LSY2,Y
 STA Y1
 INY
 JMP WPL1

.WP1

 LDA #&01
 STA LSP
 LDA #&FF
 STA LSX2
 RTS

.CHKON

 LDA K3
 CLC
 ADC K
 LDA K3+1
 ADC #&00
 BMI PL21

 LDA K3
 SEC
 SBC K
 LDA K3+1
 SBC #&00
 BMI PL31

 BNE PL21

.PL31

 LDA K4
 CLC
 ADC K
 STA P+1
 LDA K4+1
 ADC #&00
 BMI PL21

 STA P+2
 LDA K4
 SEC
 SBC K
 TAX
 LDA K4+1
 SBC #&00
 BMI PL44

 BNE PL21

 CPX #&BF
 RTS

.PL21

 SEC
 RTS

.PLS6

 JSR DVID3B2

 LDA K+3
 AND #&7F
 ORA K+2
 BNE PL21

 LDX K+1
 CPX #&04
 BCS PL6

 LDA K+3
 BPL PL6

 LDA K
 EOR #&FF
 ADC #&01
 STA K
 TXA
 EOR #&FF
 ADC #&00
 TAX

.PL44

 CLC

.PL6

 RTS

.TT17

 JSR DOKEY

 LDX JSTK
 BEQ TJ1

 LDA JSTX
 EOR #&FF
 JSR TJS1

 TYA
 TAX
 LDA JSTY

.TJS1

 TAY
 LDA #&00
 CPY #&10
 SBC #&00
 CPY #&40
 SBC #&00
 CPY #&C0
 ADC #&00
 CPY #&E0
 ADC #&00
 TAY
 LDA KL
 RTS

.TJ1

 LDA KL
 LDY #&00
 CMP #&18
 BNE L3B24

 DEX

.L3B24

 CMP #&78
 BNE L3B29

 INX

.L3B29

 CMP #&39
 BNE L3B2E

 INY

.L3B2E

 CMP #&28
 BNE L3B33

 DEY

.L3B33

 RTS

.ping

 LDX #&01

.pl1

 LDA QQ0,X
 STA QQ9,X
 DEX
 BPL pl1

 RTS

.KS3

 LDA P
 STA SLSP
 LDA P+1
 STA SLSP+1
 RTS

.KS1

 LDX XSAV
 JSR KILLSHP

 LDX XSAV
 JMP MAL1

.KS4

 JSR ZINF

 LDA #&00
 STA FRIN+1
 STA SSPR
 JSR SPBLB

 LDA #&06
 STA INWK+5
 LDA #&81
 JMP NWSHP

.KS2

 LDX #&FF

.KSL4

 INX
 LDA FRIN,X
 BEQ KS3

 CMP #&08
 BNE KSL4

 TXA
 ASL A
 TAY
 LDA UNIV,Y
 STA SC
 LDA UNIV+1,Y
 STA SCH
 LDY #&20
 LDA (SC),Y
 BPL KSL4

 AND #&7F
 LSR A
 CMP XX4
 BCC KSL4

 BEQ KS6

 SBC #&01
 ASL A
 ORA #&80
 STA (SC),Y
 BNE KSL4

.KS6

 LDA #&00
 STA (SC),Y
 BEQ KSL4

.KILLSHP

 STX XX4
 LDA MSTG
 CMP XX4
 BNE KS5

 JSR L3903

 LDA #&C8
 JSR MESS

.KS5

 LDY XX4
 LDX FRIN,Y
 CPX #&07
 BEQ KS4

 DEC MANY,X
 LDX XX4
 LDY #&05
 LDA (XX0),Y
 LDY #&21
 CLC
 ADC (INF),Y
 STA P
 INY
 LDA (INF),Y
 ADC #&00
 STA P+1

.KSL1

 INX
 LDA FRIN,X
 STA FRIN-1,X
 BEQ KS2

 ASL A
 TAY
 LDA L4ED2,Y
 STA SC
 LDA L4ED3,Y
 STA SCH
 LDY #&05
 LDA (SC),Y
 STA T
 LDA P
 SEC
 SBC T
 STA P
 LDA P+1
 SBC #&00
 STA P+1
 TXA
 ASL A
 TAY
 LDA UNIV,Y
 STA SC
 LDA UNIV+1,Y
 STA SCH
 LDY #&23
 LDA (SC),Y
 STA (INF),Y
 DEY
 LDA (SC),Y
 STA K+1
 LDA P+1
 STA (INF),Y
 DEY
 LDA (SC),Y
 STA K
 LDA P
 STA (INF),Y
 DEY

.KSL2

 LDA (SC),Y
 STA (INF),Y
 DEY
 BPL KSL2

 LDA SC
 STA INF
 LDA SCH
 STA INF+1
 LDY T

.KSL3

 DEY
 LDA (K),Y
 STA (P),Y
 TYA
 BNE KSL3

 BEQ KSL1

.L3C3C

 EQUB &11

 EQUB &01, &00, &03, &11, &02, &2C, &04, &11
 EQUB &03, &F0, &06, &10, &F1, &04, &05, &01
 EQUB &F1, &BC, &01, &11, &F4, &0C, &08, &10
 EQUB &F1, &04, &06, &10, &02, &60, &10, &11
 EQUB &04, &C2, &FF, &11, &00, &00, &00

.L3C64

 EQUB &70, &24, &56, &56, &42, &28, &C8, &D0
 EQUB &F0, &E0

.RESET

 JSR ZERO

.L3C71

 LDX #&06

.SAL3

 STA BETA,X
 DEX
 BPL SAL3

 STX QQ12

.RES4

 LDA #&FF
 LDX #&02

.REL5

 STA FSH,X
 DEX
 BPL REL5

.RES2

 LDX #&FF
 STX LSX2
 STX LSY2
 STX MSTG
 LDA #&80
 STA JSTY
 STA ALP2
 STA BET2
 ASL A
 STA ALP2+1
 STA BET2+1
 STA MCNT
 LDA #&03
 STA DELTA
 STA ALPHA
 STA ALP1
 LDA SSPR
 BEQ L3CAD

 JSR SPBLB

.L3CAD

 LDA ECMA
 BEQ yu

 JSR ECMOF

.yu

 JSR WPSHPS

 JSR ZERO

 LDA #&DF
 STA SLSP
 LDA #&0B
 STA SLSP+1
 JSR DIALS

.ZINF

 LDY #&23
 LDA #&00

.ZI1

 STA INWK,Y
 DEY
 BPL ZI1

 LDA #&60
 STA INWK+18
 STA INWK+22
 ORA #&80
 STA INWK+14
 RTS

.msblob

 LDX #&04

.ss

 CPX NOMSL
 BEQ SAL8

 LDY #&04
 JSR MSBAR

 DEX
 BNE ss

 RTS

.SAL8

 LDY #&09
 JSR MSBAR

 DEX
 BNE SAL8

 RTS

.me2

 LDA MCH
 JSR MESS

 LDA #&00
 STA DLY
 JMP me3

.Ze

 JSR ZINF

 JSR DORND

 STA T1
 AND #&80
 STA INWK+2
 TXA
 AND #&80
 STA INWK+5
 LDA #&20
 STA INWK+1
 STA INWK+4
 STA INWK+7
 TXA
 CMP #&F5
 ROL A
 ORA #&C0
 STA INWK+32

.DORND2

 CLC

.DORND

 LDA RAND
 ROL A
 TAX
 ADC RAND+2
 STA RAND
 STX RAND+2
 LDA RAND+1
 TAX
 ADC RAND+3
 STA RAND+1
 STX RAND+3
 RTS

.MTT4

 LSR A
 STA INWK+32
 STA INWK+29
 ROL INWK+31
 AND #&1F
 ORA #&10
 STA INWK+27
 LDA #&06
 JSR NWSHP

.TT100

 JSR M%

 DEC DLY
 BEQ me2

 BPL me3

 INC DLY

.me3

 DEC MCNT
 BEQ L3D5F

 JMP MLOOP

.L3D5F

 JSR DORND

 CMP #&23
 BCS MTT1

 LDA MANY+9
 CMP #&03
 BCS MTT1

 JSR ZINF

 LDA #&26
 STA INWK+7
 JSR DORND

 STA INWK
 STX INWK+3
 AND #&80
 STA INWK+2
 TXA
 AND #&80
 STA INWK+5
 ROL INWK+1
 ROL INWK+1
 JSR DORND

 BVS MTT4

 ORA #&6F
 STA INWK+29
 LDA SSPR
 BNE MTT1

 TXA
 BCS MTT2

 AND #&1F
 ORA #&10
 STA INWK+27
 BCC MTT3

.MTT2

 ORA #&7F
 STA INWK+30

.MTT3

 JSR DORND

 CMP #&05
 LDA #&09
 BCS L3DB0

 LDA #&0A

.L3DB0

 JSR NWSHP

.MTT1

 LDA SSPR
 BNE MLOOP

 JSR BAD

 ASL A
 LDX MANY+2
 BEQ L3DC4

 ORA FIST

.L3DC4

 STA T
 JSR Ze

 CMP T
 BCS L3DD2

 LDA #&02
 JSR NWSHP

.L3DD2

 LDA MANY+2
 BNE MLOOP

 DEC EV
 BPL MLOOP

 INC EV
 JSR DORND

 LDY gov
 BEQ LABEL_2

 CMP #&5A
 BCS MLOOP

 AND #&07
 CMP gov
 BCC MLOOP

.LABEL_2

 JSR Ze

 CMP #&C8
 BCS mt1

 INC EV
 AND #&03
 ADC #&03
 TAY
 TXA
 CMP #&C8
 ROL A
 ORA #&C0
 STA INWK+32
 TYA
 JSR NWSHP

 JMP MLOOP

.mt1

 AND #&03
 STA EV
 STA XX13

.mt3

 JSR DORND

 AND #&03
 ORA #&01
 JSR NWSHP

 DEC XX13
 BPL mt3

.MLOOP

 LDA LASCT
 SBC #&04
 BCS L3E2E

 LDA #&00

.L3E2E

 STA LASCT
 LDX #&FF
 TXS
 INX
 STX L0D01
 LDX GNTMP
 BEQ EE20

 DEC GNTMP

.EE20

 JSR DIALS

 LDA QQ11
 BEQ L3E50

 AND PATG
 LSR A
 BCS L3E50

 JSR L285F

.L3E50

 JSR TT17

.FRCE

 JSR TT102

 LDA QQ12
 BNE MLOOP

.L3E5A

 JMP TT100

L3E5C = L3E5A+2
 EQUB &B1

 EQUB &91, &92

.TT102

 CMP #&A6
 BNE L3E67

 JMP STATUS

.L3E67

 CMP #&93
 BNE L3E6E

 JMP TT22

.L3E6E

 CMP #&B4
 BNE L3E75

 JMP TT23

.L3E75

 CMP #&A4
 BNE TT92

 JSR TT111

 JMP TT25

.TT92

 CMP #&A7
 BNE L3E86

 JMP TT213

.L3E86

 CMP #&95
 BNE L3E8D

 JMP TT167

.L3E8D

 CMP #&B0
 BNE fvw

 JMP TT110

.fvw

 BIT QQ12
 BPL INSP

 CMP #&92
 BNE L3E9F

 JMP EQSHP

.L3E9F

 CMP #&B1
 BNE L3EA6

 JMP TT219

.L3EA6

 CMP #&48
 BNE L3EAD

 JMP SVE

.L3EAD

 CMP #&91
 BNE LABEL_3

 JMP TT208

.INSP

 STX T
 LDX #&03

.L3EB8

 CMP L3E5C,X
 BNE L3EC0

 JMP LOOK1

.L3EC0

 DEX
 BNE L3EB8

 LDX T

.LABEL_3

 CMP #&54
 BNE L3ECC

 JMP hyp

.L3ECC

 CMP #&32
 BEQ T95

 STA T1
 LDA QQ11
 AND #&C0
 BEQ TT107

 LDA QQ22+1
 BNE TT107

 LDA T1
 CMP #&36
 BNE ee2

 JSR TT103

 JSR ping

 JSR TT103

.ee2

 JSR TT16

.TT107

 LDA QQ22+1
 BEQ t95

 DEC QQ22
 BNE t95

 LDX QQ22+1
 DEX
 JSR L304B

 LDA #&05
 STA QQ22
 LDX QQ22+1
 JSR L304B

 DEC QQ22+1
 BNE t95

 JMP TT18

.t95

 RTS

.T95

 LDA QQ11
 AND #&C0
 BEQ t95

 JSR hm

 STA QQ17
 JSR cpl

 LDA #&80
 STA QQ17
 LDA #&01
 STA XC
 INC YC
 JMP TT146

.BAD

 LDA QQ20+3
 CLC
 ADC QQ20+6
 ASL A
 ADC QQ20+10
 RTS

.FAROF

 LDA #&E0

.FAROF2

 CMP INWK+1
 BCC MA34

 CMP INWK+4
 BCC MA34

 CMP INWK+7

.MA34

 RTS

.MAS4

 ORA INWK+1
 ORA INWK+4
 ORA INWK+7
 RTS

.DEATH

 JSR EXNO3

 JSR RES2

 ASL DELTA
 ASL DELTA
 JSR TT66

 LDX #&32
 STX LASCT
 JSR BOX

 JSR nWq

 LDA #&0C
 STA YC
 STA XC
 LDA #&92
 STA MCNT
 JSR ex

.D1

 JSR Ze

 LDA #&20
 STA INWK
 LDY #&00
 STY QQ11
 STY INWK+1
 STY INWK+4
 STY INWK+7
 STY INWK+32
 DEY
 EOR #&2A
 STA INWK+3
 ORA #&50
 STA INWK+6
 TXA
 AND #&8F
 STA INWK+29
 ROR A
 AND #&87
 STA INWK+30
 PHP
 LDX #&0A
 JSR fq1

 PLP
 LDA #&00
 ROR A
 LDY #&1F
 STA (INF),Y
 LDA FRIN+3
 BEQ D1

 JSR U%

 STA DELTA

.D2

 JSR M%

 DEC LASCT
 BNE D2

.DEATH2

 JSR RES2

.TT170

 LDX #&FF
 TXS

.BR1

 LDX #&03
 STX XC
 JSR FX200

 LDX #&06
 LDA #&80
 JSR TITLE

 CMP #&44
 BNE QU5

 JSR GTNME

 JSR LOD

 JSR TRNME

 JSR TTX66

.QU5

 LDX #&4B

.QUL1

 LDA NA%+7,X
 STA TP-1,X
 DEX
 BNE QUL1

 STX QQ11

.L3FE4

 JSR CHECK

 CMP CHK
 BNE L3FE4

 EOR #&A9
 TAX
 LDA COK
 CPX CHK2
 BEQ tZ

 ORA #&80

.tZ

 ORA #&08
 STA COK
 JSR msblob

 LDA #&93
 LDX #&03
 JSR TITLE

 JSR ping

 JSR hyp1

.BAY

 LDA #&FF
 STA QQ12
 LDA #&A6
 JMP FRCE

.TITLE

 PHA
 STX TYPE
 JSR RESET

 LDA #&01
 JSR TT66

 DEC QQ11
 LDA #&60
 STA INWK+14
 STA INWK+7
 LDX #&7F
 STX INWK+29
 STX INWK+30
 INX
 STX QQ17
 LDA TYPE
 JSR NWSHP

 LDY #&06
 STY XC
 LDA #&1E
 JSR plf

 LDY #&06
 STY XC
 INC YC
 LDA PATG
 BEQ awe

 LDA #&FE
 JSR TT27

.awe

 JSR CLYNS

 STY DELTA
 STY JSTK
 PLA
 JSR ex

 LDA #&94
 LDX #&07
 STX XC
 JSR ex

.TLL2

 LDA INWK+7
 CMP #&01
 BEQ TL1

 DEC INWK+7

.TL1

 JSR MVEIT

 LDA #&80
 STA INWK+6
 ASL A
 STA INWK
 STA INWK+3
 JSR LL9

 DEC MCNT
 JSR RDKEY

 BEQ TLL2

 RTS

.CHECK

 LDX #&49
 CLC
 TXA

.QUL2

 ADC NA%+7,X
 EOR NA%+8,X
 DEX
 BNE QUL2

 RTS

.TRNME

 LDX #&07

.GTL1

 LDA INWK,X
 STA NA%,X
 DEX
 BPL GTL1

.TR1

 LDX #&07

.GTL2

 LDA NA%,X
 STA INWK,X
 DEX
 BPL GTL2

 RTS

.GTNME

 LDA #&01
 JSR TT66

 LDA #&7B
 JSR TT27

 JSR DEL8

 LDA #&0F
 TAX
 JSR OSBYTE

 LDX #&D2
 LDY #&40
 LDA #&00
 DEC L0D01
 JSR OSWORD

 INC L0D01
 BCS TR1

 TYA
 BEQ TR1

 JMP TT67

.L40D2

 EQUB &53

 EQUB &00, &07, &21, &7A

.ZERO

 LDX #&0B
 JSR ZES1

 DEX
 JSR ZES1

 DEX

.ZES1

 LDY #&00
 STY SC
 STX SCH

.ZES2

 LDA #&00

.ZEL1

 STA (SC),Y
 INY
 BNE ZEL1

 RTS

.SVE

 JSR GTNME

 JSR TRNME

 JSR ZERO

 LSR SVC
 LDX #&4B

.SVL1

 LDA TP,X
 STA K%,X
 STA NA%+8,X
 DEX
 BPL SVL1

 JSR CHECK

 STA CHK
 PHA
 ORA #&80
 STA K
 EOR COK
 STA K+2
 EOR CASH+2
 STA K+1
 EOR #&5A
 EOR TALLY+1
 STA K+3
 JSR BPRNT

 JSR TT67

 JSR TT67

 PLA
 STA K%+&4B
 EOR #&A9
 STA CHK2
 STA K%+&4A
 LDY #&09
 STY &0A0B
 INY
 STY &0A0F
 LDA #&00
 JSR QUS1

 JMP BAY

.QUS1

 LDX #&53
 STX &0A00
 LDX #&FF
 STX L0D01
 INX
 JSR OSFILE

 INC L0D01
 RTS

.LOD

 LDX #&02
 JSR FX200

 JSR ZERO

 LDY #&09
 STY &0A03
 INC &0A0B
 INY
 LDA #&FF
 JSR QUS1

 LDA K%
 BMI L418E

 LDX #&4B

.LOL1

 LDA K%,X
 STA NA%+8,X
 DEX
 BPL LOL1

 LDX #&03

.FX200

 LDY #&00
 LDA #&C8
 JMP OSBYTE

 RTS

.SPS1

 LDX #&00
L418E = SPS1+1
 JSR SPS3

 LDX #&03
 JSR SPS3

 LDX #&06
 JSR SPS3

.TAS2

 LDA K3
 ORA K3+3
 ORA K3+6
 ORA #&01
 STA K3+9
 LDA K3+1
 ORA K3+4
 ORA K3+7

.TAL2

 ASL K3+9
 ROL A
 BCS TA2

 ASL K3
 ROL K3+1
 ASL K3+3
 ROL K3+4
 ASL K3+6
 ROL K3+7
 BCC TAL2

.TA2

 LDA K3+1
 LSR A
 ORA K3+2
 STA XX15
 LDA K3+4
 LSR A
 ORA K3+5
 STA Y1
 LDA K3+7
 LSR A
 ORA K3+8
 STA X2

.NORM

 LDA XX15
 JSR SQUA

 STA R
 LDA P
 STA Q
 LDA Y1
 JSR SQUA

 STA T
 LDA P
 ADC Q
 STA Q
 LDA T
 ADC R
 STA R
 LDA X2
 JSR SQUA

 STA T
 LDA P
 ADC Q
 STA Q
 LDA T
 ADC R
 STA R
 JSR LL5

 LDA XX15
 JSR TIS2

 STA XX15
 LDA Y1
 JSR TIS2

 STA Y1
 LDA X2
 JSR TIS2

 STA X2
 RTS

.RDKEY

 LDX #&10

.Rd1

 JSR CTRL

 BMI Rd2

 INX
 BPL Rd1

 TXA

.Rd2

 EOR #&80
 TAY
 JSR L42D6

 PHP
 TYA
 PLP
 BPL L4236

 ORA #&80

.L4236

 TAX

.NO1

 RTS

.ECMOF

 LDA #&00
 STA ECMA
 STA ECMP
 JSR ECBLB

 LDA #&48
 BNE NOISE

.EXNO3

 LDA #&18
 BNE NOISE

.SFRMIS

 LDX #&08
 JSR L2160

 BCC NO1

 LDA #&78
 JSR MESS

 LDA #&30
 BNE NOISE

.EXNO2

 INC TALLY
 BNE L4267

 INC TALLY+1
 LDA #&65
 JSR MESS

.L4267

 LDX #&07

.EXNO

 STX T
 LDA #&18
 JSR NOS1

 LDA INWK+7
 LSR A
 LSR A
 AND T
 ORA #&F1
 STA XX16+2
 JSR NO3

 LDA #&10
 EQUB &2C

.BEEP

 LDA #&20

.NOISE

 JSR NOS1

.NO3

 LDX DNOIZ
 BNE NO1

 LDA XX16
 AND #&01
 TAX
 LDY XX16+8
 LDA L3C64,Y
 CMP L0BFB,X
 BCC NO1

 STA L0BFB,X
 AND #&0F
 STA L0BFD,X
 LDX #&09
 LDY #&00
 LDA #&07
 JMP OSWORD

.NOS1

 STA XX16+8
 LSR A
 ADC #&03
 TAY
 LDX #&07

.NOL1

 LDA #&00
 STA XX16,X
 DEX
 LDA L3C3C,Y
 STA XX16,X
 DEY
 DEX
 BPL NOL1

.KYTB

 RTS

 EQUB &E8

 EQUB &E2, &E6, &E7, &C2, &D1, &C1, &17, &70
 EQUB &23, &35, &65, &22, &45, &52

.L42D0

 SEC
 CLV
 SEI
 JMP (S%+4)

.L42D6

 LDX #&40

.CTRL

 TYA
 PHA
 TXA
 PHA
 ORA #&80
 TAX
 JSR L42D0

 CLI
 TAX
 PLA
 AND #&7F
 CPX #&80
 BCC L42ED

 ORA #&80

.L42ED

 TAX
 PLA
 TAY
 TXA
 RTS

 LDA #&80
 JSR OSBYTE

 TYA
 EOR JSTE
 RTS

.DKS3

 STY T
 CPX T
 BNE Dk3

 LDA tek,X
 EOR #&FF
 STA tek,X
 JSR BELL

 JSR DELAY

 LDY T

.Dk3

 RTS

.U%

 LDA #&00
 LDY #&0F

.DKL3

 STA KL,Y
 DEY
 BNE DKL3

 RTS

.DOKEY

 JSR U%

 LDY #&07

.DKL2

 LDX KYTB,Y
 JSR CTRL

 BPL L432F

 LDX #&FF
 STX KL,Y

.L432F

 DEY
 BNE DKL2

 LDX JSTX
 LDA #&07
 LDY KY3
 BEQ L433D

 JSR BUMP2

.L433D

 LDY KY4
 BEQ L4344

 JSR REDU2

.L4344

 STX JSTX
 ASL A
 LDX JSTY
 LDY KY5
 BEQ L4350

 JSR REDU2

.L4350

 LDY KY6
 BEQ L4357

 JSR BUMP2

.L4357

 STX JSTY
 JSR RDKEY

 STX KL
 CPX #&38
 BNE DK2

.FREEZE

 JSR DEL8

 JSR RDKEY

 CPX #&51
 BNE DK6

 LDA #&00
 STA DNOIZ

.DK6

 LDY #&40

.DKL4

 JSR DKS3

 INY
 CPY #&47
 BNE DKL4

 CPX #&10
 BNE DK7

 STX DNOIZ

.DK7

 CPX #&70
 BNE L4389

 JMP DEATH2

.L4389

 CPX #&59
 BNE FREEZE

.DK2

 LDA QQ11
 BNE DK5

 LDY #&0F
 LDA #&FF

.DKL1

 LDX KYTB,Y
 CPX KL
 BNE DK1

 STA KL,Y

.DK1

 DEY
 CPY #&07
 BNE DKL1

.DK5

 RTS

.TT217

 STY YSAV
 DEC L0D01
 JSR OSRDCH

 INC L0D01
 TAX

.L43B1

 RTS

.me1

 STX DLY
 PHA
 LDA MCH
 JSR mes9

 PLA
 EQUB &2C

.ou2

 LDA #&6C
 EQUB &2C

.ou3

 LDA #&6F

.MESS

 LDX #&00
 STX QQ17
 LDY #&09
 STY XC
 LDY #&16
 STY YC
 CPX DLY
 BNE me1

 STY DLY
 STA MCH

.mes9

 JSR TT27

 LSR de
 BCC L43B1

 LDA #&FD
 JMP TT27

.OUCH

 JSR DORND

 BMI L43B1

 CPX #&16
 BCS L43B1

 LDA QQ20,X
 BEQ L43B1

 LDA DLY
 BNE L43B1

 LDY #&03
 STY de
 STA QQ20,X
 CPX #&11
 BCS ou1

 TXA
 ADC #&D0
 BNE MESS

.ou1

 BEQ ou2

 CPX #&12
 BEQ ou3

 TXA
 ADC #&5D
 BNE MESS

.L4416

 EQUB &41

.L4417

 EQUB &4C, &4C, &45, &58, &45, &47, &45, &5A
 EQUB &41, &43, &45, &42, &49, &53, &4F, &55
 EQUB &53, &45, &53, &41, &52, &4D, &41, &49
 EQUB &4E, &44, &49, &52, &45, &41, &3F, &45
 EQUB &52, &41, &54, &45, &4E, &42, &45, &52
 EQUB &41, &4C, &41, &56, &45, &54, &49, &45
 EQUB &44, &4F, &52, &51, &55, &41, &4E, &54
 EQUB &45, &49, &53, &52, &49, &4F, &4E

.QQ23

 EQUB &13

.L4457

 EQUB &82

.L4458

 EQUB &06

.L4459

 EQUB &01, &14, &81, &0A, &03, &41, &83, &02
 EQUB &07, &28, &85, &E2, &1F, &53, &85, &FB
 EQUB &0F, &C4, &08, &36, &03, &EB, &1D, &08
 EQUB &78, &9A, &0E, &38, &03, &75, &06, &28
 EQUB &07, &4E, &01, &11, &1F, &7C, &0D, &1D
 EQUB &07, &B0, &89, &DC, &3F, &20, &81, &35
 EQUB &03, &61, &A1, &42, &07, &AB, &A2, &37
 EQUB &1F, &2D, &C1, &FA, &0F, &35, &0F, &C0
 EQUB &07

.TI2

 TYA
 LDY #&02
 JSR TIS3

 STA INWK+20
 JMP TI3

.TI1

 TAX
 LDA Y1
 AND #&60
 BEQ TI2

 LDA #&02
 JSR TIS3

 STA INWK+18
 JMP TI3

.TIDY

 LDA INWK+10
 STA XX15
 LDA INWK+12
 STA Y1
 LDA INWK+14
 STA X2
 JSR NORM

 LDA XX15
 STA INWK+10
 LDA Y1
 STA INWK+12
 LDA X2
 STA INWK+14
 LDY #&04
 LDA XX15
 AND #&60
 BEQ TI1

 LDX #&02
 LDA #&00
 JSR TIS3

 STA INWK+16

.TI3

 LDA INWK+16
 STA XX15
 LDA INWK+18
 STA Y1
 LDA INWK+20
 STA X2
 JSR NORM

 LDA XX15
 STA INWK+16
 LDA Y1
 STA INWK+18
 LDA X2
 STA INWK+20
 LDA INWK+12
 STA Q
 LDA INWK+20
 JSR MULT12

 LDX INWK+14
 LDA INWK+18
 JSR TIS1

 EOR #&80
 STA INWK+22
 LDA INWK+16
 JSR MULT12

 LDX INWK+10
 LDA INWK+20
 JSR TIS1

 EOR #&80
 STA INWK+24
 LDA INWK+18
 JSR MULT12

 LDX INWK+12
 LDA INWK+16
 JSR TIS1

 EOR #&80
 STA INWK+26
 LDA #&00
 LDX #&0E

.TIL1

 STA INWK+9,X
 DEX
 DEX
 BPL TIL1

 RTS

.TIS2

 TAY
 AND #&7F
 CMP Q
 BCS TI4

 LDX #&FE
 STX T

.TIL2

 ASL A
 CMP Q
 BCC L454E

 SBC Q

.L454E

 ROL T
 BCS TIL2

 LDA T
 LSR A
 LSR A
 STA T
 LSR A
 ADC T
 STA T
 TYA
 AND #&80
 ORA T
 RTS

.TI4

 TYA
 AND #&80
 ORA #&60
 RTS

.TIS3

 STA P+2
 LDA INWK+10,X
 STA Q
 LDA INWK+16,X
 JSR MULT12

 LDX INWK+10,Y
 STX Q
 LDA INWK+16,Y
 JSR MAD

 STX P
 LDY P+2
 LDX INWK+10,Y
 STX Q
 EOR #&80
 STA P+1
 EOR Q
 AND #&80
 STA T
 LDA #&00
 LDX #&10
 ASL P
 ROL P+1
 ASL Q
 LSR Q

.DVL2

 ROL A
 CMP Q
 BCC L45A3

 SBC Q

.L45A3

 ROL P
 ROL P+1
 DEX
 BNE DVL2

 LDA P
 ORA T
 RTS

.SHPPT

 JSR EE51

 JSR PROJ

 ORA K3+1
 BNE nono

 LDA K4
 CMP #&BE
 BCS nono

 LDY #&02
 JSR Shpt

 LDY #&06
 LDA K4
 ADC #&01
 JSR Shpt

 LDA #&08
 ORA INWK+31
 STA INWK+31
 LDA #&08
 JMP L4C81

.L45D8

 PLA
 PLA

.nono

 LDA #&F7
 AND INWK+31
 STA INWK+31
 RTS

.Shpt

 STA (XX19),Y
 INY
 INY
 STA (XX19),Y
 LDA K3
 DEY
 STA (XX19),Y
 ADC #&03
 BCS L45D8

 DEY
 DEY
 STA (XX19),Y
 RTS

.LL5

 LDY R
 LDA Q
 STA S
 LDX #&00
 STX Q
 LDA #&08
 STA T

.LL6

 CPX Q
 BCC LL7

 BNE LL8

 CPY #&40
 BCC LL7

.LL8

 TYA
 SBC #&40
 TAY
 TXA
 SBC Q
 TAX

.LL7

 ROL Q
 ASL S
 TYA
 ROL A
 TAY
 TXA
 ROL A
 TAX
 ASL S
 TYA
 ROL A
 TAY
 TXA
 ROL A
 TAX
 DEC T
 BNE LL6

 RTS

.LL28

 CMP Q
 BCS LL2

.L4630

 LDX #&FE
 STX R

.LL31

 ASL A
 BCS LL29

 CMP Q
 BCC L463D

 SBC Q

.L463D

 ROL R
 BCS LL31

 RTS

.LL29

 SBC Q
 SEC
 ROL R
 BCS LL31

 RTS

.LL2

 LDA #&FF
 STA R
 RTS

.LL38

 EOR S
 BMI LL39

 LDA Q
 CLC
 ADC R
 RTS

.LL39

 LDA R
 SEC
 SBC Q
 BCC L4662

 CLC
 RTS

.L4662

 PHA
 LDA S
 EOR #&80
 STA S
 PLA
 EOR #&FF
 ADC #&01
 RTS

.LL51

 LDX #&00
 LDY #&00

.ll51

 LDA XX15
 STA Q
 LDA XX16,X
 JSR FMLTU

 STA T
 LDA Y1
 EOR XX16+1,X
 STA S
 LDA X2
 STA Q
 LDA XX16+2,X
 JSR FMLTU

 STA Q
 LDA T
 STA R
 LDA Y2
 EOR XX16+3,X
 JSR LL38

 STA T
 LDA XX15+4
 STA Q
 LDA XX16+4,X
 JSR FMLTU

 STA Q
 LDA T
 STA R
 LDA XX15+5
 EOR XX16+5,X
 JSR LL38

 STA XX12,Y
 LDA S
 STA XX12+1,Y
 INY
 INY
 TXA
 CLC
 ADC #&06
 TAX
 CMP #&11
 BCC ll51

 RTS

.LL25

 JMP PLANET

.LL9

 LDA TYPE
 BMI LL25

 LDA #&1F
 STA XX4
 LDA #&20
 BIT INWK+31
 BNE EE28

 BPL EE28

 ORA INWK+31
 AND #&3F
 STA INWK+31
 LDA #&00
 LDY #&1C
 STA (INF),Y
 LDY #&1E
 STA (INF),Y
 JSR EE51

 LDY #&01
 LDA #&12
 STA (XX19),Y
 LDY #&07
 LDA (XX0),Y
 LDY #&02
 STA (XX19),Y

.EE55

 INY
 JSR DORND

 STA (XX19),Y
 CPY #&06
 BNE EE55

.EE28

 LDA INWK+8
 BPL LL10

.LL14

 LDA INWK+31
 AND #&20
 BEQ EE51

 LDA INWK+31
 AND #&F7
 STA INWK+31
 JMP DOEXP

.EE51

 LDA #&08
 BIT INWK+31
 BEQ L4724

 EOR INWK+31
 STA INWK+31
 JMP LL155

.L4724

 RTS

.LL10

 LDA INWK+7
 CMP #&C0
 BCS LL14

 LDA INWK
 CMP INWK+6
 LDA INWK+1
 SBC INWK+7
 BCS LL14

 LDA INWK+3
 CMP INWK+6
 LDA INWK+4
 SBC INWK+7
 BCS LL14

 LDY #&06
 LDA (XX0),Y
 TAX
 LDA #&FF
 STA XX3,X
 STA XX3+1,X
 LDA INWK+6
 STA T
 LDA INWK+7
 LSR A
 ROR T
 LSR A
 ROR T
 LSR A
 ROR T
 LSR A
 BNE LL13

 LDA T
 ROR A
 LSR A
 LSR A
 LSR A
 STA XX4
 BPL LL17

.LL13

 LDY #&0D
 LDA (XX0),Y
 CMP INWK+7
 BCS LL17

 LDA #&20
 AND INWK+31
 BNE LL17

 JMP SHPPT

.LL17

 LDX #&05

.LL15

 LDA INWK+21,X
 STA XX16,X
 LDA INWK+15,X
 STA XX16+6,X
 LDA INWK+9,X
 STA XX16+12,X
 DEX
 BPL LL15

 LDA #&C5
 STA Q
 LDY #&10

.LL21

 LDA XX16,Y
 ASL A
 LDA XX16+1,Y
 ROL A
 JSR LL28

 LDX R
 STX XX16,Y
 DEY
 DEY
 BPL LL21

 LDX #&08

.ll91

 LDA INWK,X
 STA QQ17,X
 DEX
 BPL ll91

 LDA #&FF
 STA K4+1
 LDY #&0C
 LDA INWK+31
 AND #&20
 BEQ EE29

 LDA (XX0),Y
 LSR A
 LSR A
 TAX
 LDA #&FF

.EE30

 STA K3,X
 DEX
 BPL EE30

 INX
 STX XX4

.LL41

 JMP LL42

.EE29

 LDA (XX0),Y
 BEQ LL41

 STA XX20
 LDY #&12
 LDA (XX0),Y
 TAX
 LDA K6+3
 TAY
 BEQ LL91

.L47DA

 INX
 LSR K6
 ROR QQ19+2
 LSR QQ19
 ROR QQ17
 LSR A
 ROR QQ19+5
 TAY
 BNE L47DA

.LL91

 STX XX17
 LDA K6+4
 STA XX15+5
 LDA QQ17
 STA XX15
 LDA QQ19+1
 STA Y1
 LDA QQ19+2
 STA X2
 LDA QQ19+4
 STA Y2
 LDA QQ19+5
 STA XX15+4
 JSR LL51

 LDA XX12
 STA QQ17
 LDA XX12+1
 STA QQ19+1
 LDA XX12+2
 STA QQ19+2
 LDA XX12+3
 STA QQ19+4
 LDA XX12+4
 STA QQ19+5
 LDA XX12+5
 STA K6+4
 LDY #&04
 LDA (XX0),Y
 CLC
 ADC XX0
 STA V
 LDY #&11
 LDA (XX0),Y
 ADC XX0+1
 STA V+1
 LDY #&00

.LL86

 LDA (V),Y
 STA XX12+1
 AND #&1F
 CMP XX4
 BCS LL87

 TYA
 LSR A
 LSR A
 TAX
 LDA #&FF
 STA K3,X
 TYA
 ADC #&04
 TAY
 JMP LL88

.LL87

 LDA XX12+1
 ASL A
 STA XX12+3
 ASL A
 STA XX12+5
 INY
 LDA (V),Y
 STA XX12
 INY
 LDA (V),Y
 STA XX12+2
 INY
 LDA (V),Y
 STA XX12+4
 LDX XX17
 CPX #&04
 BCC LL92

 LDA QQ17
 STA XX15
 LDA QQ19+1
 STA Y1
 LDA QQ19+2
 STA X2
 LDA QQ19+4
 STA Y2
 LDA QQ19+5
 STA XX15+4
 LDA K6+4
 STA XX15+5
 JMP LL89

.ovflw

 LSR QQ17
 LSR QQ19+5
 LSR QQ19+2
 LDX #&01

.LL92

 LDA XX12
 STA XX15
 LDA XX12+2
 STA X2
 LDA XX12+4
 DEX
 BMI LL94

.L4897

 LSR XX15
 LSR X2
 LSR A
 DEX
 BPL L4897

.LL94

 STA R
 LDA XX12+5
 STA S
 LDA QQ19+5
 STA Q
 LDA K6+4
 JSR LL38

 BCS ovflw

 STA XX15+4
 LDA S
 STA XX15+5
 LDA XX15
 STA R
 LDA XX12+1
 STA S
 LDA QQ17
 STA Q
 LDA QQ19+1
 JSR LL38

 BCS ovflw

 STA XX15
 LDA S
 STA Y1
 LDA X2
 STA R
 LDA XX12+3
 STA S
 LDA QQ19+2
 STA Q
 LDA QQ19+4
 JSR LL38

 BCS ovflw

 STA X2
 LDA S
 STA Y2

.LL89

 LDA XX12
 STA Q
 LDA XX15
 JSR FMLTU

 STA T
 LDA XX12+1
 EOR Y1
 STA S
 LDA XX12+2
 STA Q
 LDA X2
 JSR FMLTU

 STA Q
 LDA T
 STA R
 LDA XX12+3
 EOR Y2
 JSR LL38

 STA T
 LDA XX12+4
 STA Q
 LDA XX15+4
 JSR FMLTU

 STA Q
 LDA T
 STA R
 LDA XX15+5
 EOR XX12+5
 JSR LL38

 PHA
 TYA
 LSR A
 LSR A
 TAX
 PLA
 BIT S
 BMI L4933

 LDA #&00

.L4933

 STA K3,X
 INY

.LL88

 CPY XX20
 BCS LL42

 JMP LL86

.LL42

 LDY XX16+2
 LDX XX16+3
 LDA XX16+6
 STA XX16+2
 LDA XX16+7
 STA XX16+3
 STY XX16+6
 STX XX16+7
 LDY XX16+4
 LDX XX16+5
 LDA XX16+12
 STA XX16+4
 LDA XX16+13
 STA XX16+5
 STY XX16+12
 STX XX16+13
 LDY XX16+10
 LDX XX16+11
 LDA XX16+14
 STA XX16+10
 LDA XX16+15
 STA XX16+11
 STY XX16+14
 STX XX16+15
 LDY #&08
 LDA (XX0),Y
 STA XX20
 LDA XX0
 CLC
 ADC #&14
 STA V
 LDA XX0+1
 ADC #&00
 STA V+1
 LDY #&00
 STY CNT

.LL48

 STY XX17
 LDA (V),Y
 STA XX15
 INY
 LDA (V),Y
 STA X2
 INY
 LDA (V),Y
 STA XX15+4
 INY
 LDA (V),Y
 STA T
 AND #&1F
 CMP XX4
 BCC L49CD

 INY
 LDA (V),Y
 STA P
 AND #&0F
 TAX
 LDA K3,X
 BNE LL49

 LDA P
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 LDA K3,X
 BNE LL49

 INY
 LDA (V),Y
 STA P
 AND #&0F
 TAX
 LDA K3,X
 BNE LL49

 LDA P
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 LDA K3,X
 BNE LL49

.L49CD

 JMP LL50

.LL49

 LDA T
 STA Y1
 ASL A
 STA Y2
 ASL A
 STA XX15+5
 JSR LL51

 LDA INWK+2
 STA X2
 EOR XX12+1
 BMI LL52

 CLC
 LDA XX12
 ADC INWK
 STA XX15
 LDA INWK+1
 ADC #&00
 STA Y1
 JMP LL53

.LL52

 LDA INWK
 SEC
 SBC XX12
 STA XX15
 LDA INWK+1
 SBC #&00
 STA Y1
 BCS LL53

 EOR #&FF
 STA Y1
 LDA #&01
 SBC XX15
 STA XX15
 BCC L4A12

 INC Y1

.L4A12

 LDA X2
 EOR #&80
 STA X2

.LL53

 LDA INWK+5
 STA XX15+5
 EOR XX12+3
 BMI LL54

 CLC
 LDA XX12+2
 ADC INWK+3
 STA Y2
 LDA INWK+4
 ADC #&00
 STA XX15+4
 JMP LL55

.LL54

 LDA INWK+3
 SEC
 SBC XX12+2
 STA Y2
 LDA INWK+4
 SBC #&00
 STA XX15+4
 BCS LL55

 EOR #&FF
 STA XX15+4
 LDA Y2
 EOR #&FF
 ADC #&01
 STA Y2
 LDA XX15+5
 EOR #&80
 STA XX15+5
 BCC LL55

 INC XX15+4

.LL55

 LDA XX12+5
 BMI LL56

 LDA XX12+4
 CLC
 ADC INWK+6
 STA T
 LDA INWK+7
 ADC #&00
 STA U
 JMP LL57

.LL61

 LDX Q
 BEQ LL84

 LDX #&00

.LL63

 LSR A
 INX
 CMP Q
 BCS LL63

 STX S
 JSR LL28

 LDX S
 LDA R

.LL64

 ASL A
 ROL U
 BMI LL84

 DEX
 BNE LL64

 STA R
 RTS

.LL84

 LDA #&32
 STA R
 STA U
 RTS

.LL62

 LDA #&80
 SEC
 SBC R
 STA XX3,X
 INX
 LDA #&00
 SBC U
 STA XX3,X
 JMP LL66

.LL56

 LDA INWK+6
 SEC
 SBC XX12+4
 STA T
 LDA INWK+7
 SBC #&00
 STA U
 BCC LL140

 BNE LL57

 LDA T
 CMP #&04
 BCS LL57

.LL140

 LDA #&00
 STA U
 LDA #&04
 STA T

.LL57

 LDA U
 ORA Y1
 ORA XX15+4
 BEQ LL60

 LSR Y1
 ROR XX15
 LSR XX15+4
 ROR Y2
 LSR U
 ROR T
 JMP LL57

.LL60

 LDA T
 STA Q
 LDA XX15
 CMP Q
 BCC LL69

 JSR LL61

 JMP LL65

.LL69

 JSR LL28

.LL65

 LDX CNT
 LDA X2
 BMI LL62

 LDA R
 CLC
 ADC #&80
 STA XX3,X
 INX
 LDA U
 ADC #&00
 STA XX3,X

.LL66

 TXA
 PHA
 LDA #&00
 STA U
 LDA T
 STA Q
 LDA Y2
 CMP Q
 BCC LL67

 JSR LL61

 JMP LL68

.LL70

 LDA #&60
 CLC
 ADC R
 STA XX3,X
 INX
 LDA #&00
 ADC U
 STA XX3,X
 JMP LL50

.LL67

 JSR LL28

.LL68

 PLA
 TAX
 INX
 LDA XX15+5
 BMI LL70

 LDA #&60
 SEC
 SBC R
 STA XX3,X
 INX
 LDA #&00
 SBC U
 STA XX3,X

.LL50

 CLC
 LDA CNT
 ADC #&04
 STA CNT
 LDA XX17
 ADC #&06
 TAY
 BCS LL72

 CMP XX20
 BCS LL72

 JMP LL48

.LL72

 LDA INWK+31
 AND #&20
 BEQ EE31

 LDA INWK+31
 ORA #&08
 STA INWK+31
 JMP DOEXP

.EE31

 LDA #&08
 BIT INWK+31
 BEQ LL74

 JSR LL155

 LDA #&08

.LL74

 ORA INWK+31
 STA INWK+31
 LDY #&09
 LDA (XX0),Y
 STA XX20
 LDY #&00
 STY U
 STY XX17
 INC U
 BIT INWK+31
 BVC LL170

 LDA INWK+31
 AND #&BF
 STA INWK+31
 LDY #&06
 LDA (XX0),Y
 TAY
 LDX XX3,Y
 STX XX15
 INX
 BEQ LL170

 LDX XX3+1,Y
 STX Y1
 INX
 BEQ LL170

 LDX XX3+2,Y
 STX X2
 LDX XX3+3,Y
 STX Y2
 LDA #&00
 STA XX15+4
 STA XX15+5
 STA XX12+1
 LDA INWK+6
 STA XX12
 LDA INWK+2
 BPL L4BC1

 DEC XX15+4

.L4BC1

 JSR LL145

 BCS LL170

 LDY U
 LDA XX15
 STA (XX19),Y
 INY
 LDA Y1
 STA (XX19),Y
 INY
 LDA X2
 STA (XX19),Y
 INY
 LDA Y2
 STA (XX19),Y
 INY
 STY U

.LL170

 LDY #&03
 CLC
 LDA (XX0),Y
 ADC XX0
 STA V
 LDY #&10
 LDA (XX0),Y
 ADC XX0+1
 STA V+1
 LDY #&05
 LDA (XX0),Y
 STA T1
 LDY XX17

.LL75

 LDA (V),Y
 CMP XX4
 BCC LL78

 INY
 LDA (V),Y
 INY
 STA P
 AND #&0F
 TAX
 LDA K3,X
 BNE LL79

 LDA P
 LSR A
 LSR A
 LSR A
 LSR A
 TAX
 LDA K3,X
 BEQ LL78

.LL79

 LDA (V),Y
 TAX
 INY
 LDA (V),Y
 STA Q
 LDA XX3+1,X
 STA Y1
 LDA XX3,X
 STA XX15
 LDA XX3+2,X
 STA X2
 LDA XX3+3,X
 STA Y2
 LDX Q
 LDA XX3,X
 STA XX15+4
 LDA XX3+3,X
 STA XX12+1
 LDA XX3+2,X
 STA XX12
 LDA XX3+1,X
 STA XX15+5
 JSR LL147

 BCS LL78

 LDY U
 LDA XX15
 STA (XX19),Y
 INY
 LDA Y1
 STA (XX19),Y
 INY
 LDA X2
 STA (XX19),Y
 INY
 LDA Y2
 STA (XX19),Y
 INY
 STY U
 CPY T1
 BCS LL81

.LL78

 INC XX17
 LDY XX17
 CPY XX20
 BCS LL81

 LDY #&00
 LDA V
 ADC #&04
 STA V
 BCC ll81

 INC V+1

.ll81

 JMP LL75

.LL81

 LDA U

.L4C81

 LDY #&00
 STA (XX19),Y

.LL155

 LDY #&00
 LDA (XX19),Y
 STA XX20
 CMP #&04
 BCC L4CAB

 INY

.LL27

 LDA (XX19),Y
 STA XX15
 INY
 LDA (XX19),Y
 STA Y1
 INY
 LDA (XX19),Y
 STA X2
 INY
 LDA (XX19),Y
 STA Y2
 JSR LL30

 INY
 CPY XX20
 BCC LL27

.L4CAB

 RTS

.LL118

 LDA Y1
 BPL LL119

 STA S
 JSR LL120

 TXA
 CLC
 ADC X2
 STA X2
 TYA
 ADC Y2
 STA Y2
 LDA #&00
 STA XX15
 STA Y1
 TAX

.LL119

 BEQ LL134

 STA S
 DEC S
 JSR LL120

 TXA
 CLC
 ADC X2
 STA X2
 TYA
 ADC Y2
 STA Y2
 LDX #&FF
 STX XX15
 INX
 STX Y1

.LL134

 LDA Y2
 BPL LL135

 STA S
 LDA X2
 STA R
 JSR LL123

 TXA
 CLC
 ADC XX15
 STA XX15
 TYA
 ADC Y1
 STA Y1
 LDA #&00
 STA X2
 STA Y2

.LL135

 LDA X2
 SEC
 SBC #&C0
 STA R
 LDA Y2
 SBC #&00
 STA S
 BCC LL136

 JSR LL123

 TXA
 CLC
 ADC XX15
 STA XX15
 TYA
 ADC Y1
 STA Y1
 LDA #&BF
 STA X2
 LDA #&00
 STA Y2

.LL136

 RTS

.LL120

 LDA XX15
 STA R
 JSR LL129

 PHA
 LDX T
 BNE LL121

.LL122

 LDA #&00
 TAX
 TAY
 LSR S
 ROR R
 ASL Q
 BCC LL126

.LL125

 TXA
 CLC
 ADC R
 TAX
 TYA
 ADC S
 TAY

.LL126

 LSR S
 ROR R
 ASL Q
 BCS LL125

 BNE LL126

 PLA
 BPL LL133

 RTS

.LL123

 JSR LL129

 PHA
 LDX T
 BNE LL122

.LL121

 LDA #&FF
 TAY
 ASL A
 TAX

.LL130

 ASL R
 ROL S
 LDA S
 BCS LL131

 CMP Q
 BCC LL132

.LL131

 SBC Q
 STA S
 LDA R
 SBC #&00
 STA R
 SEC

.LL132

 TXA
 ROL A
 TAX
 TYA
 ROL A
 TAY
 BCS LL130

 PLA
 BMI LL128

.LL133

 TXA
 EOR #&FF
 ADC #&01
 TAX
 TYA
 EOR #&FF
 ADC #&00
 TAY

.LL128

 RTS

.LL129

 LDX XX12+2
 STX Q
 LDA S
 BPL LL127

 LDA #&00
 SEC
 SBC R
 STA R
 LDA S
 PHA
 EOR #&FF
 ADC #&00
 STA S
 PLA

.LL127

 EOR XX12+3
 RTS

.LL145

 LDA #&00
 STA SWAP
 LDA XX15+5

.LL147

 LDX #&BF
 ORA XX12+1
 BNE LL107

 CPX XX12
 BCC LL107

 LDX #&00

.LL107

 STX XX13
 LDA Y1
 ORA Y2
 BNE LL83

 LDA #&BF
 CMP X2
 BCC LL83

 LDA XX13
 BNE LL108

.LL146

 LDA X2
 STA Y1
 LDA XX15+4
 STA X2
 LDA XX12
 STA Y2
 CLC
 RTS

.LL109

 SEC
 RTS

.LL108

 LSR XX13

.LL83

 LDA XX13
 BPL LL115

 LDA Y1
 AND XX15+5
 BMI LL109

 LDA Y2
 AND XX12+1
 BMI LL109

 LDX Y1
 DEX
 TXA
 LDX XX15+5
 DEX
 STX XX12+2
 ORA XX12+2
 BPL LL109

 LDA X2
 CMP #&C0
 LDA Y2
 SBC #&00
 STA XX12+2
 LDA XX12
 CMP #&C0
 LDA XX12+1
 SBC #&00
 ORA XX12+2
 BPL LL109

.LL115

 TYA
 PHA
 LDA XX15+4
 SEC
 SBC XX15
 STA XX12+2
 LDA XX15+5
 SBC Y1
 STA XX12+3
 LDA XX12
 SEC
 SBC X2
 STA XX12+4
 LDA XX12+1
 SBC Y2
 STA XX12+5
 EOR XX12+3
 STA S
 LDA XX12+5
 BPL LL110

 LDA #&00
 SEC
 SBC XX12+4
 STA XX12+4
 LDA #&00
 SBC XX12+5
 STA XX12+5

.LL110

 LDA XX12+3
 BPL LL111

 SEC
 LDA #&00
 SBC XX12+2
 STA XX12+2
 LDA #&00
 SBC XX12+3

.LL111

 TAX
 BNE LL112

 LDX XX12+5
 BEQ LL113

.LL112

 LSR A
 ROR XX12+2
 LSR XX12+5
 ROR XX12+4
 JMP LL111

.LL113

 STX T
 LDA XX12+2
 CMP XX12+4
 BCC LL114

 STA Q
 LDA XX12+4
 JSR LL28

 JMP LL116

.LL114

 LDA XX12+4
 STA Q
 LDA XX12+2
 JSR LL28

 DEC T

.LL116

 LDA R
 STA XX12+2
 LDA S
 STA XX12+3
 LDA XX13
 BEQ LL138

 BPL LLX117

.LL138

 JSR LL118

 LDA XX13
 BPL LL124

 LDA Y1
 ORA Y2
 BNE LL137

 LDA X2
 CMP #&C0
 BCS LL137

.LLX117

 LDX XX15
 LDA XX15+4
 STA XX15
 STX XX15+4
 LDA XX15+5
 LDX Y1
 STX XX15+5
 STA Y1
 LDX X2
 LDA XX12
 STA X2
 STX XX12
 LDA XX12+1
 LDX Y2
 STX XX12+1
 STA Y2
 JSR LL118

 DEC SWAP

.LL124

 PLA
 TAY
 JMP LL146

.LL137

 PLA
 TAY
 SEC

.L4ED2

 RTS

.L4ED3

 EQUB &67

.XX21

 EQUB &EA, &4E, &92, &4F, &6C, &50, &9A, &51
 EQUB &8C, &52, &8C, &52, &14, &54, &30, &55
 EQUB &2E, &56, &04, &57, &AC, &57

SHIP_SIDEWINDER = $4EEA
SHIP_VIPER = $4F92
SHIP_MAMBA = $506C
SHIP_PYTHON = $519A
SHIP_COBRA_MK_3 = $528C
SHIP_CORIOLIS = $5414
SHIP_MISSILE = $5530
SHIP_ASTEROID = $562E
SHIP_CANISTER = $5704
SHIP_ESCAPE_POD = $57AC

 EQUB &00, &81, &10, &50, &8C, &3D, &00, &1E
 EQUB &3C, &0F, &32, &00, &1C, &14, &46, &25
 EQUB &00, &00, &02, &10, &20, &00, &24, &9F
 EQUB &10, &54, &20, &00, &24, &1F, &20, &65
 EQUB &40, &00, &1C, &3F, &32, &66, &40, &00
 EQUB &1C, &BF, &31, &44, &00, &10, &1C, &3F
 EQUB &10, &32, &00, &10, &1C, &7F, &43, &65
 EQUB &0C, &06, &1C, &AF, &33, &33, &0C, &06
 EQUB &1C, &2F, &33, &33, &0C, &06, &1C, &6C
 EQUB &33, &33, &0C, &06, &1C, &EC, &33, &33
 EQUB &1F, &50, &00, &04, &1F, &62, &04, &08
 EQUB &1F, &20, &04, &10, &1F, &10, &00, &10
 EQUB &1F, &41, &00, &0C, &1F, &31, &0C, &10
 EQUB &1F, &32, &08, &10, &1F, &43, &0C, &14
 EQUB &1F, &63, &08, &14, &1F, &65, &04, &14
 EQUB &1F, &54, &00, &14, &0F, &33, &18, &1C
 EQUB &0C, &33, &1C, &20, &0C, &33, &18, &24
 EQUB &0C, &33, &20, &24, &1F, &00, &20, &08
 EQUB &9F, &0C, &2F, &06, &1F, &0C, &2F, &06
 EQUB &3F, &00, &00, &70, &DF, &0C, &2F, &06
 EQUB &5F, &00, &20, &08, &5F, &0C, &2F, &06

 EQUB &00, &F9, &15, &6E, &BE, &4D, &00, &2A
 EQUB &5A, &14, &00, &00, &1C, &17, &78, &20
 EQUB &00, &00, &01, &11, &00, &00, &48, &1F
 EQUB &21, &43, &00, &10, &18, &1E, &10, &22
 EQUB &00, &10, &18, &5E, &43, &55, &30, &00
 EQUB &18, &3F, &42, &66, &30, &00, &18, &BF
 EQUB &31, &66, &18, &10, &18, &7E, &54, &66
 EQUB &18, &10, &18, &FE, &35, &66, &18, &10
 EQUB &18, &3F, &20, &66, &18, &10, &18, &BF
 EQUB &10, &66, &20, &00, &18, &B3, &66, &66
 EQUB &20, &00, &18, &33, &66, &66, &08, &08
 EQUB &18, &33, &66, &66, &08, &08, &18, &B3
 EQUB &66, &66, &08, &08, &18, &F2, &66, &66
 EQUB &08, &08, &18, &72, &66, &66, &1F, &42
 EQUB &00, &0C, &1E, &21, &00, &04, &1E, &43
 EQUB &00, &08, &1F, &31, &00, &10, &1E, &20
 EQUB &04, &1C, &1E, &10, &04, &20, &1E, &54
 EQUB &08, &14, &1E, &53, &08, &18, &1F, &60
 EQUB &1C, &20, &1E, &65, &14, &18, &1F, &61
 EQUB &10, &20, &1E, &63, &10, &18, &1F, &62
 EQUB &0C, &1C, &1E, &46, &0C, &14, &13, &66
 EQUB &24, &30, &12, &66, &24, &34, &13, &66
 EQUB &28, &2C, &12, &66, &28, &38, &10, &66
 EQUB &2C, &38, &10, &66, &30, &34, &1F, &00
 EQUB &20, &00, &9F, &16, &21, &0B, &1F, &16
 EQUB &21, &0B, &DF, &16, &21, &0B, &5F, &16
 EQUB &21, &0B, &5F, &00, &20, &00, &3F, &00
 EQUB &00, &30

 EQUB &01, &24, &13, &AA, &1A, &5D, &00, &22
 EQUB &96, &1C, &96, &00, &14, &19, &5A, &1E
 EQUB &00, &01, &02, &12, &00, &00, &40, &1F
 EQUB &10, &32, &40, &08, &20, &FF, &20, &44
 EQUB &20, &08, &20, &BE, &21, &44, &20, &08
 EQUB &20, &3E, &31, &44, &40, &08, &20, &7F
 EQUB &30, &44, &04, &04, &10, &8E, &11, &11
 EQUB &04, &04, &10, &0E, &11, &11, &08, &03
 EQUB &1C, &0D, &11, &11, &08, &03, &1C, &8D
 EQUB &11, &11, &14, &04, &10, &D4, &00, &00
 EQUB &14, &04, &10, &54, &00, &00, &18, &07
 EQUB &14, &F4, &00, &00, &10, &07, &14, &F0
 EQUB &00, &00, &10, &07, &14, &70, &00, &00
 EQUB &18, &07, &14, &74, &00, &00, &08, &04
 EQUB &20, &AD, &44, &44, &08, &04, &20, &2D
 EQUB &44, &44, &08, &04, &20, &6E, &44, &44
 EQUB &08, &04, &20, &EE, &44, &44, &20, &04
 EQUB &20, &A7, &44, &44, &20, &04, &20, &27
 EQUB &44, &44, &24, &04, &20, &67, &44, &44
 EQUB &24, &04, &20, &E7, &44, &44, &26, &00
 EQUB &20, &A5, &44, &44, &26, &00, &20, &25
 EQUB &44, &44, &1F, &20, &00, &04, &1F, &30
 EQUB &00, &10, &1F, &40, &04, &10, &1E, &42
 EQUB &04, &08, &1E, &41, &08, &0C, &1E, &43
 EQUB &0C, &10, &0E, &11, &14, &18, &0C, &11
 EQUB &18, &1C, &0D, &11, &1C, &20, &0C, &11
 EQUB &14, &20, &14, &00, &24, &2C, &10, &00
 EQUB &24, &30, &10, &00, &28, &34, &14, &00
 EQUB &28, &38, &0E, &00, &34, &38, &0E, &00
 EQUB &2C, &30, &0D, &44, &3C, &40, &0E, &44
 EQUB &44, &48, &0C, &44, &3C, &48, &0C, &44
 EQUB &40, &44, &07, &44, &50, &54, &05, &44
 EQUB &50, &60, &05, &44, &54, &60, &07, &44
 EQUB &4C, &58, &05, &44, &4C, &5C, &05, &44
 EQUB &58, &5C, &1E, &21, &00, &08, &1E, &31
 EQUB &00, &0C, &5E, &00, &18, &02, &1E, &00
 EQUB &18, &02, &9E, &20, &40, &10, &1E, &20
 EQUB &40, &10, &3E, &00, &00, &7F

 EQUB &03, &40, &38, &56, &BE, &55, &00, &2E
 EQUB &42, &1A, &C8, &00, &34, &28, &FA, &14
 EQUB &00, &00, &00, &1B, &00, &00, &E0, &1F
 EQUB &10, &32, &00, &30, &30, &1E, &10, &54
 EQUB &60, &00, &10, &3F, &FF, &FF, &60, &00
 EQUB &10, &BF, &FF, &FF, &00, &30, &20, &3E
 EQUB &54, &98, &00, &18, &70, &3F, &89, &CC
 EQUB &30, &00, &70, &BF, &B8, &CC, &30, &00
 EQUB &70, &3F, &A9, &CC, &00, &30, &30, &5E
 EQUB &32, &76, &00, &30, &20, &7E, &76, &BA
 EQUB &00, &18, &70, &7E, &BA, &CC, &1E, &32
 EQUB &00, &20, &1F, &20, &00, &0C, &1F, &31
 EQUB &00, &08, &1E, &10, &00, &04, &1D, &59
 EQUB &08, &10, &1D, &51, &04, &08, &1D, &37
 EQUB &08, &20, &1D, &40, &04, &0C, &1D, &62
 EQUB &0C, &20, &1D, &A7, &08, &24, &1D, &84
 EQUB &0C, &10, &1D, &B6, &0C, &24, &05, &88
 EQUB &0C, &14, &05, &BB, &0C, &28, &05, &99
 EQUB &08, &14, &05, &AA, &08, &28, &1F, &A9
 EQUB &08, &1C, &1F, &B8, &0C, &18, &1F, &C8
 EQUB &14, &18, &1F, &C9, &14, &1C, &1D, &AC
 EQUB &1C, &28, &1D, &CB, &18, &28, &1D, &98
 EQUB &10, &14, &1D, &BA, &24, &28, &1D, &54
 EQUB &04, &10, &1D, &76, &20, &24, &9E, &1B
 EQUB &28, &0B, &1E, &1B, &28, &0B, &DE, &1B
 EQUB &28, &0B, &5E, &1B, &28, &0B, &9E, &13
 EQUB &26, &00, &1E, &13, &26, &00, &DE, &13
 EQUB &26, &00, &5E, &13, &26, &00, &BE, &19
 EQUB &25, &0B, &3E, &19, &25, &0B, &7E, &19
 EQUB &25, &0B, &FE, &19, &25, &0B, &3E, &00
 EQUB &00, &70

 EQUB &03, &41, &23, &BC, &54, &99, &54, &2A
 EQUB &A8, &26, &00, &00, &34, &32, &96, &1C
 EQUB &00, &01, &01, &13, &20, &00, &4C, &1F
 EQUB &FF, &FF, &20, &00, &4C, &9F, &FF, &FF
 EQUB &00, &1A, &18, &1F, &FF, &FF, &78, &03
 EQUB &08, &FF, &73, &AA, &78, &03, &08, &7F
 EQUB &84, &CC, &58, &10, &28, &BF, &FF, &FF
 EQUB &58, &10, &28, &3F, &FF, &FF, &80, &08
 EQUB &28, &7F, &98, &CC, &80, &08, &28, &FF
 EQUB &97, &AA, &00, &1A, &28, &3F, &65, &99
 EQUB &20, &18, &28, &FF, &A9, &BB, &20, &18
 EQUB &28, &7F, &B9, &CC, &24, &08, &28, &B4
 EQUB &99, &99, &08, &0C, &28, &B4, &99, &99
 EQUB &08, &0C, &28, &34, &99, &99, &24, &08
 EQUB &28, &34, &99, &99, &24, &0C, &28, &74
 EQUB &99, &99, &08, &10, &28, &74, &99, &99
 EQUB &08, &10, &28, &F4, &99, &99, &24, &0C
 EQUB &28, &F4, &99, &99, &00, &00, &4C, &06
 EQUB &B0, &BB, &00, &00, &5A, &1F, &B0, &BB
 EQUB &50, &06, &28, &E8, &99, &99, &50, &06
 EQUB &28, &A8, &99, &99, &58, &00, &28, &A6
 EQUB &99, &99, &50, &06, &28, &28, &99, &99
 EQUB &58, &00, &28, &26, &99, &99, &50, &06
 EQUB &28, &68, &99, &99, &1F, &B0, &00, &04
 EQUB &1F, &C4, &00, &10, &1F, &A3, &04, &0C
 EQUB &1F, &A7, &0C, &20, &1F, &C8, &10, &1C
 EQUB &1F, &98, &18, &1C, &1F, &96, &18, &24
 EQUB &1F, &95, &14, &24, &1F, &97, &14, &20
 EQUB &1F, &51, &08, &14, &1F, &62, &08, &18
 EQUB &1F, &73, &0C, &14, &1F, &84, &10, &18
 EQUB &1F, &10, &04, &08, &1F, &20, &00, &08
 EQUB &1F, &A9, &20, &28, &1F, &B9, &28, &2C
 EQUB &1F, &C9, &1C, &2C, &1F, &BA, &04, &28
 EQUB &1F, &CB, &00, &2C, &1D, &31, &04, &14
 EQUB &1D, &42, &00, &18, &06, &B0, &50, &54
 EQUB &14, &99, &30, &34, &14, &99, &48, &4C
 EQUB &14, &99, &38, &3C, &14, &99, &40, &44
 EQUB &13, &99, &3C, &40, &11, &99, &38, &44
 EQUB &13, &99, &34, &48, &13, &99, &30, &4C
 EQUB &1E, &65, &08, &24, &06, &99, &58, &60
 EQUB &06, &99, &5C, &60, &08, &99, &58, &5C
 EQUB &06, &99, &64, &68, &06, &99, &68, &6C
 EQUB &08, &99, &64, &6C, &1F, &00, &3E, &1F
 EQUB &9F, &12, &37, &10, &1F, &12, &37, &10
 EQUB &9F, &10, &34, &0E, &1F, &10, &34, &0E
 EQUB &9F, &0E, &2F, &00, &1F, &0E, &2F, &00
 EQUB &9F, &3D, &66, &00, &1F, &3D, &66, &00
 EQUB &3F, &00, &00, &50, &DF, &07, &2A, &09
 EQUB &5F, &00, &1E, &06, &5F, &07, &2A, &09

 EQUB &00, &00, &64, &74, &E4, &55, &00, &36
 EQUB &60, &1C, &00, &00, &38, &78, &F0, &00
 EQUB &00, &00, &00, &06, &A0, &00, &A0, &1F
 EQUB &10, &62, &00, &A0, &A0, &1F, &20, &83
 EQUB &A0, &00, &A0, &9F, &30, &74, &00, &A0
 EQUB &A0, &5F, &10, &54, &A0, &A0, &00, &5F
 EQUB &51, &A6, &A0, &A0, &00, &1F, &62, &B8
 EQUB &A0, &A0, &00, &9F, &73, &C8, &A0, &A0
 EQUB &00, &DF, &54, &97, &A0, &00, &A0, &3F
 EQUB &A6, &DB, &00, &A0, &A0, &3F, &B8, &DC
 EQUB &A0, &00, &A0, &BF, &97, &DC, &00, &A0
 EQUB &A0, &7F, &95, &DA, &0A, &1E, &A0, &5E
 EQUB &00, &00, &0A, &1E, &A0, &1E, &00, &00
 EQUB &0A, &1E, &A0, &9E, &00, &00, &0A, &1E
 EQUB &A0, &DE, &00, &00, &1F, &10, &00, &0C
 EQUB &1F, &20, &00, &04, &1F, &30, &04, &08
 EQUB &1F, &40, &08, &0C, &1F, &51, &0C, &10
 EQUB &1F, &61, &00, &10, &1F, &62, &00, &14
 EQUB &1F, &82, &14, &04, &1F, &83, &04, &18
 EQUB &1F, &73, &08, &18, &1F, &74, &08, &1C
 EQUB &1F, &54, &0C, &1C, &1F, &DA, &20, &2C
 EQUB &1F, &DB, &20, &24, &1F, &DC, &24, &28
 EQUB &1F, &D9, &28, &2C, &1F, &A5, &10, &2C
 EQUB &1F, &A6, &10, &20, &1F, &B6, &14, &20
 EQUB &1F, &B8, &14, &24, &1F, &C8, &18, &24
 EQUB &1F, &C7, &18, &28, &1F, &97, &1C, &28
 EQUB &1F, &95, &1C, &2C, &1E, &00, &30, &34
 EQUB &1E, &00, &34, &38, &1E, &00, &38, &3C
 EQUB &1E, &00, &3C, &30, &1F, &00, &00, &A0
 EQUB &5F, &6B, &6B, &6B, &1F, &6B, &6B, &6B
 EQUB &9F, &6B, &6B, &6B, &DF, &6B, &6B, &6B
 EQUB &5F, &00, &A0, &00, &1F, &A0, &00, &00
 EQUB &9F, &A0, &00, &00, &1F, &00, &A0, &00
 EQUB &FF, &6B, &6B, &6B, &7F, &6B, &6B, &6B
 EQUB &3F, &6B, &6B, &6B, &BF, &6B, &6B, &6B
 EQUB &3F, &00, &00, &A0

 EQUB &00, &40, &06, &7A, &DA, &51, &00, &0A
 EQUB &66, &18, &00, &00, &24, &0E, &02, &2C
 EQUB &00, &00, &02, &00, &00, &00, &44, &1F
 EQUB &10, &32, &08, &08, &24, &5F, &21, &54
 EQUB &08, &08, &24, &1F, &32, &74, &08, &08
 EQUB &24, &9F, &30, &76, &08, &08, &24, &DF
 EQUB &10, &65, &08, &08, &2C, &3F, &74, &88
 EQUB &08, &08, &2C, &7F, &54, &88, &08, &08
 EQUB &2C, &FF, &65, &88, &08, &08, &2C, &BF
 EQUB &76, &88, &0C, &0C, &2C, &28, &74, &88
 EQUB &0C, &0C, &2C, &68, &54, &88, &0C, &0C
 EQUB &2C, &E8, &65, &88, &0C, &0C, &2C, &A8
 EQUB &76, &88, &08, &08, &0C, &A8, &76, &77
 EQUB &08, &08, &0C, &E8, &65, &66, &08, &08
 EQUB &0C, &28, &74, &77, &08, &08, &0C, &68
 EQUB &54, &55, &1F, &21, &00, &04, &1F, &32
 EQUB &00, &08, &1F, &30, &00, &0C, &1F, &10
 EQUB &00, &10, &1F, &24, &04, &08, &1F, &51
 EQUB &04, &10, &1F, &60, &0C, &10, &1F, &73
 EQUB &08, &0C, &1F, &74, &08, &14, &1F, &54
 EQUB &04, &18, &1F, &65, &10, &1C, &1F, &76
 EQUB &0C, &20, &1F, &86, &1C, &20, &1F, &87
 EQUB &14, &20, &1F, &84, &14, &18, &1F, &85
 EQUB &18, &1C, &08, &85, &18, &28, &08, &87
 EQUB &14, &24, &08, &87, &20, &30, &08, &85
 EQUB &1C, &2C, &08, &74, &24, &3C, &08, &54
 EQUB &28, &40, &08, &76, &30, &34, &08, &65
 EQUB &2C, &38, &9F, &40, &00, &10, &5F, &00
 EQUB &40, &10, &1F, &40, &00, &10, &1F, &00
 EQUB &40, &10, &1F, &20, &00, &00, &5F, &00
 EQUB &20, &00, &9F, &20, &00, &00, &1F, &00
 EQUB &20, &00, &3F, &00, &00, &B0

 EQUB &00, &00, &19, &4A, &9E, &41, &00, &22
 EQUB &36, &15, &05, &00, &38, &32, &3C, &1E
 EQUB &00, &00, &01, &00, &00, &50, &00, &1F
 EQUB &FF, &FF, &50, &0A, &00, &DF, &FF, &FF
 EQUB &00, &50, &00, &5F, &FF, &FF, &46, &28
 EQUB &00, &5F, &FF, &FF, &3C, &32, &00, &1F
 EQUB &65, &DC, &32, &00, &3C, &1F, &FF, &FF
 EQUB &28, &00, &46, &9F, &10, &32, &00, &1E
 EQUB &4B, &3F, &FF, &FF, &00, &32, &3C, &7F
 EQUB &98, &BA, &1F, &72, &00, &04, &1F, &D6
 EQUB &00, &10, &1F, &C5, &0C, &10, &1F, &B4
 EQUB &08, &0C, &1F, &A3, &04, &08, &1F, &32
 EQUB &04, &18, &1F, &31, &08, &18, &1F, &41
 EQUB &08, &14, &1F, &10, &14, &18, &1F, &60
 EQUB &00, &14, &1F, &54, &0C, &14, &1F, &20
 EQUB &00, &18, &1F, &65, &10, &14, &1F, &A8
 EQUB &04, &20, &1F, &87, &04, &1C, &1F, &D7
 EQUB &00, &1C, &1F, &DC, &10, &1C, &1F, &C9
 EQUB &0C, &1C, &1F, &B9, &0C, &20, &1F, &BA
 EQUB &08, &20, &1F, &98, &1C, &20, &1F, &09
 EQUB &42, &51, &5F, &09, &42, &51, &9F, &48
 EQUB &40, &1F, &DF, &40, &49, &2F, &5F, &2D
 EQUB &4F, &41, &1F, &87, &0F, &23, &1F, &26
 EQUB &4C, &46, &BF, &42, &3B, &27, &FF, &43
 EQUB &0F, &50, &7F, &42, &0E, &4B, &FF, &46
 EQUB &50, &28, &7F, &3A, &66, &33, &3F, &51
 EQUB &09, &43, &3F, &2F, &5E, &3F

 EQUB &00, &90, &01, &50, &8C, &31, &00, &12
 EQUB &3C, &0F, &00, &00, &1C, &0C, &11, &0F
 EQUB &00, &00, &02, &00, &18, &10, &00, &1F
 EQUB &10, &55, &18, &05, &0F, &1F, &10, &22
 EQUB &18, &0D, &09, &5F, &20, &33, &18, &0D
 EQUB &09, &7F, &30, &44, &18, &05, &0F, &3F
 EQUB &40, &55, &18, &10, &00, &9F, &51, &66
 EQUB &18, &05, &0F, &9F, &21, &66, &18, &0D
 EQUB &09, &DF, &32, &66, &18, &0D, &09, &FF
 EQUB &43, &66, &18, &05, &0F, &BF, &54, &66
 EQUB &1F, &10, &00, &04, &1F, &20, &04, &08
 EQUB &1F, &30, &08, &0C, &1F, &40, &0C, &10
 EQUB &1F, &50, &00, &10, &1F, &51, &00, &14
 EQUB &1F, &21, &04, &18, &1F, &32, &08, &1C
 EQUB &1F, &43, &0C, &20, &1F, &54, &10, &24
 EQUB &1F, &61, &14, &18, &1F, &62, &18, &1C
 EQUB &1F, &63, &1C, &20, &1F, &64, &20, &24
 EQUB &1F, &65, &24, &14, &1F, &60, &00, &00
 EQUB &1F, &00, &29, &1E, &5F, &00, &12, &30
 EQUB &5F, &00, &33, &00, &7F, &00, &12, &30
 EQUB &3F, &00, &29, &1E, &9F, &60, &00, &00

 EQUB &00, &00, &01, &2C, &44, &19, &00, &16
 EQUB &18, &06, &00, &00, &10, &08, &11, &08
 EQUB &00, &00, &03, &00, &07, &00, &24, &9F
 EQUB &12, &33, &07, &0E, &0C, &FF, &02, &33
 EQUB &07, &0E, &0C, &BF, &01, &33, &15, &00
 EQUB &00, &1F, &01, &22, &1F, &23, &00, &04
 EQUB &1F, &03, &04, &08, &1F, &01, &08, &0C
 EQUB &1F, &12, &0C, &00, &1F, &13, &00, &08
 EQUB &1F, &02, &0C, &04, &3F, &1A, &00, &3D
 EQUB &1F, &13, &33, &0F, &5F, &13, &33, &0F
 EQUB &9F, &38, &00, &00

PRINT "S.ELITECO ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/ELITECO.bin", CODE%, P%, LOAD%
