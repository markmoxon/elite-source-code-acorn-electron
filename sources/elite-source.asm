INCLUDE "sources/elite-header.h.asm"

\ ******************************************************************************
\
\ ELITE RECURSIVE TEXT TOKEN FILE
\
\ Produces the binary file WORDS9.bin that gets loaded by elite-loader.asm.
\
\ The recursive token table is loaded at &1100 and is moved down to &0400 as
\ part of elite-loader.asm, so it ends up at &0400 to &07FF.
\
\ ******************************************************************************

CODE_WORDS% = &0400
LOAD_WORDS% = &1100

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

 RTOK 95                \ Token 0:      
 EQUB 0                 \ ELECTRON_VERSION

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

 TWOK 'E', 'S'          \ Token 112:    "ESCAPE POD"
 CHAR 'C'               \
 CHAR 'A'               \ Encoded as:   "<137>CAPE POD"
 CHAR 'P'
 CHAR 'E'
 CHAR ' '
 CHAR 'C'               \ ELECTRON_VERSION
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

CODE% = &0D00
LOAD% = &2000

RAND    = $0000
L0001   = $0001
L0002   = $0002
L0003   = $0003
T1      = $0006
SC      = $0007
SCH     = $0008
L0009   = $0009
L000A   = $000A
L000B   = $000B
L000C   = $000C
L000D   = $000D
L000E   = $000E
L000F   = $000F
L0010   = $0010
L0011   = $0011
L0013   = $0013
L0014   = $0014
L0015   = $0015
L0016   = $0016
L0017   = $0017
L0018   = $0018
P       = $001B
L001C   = $001C
L001D   = $001D
XX0     = $001E
L001F   = $001F
INF     = $0020
L0021   = $0021
V       = $0022
L0023   = $0023
XX      = $0024
L0025   = $0025
YY      = $0026
L0027   = $0027
BETA    = $002A
BET1    = $002B
XC      = $002C
YC      = $002D
QQ22    = $002E
L002F   = $002F
ECMA    = $0030
XX15    = $0031
Y1      = $0032
X2      = $0033
Y2      = $0034
L0035   = $0035
L0036   = $0036
XX12    = $0037
L0038   = $0038
L0039   = $0039
L003A   = $003A
L003B   = $003B
L003C   = $003C
K       = $003D
L003E   = $003E
L003F   = $003F
L0040   = $0040
KL      = $0041
KY1     = $0042
KY2     = $0043
L0044   = $0044
L0045   = $0045
L0046   = $0046
L0047   = $0047
KY7     = $0048
KY12    = $0049
KY13    = $004A
KY14    = $004B
KY15    = $004C
KY16    = $004D
KY17    = $004E
KY18    = $004F
KY19    = $0050
LAS     = $0051
MSTG    = $0052
INWK    = $0053
L0054   = $0054
L0055   = $0055
L0056   = $0056
L0057   = $0057
L0058   = $0058
L0059   = $0059
L005A   = $005A
L005B   = $005B
L005C   = $005C
L005D   = $005D
L005F   = $005F
L0061   = $0061
L0062   = $0062
L0063   = $0063
L0065   = $0065
L0067   = $0067
L0068   = $0068
L0069   = $0069
L006B   = $006B
L006D   = $006D
L006E   = $006E
L006F   = $006F
L0070   = $0070
L0071   = $0071
L0072   = $0072
L0073   = $0073
XX19    = $0074
L0075   = $0075
L0076   = $0076
LSP     = $0077
QQ15    = $0078
L0079   = $0079
L007A   = $007A
L007B   = $007B
L007C   = $007C
L007D   = $007D
QQ17    = $007E
QQ19    = $007F
L0080   = $0080
L0081   = $0081
K6      = $0082
L0083   = $0083
L0084   = $0084
L0085   = $0085
L0086   = $0086
ALP1    = $0087
ALP2    = $0088
L0089   = $0089
BET2    = $008A
L008B   = $008B
DELTA   = $008C
DELT4   = $008D
L008E   = $008E
U       = $008F
Q       = $00A0
R       = $00A1
S       = $00A2
XSAV    = $00A3
YSAV    = $00A4
XX17    = $00A5
QQ11    = $00A6
ZZ      = $00A7
XX13    = $00A8
MCNT    = $00A9
TYPE    = $00AB
JSTX    = $00AC
JSTY    = $00AD
ALPHA   = $00AE
QQ12    = $00AF
TGT     = $00B0
SWAP    = $00B1
FLAG    = $00B3
CNT     = $00B4
STP     = $00B6
XX4     = $00B7
XX20    = $00B8
RAT     = $00BA
RAT2    = $00BB
K2      = $00BC
L00BD   = $00BD
L00BE   = $00BE
L00BF   = $00BF
T       = $00D1
K3      = $00D2
L00D3   = $00D3
L00D4   = $00D4
L00D5   = $00D5
L00D6   = $00D6
L00D7   = $00D7
L00D8   = $00D8
L00D9   = $00D9
L00DA   = $00DA
L00DB   = $00DB
K4      = $00E0
L00E1   = $00E1
L00F9   = $00F9
L00FC   = $00FC
XX3     = $0100
L0101   = $0101
L0102   = $0102
L0103   = $0103
USERV   = $0200
BRKV    = $0202
IRQ1V   = $0204
IRQ2V   = $0206
CLIV    = $0208
BYTEV   = $020A
WORDV   = $020C
WRCHV   = $020E
RDCHV   = $0210
FILEV   = $0212
ARGSV   = $0214
BGETV   = $0216
BPUTV   = $0218
GBPBV   = $021A
FINDV   = $021C
FSCV    = $021E
EVENTV  = $0220
UPTV    = $0222
NETV    = $0224
VDUV    = $0226
KEYV    = $0228
INSV    = $022A
REMV    = $022C
CNPV    = $022E
INDV1   = $0230
INDV2   = $0232
INDV3   = $0234
L02B9   = $02B9
L02FF   = $02FF
TP      = $0300
QQ0     = $0301
QQ1     = $0302
QQ21    = $0303
CASH    = $0309
L030A   = $030A
L030B   = $030B
L030C   = $030C
QQ14    = $030D
COK     = $030E
GCNT    = $030F
LASER   = $0310
CRGO    = $0316
QQ20    = $0317
L031A   = $031A
L031D   = $031D
L0321   = $0321
ECM     = $0328
BST     = $0329
BOMB    = $032A
ENGY    = $032B
DKCMP   = $032C
GHYP    = $032D
ESCP    = $032E
NOMSL   = $0333
FIST    = $0334
AVL     = $0335
L0345   = $0345
QQ26    = $0346
TALLY   = $0347
L0348   = $0348
L0349   = $0349
SX      = $034C
SXL     = $0357
SY      = $0362
L0885   = $0885
K%      = $0900
L0901   = $0901
L0902   = $0902
L0904   = $0904
L0905   = $0905
L0906   = $0906
L0907   = $0907
L0908   = $0908
L0924   = $0924
L092C   = $092C
L0944   = $0944
L094A   = $094A
L094B   = $094B
L0A00   = $0A00
L0A03   = $0A03
L0A0B   = $0A0B
L0A0F   = $0A0F
L0BDF   = $0BDF
FRIN    = $0BE0
L0BE1   = $0BE1
L0BE2   = $0BE2
L0BE3   = $0BE3
LAS2    = $0BED
L0BEF   = $0BEF
SSPR    = $0BF4
L0BF6   = $0BF6
L0BF7   = $0BF7
L0BF8   = $0BF8
L0BFB   = $0BFB
L0BFD   = $0BFD
ECMP    = $0BFF
MSAR    = $0C00
VIEW    = $0C01
LASCT   = $0C02
GNTMP   = $0C03
HFX     = $0C04
EV      = $0C05
DLY     = $0C06
de      = $0C07
LSO     = $0C08
LSX2    = $0C5E
L0C85   = $0C85
LSY2    = $0C86
SYL     = $0CAE
SZ      = $0CB9
SZL     = $0CC4
XSAV2   = $0CCF
YSAV2   = $0CD0
MCH     = $0CD1
FSH     = $0CD2
ASH     = $0CD3
ENERGY  = $0CD4
LASX    = $0CD5
LASY    = $0CD6
COMX    = $0CD7
COMY    = $0CD8
QQ24    = $0CD9
QQ25    = $0CDA
QQ28    = $0CDB
QQ29    = $0CDC
gov     = $0CDD
tek     = $0CDE
SLSP    = $0CDF
L0CE0   = $0CE0
ALTIT   = $0CE2
QQ2     = $0CE3
QQ3     = $0CE9
QQ4     = $0CEA
QQ5     = $0CEB
QQ6     = $0CEC
QQ7     = $0CEE
L0CEF   = $0CEF
QQ8     = $0CF0
L0CF1   = $0CF1
QQ9     = $0CF2
QQ10    = $0CF3
L6CA9   = $6CA9
L6FA9   = $6FA9
LFBD0   = $FBD0
LFDD0   = $FDD0
VIA     = $FE00
LFE05   = $FE05
OSWRSC  = $FFB3
OSRDSC  = $FFB9
OSEVEN  = $FFBF
GSINIT  = $FFC2
GSREAD  = $FFC5
NVRDCH  = $FFC8
NNWRCH  = $FFCB
OSFIND  = $FFCE
OSGBPB  = $FFD1
OSBPUT  = $FFD4
OSBGET  = $FFD7
OSARGS  = $FFDA
OSFILE  = $FFDD
OSRDCH  = $FFE0
OSASCI  = $FFE3
OSNEWL  = $FFE7
OSWRCH  = $FFEE
OSWORD  = $FFF1
OSBYTE  = $FFF4
OSCLI   = $FFF7
LFFFD   = $FFFD

        org     $0D00
        EQUB    $40

.L0D01
        EQUB    $00

.L0D02
        EQUB    $00,$00

.L0D04
        EQUB    $00,$00

.L0D06
        EQUB    $00,$00,$B6,$3F,$F8,$1C,$25,$0D
        EQUB    $B9,$3F,$08,$2C,$01,$0D,$30,$02
        EQUB    $28,$60,$28,$6C,$04,$0D

.COMC
        EQUB    $00

.L0D1D
        EQUB    $00

.DAMP
        EQUB    $00

.DJD
        EQUB    $00

.PATG
        EQUB    $00,$00,$00

.L0D23
        EQUB    $00

.JSTK
        EQUB    $00

        EQUB    $AD

.L0D26
        ASL     L000D
        EOR     #$FF
        STA     L0D06
        ORA     L0D01
        BMI     L0D3D

        LDA     LFE05
        ORA     #$20
        STA     LFE05
        LDA     L00FC
        RTI

.L0D3D
        JMP     (L0D02)

.M%
        LDA     K%
        STA     RAND
        LDA     #$00
        LDX     #$01
.L0D49
        DEC     L0BFD,X
        BPL     L0D54

        STA     L0BFD,X
        STA     L0BFB,X
.L0D54
        DEX
        BPL     L0D49

        LDX     JSTX
        JSR     cntr

        JSR     cntr

        TXA
        EOR     #$80
        TAY
        AND     #$80
        JMP     L0D70

        EQUB    $A1

        EQUB    $BB,$80,$00,$90,$01,$D6

.L0D6F
        SBC     (L0085),Y
L0D70 = L0D6F+1
        DEY
        STX     JSTX
        EOR     #$80
        STA     L0089
        TYA
        BPL     L0D80

        EOR     #$FF
        CLC
        ADC     #$01
.L0D80
        LSR     A
        LSR     A
        CMP     #$08
        BCS     L0D88

        LSR     A
        CLC
.L0D88
        STA     ALP1
        ORA     ALP2
        STA     ALPHA
        LDX     JSTY
        JSR     cntr

        TXA
        EOR     #$80
        TAY
        AND     #$80
        STX     JSTY
        STA     L008B
        EOR     #$80
        STA     BET2
        TYA
        BPL     L0DA6

        EOR     #$FF
.L0DA6
        ADC     #$04
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        CMP     #$03
        BCS     L0DB1

        LSR     A
.L0DB1
        STA     BET1
        ORA     BET2
        STA     BETA
        LDA     KY2
        BEQ     MA17

        LDA     DELTA
        CMP     #$28
        BCS     MA17

        INC     DELTA
.MA17
        LDA     KY1
        BEQ     MA4

        DEC     DELTA
        BNE     MA4

        INC     DELTA
.MA4
        LDA     KY15
        AND     NOMSL
        BEQ     MA20

        JSR     L3903

        LDA     #$28
        JSR     NOISE

        LDA     #$00
        STA     MSAR
.MA20
        LDA     MSTG
        BPL     MA25

        LDA     KY14
        BEQ     MA25

        LDX     NOMSL
        BEQ     MA25

        STA     MSAR
        LDY     #$0D
        JSR     MSBAR

.MA25
        LDA     KY16
        BEQ     MA24

        LDA     MSTG
        BMI     MA64

        JSR     FRMIS

.MA24
        LDA     KY12
        BEQ     MA76

        ASL     BOMB
.MA76
        LDA     KY13
        AND     ESCP
        BEQ     L0E12

        JMP     ESCAPE

.L0E12
        LDA     KY18
        BEQ     L0E19

        JSR     WARP

.L0E19
        LDA     KY17
        AND     ECM
        BEQ     MA64

        LDA     ECMA
        BNE     MA64

        DEC     ECMP
        JSR     ECBLB2

.MA64
        LDA     KY19
        AND     DKCMP
        AND     SSPR
        BEQ     MA68

        LDA     L0944
        BMI     MA68

        JMP     GOIN

.MA68
        LDA     #$00
        STA     LAS
        STA     DELT4
        LDA     DELTA
        LSR     A
        ROR     DELT4
        LSR     A
        ROR     DELT4
        STA     L008E
        LDA     LASCT
        BNE     MA3

        LDA     KY7
        BEQ     MA3

        LDA     GNTMP
        CMP     #$F2
        BCS     MA3

        LDX     VIEW
        LDA     LASER,X
        BEQ     MA3

        PHA
        AND     #$7F
        STA     LAS
        STA     LAS2
        LDA     #$00
        JSR     NOISE

        JSR     LASLI

        PLA
        BPL     ma1

        LDA     #$00
.ma1
        AND     #$FA
        STA     LASCT
.MA3
        LDX     #$00
.MAL1
        STX     XSAV
        LDA     FRIN,X
        BNE     L0E8A

        JMP     MA18

.L0E8A
        STA     TYPE
        JSR     GINF

        LDY     #$23
.MAL2
        LDA     (INF),Y
        STA     INWK,Y
        DEY
        BPL     MAL2

        LDA     TYPE
        BMI     MA21

        ASL     A
        TAY
        LDA     L4ED2,Y
        STA     XX0
        LDA     L4ED3,Y
        STA     L001F
        LDA     BOMB
        BPL     MA21

        CPY     #$0E
        BEQ     MA21

        LDA     L0072
        AND     #$20
        BNE     MA21

        LDA     L0072
        ORA     #$80
        STA     L0072
        JSR     EXNO2

.MA21
        JSR     MVEIT

        LDY     #$23
.MAL3
        LDA     INWK,Y
        STA     (INF),Y
        DEY
        BPL     MAL3

        LDA     L0072
        AND     #$A0
        JSR     MAS4

        BNE     MA65

        LDA     INWK
        ORA     L0056
        ORA     L0059
        BMI     MA65

        LDX     TYPE
        BMI     MA65

        CPX     #$07
        BEQ     ISDK

        AND     #$C0
        BNE     MA65

        CPX     #$08
        BEQ     MA65

        CPX     #$0A
        BCS     MA58

        JMP     L0F73

.MA58
        LDA     BST
        AND     L0058
        BPL     L0F73

        LDA     #$03
        CPX     #$0B
        BNE     oily

        BEQ     slvy2

.oily
        JSR     DORND

        AND     #$07
.slvy2
        STA     QQ29
        LDA     #$01
        JSR     tnpr

        LDY     #$4E
        BCS     MA59

        LDY     QQ29
        ADC     QQ20,Y
        STA     QQ20,Y
        TYA
        ADC     #$D0
        JSR     MESS

        JMP     MA60

.MA65
        JMP     MA26

.ISDK
        LDA     L0944
        BMI     MA62

        LDA     L0061
        CMP     #$D6
        BCC     MA62

        JSR     SPS4

        LDA     X2
        BMI     MA62

        CMP     #$59
        BCC     MA62

        LDA     L0063
        AND     #$7F
        CMP     #$50
        BCC     MA62

.GOIN
        LDA     #$00
        STA     L002F
        LDA     #$08
        JSR     LAUN

        JSR     RES4

        JMP     BAY

.MA62
        LDA     DELTA
        CMP     #$05
        BCC     MA67

        JMP     DEATH

.MA59
        JSR     EXNO3

.MA60
        ASL     L0072
        SEC
        ROR     L0072
        BNE     MA26

.MA67
        LDA     #$01
        STA     DELTA
        LDA     #$05
        BNE     MA63

.L0F73
        ASL     L0072
        SEC
        ROR     L0072
        LDA     L0076
        SEC
        ROR     A
.MA63
        JSR     OOPS

        JSR     EXNO3

.MA26
        LDA     QQ11
        BNE     MA15

        JSR     PLUT

        JSR     HITCH

        BCC     MA8

        LDA     MSAR
        BEQ     MA47

        JSR     BEEP

        LDX     XSAV
        LDY     #$11
        JSR     ABORT2

.MA47
        LDA     LAS
        BEQ     MA8

        LDX     #$0F
        JSR     EXNO

        LDA     L0076
        SEC
        SBC     LAS
        BCS     MA14

        LDA     TYPE
        CMP     #$07
        BEQ     L0FD8

        LDA     L0072
        ORA     #$80
        STA     L0072
        BCS     MA8

        JSR     DORND

        BPL     oh

        LDY     #$00
        AND     (XX0),Y
        STA     CNT
.um
        BEQ     oh

        LDX     #$0A
        LDA     #$00
        JSR     SFS1

        DEC     CNT
        BPL     um

.oh
        JSR     EXNO2

.MA14
        STA     L0076
.L0FD8
        LDA     TYPE
        JSR     ANGRY

.MA8
        JSR     LL9

.MA15
        LDY     #$23
        LDA     L0076
        STA     (INF),Y
        LDA     L0072
        BPL     MAC1

        AND     #$20
        BEQ     MAC1

        LDA     TYPE
        CMP     #$02
        BNE     q2

        LDA     FIST
        ORA     #$40
        STA     FIST
.q2
        LDA     DLY
        BNE     KS1S

        LDY     #$0A
        LDA     (XX0),Y
        BEQ     KS1S

        TAX
        INY
        LDA     (XX0),Y
        TAY
        JSR     MCASH

        LDA     #$00
        JSR     MESS

.KS1S
        JMP     KS1

.MAC1
        LDA     TYPE
        BMI     MA27

        JSR     FAROF

        BCC     KS1S

.MA27
        LDY     #$1F
        LDA     L0072
        STA     (INF),Y
        LDX     XSAV
        INX
        JMP     MAL1

.MA18
        LDA     BOMB
        BPL     MA77

        ASL     BOMB
.MA77
        LDA     MCNT
        AND     #$07
        BNE     MA22

        LDX     ENERGY
        BPL     b

        LDX     ASH
        JSR     SHD

        STX     ASH
        LDX     FSH
        JSR     SHD

        STX     FSH
.b
        SEC
        LDA     ENGY
        ADC     ENERGY
        BCS     L105D

        STA     ENERGY
.L105D
        LDA     MCNT
        AND     #$1F
        BNE     MA93

        LDA     SSPR
        BNE     MA23S

        TAY
        JSR     MAS2

        BNE     MA23S

        LDX     #$1C
.MAL4
        LDA     K%,X
        STA     INWK,X
        DEX
        BPL     MAL4

        INX
        LDY     #$09
        JSR     MAS1

        BNE     MA23S

        LDX     #$03
        LDY     #$0B
        JSR     MAS1

        BNE     MA23S

        LDX     #$06
        LDY     #$0D
        JSR     MAS1

        BNE     MA23S

        LDA     #$C0
        JSR     FAROF2

        BCC     MA23S

        JSR     NWSPS

.MA23S
        JMP     MA23

.MA22
        LDA     MCNT
        AND     #$1F
.MA93
        CMP     #$0A
        BNE     MA23

        LDA     #$32
        CMP     ENERGY
        BCC     L10B2

        ASL     A
        JSR     MESS

.L10B2
        LDY     #$FF
        STY     ALTIT
        INY
        JSR     m

        BNE     MA23

        JSR     MAS3

        BCS     MA23

        SBC     #$24
        BCC     MA28

        STA     R
        JSR     LL5

        LDA     Q
        STA     ALTIT
        BNE     MA23

.MA28
        JMP     DEATH

.MA23
        LDA     LAS2
        BEQ     MA16

        LDA     LASCT
        CMP     #$08
        BCS     MA16

        JSR     LASLI2

        LDA     #$00
        STA     LAS2
.MA16
        LDA     ECMP
        BEQ     MA69

        JSR     DENGY

        BEQ     MA70

.MA69
        LDA     ECMA
        BEQ     MA66

        DEC     ECMA
        DEC     ECMA
        BNE     MA66

.MA70
        JSR     ECMOF

.MA66
        LDA     QQ11
        BNE     MA9

        JMP     STARS

.MAS1
        LDA     INWK,Y
        ASL     A
        STA     L003E
        LDA     L0054,Y
        ROL     A
        STA     L003F
        LDA     #$00
        ROR     A
        STA     L0040
        JSR     MVT3

        STA     L0055,X
        LDY     L003E
        STY     INWK,X
        LDY     L003F
        STY     L0054,X
        AND     #$7F
.MA9
        RTS

.m
        LDA     #$00
.MAS2
        ORA     L0902,Y
        ORA     L0905,Y
        ORA     L0908,Y
        AND     #$7F
        RTS

.MAS3
        LDA     L0901,Y
        JSR     SQUA2

        STA     R
        LDA     L0904,Y
        JSR     SQUA2

        ADC     R
        BCS     MA30

        STA     R
        LDA     L0907,Y
        JSR     SQUA2

        ADC     R
        BCC     L1156

.MA30
        LDA     #$FF
.L1156
        RTS

.MVEIT
        LDA     L0072
        AND     #$A0
        BNE     MV30

        LDA     MCNT
        EOR     XSAV
        AND     #$0F
        BNE     MV3

        JSR     TIDY

.MV3
        LDX     TYPE
        BPL     L116F

        JMP     MV40

.L116F
        LDA     L0073
        BPL     MV30

        CPX     #$08
        BEQ     MV26

        LDA     MCNT
        EOR     XSAV
        AND     #$07
        BNE     MV30

.MV26
        JSR     TACTICS

.MV30
        JSR     SCAN

        LDA     L006E
        ASL     A
        ASL     A
        STA     Q
        LDA     L005D
        AND     #$7F
        JSR     FMLTU

        STA     R
        LDA     L005D
        LDX     #$00
        JSR     L12F8

        LDA     L005F
        AND     #$7F
        JSR     FMLTU

        STA     R
        LDA     L005F
        LDX     #$03
        JSR     L12F8

        LDA     L0061
        AND     #$7F
        JSR     FMLTU

        STA     R
        LDA     L0061
        LDX     #$06
        JSR     L12F8

        LDA     L006E
        CLC
        ADC     L006F
        BPL     L11C4

        LDA     #$00
.L11C4
        LDY     #$0F
        CMP     (XX0),Y
        BCC     L11CC

        LDA     (XX0),Y
.L11CC
        STA     L006E
        LDA     #$00
        STA     L006F
        LDX     ALP1
        LDA     INWK
        EOR     #$FF
        STA     P
        LDA     L0054
        JSR     L245A

        STA     L001D
        LDA     L0089
        EOR     L0055
        LDX     #$03
        JSR     MVT6

        STA     L00BF
        LDA     L001C
        STA     L00BD
        EOR     #$FF
        STA     P
        LDA     L001D
        STA     L00BE
        LDX     BET1
        JSR     L245A

        STA     L001D
        LDA     L00BF
        EOR     BET2
        LDX     #$06
        JSR     MVT6

        STA     L005B
        LDA     L001C
        STA     L0059
        EOR     #$FF
        STA     P
        LDA     L001D
        STA     L005A
        JSR     MLTU2

        STA     L001D
        LDA     L00BF
        STA     L0058
        EOR     BET2
        EOR     L005B
        BPL     MV43

        LDA     L001C
        ADC     L00BD
        STA     L0056
        LDA     L001D
        ADC     L00BE
        STA     L0057
        JMP     MV44

.MV43
        LDA     L00BD
        SBC     L001C
        STA     L0056
        LDA     L00BE
        SBC     L001D
        STA     L0057
        BCS     MV44

        LDA     #$01
        SBC     L0056
        STA     L0056
        LDA     #$00
        SBC     L0057
        STA     L0057
        LDA     L0058
        EOR     #$80
        STA     L0058
.MV44
        LDX     ALP1
        LDA     L0056
        EOR     #$FF
        STA     P
        LDA     L0057
        JSR     L245A

        STA     L001D
        LDA     ALP2
        EOR     L0058
        LDX     #$00
        JSR     MVT6

        STA     L0055
        LDA     L001D
        STA     L0054
        LDA     L001C
        STA     INWK
.MV45
        LDA     DELTA
        STA     R
        LDA     #$80
        LDX     #$06
        JSR     MVT1

        LDY     #$09
        JSR     MVS4

        LDY     #$0F
        JSR     MVS4

        LDY     #$15
        JSR     MVS4

        LDA     L0071
        AND     #$80
        STA     RAT2
        LDA     L0071
        AND     #$7F
        BEQ     MV8

        CMP     #$7F
        SBC     #$00
        ORA     RAT2
        STA     L0071
        LDX     #$0F
        LDY     #$09
        JSR     MVS5

        LDX     #$11
        LDY     #$0B
        JSR     MVS5

        LDX     #$13
        LDY     #$0D
        JSR     MVS5

.MV8
        LDA     L0070
        AND     #$80
        STA     RAT2
        LDA     L0070
        AND     #$7F
        BEQ     MV5

        CMP     #$7F
        SBC     #$00
        ORA     RAT2
        STA     L0070
        LDX     #$0F
        LDY     #$15
        JSR     MVS5

        LDX     #$11
        LDY     #$17
        JSR     MVS5

        LDX     #$13
        LDY     #$19
        JSR     MVS5

.MV5
        LDA     L0072
        AND     #$A0
        BNE     MVD1

        LDA     L0072
        ORA     #$10
        STA     L0072
        JMP     SCAN

.MVD1
        LDA     L0072
        AND     #$EF
        STA     L0072
        RTS

.L12F8
        AND     #$80
.MVT1
        ASL     A
        STA     S
        LDA     #$00
        ROR     A
        STA     T
        LSR     S
        EOR     L0055,X
        BMI     MV10

        LDA     R
        ADC     INWK,X
        STA     INWK,X
        LDA     S
        ADC     L0054,X
        STA     L0054,X
        LDA     L0055,X
        ADC     #$00
        ORA     T
        STA     L0055,X
        RTS

.MV10
        LDA     INWK,X
        SEC
        SBC     R
        STA     INWK,X
        LDA     L0054,X
        SBC     S
        STA     L0054,X
        LDA     L0055,X
        AND     #$7F
        SBC     #$00
        ORA     #$80
        EOR     T
        STA     L0055,X
        BCS     MV11

        LDA     #$01
        SBC     INWK,X
        STA     INWK,X
        LDA     #$00
        SBC     L0054,X
        STA     L0054,X
        LDA     #$00
        SBC     L0055,X
        AND     #$7F
        ORA     T
        STA     L0055,X
.MV11
        RTS

.MVT3
        LDA     L0040
        STA     S
        AND     #$80
        STA     T
        EOR     L0055,X
        BMI     MV13

        LDA     L003E
        CLC
        ADC     INWK,X
        STA     L003E
        LDA     L003F
        ADC     L0054,X
        STA     L003F
        LDA     L0040
        ADC     L0055,X
        AND     #$7F
        ORA     T
        STA     L0040
        RTS

.MV13
        LDA     S
        AND     #$7F
        STA     S
        LDA     INWK,X
        SEC
        SBC     L003E
        STA     L003E
        LDA     L0054,X
        SBC     L003F
        STA     L003F
        LDA     L0055,X
        AND     #$7F
        SBC     S
        ORA     #$80
        EOR     T
        STA     L0040
        BCS     MV14

        LDA     #$01
        SBC     L003E
        STA     L003E
        LDA     #$00
        SBC     L003F
        STA     L003F
        LDA     #$00
        SBC     L0040
        AND     #$7F
        ORA     T
        STA     L0040
.MV14
        RTS

.MVS4
        LDA     ALPHA
        STA     Q
        LDX     L0055,Y
        STX     R
        LDX     L0056,Y
        STX     S
        LDX     INWK,Y
        STX     P
        LDA     L0054,Y
        EOR     #$80
        JSR     MAD

        STA     L0056,Y
        STX     L0055,Y
        STX     P
        LDX     INWK,Y
        STX     R
        LDX     L0054,Y
        STX     S
        LDA     L0056,Y
        JSR     MAD

        STA     L0054,Y
        STX     INWK,Y
        STX     P
        LDA     BETA
        STA     Q
        LDX     L0055,Y
        STX     R
        LDX     L0056,Y
        STX     S
        LDX     L0057,Y
        STX     P
        LDA     L0058,Y
        EOR     #$80
        JSR     MAD

        STA     L0056,Y
        STX     L0055,Y
        STX     P
        LDX     L0057,Y
        STX     R
        LDX     L0058,Y
        STX     S
        LDA     L0056,Y
        JSR     MAD

        STA     L0058,Y
        STX     L0057,Y
        RTS

.MVS5
        LDA     L0054,X
        AND     #$7F
        LSR     A
        STA     T
        LDA     INWK,X
        SEC
        SBC     T
        STA     R
        LDA     L0054,X
        SBC     #$00
        STA     S
        LDA     INWK,Y
        STA     P
        LDA     L0054,Y
        AND     #$80
        STA     T
        LDA     L0054,Y
        AND     #$7F
        LSR     A
        ROR     P
        LSR     A
        ROR     P
        LSR     A
        ROR     P
        LSR     A
        ROR     P
        ORA     T
        EOR     RAT2
        STX     Q
        JSR     ADD

        STA     L003E
        STX     K
        LDX     Q
        LDA     L0054,Y
        AND     #$7F
        LSR     A
        STA     T
        LDA     INWK,Y
        SEC
        SBC     T
        STA     R
        LDA     L0054,Y
        SBC     #$00
        STA     S
        LDA     INWK,X
        STA     P
        LDA     L0054,X
        AND     #$80
        STA     T
        LDA     L0054,X
        AND     #$7F
        LSR     A
        ROR     P
        LSR     A
        ROR     P
        LSR     A
        ROR     P
        LSR     A
        ROR     P
        ORA     T
        EOR     #$80
        EOR     RAT2
        STX     Q
        JSR     ADD

        STA     L0054,Y
        STX     INWK,Y
        LDX     Q
        LDA     K
        STA     INWK,X
        LDA     L003E
        STA     L0054,X
        RTS

.MVT6
        TAY
        EOR     L0055,X
        BMI     MV50

        LDA     L001C
        CLC
        ADC     INWK,X
        STA     L001C
        LDA     L001D
        ADC     L0054,X
        STA     L001D
        TYA
        RTS

.MV50
        LDA     INWK,X
        SEC
        SBC     L001C
        STA     L001C
        LDA     L0054,X
        SBC     L001D
        STA     L001D
        BCC     MV51

        TYA
        EOR     #$80
        RTS

.MV51
        LDA     #$01
        SBC     L001C
        STA     L001C
        LDA     #$00
        SBC     L001D
        STA     L001D
        TYA
.L14D2
        RTS

.MV40
        TXA
        LSR     A
        BCS     L14D2

        LDA     ALPHA
        EOR     #$80
        STA     Q
        LDA     INWK
        STA     P
        LDA     L0054
        STA     L001C
        LDA     L0055
        JSR     MULT3

        LDX     #$03
        JSR     MVT3

        LDA     L003E
        STA     L00BD
        STA     P
        LDA     L003F
        STA     L00BE
        STA     L001C
        LDA     BETA
        STA     Q
        LDA     L0040
        STA     L00BF
        JSR     MULT3

        LDX     #$06
        JSR     MVT3

        LDA     L003E
        STA     P
        STA     L0059
        LDA     L003F
        STA     L001C
        STA     L005A
        LDA     L0040
        STA     L005B
        EOR     #$80
        JSR     MULT3

        LDA     L0040
        AND     #$80
        STA     T
        EOR     L00BF
        BMI     MV1

        LDA     K
        ADC     K2
        LDA     L003E
        ADC     L00BD
        STA     L0056
        LDA     L003F
        ADC     L00BE
        STA     L0057
        LDA     L0040
        ADC     L00BF
        JMP     MV2

.MV1
        LDA     K
        SEC
        SBC     K2
        LDA     L003E
        SBC     L00BD
        STA     L0056
        LDA     L003F
        SBC     L00BE
        STA     L0057
        LDA     L00BF
        AND     #$7F
        STA     P
        LDA     L0040
        AND     #$7F
        SBC     P
        STA     P
        BCS     MV2

        LDA     #$01
        SBC     L0056
        STA     L0056
        LDA     #$00
        SBC     L0057
        STA     L0057
        LDA     #$00
        SBC     P
        ORA     #$80
.MV2
        EOR     T
        STA     L0058
        LDA     ALPHA
        STA     Q
        LDA     L0056
        STA     P
        LDA     L0057
        STA     L001C
        LDA     L0058
        JSR     MULT3

        LDX     #$00
        JSR     MVT3

        LDA     L003E
        STA     INWK
        LDA     L003F
        STA     L0054
        LDA     L0040
        STA     L0055
        JMP     MV45

.L159D
        EQUB    $4A

        EQUB    $41,$4D,$45,$53,$4F,$4E

.L15A4
        EQUB    $0D

.L15A5
        EQUB    $00,$14,$AD,$4A,$5A,$48,$02,$53
        EQUB    $B7,$00,$00,$03,$E8,$46,$00,$00
        EQUB    $0F,$00,$00,$00,$00,$00,$16,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$03,$00,$10,$0F,$11
        EQUB    $00,$03,$1C,$0E,$00,$00,$0A,$00
        EQUB    $11,$3A,$07,$09,$08,$00,$00,$00
        EQUB    $00,$80

.CHK2
        EQUB    $AA

.CHK
        EQUB    $03

.UNIV
        EQUB    $00

.L15F2
        EQUB    $09,$24,$09,$48,$09,$6C,$09,$90
        EQUB    $09,$B4,$09,$D8,$09,$FC,$09,$20
        EQUB    $0A,$44,$0A,$68,$0A,$8C,$0A,$B0
        EQUB    $0A

.TWOS
        EQUB    $80,$40,$20,$10,$08,$04,$02,$01
        EQUB    $80,$40

.CTWOS
        EQUB    $C0,$30,$0C,$03

.TWOS2
        EQUB    $C0,$C0,$60,$30,$18,$0C,$06,$03

.LL30
        STY     YSAV
        LDA     #$80
        STA     S
        STA     SC
        ASL     A
        STA     SWAP
        LDA     X2
        SBC     XX15
        BCS     LI1

        EOR     #$FF
        ADC     #$01
.LI1
        STA     P
        SEC
        LDA     Y2
        SBC     Y1
        BCS     LI2

        EOR     #$FF
        ADC     #$01
.LI2
        STA     Q
        CMP     P
        BCC     STPX

        JMP     STPY

.STPX
        LDX     XX15
        CPX     X2
        BCC     LI3

        DEC     SWAP
        LDA     X2
        STA     XX15
        STX     X2
        TAX
        LDA     Y2
        LDY     Y1
        STA     Y1
        STY     Y2
.LI3
        LDA     Y1
        LSR     A
        LSR     A
        LSR     A
        STA     SCH
        LSR     A
        ROR     SC
        LSR     A
        ROR     SC
        ADC     SCH
        ADC     #$58
        STA     SCH
        TXA
        AND     #$F8
        ADC     SC
        STA     SC
        BCC     L1681

        INC     SCH
.L1681
        LDA     Y1
        AND     #$07
        TAY
        TXA
        AND     #$07
        TAX
        LDA     TWOS,X
        STA     R
        LDA     Q
        LDX     #$FE
        STX     Q
.LIL1
        ASL     A
        BCS     LI4

        CMP     P
        BCC     LI5

.LI4
        SBC     P
        SEC
.LI5
        ROL     Q
        BCS     LIL1

        LDX     P
        INX
        LDA     Y2
        SBC     Y1
        BCS     DOWN

        LDA     SWAP
        BNE     LI6

        DEX
.LIL2
        LDA     R
        EOR     (SC),Y
        STA     (SC),Y
.LI6
        LSR     R
        BCC     LI7

        ROR     R
        LDA     SC
        ADC     #$08
        STA     SC
        BCC     LI7

        INC     SCH
.LI7
        LDA     S
        ADC     Q
        STA     S
        BCC     LIC2

        DEY
        BPL     LIC2

        LDA     SC
        SBC     #$40
        STA     SC
        LDA     SCH
        SBC     #$01
        STA     SCH
        LDY     #$07
.LIC2
        DEX
        BNE     LIL2

        LDY     YSAV
        RTS

.DOWN
        LDA     SWAP
        BEQ     LI9

        DEX
.LIL3
        LDA     R
        EOR     (SC),Y
        STA     (SC),Y
.LI9
        LSR     R
        BCC     LI10

        ROR     R
        LDA     SC
        ADC     #$08
        STA     SC
        BCC     LI10

        INC     SCH
.LI10
        LDA     S
        ADC     Q
        STA     S
        BCC     LIC3

        INY
        CPY     #$08
        BNE     LIC3

        LDA     SC
        ADC     #$3F
        STA     SC
        LDA     SCH
        ADC     #$01
        STA     SCH
        LDY     #$00
.LIC3
        DEX
        BNE     LIL3

        LDY     YSAV
        RTS

.STPY
        LDY     Y1
        TYA
        LDX     XX15
        CPY     Y2
        BCS     LI15

        DEC     SWAP
        LDA     X2
        STA     XX15
        STX     X2
        TAX
        LDA     Y2
        STA     Y1
        STY     Y2
        TAY
.LI15
        LSR     A
        LSR     A
        LSR     A
        STA     SCH
        LSR     A
        ROR     SC
        LSR     A
        ROR     SC
        ADC     SCH
        ADC     #$58
        STA     SCH
        TXA
        AND     #$F8
        ADC     SC
        STA     SC
        BCC     L1757

        INC     SCH
.L1757
        LDA     Y1
        AND     #$07
        TAY
        TXA
        AND     #$07
        TAX
        LDA     TWOS,X
        STA     R
        LDA     P
        LDX     #$01
        STX     P
.LIL4
        ASL     A
        BCS     LI13

        CMP     Q
        BCC     LI14

.LI13
        SBC     Q
        SEC
.LI14
        ROL     P
        BCC     LIL4

        LDX     Q
        INX
        LDA     X2
        SBC     XX15
        BCC     LFT

        CLC
        LDA     SWAP
        BEQ     LI17

        DEX
.LIL5
        LDA     R
        EOR     (SC),Y
        STA     (SC),Y
.LI17
        DEY
        BPL     LI16

        LDA     SC
        SBC     #$3F
        STA     SC
        LDA     SCH
        SBC     #$01
        STA     SCH
        LDY     #$07
.LI16
        LDA     S
        ADC     P
        STA     S
        BCC     LIC5

        LSR     R
        BCC     LIC5

        ROR     R
        LDA     SC
        ADC     #$08
        STA     SC
        BCC     LIC5

        INC     SCH
        CLC
.LIC5
        DEX
        BNE     LIL5

        LDY     YSAV
        RTS

.LFT
        LDA     SWAP
        BEQ     LI18

        DEX
.LIL6
        LDA     R
        EOR     (SC),Y
        STA     (SC),Y
.LI18
        DEY
        BPL     LI19

        LDA     SC
        SBC     #$3F
        STA     SC
        LDA     SCH
        SBC     #$01
        STA     SCH
        LDY     #$07
.LI19
        LDA     S
        ADC     P
        STA     S
        BCC     LIC6

        ASL     R
        BCC     LIC6

        ROL     R
        LDA     SC
        SBC     #$07
        STA     SC
        BCS     L17F2

        DEC     SCH
.L17F2
        CLC
.LIC6
        DEX
        BNE     LIL6

        LDY     YSAV
        RTS

        LDA     #$0F
        TAX
        JMP     OSBYTE

.NLIN3
        JSR     TT27

.NLIN4
        LDA     #$13
        BNE     NLIN2

.NLIN
        LDA     #$17
        INC     YC
.NLIN2
        STA     Y1
        LDX     #$02
        STX     XX15
        LDX     #$FE
        STX     X2
.HLOIN
        LDX     Y1
        STX     Y2
        JMP     LL30

.PIX1
        JSR     ADD

        STA     L0027
        TXA
        STA     SYL,Y
.PIXEL2
        LDA     XX15
        BPL     PX1

        EOR     #$7F
        CLC
        ADC     #$01
.PX1
        EOR     #$80
        TAX
        LDA     Y1
        AND     #$7F
        CMP     #$60
        BCS     PX4

        LDA     Y1
        BPL     PX2

        EOR     #$7F
        ADC     #$01
.PX2
        STA     T
        LDA     #$61
        SBC     T
.PIXEL
        STY     T1
        LDY     #$80
        STY     SC
        TAY
        LSR     A
        LSR     A
        LSR     A
        STA     SCH
        LSR     A
        ROR     SC
        LSR     A
        ROR     SC
        ADC     SCH
        ADC     #$58
        STA     SCH
        TXA
        AND     #$F8
        ADC     SC
        STA     SC
        BCC     L1869

        INC     SCH
.L1869
        TYA
        AND     #$07
        TAY
        TXA
        AND     #$07
        TAX
        LDA     ZZ
        CMP     #$90
        BCS     PX3

        LDA     TWOS2,X
        EOR     (SC),Y
        STA     (SC),Y
        LDA     ZZ
        CMP     #$50
        BCS     PX13

        DEY
        BPL     PX3

        LDY     #$01
.PX3
        LDA     TWOS2,X
        EOR     (SC),Y
        STA     (SC),Y
.PX13
        LDY     T1
.PX4
        RTS

.BLINE
        TXA
        ADC     K4
        STA     L0084
        LDA     L00E1
        ADC     T
        STA     L0085
        LDA     FLAG
        BEQ     BL1

        INC     FLAG
.BL5
        LDY     LSP
        LDA     #$FF
        CMP     L0C85,Y
        BEQ     BL7

        STA     LSY2,Y
        INC     LSP
        BNE     BL7

.BL1
        LDA     QQ17
        STA     XX15
        LDA     QQ19
        STA     Y1
        LDA     L0080
        STA     X2
        LDA     L0081
        STA     Y2
        LDA     K6
        STA     L0035
        LDA     L0083
        STA     L0036
        LDA     L0084
        STA     XX12
        LDA     L0085
        STA     L0038
        JSR     LL145

        BCS     BL5

        LDA     SWAP
        BEQ     BL9

        LDA     XX15
        LDY     X2
        STA     X2
        STY     XX15
        LDA     Y1
        LDY     Y2
        STA     Y2
        STY     Y1
.BL9
        LDY     LSP
        LDA     L0C85,Y
        CMP     #$FF
        BNE     BL8

        LDA     XX15
        STA     LSX2,Y
        LDA     Y1
        STA     LSY2,Y
        INY
.BL8
        LDA     X2
        STA     LSX2,Y
        LDA     Y2
        STA     LSY2,Y
        INY
        STY     LSP
        JSR     LL30

        LDA     XX13
        BNE     BL5

.BL7
        LDA     K6
        STA     QQ17
        LDA     L0083
        STA     QQ19
        LDA     L0084
        STA     L0080
        LDA     L0085
        STA     L0081
        LDA     CNT
        CLC
        ADC     STP
        STA     CNT
        RTS

.FLIP
        LDY     #$0A
.FLL1
        LDX     SY,Y
        LDA     SX,Y
        STA     Y1
        STA     SY,Y
        TXA
        STA     XX15
        STA     SX,Y
        LDA     SZ,Y
        STA     ZZ
        JSR     PIXEL2

        DEY
        BNE     FLL1

        RTS

.STARS
        LDX     VIEW
        BEQ     STARS1

        DEX
        BNE     ST11

        JMP     STARS6

.ST11
        JMP     STARS2

.STARS1
        LDY     #$0A
.STL1
        JSR     DV42

        LDA     R
        LSR     P
        ROR     A
        LSR     P
        ROR     A
        ORA     #$01
        STA     Q
        LDA     SZL,Y
        SBC     DELT4
        STA     SZL,Y
        LDA     SZ,Y
        STA     ZZ
        SBC     L008E
        STA     SZ,Y
        JSR     MLU1

        STA     L0027
        LDA     P
        ADC     SYL,Y
        STA     YY
        STA     R
        LDA     Y1
        ADC     L0027
        STA     L0027
        STA     S
        LDA     SX,Y
        STA     XX15
        JSR     MLU2

        STA     L0025
        LDA     P
        ADC     SXL,Y
        STA     XX
        LDA     XX15
        ADC     L0025
        STA     L0025
        EOR     L0089
        JSR     MLS1

        JSR     ADD

        STA     L0027
        STX     YY
        EOR     ALP2
        JSR     MLS2

        JSR     ADD

        STA     L0025
        STX     XX
        LDX     BET1
        LDA     L0027
        EOR     L008B
        JSR     L23AB

        STA     Q
        JSR     MUT2

        ASL     P
        ROL     A
        STA     T
        LDA     #$00
        ROR     A
        ORA     T
        JSR     ADD

        STA     L0025
        TXA
        STA     SXL,Y
        LDA     YY
        STA     R
        LDA     L0027
        STA     S
        LDA     #$00
        STA     P
        LDA     BETA
        EOR     #$80
        JSR     PIX1

        LDA     L0025
        STA     XX15
        STA     SX,Y
        AND     #$7F
        CMP     #$78
        BCS     KILL1

        LDA     L0027
        STA     SY,Y
        STA     Y1
        AND     #$7F
        CMP     #$78
        BCS     KILL1

        LDA     SZ,Y
        CMP     #$10
        BCC     KILL1

        STA     ZZ
.STC1
        JSR     PIXEL2

        DEY
        BEQ     L1A22

        JMP     STL1

.L1A22
        RTS

.KILL1
        JSR     DORND

        ORA     #$04
        STA     Y1
        STA     SY,Y
        JSR     DORND

        ORA     #$08
        STA     XX15
        STA     SX,Y
        JSR     DORND

        ORA     #$90
        STA     SZ,Y
        STA     ZZ
        LDA     Y1
        JMP     STC1

.STARS6
        LDY     #$0A
.STL6
        JSR     DV42

        LDA     R
        LSR     P
        ROR     A
        LSR     P
        ROR     A
        ORA     #$01
        STA     Q
        LDA     SX,Y
        STA     XX15
        JSR     MLU2

        STA     L0025
        LDA     SXL,Y
        SBC     P
        STA     XX
        LDA     XX15
        SBC     L0025
        STA     L0025
        JSR     MLU1

        STA     L0027
        LDA     SYL,Y
        SBC     P
        STA     YY
        STA     R
        LDA     Y1
        SBC     L0027
        STA     L0027
        STA     S
        LDA     SZL,Y
        ADC     DELT4
        STA     SZL,Y
        LDA     SZ,Y
        STA     ZZ
        ADC     L008E
        STA     SZ,Y
        LDA     L0025
        EOR     ALP2
        JSR     MLS1

        JSR     ADD

        STA     L0027
        STX     YY
        EOR     L0089
        JSR     MLS2

        JSR     ADD

        STA     L0025
        STX     XX
        LDA     L0027
        EOR     L008B
        LDX     BET1
        JSR     L23AB

        STA     Q
        LDA     L0025
        STA     S
        EOR     #$80
        JSR     MUT1

        ASL     P
        ROL     A
        STA     T
        LDA     #$00
        ROR     A
        ORA     T
        JSR     ADD

        STA     L0025
        TXA
        STA     SXL,Y
        LDA     YY
        STA     R
        LDA     L0027
        STA     S
        LDA     #$00
        STA     P
        LDA     BETA
        JSR     PIX1

        LDA     L0025
        STA     XX15
        STA     SX,Y
        LDA     L0027
        STA     SY,Y
        STA     Y1
        AND     #$7F
        CMP     #$6E
        BCS     KILL6

        LDA     SZ,Y
        CMP     #$A0
        BCS     KILL6

        STA     ZZ
.STC6
        JSR     PIXEL2

        DEY
        BEQ     ST3

        JMP     STL6

.ST3
        RTS

.KILL6
        JSR     DORND

        AND     #$7F
        ADC     #$0A
        STA     SZ,Y
        STA     ZZ
        LSR     A
        BCS     ST4

        LSR     A
        LDA     #$FC
        ROR     A
        STA     XX15
        STA     SX,Y
        JSR     DORND

        STA     Y1
        STA     SY,Y
        JMP     STC6

.ST4
        JSR     DORND

        STA     XX15
        STA     SX,Y
        LSR     A
        LDA     #$E6
        ROR     A
        STA     Y1
        STA     SY,Y
        BNE     STC6

.L1B45
        EQUB    $01

.L1B46
        EQUB    $00,$2C,$01,$A0,$0F,$70,$17,$A0
        EQUB    $0F,$10,$27,$82,$14,$10,$27,$28
        EQUB    $23,$98,$3A,$10,$27,$50,$C3

.L1B5D
        LDX     #$09
        CMP     #$19
        BCS     st3_lc

        DEX
        CMP     #$0A
        BCS     st3_lc

        DEX
        CMP     #$02
        BCS     st3_lc

        DEX
        BNE     st3_lc

.STATUS
        LDA     #$08
        JSR     TT66

        JSR     TT111

        LDA     #$07
        STA     XC
        LDA     #$7E
        JSR     NLIN3

        LDA     #$0F
        LDY     QQ12
        BNE     st6

        LDA     #$E6
        LDY     L0BF6
        LDX     L0BE2,Y
        BEQ     st6

        LDY     ENERGY
        CPY     #$80
        ADC     #$01
.st6
        JSR     plf

        LDA     #$7D
        JSR     spc

        LDA     #$13
        LDY     FIST
        BEQ     st5

        CPY     #$32
        ADC     #$01
.st5
        JSR     plf

        LDA     #$10
        JSR     spc

        LDA     L0348
        BNE     L1B5D

        TAX
        LDA     TALLY
        LSR     A
        LSR     A
.st5L
        INX
        LSR     A
        BNE     st5L

.st3_lc
        TXA
        CLC
        ADC     #$15
        JSR     plf

        LDA     #$12
        JSR     plf2

        LDA     ESCP
        BEQ     L1BD8

        LDA     #$70
        JSR     plf2

.L1BD8
        LDA     BST
        BEQ     L1BE2

        LDA     #$6F
        JSR     plf2

.L1BE2
        LDA     ECM
        BEQ     L1BEC

        LDA     #$6C
        JSR     plf2

.L1BEC
        LDA     #$71
        STA     XX4
.stqv
        TAY
        LDX     L02B9,Y
        BEQ     L1BF9

        JSR     plf2

.L1BF9
        INC     XX4
        LDA     XX4
        CMP     #$75
        BCC     stqv

        LDX     #$00
.st
        STX     CNT
        LDY     LASER,X
        BEQ     st1

        TXA
        CLC
        ADC     #$60
        JSR     spc

        LDA     #$67
        LDX     CNT
        LDY     LASER,X
        BPL     L1C1C

        LDA     #$68
.L1C1C
        JSR     plf2

.st1
        LDX     CNT
        INX
        CPX     #$04
        BCC     st

        RTS

.plf2
        JSR     plf

        LDX     #$06
        STX     XC
        RTS

.L1C2F
        EQUB    $48

        EQUB    $76,$E8,$00

.pr2
        LDA     #$03
.L1C35
        LDY     #$00
.TT11
        STA     U
        LDA     #$00
        STA     K
        STA     L003E
        STY     L003F
        STX     L0040
.BPRNT
        LDX     #$0B
        STX     T
        PHP
        BCC     TT30

        DEC     T
        DEC     U
.TT30
        LDA     #$0B
        SEC
        STA     XX17
        SBC     U
        STA     U
        INC     U
        LDY     #$00
        STY     S
        JMP     TT36

.TT35
        ASL     L0040
        ROL     L003F
        ROL     L003E
        ROL     K
        ROL     S
        LDX     #$03
.tt35_lc
        LDA     K,X
        STA     XX15,X
        DEX
        BPL     tt35_lc

        LDA     S
        STA     L0035
        ASL     L0040
        ROL     L003F
        ROL     L003E
        ROL     K
        ROL     S
        ASL     L0040
        ROL     L003F
        ROL     L003E
        ROL     K
        ROL     S
        CLC
        LDX     #$03
.tt36_lc
        LDA     K,X
        ADC     XX15,X
        STA     K,X
        DEX
        BPL     tt36_lc

        LDA     L0035
        ADC     S
        STA     S
        LDY     #$00
.TT36
        LDX     #$03
        SEC
.tt37_lc
        LDA     K,X
        SBC     L1C2F,X
        STA     XX15,X
        DEX
        BPL     tt37_lc

        LDA     S
        SBC     #$17
        STA     L0035
        BCC     TT37

        LDX     #$03
.tt38_lc
        LDA     XX15,X
        STA     K,X
        DEX
        BPL     tt38_lc

        LDA     L0035
        STA     S
        INY
        JMP     TT36

.TT37
        TYA
        BNE     TT32

        LDA     T
        BEQ     TT32

        DEC     U
        BPL     TT34

        LDA     #$20
        BNE     tt34_lc

.TT32
        LDY     #$00
        STY     T
        CLC
        ADC     #$30
.tt34_lc
        JSR     TT26

.TT34
        DEC     T
        BPL     L1CE4

        INC     T
.L1CE4
        DEC     XX17
        BMI     L1CF5

        BNE     L1CF2

        PLP
        BCC     L1CF2

        LDA     #$2E
        JSR     TT26

.L1CF2
        JMP     TT35

.L1CF5
        RTS

.BELL
        LDA     #$07
.TT26
        STA     K3
        STY     YSAV2
        STX     XSAV2
        LDY     QQ17
        CPY     #$FF
        BEQ     RR4

        CMP     #$07
        BEQ     R5

        CMP     #$20
        BCS     RR1

        CMP     #$0A
        BEQ     RRX1

        LDX     #$01
        STX     XC
.RRX1
        INC     YC
        BNE     RR4

.RR1
        TAY
        LDX     #$BF
        ASL     A
        ASL     A
        BCC     L1D23

        LDX     #$C1
.L1D23
        ASL     A
        BCC     L1D27

        INX
.L1D27
        STA     L001C
        STX     L001D
        LDA     #$80
        STA     SC
        LDA     YC
        CMP     #$18
        BCC     L1D3B

        JSR     TTX66

        JMP     RR4

.L1D3B
        LSR     A
        ROR     SC
        LSR     A
        ROR     SC
        ADC     YC
        ADC     #$58
        STA     SCH
        LDA     XC
        ASL     A
        ASL     A
        ASL     A
        ADC     SC
        STA     SC
        BCC     L1D54

        INC     SCH
.L1D54
        CPY     #$7F
        BNE     RR2

        DEC     XC
        DEC     SCH
        LDY     #$F8
        JSR     ZES2

        BEQ     RR4

.RR2
        INC     XC
.L1D65
        BIT     L0885
RREN = L1D65+1
        LDY     #$07
.RRL1
        LDA     (L001C),Y
        EOR     (SC),Y
        STA     (SC),Y
        DEY
        BPL     RRL1

.RR4
        LDY     YSAV2
        LDX     XSAV2
        LDA     K3
        CLC
.rT9
        RTS

.R5
        JSR     BEEP

        JMP     RR4

.DIALS
        LDA     #$F0
        STA     SC
        LDA     #$76
        STA     SCH
        LDA     DELTA
        JSR     DIL

        LDA     #$00
        STA     R
        STA     P
        LDA     #$08
        STA     S
        LDA     ALP1
        LSR     A
        LSR     A
        ORA     ALP2
        EOR     #$80
        JSR     ADD

        JSR     DIL2

        LDA     BETA
        LDX     BET1
        BEQ     L1DB0

        SBC     #$01
.L1DB0
        JSR     ADD

        JSR     DIL2

        LDA     MCNT
        AND     #$03
        BNE     rT9

        LDY     #$00
        LDX     #$03
.DLL23
        STY     XX12,X
        DEX
        BPL     DLL23

        LDX     #$03
        LDA     ENERGY
        LSR     A
        STA     Q
.DLL24
        SEC
        SBC     #$20
        BCC     DLL26

        STA     Q
        LDA     #$20
        STA     XX12,X
        LDA     Q
        DEX
        BPL     DLL24

        BMI     DLL9

.DLL26
        LDA     Q
        STA     XX12,X
.DLL9
        LDA     XX12,Y
        STY     P
        JSR     DIL

        LDY     P
        INY
        CPY     #$04
        BNE     DLL9

        LDA     #$76
        STA     SCH
        LDA     #$30
        STA     SC
        LDA     FSH
        JSR     DILX

        LDA     ASH
        JSR     DILX

        LDA     QQ14
        JSR     L1E27

        SEC
        JSR     L293D

        LDA     GNTMP
        JSR     DILX

        LDA     #$F0
        STA     T1
        STA     L003E
        LDA     ALTIT
        JSR     DILX

        JMP     COMPAS

.DILX
        LSR     A
        LSR     A
.L1E27
        LSR     A
.DIL
        STA     Q
        LDX     #$FF
        STX     R
        LDY     #$02
        LDX     #$03
.DL1
        LDA     Q
        CMP     #$08
        BCC     DL2

        SBC     #$08
        STA     Q
        LDA     R
.DL5
        STA     (SC),Y
        INY
        STA     (SC),Y
        INY
        STA     (SC),Y
        TYA
        CLC
        ADC     #$06
        BCC     L1E4E

        INC     SCH
.L1E4E
        TAY
        DEX
        BMI     DL6

        BPL     DL1

.DL2
        EOR     #$07
        STA     Q
        LDA     R
.DL3
        ASL     A
        DEC     Q
        BPL     DL3

        PHA
        LDA     #$00
        STA     R
        LDA     #$63
        STA     Q
        PLA
        JMP     DL5

.DL6
        SEC
        JMP     L293D

.DIL2
        LDY     #$01
        STA     Q
.DLL10
        SEC
        LDA     Q
        SBC     #$04
        BCS     DLL11

        LDA     #$FF
        LDX     Q
        STA     Q
        LDA     CTWOS,X
        BNE     DLL12

.DLL11
        STA     Q
        LDA     #$00
.DLL12
        STA     (SC),Y
        INY
        STA     (SC),Y
        INY
        STA     (SC),Y
        INY
        STA     (SC),Y
        TYA
        CLC
        ADC     #$05
        TAY
        CPY     #$1E
        BCC     DLL10

.L1E9E
        JMP     L293D

L1EA0 = L1E9E+2
.ESCAPE
        JSR     RES2

        JSR     RESET

        LDA     #$00
        LDX     #$10
.ESL2
        STA     QQ20,X
        DEX
        BPL     ESL2

        STA     FIST
        STA     ESCP
        LDA     #$46
        STA     QQ14
        JMP     BAY

.TA34
        LDA     #$00
        JSR     MAS4

        BEQ     L1EC9

        JMP     TA21

.L1EC9
        JSR     L1F2B

        JSR     EXNO3

        LDA     #$FA
        JMP     OOPS

.TA18
        LDA     ECMA
        BNE     TA35

        LDA     L0073
        ASL     A
        BMI     TA34

        LSR     A
        TAX
        LDA     UNIV,X
        STA     V
        LDA     L15F2,X
        STA     L0023
        LDY     #$02
        JSR     TAS1

        LDY     #$05
        JSR     TAS1

        LDY     #$08
        JSR     TAS1

        LDA     L00D4
        ORA     L00D7
        ORA     L00DA
        AND     #$7F
        ORA     L00D3
        ORA     L00D6
        ORA     L00D9
        BNE     TA64

        LDA     L0073
        CMP     #$82
        BEQ     TA35

        LDY     #$1F
        LDA     (V),Y
        BIT     L1F39
        BNE     TA35

        ORA     #$80
        STA     (V),Y
.TA35
        LDA     INWK
        ORA     L0056
        ORA     L0059
        BNE     TA87

        LDA     #$50
        JSR     OOPS

.TA87
        JSR     EXNO2

.L1F2B
        ASL     L0072
        SEC
        ROR     L0072
.TA1
        RTS

.TA64
        JSR     DORND

        CMP     #$10
        BCS     TA19

.M32
        LDY     #$20
L1F39 = M32+1
        LDA     (V),Y
        LSR     A
        BCC     TA19

        JMP     ECBLB2

.TACTICS
        CPX     #$08
        BEQ     TA18

        CPX     #$0B
        BNE     L1F50

        JSR     SPS1

        JMP     TA15

.L1F50
        CPX     #$07
        BNE     TA13

        JSR     DORND

        CMP     #$8C
        BCC     TA1

        LDA     L0BEF
        CMP     #$03
        BCS     TA1

        LDX     #$02
        LDA     #$E1
        JMP     SFS1

.TA13
        CPX     #$06
        BCS     TA62

        CPX     #$02
        BEQ     TA62

        LDA     SSPR
        BEQ     TA62

        LDA     L0073
        AND     #$81
        STA     L0073
.TA62
        LDY     #$0E
        LDA     L0076
        CMP     (XX0),Y
        BCS     TA21

        INC     L0076
.TA21
        LDX     #$08
.TAL1
        LDA     INWK,X
        STA     K3,X
        DEX
        BPL     TAL1

.TA19
        JSR     TAS2

        LDY     #$0A
        JSR     TAS3

        STA     CNT
        LDA     TYPE
        CMP     #$08
        BNE     L1FA2

        JMP     TA20

.L1FA2
        JSR     DORND

        CMP     #$FA
        BCC     TA7

        JSR     DORND

        ORA     #$68
        STA     L0070
.TA7
        LDY     #$0E
        LDA     (XX0),Y
        LSR     A
        CMP     L0076
        BCC     TA3

        LSR     A
        LSR     A
        CMP     L0076
        BCC     ta3_lc

        JSR     DORND

        CMP     #$E6
        BCC     ta3_lc

        LDA     #$00
        STA     L0073
        JMP     SESCP

.ta3_lc
        LDA     L0072
        AND     #$07
        BEQ     TA3

        STA     T
        JSR     DORND

        AND     #$1F
        CMP     T
        BCS     TA3

        LDA     ECMA
        BNE     TA3

        DEC     L0072
        LDA     TYPE
        JMP     SFRMIS

.TA3
        LDA     #$00
        JSR     MAS4

        AND     #$E0
        BNE     TA4

        LDX     CNT
        CPX     #$A0
        BCC     TA4

        LDA     L0072
        ORA     #$40
        STA     L0072
        CPX     #$A3
        BCC     TA4

        LDY     #$13
        LDA     (XX0),Y
        LSR     A
        JSR     OOPS

        DEC     L006F
        LDA     ECMA
        BNE     TA10

        LDA     #$08
        JMP     NOISE

.TA4
        LDA     L005A
        CMP     #$03
        BCS     TA5

        LDA     L0054
        ORA     L0057
        AND     #$FE
        BEQ     TA15

.TA5
        JSR     DORND

        ORA     #$80
        CMP     L0073
        BCS     TA15

.TA20
        LDA     XX15
        EOR     #$80
        STA     XX15
        LDA     Y1
        EOR     #$80
        STA     Y1
        LDA     X2
        EOR     #$80
        STA     X2
        LDA     CNT
        EOR     #$80
        STA     CNT
.TA15
        LDY     #$10
        JSR     TAS3

        EOR     #$80
        AND     #$80
        ORA     #$03
        STA     L0071
        LDA     L0070
        AND     #$7F
        CMP     #$10
        BCS     TA6

        LDY     #$16
        JSR     TAS3

        EOR     L0071
        AND     #$80
        EOR     #$85
        STA     L0070
.TA6
        LDA     CNT
        BMI     TA9

        CMP     #$16
        BCC     TA9

        LDA     #$03
        STA     L006F
        RTS

.TA9
        AND     #$7F
        CMP     #$12
        BCC     TA10

        LDA     #$FF
        LDX     TYPE
        CPX     #$08
        BNE     L2082

        ASL     A
.L2082
        STA     L006F
.TA10
        RTS

.TAS1
        LDA     (V),Y
        EOR     #$80
        STA     L0040
        DEY
        LDA     (V),Y
        STA     L003F
        DEY
        LDA     (V),Y
        STA     L003E
        STY     U
        LDX     U
        JSR     MVT3

        LDY     U
        STA     L00D4,X
        LDA     L003F
        STA     L00D3,X
        LDA     L003E
        STA     K3,X
        RTS

.HITCH
        CLC
        LDA     L005B
        BNE     HI1

        LDA     TYPE
        BMI     HI1

        LDA     L0072
        AND     #$20
        ORA     L0054
        ORA     L0057
        BNE     HI1

        LDA     INWK
        JSR     SQUA2

        STA     S
        LDA     P
        STA     R
        LDA     L0056
        JSR     SQUA2

        TAX
        LDA     P
        ADC     R
        STA     R
        TXA
        ADC     S
        BCS     L2157

        STA     S
        LDY     #$02
        LDA     (XX0),Y
        CMP     S
        BNE     HI1

        DEY
        LDA     (XX0),Y
        CMP     R
.HI1
        RTS

.FRS1
        JSR     ZINF

        LDA     #$1C
        STA     L0056
        LSR     A
        STA     L0059
        LDA     #$80
        STA     L0058
        LDA     MSTG
        ASL     A
        ORA     #$80
        STA     L0073
.fq1
        LDA     #$60
        STA     L0061
        ORA     #$80
        STA     L0069
        LDA     DELTA
        ROL     A
        STA     L006E
        TXA
        JMP     NWSHP

.FRMIS
        LDX     #$08
        JSR     FRS1

        BCC     FR1

        LDX     MSTG
        JSR     GINF

        LDA     FRIN,X
        JSR     ANGRY

        LDY     #$04
        JSR     ABORT

        DEC     NOMSL
        LDA     #$30
        JMP     NOISE

.ANGRY
        CMP     #$07
        BEQ     AN2

        BCS     HI1

        CMP     #$06
        BNE     L213A

        JSR     AN2

.L213A
        LDY     #$20
        LDA     (INF),Y
        BEQ     HI1

        ORA     #$80
        STA     (INF),Y
        LDY     #$1C
        LDA     #$02
        STA     (INF),Y
        ASL     A
        LDY     #$1E
        STA     (INF),Y
        RTS

.AN2
        ASL     L0944
        SEC
        ROR     L0944
.L2157
        CLC
        RTS

.FR1
        LDA     #$C9
        JMP     MESS

.SESCP
        LDX     #$0B
.L2160
        LDA     #$FE
.SFS1
        STA     T1
        LDA     XX0
        PHA
        LDA     L001F
        PHA
        LDA     INF
        PHA
        LDA     L0021
        PHA
        LDY     #$23
.FRL2
        LDA     INWK,Y
        STA     XX3,Y
        LDA     (INF),Y
        STA     INWK,Y
        DEY
        BPL     FRL2

        LDA     TYPE
        CMP     #$07
        BNE     rx

        TXA
        PHA
        LDA     #$20
        STA     L006E
        LDX     #$00
        LDA     L005D
        JSR     SFS2

        LDX     #$03
        LDA     L005F
        JSR     SFS2

        LDX     #$06
        LDA     L0061
        JSR     SFS2

        PLA
        TAX
.rx
        LDA     T1
        STA     L0073
        LSR     L0070
        ASL     L0070
        TXA
        CMP     #$0A
        BNE     NOIL

        JSR     DORND

        ASL     A
        STA     L0071
        TXA
        AND     #$0F
        STA     L006E
        LDA     #$FF
        ROR     A
        STA     L0070
        LDA     #$0A
.NOIL
        JSR     NWSHP

        PLA
        STA     L0021
        PLA
        STA     INF
        LDX     #$23
.FRL3
        LDA     XX3,X
        STA     INWK,X
        DEX
        BPL     FRL3

        PLA
        STA     L001F
        PLA
        STA     XX0
        RTS

.SFS2
        ASL     A
        STA     R
        LDA     #$00
        ROR     A
        JMP     MVT1

.LL164
        LDA     #$38
        JSR     NOISE

        LDA     #$01
        STA     HFX
        LDA     #$04
        JSR     HFS2

        DEC     HFX
        RTS

.LAUN
        LDA     #$30
        JSR     NOISE

        LDA     #$08
.HFS2
        STA     STP
        JSR     TTX66

        JSR     HFS1

.HFS1
        LDA     #$80
        STA     K3
        LDX     #$60
        STX     K4
        ASL     A
        STA     XX4
        STA     L00D3
        STA     L00E1
.HFL5
        JSR     HFL1

        INC     XX4
        LDX     XX4
        CPX     #$08
        BNE     HFL5

        RTS

.HFL1
        LDA     XX4
        AND     #$07
        CLC
        ADC     #$08
        STA     K
.HFL2
        LDA     #$01
        STA     LSP
        JSR     CIRCLE2

        ASL     K
        BCS     HF8

        LDA     K
        CMP     #$A0
        BCC     HFL2

.HF8
        RTS

.STARS2
        LDA     #$00
        CPX     #$02
        ROR     A
        STA     RAT
        EOR     #$80
        STA     RAT2
        JSR     ST2

        LDY     #$0A
.STL2
        LDA     SZ,Y
        STA     ZZ
        LSR     A
        LSR     A
        LSR     A
        JSR     DV41

        LDA     P
        EOR     RAT2
        STA     S
        LDA     SXL,Y
        STA     P
        LDA     SX,Y
        STA     XX15
        JSR     ADD

        STA     S
        STX     R
        LDA     SY,Y
        STA     Y1
        EOR     BET2
        LDX     BET1
        JSR     L23AB

        JSR     ADD

        STX     XX
        STA     L0025
        LDX     SYL,Y
        STX     R
        LDX     Y1
        STX     S
        LDX     BET1
        EOR     L008B
        JSR     L23AB

        JSR     ADD

        STX     YY
        STA     L0027
        LDX     ALP1
        EOR     ALP2
        JSR     L23AB

        STA     Q
        LDA     XX
        STA     R
        LDA     L0025
        STA     S
        EOR     #$80
        JSR     MAD

        STA     L0025
        TXA
        STA     SXL,Y
        LDA     YY
        STA     R
        LDA     L0027
        STA     S
        JSR     MAD

        STA     S
        STX     R
        LDA     #$00
        STA     P
        LDA     ALPHA
        JSR     PIX1

        LDA     L0025
        STA     SX,Y
        STA     XX15
        AND     #$7F
        CMP     #$74
        BCS     KILL2

        LDA     L0027
        STA     SY,Y
        STA     Y1
        AND     #$7F
        CMP     #$74
        BCS     L231E

.STC2
        JSR     PIXEL2

        DEY
        BEQ     ST2

        JMP     STL2

.ST2
        LDA     ALPHA
        EOR     RAT
        STA     ALPHA
        LDA     ALP2
        EOR     RAT
        STA     ALP2
        EOR     #$80
        STA     L0089
        LDA     BET2
        EOR     RAT
        STA     BET2
        EOR     #$80
        STA     L008B
        RTS

.KILL2
        JSR     DORND

        STA     Y1
        STA     SY,Y
        LDA     #$73
        ORA     RAT
        STA     XX15
        STA     SX,Y
        BNE     STF1

.L231E
        JSR     DORND

        STA     XX15
        STA     SX,Y
        LDA     #$6E
        ORA     L0089
        STA     Y1
        STA     SY,Y
.STF1
        JSR     DORND

        ORA     #$08
        STA     ZZ
        STA     SZ,Y
        BNE     STC2

.L233B
        EQUB    $00

        EQUB    $19,$32,$4A,$62,$79,$8E,$A2,$B5
        EQUB    $C6,$D5,$E2,$ED,$F5,$FB,$FF,$FF
        EQUB    $FF,$FB,$F5,$ED,$E2,$D5,$C6,$B5
        EQUB    $A2,$8E,$79,$62,$4A,$32,$19

.MU5
        STA     K
        STA     L003E
        STA     L003F
        STA     L0040
        CLC
        RTS

.MULT3
        STA     R
        AND     #$7F
        STA     L003F
        LDA     Q
        AND     #$7F
        BEQ     MU5

        SEC
        SBC     #$01
        STA     T
        LDA     L001C
        LSR     L003F
        ROR     A
        STA     L003E
        LDA     P
        ROR     A
        STA     K
        LDA     #$00
        LDX     #$18
.MUL2
        BCC     L238A

        ADC     T
.L238A
        ROR     A
        ROR     L003F
        ROR     L003E
        ROR     K
        DEX
        BNE     MUL2

        STA     T
        LDA     R
        EOR     Q
        AND     #$80
        ORA     T
        STA     L0040
        RTS

.MLS2
        LDX     XX
        STX     R
        LDX     L0025
        STX     S
.MLS1
        LDX     ALP1
.L23AB
        STX     P
        TAX
        AND     #$80
        STA     T
        TXA
        AND     #$7F
        BEQ     MU6

        TAX
        DEX
        STX     T1
        LDA     #$00
        LSR     P
        BCC     L23C3

        ADC     T1
.L23C3
        ROR     A
        ROR     P
        BCC     L23CA

        ADC     T1
.L23CA
        ROR     A
        ROR     P
        BCC     L23D1

        ADC     T1
.L23D1
        ROR     A
        ROR     P
        BCC     L23D8

        ADC     T1
.L23D8
        ROR     A
        ROR     P
        BCC     L23DF

        ADC     T1
.L23DF
        ROR     A
        ROR     P
        LSR     A
        ROR     P
        LSR     A
        ROR     P
        LSR     A
        ROR     P
        ORA     T
        RTS

.SQUA
        AND     #$7F
.SQUA2
        STA     P
        TAX
        BNE     MU11

.MU1
        CLC
        STX     P
        TXA
        RTS

.MLU1
        LDA     SY,Y
        STA     Y1
.MLU2
        AND     #$7F
        STA     P
.MULTU
        LDX     Q
        BEQ     MU1

.MU11
        DEX
        STX     T
        LDA     #$00
        LDX     #$08
        LSR     P
.MUL6
        BCC     L2414

        ADC     T
.L2414
        ROR     A
        ROR     P
        DEX
        BNE     MUL6

        RTS

.MU6
        STA     L001C
        STA     P
        RTS

.FMLTU2
        AND     #$1F
        TAX
        LDA     L233B,X
        STA     Q
        LDA     K
.FMLTU
        EOR     #$FF
        SEC
        ROR     A
        STA     P
        LDA     #$00
.MUL3
        BCS     MU7

        ADC     Q
        ROR     A
        LSR     P
        BNE     MUL3

        RTS

.MU7
        LSR     A
        LSR     P
        BNE     MUL3

        RTS

        LDX     Q
        BEQ     MU1

        DEX
        STX     T
        LDA     #$00
        LDX     #$08
        LSR     P
.L244F
        BCC     L2453

        ADC     T
.L2453
        ROR     A
        ROR     P
        DEX
        BNE     L244F

        RTS

.L245A
        STX     Q
.MLTU2
        EOR     #$FF
        LSR     A
        STA     L001C
        LDA     #$00
        LDX     #$10
        ROR     P
.MUL7
        BCS     MU21

        ADC     Q
        ROR     A
        ROR     L001C
        ROR     P
        DEX
        BNE     MUL7

        RTS

.MU21
        LSR     A
        ROR     L001C
        ROR     P
        DEX
        BNE     MUL7

        RTS

        LDX     ALP1
        STX     P
.MUT2
        LDX     L0025
        STX     S
.MUT1
        LDX     XX
        STX     R
.MULT1
        TAX
        AND     #$7F
        LSR     A
        STA     P
        TXA
        EOR     Q
        AND     #$80
        STA     T
        LDA     Q
        AND     #$7F
        BEQ     mu10

        TAX
        DEX
        STX     T1
        LDA     #$00
        LDX     #$07
.MUL4
        BCC     L24A8

        ADC     T1
.L24A8
        ROR     A
        ROR     P
        DEX
        BNE     MUL4

        LSR     A
        ROR     P
        ORA     T
        RTS

.mu10
        STA     P
        RTS

.MULT12
        JSR     MULT1

        STA     S
        LDA     P
        STA     R
        RTS

.TAS3
        LDX     INWK,Y
        STX     Q
        LDA     XX15
        JSR     MULT12

        LDX     L0055,Y
        STX     Q
        LDA     Y1
        JSR     MAD

        STA     S
        STX     R
        LDX     L0057,Y
        STX     Q
        LDA     X2
.MAD
        JSR     MULT1

.ADD
        STA     T1
        AND     #$80
        STA     T
        EOR     S
        BMI     MU8

        LDA     R
        CLC
        ADC     P
        TAX
        LDA     S
        ADC     T1
        ORA     T
        RTS

.MU8
        LDA     S
        AND     #$7F
        STA     U
        LDA     P
        SEC
        SBC     R
        TAX
        LDA     T1
        AND     #$7F
        SBC     U
        BCS     MU9

        STA     U
        TXA
        EOR     #$FF
        ADC     #$01
        TAX
        LDA     #$00
        SBC     U
        ORA     #$80
.MU9
        EOR     T
        RTS

.TIS1
        STX     Q
        EOR     #$80
        JSR     MAD

        TAX
        AND     #$80
        STA     T
        TXA
        AND     #$7F
        LDX     #$FE
        STX     T1
.DVL3
        ASL     A
        CMP     #$60
        BCC     DV4

        SBC     #$60
.DV4
        ROL     T1
        BCS     DVL3

        LDA     T1
        ORA     T
        RTS

.DV42
        LDA     SZ,Y
.DV41
        STA     Q
        LDA     DELTA
.DVID4
        LDX     #$08
        ASL     A
        STA     P
        LDA     #$00
.DVL4
        ROL     A
        BCS     DV8

        CMP     Q
        BCC     DV5

.DV8
        SBC     Q
        SEC
.DV5
        ROL     P
        DEX
        BNE     DVL4

        JMP     L4630

.DVID3B2
        STA     L001D
        LDA     L0059
        STA     Q
        LDA     L005A
        STA     R
        LDA     L005B
        STA     S
        LDA     P
        ORA     #$01
        STA     P
        LDA     L001D
        EOR     S
        AND     #$80
        STA     T
        LDY     #$00
        LDA     L001D
        AND     #$7F
.DVL9
        CMP     #$40
        BCS     DV14

        ASL     P
        ROL     L001C
        ROL     A
        INY
        BNE     DVL9

.DV14
        STA     L001D
        LDA     S
        AND     #$7F
        BMI     DV9

.DVL6
        DEY
        ASL     Q
        ROL     R
        ROL     A
        BPL     DVL6

.DV9
        STA     Q
        LDA     #$FE
        STA     R
        LDA     L001D
        JSR     LL31

        LDA     #$00
        STA     L003E
        STA     L003F
        STA     L0040
        TYA
        BPL     DV12

        LDA     R
.DVL8
        ASL     A
        ROL     L003E
        ROL     L003F
        ROL     L0040
        INY
        BNE     DVL8

        STA     K
        LDA     L0040
        ORA     T
        STA     L0040
        RTS

.DV13
        LDA     R
        STA     K
        LDA     T
        STA     L0040
        RTS

.DV12
        BEQ     DV13

        LDA     R
.DVL10
        LSR     A
        DEY
        BNE     DVL10

        STA     K
        LDA     T
        STA     L0040
        RTS

.cntr
        LDA     DAMP
        BNE     RE1

        TXA
        BPL     BUMP

        DEX
        BMI     RE1

.BUMP
        INX
        BNE     RE1

        DEX
        BEQ     BUMP

.RE1
        RTS

.BUMP2
        STA     T
        TXA
        CLC
        ADC     T
        TAX
        BCC     RE2

        LDX     #$FF
.RE2
        BPL     L260F

.L25FF
        LDA     T
        RTS

.REDU2
        STA     T
        TXA
        SEC
        SBC     T
        TAX
        BCS     RE3

        LDX     #$01
.RE3
        BPL     L25FF

.L260F
        LDA     DJD
        BNE     L25FF

        LDX     #$80
        BMI     L25FF

        LDA     P
        EOR     Q
        STA     T1
        LDA     Q
        BEQ     AR2

        ASL     A
        STA     Q
        LDA     P
        ASL     A
        CMP     Q
        BCS     AR1

        JSR     ARS1

        SEC
.AR4
        LDX     T1
        BMI     AR3

        RTS

.AR1
        LDX     Q
        STA     Q
        STX     P
        TXA
        JSR     ARS1

        STA     T
        LDA     #$40
        SBC     T
        BCS     AR4

.AR2
        LDA     #$3F
        RTS

.AR3
        STA     T
        LDA     #$80
        SBC     T
        RTS

.ARS1
        JSR     LL28

        LDA     R
        LSR     A
        LSR     A
        LSR     A
        TAX
        LDA     L265E,X
        RTS

.L265E
        EQUB    $00

        EQUB    $01,$03,$04,$05,$06,$08,$09,$0A
        EQUB    $0B,$0C,$0D,$0F,$10,$11,$12,$13
        EQUB    $14,$15,$16,$17,$18,$19,$19,$1A
        EQUB    $1B,$1C,$1D,$1D,$1E,$1F,$1F

.WARP
        LDA     L0BF6
        CLC
        ADC     L0BF8
        CLC
        ADC     L0BF7
        TAX
        LDA     L0BE2,X
        ORA     SSPR
        BNE     WA1

        LDY     L0908
        BMI     WA3

        TAY
        JSR     MAS2

        CMP     #$02
        BCC     WA1

.WA3
        LDY     L092C
        BMI     WA2

        LDY     #$24
        JSR     m

        CMP     #$02
        BCC     WA1

.WA2
        LDA     #$81
        STA     S
        STA     R
        STA     P
        LDA     L0908
        JSR     ADD

        STA     L0908
        LDA     L092C
        JSR     ADD

        STA     L092C
        LDA     #$01
        STA     QQ11
        STA     MCNT
        LSR     A
        STA     EV
        LDX     VIEW
        JMP     LOOK1

.WA1
        LDA     #$28
        JMP     NOISE

.LASLI
        JSR     DORND

        AND     #$07
        ADC     #$5C
        STA     LASY
        JSR     DORND

        AND     #$07
        ADC     #$7C
        STA     LASX
        LDA     GNTMP
        ADC     #$08
        STA     GNTMP
        JSR     DENGY

.LASLI2
        LDA     QQ11
        BNE     L2735

        LDA     #$20
        LDY     #$E0
        JSR     L270A

        LDA     #$30
        LDY     #$D0
.L270A
        STA     X2
        LDA     LASX
        STA     XX15
        LDA     LASY
        STA     Y1
        LDA     #$BF
        STA     Y2
        JSR     LL30

        LDA     LASX
        STA     XX15
        LDA     LASY
        STA     Y1
        STY     X2
        LDA     #$BF
        STA     Y2
        JMP     LL30

.PLUT
        LDX     VIEW
        BNE     PU1

.L2735
        RTS

.PU1
        DEX
        BNE     PU2

        LDA     L0055
        EOR     #$80
        STA     L0055
        LDA     L005B
        EOR     #$80
        STA     L005B
        LDA     L005D
        EOR     #$80
        STA     L005D
        LDA     L0061
        EOR     #$80
        STA     L0061
        LDA     L0063
        EOR     #$80
        STA     L0063
        LDA     L0067
        EOR     #$80
        STA     L0067
        LDA     L0069
        EOR     #$80
        STA     L0069
        LDA     L006D
        EOR     #$80
        STA     L006D
        RTS

.PU2
        LDA     #$00
        CPX     #$02
        ROR     A
        STA     RAT2
        EOR     #$80
        STA     RAT
        LDA     INWK
        LDX     L0059
        STA     L0059
        STX     INWK
        LDA     L0054
        LDX     L005A
        STA     L005A
        STX     L0054
        LDA     L0055
        EOR     RAT
        TAX
        LDA     L005B
        EOR     RAT2
        STA     L0055
        STX     L005B
        LDY     #$09
        JSR     PUS1

        LDY     #$0F
        JSR     PUS1

        LDY     #$15
.PUS1
        LDA     INWK,Y
        LDX     L0057,Y
        STA     L0057,Y
        STX     INWK,Y
        LDA     L0054,Y
        EOR     RAT
        TAX
        LDA     L0058,Y
        EOR     RAT2
        STA     L0054,Y
        STX     L0058,Y
.LO2
        RTS

.LQ
        STX     VIEW
        JSR     TT66

        JSR     SIGHT

        JMP     NWSTARS

.LOOK1
        LDA     #$00
        LDY     QQ11
        BNE     LQ

        CPX     VIEW
        BEQ     LO2

        STX     VIEW
        JSR     TT66

        JSR     FLIP

        JSR     WPSHPS

.SIGHT
        LDY     VIEW
        LDA     LASER,Y
        BEQ     LO2

        LDA     #$80
        STA     QQ19
        LDA     #$48
        STA     L0080
        LDA     #$14
        STA     L0081
        JSR     TT15

        LDA     #$0A
        STA     L0081
        JMP     TT15

.L27FA
        LDA     #$01
.TT66
        STA     QQ11
.TTX66
        LDA     #$80
        STA     QQ17
        ASL     A
        STA     LAS2
        STA     DLY
        STA     de
        LDX     #$58
        JSR     LYN

        LDX     L002F
        BEQ     BOX

        JSR     L304B

.BOX
        LDY     #$01
        STY     YC
        LDA     QQ11
        BNE     tt66_lc

        LDY     #$0B
        STY     XC
        LDA     VIEW
        ORA     #$60
        JSR     TT27

        JSR     TT162

        LDA     #$AF
        JSR     TT27

.tt66_lc
        LDX     #$00
        STX     QQ17
.L2838
        LDX     #$00
        STX     XX15
        STX     Y1
        DEX
        STX     X2
        JSR     HLOIN

        LDA     #$02
        STA     XX15
        STA     X2
        JSR     BOS2

.BOS2
        JSR     BOS1

.BOS1
        LDA     #$00
        STA     Y1
        LDA     #$BF
        STA     Y2
        DEC     XX15
        DEC     X2
        JMP     LL30

.L285F
        LDY     #$01
.L2861
        BIT     L1EA0
L2862 = L2861+1
.DELAY
        TXA
        LDX     #$00
        BIT     LFDD0
.L286A
        BIT     LFBD0
DEL8 = L286A+1
        DEX
        BNE     DEL8

        TAX
        DEY
        BNE     DELAY

        RTS

.hm
        JSR     TT103

        JSR     TT111

        JSR     TT103

        LDA     QQ11
        BEQ     SC5

.CLYNS
        JSR     L2838

        LDX     #$71
        JSR     LYN

        JSR     L2838

        LDA     #$14
        STA     YC
        JSR     TT67

        LDY     #$01
        STY     XC
        DEY
        TYA
.SC5
        RTS

.LYN
        JSR     L40E1

        INX
        CPX     #$76
        BNE     LYN

        RTS

.SCAN
        LDA     L0072
        AND     #$10
        BEQ     SC5

        LDA     TYPE
        BMI     SC5

        LDA     L0054
        ORA     L0057
        ORA     L005A
        AND     #$C0
        BNE     SC5

        LDA     L0054
        CLC
        LDX     L0055
        BPL     SC2

        EOR     #$FF
        ADC     #$01
.SC2
        ADC     #$7B
        STA     XX15
        LDA     L005A
        LSR     A
        LSR     A
        CLC
        LDX     L005B
        BPL     SC3

        EOR     #$FF
        SEC
.SC3
        ADC     #$23
        EOR     #$FF
        STA     SC
        LDA     L0057
        LSR     A
        CLC
        LDX     L0058
        BMI     SCD6

        EOR     #$FF
        SEC
.SCD6
        ADC     SC
        BPL     ld246

        CMP     #$C2
        BCS     L28EE

        LDA     #$C2
.L28EE
        CMP     #$F7
        BCC     L28F4

.ld246
        LDA     #$F6
.L28F4
        STA     Y1
        SEC
        SBC     SC
        PHP
        PHA
        JSR     CPIX4

        LDA     TWOS,X
        STA     XX15
        PLA
        PLP
        TAX
        BEQ     RTS

        BCC     L2926

.VLL1
        DEY
        BPL     VL1

        LDY     #$07
        LDA     SC
        SEC
        SBC     #$40
        STA     SC
        LDA     SCH
        SBC     #$01
        STA     SCH
.VL1
        LDA     XX15
        EOR     (SC),Y
        STA     (SC),Y
        DEX
        BNE     VLL1

.RTS
        RTS

.L2926
        JSR     L2936

.L2929
        JSR     L2936

        LDA     XX15
        EOR     (SC),Y
        STA     (SC),Y
        INX
        BNE     L2929

        RTS

.L2936
        INY
        CPY     #$08
        BNE     RTS

        LDY     #$00
.L293D
        LDA     SC
        ADC     #$3F
        STA     SC
        LDA     SCH
        ADC     #$01
        STA     SCH
        RTS

.tnpr
        PHA
        LDX     #$0C
        CPX     QQ29
        BCC     kg

.Tml
        ADC     QQ20,X
        DEX
        BPL     Tml

        CMP     CRGO
        PLA
        RTS

.kg
        LDY     QQ29
        ADC     QQ20,Y
        CMP     #$C8
        PLA
        RTS

.TT20
        JSR     L296A

.L296A
        JSR     TT54

.TT54
        LDA     QQ15
        CLC
        ADC     L007A
        TAX
        LDA     L0079
        ADC     L007B
        TAY
        LDA     L007A
        STA     QQ15
        LDA     L007B
        STA     L0079
        LDA     L007D
        STA     L007B
        LDA     L007C
        STA     L007A
        CLC
        TXA
        ADC     L007A
        STA     L007C
        TYA
        ADC     L007B
        STA     L007D
        RTS

.TT146
        LDA     QQ8
        ORA     L0CF1
        BNE     TT63

        INC     YC
        RTS

.TT63
        LDA     #$BF
        JSR     TT68

        LDX     QQ8
        LDY     L0CF1
        SEC
        JSR     pr5

        LDA     #$C3
.TT60
        JSR     TT27

.TTX69
        INC     YC
.TT69
        LDA     #$80
        STA     QQ17
.TT67
        LDA     #$0D
        JMP     TT27

.TT70
        LDA     #$AD
        JSR     TT27

        JMP     TT72

.spc
        JSR     TT27

        JMP     TT162

.TT25
        JSR     L27FA

        LDA     #$09
        STA     XC
        LDA     #$A3
        JSR     TT27

        JSR     NLIN

        JSR     TTX69

        INC     YC
        JSR     TT146

        LDA     #$C2
        JSR     TT68

        LDA     QQ3
        CLC
        ADC     #$01
        LSR     A
        CMP     #$02
        BEQ     TT70

        LDA     QQ3
        BCC     TT71

        SBC     #$05
        CLC
.TT71
        ADC     #$AA
        JSR     TT27

.TT72
        LDA     QQ3
        LSR     A
        LSR     A
        CLC
        ADC     #$A8
        JSR     TT60

        LDA     #$A2
        JSR     TT68

        LDA     QQ4
        CLC
        ADC     #$B1
        JSR     TT60

        LDA     #$C4
        JSR     TT68

        LDX     QQ5
        INX
        CLC
        JSR     pr2

        JSR     TTX69

        LDA     #$C0
        JSR     TT68

        SEC
        LDX     QQ6
        JSR     pr2

        LDA     #$C6
        JSR     TT60

        LDA     #$28
        JSR     TT27

        LDA     L007C
        BMI     TT75

        LDA     #$BC
        JSR     TT27

        JMP     TT76

.TT75
        LDA     L007D
        LSR     A
        LSR     A
        PHA
        AND     #$07
        CMP     #$03
        BCS     TT205

        ADC     #$E3
        JSR     spc

.TT205
        PLA
        LSR     A
        LSR     A
        LSR     A
        CMP     #$06
        BCS     TT206

        ADC     #$E6
        JSR     spc

.TT206
        LDA     L007B
        EOR     L0079
        AND     #$07
        STA     QQ19
        CMP     #$06
        BCS     TT207

        ADC     #$EC
        JSR     spc

.TT207
        LDA     L007D
        AND     #$03
        CLC
        ADC     QQ19
        AND     #$07
        ADC     #$F2
        JSR     TT27

.TT76
        LDA     #$53
        JSR     TT27

        LDA     #$29
        JSR     TT60

        LDA     #$C1
        JSR     TT68

        LDX     QQ7
        LDY     L0CEF
        JSR     pr6

        JSR     TT162

        LDA     #$00
        STA     QQ17
        LDA     #$4D
        JSR     TT27

        LDA     #$E2
        JSR     TT60

        LDA     #$FA
        JSR     TT68

        LDA     L007D
        LDX     L007B
        AND     #$0F
        CLC
        ADC     #$0B
        TAY
        JSR     pr5

        JSR     TT162

        LDA     #$6B
        JSR     TT26

        LDA     #$6D
        JMP     TT26

.TT24
        LDA     L0079
        AND     #$07
        STA     QQ3
        LDA     L007A
        LSR     A
        LSR     A
        LSR     A
        AND     #$07
        STA     QQ4
        LSR     A
        BNE     TT77

        LDA     QQ3
        ORA     #$02
        STA     QQ3
.TT77
        LDA     QQ3
        EOR     #$07
        CLC
        STA     QQ5
        LDA     L007B
        AND     #$03
        ADC     QQ5
        STA     QQ5
        LDA     QQ4
        LSR     A
        ADC     QQ5
        STA     QQ5
        ASL     A
        ASL     A
        ADC     QQ3
        ADC     QQ4
        ADC     #$01
        STA     QQ6
        LDA     QQ3
        EOR     #$07
        ADC     #$03
        STA     P
        LDA     QQ4
        ADC     #$04
        STA     Q
        JSR     MULTU

        LDA     QQ6
        STA     Q
        JSR     MULTU

        ASL     P
        ROL     A
        ASL     P
        ROL     A
        ASL     P
        ROL     A
        STA     L0CEF
        LDA     P
        STA     QQ7
        RTS

.TT22
        LDA     #$40
        JSR     TT66

        LDA     #$07
        STA     XC
        JSR     TT81

        LDA     #$C7
        JSR     TT27

        JSR     NLIN

        LDA     #$98
        JSR     NLIN2

        JSR     TT14

        LDX     #$00
.TT83
        STX     XSAV
        LDX     L007B
        LDY     L007C
        TYA
        ORA     #$50
        STA     ZZ
        LDA     L0079
        LSR     A
        CLC
        ADC     #$18
        STA     Y1
        JSR     PIXEL

        JSR     TT20

        LDX     XSAV
        INX
        BNE     TT83

        LDA     QQ9
        STA     QQ19
        LDA     QQ10
        LSR     A
        STA     L0080
        LDA     #$04
        STA     L0081
.TT15
        LDA     #$18
        LDX     QQ11
        BPL     L2B95

        LDA     #$00
.L2B95
        STA     L0084
        LDA     QQ19
        SEC
        SBC     L0081
        BCS     TT84

        LDA     #$00
.TT84
        STA     XX15
        LDA     QQ19
        CLC
        ADC     L0081
        BCC     L2BAB

        LDA     #$FF
.L2BAB
        STA     X2
        LDA     L0080
        CLC
        ADC     L0084
        STA     Y1
        JSR     HLOIN

        LDA     L0080
        SEC
        SBC     L0081
        BCS     TT86

        LDA     #$00
.TT86
        CLC
        ADC     L0084
        STA     Y1
        LDA     L0080
        CLC
        ADC     L0081
        ADC     L0084
        CMP     #$98
        BCC     TT87

        LDX     QQ11
        BMI     TT87

        LDA     #$97
.TT87
        STA     Y2
        LDA     QQ19
        STA     XX15
        STA     X2
        JMP     LL30

.TT126
        LDA     #$68
        STA     QQ19
        LDA     #$5A
        STA     L0080
        LDA     #$10
        STA     L0081
        JSR     TT15

        LDA     QQ14
        STA     K
        JMP     TT128

.TT14
        LDA     QQ11
        BMI     TT126

        LDA     QQ14
        LSR     A
        LSR     A
        STA     K
        LDA     QQ0
        STA     QQ19
        LDA     QQ1
        LSR     A
        STA     L0080
        LDA     #$07
        STA     L0081
        JSR     TT15

        LDA     L0080
        CLC
        ADC     #$18
        STA     L0080
.TT128
        LDA     QQ19
        STA     K3
        LDA     L0080
        STA     K4
        LDX     #$00
        STX     L00E1
        STX     L00D3
        INX
        STX     LSP
        LDX     #$02
        STX     STP
        JSR     CIRCLE2

        RTS

.TT219
        JSR     L27FA

        JSR     TT163

        LDA     #$80
        STA     QQ17
        LDA     #$00
        STA     QQ29
.L2C44
        JSR     TT151

        LDA     QQ25
        BNE     TT224

        JMP     TT222

.TQ4
        LDY     #$B0
.Tc
        JSR     TT162

        TYA
        JSR     prq

        JSR     dn2

.TT224
        JSR     CLYNS

        LDA     #$CC
        JSR     TT27

        LDA     QQ29
        CLC
        ADC     #$D0
        JSR     TT27

        LDA     #$2F
        JSR     TT27

        JSR     TT152

        LDA     #$3F
        JSR     TT27

        JSR     TT67

        LDX     #$00
        STX     R
        LDX     #$0C
        STX     T1
        JSR     gnum

        BCS     TQ4

        STA     P
        JSR     tnpr

        LDY     #$CE
        BCS     Tc

        LDA     QQ24
        STA     Q
        JSR     GCASH

        JSR     LCASH

        LDY     #$C5
        BCC     Tc

        LDY     QQ29
        LDA     R
        PHA
        CLC
        ADC     QQ20,Y
        STA     QQ20,Y
        LDA     AVL,Y
        SEC
        SBC     R
        STA     AVL,Y
        PLA
        BEQ     TT222

        JSR     dn

.TT222
        LDA     QQ29
        CLC
        ADC     #$05
        STA     YC
        LDA     #$00
        STA     XC
        INC     QQ29
        LDA     QQ29
        CMP     #$11
        BCS     BAY2

        JMP     L2C44

.BAY2
        LDA     #$A7
        JMP     FRCE

.gnum
        LDX     #$00
        STX     R
        LDX     #$0C
        STX     T1
.TT223
        JSR     TT217

        STA     Q
        SEC
        SBC     #$30
        BCC     OUT

        CMP     #$0A
        BCS     BAY2

        STA     S
        LDA     R
        CMP     #$1A
        BCS     OUT

        ASL     A
        STA     T
        ASL     A
        ASL     A
        ADC     T
        ADC     S
        STA     R
        CMP     QQ25
        BEQ     TT226

        BCS     OUT

.TT226
        LDA     Q
        JSR     TT26

        DEC     T1
        BNE     TT223

.OUT
        LDA     R
        RTS

.TT208
        LDA     #$04
        JSR     TT66

        LDA     #$04
        STA     YC
        STA     XC
        LDA     #$CD
        JSR     TT27

        LDA     #$CE
        JSR     TT68

.TT210
        LDY     #$00
.TT211
        STY     QQ29
        LDX     QQ20,Y
        BEQ     TT212

        TYA
        ASL     A
        ASL     A
        TAY
        LDA     L4457,Y
        STA     L0080
        TXA
        PHA
        JSR     TT69

        CLC
        LDA     QQ29
        ADC     #$D0
        JSR     TT27

        LDA     #$0E
        STA     XC
        PLA
        TAX
        CLC
        JSR     pr2

        JSR     TT152

        LDA     QQ11
        CMP     #$04
        BNE     TT212

        LDA     #$CD
        JSR     TT214

        BCC     TT212

        LDA     QQ29
        LDX     #$FF
        STX     QQ17
        JSR     TT151

        LDY     QQ29
        LDA     QQ20,Y
        STA     P
        LDA     QQ24
        STA     Q
        JSR     GCASH

        JSR     MCASH

        LDA     #$00
        LDY     QQ29
        STA     QQ20,Y
        STA     QQ17
.TT212
        LDY     QQ29
        INY
        CPY     #$11
        BCS     L2D99

        JMP     TT211

.L2D99
        LDA     QQ11
        CMP     #$04
        BNE     L2DA5

        JSR     dn2

        JMP     BAY2

.L2DA5
        RTS

.TT213
        LDA     #$08
        JSR     TT66

        LDA     #$0B
        STA     XC
        LDA     #$A4
        JSR     TT60

        JSR     NLIN4

        JSR     fwl

        LDA     CRGO
        CMP     #$1A
        BCC     L2DC6

        LDA     #$6B
        JSR     TT27

.L2DC6
        JMP     TT210

.TT214
        PHA
        JSR     TT162

        PLA
        JSR     TT27

        LDA     #$E1
        JSR     TT27

        JSR     TT217

        ORA     #$20
        CMP     #$79
        BEQ     TT218

        LDA     #$6E
        JMP     TT26

.TT218
        JSR     TT26

        SEC
        RTS

.TT16
        TXA
        PHA
        DEY
        TYA
        EOR     #$FF
        PHA
        JSR     TT103

        PLA
        STA     K6
        LDA     QQ10
        JSR     TT123

        LDA     L0083
        STA     QQ10
        STA     L0080
        PLA
        STA     K6
        LDA     QQ9
        JSR     TT123

        LDA     L0083
        STA     QQ9
        STA     QQ19
.TT103
        LDA     QQ11
        BEQ     TT180

        BMI     TT105

        LDA     QQ9
        STA     QQ19
        LDA     QQ10
        LSR     A
        STA     L0080
        LDA     #$04
        STA     L0081
        JMP     TT15

.TT123
        STA     L0083
        CLC
        ADC     K6
        LDX     K6
        BMI     TT124

        BCC     TT125

        RTS

.TT124
        BCC     TT180

.TT125
        STA     L0083
.TT180
        RTS

.TT105
        LDA     QQ9
        SEC
        SBC     QQ0
        CMP     #$26
        BCC     TT179

        CMP     #$E6
        BCC     TT180

.TT179
        ASL     A
        ASL     A
        CLC
        ADC     #$68
        STA     QQ19
        LDA     QQ10
        SEC
        SBC     QQ1
        CMP     #$26
        BCC     L2E61

        CMP     #$DC
        BCC     TT180

.L2E61
        ASL     A
        CLC
        ADC     #$5A
        STA     L0080
        LDA     #$08
        STA     L0081
        JMP     TT15

.TT23
        LDA     #$80
        JSR     TT66

        LDA     #$07
        STA     XC
        LDA     #$BE
        JSR     NLIN3

        JSR     TT14

        JSR     TT103

        JSR     TT81

        LDA     #$00
        STA     XX20
        LDX     #$18
.EE3
        STA     INWK,X
        DEX
        BPL     EE3

.TT182
        LDA     L007B
        SEC
        SBC     QQ0
        BCS     TT184

        EOR     #$FF
        ADC     #$01
.TT184
        CMP     #$14
        BCS     TT187

        LDA     L0079
        SEC
        SBC     QQ1
        BCS     TT186

        EOR     #$FF
        ADC     #$01
.TT186
        CMP     #$26
        BCS     TT187

        LDA     L007B
        SEC
        SBC     QQ0
        ASL     A
        ASL     A
        ADC     #$68
        STA     XX12
        LSR     A
        LSR     A
        LSR     A
        STA     XC
        INC     XC
        LDA     L0079
        SEC
        SBC     QQ1
        ASL     A
        ADC     #$5A
        STA     Y1
        LSR     A
        LSR     A
        LSR     A
        TAY
        LDX     INWK,Y
        BEQ     EE4

        INY
        LDX     INWK,Y
        BEQ     EE4

        DEY
        DEY
        LDX     INWK,Y
        BNE     ee1

.EE4
        STY     YC
        CPY     #$03
        BCC     TT187

        DEX
        STX     INWK,Y
        LDA     #$80
        STA     QQ17
        JSR     cpl

.ee1
        LDA     XX12
        STA     XX15
        JSR     CPIX4

.TT187
        JSR     TT20

        INC     XX20
        BEQ     L2F0C

        JMP     TT182

.TT81
        LDX     #$05
.L2F04
        LDA     QQ21,X
        STA     QQ15,X
        DEX
        BPL     L2F04

.L2F0C
        RTS

.TT111
        JSR     TT81

        LDY     #$7F
        STY     T
        LDA     #$00
        STA     U
.TT130
        LDA     L007B
        SEC
        SBC     QQ9
        BCS     TT132

        EOR     #$FF
        ADC     #$01
.TT132
        LSR     A
        STA     S
        LDA     L0079
        SEC
        SBC     QQ10
        BCS     TT134

        EOR     #$FF
        ADC     #$01
.TT134
        LSR     A
        CLC
        ADC     S
        CMP     T
        BCS     TT135

        STA     T
        LDX     #$05
.TT136
        LDA     QQ15,X
        STA     QQ19,X
        DEX
        BPL     TT136

.TT135
        JSR     TT20

        INC     U
        BNE     TT130

        LDX     #$05
.TT137
        LDA     QQ19,X
        STA     QQ15,X
        DEX
        BPL     TT137

        LDA     L0079
        STA     QQ10
        LDA     L007B
        STA     QQ9
        SEC
        SBC     QQ0
        BCS     TT139

        EOR     #$FF
        ADC     #$01
.TT139
        JSR     SQUA2

        STA     L003E
        LDA     P
        STA     K
        LDA     QQ10
        SEC
        SBC     QQ1
        BCS     TT141

        EOR     #$FF
        ADC     #$01
.TT141
        LSR     A
        JSR     SQUA2

        PHA
        LDA     P
        CLC
        ADC     K
        STA     Q
        PLA
        ADC     L003E
        STA     R
        JSR     LL5

        LDA     Q
        ASL     A
        LDX     #$00
        STX     L0CF1
        ROL     L0CF1
        ASL     A
        ROL     L0CF1
        STA     QQ8
        JMP     TT24

.hy6
        JSR     CLYNS

        LDA     #$0F
        STA     XC
        JMP     TT27

.hyp
        LDA     QQ12
        BNE     hy6

        LDA     L002F
        BNE     hy5

        LDX     #$01
        JSR     CTRL

        BMI     Ghy

        JSR     hm

        LDA     QQ8
        ORA     L0CF1
        BEQ     hy5

        LDA     #$07
        STA     XC
        LDA     #$17
        STA     YC
        LDA     #$00
        STA     QQ17
        LDA     #$BD
        JSR     TT27

        LDA     L0CF1
        BNE     TT147

        LDA     QQ14
        CMP     QQ8
        BCC     TT147

        LDA     #$2D
        JSR     TT27

        JSR     cpl

.wW
        LDA     #$0F
        STA     L002F
        STA     QQ22
        TAX
        JMP     L304B

.Ghy
        LDX     GHYP
        BEQ     hy5

        INX
        STX     GHYP
        STX     FIST
        JSR     wW

        LDX     #$05
        INC     GCNT
        LDA     GCNT
        AND     #$07
        STA     GCNT
.G1
        LDA     QQ21,X
        ASL     A
        ROL     QQ21,X
        DEX
        BPL     G1

.L3023
        LDA     #$60
hy5 = L3023+1
        STA     QQ9
        STA     QQ10
        JSR     TT110

        JSR     TT111

        LDX     #$00
        STX     QQ8
        STX     L0CF1
        LDA     #$74
        JSR     MESS

.jmp
        LDA     QQ9
        STA     QQ0
        LDA     QQ10
        STA     QQ1
        RTS

.L304B
        LDY     #$01
        STY     YC
        DEY
        STY     XC
.pr6
        CLC
.pr5
        LDA     #$05
        JMP     TT11

.TT147
        LDA     #$CA
.prq
        JSR     TT27

        LDA     #$3F
        JMP     TT27

.TT151
        PHA
        STA     L0083
        ASL     A
        ASL     A
        STA     QQ19
        LDA     #$01
        STA     XC
        PLA
        ADC     #$D0
        JSR     TT27

        LDA     #$0E
        STA     XC
        LDX     QQ19
        LDA     L4457,X
        STA     L0080
        LDA     QQ26
        AND     L4459,X
        CLC
        ADC     QQ23,X
        STA     QQ24
        JSR     TT152

        JSR     var

        LDA     L0080
        BMI     TT155

        LDA     QQ24
        ADC     K6
        JMP     TT156

.TT155
        LDA     QQ24
        SEC
        SBC     K6
.TT156
        STA     QQ24
        STA     P
        LDA     #$00
        JSR     GC2

        SEC
        JSR     pr5

        LDY     L0083
        LDA     #$05
        LDX     AVL,Y
        STX     QQ25
        CLC
        BEQ     TT172

        JSR     L1C35

        JMP     TT152

.TT172
        LDA     XC
        ADC     #$04
        STA     XC
        LDA     #$2D
        BNE     L30DD

.TT152
        LDA     L0080
        AND     #$60
        BEQ     TT160

        CMP     #$20
        BEQ     TT161

        JSR     TT16a

.TT162
        LDA     #$20
.L30DD
        JMP     TT27

.TT160
        LDA     #$74
        JSR     TT26

        BCC     TT162

.TT161
        LDA     #$6B
        JSR     TT26

.TT16a
        LDA     #$67
        JMP     TT26

.TT163
        LDA     #$11
        STA     XC
        LDA     #$FF
        BNE     L30DD

.TT167
        LDA     #$10
        JSR     TT66

        LDA     #$05
        STA     XC
        LDA     #$A7
        JSR     NLIN3

        LDA     #$03
        STA     YC
        JSR     TT163

        LDA     #$00
        STA     QQ29
.TT168
        LDX     #$80
        STX     QQ17
        JSR     TT151

        INC     YC
        INC     QQ29
        LDA     QQ29
        CMP     #$11
        BCC     TT168

        RTS

.var
        LDA     L0080
        AND     #$1F
        LDY     QQ28
        STA     L0081
        CLC
        LDA     #$00
        STA     L0345
.TT153
        DEY
        BMI     TT154

        ADC     L0081
        JMP     TT153

.TT154
        STA     K6
        RTS

.hyp1
        JSR     TT111

        JSR     jmp

        LDX     #$05
.TT112
        LDA     QQ15,X
        STA     QQ2,X
        DEX
        BPL     TT112

        INX
        STX     EV
        LDA     QQ3
        STA     QQ28
        LDA     QQ5
        STA     tek
        LDA     QQ4
        STA     gov
        RTS

.GVL
        JSR     DORND

        STA     QQ26
        LDX     #$00
        STX     XX4
.hy9
        LDA     L4457,X
        STA     L0080
        JSR     var

        LDA     L4459,X
        AND     QQ26
        CLC
        ADC     L4458,X
        LDY     L0080
        BMI     TT157

        SEC
        SBC     K6
        JMP     TT158

.TT157
        CLC
        ADC     K6
.TT158
        BPL     TT159

        LDA     #$00
.TT159
        LDY     XX4
        AND     #$3F
        STA     AVL,Y
        INY
        TYA
        STA     XX4
        ASL     A
        ASL     A
        TAX
        CMP     #$3F
        BCC     hy9

.hyR
        RTS

.TT18
        LDA     QQ14
        SEC
        SBC     QQ8
        STA     QQ14
        LDA     QQ11
        BNE     ee5

        JSR     TT66

        JSR     LL164

.ee5
        JSR     hyp1

        JSR     GVL

        JSR     RES2

        JSR     SOLAR

        LDA     QQ11
        AND     #$3F
        BNE     hyR

        JSR     TTX66

        LDA     QQ11
        BNE     TT114

        INC     QQ11
.TT110
        LDX     QQ12
        BEQ     NLUNCH

        JSR     LAUN

        JSR     RES2

        JSR     TT111

        INC     L005B
        JSR     SOS1

        LDA     #$80
        STA     L005B
        INC     L005A
        JSR     NWSPS

        LDA     #$0C
        STA     DELTA
        JSR     BAD

        ORA     FIST
        STA     FIST
.NLUNCH
        LDX     #$00
        STX     QQ12
        JMP     LOOK1

.TT114
        BMI     TT115

        JMP     TT22

.TT115
        JMP     TT23

.LCASH
        STX     T1
        LDA     L030C
        SEC
        SBC     T1
        STA     L030C
        STY     T1
        LDA     L030B
        SBC     T1
        STA     L030B
        LDA     L030A
        SBC     #$00
        STA     L030A
        LDA     CASH
        SBC     #$00
        STA     CASH
        BCS     TT113

.MCASH
        TXA
        CLC
        ADC     L030C
        STA     L030C
        TYA
        ADC     L030B
        STA     L030B
        LDA     L030A
        ADC     #$00
        STA     L030A
        LDA     CASH
        ADC     #$00
        STA     CASH
        CLC
.TT113
        RTS

.GCASH
        JSR     MULTU

.GC2
        ASL     P
        ROL     A
        ASL     P
        ROL     A
        TAY
        LDX     P
        RTS

.bay_lc
        JMP     BAY

.EQSHP
        JSR     DIALS

        LDA     #$20
        JSR     TT66

        LDA     #$0C
        STA     XC
        LDA     #$CF
        JSR     spc

        LDA     #$B9
        JSR     NLIN3

        LDA     #$80
        STA     QQ17
        INC     YC
        LDA     tek
        CLC
        ADC     #$03
        CMP     #$0C
        BCC     L328E

        LDA     #$0C
.L328E
        STA     Q
        STA     QQ25
        INC     Q
        LDA     #$46
        SEC
        SBC     QQ14
        ASL     A
        STA     L1B45
        LDX     #$01
.EQL1
        STX     XX13
        JSR     TT67

        LDX     XX13
        CLC
        JSR     pr2

        JSR     TT162

        LDA     XX13
        CLC
        ADC     #$68
        JSR     TT27

        LDA     XX13
        JSR     L33EC

        SEC
        LDA     #$19
        STA     XC
        LDA     #$06
        JSR     TT11

        LDX     XX13
        INX
        CPX     Q
        BCC     EQL1

        JSR     CLYNS

        LDA     #$7F
        JSR     prq

        JSR     gnum

        BEQ     bay_lc

        BCS     bay_lc

        SBC     #$00
        LDX     #$02
        STX     XC
        INC     YC
        PHA
        JSR     eq

        PLA
        BNE     et0

        STA     MCNT
        LDX     #$46
        STX     QQ14
.et0
        CMP     #$01
        BNE     et1

        LDX     NOMSL
        INX
        LDY     #$75
        CPX     #$05
        BCS     pres

        STX     NOMSL
        JSR     msblob

.et1
        LDY     #$6B
        CMP     #$02
        BNE     et2

        LDX     #$25
        CPX     CRGO
        BEQ     pres

        STX     CRGO
.et2
        CMP     #$03
        BNE     et3

        INY
        LDX     ECM
        BNE     pres

        DEC     ECM
.et3
        CMP     #$04
        BNE     et4

        JSR     qv

        LDA     #$04
        LDY     LASER,X
        BEQ     ed4

.ed7
        LDY     #$BB
        BNE     pres

.ed4
        LDA     #$0F
        STA     LASER,X
        LDA     #$04
.et4
        CMP     #$05
        BNE     et5

        JSR     qv

        STX     T1
        LDA     #$05
        LDY     LASER,X
        BEQ     ed5

        BMI     ed7

        LDA     #$04
        JSR     prx

        JSR     MCASH

.ed5
        LDA     #$8F
        LDX     T1
        STA     LASER,X
.et5
        LDY     #$6F
        CMP     #$06
        BNE     et6

        LDX     BST
        BEQ     ed9

.pres
        STY     K
        JSR     prx

        JSR     MCASH

        LDA     K
        JSR     spc

        LDA     #$1F
        JSR     TT27

.err
        JSR     dn2

        JMP     BAY

.ed9
        DEC     BST
.et6
        INY
        CMP     #$07
        BNE     et7

        LDX     ESCP
        BNE     pres

        DEC     ESCP
.et7
        INY
        CMP     #$08
        BNE     et8

        LDX     BOMB
        BNE     pres

        LDX     #$7F
        STX     BOMB
.et8
        INY
        CMP     #$09
        BNE     etA

        LDX     ENGY
        BNE     pres

        INC     ENGY
.etA
        INY
        CMP     #$0A
        BNE     etB

        LDX     DKCMP
        BNE     pres

        DEC     DKCMP
.etB
        INY
        CMP     #$0B
        BNE     et9

        LDX     GHYP
        BNE     pres

        DEC     GHYP
.et9
        JSR     dn

        JMP     EQSHP

.dn
        JSR     TT162

        LDA     #$77
        JSR     spc

.dn2
        JSR     BEEP

        LDY     #$C8
        JMP     DELAY

.eq
        JSR     prx

        JSR     LCASH

        BCS     c

        LDA     #$C5
        JSR     prq

        JMP     err

.L33EC
        SEC
        SBC     #$01
.prx
        ASL     A
        TAY
        LDX     L1B45,Y
        LDA     L1B46,Y
        TAY
.c
        RTS

.qv
        LDY     #$10
        STY     YC
.qv1
        LDX     #$0C
        STX     XC
        TYA
        CLC
        ADC     #$20
        JSR     spc

        LDA     YC
        CLC
        ADC     #$50
        JSR     TT27

        INC     YC
        LDY     YC
        CPY     #$14
        BCC     qv1

.qv3
        JSR     CLYNS

        LDA     #$AF
        JSR     prq

        JSR     TT217

        SEC
        SBC     #$30
        CMP     #$04
        BCS     qv3

        TAX
        RTS

        EQUB    $8C

        EQUB    $E7,$8D,$E6,$C1,$C8,$C8,$E6,$D6
        EQUB    $C5,$C6,$C1,$CA,$83,$9C,$90

.cpl
        LDX     #$05
.TT53
        LDA     QQ15,X
        STA     QQ19,X
        DEX
        BPL     TT53

        LDY     #$03
        BIT     QQ15
        BVS     L344C

        DEY
.L344C
        STY     T
.TT55
        LDA     L007D
        AND     #$1F
        BEQ     L3459

        ORA     #$80
        JSR     TT27

.L3459
        JSR     TT54

        DEC     T
        BPL     TT55

        LDX     #$05
.TT56
        LDA     QQ19,X
        STA     QQ15,X
        DEX
        BPL     TT56

        RTS

.cmn
        LDY     #$00
.QUL4
        LDA     L159D,Y
        CMP     #$0D
        BEQ     L3479

        JSR     TT26

        INY
        BNE     QUL4

.L3479
        RTS

.ypl
        JSR     TT62

        JSR     cpl

.TT62
        LDX     #$05
.TT78
        LDA     QQ15,X
        LDY     QQ2,X
        STA     QQ2,X
        STY     QQ15,X
        DEX
        BPL     TT78

        RTS

.tal
        CLC
        LDX     GCNT
        INX
        JMP     pr2

.fwl
        LDA     #$69
        JSR     TT68

        LDX     QQ14
        SEC
        JSR     pr2

        LDA     #$C3
        JSR     plf

        LDA     #$77
        BNE     TT27

.csh
        LDX     #$03
.pc1
        LDA     CASH,X
        STA     K,X
        DEX
        BPL     pc1

        LDA     #$09
        STA     U
        SEC
        JSR     BPRNT

        LDA     #$E2
.plf
        JSR     TT27

        JMP     TT67

.TT68
        JSR     TT27

.TT73
        LDA     #$3A
.TT27
        TAX
        BEQ     csh

        BMI     TT43

        DEX
        BEQ     tal

        DEX
        BEQ     ypl

        DEX
        BNE     L34DD

        JMP     cpl

.L34DD
        DEX
        BEQ     cmn

        DEX
        BEQ     fwl

        DEX
        BNE     L34EB

        LDA     #$80
        STA     QQ17
        RTS

.L34EB
        DEX
        DEX
        BNE     L34F2

        STX     QQ17
        RTS

.L34F2
        DEX
        BEQ     crlf

        CMP     #$60
        BCS     ex

        CMP     #$0E
        BCC     L3501

        CMP     #$20
        BCC     qw

.L3501
        LDX     QQ17
        BEQ     TT74

        BMI     TT41

        BIT     QQ17
        BVS     TT46

.TT42
        CMP     #$41
        BCC     TT44

        CMP     #$5B
        BCS     TT44

        ADC     #$20
.TT44
        JMP     TT26

.TT41
        BIT     QQ17
        BVS     TT45

        CMP     #$41
        BCC     TT74

        PHA
        TXA
        ORA     #$40
        STA     QQ17
        PLA
        BNE     TT44

.qw
        ADC     #$72
        BNE     ex

.crlf
        LDA     #$15
        STA     XC
        BNE     TT73

.TT45
        CPX     #$FF
        BEQ     TT48

        CMP     #$41
        BCS     TT42

.TT46
        PHA
        TXA
        AND     #$BF
        STA     QQ17
        PLA
.TT74
        JMP     TT26

.TT43
        CMP     #$A0
        BCS     TT47

        AND     #$7F
        ASL     A
        TAY
        LDA     L4416,Y
        JSR     TT27

        LDA     L4417,Y
        CMP     #$3F
        BEQ     TT48

        JMP     TT27

.TT47
        SBC     #$A0
.ex
        TAX
        LDA     #$00
        STA     V
        LDA     #$04
        STA     L0023
        LDY     #$00
        TXA
        BEQ     TT50

.TT51
        LDA     (V),Y
        BEQ     TT49

        INY
        BNE     TT51

        INC     L0023
        BNE     TT51

.TT49
        INY
        BNE     TT59

        INC     L0023
.TT59
        DEX
        BNE     TT51

.TT50
        TYA
        PHA
        LDA     L0023
        PHA
        LDA     (V),Y
        EOR     #$23
        JSR     TT27

        PLA
        STA     L0023
        PLA
        TAY
        INY
        BNE     L3596

        INC     L0023
.L3596
        LDA     (V),Y
        BNE     TT50

.TT48
        RTS

.EX2
        LDA     L0072
        ORA     #$A0
        STA     L0072
        RTS

.DOEXP
        LDA     L0072
        AND     #$40
        BEQ     L35AB

        JSR     PTCLS

.L35AB
        LDA     L0059
        STA     T
        LDA     L005A
        CMP     #$20
        BCC     L35B9

        LDA     #$FE
        BNE     L35C1

.L35B9
        ASL     T
        ROL     A
        ASL     T
        ROL     A
        SEC
        ROL     A
.L35C1
        STA     Q
        LDY     #$01
        LDA     (XX19),Y
        ADC     #$04
        BCS     EX2

        STA     (XX19),Y
        JSR     DVID4

        LDA     P
        CMP     #$1C
        BCC     L35DA

        LDA     #$FE
        BNE     LABEL_1

.L35DA
        ASL     R
        ROL     A
        ASL     R
        ROL     A
        ASL     R
        ROL     A
.LABEL_1
        DEY
        STA     (XX19),Y
        LDA     L0072
        AND     #$BF
        STA     L0072
        AND     #$08
        BEQ     TT48

        LDY     #$02
        LDA     (XX19),Y
        TAY
.EXL1
        LDA     L00F9,Y
        STA     (XX19),Y
        DEY
        CPY     #$06
        BNE     EXL1

        LDA     L0072
        ORA     #$40
        STA     L0072
.PTCLS
        LDY     #$00
        LDA     (XX19),Y
        STA     Q
        INY
        LDA     (XX19),Y
        BPL     L3612

        EOR     #$FF
.L3612
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        ORA     #$01
        STA     U
        INY
        LDA     (XX19),Y
        STA     TGT
        LDA     L0001
        PHA
        LDY     #$06
.EXL5
        LDX     #$03
.EXL3
        INY
        LDA     (XX19),Y
        STA     K3,X
        DEX
        BPL     EXL3

        STY     CNT
        LDY     #$02
.EXL2
        INY
        LDA     (XX19),Y
        EOR     CNT
        STA     LFFFD,Y
        CPY     #$06
        BNE     EXL2

        LDY     U
.EXL4
        JSR     DORND2

        STA     ZZ
        LDA     L00D3
        STA     R
        LDA     K3
        JSR     EXS1

        BNE     EX11

        CPX     #$BF
        BCS     EX11

        STX     Y1
        LDA     L00D5
        STA     R
        LDA     L00D4
        JSR     EXS1

        BNE     EX4

        LDA     Y1
        JSR     PIXEL

.EX4
        DEY
        BPL     EXL4

        LDY     CNT
        CPY     TGT
        BCC     EXL5

        PLA
        STA     L0001
        LDA     L0906
        STA     L0003
        RTS

.EX11
        JSR     DORND2

        JMP     EX4

.EXS1
        STA     S
        JSR     DORND2

        ROL     A
        BCS     EX5

        JSR     FMLTU

        ADC     R
        TAX
        LDA     S
        ADC     #$00
        RTS

.EX5
        JSR     FMLTU

        STA     T
        LDA     R
        SBC     T
        TAX
        LDA     S
        SBC     #$00
        RTS

.SOS1
        JSR     msblob

        LDA     #$7F
        STA     L0070
        STA     L0071
        LDA     tek
        AND     #$02
        ORA     #$80
        JMP     NWSHP

.SOLAR
        LSR     FIST
        JSR     ZINF

        LDA     L0079
        AND     #$07
        ADC     #$06
        LSR     A
        STA     L005B
        ROR     A
        STA     L0055
        STA     L0058
        JSR     SOS1

        LDA     #$81
        JSR     NWSHP

.NWSTARS
        LDA     QQ11
        BNE     WPSHPS

.nWq
        LDY     #$0A
.SAL4
        JSR     DORND

        ORA     #$08
        STA     SZ,Y
        STA     ZZ
        JSR     DORND

        STA     SX,Y
        STA     XX15
        JSR     DORND

        STA     SY,Y
        STA     Y1
        JSR     PIXEL2

        DEY
        BNE     SAL4

.WPSHPS
        LDX     #$00
.WSL1
        LDA     FRIN,X
        BEQ     WS2

        BMI     WS1

        STA     TYPE
        JSR     GINF

        LDY     #$1F
.WAL2
        LDA     (INF),Y
        STA     INWK,Y
        DEY
        BPL     WAL2

        STX     XSAV
        JSR     SCAN

        LDX     XSAV
        LDY     #$1F
        LDA     (INF),Y
        AND     #$A7
        STA     (INF),Y
.WS1
        INX
        BNE     WSL1

.WS2
        LDX     #$FF
        STX     LSX2
        STX     LSY2
.L3727
        DEX
        RTS

.SHD
        INX
        BEQ     L3727

.DENGY
        DEC     ENERGY
        PHP
        BNE     L3735

        INC     ENERGY
.L3735
        PLP
        RTS

.COMPAS
        JSR     DOT

        LDA     SSPR
        BNE     SP1

        JSR     SPS1

        JMP     SP2

.SPS2
        ASL     A
        TAX
        LDA     #$00
        ROR     A
        TAY
        LDA     #$14
        STA     Q
        TXA
        JSR     DVID4

        LDX     P
        TYA
        BMI     LL163

        LDY     #$00
        RTS

.LL163
        LDY     #$FF
        TXA
        EOR     #$FF
        TAX
        INX
        RTS

.SPS4
        LDX     #$08
.SPL1
        LDA     L0924,X
        STA     K3,X
        DEX
        BPL     SPL1

        JMP     TAS2

.SP1
        JSR     SPS4

.SP2
        LDA     XX15
        JSR     SPS2

        TXA
        ADC     #$C1
        STA     COMX
        LDA     Y1
        JSR     SPS2

        STX     T
        LDA     #$CC
        SBC     T
        STA     COMY
        LDA     #$F0
        LDX     X2
        BPL     L3794

        LDA     #$FF
.L3794
        STA     COMC
.DOT
        LDA     COMY
        STA     Y1
        LDA     COMX
        STA     XX15
        LDA     COMC
        CMP     #$F0
        BNE     CPIX2

.CPIX4
        JSR     CPIX2

        DEC     Y1
.CPIX2
        LDY     #$80
        STY     SC
        LDA     Y1
        LSR     A
        LSR     A
        LSR     A
        STA     SCH
        LSR     A
        ROR     SC
        LSR     A
        ROR     SC
        ADC     SCH
        ADC     #$58
        STA     SCH
        LDA     XX15
        AND     #$F8
        ADC     SC
        STA     SC
        BCC     L37D0

        INC     SCH
.L37D0
        LDA     Y1
        AND     #$07
        TAY
        LDA     XX15
        AND     #$07
        TAX
        LDA     TWOS,X
        EOR     (SC),Y
        STA     (SC),Y
        JSR     L37E4

.L37E4
        INX
        LDA     TWOS,X
        BPL     CP1

        LDA     SC
        CLC
        ADC     #$08
        STA     SC
        BCC     L37F5

        INC     SCH
.L37F5
        LDA     TWOS,X
.CP1
        EOR     (SC),Y
        STA     (SC),Y
        RTS

.OOPS
        STA     T
        LDY     #$08
        LDX     #$00
        LDA     (INF),Y
        BMI     OO1

        LDA     FSH
        SBC     T
        BCC     OO2

        STA     FSH
        RTS

.OO2
        STX     FSH
        BCC     OO3

.OO1
        LDA     ASH
        SBC     T
        BCC     OO5

        STA     ASH
        RTS

.OO5
        STX     ASH
.OO3
        ADC     ENERGY
        STA     ENERGY
        BEQ     L382F

        BCS     L3832

.L382F
        JMP     DEATH

.L3832
        JSR     EXNO3

        JMP     OUCH

.SPS3
        LDA     L0901,X
        STA     K3,X
        LDA     L0902,X
        TAY
        AND     #$7F
        STA     L00D3,X
        TYA
        AND     #$80
        STA     L00D4,X
        RTS

.GINF
        TXA
        ASL     A
        TAY
        LDA     UNIV,Y
        STA     INF
        LDA     L15F2,Y
        STA     L0021
        RTS

.NWSPS
        JSR     SPBLB

        LDX     #$01
        STX     L0073
        DEX
        STX     L0071
        STX     L0BE1
        DEX
        STX     L0070
        LDX     #$0A
        JSR     NwS1

        JSR     NwS1

        JSR     NwS1

        LDA     #$08
        STA     XX19
        LDA     #$0C
        STA     L0075
        LDA     #$07
.NWSHP
        STA     T
        LDX     #$00
.NWL1
        LDA     FRIN,X
        BEQ     NW1

        INX
        CPX     #$0C
        BCC     NWL1

        CLC
.L388D
        RTS

.NW1
        JSR     GINF

        LDA     T
        BMI     NW2

        ASL     A
        TAY
        LDA     L4ED2,Y
        STA     XX0
        LDA     L4ED3,Y
        STA     L001F
        CPY     #$0E
        BEQ     NW6

        LDY     #$05
        LDA     (XX0),Y
        STA     T1
        LDA     SLSP
        SEC
        SBC     T1
        STA     XX19
        LDA     L0CE0
        SBC     #$00
        STA     L0075
        LDA     XX19
        SBC     INF
        TAY
        LDA     L0075
        SBC     L0021
        BCC     L388D

        BNE     NW4

        CPY     #$24
        BCC     L388D

.NW4
        LDA     XX19
        STA     SLSP
        LDA     L0075
        STA     L0CE0
.NW6
        LDY     #$0E
        LDA     (XX0),Y
        STA     L0076
        LDY     #$13
        LDA     (XX0),Y
        AND     #$07
        STA     L0072
        LDA     T
.NW2
        STA     FRIN,X
        TAX
        BMI     L38EE

        INC     LAS2,X
.L38EE
        LDY     #$23
.NWL3
        LDA     INWK,Y
        STA     (INF),Y
        DEY
        BPL     NWL3

        SEC
        RTS

.NwS1
        LDA     INWK,X
        EOR     #$80
        STA     INWK,X
        INX
        INX
        RTS

.L3903
        LDY     #$09
.ABORT
        LDX     #$FF
.ABORT2
        STX     MSTG
        LDX     NOMSL
        JSR     MSBAR

        STY     MSAR
        RTS

.ECBLB2
        LDA     #$20
        STA     ECMA
        ASL     A
        JSR     NOISE

.ECBLB
        LDA     #$98
        LDX     #$35
        LDY     #$7C
        BNE     BULB

.SPBLB
        LDA     #$20
        LDX     #$38
        LDY     #$7D
.BULB
        STA     SC
        STX     L001C
        LDX     #$39
        STX     L001D
        TYA
        JMP     RREN

.L3935
        EQUB    $FE

        EQUB    $FE,$E0

        EQUB    $FE,$FE,$E0,$FE,$FE,$0E,$FE,$FE

.MSBAR
        TXA
        PHA
        ASL     A
        ASL     A
        ASL     A
        STA     T
        LDA     #$D1
        SBC     T
        STA     SC
        LDA     #$7D
        STA     SCH
        TYA
        TAX
        LDY     #$05
.MBL1
        LDA     L3961,X
        STA     (SC),Y
        DEX
        DEY
        BNE     MBL1

        PLA
        TAX
        RTS

.L3961
        EQUB    $00

        EQUB    $00,$00,$00,$00,$FC,$FC,$FC,$FC
        EQUB    $FC,$84,$B4,$84,$FC,$C4,$EC,$EC
        EQUB    $FC

.PROJ
        LDA     INWK
        STA     P
        LDA     L0054
        STA     L001C
        LDA     L0055
        JSR     PLS6

        BCS     RTS2

        LDA     K
        ADC     #$80
        STA     K3
        TXA
        ADC     #$00
        STA     L00D3
        LDA     L0056
        STA     P
        LDA     L0057
        STA     L001C
        LDA     L0058
        EOR     #$80
        JSR     PLS6

        BCS     RTS2

        LDA     K
        ADC     #$60
        STA     K4
        TXA
        ADC     #$00
        STA     L00E1
        CLC
.RTS2
        RTS

.PL2
        JMP     WPLS2

.L39AE
        LDA     TYPE
        LSR     A
        BCS     RTS2

        LDA     L005B
        BMI     PL2

        CMP     #$30
        BCS     PL2

        ORA     L005A
        BEQ     PL2

        JSR     PROJ

        BCS     PL2

        LDA     #$60
        STA     L001C
        LDA     #$00
        STA     P
        JSR     DVID3B2

        LDA     L003E
        BEQ     PL82

        LDA     #$F8
        STA     K
.PL82
        JSR     WPLS2

        JMP     CIRCLE

.CIRCLE
        JSR     CHKON

        BCS     RTS2

        LDA     #$00
        STA     LSX2
        LDX     K
        LDA     #$08
        CPX     #$09
        BCC     PL89

        LSR     A
.PL89
        STA     STP
.CIRCLE2
        LDX     #$FF
        STX     FLAG
        INX
        STX     CNT
.PLL3
        LDA     CNT
        JSR     FMLTU2

        LDX     #$00
        STX     T
        LDX     CNT
        CPX     #$21
        BCC     PL37

        EOR     #$FF
        ADC     #$00
        TAX
        LDA     #$FF
        ADC     #$00
        STA     T
        TXA
        CLC
.PL37
        ADC     K3
        STA     K6
        LDA     L00D3
        ADC     T
        STA     L0083
        LDA     CNT
        CLC
        ADC     #$10
        JSR     FMLTU2

        TAX
        LDA     #$00
        STA     T
        LDA     CNT
        ADC     #$0F
        AND     #$3F
        CMP     #$21
        BCC     PL38

        TXA
        EOR     #$FF
        ADC     #$00
        TAX
        LDA     #$FF
        ADC     #$00
        STA     T
        CLC
.PL38
        JSR     BLINE

        CMP     #$41
        BCS     L3A4D

        JMP     PLL3

.L3A4D
        CLC
        RTS

.WPLS2
        LDY     LSX2
        BNE     WP1

.WPL1
        CPY     LSP
        BCS     WP1

        LDA     LSY2,Y
        CMP     #$FF
        BEQ     WP2

        STA     Y2
        LDA     LSX2,Y
        STA     X2
        JSR     LL30

        INY
        LDA     SWAP
        BNE     WPL1

        LDA     X2
        STA     XX15
        LDA     Y2
        STA     Y1
        JMP     WPL1

.WP2
        INY
        LDA     LSX2,Y
        STA     XX15
        LDA     LSY2,Y
        STA     Y1
        INY
        JMP     WPL1

.WP1
        LDA     #$01
        STA     LSP
        LDA     #$FF
        STA     LSX2
        RTS

.CHKON
        LDA     K3
        CLC
        ADC     K
        LDA     L00D3
        ADC     #$00
        BMI     PL21

        LDA     K3
        SEC
        SBC     K
        LDA     L00D3
        SBC     #$00
        BMI     PL31

        BNE     PL21

.PL31
        LDA     K4
        CLC
        ADC     K
        STA     L001C
        LDA     L00E1
        ADC     #$00
        BMI     PL21

        STA     L001D
        LDA     K4
        SEC
        SBC     K
        TAX
        LDA     L00E1
        SBC     #$00
        BMI     PL44

        BNE     PL21

        CPX     #$BF
        RTS

.PL21
        SEC
        RTS

.PLS6
        JSR     DVID3B2

        LDA     L0040
        AND     #$7F
        ORA     L003F
        BNE     PL21

        LDX     L003E
        CPX     #$04
        BCS     PL6

        LDA     L0040
        BPL     PL6

        LDA     K
        EOR     #$FF
        ADC     #$01
        STA     K
        TXA
        EOR     #$FF
        ADC     #$00
        TAX
.PL44
        CLC
.PL6
        RTS

.TT17
        JSR     DOKEY

        LDX     JSTK
        BEQ     TJ1

        LDA     JSTX
        EOR     #$FF
        JSR     TJS1

        TYA
        TAX
        LDA     JSTY
.TJS1
        TAY
        LDA     #$00
        CPY     #$10
        SBC     #$00
        CPY     #$40
        SBC     #$00
        CPY     #$C0
        ADC     #$00
        CPY     #$E0
        ADC     #$00
        TAY
        LDA     KL
        RTS

.TJ1
        LDA     KL
        LDY     #$00
        CMP     #$18
        BNE     L3B24

        DEX
.L3B24
        CMP     #$78
        BNE     L3B29

        INX
.L3B29
        CMP     #$39
        BNE     L3B2E

        INY
.L3B2E
        CMP     #$28
        BNE     L3B33

        DEY
.L3B33
        RTS

.ping
        LDX     #$01
.pl1
        LDA     QQ0,X
        STA     QQ9,X
        DEX
        BPL     pl1

        RTS

.KS3
        LDA     P
        STA     SLSP
        LDA     L001C
        STA     L0CE0
        RTS

.KS1
        LDX     XSAV
        JSR     KILLSHP

        LDX     XSAV
        JMP     MAL1

.KS4
        JSR     ZINF

        LDA     #$00
        STA     L0BE1
        STA     SSPR
        JSR     SPBLB

        LDA     #$06
        STA     L0058
        LDA     #$81
        JMP     NWSHP

.KS2
        LDX     #$FF
.KSL4
        INX
        LDA     FRIN,X
        BEQ     KS3

        CMP     #$08
        BNE     KSL4

        TXA
        ASL     A
        TAY
        LDA     UNIV,Y
        STA     SC
        LDA     L15F2,Y
        STA     SCH
        LDY     #$20
        LDA     (SC),Y
        BPL     KSL4

        AND     #$7F
        LSR     A
        CMP     XX4
        BCC     KSL4

        BEQ     KS6

        SBC     #$01
        ASL     A
        ORA     #$80
        STA     (SC),Y
        BNE     KSL4

.KS6
        LDA     #$00
        STA     (SC),Y
        BEQ     KSL4

.KILLSHP
        STX     XX4
        LDA     MSTG
        CMP     XX4
        BNE     KS5

        JSR     L3903

        LDA     #$C8
        JSR     MESS

.KS5
        LDY     XX4
        LDX     FRIN,Y
        CPX     #$07
        BEQ     KS4

        DEC     LAS2,X
        LDX     XX4
        LDY     #$05
        LDA     (XX0),Y
        LDY     #$21
        CLC
        ADC     (INF),Y
        STA     P
        INY
        LDA     (INF),Y
        ADC     #$00
        STA     L001C
.KSL1
        INX
        LDA     FRIN,X
        STA     L0BDF,X
        BEQ     KS2

        ASL     A
        TAY
        LDA     L4ED2,Y
        STA     SC
        LDA     L4ED3,Y
        STA     SCH
        LDY     #$05
        LDA     (SC),Y
        STA     T
        LDA     P
        SEC
        SBC     T
        STA     P
        LDA     L001C
        SBC     #$00
        STA     L001C
        TXA
        ASL     A
        TAY
        LDA     UNIV,Y
        STA     SC
        LDA     L15F2,Y
        STA     SCH
        LDY     #$23
        LDA     (SC),Y
        STA     (INF),Y
        DEY
        LDA     (SC),Y
        STA     L003E
        LDA     L001C
        STA     (INF),Y
        DEY
        LDA     (SC),Y
        STA     K
        LDA     P
        STA     (INF),Y
        DEY
.KSL2
        LDA     (SC),Y
        STA     (INF),Y
        DEY
        BPL     KSL2

        LDA     SC
        STA     INF
        LDA     SCH
        STA     L0021
        LDY     T
.KSL3
        DEY
        LDA     (K),Y
        STA     (P),Y
        TYA
        BNE     KSL3

        BEQ     KSL1

.L3C3C
        EQUB    $11

        EQUB    $01,$00,$03,$11,$02,$2C,$04,$11
        EQUB    $03,$F0,$06,$10,$F1,$04,$05,$01
        EQUB    $F1,$BC,$01,$11,$F4,$0C,$08,$10
        EQUB    $F1,$04,$06,$10,$02,$60,$10,$11
        EQUB    $04,$C2,$FF,$11,$00,$00,$00

.L3C64
        EQUB    $70,$24,$56,$56,$42,$28,$C8,$D0
        EQUB    $F0,$E0

.RESET
        JSR     ZERO

.L3C71
        LDX     #$06
.SAL3
        STA     BETA,X
        DEX
        BPL     SAL3

        STX     QQ12
.RES4
        LDA     #$FF
        LDX     #$02
.REL5
        STA     FSH,X
        DEX
        BPL     REL5

.RES2
        LDX     #$FF
        STX     LSX2
        STX     LSY2
        STX     MSTG
        LDA     #$80
        STA     JSTY
        STA     ALP2
        STA     BET2
        ASL     A
        STA     L0089
        STA     L008B
        STA     MCNT
        LDA     #$03
        STA     DELTA
        STA     ALPHA
        STA     ALP1
        LDA     SSPR
        BEQ     L3CAD

        JSR     SPBLB

.L3CAD
        LDA     ECMA
        BEQ     yu

        JSR     ECMOF

.yu
        JSR     WPSHPS

        JSR     ZERO

        LDA     #$DF
        STA     SLSP
        LDA     #$0B
        STA     L0CE0
        JSR     DIALS

.ZINF
        LDY     #$23
        LDA     #$00
.ZI1
        STA     INWK,Y
        DEY
        BPL     ZI1

        LDA     #$60
        STA     L0065
        STA     L0069
        ORA     #$80
        STA     L0061
        RTS

.msblob
        LDX     #$04
.ss
        CPX     NOMSL
        BEQ     SAL8

        LDY     #$04
        JSR     MSBAR

        DEX
        BNE     ss

        RTS

.SAL8
        LDY     #$09
        JSR     MSBAR

        DEX
        BNE     SAL8

        RTS

.me2
        LDA     MCH
        JSR     MESS

        LDA     #$00
        STA     DLY
        JMP     me3

.Ze
        JSR     ZINF

        JSR     DORND

        STA     T1
        AND     #$80
        STA     L0055
        TXA
        AND     #$80
        STA     L0058
        LDA     #$20
        STA     L0054
        STA     L0057
        STA     L005A
        TXA
        CMP     #$F5
        ROL     A
        ORA     #$C0
        STA     L0073
.DORND2
        CLC
.DORND
        LDA     RAND
        ROL     A
        TAX
        ADC     L0002
        STA     RAND
        STX     L0002
        LDA     L0001
        TAX
        ADC     L0003
        STA     L0001
        STX     L0003
        RTS

.MTT4
        LSR     A
        STA     L0073
        STA     L0070
        ROL     L0072
        AND     #$1F
        ORA     #$10
        STA     L006E
        LDA     #$06
        JSR     NWSHP

.TT100
        JSR     M%

        DEC     DLY
        BEQ     me2

        BPL     me3

        INC     DLY
.me3
        DEC     MCNT
        BEQ     L3D5F

        JMP     MLOOP

.L3D5F
        JSR     DORND

        CMP     #$23
        BCS     MTT1

        LDA     L0BF6
        CMP     #$03
        BCS     MTT1

        JSR     ZINF

        LDA     #$26
        STA     L005A
        JSR     DORND

        STA     INWK
        STX     L0056
        AND     #$80
        STA     L0055
        TXA
        AND     #$80
        STA     L0058
        ROL     L0054
        ROL     L0054
        JSR     DORND

        BVS     MTT4

        ORA     #$6F
        STA     L0070
        LDA     SSPR
        BNE     MTT1

        TXA
        BCS     MTT2

        AND     #$1F
        ORA     #$10
        STA     L006E
        BCC     MTT3

.MTT2
        ORA     #$7F
        STA     L0071
.MTT3
        JSR     DORND

        CMP     #$05
        LDA     #$09
        BCS     L3DB0

        LDA     #$0A
.L3DB0
        JSR     NWSHP

.MTT1
        LDA     SSPR
        BNE     MLOOP

        JSR     BAD

        ASL     A
        LDX     L0BEF
        BEQ     L3DC4

        ORA     FIST
.L3DC4
        STA     T
        JSR     Ze

        CMP     T
        BCS     L3DD2

        LDA     #$02
        JSR     NWSHP

.L3DD2
        LDA     L0BEF
        BNE     MLOOP

        DEC     EV
        BPL     MLOOP

        INC     EV
        JSR     DORND

        LDY     gov
        BEQ     LABEL_2

        CMP     #$5A
        BCS     MLOOP

        AND     #$07
        CMP     gov
        BCC     MLOOP

.LABEL_2
        JSR     Ze

        CMP     #$C8
        BCS     mt1

        INC     EV
        AND     #$03
        ADC     #$03
        TAY
        TXA
        CMP     #$C8
        ROL     A
        ORA     #$C0
        STA     L0073
        TYA
        JSR     NWSHP

        JMP     MLOOP

.mt1
        AND     #$03
        STA     EV
        STA     XX13
.mt3
        JSR     DORND

        AND     #$03
        ORA     #$01
        JSR     NWSHP

        DEC     XX13
        BPL     mt3

.MLOOP
        LDA     LASCT
        SBC     #$04
        BCS     L3E2E

        LDA     #$00
.L3E2E
        STA     LASCT
        LDX     #$FF
        TXS
        INX
        STX     L0D01
        LDX     GNTMP
        BEQ     EE20

        DEC     GNTMP
.EE20
        JSR     DIALS

        LDA     QQ11
        BEQ     L3E50

        AND     PATG
        LSR     A
        BCS     L3E50

        JSR     L285F

.L3E50
        JSR     TT17

.FRCE
        JSR     TT102

        LDA     QQ12
        BNE     MLOOP

.L3E5A
        JMP     TT100

L3E5C = L3E5A+2
        EQUB    $B1

        EQUB    $91,$92

.TT102
        CMP     #$A6
        BNE     L3E67

        JMP     STATUS

.L3E67
        CMP     #$93
        BNE     L3E6E

        JMP     TT22

.L3E6E
        CMP     #$B4
        BNE     L3E75

        JMP     TT23

.L3E75
        CMP     #$A4
        BNE     TT92

        JSR     TT111

        JMP     TT25

.TT92
        CMP     #$A7
        BNE     L3E86

        JMP     TT213

.L3E86
        CMP     #$95
        BNE     L3E8D

        JMP     TT167

.L3E8D
        CMP     #$B0
        BNE     fvw

        JMP     TT110

.fvw
        BIT     QQ12
        BPL     INSP

        CMP     #$92
        BNE     L3E9F

        JMP     EQSHP

.L3E9F
        CMP     #$B1
        BNE     L3EA6

        JMP     TT219

.L3EA6
        CMP     #$48
        BNE     L3EAD

        JMP     L40EF

.L3EAD
        CMP     #$91
        BNE     LABEL_3

        JMP     TT208

.INSP
        STX     T
        LDX     #$03
.L3EB8
        CMP     L3E5C,X
        BNE     L3EC0

        JMP     LOOK1

.L3EC0
        DEX
        BNE     L3EB8

        LDX     T
.LABEL_3
        CMP     #$54
        BNE     L3ECC

        JMP     hyp

.L3ECC
        CMP     #$32
        BEQ     T95

        STA     T1
        LDA     QQ11
        AND     #$C0
        BEQ     TT107

        LDA     L002F
        BNE     TT107

        LDA     T1
        CMP     #$36
        BNE     ee2

        JSR     TT103

        JSR     ping

        JSR     TT103

.ee2
        JSR     TT16

.TT107
        LDA     L002F
        BEQ     t95_lc

        DEC     QQ22
        BNE     t95_lc

        LDX     L002F
        DEX
        JSR     L304B

        LDA     #$05
        STA     QQ22
        LDX     L002F
        JSR     L304B

        DEC     L002F
        BNE     t95_lc

        JMP     TT18

.t95_lc
        RTS

.T95
        LDA     QQ11
        AND     #$C0
        BEQ     t95_lc

        JSR     hm

        STA     QQ17
        JSR     cpl

        LDA     #$80
        STA     QQ17
        LDA     #$01
        STA     XC
        INC     YC
        JMP     TT146

.BAD
        LDA     L031A
        CLC
        ADC     L031D
        ASL     A
        ADC     L0321
        RTS

.FAROF
        LDA     #$E0
.FAROF2
        CMP     L0054
        BCC     MA34

        CMP     L0057
        BCC     MA34

        CMP     L005A
.MA34
        RTS

.MAS4
        ORA     L0054
        ORA     L0057
        ORA     L005A
        RTS

.DEATH
        JSR     EXNO3

        JSR     RES2

        ASL     DELTA
        ASL     DELTA
        JSR     TT66

        LDX     #$32
        STX     LASCT
        JSR     BOX

        JSR     nWq

        LDA     #$0C
        STA     YC
        STA     XC
        LDA     #$92
        STA     MCNT
        JSR     ex

.D1
        JSR     Ze

        LDA     #$20
        STA     INWK
        LDY     #$00
        STY     QQ11
        STY     L0054
        STY     L0057
        STY     L005A
        STY     L0073
        DEY
        EOR     #$2A
        STA     L0056
        ORA     #$50
        STA     L0059
        TXA
        AND     #$8F
        STA     L0070
        ROR     A
        AND     #$87
        STA     L0071
        PHP
        LDX     #$0A
        JSR     fq1

        PLP
        LDA     #$00
        ROR     A
        LDY     #$1F
        STA     (INF),Y
        LDA     L0BE3
        BEQ     D1

        JSR     U%

        STA     DELTA
.D2
        JSR     M%

        DEC     LASCT
        BNE     D2

.DEATH2
        JSR     RES2

        LDX     #$FF
        TXS
        LDX     #$03
        STX     XC
        JSR     FX200

        LDX     #$06
        LDA     #$80
        JSR     TITLE

        CMP     #$44
        BNE     QU5

        JSR     GTNME

        JSR     LOD

        JSR     TRNME

        JSR     TTX66

.QU5
        LDX     #$4B
.QUL1
        LDA     L15A4,X
        STA     L02FF,X
        DEX
        BNE     QUL1

        STX     QQ11
.L3FE4
        JSR     CHECK

        CMP     CHK
        BNE     L3FE4

        EOR     #$A9
        TAX
        LDA     COK
        CPX     CHK2
        BEQ     tZ

        ORA     #$80
.tZ
        ORA     #$08
        STA     COK
        JSR     msblob

        LDA     #$93
        LDX     #$03
        JSR     TITLE

        JSR     ping

        JSR     hyp1

.BAY
        LDA     #$FF
        STA     QQ12
        LDA     #$A6
        JMP     FRCE

.TITLE
        PHA
        STX     TYPE
        JSR     RESET

        LDA     #$01
        JSR     TT66

        DEC     QQ11
        LDA     #$60
        STA     L0061
        STA     L005A
        LDX     #$7F
        STX     L0070
        STX     L0071
        INX
        STX     QQ17
        LDA     TYPE
        JSR     NWSHP

        LDY     #$06
        STY     XC
        LDA     #$1E
        JSR     plf

        LDY     #$06
        STY     XC
        INC     YC
        LDA     PATG
        BEQ     awe

        LDA     #$FE
        JSR     TT27

.awe
        JSR     CLYNS

        STY     DELTA
        STY     JSTK
        PLA
        JSR     ex

        LDA     #$94
        LDX     #$07
        STX     XC
        JSR     ex

.TLL2
        LDA     L005A
        CMP     #$01
        BEQ     TL1

        DEC     L005A
.TL1
        JSR     MVEIT

        LDA     #$80
        STA     L0059
        ASL     A
        STA     INWK
        STA     L0056
        JSR     LL9

        DEC     MCNT
        JSR     L421E

        BEQ     TLL2

        RTS

.CHECK
        LDX     #$49
        CLC
        TXA
.QUL2
        ADC     L15A4,X
        EOR     L15A5,X
        DEX
        BNE     QUL2

        RTS

.TRNME
        LDX     #$07
.GTL1
        LDA     INWK,X
        STA     L159D,X
        DEX
        BPL     GTL1

.TR1
        LDX     #$07
.GTL2
        LDA     L159D,X
        STA     INWK,X
        DEX
        BPL     GTL2

        RTS

.GTNME
        LDA     #$01
        JSR     TT66

        LDA     #$7B
        JSR     TT27

        JSR     L2862

        LDA     #$0F
        TAX
        JSR     OSBYTE

        LDX     #$D2
        LDY     #$40
        LDA     #$00
        DEC     L0D01
        JSR     OSWORD

        INC     L0D01
        BCS     TR1

        TYA
        BEQ     TR1

        JMP     TT67

        EQUB    $53

        EQUB    $00,$07,$21,$7A

.ZERO
        LDX     #$0B
        JSR     L40E1

        DEX
        JSR     L40E1

        DEX
.L40E1
        LDY     #$00
        STY     SC
        STX     SCH
.ZES2
        LDA     #$00
.L40E9
        STA     (SC),Y
        INY
        BNE     L40E9

        RTS

.L40EF
        JSR     GTNME

        JSR     TRNME

        JSR     ZERO

        LSR     L0349
        LDX     #$4B
.L40FD
        LDA     TP,X
        STA     K%,X
        STA     L15A5,X
        DEX
        BPL     L40FD

        JSR     CHECK

        STA     CHK
        PHA
        ORA     #$80
        STA     K
        EOR     COK
        STA     L003F
        EOR     L030B
        STA     L003E
        EOR     #$5A
        EOR     L0348
        STA     L0040
        JSR     BPRNT

        JSR     TT67

        JSR     TT67

        PLA
        STA     L094B
        EOR     #$A9
        STA     CHK2
        STA     L094A
        LDY     #$09
        STY     L0A0B
        INY
        STY     L0A0F
        LDA     #$00
        JSR     L414B

        JMP     BAY

.L414B
        LDX     #$53
        STX     L0A00
        LDX     #$FF
        STX     L0D01
        INX
        JSR     OSFILE

        INC     L0D01
        RTS

.LOD
        LDX     #$02
        JSR     FX200

        JSR     ZERO

        LDY     #$09
        STY     L0A03
        INC     L0A0B
        INY
        LDA     #$FF
        JSR     L414B

        LDA     K%
        BMI     L418E

        LDX     #$4B
.L417A
        LDA     K%,X
        STA     L15A5,X
        DEX
        BPL     L417A

        LDX     #$03
.FX200
        LDY     #$00
        LDA     #$C8
        JMP     OSBYTE

        RTS

.SPS1
        LDX     #$00
L418E = SPS1+1
        JSR     SPS3

        LDX     #$03
        JSR     SPS3

        LDX     #$06
        JSR     SPS3

.TAS2
        LDA     K3
        ORA     L00D5
        ORA     L00D8
        ORA     #$01
        STA     L00DB
        LDA     L00D3
        ORA     L00D6
        ORA     L00D9
.L41AC
        ASL     L00DB
        ROL     A
        BCS     L41BF

        ASL     K3
        ROL     L00D3
        ASL     L00D5
        ROL     L00D6
        ASL     L00D8
        ROL     L00D9
        BCC     L41AC

.L41BF
        LDA     L00D3
        LSR     A
        ORA     L00D4
        STA     XX15
        LDA     L00D6
        LSR     A
        ORA     L00D7
        STA     Y1
        LDA     L00D9
        LSR     A
        ORA     L00DA
        STA     X2
.L41D4
        LDA     XX15
        JSR     SQUA

        STA     R
        LDA     P
        STA     Q
        LDA     Y1
        JSR     SQUA

        STA     T
        LDA     P
        ADC     Q
        STA     Q
        LDA     T
        ADC     R
        STA     R
        LDA     X2
        JSR     SQUA

        STA     T
        LDA     P
        ADC     Q
        STA     Q
        LDA     T
        ADC     R
        STA     R
        JSR     LL5

        LDA     XX15
        JSR     L453C

        STA     XX15
        LDA     Y1
        JSR     L453C

        STA     Y1
        LDA     X2
        JSR     L453C

        STA     X2
        RTS

.L421E
        LDX     #$10
.L4220
        JSR     CTRL

        BMI     L4229

        INX
        BPL     L4220

        TXA
.L4229
        EOR     #$80
        TAY
        JSR     L42D6

        PHP
        TYA
        PLP
        BPL     L4236

        ORA     #$80
.L4236
        TAX
.L4237
        RTS

.ECMOF
        LDA     #$00
        STA     ECMA
        STA     ECMP
        JSR     ECBLB

        LDA     #$48
        BNE     NOISE

.EXNO3
        LDA     #$18
        BNE     NOISE

.SFRMIS
        LDX     #$08
        JSR     L2160

        BCC     L4237

        LDA     #$78
        JSR     MESS

        LDA     #$30
        BNE     NOISE

.EXNO2
        INC     TALLY
        BNE     L4267

        INC     L0348
        LDA     #$65
        JSR     MESS

.L4267
        LDX     #$07
.EXNO
        STX     T
        LDA     #$18
        JSR     L42AA

        LDA     L005A
        LSR     A
        LSR     A
        AND     T
        ORA     #$F1
        STA     L000B
        JSR     L4285

        LDA     #$10
.L427F
        BIT     HITCH
BEEP = L427F+1
.NOISE
        JSR     L42AA

.L4285
        LDX     L0D1D
        BNE     L4237

        LDA     L0009
        AND     #$01
        TAX
        LDY     L0011
        LDA     L3C64,Y
        CMP     L0BFB,X
        BCC     L4237

        STA     L0BFB,X
        AND     #$0F
        STA     L0BFD,X
        LDX     #$09
        LDY     #$00
        LDA     #$07
        JMP     OSWORD

.L42AA
        STA     L0011
        LSR     A
        ADC     #$03
        TAY
        LDX     #$07
.L42B2
        LDA     #$00
        STA     L0009,X
        DEX
        LDA     L3C3C,Y
        STA     L0009,X
        DEY
        DEX
        BPL     L42B2

.L42C0
        RTS

        EQUB    $E8

        EQUB    $E2,$E6,$E7,$C2,$D1,$C1,$17,$70
        EQUB    $23,$35,$65,$22,$45,$52

.L42D0
        SEC
        CLV
        SEI
        JMP     (L0D04)

.L42D6
        LDX     #$40
.CTRL
        TYA
        PHA
        TXA
        PHA
        ORA     #$80
        TAX
        JSR     L42D0

        CLI
        TAX
        PLA
        AND     #$7F
        CPX     #$80
        BCC     L42ED

        ORA     #$80
.L42ED
        TAX
        PLA
        TAY
        TXA
        RTS

        LDA     #$80
        JSR     OSBYTE

        TYA
        EOR     L0D23
        RTS

.L42FC
        STY     T
        CPX     T
        BNE     L4312

        LDA     tek,X
        EOR     #$FF
        STA     tek,X
        JSR     BELL

        JSR     DELAY

        LDY     T
.L4312
        RTS

.U%
        LDA     #$00
        LDY     #$0F
.L4317
        STA     KL,Y
        DEY
        BNE     L4317

        RTS

.DOKEY
        JSR     U%

        LDY     #$07
.L4323
        LDX     L42C0,Y
        JSR     CTRL

        BPL     L432F

        LDX     #$FF
        STX     KL,Y
.L432F
        DEY
        BNE     L4323

        LDX     JSTX
        LDA     #$07
        LDY     L0044
        BEQ     L433D

        JSR     BUMP2

.L433D
        LDY     L0045
        BEQ     L4344

        JSR     REDU2

.L4344
        STX     JSTX
        ASL     A
        LDX     JSTY
        LDY     L0046
        BEQ     L4350

        JSR     REDU2

.L4350
        LDY     L0047
        BEQ     L4357

        JSR     BUMP2

.L4357
        STX     JSTY
        JSR     L421E

        STX     KL
        CPX     #$38
        BNE     L438D

.L4362
        JSR     L2862

        JSR     L421E

        CPX     #$51
        BNE     L4371

        LDA     #$00
        STA     L0D1D
.L4371
        LDY     #$40
.L4373
        JSR     L42FC

        INY
        CPY     #$47
        BNE     L4373

        CPX     #$10
        BNE     L4382

        STX     L0D1D
.L4382
        CPX     #$70
        BNE     L4389

        JMP     DEATH2

.L4389
        CPX     #$59
        BNE     L4362

.L438D
        LDA     QQ11
        BNE     L43A4

        LDY     #$0F
        LDA     #$FF
.L4395
        LDX     L42C0,Y
        CPX     KL
        BNE     L439F

        STA     KL,Y
.L439F
        DEY
        CPY     #$07
        BNE     L4395

.L43A4
        RTS

.TT217
        STY     YSAV
        DEC     L0D01
        JSR     OSRDCH

        INC     L0D01
        TAX
.L43B1
        RTS

.L43B2
        STX     DLY
        PHA
        LDA     MCH
        JSR     L43DA

        PLA
.L43BD
        BIT     L6CA9
L43BE = L43BD+1
.L43C0
        BIT     L6FA9
L43C1 = L43C0+1
.MESS
        LDX     #$00
        STX     QQ17
        LDY     #$09
        STY     XC
        LDY     #$16
        STY     YC
        CPX     DLY
        BNE     L43B2

        STY     DLY
        STA     MCH
.L43DA
        JSR     TT27

        LSR     de
        BCC     L43B1

        LDA     #$FD
        JMP     TT27

.OUCH
        JSR     DORND

        BMI     L43B1

        CPX     #$16
        BCS     L43B1

        LDA     QQ20,X
        BEQ     L43B1

        LDA     DLY
        BNE     L43B1

        LDY     #$03
        STY     de
        STA     QQ20,X
        CPX     #$11
        BCS     L440B

        TXA
        ADC     #$D0
        BNE     MESS

.L440B
        BEQ     L43BE

        CPX     #$12
        BEQ     L43C1

        TXA
        ADC     #$5D
        BNE     MESS

.L4416
        EQUB    $41

.L4417
        EQUB    $4C,$4C,$45,$58,$45,$47,$45,$5A
        EQUB    $41,$43,$45,$42,$49,$53,$4F,$55
        EQUB    $53,$45,$53,$41,$52,$4D,$41,$49
        EQUB    $4E,$44,$49,$52,$45,$41,$3F,$45
        EQUB    $52,$41,$54,$45,$4E,$42,$45,$52
        EQUB    $41,$4C,$41,$56,$45,$54,$49,$45
        EQUB    $44,$4F,$52,$51,$55,$41,$4E,$54
        EQUB    $45,$49,$53,$52,$49,$4F,$4E

.QQ23
        EQUB    $13

.L4457
        EQUB    $82

.L4458
        EQUB    $06

.L4459
        EQUB    $01,$14,$81,$0A,$03,$41,$83,$02
        EQUB    $07,$28,$85,$E2,$1F,$53,$85,$FB
        EQUB    $0F,$C4,$08,$36,$03,$EB,$1D,$08
        EQUB    $78,$9A,$0E,$38,$03,$75,$06,$28
        EQUB    $07,$4E,$01,$11,$1F,$7C,$0D,$1D
        EQUB    $07,$B0,$89,$DC,$3F,$20,$81,$35
        EQUB    $03,$61,$A1,$42,$07,$AB,$A2,$37
        EQUB    $1F,$2D,$C1,$FA,$0F,$35,$0F,$C0
        EQUB    $07

.L449A
        TYA
        LDY     #$02
        JSR     L4569

        STA     L0067
        JMP     L44E2

.L44A5
        TAX
        LDA     Y1
        AND     #$60
        BEQ     L449A

        LDA     #$02
        JSR     L4569

        STA     L0065
        JMP     L44E2

.TIDY
        LDA     L005D
        STA     XX15
        LDA     L005F
        STA     Y1
        LDA     L0061
        STA     X2
        JSR     L41D4

        LDA     XX15
        STA     L005D
        LDA     Y1
        STA     L005F
        LDA     X2
        STA     L0061
        LDY     #$04
        LDA     XX15
        AND     #$60
        BEQ     L44A5

        LDX     #$02
        LDA     #$00
        JSR     L4569

        STA     L0063
.L44E2
        LDA     L0063
        STA     XX15
        LDA     L0065
        STA     Y1
        LDA     L0067
        STA     X2
        JSR     L41D4

        LDA     XX15
        STA     L0063
        LDA     Y1
        STA     L0065
        LDA     X2
        STA     L0067
        LDA     L005F
        STA     Q
        LDA     L0067
        JSR     MULT12

        LDX     L0061
        LDA     L0065
        JSR     TIS1

        EOR     #$80
        STA     L0069
        LDA     L0063
        JSR     MULT12

        LDX     L005D
        LDA     L0067
        JSR     TIS1

        EOR     #$80
        STA     L006B
        LDA     L0065
        JSR     MULT12

        LDX     L005F
        LDA     L0063
        JSR     TIS1

        EOR     #$80
        STA     L006D
        LDA     #$00
        LDX     #$0E
.L4535
        STA     L005C,X
        DEX
        DEX
        BPL     L4535

        RTS

.L453C
        TAY
        AND     #$7F
        CMP     Q
        BCS     L4563

        LDX     #$FE
        STX     T
.L4547
        ASL     A
        CMP     Q
        BCC     L454E

        SBC     Q
.L454E
        ROL     T
        BCS     L4547

        LDA     T
        LSR     A
        LSR     A
        STA     T
        LSR     A
        ADC     T
        STA     T
        TYA
        AND     #$80
        ORA     T
        RTS

.L4563
        TYA
        AND     #$80
        ORA     #$60
        RTS

.L4569
        STA     L001D
        LDA     L005D,X
        STA     Q
        LDA     L0063,X
        JSR     MULT12

        LDX     L005D,Y
        STX     Q
        LDA     L0063,Y
        JSR     MAD

        STX     P
        LDY     L001D
        LDX     L005D,Y
        STX     Q
        EOR     #$80
        STA     L001C
        EOR     Q
        AND     #$80
        STA     T
        LDA     #$00
        LDX     #$10
        ASL     P
        ROL     L001C
        ASL     Q
        LSR     Q
.L459C
        ROL     A
        CMP     Q
        BCC     L45A3

        SBC     Q
.L45A3
        ROL     P
        ROL     L001C
        DEX
        BNE     L459C

        LDA     P
        ORA     T
        RTS

.L45AF
        JSR     L4717

        JSR     PROJ

        ORA     L00D3
        BNE     L45DA

        LDA     K4
        CMP     #$BE
        BCS     L45DA

        LDY     #$02
        JSR     L45E1

        LDY     #$06
        LDA     K4
        ADC     #$01
        JSR     L45E1

        LDA     #$08
        ORA     L0072
        STA     L0072
        LDA     #$08
        JMP     L4C81

.L45D8
        PLA
        PLA
.L45DA
        LDA     #$F7
        AND     L0072
        STA     L0072
        RTS

.L45E1
        STA     (XX19),Y
        INY
        INY
        STA     (XX19),Y
        LDA     K3
        DEY
        STA     (XX19),Y
        ADC     #$03
        BCS     L45D8

        DEY
        DEY
        STA     (XX19),Y
        RTS

.LL5
        LDY     R
        LDA     Q
        STA     S
        LDX     #$00
        STX     Q
        LDA     #$08
        STA     T
.L4603
        CPX     Q
        BCC     L4615

        BNE     L460D

        CPY     #$40
        BCC     L4615

.L460D
        TYA
        SBC     #$40
        TAY
        TXA
        SBC     Q
        TAX
.L4615
        ROL     Q
        ASL     S
        TYA
        ROL     A
        TAY
        TXA
        ROL     A
        TAX
        ASL     S
        TYA
        ROL     A
        TAY
        TXA
        ROL     A
        TAX
        DEC     T
        BNE     L4603

        RTS

.LL28
        CMP     Q
        BCS     L464A

.L4630
        LDX     #$FE
        STX     R
.LL31
        ASL     A
        BCS     L4642

        CMP     Q
        BCC     L463D

        SBC     Q
.L463D
        ROL     R
        BCS     LL31

        RTS

.L4642
        SBC     Q
        SEC
        ROL     R
        BCS     LL31

        RTS

.L464A
        LDA     #$FF
        STA     R
        RTS

.L464F
        EOR     S
        BMI     L4659

        LDA     Q
        CLC
        ADC     R
        RTS

.L4659
        LDA     R
        SEC
        SBC     Q
        BCC     L4662

        CLC
        RTS

.L4662
        PHA
        LDA     S
        EOR     #$80
        STA     S
        PLA
        EOR     #$FF
        ADC     #$01
        RTS

.L466F
        LDX     #$00
        LDY     #$00
.L4673
        LDA     XX15
        STA     Q
        LDA     L0009,X
        JSR     FMLTU

        STA     T
        LDA     Y1
        EOR     L000A,X
        STA     S
        LDA     X2
        STA     Q
        LDA     L000B,X
        JSR     FMLTU

        STA     Q
        LDA     T
        STA     R
        LDA     Y2
        EOR     L000C,X
        JSR     L464F

        STA     T
        LDA     L0035
        STA     Q
        LDA     L000D,X
        JSR     FMLTU

        STA     Q
        LDA     T
        STA     R
        LDA     L0036
        EOR     L000E,X
        JSR     L464F

        STA     XX12,Y
        LDA     S
        STA     L0038,Y
        INY
        INY
        TXA
        CLC
        ADC     #$06
        TAX
        CMP     #$11
        BCC     L4673

        RTS

.L46C6
        JMP     L39AE

.LL9
        LDA     TYPE
        BMI     L46C6

        LDA     #$1F
        STA     XX4
        LDA     #$20
        BIT     L0072
        BNE     L4704

        BPL     L4704

        ORA     L0072
        AND     #$3F
        STA     L0072
        LDA     #$00
        LDY     #$1C
        STA     (INF),Y
        LDY     #$1E
        STA     (INF),Y
        JSR     L4717

        LDY     #$01
        LDA     #$12
        STA     (XX19),Y
        LDY     #$07
        LDA     (XX0),Y
        LDY     #$02
        STA     (XX19),Y
.L46FA
        INY
        JSR     DORND

        STA     (XX19),Y
        CPY     #$06
        BNE     L46FA

.L4704
        LDA     L005B
        BPL     L4725

.L4708
        LDA     L0072
        AND     #$20
        BEQ     L4717

        LDA     L0072
        AND     #$F7
        STA     L0072
        JMP     DOEXP

.L4717
        LDA     #$08
        BIT     L0072
        BEQ     L4724

        EOR     L0072
        STA     L0072
        JMP     L4C85

.L4724
        RTS

.L4725
        LDA     L005A
        CMP     #$C0
        BCS     L4708

        LDA     INWK
        CMP     L0059
        LDA     L0054
        SBC     L005A
        BCS     L4708

        LDA     L0056
        CMP     L0059
        LDA     L0057
        SBC     L005A
        BCS     L4708

        LDY     #$06
        LDA     (XX0),Y
        TAX
        LDA     #$FF
        STA     XX3,X
        STA     L0101,X
        LDA     L0059
        STA     T
        LDA     L005A
        LSR     A
        ROR     T
        LSR     A
        ROR     T
        LSR     A
        ROR     T
        LSR     A
        BNE     L4768

        LDA     T
        ROR     A
        LSR     A
        LSR     A
        LSR     A
        STA     XX4
        BPL     L4779

.L4768
        LDY     #$0D
        LDA     (XX0),Y
        CMP     L005A
        BCS     L4779

        LDA     #$20
        AND     L0072
        BNE     L4779

        JMP     L45AF

.L4779
        LDX     #$05
.L477B
        LDA     L0068,X
        STA     L0009,X
        LDA     L0062,X
        STA     L000F,X
        LDA     L005C,X
        STA     L0015,X
        DEX
        BPL     L477B

        LDA     #$C5
        STA     Q
        LDY     #$10
.L4790
        LDA     L0009,Y
        ASL     A
        LDA     L000A,Y
        ROL     A
        JSR     LL28

        LDX     R
        STX     L0009,Y
        DEY
        DEY
        BPL     L4790

        LDX     #$08
.L47A5
        LDA     INWK,X
        STA     QQ17,X
        DEX
        BPL     L47A5

        LDA     #$FF
        STA     L00E1
        LDY     #$0C
        LDA     L0072
        AND     #$20
        BEQ     L47CA

        LDA     (XX0),Y
        LSR     A
        LSR     A
        TAX
        LDA     #$FF
.L47BF
        STA     K3,X
        DEX
        BPL     L47BF

        INX
        STX     XX4
.L47C7
        JMP     L493D

.L47CA
        LDA     (XX0),Y
        BEQ     L47C7

        STA     XX20
        LDY     #$12
        LDA     (XX0),Y
        TAX
        LDA     L0085
        TAY
        BEQ     L47E9

.L47DA
        INX
        LSR     K6
        ROR     L0081
        LSR     QQ19
        ROR     QQ17
        LSR     A
        ROR     L0084
        TAY
        BNE     L47DA

.L47E9
        STX     XX17
        LDA     L0086
        STA     L0036
        LDA     QQ17
        STA     XX15
        LDA     L0080
        STA     Y1
        LDA     L0081
        STA     X2
        LDA     L0083
        STA     Y2
        LDA     L0084
        STA     L0035
        JSR     L466F

        LDA     XX12
        STA     QQ17
        LDA     L0038
        STA     L0080
        LDA     L0039
        STA     L0081
        LDA     L003A
        STA     L0083
        LDA     L003B
        STA     L0084
        LDA     L003C
        STA     L0086
        LDY     #$04
        LDA     (XX0),Y
        CLC
        ADC     XX0
        STA     V
        LDY     #$11
        LDA     (XX0),Y
        ADC     L001F
        STA     L0023
        LDY     #$00
.L4831
        LDA     (V),Y
        STA     L0038
        AND     #$1F
        CMP     XX4
        BCS     L484A

        TYA
        LSR     A
        LSR     A
        TAX
        LDA     #$FF
        STA     K3,X
        TYA
        ADC     #$04
        TAY
        JMP     L4936

.L484A
        LDA     L0038
        ASL     A
        STA     L003A
        ASL     A
        STA     L003C
        INY
        LDA     (V),Y
        STA     XX12
        INY
        LDA     (V),Y
        STA     L0039
        INY
        LDA     (V),Y
        STA     L003B
        LDX     XX17
        CPX     #$04
        BCC     L488A

        LDA     QQ17
        STA     XX15
        LDA     L0080
        STA     Y1
        LDA     L0081
        STA     X2
        LDA     L0083
        STA     Y2
        LDA     L0084
        STA     L0035
        LDA     L0086
        STA     L0036
        JMP     L48E8

.L4882
        LSR     QQ17
        LSR     L0084
        LSR     L0081
        LDX     #$01
.L488A
        LDA     XX12
        STA     XX15
        LDA     L0039
        STA     X2
        LDA     L003B
        DEX
        BMI     L489F

.L4897
        LSR     XX15
        LSR     X2
        LSR     A
        DEX
        BPL     L4897

.L489F
        STA     R
        LDA     L003C
        STA     S
        LDA     L0084
        STA     Q
        LDA     L0086
        JSR     L464F

        BCS     L4882

        STA     L0035
        LDA     S
        STA     L0036
        LDA     XX15
        STA     R
        LDA     L0038
        STA     S
        LDA     QQ17
        STA     Q
        LDA     L0080
        JSR     L464F

        BCS     L4882

        STA     XX15
        LDA     S
        STA     Y1
        LDA     X2
        STA     R
        LDA     L003A
        STA     S
        LDA     L0081
        STA     Q
        LDA     L0083
        JSR     L464F

        BCS     L4882

        STA     X2
        LDA     S
        STA     Y2
.L48E8
        LDA     XX12
        STA     Q
        LDA     XX15
        JSR     FMLTU

        STA     T
        LDA     L0038
        EOR     Y1
        STA     S
        LDA     L0039
        STA     Q
        LDA     X2
        JSR     FMLTU

        STA     Q
        LDA     T
        STA     R
        LDA     L003A
        EOR     Y2
        JSR     L464F

        STA     T
        LDA     L003B
        STA     Q
        LDA     L0035
        JSR     FMLTU

        STA     Q
        LDA     T
        STA     R
        LDA     L0036
        EOR     L003C
        JSR     L464F

        PHA
        TYA
        LSR     A
        LSR     A
        TAX
        PLA
        BIT     S
        BMI     L4933

        LDA     #$00
.L4933
        STA     K3,X
        INY
.L4936
        CPY     XX20
        BCS     L493D

        JMP     L4831

.L493D
        LDY     L000B
        LDX     L000C
        LDA     L000F
        STA     L000B
        LDA     L0010
        STA     L000C
        STY     L000F
        STX     L0010
        LDY     L000D
        LDX     L000E
        LDA     L0015
        STA     L000D
        LDA     L0016
        STA     L000E
        STY     L0015
        STX     L0016
        LDY     L0013
        LDX     L0014
        LDA     L0017
        STA     L0013
        LDA     L0018
        STA     L0014
        STY     L0017
        STX     L0018
        LDY     #$08
        LDA     (XX0),Y
        STA     XX20
        LDA     XX0
        CLC
        ADC     #$14
        STA     V
        LDA     L001F
        ADC     #$00
        STA     L0023
        LDY     #$00
        STY     CNT
.L4984
        STY     XX17
        LDA     (V),Y
        STA     XX15
        INY
        LDA     (V),Y
        STA     X2
        INY
        LDA     (V),Y
        STA     L0035
        INY
        LDA     (V),Y
        STA     T
        AND     #$1F
        CMP     XX4
        BCC     L49CD

        INY
        LDA     (V),Y
        STA     P
        AND     #$0F
        TAX
        LDA     K3,X
        BNE     L49D0

        LDA     P
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        TAX
        LDA     K3,X
        BNE     L49D0

        INY
        LDA     (V),Y
        STA     P
        AND     #$0F
        TAX
        LDA     K3,X
        BNE     L49D0

        LDA     P
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        TAX
        LDA     K3,X
        BNE     L49D0

.L49CD
        JMP     L4B45

.L49D0
        LDA     T
        STA     Y1
        ASL     A
        STA     Y2
        ASL     A
        STA     L0036
        JSR     L466F

        LDA     L0055
        STA     X2
        EOR     L0038
        BMI     L49F5

        CLC
        LDA     XX12
        ADC     INWK
        STA     XX15
        LDA     L0054
        ADC     #$00
        STA     Y1
        JMP     L4A18

.L49F5
        LDA     INWK
        SEC
        SBC     XX12
        STA     XX15
        LDA     L0054
        SBC     #$00
        STA     Y1
        BCS     L4A18

        EOR     #$FF
        STA     Y1
        LDA     #$01
        SBC     XX15
        STA     XX15
        BCC     L4A12

        INC     Y1
.L4A12
        LDA     X2
        EOR     #$80
        STA     X2
.L4A18
        LDA     L0058
        STA     L0036
        EOR     L003A
        BMI     L4A30

        CLC
        LDA     L0039
        ADC     L0056
        STA     Y2
        LDA     L0057
        ADC     #$00
        STA     L0035
        JMP     L4A55

.L4A30
        LDA     L0056
        SEC
        SBC     L0039
        STA     Y2
        LDA     L0057
        SBC     #$00
        STA     L0035
        BCS     L4A55

        EOR     #$FF
        STA     L0035
        LDA     Y2
        EOR     #$FF
        ADC     #$01
        STA     Y2
        LDA     L0036
        EOR     #$80
        STA     L0036
        BCC     L4A55

        INC     L0035
.L4A55
        LDA     L003C
        BMI     L4AA3

        LDA     L003B
        CLC
        ADC     L0059
        STA     T
        LDA     L005A
        ADC     #$00
        STA     U
        JMP     L4AC2

.L4A69
        LDX     Q
        BEQ     L4A89

        LDX     #$00
.L4A6F
        LSR     A
        INX
        CMP     Q
        BCS     L4A6F

        STX     S
        JSR     LL28

        LDX     S
        LDA     R
.L4A7E
        ASL     A
        ROL     U
        BMI     L4A89

        DEX
        BNE     L4A7E

        STA     R
        RTS

.L4A89
        LDA     #$32
        STA     R
        STA     U
        RTS

.L4A90
        LDA     #$80
        SEC
        SBC     R
        STA     XX3,X
        INX
        LDA     #$00
        SBC     U
        STA     XX3,X
        JMP     L4B02

.L4AA3
        LDA     L0059
        SEC
        SBC     L003B
        STA     T
        LDA     L005A
        SBC     #$00
        STA     U
        BCC     L4ABA

        BNE     L4AC2

        LDA     T
        CMP     #$04
        BCS     L4AC2

.L4ABA
        LDA     #$00
        STA     U
        LDA     #$04
        STA     T
.L4AC2
        LDA     U
        ORA     Y1
        ORA     L0035
        BEQ     L4AD9

        LSR     Y1
        ROR     XX15
        LSR     L0035
        ROR     Y2
        LSR     U
        ROR     T
        JMP     L4AC2

.L4AD9
        LDA     T
        STA     Q
        LDA     XX15
        CMP     Q
        BCC     L4AE9

        JSR     L4A69

        JMP     L4AEC

.L4AE9
        JSR     LL28

.L4AEC
        LDX     CNT
        LDA     X2
        BMI     L4A90

        LDA     R
        CLC
        ADC     #$80
        STA     XX3,X
        INX
        LDA     U
        ADC     #$00
        STA     XX3,X
.L4B02
        TXA
        PHA
        LDA     #$00
        STA     U
        LDA     T
        STA     Q
        LDA     Y2
        CMP     Q
        BCC     L4B2B

        JSR     L4A69

        JMP     L4B2E

.L4B18
        LDA     #$60
        CLC
        ADC     R
        STA     XX3,X
        INX
        LDA     #$00
        ADC     U
        STA     XX3,X
        JMP     L4B45

.L4B2B
        JSR     LL28

.L4B2E
        PLA
        TAX
        INX
        LDA     L0036
        BMI     L4B18

        LDA     #$60
        SEC
        SBC     R
        STA     XX3,X
        INX
        LDA     #$00
        SBC     U
        STA     XX3,X
.L4B45
        CLC
        LDA     CNT
        ADC     #$04
        STA     CNT
        LDA     XX17
        ADC     #$06
        TAY
        BCS     L4B5A

        CMP     XX20
        BCS     L4B5A

        JMP     L4984

.L4B5A
        LDA     L0072
        AND     #$20
        BEQ     L4B69

        LDA     L0072
        ORA     #$08
        STA     L0072
        JMP     DOEXP

.L4B69
        LDA     #$08
        BIT     L0072
        BEQ     L4B74

        JSR     L4C85

        LDA     #$08
.L4B74
        ORA     L0072
        STA     L0072
        LDY     #$09
        LDA     (XX0),Y
        STA     XX20
        LDY     #$00
        STY     U
        STY     XX17
        INC     U
        BIT     L0072
        BVC     L4BDE

        LDA     L0072
        AND     #$BF
        STA     L0072
        LDY     #$06
        LDA     (XX0),Y
        TAY
        LDX     XX3,Y
        STX     XX15
        INX
        BEQ     L4BDE

        LDX     L0101,Y
        STX     Y1
        INX
        BEQ     L4BDE

        LDX     L0102,Y
        STX     X2
        LDX     L0103,Y
        STX     Y2
        LDA     #$00
        STA     L0035
        STA     L0036
        STA     L0038
        LDA     L0059
        STA     XX12
        LDA     L0055
        BPL     L4BC1

        DEC     L0035
.L4BC1
        JSR     LL145

        BCS     L4BDE

        LDY     U
        LDA     XX15
        STA     (XX19),Y
        INY
        LDA     Y1
        STA     (XX19),Y
        INY
        LDA     X2
        STA     (XX19),Y
        INY
        LDA     Y2
        STA     (XX19),Y
        INY
        STY     U
.L4BDE
        LDY     #$03
        CLC
        LDA     (XX0),Y
        ADC     XX0
        STA     V
        LDY     #$10
        LDA     (XX0),Y
        ADC     L001F
        STA     L0023
        LDY     #$05
        LDA     (XX0),Y
        STA     T1
        LDY     XX17
.L4BF7
        LDA     (V),Y
        CMP     XX4
        BCC     L4C68

        INY
        LDA     (V),Y
        INY
        STA     P
        AND     #$0F
        TAX
        LDA     K3,X
        BNE     L4C15

        LDA     P
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        TAX
        LDA     K3,X
        BEQ     L4C68

.L4C15
        LDA     (V),Y
        TAX
        INY
        LDA     (V),Y
        STA     Q
        LDA     L0101,X
        STA     Y1
        LDA     XX3,X
        STA     XX15
        LDA     L0102,X
        STA     X2
        LDA     L0103,X
        STA     Y2
        LDX     Q
        LDA     XX3,X
        STA     L0035
        LDA     L0103,X
        STA     L0038
        LDA     L0102,X
        STA     XX12
        LDA     L0101,X
        STA     L0036
        JSR     L4DB3

        BCS     L4C68

        LDY     U
        LDA     XX15
        STA     (XX19),Y
        INY
        LDA     Y1
        STA     (XX19),Y
        INY
        LDA     X2
        STA     (XX19),Y
        INY
        LDA     Y2
        STA     (XX19),Y
        INY
        STY     U
        CPY     T1
        BCS     L4C7F

.L4C68
        INC     XX17
        LDY     XX17
        CPY     XX20
        BCS     L4C7F

        LDY     #$00
        LDA     V
        ADC     #$04
        STA     V
        BCC     L4C7C

        INC     L0023
.L4C7C
        JMP     L4BF7

.L4C7F
        LDA     U
.L4C81
        LDY     #$00
        STA     (XX19),Y
.L4C85
        LDY     #$00
        LDA     (XX19),Y
        STA     XX20
        CMP     #$04
        BCC     L4CAB

        INY
.L4C90
        LDA     (XX19),Y
        STA     XX15
        INY
        LDA     (XX19),Y
        STA     Y1
        INY
        LDA     (XX19),Y
        STA     X2
        INY
        LDA     (XX19),Y
        STA     Y2
        JSR     LL30

        INY
        CPY     XX20
        BCC     L4C90

.L4CAB
        RTS

.L4CAC
        LDA     Y1
        BPL     L4CC7

        STA     S
        JSR     L4D26

        TXA
        CLC
        ADC     X2
        STA     X2
        TYA
        ADC     Y2
        STA     Y2
        LDA     #$00
        STA     XX15
        STA     Y1
        TAX
.L4CC7
        BEQ     L4CE2

        STA     S
        DEC     S
        JSR     L4D26

        TXA
        CLC
        ADC     X2
        STA     X2
        TYA
        ADC     Y2
        STA     Y2
        LDX     #$FF
        STX     XX15
        INX
        STX     Y1
.L4CE2
        LDA     Y2
        BPL     L4D00

        STA     S
        LDA     X2
        STA     R
        JSR     L4D55

        TXA
        CLC
        ADC     XX15
        STA     XX15
        TYA
        ADC     Y1
        STA     Y1
        LDA     #$00
        STA     X2
        STA     Y2
.L4D00
        LDA     X2
        SEC
        SBC     #$C0
        STA     R
        LDA     Y2
        SBC     #$00
        STA     S
        BCC     L4D25

        JSR     L4D55

        TXA
        CLC
        ADC     XX15
        STA     XX15
        TYA
        ADC     Y1
        STA     Y1
        LDA     #$BF
        STA     X2
        LDA     #$00
        STA     Y2
.L4D25
        RTS

.L4D26
        LDA     XX15
        STA     R
        JSR     L4D91

        PHA
        LDX     T
        BNE     L4D5D

.L4D32
        LDA     #$00
        TAX
        TAY
        LSR     S
        ROR     R
        ASL     Q
        BCC     L4D47

.L4D3E
        TXA
        CLC
        ADC     R
        TAX
        TYA
        ADC     S
        TAY
.L4D47
        LSR     S
        ROR     R
        ASL     Q
        BCS     L4D3E

        BNE     L4D47

        PLA
        BPL     L4D84

        RTS

.L4D55
        JSR     L4D91

        PHA
        LDX     T
        BNE     L4D32

.L4D5D
        LDA     #$FF
        TAY
        ASL     A
        TAX
.L4D62
        ASL     R
        ROL     S
        LDA     S
        BCS     L4D6E

        CMP     Q
        BCC     L4D79

.L4D6E
        SBC     Q
        STA     S
        LDA     R
        SBC     #$00
        STA     R
        SEC
.L4D79
        TXA
        ROL     A
        TAX
        TYA
        ROL     A
        TAY
        BCS     L4D62

        PLA
        BMI     L4D90

.L4D84
        TXA
        EOR     #$FF
        ADC     #$01
        TAX
        TYA
        EOR     #$FF
        ADC     #$00
        TAY
.L4D90
        RTS

.L4D91
        LDX     L0039
        STX     Q
        LDA     S
        BPL     L4DAA

        LDA     #$00
        SEC
        SBC     R
        STA     R
        LDA     S
        PHA
        EOR     #$FF
        ADC     #$00
        STA     S
        PLA
.L4DAA
        EOR     L003A
        RTS

.LL145
        LDA     #$00
        STA     SWAP
        LDA     L0036
.L4DB3
        LDX     #$BF
        ORA     L0038
        BNE     L4DBF

        CPX     XX12
        BCC     L4DBF

        LDX     #$00
.L4DBF
        STX     XX13
        LDA     Y1
        ORA     Y2
        BNE     L4DE3

        LDA     #$BF
        CMP     X2
        BCC     L4DE3

        LDA     XX13
        BNE     L4DE1

.L4DD1
        LDA     X2
        STA     Y1
        LDA     L0035
        STA     X2
        LDA     XX12
        STA     Y2
        CLC
        RTS

.L4DDF
        SEC
        RTS

.L4DE1
        LSR     XX13
.L4DE3
        LDA     XX13
        BPL     L4E16

        LDA     Y1
        AND     L0036
        BMI     L4DDF

        LDA     Y2
        AND     L0038
        BMI     L4DDF

        LDX     Y1
        DEX
        TXA
        LDX     L0036
        DEX
        STX     L0039
        ORA     L0039
        BPL     L4DDF

        LDA     X2
        CMP     #$C0
        LDA     Y2
        SBC     #$00
        STA     L0039
        LDA     XX12
        CMP     #$C0
        LDA     L0038
        SBC     #$00
        ORA     L0039
        BPL     L4DDF

.L4E16
        TYA
        PHA
        LDA     L0035
        SEC
        SBC     XX15
        STA     L0039
        LDA     L0036
        SBC     Y1
        STA     L003A
        LDA     XX12
        SEC
        SBC     X2
        STA     L003B
        LDA     L0038
        SBC     Y2
        STA     L003C
        EOR     L003A
        STA     S
        LDA     L003C
        BPL     L4E47

        LDA     #$00
        SEC
        SBC     L003B
        STA     L003B
        LDA     #$00
        SBC     L003C
        STA     L003C
.L4E47
        LDA     L003A
        BPL     L4E56

        SEC
        LDA     #$00
        SBC     L0039
        STA     L0039
        LDA     #$00
        SBC     L003A
.L4E56
        TAX
        BNE     L4E5D

        LDX     L003C
        BEQ     L4E67

.L4E5D
        LSR     A
        ROR     L0039
        LSR     L003C
        ROR     L003B
        JMP     L4E56

.L4E67
        STX     T
        LDA     L0039
        CMP     L003B
        BCC     L4E79

        STA     Q
        LDA     L003B
        JSR     LL28

        JMP     L4E84

.L4E79
        LDA     L003B
        STA     Q
        LDA     L0039
        JSR     LL28

        DEC     T
.L4E84
        LDA     R
        STA     L0039
        LDA     S
        STA     L003A
        LDA     XX13
        BEQ     L4E92

        BPL     L4EA5

.L4E92
        JSR     L4CAC

        LDA     XX13
        BPL     L4ECA

        LDA     Y1
        ORA     Y2
        BNE     L4ECF

        LDA     X2
        CMP     #$C0
        BCS     L4ECF

.L4EA5
        LDX     XX15
        LDA     L0035
        STA     XX15
        STX     L0035
        LDA     L0036
        LDX     Y1
        STX     L0036
        STA     Y1
        LDX     X2
        LDA     XX12
        STA     X2
        STX     XX12
        LDA     L0038
        LDX     Y2
        STX     L0038
        STA     Y2
        JSR     L4CAC

        DEC     SWAP
.L4ECA
        PLA
        TAY
        JMP     L4DD1

.L4ECF
        PLA
        TAY
        SEC
.L4ED2
        RTS

.L4ED3
        EQUB    $67

        EQUB    $EA,$4E,$92,$4F,$6C,$50,$9A,$51
        EQUB    $8C,$52,$8C,$52,$14,$54,$30,$55
        EQUB    $2E,$56,$04,$57,$AC,$57,$00,$81
        EQUB    $10,$50,$8C,$3D,$00,$1E,$3C,$0F
        EQUB    $32,$00,$1C,$14,$46,$25,$00,$00
        EQUB    $02,$10,$20,$00,$24,$9F,$10,$54
        EQUB    $20,$00,$24,$1F,$20,$65,$40,$00
        EQUB    $1C,$3F,$32,$66,$40,$00,$1C,$BF
        EQUB    $31,$44,$00,$10,$1C,$3F,$10,$32
        EQUB    $00,$10,$1C,$7F,$43,$65,$0C,$06
        EQUB    $1C,$AF,$33,$33,$0C,$06,$1C,$2F
        EQUB    $33,$33,$0C,$06,$1C,$6C,$33,$33
        EQUB    $0C,$06,$1C,$EC,$33,$33,$1F,$50
        EQUB    $00,$04,$1F,$62,$04,$08,$1F,$20
        EQUB    $04,$10,$1F,$10,$00,$10,$1F,$41
        EQUB    $00,$0C,$1F,$31,$0C,$10,$1F,$32
        EQUB    $08,$10,$1F,$43,$0C,$14,$1F,$63
        EQUB    $08,$14,$1F,$65,$04,$14,$1F,$54
        EQUB    $00,$14,$0F,$33,$18,$1C,$0C,$33
        EQUB    $1C,$20,$0C,$33,$18,$24,$0C,$33
        EQUB    $20,$24,$1F,$00,$20,$08,$9F,$0C
        EQUB    $2F,$06,$1F,$0C,$2F,$06,$3F,$00
        EQUB    $00,$70,$DF,$0C,$2F,$06,$5F,$00
        EQUB    $20,$08,$5F,$0C,$2F,$06,$00,$F9
        EQUB    $15,$6E,$BE,$4D,$00,$2A,$5A,$14
        EQUB    $00,$00,$1C,$17,$78,$20,$00,$00
        EQUB    $01,$11,$00,$00,$48,$1F,$21,$43
        EQUB    $00,$10,$18,$1E,$10,$22,$00,$10
        EQUB    $18,$5E,$43,$55,$30,$00,$18,$3F
        EQUB    $42,$66,$30,$00,$18,$BF,$31,$66
        EQUB    $18,$10,$18,$7E,$54,$66,$18,$10
        EQUB    $18,$FE,$35,$66,$18,$10,$18,$3F
        EQUB    $20,$66,$18,$10,$18,$BF,$10,$66
        EQUB    $20,$00,$18,$B3,$66,$66,$20,$00
        EQUB    $18,$33,$66,$66,$08,$08,$18,$33
        EQUB    $66,$66,$08,$08,$18,$B3,$66,$66
        EQUB    $08,$08,$18,$F2,$66,$66,$08,$08
        EQUB    $18,$72,$66,$66,$1F,$42,$00,$0C
        EQUB    $1E,$21,$00,$04,$1E,$43,$00,$08
        EQUB    $1F,$31,$00,$10,$1E,$20,$04,$1C
        EQUB    $1E,$10,$04,$20,$1E,$54,$08,$14
        EQUB    $1E,$53,$08,$18,$1F,$60,$1C,$20
        EQUB    $1E,$65,$14,$18,$1F,$61,$10,$20
        EQUB    $1E,$63,$10,$18,$1F,$62,$0C,$1C
        EQUB    $1E,$46,$0C,$14,$13,$66,$24,$30
        EQUB    $12,$66,$24,$34,$13,$66,$28,$2C
        EQUB    $12,$66,$28,$38,$10,$66,$2C,$38
        EQUB    $10,$66,$30,$34,$1F,$00,$20,$00
        EQUB    $9F,$16,$21,$0B,$1F,$16,$21,$0B
        EQUB    $DF,$16,$21,$0B,$5F,$16,$21,$0B
        EQUB    $5F,$00,$20,$00,$3F,$00,$00,$30
        EQUB    $01,$24,$13,$AA,$1A,$5D,$00,$22
        EQUB    $96,$1C,$96,$00,$14,$19,$5A,$1E
        EQUB    $00,$01,$02,$12,$00,$00,$40,$1F
        EQUB    $10,$32,$40,$08,$20,$FF,$20,$44
        EQUB    $20,$08,$20,$BE,$21,$44,$20,$08
        EQUB    $20,$3E,$31,$44,$40,$08,$20,$7F
        EQUB    $30,$44,$04,$04,$10,$8E,$11,$11
        EQUB    $04,$04,$10,$0E,$11,$11,$08,$03
        EQUB    $1C,$0D,$11,$11,$08,$03,$1C,$8D
        EQUB    $11,$11,$14,$04,$10,$D4,$00,$00
        EQUB    $14,$04,$10,$54,$00,$00,$18,$07
        EQUB    $14,$F4,$00,$00,$10,$07,$14,$F0
        EQUB    $00,$00,$10,$07,$14,$70,$00,$00
        EQUB    $18,$07,$14,$74,$00,$00,$08,$04
        EQUB    $20,$AD,$44,$44,$08,$04,$20,$2D
        EQUB    $44,$44,$08,$04,$20,$6E,$44,$44
        EQUB    $08,$04,$20,$EE,$44,$44,$20,$04
        EQUB    $20,$A7,$44,$44,$20,$04,$20,$27
        EQUB    $44,$44,$24,$04,$20,$67,$44,$44
        EQUB    $24,$04,$20,$E7,$44,$44,$26,$00
        EQUB    $20,$A5,$44,$44,$26,$00,$20,$25
        EQUB    $44,$44,$1F,$20,$00,$04,$1F,$30
        EQUB    $00,$10,$1F,$40,$04,$10,$1E,$42
        EQUB    $04,$08,$1E,$41,$08,$0C,$1E,$43
        EQUB    $0C,$10,$0E,$11,$14,$18,$0C,$11
        EQUB    $18,$1C,$0D,$11,$1C,$20,$0C,$11
        EQUB    $14,$20,$14,$00,$24,$2C,$10,$00
        EQUB    $24,$30,$10,$00,$28,$34,$14,$00
        EQUB    $28,$38,$0E,$00,$34,$38,$0E,$00
        EQUB    $2C,$30,$0D,$44,$3C,$40,$0E,$44
        EQUB    $44,$48,$0C,$44,$3C,$48,$0C,$44
        EQUB    $40,$44,$07,$44,$50,$54,$05,$44
        EQUB    $50,$60,$05,$44,$54,$60,$07,$44
        EQUB    $4C,$58,$05,$44,$4C,$5C,$05,$44
        EQUB    $58,$5C,$1E,$21,$00,$08,$1E,$31
        EQUB    $00,$0C,$5E,$00,$18,$02,$1E,$00
        EQUB    $18,$02,$9E,$20,$40,$10,$1E,$20
        EQUB    $40,$10,$3E,$00,$00,$7F,$03,$40
        EQUB    $38,$56,$BE,$55,$00,$2E,$42,$1A
        EQUB    $C8,$00,$34,$28,$FA,$14,$00,$00
        EQUB    $00,$1B,$00,$00,$E0,$1F,$10,$32
        EQUB    $00,$30,$30,$1E,$10,$54,$60,$00
        EQUB    $10,$3F,$FF,$FF,$60,$00,$10,$BF
        EQUB    $FF,$FF,$00,$30,$20,$3E,$54,$98
        EQUB    $00,$18,$70,$3F,$89,$CC,$30,$00
        EQUB    $70,$BF,$B8,$CC,$30,$00,$70,$3F
        EQUB    $A9,$CC,$00,$30,$30,$5E,$32,$76
        EQUB    $00,$30,$20,$7E,$76,$BA,$00,$18
        EQUB    $70,$7E,$BA,$CC,$1E,$32,$00,$20
        EQUB    $1F,$20,$00,$0C,$1F,$31,$00,$08
        EQUB    $1E,$10,$00,$04,$1D,$59,$08,$10
        EQUB    $1D,$51,$04,$08,$1D,$37,$08,$20
        EQUB    $1D,$40,$04,$0C,$1D,$62,$0C,$20
        EQUB    $1D,$A7,$08,$24,$1D,$84,$0C,$10
        EQUB    $1D,$B6,$0C,$24,$05,$88,$0C,$14
        EQUB    $05,$BB,$0C,$28,$05,$99,$08,$14
        EQUB    $05,$AA,$08,$28,$1F,$A9,$08,$1C
        EQUB    $1F,$B8,$0C,$18,$1F,$C8,$14,$18
        EQUB    $1F,$C9,$14,$1C,$1D,$AC,$1C,$28
        EQUB    $1D,$CB,$18,$28,$1D,$98,$10,$14
        EQUB    $1D,$BA,$24,$28,$1D,$54,$04,$10
        EQUB    $1D,$76,$20,$24,$9E,$1B,$28,$0B
        EQUB    $1E,$1B,$28,$0B,$DE,$1B,$28,$0B
        EQUB    $5E,$1B,$28,$0B,$9E,$13,$26,$00
        EQUB    $1E,$13,$26,$00,$DE,$13,$26,$00
        EQUB    $5E,$13,$26,$00,$BE,$19,$25,$0B
        EQUB    $3E,$19,$25,$0B,$7E,$19,$25,$0B
        EQUB    $FE,$19,$25,$0B,$3E,$00,$00,$70
        EQUB    $03,$41,$23,$BC,$54,$99,$54,$2A
        EQUB    $A8,$26,$00,$00,$34,$32,$96,$1C
        EQUB    $00,$01,$01,$13,$20,$00,$4C,$1F
        EQUB    $FF,$FF,$20,$00,$4C,$9F,$FF,$FF
        EQUB    $00,$1A,$18,$1F,$FF,$FF,$78,$03
        EQUB    $08,$FF,$73,$AA,$78,$03,$08,$7F
        EQUB    $84,$CC,$58,$10,$28,$BF,$FF,$FF
        EQUB    $58,$10,$28,$3F,$FF,$FF,$80,$08
        EQUB    $28,$7F,$98,$CC,$80,$08,$28,$FF
        EQUB    $97,$AA,$00,$1A,$28,$3F,$65,$99
        EQUB    $20,$18,$28,$FF,$A9,$BB,$20,$18
        EQUB    $28,$7F,$B9,$CC,$24,$08,$28,$B4
        EQUB    $99,$99,$08,$0C,$28,$B4,$99,$99
        EQUB    $08,$0C,$28,$34,$99,$99,$24,$08
        EQUB    $28,$34,$99,$99,$24,$0C,$28,$74
        EQUB    $99,$99,$08,$10,$28,$74,$99,$99
        EQUB    $08,$10,$28,$F4,$99,$99,$24,$0C
        EQUB    $28,$F4,$99,$99,$00,$00,$4C,$06
        EQUB    $B0,$BB,$00,$00,$5A,$1F,$B0,$BB
        EQUB    $50,$06,$28,$E8,$99,$99,$50,$06
        EQUB    $28,$A8,$99,$99,$58,$00,$28,$A6
        EQUB    $99,$99,$50,$06,$28,$28,$99,$99
        EQUB    $58,$00,$28,$26,$99,$99,$50,$06
        EQUB    $28,$68,$99,$99,$1F,$B0,$00,$04
        EQUB    $1F,$C4,$00,$10,$1F,$A3,$04,$0C
        EQUB    $1F,$A7,$0C,$20,$1F,$C8,$10,$1C
        EQUB    $1F,$98,$18,$1C,$1F,$96,$18,$24
        EQUB    $1F,$95,$14,$24,$1F,$97,$14,$20
        EQUB    $1F,$51,$08,$14,$1F,$62,$08,$18
        EQUB    $1F,$73,$0C,$14,$1F,$84,$10,$18
        EQUB    $1F,$10,$04,$08,$1F,$20,$00,$08
        EQUB    $1F,$A9,$20,$28,$1F,$B9,$28,$2C
        EQUB    $1F,$C9,$1C,$2C,$1F,$BA,$04,$28
        EQUB    $1F,$CB,$00,$2C,$1D,$31,$04,$14
        EQUB    $1D,$42,$00,$18,$06,$B0,$50,$54
        EQUB    $14,$99,$30,$34,$14,$99,$48,$4C
        EQUB    $14,$99,$38,$3C,$14,$99,$40,$44
        EQUB    $13,$99,$3C,$40,$11,$99,$38,$44
        EQUB    $13,$99,$34,$48,$13,$99,$30,$4C
        EQUB    $1E,$65,$08,$24,$06,$99,$58,$60
        EQUB    $06,$99,$5C,$60,$08,$99,$58,$5C
        EQUB    $06,$99,$64,$68,$06,$99,$68,$6C
        EQUB    $08,$99,$64,$6C,$1F,$00,$3E,$1F
        EQUB    $9F,$12,$37,$10,$1F,$12,$37,$10
        EQUB    $9F,$10,$34,$0E,$1F,$10,$34,$0E
        EQUB    $9F,$0E,$2F,$00,$1F,$0E,$2F,$00
        EQUB    $9F,$3D,$66,$00,$1F,$3D,$66,$00
        EQUB    $3F,$00,$00,$50,$DF,$07,$2A,$09
        EQUB    $5F,$00,$1E,$06,$5F,$07,$2A,$09
        EQUB    $00,$00,$64,$74,$E4,$55,$00,$36
        EQUB    $60,$1C,$00,$00,$38,$78,$F0,$00
        EQUB    $00,$00,$00,$06,$A0,$00,$A0,$1F
        EQUB    $10,$62,$00,$A0,$A0,$1F,$20,$83
        EQUB    $A0,$00,$A0,$9F,$30,$74,$00,$A0
        EQUB    $A0,$5F,$10,$54,$A0,$A0,$00,$5F
        EQUB    $51,$A6,$A0,$A0,$00,$1F,$62,$B8
        EQUB    $A0,$A0,$00,$9F,$73,$C8,$A0,$A0
        EQUB    $00,$DF,$54,$97,$A0,$00,$A0,$3F
        EQUB    $A6,$DB,$00,$A0,$A0,$3F,$B8,$DC
        EQUB    $A0,$00,$A0,$BF,$97,$DC,$00,$A0
        EQUB    $A0,$7F,$95,$DA,$0A,$1E,$A0,$5E
        EQUB    $00,$00,$0A,$1E,$A0,$1E,$00,$00
        EQUB    $0A,$1E,$A0,$9E,$00,$00,$0A,$1E
        EQUB    $A0,$DE,$00,$00,$1F,$10,$00,$0C
        EQUB    $1F,$20,$00,$04,$1F,$30,$04,$08
        EQUB    $1F,$40,$08,$0C,$1F,$51,$0C,$10
        EQUB    $1F,$61,$00,$10,$1F,$62,$00,$14
        EQUB    $1F,$82,$14,$04,$1F,$83,$04,$18
        EQUB    $1F,$73,$08,$18,$1F,$74,$08,$1C
        EQUB    $1F,$54,$0C,$1C,$1F,$DA,$20,$2C
        EQUB    $1F,$DB,$20,$24,$1F,$DC,$24,$28
        EQUB    $1F,$D9,$28,$2C,$1F,$A5,$10,$2C
        EQUB    $1F,$A6,$10,$20,$1F,$B6,$14,$20
        EQUB    $1F,$B8,$14,$24,$1F,$C8,$18,$24
        EQUB    $1F,$C7,$18,$28,$1F,$97,$1C,$28
        EQUB    $1F,$95,$1C,$2C,$1E,$00,$30,$34
        EQUB    $1E,$00,$34,$38,$1E,$00,$38,$3C
        EQUB    $1E,$00,$3C,$30,$1F,$00,$00,$A0
        EQUB    $5F,$6B,$6B,$6B,$1F,$6B,$6B,$6B
        EQUB    $9F,$6B,$6B,$6B,$DF,$6B,$6B,$6B
        EQUB    $5F,$00,$A0,$00,$1F,$A0,$00,$00
        EQUB    $9F,$A0,$00,$00,$1F,$00,$A0,$00
        EQUB    $FF,$6B,$6B,$6B,$7F,$6B,$6B,$6B
        EQUB    $3F,$6B,$6B,$6B,$BF,$6B,$6B,$6B
        EQUB    $3F,$00,$00,$A0,$00,$40,$06,$7A
        EQUB    $DA,$51,$00,$0A,$66,$18,$00,$00
        EQUB    $24,$0E,$02,$2C,$00,$00,$02,$00
        EQUB    $00,$00,$44,$1F,$10,$32,$08,$08
        EQUB    $24,$5F,$21,$54,$08,$08,$24,$1F
        EQUB    $32,$74,$08,$08,$24,$9F,$30,$76
        EQUB    $08,$08,$24,$DF,$10,$65,$08,$08
        EQUB    $2C,$3F,$74,$88,$08,$08,$2C,$7F
        EQUB    $54,$88,$08,$08,$2C,$FF,$65,$88
        EQUB    $08,$08,$2C,$BF,$76,$88,$0C,$0C
        EQUB    $2C,$28,$74,$88,$0C,$0C,$2C,$68
        EQUB    $54,$88,$0C,$0C,$2C,$E8,$65,$88
        EQUB    $0C,$0C,$2C,$A8,$76,$88,$08,$08
        EQUB    $0C,$A8,$76,$77,$08,$08,$0C,$E8
        EQUB    $65,$66,$08,$08,$0C,$28,$74,$77
        EQUB    $08,$08,$0C,$68,$54,$55,$1F,$21
        EQUB    $00,$04,$1F,$32,$00,$08,$1F,$30
        EQUB    $00,$0C,$1F,$10,$00,$10,$1F,$24
        EQUB    $04,$08,$1F,$51,$04,$10,$1F,$60
        EQUB    $0C,$10,$1F,$73,$08,$0C,$1F,$74
        EQUB    $08,$14,$1F,$54,$04,$18,$1F,$65
        EQUB    $10,$1C,$1F,$76,$0C,$20,$1F,$86
        EQUB    $1C,$20,$1F,$87,$14,$20,$1F,$84
        EQUB    $14,$18,$1F,$85,$18,$1C,$08,$85
        EQUB    $18,$28,$08,$87,$14,$24,$08,$87
        EQUB    $20,$30,$08,$85,$1C,$2C,$08,$74
        EQUB    $24,$3C,$08,$54,$28,$40,$08,$76
        EQUB    $30,$34,$08,$65,$2C,$38,$9F,$40
        EQUB    $00,$10,$5F,$00,$40,$10,$1F,$40
        EQUB    $00,$10,$1F,$00,$40,$10,$1F,$20
        EQUB    $00,$00,$5F,$00,$20,$00,$9F,$20
        EQUB    $00,$00,$1F,$00,$20,$00,$3F,$00
        EQUB    $00,$B0,$00,$00,$19,$4A,$9E,$41
        EQUB    $00,$22,$36,$15,$05,$00,$38,$32
        EQUB    $3C,$1E,$00,$00,$01,$00,$00,$50
        EQUB    $00,$1F,$FF,$FF,$50,$0A,$00,$DF
        EQUB    $FF,$FF,$00,$50,$00,$5F,$FF,$FF
        EQUB    $46,$28,$00,$5F,$FF,$FF,$3C,$32
        EQUB    $00,$1F,$65,$DC,$32,$00,$3C,$1F
        EQUB    $FF,$FF,$28,$00,$46,$9F,$10,$32
        EQUB    $00,$1E,$4B,$3F,$FF,$FF,$00,$32
        EQUB    $3C,$7F,$98,$BA,$1F,$72,$00,$04
        EQUB    $1F,$D6,$00,$10,$1F,$C5,$0C,$10
        EQUB    $1F,$B4,$08,$0C,$1F,$A3,$04,$08
        EQUB    $1F,$32,$04,$18,$1F,$31,$08,$18
        EQUB    $1F,$41,$08,$14,$1F,$10,$14,$18
        EQUB    $1F,$60,$00,$14,$1F,$54,$0C,$14
        EQUB    $1F,$20,$00,$18,$1F,$65,$10,$14
        EQUB    $1F,$A8,$04,$20,$1F,$87,$04,$1C
        EQUB    $1F,$D7,$00,$1C,$1F,$DC,$10,$1C
        EQUB    $1F,$C9,$0C,$1C,$1F,$B9,$0C,$20
        EQUB    $1F,$BA,$08,$20,$1F,$98,$1C,$20
        EQUB    $1F,$09,$42,$51,$5F,$09,$42,$51
        EQUB    $9F,$48,$40,$1F,$DF,$40,$49,$2F
        EQUB    $5F,$2D,$4F,$41,$1F,$87,$0F,$23
        EQUB    $1F,$26,$4C,$46,$BF,$42,$3B,$27
        EQUB    $FF,$43,$0F,$50,$7F,$42,$0E,$4B
        EQUB    $FF,$46,$50,$28,$7F,$3A,$66,$33
        EQUB    $3F,$51,$09,$43,$3F,$2F,$5E,$3F
        EQUB    $00,$90,$01,$50,$8C,$31,$00,$12
        EQUB    $3C,$0F,$00,$00,$1C,$0C,$11,$0F
        EQUB    $00,$00,$02,$00,$18,$10,$00,$1F
        EQUB    $10,$55,$18,$05,$0F,$1F,$10,$22
        EQUB    $18,$0D,$09,$5F,$20,$33,$18,$0D
        EQUB    $09,$7F,$30,$44,$18,$05,$0F,$3F
        EQUB    $40,$55,$18,$10,$00,$9F,$51,$66
        EQUB    $18,$05,$0F,$9F,$21,$66,$18,$0D
        EQUB    $09,$DF,$32,$66,$18,$0D,$09,$FF
        EQUB    $43,$66,$18,$05,$0F,$BF,$54,$66
        EQUB    $1F,$10,$00,$04,$1F,$20,$04,$08
        EQUB    $1F,$30,$08,$0C,$1F,$40,$0C,$10
        EQUB    $1F,$50,$00,$10,$1F,$51,$00,$14
        EQUB    $1F,$21,$04,$18,$1F,$32,$08,$1C
        EQUB    $1F,$43,$0C,$20,$1F,$54,$10,$24
        EQUB    $1F,$61,$14,$18,$1F,$62,$18,$1C
        EQUB    $1F,$63,$1C,$20,$1F,$64,$20,$24
        EQUB    $1F,$65,$24,$14,$1F,$60,$00,$00
        EQUB    $1F,$00,$29,$1E,$5F,$00,$12,$30
        EQUB    $5F,$00,$33,$00,$7F,$00,$12,$30
        EQUB    $3F,$00,$29,$1E,$9F,$60,$00,$00
        EQUB    $00,$00,$01,$2C,$44,$19,$00,$16
        EQUB    $18,$06,$00,$00,$10,$08,$11,$08
        EQUB    $00,$00,$03,$00,$07,$00,$24,$9F
        EQUB    $12,$33,$07,$0E,$0C,$FF,$02,$33
        EQUB    $07,$0E,$0C,$BF,$01,$33,$15,$00
        EQUB    $00,$1F,$01,$22,$1F,$23,$00,$04
        EQUB    $1F,$03,$04,$08,$1F,$01,$08,$0C
        EQUB    $1F,$12,$0C,$00,$1F,$13,$00,$08
        EQUB    $1F,$02,$0C,$04,$3F,$1A,$00,$3D
        EQUB    $1F,$13,$33,$0F,$5F,$13,$33,$0F
        EQUB    $9F,$38,$00,$00

.BeebDisEndAddr

PRINT "S.ELITECO ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/ELITECO.bin", CODE%, P%, LOAD%
