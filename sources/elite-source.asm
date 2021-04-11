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

L0000   = $0000
L0001   = $0001
L0002   = $0002
L0003   = $0003
L0006   = $0006
L0007   = $0007
L0008   = $0008
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
L001B   = $001B
L001C   = $001C
L001D   = $001D
L001E   = $001E
L001F   = $001F
L0020   = $0020
L0021   = $0021
L0022   = $0022
L0023   = $0023
L0024   = $0024
L0025   = $0025
L0026   = $0026
L0027   = $0027
L002A   = $002A
L002B   = $002B
L002C   = $002C
L002D   = $002D
L002E   = $002E
L002F   = $002F
L0030   = $0030
L0031   = $0031
L0032   = $0032
L0033   = $0033
L0034   = $0034
L0035   = $0035
L0036   = $0036
L0037   = $0037
L0038   = $0038
L0039   = $0039
L003A   = $003A
L003B   = $003B
L003C   = $003C
L003D   = $003D
L003E   = $003E
L003F   = $003F
L0040   = $0040
L0041   = $0041
L0042   = $0042
L0043   = $0043
L0044   = $0044
L0045   = $0045
L0046   = $0046
L0047   = $0047
L0048   = $0048
L0049   = $0049
L004A   = $004A
L004B   = $004B
L004C   = $004C
L004D   = $004D
L004E   = $004E
L004F   = $004F
L0050   = $0050
L0051   = $0051
L0052   = $0052
L0053   = $0053
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
L0074   = $0074
L0075   = $0075
L0076   = $0076
L0077   = $0077
L0078   = $0078
L0079   = $0079
L007A   = $007A
L007B   = $007B
L007C   = $007C
L007D   = $007D
L007E   = $007E
L007F   = $007F
L0080   = $0080
L0081   = $0081
L0082   = $0082
L0083   = $0083
L0084   = $0084
L0085   = $0085
L0086   = $0086
L0087   = $0087
L0088   = $0088
L0089   = $0089
L008A   = $008A
L008B   = $008B
L008C   = $008C
L008D   = $008D
L008E   = $008E
L008F   = $008F
L00A0   = $00A0
L00A1   = $00A1
L00A2   = $00A2
L00A3   = $00A3
L00A4   = $00A4
L00A5   = $00A5
L00A6   = $00A6
L00A7   = $00A7
L00A8   = $00A8
L00A9   = $00A9
L00AB   = $00AB
L00AC   = $00AC
L00AD   = $00AD
L00AE   = $00AE
L00AF   = $00AF
L00B0   = $00B0
L00B1   = $00B1
L00B3   = $00B3
L00B4   = $00B4
L00B6   = $00B6
L00B7   = $00B7
L00B8   = $00B8
L00BA   = $00BA
L00BB   = $00BB
L00BC   = $00BC
L00BD   = $00BD
L00BE   = $00BE
L00BF   = $00BF
L00D1   = $00D1
L00D2   = $00D2
L00D3   = $00D3
L00D4   = $00D4
L00D5   = $00D5
L00D6   = $00D6
L00D7   = $00D7
L00D8   = $00D8
L00D9   = $00D9
L00DA   = $00DA
L00DB   = $00DB
L00E0   = $00E0
L00E1   = $00E1
L00F9   = $00F9
L00FC   = $00FC
L0100   = $0100
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
L0300   = $0300
L0301   = $0301
L0302   = $0302
L0303   = $0303
L0309   = $0309
L030A   = $030A
L030B   = $030B
L030C   = $030C
L030D   = $030D
L030E   = $030E
L030F   = $030F
L0310   = $0310
L0316   = $0316
L0317   = $0317
L031A   = $031A
L031D   = $031D
L0321   = $0321
L0328   = $0328
L0329   = $0329
L032A   = $032A
L032B   = $032B
L032C   = $032C
L032D   = $032D
L032E   = $032E
L0333   = $0333
L0334   = $0334
L0335   = $0335
L0345   = $0345
L0346   = $0346
L0347   = $0347
L0348   = $0348
L0349   = $0349
L034C   = $034C
L0357   = $0357
L0362   = $0362
L0885   = $0885
L0900   = $0900
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
L0BE0   = $0BE0
L0BE1   = $0BE1
L0BE2   = $0BE2
L0BE3   = $0BE3
L0BED   = $0BED
L0BEF   = $0BEF
L0BF4   = $0BF4
L0BF6   = $0BF6
L0BF7   = $0BF7
L0BF8   = $0BF8
L0BFB   = $0BFB
L0BFD   = $0BFD
L0BFF   = $0BFF
L0C00   = $0C00
L0C01   = $0C01
L0C02   = $0C02
L0C03   = $0C03
L0C04   = $0C04
L0C05   = $0C05
L0C06   = $0C06
L0C07   = $0C07
L0C5E   = $0C5E
L0C85   = $0C85
L0C86   = $0C86
L0CAE   = $0CAE
L0CB9   = $0CB9
L0CC4   = $0CC4
L0CCF   = $0CCF
L0CD0   = $0CD0
L0CD1   = $0CD1
L0CD2   = $0CD2
L0CD3   = $0CD3
L0CD4   = $0CD4
L0CD5   = $0CD5
L0CD6   = $0CD6
L0CD7   = $0CD7
L0CD8   = $0CD8
L0CD9   = $0CD9
L0CDA   = $0CDA
L0CDB   = $0CDB
L0CDC   = $0CDC
L0CDD   = $0CDD
L0CDE   = $0CDE
L0CDF   = $0CDF
L0CE0   = $0CE0
L0CE2   = $0CE2
L0CE3   = $0CE3
L0CE9   = $0CE9
L0CEA   = $0CEA
L0CEB   = $0CEB
L0CEC   = $0CEC
L0CEE   = $0CEE
L0CEF   = $0CEF
L0CF0   = $0CF0
L0CF1   = $0CF1
L0CF2   = $0CF2
L0CF3   = $0CF3
L6CA9   = $6CA9
L6FA9   = $6FA9
L8AFE   = $8AFE
LE0FE   = $E0FE
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

.L0D1C
        EQUB    $00

.L0D1D
        EQUB    $00

.L0D1E
        EQUB    $00

.L0D1F
        EQUB    $00

.L0D20
        EQUB    $00,$00,$00

.L0D23
        EQUB    $00

.L0D24
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

.L0D40
        LDA     L0900
        STA     L0000
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

        LDX     L00AC
        JSR     L25E0

        JSR     L25E0

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
        STX     L00AC
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
        STA     L0087
        ORA     L0088
        STA     L00AE
        LDX     L00AD
        JSR     L25E0

        TXA
        EOR     #$80
        TAY
        AND     #$80
        STX     L00AD
        STA     L008B
        EOR     #$80
        STA     L008A
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
        STA     L002B
        ORA     L008A
        STA     L002A
        LDA     L0043
        BEQ     L0DC3

        LDA     L008C
        CMP     #$28
        BCS     L0DC3

        INC     L008C
.L0DC3
        LDA     L0042
        BEQ     L0DCD

        DEC     L008C
        BNE     L0DCD

        INC     L008C
.L0DCD
        LDA     L004C
        AND     L0333
        BEQ     L0DE1

        JSR     L3903

        LDA     #$28
        JSR     L4282

        LDA     #$00
        STA     L0C00
.L0DE1
        LDA     L0052
        BPL     L0DF6

        LDA     L004B
        BEQ     L0DF6

        LDX     L0333
        BEQ     L0DF6

        STA     L0C00
        LDY     #$0D
        JSR     L3940

.L0DF6
        LDA     L004D
        BEQ     L0E01

        LDA     L0052
        BMI     L0E2A

        JSR     L210E

.L0E01
        LDA     L0049
        BEQ     L0E08

        ASL     L032A
.L0E08
        LDA     L004A
        AND     L032E
        BEQ     L0E12

        JMP     L1EA1

.L0E12
        LDA     L004F
        BEQ     L0E19

        JSR     L267E

.L0E19
        LDA     L004E
        AND     L0328
        BEQ     L0E2A

        LDA     L0030
        BNE     L0E2A

        DEC     L0BFF
        JSR     L3913

.L0E2A
        LDA     L0050
        AND     L032C
        AND     L0BF4
        BEQ     L0E3C

        LDA     L0944
        BMI     L0E3C

        JMP     L0F49

.L0E3C
        LDA     #$00
        STA     L0051
        STA     L008D
        LDA     L008C
        LSR     A
        ROR     L008D
        LSR     A
        ROR     L008D
        STA     L008E
        LDA     L0C02
        BNE     L0E7E

        LDA     L0048
        BEQ     L0E7E

        LDA     L0C03
        CMP     #$F2
        BCS     L0E7E

        LDX     L0C01
        LDA     L0310,X
        BEQ     L0E7E

        PHA
        AND     #$7F
        STA     L0051
        STA     L0BED
        LDA     #$00
        JSR     L4282

        JSR     L26DC

        PLA
        BPL     L0E79

        LDA     #$00
.L0E79
        AND     #$FA
        STA     L0C02
.L0E7E
        LDX     #$00
.L0E80
        STX     L00A3
        LDA     L0BE0,X
        BNE     L0E8A

        JMP     L102C

.L0E8A
        STA     L00AB
        JSR     L384B

        LDY     #$23
.L0E91
        LDA     (L0020),Y
        STA     L0053,Y
        DEY
        BPL     L0E91

        LDA     L00AB
        BMI     L0EC1

        ASL     A
        TAY
        LDA     L4ED2,Y
        STA     L001E
        LDA     L4ED3,Y
        STA     L001F
        LDA     L032A
        BPL     L0EC1

        CPY     #$0E
        BEQ     L0EC1

        LDA     L0072
        AND     #$20
        BNE     L0EC1

        LDA     L0072
        ORA     #$80
        STA     L0072
        JSR     L425A

.L0EC1
        JSR     L1157

        LDY     #$23
.L0EC6
        LDA     L0053,Y
        STA     (L0020),Y
        DEY
        BPL     L0EC6

        LDA     L0072
        AND     #$A0
        JSR     L3F41

        BNE     L0F28

        LDA     L0053
        ORA     L0056
        ORA     L0059
        BMI     L0F28

        LDX     L00AB
        BMI     L0F28

        CPX     #$07
        BEQ     L0F2B

        AND     #$C0
        BNE     L0F28

        CPX     #$08
        BEQ     L0F28

        CPX     #$0A
        BCS     L0EF6

        JMP     L0F73

.L0EF6
        LDA     L0329
        AND     L0058
        BPL     L0F73

.L0EFD
        LDA     #$03
L0EFE = L0EFD+1
        CPX     #$0B
        BNE     L0F05

        BEQ     L0F0A

.L0F05
        JSR     L3D25

        AND     #$07
.L0F0A
        STA     L0CDC
        LDA     #$01
        JSR     L294A

        LDY     #$4E
        BCS     L0F61

        LDY     L0CDC
        ADC     L0317,Y
        STA     L0317,Y
        TYA
        ADC     #$D0
        JSR     L43C3

        JMP     L0F64

.L0F28
        JMP     L0F82

.L0F2B
        LDA     L0944
        BMI     L0F58

        LDA     L0061
        CMP     #$D6
        BCC     L0F58

        JSR     L3763

        LDA     L0033
        BMI     L0F58

        CMP     #$59
        BCC     L0F58

        LDA     L0063
        AND     #$7F
        CMP     #$50
        BCC     L0F58

.L0F49
        LDA     #$00
        STA     L002F
        LDA     #$08
        JSR     L21F8

        JSR     L3C7A

        JMP     L400E

.L0F58
        LDA     L008C
        CMP     #$05
        BCC     L0F6B

        JMP     L3F48

.L0F61
        JSR     L4246

.L0F64
        ASL     L0072
        SEC
        ROR     L0072
        BNE     L0F82

.L0F6B
        LDA     #$01
        STA     L008C
        LDA     #$05
        BNE     L0F7C

.L0F73
        ASL     L0072
        SEC
        ROR     L0072
        LDA     L0076
        SEC
        ROR     A
.L0F7C
        JSR     L37FD

        JSR     L4246

.L0F82
        LDA     L00A6
        BNE     L0FE0

        JSR     L2730

        JSR     L20A9

        BCC     L0FDD

        LDA     L0C00
        BEQ     L0F9D

        JSR     L4280

        LDX     L00A3
        LDY     #$11
        JSR     L3907

.L0F9D
        LDA     L0051
        BEQ     L0FDD

        LDX     #$0F
        JSR     L4269

        LDA     L0076
        SEC
        SBC     L0051
        BCS     L0FD6

        LDA     L00AB
        CMP     #$07
        BEQ     L0FD8

        LDA     L0072
        ORA     #$80
        STA     L0072
        BCS     L0FDD

        JSR     L3D25

        BPL     L0FD3

        LDY     #$00
        AND     (L001E),Y
        STA     L00B4
.L0FC6
        BEQ     L0FD3

        LDX     #$0A
        LDA     #$00
        JSR     L2162

        DEC     L00B4
        BPL     L0FC6

.L0FD3
        JSR     L425A

.L0FD6
        STA     L0076
.L0FD8
        LDA     L00AB
        JSR     L212D

.L0FDD
        JSR     L46C9

.L0FE0
        LDY     #$23
        LDA     L0076
        STA     (L0020),Y
        LDA     L0072
        BPL     L1017

        AND     #$20
        BEQ     L1017

        LDA     L00AB
        CMP     #$02
        BNE     L0FFC

        LDA     L0334
        ORA     #$40
        STA     L0334
.L0FFC
        LDA     L0C06
        BNE     L1014

        LDY     #$0A
        LDA     (L001E),Y
        BEQ     L1014

        TAX
        INY
        LDA     (L001E),Y
        TAY
        JSR     L3235

        LDA     #$00
        JSR     L43C3

.L1014
        JMP     L3B4B

.L1017
        LDA     L00AB
        BMI     L1020

        JSR     L3F34

        BCC     L1014

.L1020
        LDY     #$1F
        LDA     L0072
        STA     (L0020),Y
        LDX     L00A3
        INX
        JMP     L0E80

.L102C
        LDA     L032A
        BPL     L1034

        ASL     L032A
.L1034
        LDA     L00A9
        AND     #$07
        BNE     L109F

        LDX     L0CD4
        BPL     L1051

        LDX     L0CD3
        JSR     L3729

        STX     L0CD3
        LDX     L0CD2
        JSR     L3729

        STX     L0CD2
.L1051
        SEC
        LDA     L032B
        ADC     L0CD4
        BCS     L105D

        STA     L0CD4
.L105D
        LDA     L00A9
        AND     #$1F
        BNE     L10A3

        LDA     L0BF4
        BNE     L109C

        TAY
        JSR     L112A

        BNE     L109C

        LDX     #$1C
.L1070
        LDA     L0900,X
        STA     L0053,X
        DEX
        BPL     L1070

        INX
        LDY     #$09
        JSR     L1107

        BNE     L109C

        LDX     #$03
        LDY     #$0B
        JSR     L1107

        BNE     L109C

        LDX     #$06
        LDY     #$0D
        JSR     L1107

        BNE     L109C

        LDA     #$C0
        JSR     L3F36

        BCC     L109C

        JSR     L3859

.L109C
        JMP     L10D5

.L109F
        LDA     L00A9
        AND     #$1F
.L10A3
        CMP     #$0A
        BNE     L10D5

        LDA     #$32
        CMP     L0CD4
        BCC     L10B2

        ASL     A
        JSR     L43C3

.L10B2
        LDY     #$FF
        STY     L0CE2
        INY
        JSR     L1128

        BNE     L10D5

        JSR     L1136

        BCS     L10D5

        SBC     #$24
        BCC     L10D2

        STA     L00A1
        JSR     L45F5

        LDA     L00A0
        STA     L0CE2
        BNE     L10D5

.L10D2
        JMP     L3F48

.L10D5
        LDA     L0BED
        BEQ     L10E9

        LDA     L0C02
        CMP     #$08
        BCS     L10E9

        JSR     L26FB

        LDA     #$00
        STA     L0BED
.L10E9
        LDA     L0BFF
        BEQ     L10F3

        JSR     L372C

        BEQ     L10FD

.L10F3
        LDA     L0030
        BEQ     L1100

        DEC     L0030
        DEC     L0030
        BNE     L1100

.L10FD
        JSR     L4238

.L1100
        LDA     L00A6
        BNE     L1127

        JMP     L194C

.L1107
        LDA     L0053,Y
        ASL     A
        STA     L003E
        LDA     L0054,Y
        ROL     A
        STA     L003F
        LDA     #$00
        ROR     A
        STA     L0040
        JSR     L134F

        STA     L0055,X
        LDY     L003E
        STY     L0053,X
        LDY     L003F
        STY     L0054,X
        AND     #$7F
.L1127
        RTS

.L1128
        LDA     #$00
.L112A
        ORA     L0902,Y
        ORA     L0905,Y
        ORA     L0908,Y
        AND     #$7F
        RTS

.L1136
        LDA     L0901,Y
        JSR     L23F0

        STA     L00A1
        LDA     L0904,Y
        JSR     L23F0

        ADC     L00A1
        BCS     L1154

        STA     L00A1
        LDA     L0907,Y
        JSR     L23F0

        ADC     L00A1
        BCC     L1156

.L1154
        LDA     #$FF
.L1156
        RTS

.L1157
        LDA     L0072
        AND     #$A0
        BNE     L1182

        LDA     L00A9
        EOR     L00A3
        AND     #$0F
        BNE     L1168

        JSR     L44B6

.L1168
        LDX     L00AB
        BPL     L116F

        JMP     L14D3

.L116F
        LDA     L0073
        BPL     L1182

        CPX     #$08
        BEQ     L117F

        LDA     L00A9
        EOR     L00A3
        AND     #$07
        BNE     L1182

.L117F
        JSR     L1F42

.L1182
        JSR     L28A4

        LDA     L006E
        ASL     A
        ASL     A
        STA     L00A0
        LDA     L005D
        AND     #$7F
        JSR     L242A

        STA     L00A1
        LDA     L005D
        LDX     #$00
        JSR     L12F8

        LDA     L005F
        AND     #$7F
        JSR     L242A

        STA     L00A1
        LDA     L005F
        LDX     #$03
        JSR     L12F8

        LDA     L0061
        AND     #$7F
        JSR     L242A

        STA     L00A1
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
        CMP     (L001E),Y
        BCC     L11CC

        LDA     (L001E),Y
.L11CC
        STA     L006E
        LDA     #$00
        STA     L006F
        LDX     L0087
        LDA     L0053
        EOR     #$FF
        STA     L001B
        LDA     L0054
        JSR     L245A

        STA     L001D
        LDA     L0089
        EOR     L0055
        LDX     #$03
        JSR     L149E

        STA     L00BF
        LDA     L001C
        STA     L00BD
        EOR     #$FF
        STA     L001B
        LDA     L001D
        STA     L00BE
        LDX     L002B
        JSR     L245A

        STA     L001D
        LDA     L00BF
        EOR     L008A
        LDX     #$06
        JSR     L149E

        STA     L005B
        LDA     L001C
        STA     L0059
        EOR     #$FF
        STA     L001B
        LDA     L001D
        STA     L005A
        JSR     L245C

        STA     L001D
        LDA     L00BF
        STA     L0058
        EOR     L008A
        EOR     L005B
        BPL     L1234

        LDA     L001C
        ADC     L00BD
        STA     L0056
        LDA     L001D
        ADC     L00BE
        STA     L0057
        JMP     L1254

.L1234
        LDA     L00BD
        SBC     L001C
        STA     L0056
        LDA     L00BE
        SBC     L001D
        STA     L0057
        BCS     L1254

        LDA     #$01
        SBC     L0056
        STA     L0056
        LDA     #$00
        SBC     L0057
        STA     L0057
        LDA     L0058
        EOR     #$80
        STA     L0058
.L1254
        LDX     L0087
        LDA     L0056
        EOR     #$FF
        STA     L001B
        LDA     L0057
        JSR     L245A

        STA     L001D
        LDA     L0088
        EOR     L0058
        LDX     #$00
        JSR     L149E

        STA     L0055
        LDA     L001D
        STA     L0054
        LDA     L001C
        STA     L0053
.L1276
        LDA     L008C
        STA     L00A1
        LDA     #$80
        LDX     #$06
        JSR     L12FA

        LDY     #$09
        JSR     L13AB

        LDY     #$0F
        JSR     L13AB

        LDY     #$15
        JSR     L13AB

        LDA     L0071
        AND     #$80
        STA     L00BB
        LDA     L0071
        AND     #$7F
        BEQ     L12B9

        CMP     #$7F
        SBC     #$00
        ORA     L00BB
        STA     L0071
        LDX     #$0F
        LDY     #$09
        JSR     L1412

        LDX     #$11
        LDY     #$0B
        JSR     L1412

        LDX     #$13
        LDY     #$0D
        JSR     L1412

.L12B9
        LDA     L0070
        AND     #$80
        STA     L00BB
        LDA     L0070
        AND     #$7F
        BEQ     L12E2

        CMP     #$7F
        SBC     #$00
        ORA     L00BB
        STA     L0070
        LDX     #$0F
        LDY     #$15
        JSR     L1412

        LDX     #$11
        LDY     #$17
        JSR     L1412

        LDX     #$13
        LDY     #$19
        JSR     L1412

.L12E2
        LDA     L0072
        AND     #$A0
        BNE     L12F1

        LDA     L0072
        ORA     #$10
        STA     L0072
        JMP     L28A4

.L12F1
        LDA     L0072
        AND     #$EF
        STA     L0072
        RTS

.L12F8
        AND     #$80
.L12FA
        ASL     A
        STA     L00A2
        LDA     #$00
        ROR     A
        STA     L00D1
        LSR     L00A2
        EOR     L0055,X
        BMI     L131D

        LDA     L00A1
        ADC     L0053,X
        STA     L0053,X
        LDA     L00A2
        ADC     L0054,X
        STA     L0054,X
        LDA     L0055,X
        ADC     #$00
        ORA     L00D1
        STA     L0055,X
        RTS

.L131D
        LDA     L0053,X
        SEC
        SBC     L00A1
        STA     L0053,X
        LDA     L0054,X
        SBC     L00A2
        STA     L0054,X
        LDA     L0055,X
        AND     #$7F
        SBC     #$00
        ORA     #$80
        EOR     L00D1
        STA     L0055,X
        BCS     L134E

        LDA     #$01
        SBC     L0053,X
        STA     L0053,X
        LDA     #$00
        SBC     L0054,X
        STA     L0054,X
        LDA     #$00
        SBC     L0055,X
        AND     #$7F
        ORA     L00D1
        STA     L0055,X
.L134E
        RTS

.L134F
        LDA     L0040
        STA     L00A2
        AND     #$80
        STA     L00D1
        EOR     L0055,X
        BMI     L1373

        LDA     L003E
        CLC
        ADC     L0053,X
        STA     L003E
        LDA     L003F
        ADC     L0054,X
        STA     L003F
        LDA     L0040
        ADC     L0055,X
        AND     #$7F
        ORA     L00D1
        STA     L0040
        RTS

.L1373
        LDA     L00A2
        AND     #$7F
        STA     L00A2
        LDA     L0053,X
        SEC
        SBC     L003E
        STA     L003E
        LDA     L0054,X
        SBC     L003F
        STA     L003F
        LDA     L0055,X
        AND     #$7F
        SBC     L00A2
        ORA     #$80
        EOR     L00D1
        STA     L0040
        BCS     L13AA

        LDA     #$01
        SBC     L003E
        STA     L003E
        LDA     #$00
        SBC     L003F
        STA     L003F
        LDA     #$00
        SBC     L0040
        AND     #$7F
        ORA     L00D1
        STA     L0040
.L13AA
        RTS

.L13AB
        LDA     L00AE
        STA     L00A0
        LDX     L0055,Y
        STX     L00A1
        LDX     L0056,Y
        STX     L00A2
        LDX     L0053,Y
        STX     L001B
        LDA     L0054,Y
        EOR     #$80
        JSR     L24DD

        STA     L0056,Y
        STX     L0055,Y
        STX     L001B
        LDX     L0053,Y
        STX     L00A1
        LDX     L0054,Y
        STX     L00A2
        LDA     L0056,Y
        JSR     L24DD

        STA     L0054,Y
        STX     L0053,Y
        STX     L001B
        LDA     L002A
        STA     L00A0
        LDX     L0055,Y
        STX     L00A1
        LDX     L0056,Y
        STX     L00A2
        LDX     L0057,Y
        STX     L001B
        LDA     L0058,Y
        EOR     #$80
        JSR     L24DD

        STA     L0056,Y
        STX     L0055,Y
        STX     L001B
        LDX     L0057,Y
        STX     L00A1
        LDX     L0058,Y
        STX     L00A2
        LDA     L0056,Y
        JSR     L24DD

        STA     L0058,Y
        STX     L0057,Y
        RTS

.L1412
        LDA     L0054,X
        AND     #$7F
        LSR     A
        STA     L00D1
        LDA     L0053,X
        SEC
        SBC     L00D1
        STA     L00A1
        LDA     L0054,X
        SBC     #$00
        STA     L00A2
        LDA     L0053,Y
        STA     L001B
        LDA     L0054,Y
        AND     #$80
        STA     L00D1
        LDA     L0054,Y
        AND     #$7F
        LSR     A
        ROR     L001B
        LSR     A
        ROR     L001B
        LSR     A
        ROR     L001B
        LSR     A
        ROR     L001B
        ORA     L00D1
        EOR     L00BB
        STX     L00A0
        JSR     L24E0

        STA     L003E
        STX     L003D
        LDX     L00A0
        LDA     L0054,Y
        AND     #$7F
        LSR     A
        STA     L00D1
        LDA     L0053,Y
        SEC
        SBC     L00D1
        STA     L00A1
        LDA     L0054,Y
        SBC     #$00
        STA     L00A2
        LDA     L0053,X
        STA     L001B
        LDA     L0054,X
        AND     #$80
        STA     L00D1
        LDA     L0054,X
        AND     #$7F
        LSR     A
        ROR     L001B
        LSR     A
        ROR     L001B
        LSR     A
        ROR     L001B
        LSR     A
        ROR     L001B
        ORA     L00D1
        EOR     #$80
        EOR     L00BB
        STX     L00A0
        JSR     L24E0

        STA     L0054,Y
        STX     L0053,Y
        LDX     L00A0
        LDA     L003D
        STA     L0053,X
        LDA     L003E
        STA     L0054,X
        RTS

.L149E
        TAY
        EOR     L0055,X
        BMI     L14B2

        LDA     L001C
        CLC
        ADC     L0053,X
        STA     L001C
        LDA     L001D
        ADC     L0054,X
        STA     L001D
        TYA
        RTS

.L14B2
        LDA     L0053,X
        SEC
        SBC     L001C
        STA     L001C
        LDA     L0054,X
        SBC     L001D
        STA     L001D
        BCC     L14C5

        TYA
        EOR     #$80
        RTS

.L14C5
        LDA     #$01
        SBC     L001C
        STA     L001C
        LDA     #$00
        SBC     L001D
        STA     L001D
        TYA
.L14D2
        RTS

.L14D3
        TXA
        LSR     A
        BCS     L14D2

        LDA     L00AE
        EOR     #$80
        STA     L00A0
        LDA     L0053
        STA     L001B
        LDA     L0054
        STA     L001C
        LDA     L0055
        JSR     L2365

        LDX     #$03
        JSR     L134F

        LDA     L003E
        STA     L00BD
        STA     L001B
        LDA     L003F
        STA     L00BE
        STA     L001C
        LDA     L002A
        STA     L00A0
        LDA     L0040
        STA     L00BF
        JSR     L2365

        LDX     #$06
        JSR     L134F

        LDA     L003E
        STA     L001B
        STA     L0059
        LDA     L003F
        STA     L001C
        STA     L005A
        LDA     L0040
        STA     L005B
        EOR     #$80
        JSR     L2365

        LDA     L0040
        AND     #$80
        STA     L00D1
        EOR     L00BF
        BMI     L1541

        LDA     L003D
        ADC     L00BC
        LDA     L003E
        ADC     L00BD
        STA     L0056
        LDA     L003F
        ADC     L00BE
        STA     L0057
        LDA     L0040
        ADC     L00BF
        JMP     L1574

.L1541
        LDA     L003D
        SEC
        SBC     L00BC
        LDA     L003E
        SBC     L00BD
        STA     L0056
        LDA     L003F
        SBC     L00BE
        STA     L0057
        LDA     L00BF
        AND     #$7F
        STA     L001B
        LDA     L0040
        AND     #$7F
        SBC     L001B
        STA     L001B
        BCS     L1574

        LDA     #$01
        SBC     L0056
        STA     L0056
        LDA     #$00
        SBC     L0057
        STA     L0057
        LDA     #$00
        SBC     L001B
        ORA     #$80
.L1574
        EOR     L00D1
        STA     L0058
        LDA     L00AE
        STA     L00A0
        LDA     L0056
        STA     L001B
        LDA     L0057
        STA     L001C
        LDA     L0058
        JSR     L2365

        LDX     #$00
        JSR     L134F

        LDA     L003E
        STA     L0053
        LDA     L003F
        STA     L0054
        LDA     L0040
        STA     L0055
        JMP     L1276

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

.L15EF
        EQUB    $AA

.L15F0
        EQUB    $03

.L15F1
        EQUB    $00

.L15F2
        EQUB    $09,$24,$09,$48,$09,$6C,$09,$90
        EQUB    $09,$B4,$09,$D8,$09,$FC,$09,$20
        EQUB    $0A,$44,$0A,$68,$0A,$8C,$0A,$B0
        EQUB    $0A

.L160B
        EQUB    $80,$40,$20,$10,$08,$04,$02,$01
        EQUB    $80,$40

.L1615
        EQUB    $C0,$30,$0C,$03

.L1619
        EQUB    $C0,$C0,$60,$30,$18,$0C,$06,$03

.L1621
        STY     L00A4
        LDA     #$80
        STA     L00A2
        STA     L0007
        ASL     A
        STA     L00B1
        LDA     L0033
        SBC     L0031
        BCS     L1636

        EOR     #$FF
        ADC     #$01
.L1636
        STA     L001B
        SEC
        LDA     L0034
        SBC     L0032
        BCS     L1643

        EOR     #$FF
        ADC     #$01
.L1643
        STA     L00A0
        CMP     L001B
        BCC     L164C

        JMP     L1722

.L164C
        LDX     L0031
        CPX     L0033
        BCC     L1663

        DEC     L00B1
        LDA     L0033
        STA     L0031
        STX     L0033
        TAX
        LDA     L0034
        LDY     L0032
        STA     L0032
        STY     L0034
.L1663
        LDA     L0032
        LSR     A
        LSR     A
        LSR     A
        STA     L0008
        LSR     A
        ROR     L0007
        LSR     A
        ROR     L0007
        ADC     L0008
        ADC     #$58
        STA     L0008
        TXA
        AND     #$F8
        ADC     L0007
        STA     L0007
        BCC     L1681

        INC     L0008
.L1681
        LDA     L0032
        AND     #$07
        TAY
        TXA
        AND     #$07
        TAX
        LDA     L160B,X
        STA     L00A1
        LDA     L00A0
        LDX     #$FE
        STX     L00A0
.L1695
        ASL     A
        BCS     L169C

        CMP     L001B
        BCC     L169F

.L169C
        SBC     L001B
        SEC
.L169F
        ROL     L00A0
        BCS     L1695

        LDX     L001B
        INX
        LDA     L0034
        SBC     L0032
        BCS     L16E6

        LDA     L00B1
        BNE     L16B7

        DEX
.L16B1
        LDA     L00A1
        EOR     (L0007),Y
        STA     (L0007),Y
.L16B7
        LSR     L00A1
        BCC     L16C7

        ROR     L00A1
        LDA     L0007
        ADC     #$08
        STA     L0007
        BCC     L16C7

        INC     L0008
.L16C7
        LDA     L00A2
        ADC     L00A0
        STA     L00A2
        BCC     L16E0

        DEY
        BPL     L16E0

        LDA     L0007
        SBC     #$40
        STA     L0007
        LDA     L0008
        SBC     #$01
        STA     L0008
        LDY     #$07
.L16E0
        DEX
        BNE     L16B1

        LDY     L00A4
        RTS

.L16E6
        LDA     L00B1
        BEQ     L16F1

        DEX
.L16EB
        LDA     L00A1
        EOR     (L0007),Y
        STA     (L0007),Y
.L16F1
        LSR     L00A1
        BCC     L1701

        ROR     L00A1
        LDA     L0007
        ADC     #$08
        STA     L0007
        BCC     L1701

        INC     L0008
.L1701
        LDA     L00A2
        ADC     L00A0
        STA     L00A2
        BCC     L171C

        INY
        CPY     #$08
        BNE     L171C

        LDA     L0007
        ADC     #$3F
        STA     L0007
        LDA     L0008
        ADC     #$01
        STA     L0008
        LDY     #$00
.L171C
        DEX
        BNE     L16EB

        LDY     L00A4
        RTS

.L1722
        LDY     L0032
        TYA
        LDX     L0031
        CPY     L0034
        BCS     L173B

        DEC     L00B1
        LDA     L0033
        STA     L0031
        STX     L0033
        TAX
        LDA     L0034
        STA     L0032
        STY     L0034
        TAY
.L173B
        LSR     A
        LSR     A
        LSR     A
        STA     L0008
        LSR     A
        ROR     L0007
        LSR     A
        ROR     L0007
        ADC     L0008
        ADC     #$58
        STA     L0008
        TXA
        AND     #$F8
        ADC     L0007
        STA     L0007
        BCC     L1757

        INC     L0008
.L1757
        LDA     L0032
        AND     #$07
        TAY
        TXA
        AND     #$07
        TAX
        LDA     L160B,X
        STA     L00A1
        LDA     L001B
        LDX     #$01
        STX     L001B
.L176B
        ASL     A
        BCS     L1772

        CMP     L00A0
        BCC     L1775

.L1772
        SBC     L00A0
        SEC
.L1775
        ROL     L001B
        BCC     L176B

        LDX     L00A0
        INX
        LDA     L0033
        SBC     L0031
        BCC     L17BE

        CLC
        LDA     L00B1
        BEQ     L178E

        DEX
.L1788
        LDA     L00A1
        EOR     (L0007),Y
        STA     (L0007),Y
.L178E
        DEY
        BPL     L179F

        LDA     L0007
        SBC     #$3F
        STA     L0007
        LDA     L0008
        SBC     #$01
        STA     L0008
        LDY     #$07
.L179F
        LDA     L00A2
        ADC     L001B
        STA     L00A2
        BCC     L17B8

        LSR     L00A1
        BCC     L17B8

        ROR     L00A1
        LDA     L0007
        ADC     #$08
        STA     L0007
        BCC     L17B8

        INC     L0008
        CLC
.L17B8
        DEX
        BNE     L1788

        LDY     L00A4
        RTS

.L17BE
        LDA     L00B1
        BEQ     L17C9

        DEX
.L17C3
        LDA     L00A1
        EOR     (L0007),Y
        STA     (L0007),Y
.L17C9
        DEY
        BPL     L17DA

        LDA     L0007
        SBC     #$3F
        STA     L0007
        LDA     L0008
        SBC     #$01
        STA     L0008
        LDY     #$07
.L17DA
        LDA     L00A2
        ADC     L001B
        STA     L00A2
        BCC     L17F3

        ASL     L00A1
        BCC     L17F3

        ROL     L00A1
        LDA     L0007
        SBC     #$07
        STA     L0007
        BCS     L17F2

        DEC     L0008
.L17F2
        CLC
.L17F3
        DEX
        BNE     L17C3

        LDY     L00A4
        RTS

        LDA     #$0F
        TAX
        JMP     OSBYTE

.L17FF
        JSR     L34CC

.L1802
        LDA     #$13
        BNE     L180A

.L1806
        LDA     #$17
        INC     L002D
.L180A
        STA     L0032
        LDX     #$02
        STX     L0031
        LDX     #$FE
        STX     L0033
.L1814
        LDX     L0032
        STX     L0034
        JMP     L1621

.L181B
        JSR     L24E0

        STA     L0027
        TXA
        STA     L0CAE,Y
.L1824
        LDA     L0031
        BPL     L182D

        EOR     #$7F
        CLC
        ADC     #$01
.L182D
        EOR     #$80
        TAX
        LDA     L0032
        AND     #$7F
        CMP     #$60
        BCS     L1892

        LDA     L0032
        BPL     L1840

        EOR     #$7F
        ADC     #$01
.L1840
        STA     L00D1
        LDA     #$61
        SBC     L00D1
.L1846
        STY     L0006
        LDY     #$80
        STY     L0007
        TAY
        LSR     A
        LSR     A
        LSR     A
        STA     L0008
        LSR     A
        ROR     L0007
        LSR     A
        ROR     L0007
        ADC     L0008
        ADC     #$58
        STA     L0008
        TXA
        AND     #$F8
        ADC     L0007
        STA     L0007
        BCC     L1869

        INC     L0008
.L1869
        TYA
        AND     #$07
        TAY
        TXA
        AND     #$07
        TAX
        LDA     L00A7
        CMP     #$90
        BCS     L1889

        LDA     L1619,X
        EOR     (L0007),Y
        STA     (L0007),Y
        LDA     L00A7
        CMP     #$50
        BCS     L1890

        DEY
        BPL     L1889

        LDY     #$01
.L1889
        LDA     L1619,X
        EOR     (L0007),Y
        STA     (L0007),Y
.L1890
        LDY     L0006
.L1892
        RTS

.L1893
        TXA
        ADC     L00E0
        STA     L0084
        LDA     L00E1
        ADC     L00D1
        STA     L0085
        LDA     L00B3
        BEQ     L18B4

        INC     L00B3
.L18A4
        LDY     L0077
        LDA     #$FF
        CMP     L0C85,Y
        BEQ     L1915

        STA     L0C86,Y
        INC     L0077
        BNE     L1915

.L18B4
        LDA     L007E
        STA     L0031
        LDA     L007F
        STA     L0032
        LDA     L0080
        STA     L0033
        LDA     L0081
        STA     L0034
        LDA     L0082
        STA     L0035
        LDA     L0083
        STA     L0036
        LDA     L0084
        STA     L0037
        LDA     L0085
        STA     L0038
        JSR     L4DAD

        BCS     L18A4

        LDA     L00B1
        BEQ     L18ED

        LDA     L0031
        LDY     L0033
        STA     L0033
        STY     L0031
        LDA     L0032
        LDY     L0034
        STA     L0034
        STY     L0032
.L18ED
        LDY     L0077
        LDA     L0C85,Y
        CMP     #$FF
        BNE     L1901

        LDA     L0031
        STA     L0C5E,Y
        LDA     L0032
        STA     L0C86,Y
        INY
.L1901
        LDA     L0033
        STA     L0C5E,Y
        LDA     L0034
        STA     L0C86,Y
        INY
        STY     L0077
        JSR     L1621

        LDA     L00A8
        BNE     L18A4

.L1915
        LDA     L0082
        STA     L007E
        LDA     L0083
        STA     L007F
        LDA     L0084
        STA     L0080
        LDA     L0085
        STA     L0081
        LDA     L00B4
        CLC
        ADC     L00B6
        STA     L00B4
        RTS

.L192D
        LDY     #$0A
.L192F
        LDX     L0362,Y
        LDA     L034C,Y
        STA     L0032
        STA     L0362,Y
        TXA
        STA     L0031
        STA     L034C,Y
        LDA     L0CB9,Y
        STA     L00A7
        JSR     L1824

        DEY
        BNE     L192F

        RTS

.L194C
        LDX     L0C01
        BEQ     L195A

        DEX
        BNE     L1957

        JMP     L1A46

.L1957
        JMP     L223D

.L195A
        LDY     #$0A
.L195C
        JSR     L253F

        LDA     L00A1
        LSR     L001B
        ROR     A
        LSR     L001B
        ROR     A
        ORA     #$01
        STA     L00A0
        LDA     L0CC4,Y
        SBC     L008D
        STA     L0CC4,Y
        LDA     L0CB9,Y
        STA     L00A7
        SBC     L008E
        STA     L0CB9,Y
        JSR     L23FA

        STA     L0027
        LDA     L001B
        ADC     L0CAE,Y
        STA     L0026
        STA     L00A1
        LDA     L0032
        ADC     L0027
        STA     L0027
        STA     L00A2
        LDA     L034C,Y
        STA     L0031
        JSR     L23FF

        STA     L0025
        LDA     L001B
        ADC     L0357,Y
        STA     L0024
        LDA     L0031
        ADC     L0025
        STA     L0025
        EOR     L0089
        JSR     L23A9

        JSR     L24E0

        STA     L0027
        STX     L0026
        EOR     L0088
        JSR     L23A1

        JSR     L24E0

        STA     L0025
        STX     L0024
        LDX     L002B
        LDA     L0027
        EOR     L008B
        JSR     L23AB

        STA     L00A0
        JSR     L2481

        ASL     L001B
        ROL     A
        STA     L00D1
        LDA     #$00
        ROR     A
        ORA     L00D1
        JSR     L24E0

        STA     L0025
        TXA
        STA     L0357,Y
        LDA     L0026
        STA     L00A1
        LDA     L0027
        STA     L00A2
        LDA     #$00
        STA     L001B
        LDA     L002A
        EOR     #$80
        JSR     L181B

        LDA     L0025
        STA     L0031
        STA     L034C,Y
        AND     #$7F
        CMP     #$78
        BCS     L1A23

        LDA     L0027
        STA     L0362,Y
        STA     L0032
        AND     #$7F
        CMP     #$78
        BCS     L1A23

        LDA     L0CB9,Y
        CMP     #$10
        BCC     L1A23

        STA     L00A7
.L1A19
        JSR     L1824

        DEY
        BEQ     L1A22

        JMP     L195C

.L1A22
        RTS

.L1A23
        JSR     L3D25

        ORA     #$04
        STA     L0032
        STA     L0362,Y
        JSR     L3D25

        ORA     #$08
        STA     L0031
        STA     L034C,Y
        JSR     L3D25

        ORA     #$90
        STA     L0CB9,Y
        STA     L00A7
        LDA     L0032
        JMP     L1A19

.L1A46
        LDY     #$0A
.L1A48
        JSR     L253F

        LDA     L00A1
        LSR     L001B
        ROR     A
        LSR     L001B
        ROR     A
        ORA     #$01
        STA     L00A0
        LDA     L034C,Y
        STA     L0031
        JSR     L23FF

        STA     L0025
        LDA     L0357,Y
        SBC     L001B
        STA     L0024
        LDA     L0031
        SBC     L0025
        STA     L0025
        JSR     L23FA

        STA     L0027
        LDA     L0CAE,Y
        SBC     L001B
        STA     L0026
        STA     L00A1
        LDA     L0032
        SBC     L0027
        STA     L0027
        STA     L00A2
        LDA     L0CC4,Y
        ADC     L008D
        STA     L0CC4,Y
        LDA     L0CB9,Y
        STA     L00A7
        ADC     L008E
        STA     L0CB9,Y
        LDA     L0025
        EOR     L0088
        JSR     L23A9

        JSR     L24E0

        STA     L0027
        STX     L0026
        EOR     L0089
        JSR     L23A1

        JSR     L24E0

        STA     L0025
        STX     L0024
        LDA     L0027
        EOR     L008B
        LDX     L002B
        JSR     L23AB

        STA     L00A0
        LDA     L0025
        STA     L00A2
        EOR     #$80
        JSR     L2485

        ASL     L001B
        ROL     A
        STA     L00D1
        LDA     #$00
        ROR     A
        ORA     L00D1
        JSR     L24E0

        STA     L0025
        TXA
        STA     L0357,Y
        LDA     L0026
        STA     L00A1
        LDA     L0027
        STA     L00A2
        LDA     #$00
        STA     L001B
        LDA     L002A
        JSR     L181B

        LDA     L0025
        STA     L0031
        STA     L034C,Y
        LDA     L0027
        STA     L0362,Y
        STA     L0032
        AND     #$7F
        CMP     #$6E
        BCS     L1B0F

        LDA     L0CB9,Y
        CMP     #$A0
        BCS     L1B0F

        STA     L00A7
.L1B05
        JSR     L1824

        DEY
        BEQ     L1B0E

        JMP     L1A48

.L1B0E
        RTS

.L1B0F
        JSR     L3D25

        AND     #$7F
        ADC     #$0A
        STA     L0CB9,Y
        STA     L00A7
        LSR     A
        BCS     L1B32

        LSR     A
        LDA     #$FC
        ROR     A
        STA     L0031
        STA     L034C,Y
        JSR     L3D25

        STA     L0032
        STA     L0362,Y
        JMP     L1B05

.L1B32
        JSR     L3D25

        STA     L0031
        STA     L034C,Y
        LSR     A
        LDA     #$E6
        ROR     A
        STA     L0032
        STA     L0362,Y
        BNE     L1B05

.L1B45
        EQUB    $01

.L1B46
        EQUB    $00,$2C,$01,$A0,$0F,$70,$17,$A0
        EQUB    $0F,$10,$27,$82,$14,$10,$27,$28
        EQUB    $23,$98,$3A,$10,$27,$50,$C3

.L1B5D
        LDX     #$09
        CMP     #$19
        BCS     L1BC2

        DEX
        CMP     #$0A
        BCS     L1BC2

        DEX
        CMP     #$02
        BCS     L1BC2

        DEX
        BNE     L1BC2

.L1B70
        LDA     #$08
        JSR     L27FC

        JSR     L2F0D

        LDA     #$07
        STA     L002C
        LDA     #$7E
        JSR     L17FF

        LDA     #$0F
        LDY     L00AF
        BNE     L1B98

        LDA     #$E6
        LDY     L0BF6
        LDX     L0BE2,Y
        BEQ     L1B98

        LDY     L0CD4
        CPY     #$80
        ADC     #$01
.L1B98
        JSR     L34C1

        LDA     #$7D
        JSR     L29C6

        LDA     #$13
        LDY     L0334
        BEQ     L1BAB

        CPY     #$32
        ADC     #$01
.L1BAB
        JSR     L34C1

        LDA     #$10
        JSR     L29C6

        LDA     L0348
        BNE     L1B5D

        TAX
        LDA     L0347
        LSR     A
        LSR     A
.L1BBE
        INX
        LSR     A
        BNE     L1BBE

.L1BC2
        TXA
        CLC
        ADC     #$15
        JSR     L34C1

        LDA     #$12
        JSR     L1C27

        LDA     L032E
        BEQ     L1BD8

        LDA     #$70
        JSR     L1C27

.L1BD8
        LDA     L0329
        BEQ     L1BE2

        LDA     #$6F
        JSR     L1C27

.L1BE2
        LDA     L0328
        BEQ     L1BEC

        LDA     #$6C
        JSR     L1C27

.L1BEC
        LDA     #$71
        STA     L00B7
.L1BF0
        TAY
        LDX     L02B9,Y
        BEQ     L1BF9

        JSR     L1C27

.L1BF9
        INC     L00B7
        LDA     L00B7
        CMP     #$75
        BCC     L1BF0

        LDX     #$00
.L1C03
        STX     L00B4
        LDY     L0310,X
        BEQ     L1C1F

        TXA
        CLC
        ADC     #$60
        JSR     L29C6

        LDA     #$67
        LDX     L00B4
        LDY     L0310,X
        BPL     L1C1C

        LDA     #$68
.L1C1C
        JSR     L1C27

.L1C1F
        LDX     L00B4
        INX
        CPX     #$04
        BCC     L1C03

        RTS

.L1C27
        JSR     L34C1

        LDX     #$06
        STX     L002C
        RTS

.L1C2F
        EQUB    $48

        EQUB    $76,$E8,$00

.L1C33
        LDA     #$03
.L1C35
        LDY     #$00
.L1C37
        STA     L008F
        LDA     #$00
        STA     L003D
        STA     L003E
        STY     L003F
        STX     L0040
.L1C43
        LDX     #$0B
        STX     L00D1
        PHP
        BCC     L1C4E

        DEC     L00D1
        DEC     L008F
.L1C4E
        LDA     #$0B
        SEC
        STA     L00A5
        SBC     L008F
        STA     L008F
        INC     L008F
        LDY     #$00
        STY     L00A2
        JMP     L1C9F

.L1C60
        ASL     L0040
        ROL     L003F
        ROL     L003E
        ROL     L003D
        ROL     L00A2
        LDX     #$03
.L1C6C
        LDA     L003D,X
        STA     L0031,X
        DEX
        BPL     L1C6C

        LDA     L00A2
        STA     L0035
        ASL     L0040
        ROL     L003F
        ROL     L003E
        ROL     L003D
        ROL     L00A2
        ASL     L0040
        ROL     L003F
        ROL     L003E
        ROL     L003D
        ROL     L00A2
        CLC
        LDX     #$03
.L1C8E
        LDA     L003D,X
        ADC     L0031,X
        STA     L003D,X
        DEX
        BPL     L1C8E

        LDA     L0035
        ADC     L00A2
        STA     L00A2
        LDY     #$00
.L1C9F
        LDX     #$03
        SEC
.L1CA2
        LDA     L003D,X
        SBC     L1C2F,X
        STA     L0031,X
        DEX
        BPL     L1CA2

        LDA     L00A2
        SBC     #$17
        STA     L0035
        BCC     L1CC5

        LDX     #$03
.L1CB6
        LDA     L0031,X
        STA     L003D,X
        DEX
        BPL     L1CB6

        LDA     L0035
        STA     L00A2
        INY
        JMP     L1C9F

.L1CC5
        TYA
        BNE     L1CD4

        LDA     L00D1
        BEQ     L1CD4

        DEC     L008F
        BPL     L1CDE

        LDA     #$20
        BNE     L1CDB

.L1CD4
        LDY     #$00
        STY     L00D1
        CLC
        ADC     #$30
.L1CDB
        JSR     L1CF8

.L1CDE
        DEC     L00D1
        BPL     L1CE4

        INC     L00D1
.L1CE4
        DEC     L00A5
        BMI     L1CF5

        BNE     L1CF2

        PLP
        BCC     L1CF2

        LDA     #$2E
        JSR     L1CF8

.L1CF2
        JMP     L1C60

.L1CF5
        RTS

.L1CF6
        LDA     #$07
.L1CF8
        STA     L00D2
        STY     L0CD0
        STX     L0CCF
        LDY     L007E
        CPY     #$FF
        BEQ     L1D73

        CMP     #$07
        BEQ     L1D7D

        CMP     #$20
        BCS     L1D1A

        CMP     #$0A
        BEQ     L1D16

        LDX     #$01
        STX     L002C
.L1D16
        INC     L002D
        BNE     L1D73

.L1D1A
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
        STA     L0007
        LDA     L002D
        CMP     #$18
        BCC     L1D3B

        JSR     L27FE

        JMP     L1D73

.L1D3B
        LSR     A
        ROR     L0007
        LSR     A
        ROR     L0007
        ADC     L002D
        ADC     #$58
        STA     L0008
        LDA     L002C
        ASL     A
        ASL     A
        ASL     A
        ADC     L0007
        STA     L0007
        BCC     L1D54

        INC     L0008
.L1D54
        CPY     #$7F
        BNE     L1D63

        DEC     L002C
        DEC     L0008
        LDY     #$F8
        JSR     L40E7

        BEQ     L1D73

.L1D63
        INC     L002C
.L1D65
        BIT     L0885
L1D66 = L1D65+1
        LDY     #$07
.L1D6A
        LDA     (L001C),Y
        EOR     (L0007),Y
        STA     (L0007),Y
        DEY
        BPL     L1D6A

.L1D73
        LDY     L0CD0
        LDX     L0CCF
        LDA     L00D2
        CLC
.L1D7C
        RTS

.L1D7D
        JSR     L4280

        JMP     L1D73

.L1D83
        LDA     #$F0
        STA     L0007
        LDA     #$76
        STA     L0008
        LDA     L008C
        JSR     L1E28

        LDA     #$00
        STA     L00A1
        STA     L001B
        LDA     #$08
        STA     L00A2
        LDA     L0087
        LSR     A
        LSR     A
        ORA     L0088
        EOR     #$80
        JSR     L24E0

        JSR     L1E70

        LDA     L002A
        LDX     L002B
        BEQ     L1DB0

        SBC     #$01
.L1DB0
        JSR     L24E0

        JSR     L1E70

        LDA     L00A9
        AND     #$03
        BNE     L1D7C

        LDY     #$00
        LDX     #$03
.L1DC0
        STY     L0037,X
        DEX
        BPL     L1DC0

        LDX     #$03
        LDA     L0CD4
        LSR     A
        STA     L00A0
.L1DCD
        SEC
        SBC     #$20
        BCC     L1DDF

        STA     L00A0
        LDA     #$20
        STA     L0037,X
        LDA     L00A0
        DEX
        BPL     L1DCD

        BMI     L1DE3

.L1DDF
        LDA     L00A0
        STA     L0037,X
.L1DE3
        LDA     L0037,Y
        STY     L001B
        JSR     L1E28

        LDY     L001B
        INY
        CPY     #$04
        BNE     L1DE3

        LDA     #$76
        STA     L0008
        LDA     #$30
        STA     L0007
        LDA     L0CD2
        JSR     L1E25

        LDA     L0CD3
        JSR     L1E25

        LDA     L030D
        JSR     L1E27

        SEC
        JSR     L293D

        LDA     L0C03
        JSR     L1E25

        LDA     #$F0
        STA     L0006
        STA     L003E
        LDA     L0CE2
        JSR     L1E25

        JMP     L3737

.L1E25
        LSR     A
        LSR     A
.L1E27
        LSR     A
.L1E28
        STA     L00A0
        LDX     #$FF
        STX     L00A1
        LDY     #$02
        LDX     #$03
.L1E32
        LDA     L00A0
        CMP     #$08
        BCC     L1E54

        SBC     #$08
        STA     L00A0
        LDA     L00A1
.L1E3E
        STA     (L0007),Y
        INY
        STA     (L0007),Y
        INY
        STA     (L0007),Y
        TYA
        CLC
        ADC     #$06
        BCC     L1E4E

        INC     L0008
.L1E4E
        TAY
        DEX
        BMI     L1E6C

        BPL     L1E32

.L1E54
        EOR     #$07
        STA     L00A0
        LDA     L00A1
.L1E5A
        ASL     A
        DEC     L00A0
        BPL     L1E5A

        PHA
        LDA     #$00
        STA     L00A1
        LDA     #$63
        STA     L00A0
        PLA
        JMP     L1E3E

.L1E6C
        SEC
        JMP     L293D

.L1E70
        LDY     #$01
        STA     L00A0
.L1E74
        SEC
        LDA     L00A0
        SBC     #$04
        BCS     L1E86

        LDA     #$FF
        LDX     L00A0
        STA     L00A0
        LDA     L1615,X
        BNE     L1E8A

.L1E86
        STA     L00A0
        LDA     #$00
.L1E8A
        STA     (L0007),Y
        INY
        STA     (L0007),Y
        INY
        STA     (L0007),Y
        INY
        STA     (L0007),Y
        TYA
        CLC
        ADC     #$05
        TAY
        CPY     #$1E
        BCC     L1E74

.L1E9E
        JMP     L293D

L1EA0 = L1E9E+2
.L1EA1
        JSR     L3C84

        JSR     L3C6E

        LDA     #$00
        LDX     #$10
.L1EAB
        STA     L0317,X
        DEX
        BPL     L1EAB

        STA     L0334
        STA     L032E
        LDA     #$46
        STA     L030D
        JMP     L400E

.L1EBF
        LDA     #$00
        JSR     L3F41

        BEQ     L1EC9

        JMP     L1F86

.L1EC9
        JSR     L1F2B

        JSR     L4246

        LDA     #$FA
        JMP     L37FD

.L1ED4
        LDA     L0030
        BNE     L1F1B

        LDA     L0073
        ASL     A
        BMI     L1EBF

        LSR     A
        TAX
        LDA     L15F1,X
        STA     L0022
        LDA     L15F2,X
        STA     L0023
        LDY     #$02
        JSR     L2085

        LDY     #$05
        JSR     L2085

        LDY     #$08
        JSR     L2085

        LDA     L00D4
        ORA     L00D7
        ORA     L00DA
        AND     #$7F
        ORA     L00D3
        ORA     L00D6
        ORA     L00D9
        BNE     L1F31

        LDA     L0073
        CMP     #$82
        BEQ     L1F1B

        LDY     #$1F
        LDA     (L0022),Y
        BIT     L1F39
        BNE     L1F1B

        ORA     #$80
        STA     (L0022),Y
.L1F1B
        LDA     L0053
        ORA     L0056
        ORA     L0059
        BNE     L1F28

        LDA     #$50
        JSR     L37FD

.L1F28
        JSR     L425A

.L1F2B
        ASL     L0072
        SEC
        ROR     L0072
.L1F30
        RTS

.L1F31
        JSR     L3D25

        CMP     #$10
        BCS     L1F8F

.L1F38
        LDY     #$20
L1F39 = L1F38+1
        LDA     (L0022),Y
        LSR     A
        BCC     L1F8F

        JMP     L3913

.L1F42
        CPX     #$08
        BEQ     L1ED4

        CPX     #$0B
        BNE     L1F50

        JSR     L418D

        JMP     L2044

.L1F50
        CPX     #$07
        BNE     L1F69

        JSR     L3D25

        CMP     #$8C
        BCC     L1F30

        LDA     L0BEF
        CMP     #$03
        BCS     L1F30

        LDX     #$02
        LDA     #$E1
        JMP     L2162

.L1F69
        CPX     #$06
        BCS     L1F7C

        CPX     #$02
        BEQ     L1F7C

        LDA     L0BF4
        BEQ     L1F7C

        LDA     L0073
        AND     #$81
        STA     L0073
.L1F7C
        LDY     #$0E
        LDA     L0076
        CMP     (L001E),Y
        BCS     L1F86

        INC     L0076
.L1F86
        LDX     #$08
.L1F88
        LDA     L0053,X
        STA     L00D2,X
        DEX
        BPL     L1F88

.L1F8F
        JSR     L419C

        LDY     #$0A
        JSR     L24C1

        STA     L00B4
        LDA     L00AB
        CMP     #$08
        BNE     L1FA2

        JMP     L202C

.L1FA2
        JSR     L3D25

        CMP     #$FA
        BCC     L1FB0

        JSR     L3D25

        ORA     #$68
        STA     L0070
.L1FB0
        LDY     #$0E
        LDA     (L001E),Y
        LSR     A
        CMP     L0076
        BCC     L1FE9

        LSR     A
        LSR     A
        CMP     L0076
        BCC     L1FCD

        JSR     L3D25

        CMP     #$E6
        BCC     L1FCD

        LDA     #$00
        STA     L0073
        JMP     L215E

.L1FCD
        LDA     L0072
        AND     #$07
        BEQ     L1FE9

        STA     L00D1
        JSR     L3D25

        AND     #$1F
        CMP     L00D1
        BCS     L1FE9

        LDA     L0030
        BNE     L1FE9

        DEC     L0072
        LDA     L00AB
        JMP     L424A

.L1FE9
        LDA     #$00
        JSR     L3F41

        AND     #$E0
        BNE     L2015

        LDX     L00B4
        CPX     #$A0
        BCC     L2015

        LDA     L0072
        ORA     #$40
        STA     L0072
        CPX     #$A3
        BCC     L2015

        LDY     #$13
        LDA     (L001E),Y
        LSR     A
        JSR     L37FD

        DEC     L006F
        LDA     L0030
        BNE     L2084

        LDA     #$08
        JMP     L4282

.L2015
        LDA     L005A
        CMP     #$03
        BCS     L2023

        LDA     L0054
        ORA     L0057
        AND     #$FE
        BEQ     L2044

.L2023
        JSR     L3D25

        ORA     #$80
        CMP     L0073
        BCS     L2044

.L202C
        LDA     L0031
        EOR     #$80
        STA     L0031
        LDA     L0032
        EOR     #$80
        STA     L0032
        LDA     L0033
        EOR     #$80
        STA     L0033
        LDA     L00B4
        EOR     #$80
        STA     L00B4
.L2044
        LDY     #$10
        JSR     L24C1

        EOR     #$80
        AND     #$80
        ORA     #$03
        STA     L0071
        LDA     L0070
        AND     #$7F
        CMP     #$10
        BCS     L2066

        LDY     #$16
        JSR     L24C1

        EOR     L0071
        AND     #$80
        EOR     #$85
        STA     L0070
.L2066
        LDA     L00B4
        BMI     L2073

        CMP     #$16
        BCC     L2073

        LDA     #$03
        STA     L006F
        RTS

.L2073
        AND     #$7F
        CMP     #$12
        BCC     L2084

        LDA     #$FF
        LDX     L00AB
        CPX     #$08
        BNE     L2082

        ASL     A
.L2082
        STA     L006F
.L2084
        RTS

.L2085
        LDA     (L0022),Y
        EOR     #$80
        STA     L0040
        DEY
        LDA     (L0022),Y
        STA     L003F
        DEY
        LDA     (L0022),Y
        STA     L003E
        STY     L008F
        LDX     L008F
        JSR     L134F

        LDY     L008F
        STA     L00D4,X
        LDA     L003F
        STA     L00D3,X
        LDA     L003E
        STA     L00D2,X
        RTS

.L20A9
        CLC
        LDA     L005B
        BNE     L20E7

        LDA     L00AB
        BMI     L20E7

        LDA     L0072
        AND     #$20
        ORA     L0054
        ORA     L0057
        BNE     L20E7

        LDA     L0053
        JSR     L23F0

        STA     L00A2
        LDA     L001B
        STA     L00A1
        LDA     L0056
        JSR     L23F0

        TAX
        LDA     L001B
        ADC     L00A1
        STA     L00A1
        TXA
        ADC     L00A2
        BCS     L2157

        STA     L00A2
        LDY     #$02
        LDA     (L001E),Y
        CMP     L00A2
        BNE     L20E7

        DEY
        LDA     (L001E),Y
        CMP     L00A1
.L20E7
        RTS

.L20E8
        JSR     L3CC7

        LDA     #$1C
        STA     L0056
        LSR     A
        STA     L0059
        LDA     #$80
        STA     L0058
        LDA     L0052
        ASL     A
        ORA     #$80
        STA     L0073
.L20FD
        LDA     #$60
        STA     L0061
        ORA     #$80
        STA     L0069
        LDA     L008C
        ROL     A
        STA     L006E
        TXA
        JMP     L387E

.L210E
        LDX     #$08
        JSR     L20E8

        BCC     L2159

        LDX     L0052
        JSR     L384B

        LDA     L0BE0,X
        JSR     L212D

        LDY     #$04
        JSR     L3905

        DEC     L0333
        LDA     #$30
        JMP     L4282

.L212D
        CMP     #$07
        BEQ     L2150

        BCS     L20E7

        CMP     #$06
        BNE     L213A

        JSR     L2150

.L213A
        LDY     #$20
        LDA     (L0020),Y
        BEQ     L20E7

        ORA     #$80
        STA     (L0020),Y
        LDY     #$1C
        LDA     #$02
        STA     (L0020),Y
        ASL     A
        LDY     #$1E
        STA     (L0020),Y
        RTS

.L2150
        ASL     L0944
        SEC
        ROR     L0944
.L2157
        CLC
        RTS

.L2159
        LDA     #$C9
        JMP     L43C3

.L215E
        LDX     #$0B
.L2160
        LDA     #$FE
.L2162
        STA     L0006
        LDA     L001E
        PHA
        LDA     L001F
        PHA
        LDA     L0020
        PHA
        LDA     L0021
        PHA
        LDY     #$23
.L2172
        LDA     L0053,Y
        STA     L0100,Y
        LDA     (L0020),Y
        STA     L0053,Y
        DEY
        BPL     L2172

        LDA     L00AB
        CMP     #$07
        BNE     L21A3

        TXA
        PHA
        LDA     #$20
        STA     L006E
        LDX     #$00
        LDA     L005D
        JSR     L21DC

        LDX     #$03
        LDA     L005F
        JSR     L21DC

        LDX     #$06
        LDA     L0061
        JSR     L21DC

        PLA
        TAX
.L21A3
        LDA     L0006
        STA     L0073
        LSR     L0070
        ASL     L0070
        TXA
        CMP     #$0A
        BNE     L21C2

        JSR     L3D25

        ASL     A
        STA     L0071
        TXA
        AND     #$0F
        STA     L006E
        LDA     #$FF
        ROR     A
        STA     L0070
        LDA     #$0A
.L21C2
        JSR     L387E

        PLA
        STA     L0021
        PLA
        STA     L0020
        LDX     #$23
.L21CD
        LDA     L0100,X
        STA     L0053,X
        DEX
        BPL     L21CD

        PLA
        STA     L001F
        PLA
        STA     L001E
        RTS

.L21DC
        ASL     A
        STA     L00A1
        LDA     #$00
        ROR     A
        JMP     L12FA

.L21E5
        LDA     #$38
        JSR     L4282

        LDA     #$01
        STA     L0C04
        LDA     #$04
        JSR     L21FF

        DEC     L0C04
        RTS

.L21F8
        LDA     #$30
        JSR     L4282

        LDA     #$08
.L21FF
        STA     L00B6
        JSR     L27FE

        JSR     L2207

.L2207
        LDA     #$80
        STA     L00D2
        LDX     #$60
        STX     L00E0
        ASL     A
        STA     L00B7
        STA     L00D3
        STA     L00E1
.L2216
        JSR     L2222

        INC     L00B7
        LDX     L00B7
        CPX     #$08
        BNE     L2216

        RTS

.L2222
        LDA     L00B7
        AND     #$07
        CLC
        ADC     #$08
        STA     L003D
.L222B
        LDA     #$01
        STA     L0077
        JSR     L39F2

        ASL     L003D
        BCS     L223C

        LDA     L003D
        CMP     #$A0
        BCC     L222B

.L223C
        RTS

.L223D
        LDA     #$00
        CPX     #$02
        ROR     A
        STA     L00BA
        EOR     #$80
        STA     L00BB
        JSR     L22F0

        LDY     #$0A
.L224D
        LDA     L0CB9,Y
        STA     L00A7
        LSR     A
        LSR     A
        LSR     A
        JSR     L2542

        LDA     L001B
        EOR     L00BB
        STA     L00A2
        LDA     L0357,Y
        STA     L001B
        LDA     L034C,Y
        STA     L0031
        JSR     L24E0

        STA     L00A2
        STX     L00A1
        LDA     L0362,Y
        STA     L0032
        EOR     L008A
        LDX     L002B
        JSR     L23AB

        JSR     L24E0

        STX     L0024
        STA     L0025
        LDX     L0CAE,Y
        STX     L00A1
        LDX     L0032
        STX     L00A2
        LDX     L002B
        EOR     L008B
        JSR     L23AB

        JSR     L24E0

        STX     L0026
        STA     L0027
        LDX     L0087
        EOR     L0088
        JSR     L23AB

        STA     L00A0
        LDA     L0024
        STA     L00A1
        LDA     L0025
        STA     L00A2
        EOR     #$80
        JSR     L24DD

        STA     L0025
        TXA
        STA     L0357,Y
        LDA     L0026
        STA     L00A1
        LDA     L0027
        STA     L00A2
        JSR     L24DD

        STA     L00A2
        STX     L00A1
        LDA     #$00
        STA     L001B
        LDA     L00AE
        JSR     L181B

        LDA     L0025
        STA     L034C,Y
        STA     L0031
        AND     #$7F
        CMP     #$74
        BCS     L230B

        LDA     L0027
        STA     L0362,Y
        STA     L0032
        AND     #$7F
        CMP     #$74
        BCS     L231E

.L22E7
        JSR     L1824

        DEY
        BEQ     L22F0

        JMP     L224D

.L22F0
        LDA     L00AE
        EOR     L00BA
        STA     L00AE
        LDA     L0088
        EOR     L00BA
        STA     L0088
        EOR     #$80
        STA     L0089
        LDA     L008A
        EOR     L00BA
        STA     L008A
        EOR     #$80
        STA     L008B
        RTS

.L230B
        JSR     L3D25

        STA     L0032
        STA     L0362,Y
        LDA     #$73
        ORA     L00BA
        STA     L0031
        STA     L034C,Y
        BNE     L232F

.L231E
        JSR     L3D25

        STA     L0031
        STA     L034C,Y
        LDA     #$6E
        ORA     L0089
        STA     L0032
        STA     L0362,Y
.L232F
        JSR     L3D25

        ORA     #$08
        STA     L00A7
        STA     L0CB9,Y
        BNE     L22E7

.L233B
        EQUB    $00

        EQUB    $19,$32,$4A,$62,$79,$8E,$A2,$B5
        EQUB    $C6,$D5,$E2,$ED,$F5,$FB,$FF,$FF
        EQUB    $FF,$FB,$F5,$ED,$E2,$D5,$C6,$B5
        EQUB    $A2,$8E,$79,$62,$4A,$32,$19

.L235B
        STA     L003D
        STA     L003E
        STA     L003F
        STA     L0040
        CLC
        RTS

.L2365
        STA     L00A1
        AND     #$7F
        STA     L003F
        LDA     L00A0
        AND     #$7F
        BEQ     L235B

        SEC
        SBC     #$01
        STA     L00D1
        LDA     L001C
        LSR     L003F
        ROR     A
        STA     L003E
        LDA     L001B
        ROR     A
        STA     L003D
        LDA     #$00
        LDX     #$18
.L2386
        BCC     L238A

        ADC     L00D1
.L238A
        ROR     A
        ROR     L003F
        ROR     L003E
        ROR     L003D
        DEX
        BNE     L2386

        STA     L00D1
        LDA     L00A1
        EOR     L00A0
        AND     #$80
        ORA     L00D1
        STA     L0040
        RTS

.L23A1
        LDX     L0024
        STX     L00A1
        LDX     L0025
        STX     L00A2
.L23A9
        LDX     L0087
.L23AB
        STX     L001B
        TAX
        AND     #$80
        STA     L00D1
        TXA
        AND     #$7F
        BEQ     L241B

        TAX
        DEX
        STX     L0006
        LDA     #$00
        LSR     L001B
        BCC     L23C3

        ADC     L0006
.L23C3
        ROR     A
        ROR     L001B
        BCC     L23CA

        ADC     L0006
.L23CA
        ROR     A
        ROR     L001B
        BCC     L23D1

        ADC     L0006
.L23D1
        ROR     A
        ROR     L001B
        BCC     L23D8

        ADC     L0006
.L23D8
        ROR     A
        ROR     L001B
        BCC     L23DF

        ADC     L0006
.L23DF
        ROR     A
        ROR     L001B
        LSR     A
        ROR     L001B
        LSR     A
        ROR     L001B
        LSR     A
        ROR     L001B
        ORA     L00D1
        RTS

.L23EE
        AND     #$7F
.L23F0
        STA     L001B
        TAX
        BNE     L2407

.L23F5
        CLC
        STX     L001B
        TXA
        RTS

.L23FA
        LDA     L0362,Y
        STA     L0032
.L23FF
        AND     #$7F
        STA     L001B
.L2403
        LDX     L00A0
        BEQ     L23F5

.L2407
        DEX
        STX     L00D1
        LDA     #$00
        LDX     #$08
        LSR     L001B
.L2410
        BCC     L2414

        ADC     L00D1
.L2414
        ROR     A
        ROR     L001B
        DEX
        BNE     L2410

        RTS

.L241B
        STA     L001C
        STA     L001B
        RTS

.L2420
        AND     #$1F
        TAX
        LDA     L233B,X
        STA     L00A0
        LDA     L003D
.L242A
        EOR     #$FF
        SEC
        ROR     A
        STA     L001B
        LDA     #$00
.L2432
        BCS     L243C

        ADC     L00A0
        ROR     A
        LSR     L001B
        BNE     L2432

        RTS

.L243C
        LSR     A
        LSR     L001B
        BNE     L2432

        RTS

        LDX     L00A0
        BEQ     L23F5

        DEX
        STX     L00D1
        LDA     #$00
        LDX     #$08
        LSR     L001B
.L244F
        BCC     L2453

        ADC     L00D1
.L2453
        ROR     A
        ROR     L001B
        DEX
        BNE     L244F

        RTS

.L245A
        STX     L00A0
.L245C
        EOR     #$FF
        LSR     A
        STA     L001C
        LDA     #$00
        LDX     #$10
        ROR     L001B
.L2467
        BCS     L2474

        ADC     L00A0
        ROR     A
        ROR     L001C
        ROR     L001B
        DEX
        BNE     L2467

        RTS

.L2474
        LSR     A
        ROR     L001C
        ROR     L001B
        DEX
        BNE     L2467

        RTS

        LDX     L0087
        STX     L001B
.L2481
        LDX     L0025
        STX     L00A2
.L2485
        LDX     L0024
        STX     L00A1
.L2489
        TAX
        AND     #$7F
        LSR     A
        STA     L001B
        TXA
        EOR     L00A0
        AND     #$80
        STA     L00D1
        LDA     L00A0
        AND     #$7F
        BEQ     L24B4

        TAX
        DEX
        STX     L0006
        LDA     #$00
        LDX     #$07
.L24A4
        BCC     L24A8

        ADC     L0006
.L24A8
        ROR     A
        ROR     L001B
        DEX
        BNE     L24A4

        LSR     A
        ROR     L001B
        ORA     L00D1
        RTS

.L24B4
        STA     L001B
        RTS

.L24B7
        JSR     L2489

        STA     L00A2
        LDA     L001B
        STA     L00A1
        RTS

.L24C1
        LDX     L0053,Y
        STX     L00A0
        LDA     L0031
        JSR     L24B7

        LDX     L0055,Y
        STX     L00A0
        LDA     L0032
        JSR     L24DD

        STA     L00A2
        STX     L00A1
        LDX     L0057,Y
        STX     L00A0
        LDA     L0033
.L24DD
        JSR     L2489

.L24E0
        STA     L0006
        AND     #$80
        STA     L00D1
        EOR     L00A2
        BMI     L24F7

        LDA     L00A1
        CLC
        ADC     L001B
        TAX
        LDA     L00A2
        ADC     L0006
        ORA     L00D1
        RTS

.L24F7
        LDA     L00A2
        AND     #$7F
        STA     L008F
        LDA     L001B
        SEC
        SBC     L00A1
        TAX
        LDA     L0006
        AND     #$7F
        SBC     L008F
        BCS     L2519

        STA     L008F
        TXA
        EOR     #$FF
        ADC     #$01
        TAX
        LDA     #$00
        SBC     L008F
        ORA     #$80
.L2519
        EOR     L00D1
        RTS

.L251C
        STX     L00A0
        EOR     #$80
        JSR     L24DD

        TAX
        AND     #$80
        STA     L00D1
        TXA
        AND     #$7F
        LDX     #$FE
        STX     L0006
.L252F
        ASL     A
        CMP     #$60
        BCC     L2536

        SBC     #$60
.L2536
        ROL     L0006
        BCS     L252F

        LDA     L0006
        ORA     L00D1
        RTS

.L253F
        LDA     L0CB9,Y
.L2542
        STA     L00A0
        LDA     L008C
.L2546
        LDX     #$08
        ASL     A
        STA     L001B
        LDA     #$00
.L254D
        ROL     A
        BCS     L2554

        CMP     L00A0
        BCC     L2557

.L2554
        SBC     L00A0
        SEC
.L2557
        ROL     L001B
        DEX
        BNE     L254D

        JMP     L4630

.L255F
        STA     L001D
        LDA     L0059
        STA     L00A0
        LDA     L005A
        STA     L00A1
        LDA     L005B
        STA     L00A2
        LDA     L001B
        ORA     #$01
        STA     L001B
        LDA     L001D
        EOR     L00A2
        AND     #$80
        STA     L00D1
        LDY     #$00
        LDA     L001D
        AND     #$7F
.L2581
        CMP     #$40
        BCS     L258D

        ASL     L001B
        ROL     L001C
        ROL     A
        INY
        BNE     L2581

.L258D
        STA     L001D
        LDA     L00A2
        AND     #$7F
        BMI     L259D

.L2595
        DEY
        ASL     L00A0
        ROL     L00A1
        ROL     A
        BPL     L2595

.L259D
        STA     L00A0
        LDA     #$FE
        STA     L00A1
        LDA     L001D
        JSR     L4634

        LDA     #$00
        STA     L003E
        STA     L003F
        STA     L0040
        TYA
        BPL     L25D1

        LDA     L00A1
.L25B5
        ASL     A
        ROL     L003E
        ROL     L003F
        ROL     L0040
        INY
        BNE     L25B5

        STA     L003D
        LDA     L0040
        ORA     L00D1
        STA     L0040
        RTS

.L25C8
        LDA     L00A1
        STA     L003D
        LDA     L00D1
        STA     L0040
        RTS

.L25D1
        BEQ     L25C8

        LDA     L00A1
.L25D5
        LSR     A
        DEY
        BNE     L25D5

        STA     L003D
        LDA     L00D1
        STA     L0040
        RTS

.L25E0
        LDA     L0D1E
        BNE     L25F1

        TXA
        BPL     L25EB

        DEX
        BMI     L25F1

.L25EB
        INX
        BNE     L25F1

        DEX
        BEQ     L25EB

.L25F1
        RTS

.L25F2
        STA     L00D1
        TXA
        CLC
        ADC     L00D1
        TAX
        BCC     L25FD

        LDX     #$FF
.L25FD
        BPL     L260F

.L25FF
        LDA     L00D1
        RTS

.L2602
        STA     L00D1
        TXA
        SEC
        SBC     L00D1
        TAX
        BCS     L260D

        LDX     #$01
.L260D
        BPL     L25FF

.L260F
        LDA     L0D1F
        BNE     L25FF

        LDX     #$80
        BMI     L25FF

        LDA     L001B
        EOR     L00A0
        STA     L0006
        LDA     L00A0
        BEQ     L2647

        ASL     A
        STA     L00A0
        LDA     L001B
        ASL     A
        CMP     L00A0
        BCS     L2635

        JSR     L2651

        SEC
.L2630
        LDX     L0006
        BMI     L264A

        RTS

.L2635
        LDX     L00A0
        STA     L00A0
        STX     L001B
        TXA
        JSR     L2651

        STA     L00D1
        LDA     #$40
        SBC     L00D1
        BCS     L2630

.L2647
        LDA     #$3F
        RTS

.L264A
        STA     L00D1
        LDA     #$80
        SBC     L00D1
        RTS

.L2651
        JSR     L462C

        LDA     L00A1
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

.L267E
        LDA     L0BF6
        CLC
        ADC     L0BF8
        CLC
        ADC     L0BF7
        TAX
        LDA     L0BE2,X
        ORA     L0BF4
        BNE     L26D7

        LDY     L0908
        BMI     L269F

        TAY
        JSR     L112A

        CMP     #$02
        BCC     L26D7

.L269F
        LDY     L092C
        BMI     L26AD

        LDY     #$24
        JSR     L1128

        CMP     #$02
        BCC     L26D7

.L26AD
        LDA     #$81
        STA     L00A2
        STA     L00A1
        STA     L001B
        LDA     L0908
        JSR     L24E0

        STA     L0908
        LDA     L092C
        JSR     L24E0

        STA     L092C
        LDA     #$01
        STA     L00A6
        STA     L00A9
        LSR     A
        STA     L0C05
        LDX     L0C01
        JMP     L27C5

.L26D7
        LDA     #$28
        JMP     L4282

.L26DC
        JSR     L3D25

        AND     #$07
        ADC     #$5C
        STA     L0CD6
        JSR     L3D25

        AND     #$07
        ADC     #$7C
        STA     L0CD5
        LDA     L0C03
        ADC     #$08
        STA     L0C03
        JSR     L372C

.L26FB
        LDA     L00A6
        BNE     L2735

        LDA     #$20
        LDY     #$E0
        JSR     L270A

        LDA     #$30
        LDY     #$D0
.L270A
        STA     L0033
        LDA     L0CD5
        STA     L0031
        LDA     L0CD6
        STA     L0032
        LDA     #$BF
        STA     L0034
        JSR     L1621

        LDA     L0CD5
        STA     L0031
        LDA     L0CD6
        STA     L0032
        STY     L0033
        LDA     #$BF
        STA     L0034
        JMP     L1621

.L2730
        LDX     L0C01
        BNE     L2736

.L2735
        RTS

.L2736
        DEX
        BNE     L276A

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

.L276A
        LDA     #$00
        CPX     #$02
        ROR     A
        STA     L00BB
        EOR     #$80
        STA     L00BA
        LDA     L0053
        LDX     L0059
        STA     L0059
        STX     L0053
        LDA     L0054
        LDX     L005A
        STA     L005A
        STX     L0054
        LDA     L0055
        EOR     L00BA
        TAX
        LDA     L005B
        EOR     L00BB
        STA     L0055
        STX     L005B
        LDY     #$09
        JSR     L279E

        LDY     #$0F
        JSR     L279E

        LDY     #$15
.L279E
        LDA     L0053,Y
        LDX     L0057,Y
        STA     L0057,Y
        STX     L0053,Y
        LDA     L0054,Y
        EOR     L00BA
        TAX
        LDA     L0058,Y
        EOR     L00BB
        STA     L0054,Y
        STX     L0058,Y
.L27B8
        RTS

.L27B9
        STX     L0C01
        JSR     L27FC

        JSR     L27DC

        JMP     L36CF

.L27C5
        LDA     #$00
        LDY     L00A6
        BNE     L27B9

        CPX     L0C01
        BEQ     L27B8

        STX     L0C01
        JSR     L27FC

        JSR     L192D

        JSR     L36F5

.L27DC
        LDY     L0C01
        LDA     L0310,Y
        BEQ     L27B8

        LDA     #$80
        STA     L007F
        LDA     #$48
        STA     L0080
        LDA     #$14
        STA     L0081
        JSR     L2B8D

        LDA     #$0A
        STA     L0081
        JMP     L2B8D

.L27FA
        LDA     #$01
.L27FC
        STA     L00A6
.L27FE
        LDA     #$80
        STA     L007E
        ASL     A
        STA     L0BED
        STA     L0C06
        STA     L0C07
        LDX     #$58
        JSR     L289B

        LDX     L002F
        BEQ     L2818

        JSR     L304B

.L2818
        LDY     #$01
        STY     L002D
        LDA     L00A6
        BNE     L2834

        LDY     #$0B
        STY     L002C
        LDA     L0C01
        ORA     #$60
        JSR     L34CC

        JSR     L30DB

        LDA     #$AF
        JSR     L34CC

.L2834
        LDX     #$00
        STX     L007E
.L2838
        LDX     #$00
        STX     L0031
        STX     L0032
        DEX
        STX     L0033
        JSR     L1814

        LDA     #$02
        STA     L0031
        STA     L0033
        JSR     L284D

.L284D
        JSR     L2850

.L2850
        LDA     #$00
        STA     L0032
        LDA     #$BF
        STA     L0034
        DEC     L0031
        DEC     L0033
        JMP     L1621

.L285F
        LDY     #$01
.L2861
        BIT     L1EA0
L2862 = L2861+1
.L2864
        TXA
        LDX     #$00
        BIT     LFDD0
.L286A
        BIT     LFBD0
L286B = L286A+1
        DEX
        BNE     L286B

        TAX
        DEY
        BNE     L2864

        RTS

.L2875
        JSR     L2E13

        JSR     L2F0D

        JSR     L2E13

        LDA     L00A6
        BEQ     L289A

.L2882
        JSR     L2838

        LDX     #$71
        JSR     L289B

        JSR     L2838

        LDA     #$14
        STA     L002D
        JSR     L29B9

        LDY     #$01
        STY     L002C
        DEY
        TYA
.L289A
        RTS

.L289B
        JSR     L40E1

        INX
        CPX     #$76
        BNE     L289B

        RTS

.L28A4
        LDA     L0072
        AND     #$10
        BEQ     L289A

        LDA     L00AB
        BMI     L289A

        LDA     L0054
        ORA     L0057
        ORA     L005A
        AND     #$C0
        BNE     L289A

        LDA     L0054
        CLC
        LDX     L0055
        BPL     L28C3

        EOR     #$FF
        ADC     #$01
.L28C3
        ADC     #$7B
        STA     L0031
        LDA     L005A
        LSR     A
        LSR     A
        CLC
        LDX     L005B
        BPL     L28D3

        EOR     #$FF
        SEC
.L28D3
        ADC     #$23
        EOR     #$FF
        STA     L0007
        LDA     L0057
        LSR     A
        CLC
        LDX     L0058
        BMI     L28E4

        EOR     #$FF
        SEC
.L28E4
        ADC     L0007
        BPL     L28F2

        CMP     #$C2
        BCS     L28EE

        LDA     #$C2
.L28EE
        CMP     #$F7
        BCC     L28F4

.L28F2
        LDA     #$F6
.L28F4
        STA     L0032
        SEC
        SBC     L0007
        PHP
        PHA
        JSR     L37A8

        LDA     L160B,X
        STA     L0031
        PLA
        PLP
        TAX
        BEQ     L2925

        BCC     L2926

.L290A
        DEY
        BPL     L291C

        LDY     #$07
        LDA     L0007
        SEC
        SBC     #$40
        STA     L0007
        LDA     L0008
        SBC     #$01
        STA     L0008
.L291C
        LDA     L0031
        EOR     (L0007),Y
        STA     (L0007),Y
        DEX
        BNE     L290A

.L2925
        RTS

.L2926
        JSR     L2936

.L2929
        JSR     L2936

        LDA     L0031
        EOR     (L0007),Y
        STA     (L0007),Y
        INX
        BNE     L2929

        RTS

.L2936
        INY
        CPY     #$08
        BNE     L2925

        LDY     #$00
.L293D
        LDA     L0007
        ADC     #$3F
        STA     L0007
        LDA     L0008
        ADC     #$01
        STA     L0008
        RTS

.L294A
        PHA
        LDX     #$0C
        CPX     L0CDC
        BCC     L295D

.L2952
        ADC     L0317,X
        DEX
        BPL     L2952

        CMP     L0316
        PLA
        RTS

.L295D
        LDY     L0CDC
        ADC     L0317,Y
        CMP     #$C8
        PLA
        RTS

.L2967
        JSR     L296A

.L296A
        JSR     L296D

.L296D
        LDA     L0078
        CLC
        ADC     L007A
        TAX
        LDA     L0079
        ADC     L007B
        TAY
        LDA     L007A
        STA     L0078
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

.L2994
        LDA     L0CF0
        ORA     L0CF1
        BNE     L299F

        INC     L002D
        RTS

.L299F
        LDA     #$BF
        JSR     L34C7

        LDX     L0CF0
        LDY     L0CF1
        SEC
        JSR     L3053

        LDA     #$C3
.L29B0
        JSR     L34CC

.L29B3
        INC     L002D
.L29B5
        LDA     #$80
        STA     L007E
.L29B9
        LDA     #$0D
        JMP     L34CC

.L29BE
        LDA     #$AD
        JSR     L34CC

        JMP     L2A00

.L29C6
        JSR     L34CC

        JMP     L30DB

.L29CC
        JSR     L27FA

        LDA     #$09
        STA     L002C
        LDA     #$A3
        JSR     L34CC

        JSR     L1806

        JSR     L29B3

        INC     L002D
        JSR     L2994

        LDA     #$C2
        JSR     L34C7

        LDA     L0CE9
        CLC
        ADC     #$01
        LSR     A
        CMP     #$02
        BEQ     L29BE

        LDA     L0CE9
        BCC     L29FB

        SBC     #$05
        CLC
.L29FB
        ADC     #$AA
        JSR     L34CC

.L2A00
        LDA     L0CE9
        LSR     A
        LSR     A
        CLC
        ADC     #$A8
        JSR     L29B0

        LDA     #$A2
        JSR     L34C7

        LDA     L0CEA
        CLC
        ADC     #$B1
        JSR     L29B0

        LDA     #$C4
        JSR     L34C7

        LDX     L0CEB
        INX
        CLC
        JSR     L1C33

        JSR     L29B3

        LDA     #$C0
        JSR     L34C7

        SEC
        LDX     L0CEC
        JSR     L1C33

        LDA     #$C6
        JSR     L29B0

        LDA     #$28
        JSR     L34CC

        LDA     L007C
        BMI     L2A4B

        LDA     #$BC
        JSR     L34CC

        JMP     L2A87

.L2A4B
        LDA     L007D
        LSR     A
        LSR     A
        PHA
        AND     #$07
        CMP     #$03
        BCS     L2A5B

        ADC     #$E3
        JSR     L29C6

.L2A5B
        PLA
        LSR     A
        LSR     A
        LSR     A
        CMP     #$06
        BCS     L2A68

        ADC     #$E6
        JSR     L29C6

.L2A68
        LDA     L007B
        EOR     L0079
        AND     #$07
        STA     L007F
        CMP     #$06
        BCS     L2A79

        ADC     #$EC
        JSR     L29C6

.L2A79
        LDA     L007D
        AND     #$03
        CLC
        ADC     L007F
        AND     #$07
        ADC     #$F2
        JSR     L34CC

.L2A87
        LDA     #$53
        JSR     L34CC

        LDA     #$29
        JSR     L29B0

        LDA     #$C1
        JSR     L34C7

        LDX     L0CEE
        LDY     L0CEF
        JSR     L3052

        JSR     L30DB

        LDA     #$00
        STA     L007E
        LDA     #$4D
        JSR     L34CC

        LDA     #$E2
        JSR     L29B0

        LDA     #$FA
        JSR     L34C7

        LDA     L007D
        LDX     L007B
        AND     #$0F
        CLC
        ADC     #$0B
        TAY
        JSR     L3053

        JSR     L30DB

        LDA     #$6B
        JSR     L1CF8

        LDA     #$6D
        JMP     L1CF8

.L2ACF
        LDA     L0079
        AND     #$07
        STA     L0CE9
        LDA     L007A
        LSR     A
        LSR     A
        LSR     A
        AND     #$07
        STA     L0CEA
        LSR     A
        BNE     L2AEB

        LDA     L0CE9
        ORA     #$02
        STA     L0CE9
.L2AEB
        LDA     L0CE9
        EOR     #$07
        CLC
        STA     L0CEB
        LDA     L007B
        AND     #$03
        ADC     L0CEB
        STA     L0CEB
        LDA     L0CEA
        LSR     A
        ADC     L0CEB
        STA     L0CEB
        ASL     A
        ASL     A
        ADC     L0CE9
        ADC     L0CEA
        ADC     #$01
        STA     L0CEC
        LDA     L0CE9
        EOR     #$07
        ADC     #$03
        STA     L001B
        LDA     L0CEA
        ADC     #$04
        STA     L00A0
        JSR     L2403

        LDA     L0CEC
        STA     L00A0
        JSR     L2403

        ASL     L001B
        ROL     A
        ASL     L001B
        ROL     A
        ASL     L001B
        ROL     A
        STA     L0CEF
        LDA     L001B
        STA     L0CEE
        RTS

.L2B42
        LDA     #$40
        JSR     L27FC

        LDA     #$07
        STA     L002C
        JSR     L2F02

        LDA     #$C7
        JSR     L34CC

        JSR     L1806

        LDA     #$98
        JSR     L180A

        JSR     L2BF8

        LDX     #$00
.L2B60
        STX     L00A3
        LDX     L007B
        LDY     L007C
        TYA
        ORA     #$50
        STA     L00A7
        LDA     L0079
        LSR     A
        CLC
        ADC     #$18
        STA     L0032
        JSR     L1846

        JSR     L2967

        LDX     L00A3
        INX
        BNE     L2B60

        LDA     L0CF2
        STA     L007F
        LDA     L0CF3
        LSR     A
        STA     L0080
        LDA     #$04
        STA     L0081
.L2B8D
        LDA     #$18
        LDX     L00A6
        BPL     L2B95

        LDA     #$00
.L2B95
        STA     L0084
        LDA     L007F
        SEC
        SBC     L0081
        BCS     L2BA0

        LDA     #$00
.L2BA0
        STA     L0031
        LDA     L007F
        CLC
        ADC     L0081
        BCC     L2BAB

        LDA     #$FF
.L2BAB
        STA     L0033
        LDA     L0080
        CLC
        ADC     L0084
        STA     L0032
        JSR     L1814

        LDA     L0080
        SEC
        SBC     L0081
        BCS     L2BC0

        LDA     #$00
.L2BC0
        CLC
        ADC     L0084
        STA     L0032
        LDA     L0080
        CLC
        ADC     L0081
        ADC     L0084
        CMP     #$98
        BCC     L2BD6

        LDX     L00A6
        BMI     L2BD6

        LDA     #$97
.L2BD6
        STA     L0034
        LDA     L007F
        STA     L0031
        STA     L0033
        JMP     L1621

.L2BE1
        LDA     #$68
        STA     L007F
        LDA     #$5A
        STA     L0080
        LDA     #$10
        STA     L0081
        JSR     L2B8D

        LDA     L030D
        STA     L003D
        JMP     L2C1C

.L2BF8
        LDA     L00A6
        BMI     L2BE1

        LDA     L030D
        LSR     A
        LSR     A
        STA     L003D
        LDA     L0301
        STA     L007F
        LDA     L0302
        LSR     A
        STA     L0080
        LDA     #$07
        STA     L0081
        JSR     L2B8D

        LDA     L0080
        CLC
        ADC     #$18
        STA     L0080
.L2C1C
        LDA     L007F
        STA     L00D2
        LDA     L0080
        STA     L00E0
        LDX     #$00
        STX     L00E1
        STX     L00D3
        INX
        STX     L0077
        LDX     #$02
        STX     L00B6
        JSR     L39F2

        RTS

.L2C35
        JSR     L27FA

        JSR     L30F1

        LDA     #$80
        STA     L007E
        LDA     #$00
        STA     L0CDC
.L2C44
        JSR     L3062

        LDA     L0CDA
        BNE     L2C5B

        JMP     L2CBD

.L2C4F
        LDY     #$B0
.L2C51
        JSR     L30DB

        TYA
        JSR     L305A

        JSR     L33D4

.L2C5B
        JSR     L2882

        LDA     #$CC
        JSR     L34CC

        LDA     L0CDC
        CLC
        ADC     #$D0
        JSR     L34CC

        LDA     #$2F
        JSR     L34CC

        JSR     L30CE

        LDA     #$3F
        JSR     L34CC

        JSR     L29B9

        LDX     #$00
        STX     L00A1
        LDX     #$0C
        STX     L0006
        JSR     L2CDB

        BCS     L2C4F

        STA     L001B
        JSR     L294A

        LDY     #$CE
        BCS     L2C51

        LDA     L0CD9
        STA     L00A0
        JSR     L3256

        JSR     L320E

        LDY     #$C5
        BCC     L2C51

        LDY     L0CDC
        LDA     L00A1
        PHA
        CLC
        ADC     L0317,Y
        STA     L0317,Y
        LDA     L0335,Y
        SEC
        SBC     L00A1
        STA     L0335,Y
        PLA
        BEQ     L2CBD

        JSR     L33CC

.L2CBD
        LDA     L0CDC
        CLC
        ADC     #$05
        STA     L002D
        LDA     #$00
        STA     L002C
        INC     L0CDC
        LDA     L0CDC
        CMP     #$11
        BCS     L2CD6

        JMP     L2C44

.L2CD6
        LDA     #$A7
        JMP     L3E53

.L2CDB
        LDX     #$00
        STX     L00A1
        LDX     #$0C
        STX     L0006
.L2CE3
        JSR     L43A5

        STA     L00A0
        SEC
        SBC     #$30
        BCC     L2D14

        CMP     #$0A
        BCS     L2CD6

        STA     L00A2
        LDA     L00A1
        CMP     #$1A
        BCS     L2D14

        ASL     A
        STA     L00D1
        ASL     A
        ASL     A
        ADC     L00D1
        ADC     L00A2
        STA     L00A1
        CMP     L0CDA
        BEQ     L2D0B

        BCS     L2D14

.L2D0B
        LDA     L00A0
        JSR     L1CF8

        DEC     L0006
        BNE     L2CE3

.L2D14
        LDA     L00A1
        RTS

.L2D17
        LDA     #$04
        JSR     L27FC

        LDA     #$04
        STA     L002D
        STA     L002C
        LDA     #$CD
        JSR     L34CC

        LDA     #$CE
        JSR     L34C7

.L2D2C
        LDY     #$00
.L2D2E
        STY     L0CDC
        LDX     L0317,Y
        BEQ     L2D8E

        TYA
        ASL     A
        ASL     A
        TAY
        LDA     L4457,Y
        STA     L0080
        TXA
        PHA
        JSR     L29B5

        CLC
        LDA     L0CDC
        ADC     #$D0
        JSR     L34CC

        LDA     #$0E
        STA     L002C
        PLA
        TAX
        CLC
        JSR     L1C33

        JSR     L30CE

        LDA     L00A6
        CMP     #$04
        BNE     L2D8E

        LDA     #$CD
        JSR     L2DC9

        BCC     L2D8E

        LDA     L0CDC
        LDX     #$FF
        STX     L007E
        JSR     L3062

        LDY     L0CDC
        LDA     L0317,Y
        STA     L001B
        LDA     L0CD9
        STA     L00A0
        JSR     L3256

        JSR     L3235

        LDA     #$00
        LDY     L0CDC
        STA     L0317,Y
        STA     L007E
.L2D8E
        LDY     L0CDC
        INY
        CPY     #$11
        BCS     L2D99

        JMP     L2D2E

.L2D99
        LDA     L00A6
        CMP     #$04
        BNE     L2DA5

        JSR     L33D4

        JMP     L2CD6

.L2DA5
        RTS

.L2DA6
        LDA     #$08
        JSR     L27FC

        LDA     #$0B
        STA     L002C
        LDA     #$A4
        JSR     L29B0

        JSR     L1802

        JSR     L3498

        LDA     L0316
        CMP     #$1A
        BCC     L2DC6

        LDA     #$6B
        JSR     L34CC

.L2DC6
        JMP     L2D2C

.L2DC9
        PHA
        JSR     L30DB

        PLA
        JSR     L34CC

        LDA     #$E1
        JSR     L34CC

        JSR     L43A5

        ORA     #$20
        CMP     #$79
        BEQ     L2DE4

        LDA     #$6E
        JMP     L1CF8

.L2DE4
        JSR     L1CF8

        SEC
        RTS

.L2DE9
        TXA
        PHA
        DEY
        TYA
        EOR     #$FF
        PHA
        JSR     L2E13

        PLA
        STA     L0082
        LDA     L0CF3
        JSR     L2E2B

        LDA     L0083
        STA     L0CF3
        STA     L0080
        PLA
        STA     L0082
        LDA     L0CF2
        JSR     L2E2B

        LDA     L0083
        STA     L0CF2
        STA     L007F
.L2E13
        LDA     L00A6
        BEQ     L2E3B

        BMI     L2E3C

        LDA     L0CF2
        STA     L007F
        LDA     L0CF3
        LSR     A
        STA     L0080
        LDA     #$04
        STA     L0081
        JMP     L2B8D

.L2E2B
        STA     L0083
        CLC
        ADC     L0082
        LDX     L0082
        BMI     L2E37

        BCC     L2E39

        RTS

.L2E37
        BCC     L2E3B

.L2E39
        STA     L0083
.L2E3B
        RTS

.L2E3C
        LDA     L0CF2
        SEC
        SBC     L0301
        CMP     #$26
        BCC     L2E4B

        CMP     #$E6
        BCC     L2E3B

.L2E4B
        ASL     A
        ASL     A
        CLC
        ADC     #$68
        STA     L007F
        LDA     L0CF3
        SEC
        SBC     L0302
        CMP     #$26
        BCC     L2E61

        CMP     #$DC
        BCC     L2E3B

.L2E61
        ASL     A
        CLC
        ADC     #$5A
        STA     L0080
        LDA     #$08
        STA     L0081
        JMP     L2B8D

.L2E6E
        LDA     #$80
        JSR     L27FC

        LDA     #$07
        STA     L002C
        LDA     #$BE
        JSR     L17FF

        JSR     L2BF8

        JSR     L2E13

        JSR     L2F02

        LDA     #$00
        STA     L00B8
        LDX     #$18
.L2E8B
        STA     L0053,X
        DEX
        BPL     L2E8B

.L2E90
        LDA     L007B
        SEC
        SBC     L0301
        BCS     L2E9C

        EOR     #$FF
        ADC     #$01
.L2E9C
        CMP     #$14
        BCS     L2EF8

        LDA     L0079
        SEC
        SBC     L0302
        BCS     L2EAC

        EOR     #$FF
        ADC     #$01
.L2EAC
        CMP     #$26
        BCS     L2EF8

        LDA     L007B
        SEC
        SBC     L0301
        ASL     A
        ASL     A
        ADC     #$68
        STA     L0037
        LSR     A
        LSR     A
        LSR     A
        STA     L002C
        INC     L002C
        LDA     L0079
        SEC
        SBC     L0302
        ASL     A
        ADC     #$5A
        STA     L0032
        LSR     A
        LSR     A
        LSR     A
        TAY
        LDX     L0053,Y
        BEQ     L2EE1

        INY
        LDX     L0053,Y
        BEQ     L2EE1

        DEY
        DEY
        LDX     L0053,Y
        BNE     L2EF1

.L2EE1
        STY     L002D
        CPY     #$03
        BCC     L2EF8

        DEX
        STX     L0053,Y
        LDA     #$80
        STA     L007E
        JSR     L343C

.L2EF1
        LDA     L0037
        STA     L0031
        JSR     L37A8

.L2EF8
        JSR     L2967

        INC     L00B8
        BEQ     L2F0C

        JMP     L2E90

.L2F02
        LDX     #$05
.L2F04
        LDA     L0303,X
        STA     L0078,X
        DEX
        BPL     L2F04

.L2F0C
        RTS

.L2F0D
        JSR     L2F02

        LDY     #$7F
        STY     L00D1
        LDA     #$00
        STA     L008F
.L2F18
        LDA     L007B
        SEC
        SBC     L0CF2
        BCS     L2F24

        EOR     #$FF
        ADC     #$01
.L2F24
        LSR     A
        STA     L00A2
        LDA     L0079
        SEC
        SBC     L0CF3
        BCS     L2F33

        EOR     #$FF
        ADC     #$01
.L2F33
        LSR     A
        CLC
        ADC     L00A2
        CMP     L00D1
        BCS     L2F46

        STA     L00D1
        LDX     #$05
.L2F3F
        LDA     L0078,X
        STA     L007F,X
        DEX
        BPL     L2F3F

.L2F46
        JSR     L2967

        INC     L008F
        BNE     L2F18

        LDX     #$05
.L2F4F
        LDA     L007F,X
        STA     L0078,X
        DEX
        BPL     L2F4F

        LDA     L0079
        STA     L0CF3
        LDA     L007B
        STA     L0CF2
        SEC
        SBC     L0301
        BCS     L2F6A

        EOR     #$FF
        ADC     #$01
.L2F6A
        JSR     L23F0

        STA     L003E
        LDA     L001B
        STA     L003D
        LDA     L0CF3
        SEC
        SBC     L0302
        BCS     L2F80

        EOR     #$FF
        ADC     #$01
.L2F80
        LSR     A
        JSR     L23F0

        PHA
        LDA     L001B
        CLC
        ADC     L003D
        STA     L00A0
        PLA
        ADC     L003E
        STA     L00A1
        JSR     L45F5

        LDA     L00A0
        ASL     A
        LDX     #$00
        STX     L0CF1
        ROL     L0CF1
        ASL     A
        ROL     L0CF1
        STA     L0CF0
        JMP     L2ACF

.L2FA9
        JSR     L2882

        LDA     #$0F
        STA     L002C
        JMP     L34CC

.L2FB3
        LDA     L00AF
        BNE     L2FA9

        LDA     L002F
        BNE     L3024

        LDX     #$01
        JSR     L42D8

        BMI     L2FFD

        JSR     L2875

        LDA     L0CF0
        ORA     L0CF1
        BEQ     L3024

        LDA     #$07
        STA     L002C
        LDA     #$17
        STA     L002D
        LDA     #$00
        STA     L007E
        LDA     #$BD
        JSR     L34CC

        LDA     L0CF1
        BNE     L3058

        LDA     L030D
        CMP     L0CF0
        BCC     L3058

        LDA     #$2D
        JSR     L34CC

        JSR     L343C

.L2FF3
        LDA     #$0F
        STA     L002F
        STA     L002E
        TAX
        JMP     L304B

.L2FFD
        LDX     L032D
        BEQ     L3024

        INX
        STX     L032D
        STX     L0334
        JSR     L2FF3

        LDX     #$05
        INC     L030F
        LDA     L030F
        AND     #$07
        STA     L030F
.L3019
        LDA     L0303,X
        ASL     A
        ROL     L0303,X
        DEX
        BPL     L3019

.L3023
        LDA     #$60
L3024 = L3023+1
        STA     L0CF2
        STA     L0CF3
        JSR     L31D7

        JSR     L2F0D

        LDX     #$00
        STX     L0CF0
        STX     L0CF1
        LDA     #$74
        JSR     L43C3

.L303E
        LDA     L0CF2
        STA     L0301
        LDA     L0CF3
        STA     L0302
        RTS

.L304B
        LDY     #$01
        STY     L002D
        DEY
        STY     L002C
.L3052
        CLC
.L3053
        LDA     #$05
        JMP     L1C37

.L3058
        LDA     #$CA
.L305A
        JSR     L34CC

        LDA     #$3F
        JMP     L34CC

.L3062
        PHA
        STA     L0083
        ASL     A
        ASL     A
        STA     L007F
        LDA     #$01
        STA     L002C
        PLA
        ADC     #$D0
        JSR     L34CC

        LDA     #$0E
        STA     L002C
        LDX     L007F
        LDA     L4457,X
        STA     L0080
        LDA     L0346
        AND     L4459,X
        CLC
        ADC     L4456,X
        STA     L0CD9
        JSR     L30CE

        JSR     L3127

        LDA     L0080
        BMI     L309D

        LDA     L0CD9
        ADC     L0082
        JMP     L30A3

.L309D
        LDA     L0CD9
        SEC
        SBC     L0082
.L30A3
        STA     L0CD9
        STA     L001B
        LDA     #$00
        JSR     L3259

        SEC
        JSR     L3053

        LDY     L0083
        LDA     #$05
        LDX     L0335,Y
        STX     L0CDA
        CLC
        BEQ     L30C4

        JSR     L1C35

        JMP     L30CE

.L30C4
        LDA     L002C
        ADC     #$04
        STA     L002C
        LDA     #$2D
        BNE     L30DD

.L30CE
        LDA     L0080
        AND     #$60
        BEQ     L30E0

        CMP     #$20
        BEQ     L30E7

        JSR     L30EC

.L30DB
        LDA     #$20
.L30DD
        JMP     L34CC

.L30E0
        LDA     #$74
        JSR     L1CF8

        BCC     L30DB

.L30E7
        LDA     #$6B
        JSR     L1CF8

.L30EC
        LDA     #$67
        JMP     L1CF8

.L30F1
        LDA     #$11
        STA     L002C
        LDA     #$FF
        BNE     L30DD

.L30F9
        LDA     #$10
        JSR     L27FC

        LDA     #$05
        STA     L002C
        LDA     #$A7
        JSR     L17FF

        LDA     #$03
        STA     L002D
        JSR     L30F1

        LDA     #$00
        STA     L0CDC
.L3113
        LDX     #$80
        STX     L007E
        JSR     L3062

        INC     L002D
        INC     L0CDC
        LDA     L0CDC
        CMP     #$11
        BCC     L3113

        RTS

.L3127
        LDA     L0080
        AND     #$1F
        LDY     L0CDB
        STA     L0081
        CLC
        LDA     #$00
        STA     L0345
.L3136
        DEY
        BMI     L313E

        ADC     L0081
        JMP     L3136

.L313E
        STA     L0082
        RTS

.L3141
        JSR     L2F0D

        JSR     L303E

        LDX     #$05
.L3149
        LDA     L0078,X
        STA     L0CE3,X
        DEX
        BPL     L3149

        INX
        STX     L0C05
        LDA     L0CE9
        STA     L0CDB
        LDA     L0CEB
        STA     L0CDE
        LDA     L0CEA
        STA     L0CDD
        RTS

.L3168
        JSR     L3D25

        STA     L0346
        LDX     #$00
        STX     L00B7
.L3172
        LDA     L4457,X
        STA     L0080
        JSR     L3127

        LDA     L4459,X
        AND     L0346
        CLC
        ADC     L4458,X
        LDY     L0080
        BMI     L318E

        SEC
        SBC     L0082
        JMP     L3191

.L318E
        CLC
        ADC     L0082
.L3191
        BPL     L3195

        LDA     #$00
.L3195
        LDY     L00B7
        AND     #$3F
        STA     L0335,Y
        INY
        TYA
        STA     L00B7
        ASL     A
        ASL     A
        TAX
        CMP     #$3F
        BCC     L3172

.L31A7
        RTS

.L31A8
        LDA     L030D
        SEC
        SBC     L0CF0
        STA     L030D
        LDA     L00A6
        BNE     L31BC

        JSR     L27FC

        JSR     L21E5

.L31BC
        JSR     L3141

        JSR     L3168

        JSR     L3C84

        JSR     L36B3

        LDA     L00A6
        AND     #$3F
        BNE     L31A7

        JSR     L27FE

        LDA     L00A6
        BNE     L3206

        INC     L00A6
.L31D7
        LDX     L00AF
        BEQ     L31FF

        JSR     L21F8

        JSR     L3C84

        JSR     L2F0D

        INC     L005B
        JSR     L36A0

        LDA     #$80
        STA     L005B
        INC     L005A
        JSR     L3859

        LDA     #$0C
        STA     L008C
        JSR     L3F28

        ORA     L0334
        STA     L0334
.L31FF
        LDX     #$00
        STX     L00AF
        JMP     L27C5

.L3206
        BMI     L320B

        JMP     L2B42

.L320B
        JMP     L2E6E

.L320E
        STX     L0006
        LDA     L030C
        SEC
        SBC     L0006
        STA     L030C
        STY     L0006
        LDA     L030B
        SBC     L0006
        STA     L030B
        LDA     L030A
        SBC     #$00
        STA     L030A
        LDA     L0309
        SBC     #$00
        STA     L0309
        BCS     L3255

.L3235
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
        LDA     L0309
        ADC     #$00
        STA     L0309
        CLC
.L3255
        RTS

.L3256
        JSR     L2403

.L3259
        ASL     L001B
        ROL     A
        ASL     L001B
        ROL     A
        TAY
        LDX     L001B
        RTS

.L3263
        JMP     L400E

.L3266
        JSR     L1D83

        LDA     #$20
        JSR     L27FC

        LDA     #$0C
        STA     L002C
        LDA     #$CF
        JSR     L29C6

        LDA     #$B9
        JSR     L17FF

        LDA     #$80
        STA     L007E
        INC     L002D
        LDA     L0CDE
        CLC
        ADC     #$03
        CMP     #$0C
        BCC     L328E

        LDA     #$0C
.L328E
        STA     L00A0
        STA     L0CDA
        INC     L00A0
        LDA     #$46
        SEC
        SBC     L030D
        ASL     A
        STA     L1B45
        LDX     #$01
.L32A1
        STX     L00A8
        JSR     L29B9

        LDX     L00A8
        CLC
        JSR     L1C33

        JSR     L30DB

        LDA     L00A8
        CLC
        ADC     #$68
        JSR     L34CC

        LDA     L00A8
        JSR     L33EC

        SEC
        LDA     #$19
        STA     L002C
        LDA     #$06
        JSR     L1C37

        LDX     L00A8
        INX
        CPX     L00A0
        BCC     L32A1

        JSR     L2882

        LDA     #$7F
        JSR     L305A

        JSR     L2CDB

        BEQ     L3263

        BCS     L3263

        SBC     #$00
        LDX     #$02
        STX     L002C
        INC     L002D
        PHA
        JSR     L33DC

        PLA
        BNE     L32F2

        STA     L00A9
        LDX     #$46
        STX     L030D
.L32F2
        CMP     #$01
        BNE     L3306

        LDX     L0333
        INX
        LDY     #$75
        CPX     #$05
        BCS     L3368

        STX     L0333
        JSR     L3CDC

.L3306
        LDY     #$6B
        CMP     #$02
        BNE     L3316

        LDX     #$25
        CPX     L0316
        BEQ     L3368

        STX     L0316
.L3316
        CMP     #$03
        BNE     L3323

        INY
        LDX     L0328
        BNE     L3368

        DEC     L0328
.L3323
        CMP     #$04
        BNE     L333C

        JSR     L33F9

        LDA     #$04
        LDY     L0310,X
        BEQ     L3335

.L3331
        LDY     #$BB
        BNE     L3368

.L3335
        LDA     #$0F
        STA     L0310,X
        LDA     #$04
.L333C
        CMP     #$05
        BNE     L335D

        JSR     L33F9

        STX     L0006
        LDA     #$05
        LDY     L0310,X
        BEQ     L3356

        BMI     L3331

        LDA     #$04
        JSR     L33EF

        JSR     L3235

.L3356
        LDA     #$8F
        LDX     L0006
        STA     L0310,X
.L335D
        LDY     #$6F
        CMP     #$06
        BNE     L3383

        LDX     L0329
        BEQ     L3380

.L3368
        STY     L003D
        JSR     L33EF

        JSR     L3235

        LDA     L003D
        JSR     L29C6

        LDA     #$1F
        JSR     L34CC

.L337A
        JSR     L33D4

        JMP     L400E

.L3380
        DEC     L0329
.L3383
        INY
        CMP     #$07
        BNE     L3390

        LDX     L032E
        BNE     L3368

        DEC     L032E
.L3390
        INY
        CMP     #$08
        BNE     L339F

        LDX     L032A
        BNE     L3368

        LDX     #$7F
        STX     L032A
.L339F
        INY
        CMP     #$09
        BNE     L33AC

        LDX     L032B
        BNE     L3368

        INC     L032B
.L33AC
        INY
        CMP     #$0A
        BNE     L33B9

        LDX     L032C
        BNE     L3368

        DEC     L032C
.L33B9
        INY
        CMP     #$0B
        BNE     L33C6

        LDX     L032D
        BNE     L3368

        DEC     L032D
.L33C6
        JSR     L33CC

        JMP     L3266

.L33CC
        JSR     L30DB

        LDA     #$77
        JSR     L29C6

.L33D4
        JSR     L4280

        LDY     #$C8
        JMP     L2864

.L33DC
        JSR     L33EF

        JSR     L320E

        BCS     L33F8

        LDA     #$C5
        JSR     L305A

        JMP     L337A

.L33EC
        SEC
        SBC     #$01
.L33EF
        ASL     A
        TAY
        LDX     L1B45,Y
        LDA     L1B46,Y
        TAY
.L33F8
        RTS

.L33F9
        LDY     #$10
        STY     L002D
.L33FD
        LDX     #$0C
        STX     L002C
        TYA
        CLC
        ADC     #$20
        JSR     L29C6

        LDA     L002D
        CLC
        ADC     #$50
        JSR     L34CC

        INC     L002D
        LDY     L002D
        CPY     #$14
        BCC     L33FD

.L3418
        JSR     L2882

        LDA     #$AF
        JSR     L305A

        JSR     L43A5

        SEC
        SBC     #$30
        CMP     #$04
        BCS     L3418

        TAX
        RTS

        EQUB    $8C

        EQUB    $E7,$8D,$E6,$C1,$C8,$C8,$E6,$D6
        EQUB    $C5,$C6,$C1,$CA,$83,$9C,$90

.L343C
        LDX     #$05
.L343E
        LDA     L0078,X
        STA     L007F,X
        DEX
        BPL     L343E

        LDY     #$03
        BIT     L0078
        BVS     L344C

        DEY
.L344C
        STY     L00D1
.L344E
        LDA     L007D
        AND     #$1F
        BEQ     L3459

        ORA     #$80
        JSR     L34CC

.L3459
        JSR     L296D

        DEC     L00D1
        BPL     L344E

        LDX     #$05
.L3462
        LDA     L007F,X
        STA     L0078,X
        DEX
        BPL     L3462

        RTS

.L346A
        LDY     #$00
.L346C
        LDA     L159D,Y
        CMP     #$0D
        BEQ     L3479

        JSR     L1CF8

        INY
        BNE     L346C

.L3479
        RTS

.L347A
        JSR     L3480

        JSR     L343C

.L3480
        LDX     #$05
.L3482
        LDA     L0078,X
        LDY     L0CE3,X
        STA     L0CE3,X
        STY     L0078,X
        DEX
        BPL     L3482

        RTS

.L3490
        CLC
        LDX     L030F
        INX
        JMP     L1C33

.L3498
        LDA     #$69
        JSR     L34C7

        LDX     L030D
        SEC
        JSR     L1C33

        LDA     #$C3
        JSR     L34C1

        LDA     #$77
        BNE     L34CC

.L34AD
        LDX     #$03
.L34AF
        LDA     L0309,X
        STA     L003D,X
        DEX
        BPL     L34AF

        LDA     #$09
        STA     L008F
        SEC
        JSR     L1C43

        LDA     #$E2
.L34C1
        JSR     L34CC

        JMP     L29B9

.L34C7
        JSR     L34CC

.L34CA
        LDA     #$3A
.L34CC
        TAX
        BEQ     L34AD

        BMI     L3545

        DEX
        BEQ     L3490

        DEX
        BEQ     L347A

        DEX
        BNE     L34DD

        JMP     L343C

.L34DD
        DEX
        BEQ     L346A

        DEX
        BEQ     L3498

        DEX
        BNE     L34EB

        LDA     #$80
        STA     L007E
        RTS

.L34EB
        DEX
        DEX
        BNE     L34F2

        STX     L007E
        RTS

.L34F2
        DEX
        BEQ     L352D

        CMP     #$60
        BCS     L355F

        CMP     #$0E
        BCC     L3501

        CMP     #$20
        BCC     L3529

.L3501
        LDX     L007E
        BEQ     L3542

        BMI     L3518

        BIT     L007E
        BVS     L353B

.L350B
        CMP     #$41
        BCC     L3515

        CMP     #$5B
        BCS     L3515

        ADC     #$20
.L3515
        JMP     L1CF8

.L3518
        BIT     L007E
        BVS     L3533

        CMP     #$41
        BCC     L3542

        PHA
        TXA
        ORA     #$40
        STA     L007E
        PLA
        BNE     L3515

.L3529
        ADC     #$72
        BNE     L355F

.L352D
        LDA     #$15
        STA     L002C
        BNE     L34CA

.L3533
        CPX     #$FF
        BEQ     L359A

        CMP     #$41
        BCS     L350B

.L353B
        PHA
        TXA
        AND     #$BF
        STA     L007E
        PLA
.L3542
        JMP     L1CF8

.L3545
        CMP     #$A0
        BCS     L355D

        AND     #$7F
        ASL     A
        TAY
        LDA     L4416,Y
        JSR     L34CC

        LDA     L4417,Y
        CMP     #$3F
        BEQ     L359A

        JMP     L34CC

.L355D
        SBC     #$A0
.L355F
        TAX
        LDA     #$00
        STA     L0022
        LDA     #$04
        STA     L0023
        LDY     #$00
        TXA
        BEQ     L3580

.L356D
        LDA     (L0022),Y
        BEQ     L3578

        INY
        BNE     L356D

        INC     L0023
        BNE     L356D

.L3578
        INY
        BNE     L357D

        INC     L0023
.L357D
        DEX
        BNE     L356D

.L3580
        TYA
        PHA
        LDA     L0023
        PHA
        LDA     (L0022),Y
        EOR     #$23
        JSR     L34CC

        PLA
        STA     L0023
        PLA
        TAY
        INY
        BNE     L3596

        INC     L0023
.L3596
        LDA     (L0022),Y
        BNE     L3580

.L359A
        RTS

.L359B
        LDA     L0072
        ORA     #$A0
        STA     L0072
        RTS

.L35A2
        LDA     L0072
        AND     #$40
        BEQ     L35AB

        JSR     L3605

.L35AB
        LDA     L0059
        STA     L00D1
        LDA     L005A
        CMP     #$20
        BCC     L35B9

        LDA     #$FE
        BNE     L35C1

.L35B9
        ASL     L00D1
        ROL     A
        ASL     L00D1
        ROL     A
        SEC
        ROL     A
.L35C1
        STA     L00A0
        LDY     #$01
        LDA     (L0074),Y
        ADC     #$04
        BCS     L359B

        STA     (L0074),Y
        JSR     L2546

        LDA     L001B
        CMP     #$1C
        BCC     L35DA

        LDA     #$FE
        BNE     L35E3

.L35DA
        ASL     L00A1
        ROL     A
        ASL     L00A1
        ROL     A
        ASL     L00A1
        ROL     A
.L35E3
        DEY
        STA     (L0074),Y
        LDA     L0072
        AND     #$BF
        STA     L0072
        AND     #$08
        BEQ     L359A

        LDY     #$02
        LDA     (L0074),Y
        TAY
.L35F5
        LDA     L00F9,Y
        STA     (L0074),Y
        DEY
        CPY     #$06
        BNE     L35F5

        LDA     L0072
        ORA     #$40
        STA     L0072
.L3605
        LDY     #$00
        LDA     (L0074),Y
        STA     L00A0
        INY
        LDA     (L0074),Y
        BPL     L3612

        EOR     #$FF
.L3612
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        ORA     #$01
        STA     L008F
        INY
        LDA     (L0074),Y
        STA     L00B0
        LDA     L0001
        PHA
        LDY     #$06
.L3624
        LDX     #$03
.L3626
        INY
        LDA     (L0074),Y
        STA     L00D2,X
        DEX
        BPL     L3626

        STY     L00B4
        LDY     #$02
.L3632
        INY
        LDA     (L0074),Y
        EOR     L00B4
        STA     LFFFD,Y
        CPY     #$06
        BNE     L3632

        LDY     L008F
.L3640
        JSR     L3D24

        STA     L00A7
        LDA     L00D3
        STA     L00A1
        LDA     L00D2
        JSR     L367E

        BNE     L3678

        CPX     #$BF
        BCS     L3678

        STX     L0032
        LDA     L00D5
        STA     L00A1
        LDA     L00D4
        JSR     L367E

        BNE     L3666

        LDA     L0032
        JSR     L1846

.L3666
        DEY
        BPL     L3640

        LDY     L00B4
        CPY     L00B0
        BCC     L3624

        PLA
        STA     L0001
        LDA     L0906
        STA     L0003
        RTS

.L3678
        JSR     L3D24

        JMP     L3666

.L367E
        STA     L00A2
        JSR     L3D24

        ROL     A
        BCS     L3691

        JSR     L242A

        ADC     L00A1
        TAX
        LDA     L00A2
        ADC     #$00
        RTS

.L3691
        JSR     L242A

        STA     L00D1
        LDA     L00A1
        SBC     L00D1
        TAX
        LDA     L00A2
        SBC     #$00
        RTS

.L36A0
        JSR     L3CDC

        LDA     #$7F
        STA     L0070
        STA     L0071
        LDA     L0CDE
        AND     #$02
        ORA     #$80
        JMP     L387E

.L36B3
        LSR     L0334
        JSR     L3CC7

        LDA     L0079
        AND     #$07
        ADC     #$06
        LSR     A
        STA     L005B
        ROR     A
        STA     L0055
        STA     L0058
        JSR     L36A0

        LDA     #$81
        JSR     L387E

.L36CF
        LDA     L00A6
        BNE     L36F5

.L36D3
        LDY     #$0A
.L36D5
        JSR     L3D25

        ORA     #$08
        STA     L0CB9,Y
        STA     L00A7
        JSR     L3D25

        STA     L034C,Y
        STA     L0031
        JSR     L3D25

        STA     L0362,Y
        STA     L0032
        JSR     L1824

        DEY
        BNE     L36D5

.L36F5
        LDX     #$00
.L36F7
        LDA     L0BE0,X
        BEQ     L371F

        BMI     L371C

        STA     L00AB
        JSR     L384B

        LDY     #$1F
.L3705
        LDA     (L0020),Y
        STA     L0053,Y
        DEY
        BPL     L3705

        STX     L00A3
        JSR     L28A4

        LDX     L00A3
        LDY     #$1F
        LDA     (L0020),Y
        AND     #$A7
        STA     (L0020),Y
.L371C
        INX
        BNE     L36F7

.L371F
        LDX     #$FF
        STX     L0C5E
        STX     L0C86
.L3727
        DEX
        RTS

.L3729
        INX
        BEQ     L3727

.L372C
        DEC     L0CD4
        PHP
        BNE     L3735

        INC     L0CD4
.L3735
        PLP
        RTS

.L3737
        JSR     L3797

        LDA     L0BF4
        BNE     L3770

        JSR     L418D

        JMP     L3773

.L3745
        ASL     A
        TAX
        LDA     #$00
        ROR     A
        TAY
        LDA     #$14
        STA     L00A0
        TXA
        JSR     L2546

        LDX     L001B
        TYA
        BMI     L375B

        LDY     #$00
        RTS

.L375B
        LDY     #$FF
        TXA
        EOR     #$FF
        TAX
        INX
        RTS

.L3763
        LDX     #$08
.L3765
        LDA     L0924,X
        STA     L00D2,X
        DEX
        BPL     L3765

        JMP     L419C

.L3770
        JSR     L3763

.L3773
        LDA     L0031
        JSR     L3745

        TXA
        ADC     #$C1
        STA     L0CD7
        LDA     L0032
        JSR     L3745

        STX     L00D1
        LDA     #$CC
        SBC     L00D1
        STA     L0CD8
        LDA     #$F0
        LDX     L0033
        BPL     L3794

        LDA     #$FF
.L3794
        STA     L0D1C
.L3797
        LDA     L0CD8
        STA     L0032
        LDA     L0CD7
        STA     L0031
        LDA     L0D1C
        CMP     #$F0
        BNE     L37AD

.L37A8
        JSR     L37AD

        DEC     L0032
.L37AD
        LDY     #$80
        STY     L0007
        LDA     L0032
        LSR     A
        LSR     A
        LSR     A
        STA     L0008
        LSR     A
        ROR     L0007
        LSR     A
        ROR     L0007
        ADC     L0008
        ADC     #$58
        STA     L0008
        LDA     L0031
        AND     #$F8
        ADC     L0007
        STA     L0007
        BCC     L37D0

        INC     L0008
.L37D0
        LDA     L0032
        AND     #$07
        TAY
        LDA     L0031
        AND     #$07
        TAX
        LDA     L160B,X
        EOR     (L0007),Y
        STA     (L0007),Y
        JSR     L37E4

.L37E4
        INX
        LDA     L160B,X
        BPL     L37F8

        LDA     L0007
        CLC
        ADC     #$08
        STA     L0007
        BCC     L37F5

        INC     L0008
.L37F5
        LDA     L160B,X
.L37F8
        EOR     (L0007),Y
        STA     (L0007),Y
        RTS

.L37FD
        STA     L00D1
        LDY     #$08
        LDX     #$00
        LDA     (L0020),Y
        BMI     L3817

        LDA     L0CD2
        SBC     L00D1
        BCC     L3812

        STA     L0CD2
        RTS

.L3812
        STX     L0CD2
        BCC     L3825

.L3817
        LDA     L0CD3
        SBC     L00D1
        BCC     L3822

        STA     L0CD3
        RTS

.L3822
        STX     L0CD3
.L3825
        ADC     L0CD4
        STA     L0CD4
        BEQ     L382F

        BCS     L3832

.L382F
        JMP     L3F48

.L3832
        JSR     L4246

        JMP     L43E7

.L3838
        LDA     L0901,X
        STA     L00D2,X
        LDA     L0902,X
        TAY
        AND     #$7F
        STA     L00D3,X
        TYA
        AND     #$80
        STA     L00D4,X
        RTS

.L384B
        TXA
        ASL     A
        TAY
        LDA     L15F1,Y
        STA     L0020
        LDA     L15F2,Y
        STA     L0021
        RTS

.L3859
        JSR     L3923

        LDX     #$01
        STX     L0073
        DEX
        STX     L0071
        STX     L0BE1
        DEX
        STX     L0070
        LDX     #$0A
        JSR     L38FA

        JSR     L38FA

        JSR     L38FA

        LDA     #$08
        STA     L0074
        LDA     #$0C
        STA     L0075
        LDA     #$07
.L387E
        STA     L00D1
        LDX     #$00
.L3882
        LDA     L0BE0,X
        BEQ     L388E

        INX
        CPX     #$0C
        BCC     L3882

        CLC
.L388D
        RTS

.L388E
        JSR     L384B

        LDA     L00D1
        BMI     L38E5

        ASL     A
        TAY
        LDA     L4ED2,Y
        STA     L001E
        LDA     L4ED3,Y
        STA     L001F
        CPY     #$0E
        BEQ     L38D5

        LDY     #$05
        LDA     (L001E),Y
        STA     L0006
        LDA     L0CDF
        SEC
        SBC     L0006
        STA     L0074
        LDA     L0CE0
        SBC     #$00
        STA     L0075
        LDA     L0074
        SBC     L0020
        TAY
        LDA     L0075
        SBC     L0021
        BCC     L388D

        BNE     L38CB

        CPY     #$24
        BCC     L388D

.L38CB
        LDA     L0074
        STA     L0CDF
        LDA     L0075
        STA     L0CE0
.L38D5
        LDY     #$0E
        LDA     (L001E),Y
        STA     L0076
        LDY     #$13
        LDA     (L001E),Y
        AND     #$07
        STA     L0072
        LDA     L00D1
.L38E5
        STA     L0BE0,X
        TAX
        BMI     L38EE

        INC     L0BED,X
.L38EE
        LDY     #$23
.L38F0
        LDA     L0053,Y
        STA     (L0020),Y
        DEY
        BPL     L38F0

        SEC
        RTS

.L38FA
        LDA     L0053,X
        EOR     #$80
        STA     L0053,X
        INX
        INX
        RTS

.L3903
        LDY     #$09
.L3905
        LDX     #$FF
.L3907
        STX     L0052
        LDX     L0333
        JSR     L3940

        STY     L0C00
        RTS

.L3913
        LDA     #$20
        STA     L0030
        ASL     A
        JSR     L4282

.L391B
        LDA     #$98
        LDX     #$35
        LDY     #$7C
        BNE     L3929

.L3923
        LDA     #$20
        LDX     #$38
        LDY     #$7D
.L3929
        STA     L0007
        STX     L001C
        LDX     #$39
        STX     L001D
        TYA
        JMP     L1D66

        INC     LE0FE,X
        INC     LE0FE,X
        INC     L0EFE,X
.L393E
        INC     L8AFE,X
L3940 = L393E+2
        PHA
        ASL     A
        ASL     A
        ASL     A
        STA     L00D1
        LDA     #$D1
        SBC     L00D1
        STA     L0007
        LDA     #$7D
        STA     L0008
        TYA
        TAX
        LDY     #$05
.L3955
        LDA     L3961,X
        STA     (L0007),Y
        DEX
        DEY
        BNE     L3955

        PLA
        TAX
        RTS

.L3961
        EQUB    $00

        EQUB    $00,$00,$00,$00,$FC,$FC,$FC,$FC
        EQUB    $FC,$84,$B4,$84,$FC,$C4,$EC,$EC
        EQUB    $FC

.L3973
        LDA     L0053
        STA     L001B
        LDA     L0054
        STA     L001C
        LDA     L0055
        JSR     L3ACC

        BCS     L39AA

        LDA     L003D
        ADC     #$80
        STA     L00D2
        TXA
        ADC     #$00
        STA     L00D3
        LDA     L0056
        STA     L001B
        LDA     L0057
        STA     L001C
        LDA     L0058
        EOR     #$80
        JSR     L3ACC

        BCS     L39AA

        LDA     L003D
        ADC     #$60
        STA     L00E0
        TXA
        ADC     #$00
        STA     L00E1
        CLC
.L39AA
        RTS

.L39AB
        JMP     L3A4F

.L39AE
        LDA     L00AB
        LSR     A
        BCS     L39AA

        LDA     L005B
        BMI     L39AB

        CMP     #$30
        BCS     L39AB

        ORA     L005A
        BEQ     L39AB

        JSR     L3973

        BCS     L39AB

        LDA     #$60
        STA     L001C
        LDA     #$00
        STA     L001B
        JSR     L255F

        LDA     L003E
        BEQ     L39D7

        LDA     #$F8
        STA     L003D
.L39D7
        JSR     L3A4F

        JMP     L39DD

.L39DD
        JSR     L3A92

        BCS     L39AA

        LDA     #$00
        STA     L0C5E
        LDX     L003D
        LDA     #$08
        CPX     #$09
        BCC     L39F0

        LSR     A
.L39F0
        STA     L00B6
.L39F2
        LDX     #$FF
        STX     L00B3
        INX
        STX     L00B4
.L39F9
        LDA     L00B4
        JSR     L2420

        LDX     #$00
        STX     L00D1
        LDX     L00B4
        CPX     #$21
        BCC     L3A15

        EOR     #$FF
        ADC     #$00
        TAX
        LDA     #$FF
        ADC     #$00
        STA     L00D1
        TXA
        CLC
.L3A15
        ADC     L00D2
        STA     L0082
        LDA     L00D3
        ADC     L00D1
        STA     L0083
        LDA     L00B4
        CLC
        ADC     #$10
        JSR     L2420

        TAX
        LDA     #$00
        STA     L00D1
        LDA     L00B4
        ADC     #$0F
        AND     #$3F
        CMP     #$21
        BCC     L3A43

        TXA
        EOR     #$FF
        ADC     #$00
        TAX
        LDA     #$FF
        ADC     #$00
        STA     L00D1
        CLC
.L3A43
        JSR     L1893

        CMP     #$41
        BCS     L3A4D

        JMP     L39F9

.L3A4D
        CLC
        RTS

.L3A4F
        LDY     L0C5E
        BNE     L3A88

.L3A54
        CPY     L0077
        BCS     L3A88

        LDA     L0C86,Y
        CMP     #$FF
        BEQ     L3A79

        STA     L0034
        LDA     L0C5E,Y
        STA     L0033
        JSR     L1621

        INY
        LDA     L00B1
        BNE     L3A54

        LDA     L0033
        STA     L0031
        LDA     L0034
        STA     L0032
        JMP     L3A54

.L3A79
        INY
        LDA     L0C5E,Y
        STA     L0031
        LDA     L0C86,Y
        STA     L0032
        INY
        JMP     L3A54

.L3A88
        LDA     #$01
        STA     L0077
        LDA     #$FF
        STA     L0C5E
        RTS

.L3A92
        LDA     L00D2
        CLC
        ADC     L003D
        LDA     L00D3
        ADC     #$00
        BMI     L3ACA

        LDA     L00D2
        SEC
        SBC     L003D
        LDA     L00D3
        SBC     #$00
        BMI     L3AAA

        BNE     L3ACA

.L3AAA
        LDA     L00E0
        CLC
        ADC     L003D
        STA     L001C
        LDA     L00E1
        ADC     #$00
        BMI     L3ACA

        STA     L001D
        LDA     L00E0
        SEC
        SBC     L003D
        TAX
        LDA     L00E1
        SBC     #$00
        BMI     L3AEF

        BNE     L3ACA

        CPX     #$BF
        RTS

.L3ACA
        SEC
        RTS

.L3ACC
        JSR     L255F

        LDA     L0040
        AND     #$7F
        ORA     L003F
        BNE     L3ACA

        LDX     L003E
        CPX     #$04
        BCS     L3AF0

        LDA     L0040
        BPL     L3AF0

        LDA     L003D
        EOR     #$FF
        ADC     #$01
        STA     L003D
        TXA
        EOR     #$FF
        ADC     #$00
        TAX
.L3AEF
        CLC
.L3AF0
        RTS

.L3AF1
        JSR     L431E

        LDX     L0D24
        BEQ     L3B1B

        LDA     L00AC
        EOR     #$FF
        JSR     L3B04

        TYA
        TAX
        LDA     L00AD
.L3B04
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
        LDA     L0041
        RTS

.L3B1B
        LDA     L0041
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

.L3B34
        LDX     #$01
.L3B36
        LDA     L0301,X
        STA     L0CF2,X
        DEX
        BPL     L3B36

        RTS

.L3B40
        LDA     L001B
        STA     L0CDF
        LDA     L001C
        STA     L0CE0
        RTS

.L3B4B
        LDX     L00A3
        JSR     L3BA3

        LDX     L00A3
        JMP     L0E80

.L3B55
        JSR     L3CC7

        LDA     #$00
        STA     L0BE1
        STA     L0BF4
        JSR     L3923

        LDA     #$06
        STA     L0058
        LDA     #$81
        JMP     L387E

.L3B6C
        LDX     #$FF
.L3B6E
        INX
        LDA     L0BE0,X
        BEQ     L3B40

        CMP     #$08
        BNE     L3B6E

        TXA
        ASL     A
        TAY
        LDA     L15F1,Y
        STA     L0007
        LDA     L15F2,Y
        STA     L0008
        LDY     #$20
        LDA     (L0007),Y
        BPL     L3B6E

        AND     #$7F
        LSR     A
        CMP     L00B7
        BCC     L3B6E

        BEQ     L3B9D

        SBC     #$01
        ASL     A
        ORA     #$80
        STA     (L0007),Y
        BNE     L3B6E

.L3B9D
        LDA     #$00
        STA     (L0007),Y
        BEQ     L3B6E

.L3BA3
        STX     L00B7
        LDA     L0052
        CMP     L00B7
        BNE     L3BB3

        JSR     L3903

        LDA     #$C8
        JSR     L43C3

.L3BB3
        LDY     L00B7
        LDX     L0BE0,Y
        CPX     #$07
        BEQ     L3B55

        DEC     L0BED,X
        LDX     L00B7
        LDY     #$05
        LDA     (L001E),Y
        LDY     #$21
        CLC
        ADC     (L0020),Y
        STA     L001B
        INY
        LDA     (L0020),Y
        ADC     #$00
        STA     L001C
.L3BD3
        INX
        LDA     L0BE0,X
        STA     L0BDF,X
        BEQ     L3B6C

        ASL     A
        TAY
        LDA     L4ED2,Y
        STA     L0007
        LDA     L4ED3,Y
        STA     L0008
        LDY     #$05
        LDA     (L0007),Y
        STA     L00D1
        LDA     L001B
        SEC
        SBC     L00D1
        STA     L001B
        LDA     L001C
        SBC     #$00
        STA     L001C
        TXA
        ASL     A
        TAY
        LDA     L15F1,Y
        STA     L0007
        LDA     L15F2,Y
        STA     L0008
        LDY     #$23
        LDA     (L0007),Y
        STA     (L0020),Y
        DEY
        LDA     (L0007),Y
        STA     L003E
        LDA     L001C
        STA     (L0020),Y
        DEY
        LDA     (L0007),Y
        STA     L003D
        LDA     L001B
        STA     (L0020),Y
        DEY
.L3C21
        LDA     (L0007),Y
        STA     (L0020),Y
        DEY
        BPL     L3C21

        LDA     L0007
        STA     L0020
        LDA     L0008
        STA     L0021
        LDY     L00D1
.L3C32
        DEY
        LDA     (L003D),Y
        STA     (L001B),Y
        TYA
        BNE     L3C32

        BEQ     L3BD3

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

.L3C6E
        JSR     L40D7

.L3C71
        LDX     #$06
.L3C73
        STA     L002A,X
        DEX
        BPL     L3C73

        STX     L00AF
.L3C7A
        LDA     #$FF
        LDX     #$02
.L3C7E
        STA     L0CD2,X
        DEX
        BPL     L3C7E

.L3C84
        LDX     #$FF
        STX     L0C5E
        STX     L0C86
        STX     L0052
        LDA     #$80
        STA     L00AD
        STA     L0088
        STA     L008A
        ASL     A
        STA     L0089
        STA     L008B
        STA     L00A9
        LDA     #$03
        STA     L008C
        STA     L00AE
        STA     L0087
        LDA     L0BF4
        BEQ     L3CAD

        JSR     L3923

.L3CAD
        LDA     L0030
        BEQ     L3CB4

        JSR     L4238

.L3CB4
        JSR     L36F5

        JSR     L40D7

        LDA     #$DF
        STA     L0CDF
        LDA     #$0B
        STA     L0CE0
        JSR     L1D83

.L3CC7
        LDY     #$23
        LDA     #$00
.L3CCB
        STA     L0053,Y
        DEY
        BPL     L3CCB

        LDA     #$60
        STA     L0065
        STA     L0069
        ORA     #$80
        STA     L0061
        RTS

.L3CDC
        LDX     #$04
.L3CDE
        CPX     L0333
        BEQ     L3CEC

        LDY     #$04
        JSR     L3940

        DEX
        BNE     L3CDE

        RTS

.L3CEC
        LDY     #$09
        JSR     L3940

        DEX
        BNE     L3CEC

        RTS

.L3CF5
        LDA     L0CD1
        JSR     L43C3

        LDA     #$00
        STA     L0C06
        JMP     L3D58

.L3D03
        JSR     L3CC7

        JSR     L3D25

        STA     L0006
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
.L3D24
        CLC
.L3D25
        LDA     L0000
        ROL     A
        TAX
        ADC     L0002
        STA     L0000
        STX     L0002
        LDA     L0001
        TAX
        ADC     L0003
        STA     L0001
        STX     L0003
        RTS

.L3D39
        LSR     A
        STA     L0073
        STA     L0070
        ROL     L0072
        AND     #$1F
        ORA     #$10
        STA     L006E
        LDA     #$06
        JSR     L387E

        JSR     L0D40

        DEC     L0C06
        BEQ     L3CF5

        BPL     L3D58

        INC     L0C06
.L3D58
        DEC     L00A9
        BEQ     L3D5F

        JMP     L3E25

.L3D5F
        JSR     L3D25

        CMP     #$23
        BCS     L3DB3

        LDA     L0BF6
        CMP     #$03
        BCS     L3DB3

        JSR     L3CC7

        LDA     #$26
        STA     L005A
        JSR     L3D25

        STA     L0053
        STX     L0056
        AND     #$80
        STA     L0055
        TXA
        AND     #$80
        STA     L0058
        ROL     L0054
        ROL     L0054
        JSR     L3D25

        BVS     L3D39

        ORA     #$6F
        STA     L0070
        LDA     L0BF4
        BNE     L3DB3

        TXA
        BCS     L3DA1

        AND     #$1F
        ORA     #$10
        STA     L006E
        BCC     L3DA5

.L3DA1
        ORA     #$7F
        STA     L0071
.L3DA5
        JSR     L3D25

        CMP     #$05
        LDA     #$09
        BCS     L3DB0

        LDA     #$0A
.L3DB0
        JSR     L387E

.L3DB3
        LDA     L0BF4
        BNE     L3E25

        JSR     L3F28

        ASL     A
        LDX     L0BEF
        BEQ     L3DC4

        ORA     L0334
.L3DC4
        STA     L00D1
        JSR     L3D03

        CMP     L00D1
        BCS     L3DD2

        LDA     #$02
        JSR     L387E

.L3DD2
        LDA     L0BEF
        BNE     L3E25

        DEC     L0C05
        BPL     L3E25

        INC     L0C05
        JSR     L3D25

        LDY     L0CDD
        BEQ     L3DF2

        CMP     #$5A
        BCS     L3E25

        AND     #$07
        CMP     L0CDD
        BCC     L3E25

.L3DF2
        JSR     L3D03

        CMP     #$C8
        BCS     L3E10

        INC     L0C05
        AND     #$03
        ADC     #$03
        TAY
        TXA
        CMP     #$C8
        ROL     A
        ORA     #$C0
        STA     L0073
        TYA
        JSR     L387E

        JMP     L3E25

.L3E10
        AND     #$03
        STA     L0C05
        STA     L00A8
.L3E17
        JSR     L3D25

        AND     #$03
        ORA     #$01
        JSR     L387E

        DEC     L00A8
        BPL     L3E17

.L3E25
        LDA     L0C02
        SBC     #$04
        BCS     L3E2E

        LDA     #$00
.L3E2E
        STA     L0C02
        LDX     #$FF
        TXS
        INX
        STX     L0D01
        LDX     L0C03
        BEQ     L3E40

        DEC     L0C03
.L3E40
        JSR     L1D83

        LDA     L00A6
        BEQ     L3E50

        AND     L0D20
        LSR     A
        BCS     L3E50

        JSR     L285F

.L3E50
        JSR     L3AF1

.L3E53
        JSR     L3E60

        LDA     L00AF
        BNE     L3E25

        EQUB    $4C

        EQUB    $4B

.L3E5C
        EQUB    $3D,$B1,$91,$92

.L3E60
        CMP     #$A6
        BNE     L3E67

        JMP     L1B70

.L3E67
        CMP     #$93
        BNE     L3E6E

        JMP     L2B42

.L3E6E
        CMP     #$B4
        BNE     L3E75

        JMP     L2E6E

.L3E75
        CMP     #$A4
        BNE     L3E7F

        JSR     L2F0D

        JMP     L29CC

.L3E7F
        CMP     #$A7
        BNE     L3E86

        JMP     L2DA6

.L3E86
        CMP     #$95
        BNE     L3E8D

        JMP     L30F9

.L3E8D
        CMP     #$B0
        BNE     L3E94

        JMP     L31D7

.L3E94
        BIT     L00AF
        BPL     L3EB4

        CMP     #$92
        BNE     L3E9F

        JMP     L3266

.L3E9F
        CMP     #$B1
        BNE     L3EA6

        JMP     L2C35

.L3EA6
        CMP     #$48
        BNE     L3EAD

        JMP     L40EF

.L3EAD
        CMP     #$91
        BNE     L3EC5

        JMP     L2D17

.L3EB4
        STX     L00D1
        LDX     #$03
.L3EB8
        CMP     L3E5C,X
        BNE     L3EC0

        JMP     L27C5

.L3EC0
        DEX
        BNE     L3EB8

        LDX     L00D1
.L3EC5
        CMP     #$54
        BNE     L3ECC

        JMP     L2FB3

.L3ECC
        CMP     #$32
        BEQ     L3F0D

        STA     L0006
        LDA     L00A6
        AND     #$C0
        BEQ     L3EEE

        LDA     L002F
        BNE     L3EEE

        LDA     L0006
        CMP     #$36
        BNE     L3EEB

        JSR     L2E13

        JSR     L3B34

        JSR     L2E13

.L3EEB
        JSR     L2DE9

.L3EEE
        LDA     L002F
        BEQ     L3F0C

        DEC     L002E
        BNE     L3F0C

        LDX     L002F
        DEX
        JSR     L304B

        LDA     #$05
        STA     L002E
        LDX     L002F
        JSR     L304B

        DEC     L002F
        BNE     L3F0C

        JMP     L31A8

.L3F0C
        RTS

.L3F0D
        LDA     L00A6
        AND     #$C0
        BEQ     L3F0C

        JSR     L2875

        STA     L007E
        JSR     L343C

        LDA     #$80
        STA     L007E
        LDA     #$01
        STA     L002C
        INC     L002D
        JMP     L2994

.L3F28
        LDA     L031A
        CLC
        ADC     L031D
        ASL     A
        ADC     L0321
        RTS

.L3F34
        LDA     #$E0
.L3F36
        CMP     L0054
        BCC     L3F40

        CMP     L0057
        BCC     L3F40

        CMP     L005A
.L3F40
        RTS

.L3F41
        ORA     L0054
        ORA     L0057
        ORA     L005A
        RTS

.L3F48
        JSR     L4246

        JSR     L3C84

        ASL     L008C
        ASL     L008C
        JSR     L27FC

        LDX     #$32
        STX     L0C02
        JSR     L2818

        JSR     L36D3

        LDA     #$0C
        STA     L002D
        STA     L002C
        LDA     #$92
        STA     L00A9
        JSR     L355F

.L3F6D
        JSR     L3D03

        LDA     #$20
        STA     L0053
        LDY     #$00
        STY     L00A6
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
        JSR     L20FD

        PLP
        LDA     #$00
        ROR     A
        LDY     #$1F
        STA     (L0020),Y
        LDA     L0BE3
        BEQ     L3F6D

        JSR     L4313

        STA     L008C
.L3FAB
        JSR     L0D40

        DEC     L0C02
        BNE     L3FAB

.L3FB3
        JSR     L3C84

        LDX     #$FF
        TXS
        LDX     #$03
        STX     L002C
        JSR     L4185

        LDX     #$06
        LDA     #$80
        JSR     L4017

        CMP     #$44
        BNE     L3FD7

        JSR     L40A8

        JSR     L415D

        JSR     L4093

        JSR     L27FE

.L3FD7
        LDX     #$4B
.L3FD9
        LDA     L15A4,X
        STA     L02FF,X
        DEX
        BNE     L3FD9

        STX     L00A6
.L3FE4
        JSR     L4085

        CMP     L15F0
        BNE     L3FE4

        EOR     #$A9
        TAX
        LDA     L030E
        CPX     L15EF
        BEQ     L3FF9

        ORA     #$80
.L3FF9
        ORA     #$08
        STA     L030E
        JSR     L3CDC

        LDA     #$93
        LDX     #$03
        JSR     L4017

        JSR     L3B34

        JSR     L3141

.L400E
        LDA     #$FF
        STA     L00AF
        LDA     #$A6
        JMP     L3E53

.L4017
        PHA
        STX     L00AB
        JSR     L3C6E

        LDA     #$01
        JSR     L27FC

        DEC     L00A6
        LDA     #$60
        STA     L0061
        STA     L005A
        LDX     #$7F
        STX     L0070
        STX     L0071
        INX
        STX     L007E
        LDA     L00AB
        JSR     L387E

        LDY     #$06
        STY     L002C
        LDA     #$1E
        JSR     L34C1

        LDY     #$06
        STY     L002C
        INC     L002D
        LDA     L0D20
        BEQ     L4051

        LDA     #$FE
        JSR     L34CC

.L4051
        JSR     L2882

        STY     L008C
        STY     L0D24
        PLA
        JSR     L355F

        LDA     #$94
        LDX     #$07
        STX     L002C
        JSR     L355F

.L4066
        LDA     L005A
        CMP     #$01
        BEQ     L406E

        DEC     L005A
.L406E
        JSR     L1157

        LDA     #$80
        STA     L0059
        ASL     A
        STA     L0053
        STA     L0056
        JSR     L46C9

        DEC     L00A9
        JSR     L421E

        BEQ     L4066

        RTS

.L4085
        LDX     #$49
        CLC
        TXA
.L4089
        ADC     L15A4,X
        EOR     L15A5,X
        DEX
        BNE     L4089

        RTS

.L4093
        LDX     #$07
.L4095
        LDA     L0053,X
        STA     L159D,X
        DEX
        BPL     L4095

.L409D
        LDX     #$07
.L409F
        LDA     L159D,X
        STA     L0053,X
        DEX
        BPL     L409F

        RTS

.L40A8
        LDA     #$01
        JSR     L27FC

        LDA     #$7B
        JSR     L34CC

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
        BCS     L409D

        TYA
        BEQ     L409D

        JMP     L29B9

        EQUB    $53

        EQUB    $00,$07,$21,$7A

.L40D7
        LDX     #$0B
        JSR     L40E1

        DEX
        JSR     L40E1

        DEX
.L40E1
        LDY     #$00
        STY     L0007
        STX     L0008
.L40E7
        LDA     #$00
.L40E9
        STA     (L0007),Y
        INY
        BNE     L40E9

        RTS

.L40EF
        JSR     L40A8

        JSR     L4093

        JSR     L40D7

        LSR     L0349
        LDX     #$4B
.L40FD
        LDA     L0300,X
        STA     L0900,X
        STA     L15A5,X
        DEX
        BPL     L40FD

        JSR     L4085

        STA     L15F0
        PHA
        ORA     #$80
        STA     L003D
        EOR     L030E
        STA     L003F
        EOR     L030B
        STA     L003E
        EOR     #$5A
        EOR     L0348
        STA     L0040
        JSR     L1C43

        JSR     L29B9

        JSR     L29B9

        PLA
        STA     L094B
        EOR     #$A9
        STA     L15EF
        STA     L094A
        LDY     #$09
        STY     L0A0B
        INY
        STY     L0A0F
        LDA     #$00
        JSR     L414B

        JMP     L400E

.L414B
        LDX     #$53
        STX     L0A00
        LDX     #$FF
        STX     L0D01
        INX
        JSR     OSFILE

        INC     L0D01
        RTS

.L415D
        LDX     #$02
        JSR     L4185

        JSR     L40D7

        LDY     #$09
        STY     L0A03
        INC     L0A0B
        INY
        LDA     #$FF
        JSR     L414B

        LDA     L0900
        BMI     L418E

        LDX     #$4B
.L417A
        LDA     L0900,X
        STA     L15A5,X
        DEX
        BPL     L417A

        LDX     #$03
.L4185
        LDY     #$00
        LDA     #$C8
        JMP     OSBYTE

        RTS

.L418D
        LDX     #$00
L418E = L418D+1
        JSR     L3838

        LDX     #$03
        JSR     L3838

        LDX     #$06
        JSR     L3838

.L419C
        LDA     L00D2
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

        ASL     L00D2
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
        STA     L0031
        LDA     L00D6
        LSR     A
        ORA     L00D7
        STA     L0032
        LDA     L00D9
        LSR     A
        ORA     L00DA
        STA     L0033
.L41D4
        LDA     L0031
        JSR     L23EE

        STA     L00A1
        LDA     L001B
        STA     L00A0
        LDA     L0032
        JSR     L23EE

        STA     L00D1
        LDA     L001B
        ADC     L00A0
        STA     L00A0
        LDA     L00D1
        ADC     L00A1
        STA     L00A1
        LDA     L0033
        JSR     L23EE

        STA     L00D1
        LDA     L001B
        ADC     L00A0
        STA     L00A0
        LDA     L00D1
        ADC     L00A1
        STA     L00A1
        JSR     L45F5

        LDA     L0031
        JSR     L453C

        STA     L0031
        LDA     L0032
        JSR     L453C

        STA     L0032
        LDA     L0033
        JSR     L453C

        STA     L0033
        RTS

.L421E
        LDX     #$10
.L4220
        JSR     L42D8

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

.L4238
        LDA     #$00
        STA     L0030
        STA     L0BFF
        JSR     L391B

        LDA     #$48
        BNE     L4282

.L4246
        LDA     #$18
        BNE     L4282

.L424A
        LDX     #$08
        JSR     L2160

        BCC     L4237

        LDA     #$78
        JSR     L43C3

        LDA     #$30
        BNE     L4282

.L425A
        INC     L0347
        BNE     L4267

        INC     L0348
        LDA     #$65
        JSR     L43C3

.L4267
        LDX     #$07
.L4269
        STX     L00D1
        LDA     #$18
        JSR     L42AA

        LDA     L005A
        LSR     A
        LSR     A
        AND     L00D1
        ORA     #$F1
        STA     L000B
        JSR     L4285

        LDA     #$10
.L427F
        BIT     L20A9
L4280 = L427F+1
.L4282
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
.L42D8
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
        STY     L00D1
        CPX     L00D1
        BNE     L4312

        LDA     L0CDE,X
        EOR     #$FF
        STA     L0CDE,X
        JSR     L1CF6

        JSR     L2864

        LDY     L00D1
.L4312
        RTS

.L4313
        LDA     #$00
        LDY     #$0F
.L4317
        STA     L0041,Y
        DEY
        BNE     L4317

        RTS

.L431E
        JSR     L4313

        LDY     #$07
.L4323
        LDX     L42C0,Y
        JSR     L42D8

        BPL     L432F

        LDX     #$FF
        STX     L0041,Y
.L432F
        DEY
        BNE     L4323

        LDX     L00AC
        LDA     #$07
        LDY     L0044
        BEQ     L433D

        JSR     L25F2

.L433D
        LDY     L0045
        BEQ     L4344

        JSR     L2602

.L4344
        STX     L00AC
        ASL     A
        LDX     L00AD
        LDY     L0046
        BEQ     L4350

        JSR     L2602

.L4350
        LDY     L0047
        BEQ     L4357

        JSR     L25F2

.L4357
        STX     L00AD
        JSR     L421E

        STX     L0041
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

        JMP     L3FB3

.L4389
        CPX     #$59
        BNE     L4362

.L438D
        LDA     L00A6
        BNE     L43A4

        LDY     #$0F
        LDA     #$FF
.L4395
        LDX     L42C0,Y
        CPX     L0041
        BNE     L439F

        STA     L0041,Y
.L439F
        DEY
        CPY     #$07
        BNE     L4395

.L43A4
        RTS

.L43A5
        STY     L00A4
        DEC     L0D01
        JSR     OSRDCH

        INC     L0D01
        TAX
.L43B1
        RTS

.L43B2
        STX     L0C06
        PHA
        LDA     L0CD1
        JSR     L43DA

        PLA
.L43BD
        BIT     L6CA9
L43BE = L43BD+1
.L43C0
        BIT     L6FA9
L43C1 = L43C0+1
.L43C3
        LDX     #$00
        STX     L007E
        LDY     #$09
        STY     L002C
        LDY     #$16
        STY     L002D
        CPX     L0C06
        BNE     L43B2

        STY     L0C06
        STA     L0CD1
.L43DA
        JSR     L34CC

        LSR     L0C07
        BCC     L43B1

        LDA     #$FD
        JMP     L34CC

.L43E7
        JSR     L3D25

        BMI     L43B1

        CPX     #$16
        BCS     L43B1

        LDA     L0317,X
        BEQ     L43B1

        LDA     L0C06
        BNE     L43B1

        LDY     #$03
        STY     L0C07
        STA     L0317,X
        CPX     #$11
        BCS     L440B

        TXA
        ADC     #$D0
        BNE     L43C3

.L440B
        BEQ     L43BE

        CPX     #$12
        BEQ     L43C1

        TXA
        ADC     #$5D
        BNE     L43C3

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

.L4456
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
        LDA     L0032
        AND     #$60
        BEQ     L449A

        LDA     #$02
        JSR     L4569

        STA     L0065
        JMP     L44E2

.L44B6
        LDA     L005D
        STA     L0031
        LDA     L005F
        STA     L0032
        LDA     L0061
        STA     L0033
        JSR     L41D4

        LDA     L0031
        STA     L005D
        LDA     L0032
        STA     L005F
        LDA     L0033
        STA     L0061
        LDY     #$04
        LDA     L0031
        AND     #$60
        BEQ     L44A5

        LDX     #$02
        LDA     #$00
        JSR     L4569

        STA     L0063
.L44E2
        LDA     L0063
        STA     L0031
        LDA     L0065
        STA     L0032
        LDA     L0067
        STA     L0033
        JSR     L41D4

        LDA     L0031
        STA     L0063
        LDA     L0032
        STA     L0065
        LDA     L0033
        STA     L0067
        LDA     L005F
        STA     L00A0
        LDA     L0067
        JSR     L24B7

        LDX     L0061
        LDA     L0065
        JSR     L251C

        EOR     #$80
        STA     L0069
        LDA     L0063
        JSR     L24B7

        LDX     L005D
        LDA     L0067
        JSR     L251C

        EOR     #$80
        STA     L006B
        LDA     L0065
        JSR     L24B7

        LDX     L005F
        LDA     L0063
        JSR     L251C

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
        CMP     L00A0
        BCS     L4563

        LDX     #$FE
        STX     L00D1
.L4547
        ASL     A
        CMP     L00A0
        BCC     L454E

        SBC     L00A0
.L454E
        ROL     L00D1
        BCS     L4547

        LDA     L00D1
        LSR     A
        LSR     A
        STA     L00D1
        LSR     A
        ADC     L00D1
        STA     L00D1
        TYA
        AND     #$80
        ORA     L00D1
        RTS

.L4563
        TYA
        AND     #$80
        ORA     #$60
        RTS

.L4569
        STA     L001D
        LDA     L005D,X
        STA     L00A0
        LDA     L0063,X
        JSR     L24B7

        LDX     L005D,Y
        STX     L00A0
        LDA     L0063,Y
        JSR     L24DD

        STX     L001B
        LDY     L001D
        LDX     L005D,Y
        STX     L00A0
        EOR     #$80
        STA     L001C
        EOR     L00A0
        AND     #$80
        STA     L00D1
        LDA     #$00
        LDX     #$10
        ASL     L001B
        ROL     L001C
        ASL     L00A0
        LSR     L00A0
.L459C
        ROL     A
        CMP     L00A0
        BCC     L45A3

        SBC     L00A0
.L45A3
        ROL     L001B
        ROL     L001C
        DEX
        BNE     L459C

        LDA     L001B
        ORA     L00D1
        RTS

.L45AF
        JSR     L4717

        JSR     L3973

        ORA     L00D3
        BNE     L45DA

        LDA     L00E0
        CMP     #$BE
        BCS     L45DA

        LDY     #$02
        JSR     L45E1

        LDY     #$06
        LDA     L00E0
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
        STA     (L0074),Y
        INY
        INY
        STA     (L0074),Y
        LDA     L00D2
        DEY
        STA     (L0074),Y
        ADC     #$03
        BCS     L45D8

        DEY
        DEY
        STA     (L0074),Y
        RTS

.L45F5
        LDY     L00A1
        LDA     L00A0
        STA     L00A2
        LDX     #$00
        STX     L00A0
        LDA     #$08
        STA     L00D1
.L4603
        CPX     L00A0
        BCC     L4615

        BNE     L460D

        CPY     #$40
        BCC     L4615

.L460D
        TYA
        SBC     #$40
        TAY
        TXA
        SBC     L00A0
        TAX
.L4615
        ROL     L00A0
        ASL     L00A2
        TYA
        ROL     A
        TAY
        TXA
        ROL     A
        TAX
        ASL     L00A2
        TYA
        ROL     A
        TAY
        TXA
        ROL     A
        TAX
        DEC     L00D1
        BNE     L4603

        RTS

.L462C
        CMP     L00A0
        BCS     L464A

.L4630
        LDX     #$FE
        STX     L00A1
.L4634
        ASL     A
        BCS     L4642

        CMP     L00A0
        BCC     L463D

        SBC     L00A0
.L463D
        ROL     L00A1
        BCS     L4634

        RTS

.L4642
        SBC     L00A0
        SEC
        ROL     L00A1
        BCS     L4634

        RTS

.L464A
        LDA     #$FF
        STA     L00A1
        RTS

.L464F
        EOR     L00A2
        BMI     L4659

        LDA     L00A0
        CLC
        ADC     L00A1
        RTS

.L4659
        LDA     L00A1
        SEC
        SBC     L00A0
        BCC     L4662

        CLC
        RTS

.L4662
        PHA
        LDA     L00A2
        EOR     #$80
        STA     L00A2
        PLA
        EOR     #$FF
        ADC     #$01
        RTS

.L466F
        LDX     #$00
        LDY     #$00
.L4673
        LDA     L0031
        STA     L00A0
        LDA     L0009,X
        JSR     L242A

        STA     L00D1
        LDA     L0032
        EOR     L000A,X
        STA     L00A2
        LDA     L0033
        STA     L00A0
        LDA     L000B,X
        JSR     L242A

        STA     L00A0
        LDA     L00D1
        STA     L00A1
        LDA     L0034
        EOR     L000C,X
        JSR     L464F

        STA     L00D1
        LDA     L0035
        STA     L00A0
        LDA     L000D,X
        JSR     L242A

        STA     L00A0
        LDA     L00D1
        STA     L00A1
        LDA     L0036
        EOR     L000E,X
        JSR     L464F

        STA     L0037,Y
        LDA     L00A2
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

.L46C9
        LDA     L00AB
        BMI     L46C6

        LDA     #$1F
        STA     L00B7
        LDA     #$20
        BIT     L0072
        BNE     L4704

        BPL     L4704

        ORA     L0072
        AND     #$3F
        STA     L0072
        LDA     #$00
        LDY     #$1C
        STA     (L0020),Y
        LDY     #$1E
        STA     (L0020),Y
        JSR     L4717

        LDY     #$01
        LDA     #$12
        STA     (L0074),Y
        LDY     #$07
        LDA     (L001E),Y
        LDY     #$02
        STA     (L0074),Y
.L46FA
        INY
        JSR     L3D25

        STA     (L0074),Y
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
        JMP     L35A2

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

        LDA     L0053
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
        LDA     (L001E),Y
        TAX
        LDA     #$FF
        STA     L0100,X
        STA     L0101,X
        LDA     L0059
        STA     L00D1
        LDA     L005A
        LSR     A
        ROR     L00D1
        LSR     A
        ROR     L00D1
        LSR     A
        ROR     L00D1
        LSR     A
        BNE     L4768

        LDA     L00D1
        ROR     A
        LSR     A
        LSR     A
        LSR     A
        STA     L00B7
        BPL     L4779

.L4768
        LDY     #$0D
        LDA     (L001E),Y
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
        STA     L00A0
        LDY     #$10
.L4790
        LDA     L0009,Y
        ASL     A
        LDA     L000A,Y
        ROL     A
        JSR     L462C

        LDX     L00A1
        STX     L0009,Y
        DEY
        DEY
        BPL     L4790

        LDX     #$08
.L47A5
        LDA     L0053,X
        STA     L007E,X
        DEX
        BPL     L47A5

        LDA     #$FF
        STA     L00E1
        LDY     #$0C
        LDA     L0072
        AND     #$20
        BEQ     L47CA

        LDA     (L001E),Y
        LSR     A
        LSR     A
        TAX
        LDA     #$FF
.L47BF
        STA     L00D2,X
        DEX
        BPL     L47BF

        INX
        STX     L00B7
.L47C7
        JMP     L493D

.L47CA
        LDA     (L001E),Y
        BEQ     L47C7

        STA     L00B8
        LDY     #$12
        LDA     (L001E),Y
        TAX
        LDA     L0085
        TAY
        BEQ     L47E9

.L47DA
        INX
        LSR     L0082
        ROR     L0081
        LSR     L007F
        ROR     L007E
        LSR     A
        ROR     L0084
        TAY
        BNE     L47DA

.L47E9
        STX     L00A5
        LDA     L0086
        STA     L0036
        LDA     L007E
        STA     L0031
        LDA     L0080
        STA     L0032
        LDA     L0081
        STA     L0033
        LDA     L0083
        STA     L0034
        LDA     L0084
        STA     L0035
        JSR     L466F

        LDA     L0037
        STA     L007E
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
        LDA     (L001E),Y
        CLC
        ADC     L001E
        STA     L0022
        LDY     #$11
        LDA     (L001E),Y
        ADC     L001F
        STA     L0023
        LDY     #$00
.L4831
        LDA     (L0022),Y
        STA     L0038
        AND     #$1F
        CMP     L00B7
        BCS     L484A

        TYA
        LSR     A
        LSR     A
        TAX
        LDA     #$FF
        STA     L00D2,X
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
        LDA     (L0022),Y
        STA     L0037
        INY
        LDA     (L0022),Y
        STA     L0039
        INY
        LDA     (L0022),Y
        STA     L003B
        LDX     L00A5
        CPX     #$04
        BCC     L488A

        LDA     L007E
        STA     L0031
        LDA     L0080
        STA     L0032
        LDA     L0081
        STA     L0033
        LDA     L0083
        STA     L0034
        LDA     L0084
        STA     L0035
        LDA     L0086
        STA     L0036
        JMP     L48E8

.L4882
        LSR     L007E
        LSR     L0084
        LSR     L0081
        LDX     #$01
.L488A
        LDA     L0037
        STA     L0031
        LDA     L0039
        STA     L0033
        LDA     L003B
        DEX
        BMI     L489F

.L4897
        LSR     L0031
        LSR     L0033
        LSR     A
        DEX
        BPL     L4897

.L489F
        STA     L00A1
        LDA     L003C
        STA     L00A2
        LDA     L0084
        STA     L00A0
        LDA     L0086
        JSR     L464F

        BCS     L4882

        STA     L0035
        LDA     L00A2
        STA     L0036
        LDA     L0031
        STA     L00A1
        LDA     L0038
        STA     L00A2
        LDA     L007E
        STA     L00A0
        LDA     L0080
        JSR     L464F

        BCS     L4882

        STA     L0031
        LDA     L00A2
        STA     L0032
        LDA     L0033
        STA     L00A1
        LDA     L003A
        STA     L00A2
        LDA     L0081
        STA     L00A0
        LDA     L0083
        JSR     L464F

        BCS     L4882

        STA     L0033
        LDA     L00A2
        STA     L0034
.L48E8
        LDA     L0037
        STA     L00A0
        LDA     L0031
        JSR     L242A

        STA     L00D1
        LDA     L0038
        EOR     L0032
        STA     L00A2
        LDA     L0039
        STA     L00A0
        LDA     L0033
        JSR     L242A

        STA     L00A0
        LDA     L00D1
        STA     L00A1
        LDA     L003A
        EOR     L0034
        JSR     L464F

        STA     L00D1
        LDA     L003B
        STA     L00A0
        LDA     L0035
        JSR     L242A

        STA     L00A0
        LDA     L00D1
        STA     L00A1
        LDA     L0036
        EOR     L003C
        JSR     L464F

        PHA
        TYA
        LSR     A
        LSR     A
        TAX
        PLA
        BIT     L00A2
        BMI     L4933

        LDA     #$00
.L4933
        STA     L00D2,X
        INY
.L4936
        CPY     L00B8
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
        LDA     (L001E),Y
        STA     L00B8
        LDA     L001E
        CLC
        ADC     #$14
        STA     L0022
        LDA     L001F
        ADC     #$00
        STA     L0023
        LDY     #$00
        STY     L00B4
.L4984
        STY     L00A5
        LDA     (L0022),Y
        STA     L0031
        INY
        LDA     (L0022),Y
        STA     L0033
        INY
        LDA     (L0022),Y
        STA     L0035
        INY
        LDA     (L0022),Y
        STA     L00D1
        AND     #$1F
        CMP     L00B7
        BCC     L49CD

        INY
        LDA     (L0022),Y
        STA     L001B
        AND     #$0F
        TAX
        LDA     L00D2,X
        BNE     L49D0

        LDA     L001B
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        TAX
        LDA     L00D2,X
        BNE     L49D0

        INY
        LDA     (L0022),Y
        STA     L001B
        AND     #$0F
        TAX
        LDA     L00D2,X
        BNE     L49D0

        LDA     L001B
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        TAX
        LDA     L00D2,X
        BNE     L49D0

.L49CD
        JMP     L4B45

.L49D0
        LDA     L00D1
        STA     L0032
        ASL     A
        STA     L0034
        ASL     A
        STA     L0036
        JSR     L466F

        LDA     L0055
        STA     L0033
        EOR     L0038
        BMI     L49F5

        CLC
        LDA     L0037
        ADC     L0053
        STA     L0031
        LDA     L0054
        ADC     #$00
        STA     L0032
        JMP     L4A18

.L49F5
        LDA     L0053
        SEC
        SBC     L0037
        STA     L0031
        LDA     L0054
        SBC     #$00
        STA     L0032
        BCS     L4A18

        EOR     #$FF
        STA     L0032
        LDA     #$01
        SBC     L0031
        STA     L0031
        BCC     L4A12

        INC     L0032
.L4A12
        LDA     L0033
        EOR     #$80
        STA     L0033
.L4A18
        LDA     L0058
        STA     L0036
        EOR     L003A
        BMI     L4A30

        CLC
        LDA     L0039
        ADC     L0056
        STA     L0034
        LDA     L0057
        ADC     #$00
        STA     L0035
        JMP     L4A55

.L4A30
        LDA     L0056
        SEC
        SBC     L0039
        STA     L0034
        LDA     L0057
        SBC     #$00
        STA     L0035
        BCS     L4A55

        EOR     #$FF
        STA     L0035
        LDA     L0034
        EOR     #$FF
        ADC     #$01
        STA     L0034
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
        STA     L00D1
        LDA     L005A
        ADC     #$00
        STA     L008F
        JMP     L4AC2

.L4A69
        LDX     L00A0
        BEQ     L4A89

        LDX     #$00
.L4A6F
        LSR     A
        INX
        CMP     L00A0
        BCS     L4A6F

        STX     L00A2
        JSR     L462C

        LDX     L00A2
        LDA     L00A1
.L4A7E
        ASL     A
        ROL     L008F
        BMI     L4A89

        DEX
        BNE     L4A7E

        STA     L00A1
        RTS

.L4A89
        LDA     #$32
        STA     L00A1
        STA     L008F
        RTS

.L4A90
        LDA     #$80
        SEC
        SBC     L00A1
        STA     L0100,X
        INX
        LDA     #$00
        SBC     L008F
        STA     L0100,X
        JMP     L4B02

.L4AA3
        LDA     L0059
        SEC
        SBC     L003B
        STA     L00D1
        LDA     L005A
        SBC     #$00
        STA     L008F
        BCC     L4ABA

        BNE     L4AC2

        LDA     L00D1
        CMP     #$04
        BCS     L4AC2

.L4ABA
        LDA     #$00
        STA     L008F
        LDA     #$04
        STA     L00D1
.L4AC2
        LDA     L008F
        ORA     L0032
        ORA     L0035
        BEQ     L4AD9

        LSR     L0032
        ROR     L0031
        LSR     L0035
        ROR     L0034
        LSR     L008F
        ROR     L00D1
        JMP     L4AC2

.L4AD9
        LDA     L00D1
        STA     L00A0
        LDA     L0031
        CMP     L00A0
        BCC     L4AE9

        JSR     L4A69

        JMP     L4AEC

.L4AE9
        JSR     L462C

.L4AEC
        LDX     L00B4
        LDA     L0033
        BMI     L4A90

        LDA     L00A1
        CLC
        ADC     #$80
        STA     L0100,X
        INX
        LDA     L008F
        ADC     #$00
        STA     L0100,X
.L4B02
        TXA
        PHA
        LDA     #$00
        STA     L008F
        LDA     L00D1
        STA     L00A0
        LDA     L0034
        CMP     L00A0
        BCC     L4B2B

        JSR     L4A69

        JMP     L4B2E

.L4B18
        LDA     #$60
        CLC
        ADC     L00A1
        STA     L0100,X
        INX
        LDA     #$00
        ADC     L008F
        STA     L0100,X
        JMP     L4B45

.L4B2B
        JSR     L462C

.L4B2E
        PLA
        TAX
        INX
        LDA     L0036
        BMI     L4B18

        LDA     #$60
        SEC
        SBC     L00A1
        STA     L0100,X
        INX
        LDA     #$00
        SBC     L008F
        STA     L0100,X
.L4B45
        CLC
        LDA     L00B4
        ADC     #$04
        STA     L00B4
        LDA     L00A5
        ADC     #$06
        TAY
        BCS     L4B5A

        CMP     L00B8
        BCS     L4B5A

        JMP     L4984

.L4B5A
        LDA     L0072
        AND     #$20
        BEQ     L4B69

        LDA     L0072
        ORA     #$08
        STA     L0072
        JMP     L35A2

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
        LDA     (L001E),Y
        STA     L00B8
        LDY     #$00
        STY     L008F
        STY     L00A5
        INC     L008F
        BIT     L0072
        BVC     L4BDE

        LDA     L0072
        AND     #$BF
        STA     L0072
        LDY     #$06
        LDA     (L001E),Y
        TAY
        LDX     L0100,Y
        STX     L0031
        INX
        BEQ     L4BDE

        LDX     L0101,Y
        STX     L0032
        INX
        BEQ     L4BDE

        LDX     L0102,Y
        STX     L0033
        LDX     L0103,Y
        STX     L0034
        LDA     #$00
        STA     L0035
        STA     L0036
        STA     L0038
        LDA     L0059
        STA     L0037
        LDA     L0055
        BPL     L4BC1

        DEC     L0035
.L4BC1
        JSR     L4DAD

        BCS     L4BDE

        LDY     L008F
        LDA     L0031
        STA     (L0074),Y
        INY
        LDA     L0032
        STA     (L0074),Y
        INY
        LDA     L0033
        STA     (L0074),Y
        INY
        LDA     L0034
        STA     (L0074),Y
        INY
        STY     L008F
.L4BDE
        LDY     #$03
        CLC
        LDA     (L001E),Y
        ADC     L001E
        STA     L0022
        LDY     #$10
        LDA     (L001E),Y
        ADC     L001F
        STA     L0023
        LDY     #$05
        LDA     (L001E),Y
        STA     L0006
        LDY     L00A5
.L4BF7
        LDA     (L0022),Y
        CMP     L00B7
        BCC     L4C68

        INY
        LDA     (L0022),Y
        INY
        STA     L001B
        AND     #$0F
        TAX
        LDA     L00D2,X
        BNE     L4C15

        LDA     L001B
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        TAX
        LDA     L00D2,X
        BEQ     L4C68

.L4C15
        LDA     (L0022),Y
        TAX
        INY
        LDA     (L0022),Y
        STA     L00A0
        LDA     L0101,X
        STA     L0032
        LDA     L0100,X
        STA     L0031
        LDA     L0102,X
        STA     L0033
        LDA     L0103,X
        STA     L0034
        LDX     L00A0
        LDA     L0100,X
        STA     L0035
        LDA     L0103,X
        STA     L0038
        LDA     L0102,X
        STA     L0037
        LDA     L0101,X
        STA     L0036
        JSR     L4DB3

        BCS     L4C68

        LDY     L008F
        LDA     L0031
        STA     (L0074),Y
        INY
        LDA     L0032
        STA     (L0074),Y
        INY
        LDA     L0033
        STA     (L0074),Y
        INY
        LDA     L0034
        STA     (L0074),Y
        INY
        STY     L008F
        CPY     L0006
        BCS     L4C7F

.L4C68
        INC     L00A5
        LDY     L00A5
        CPY     L00B8
        BCS     L4C7F

        LDY     #$00
        LDA     L0022
        ADC     #$04
        STA     L0022
        BCC     L4C7C

        INC     L0023
.L4C7C
        JMP     L4BF7

.L4C7F
        LDA     L008F
.L4C81
        LDY     #$00
        STA     (L0074),Y
.L4C85
        LDY     #$00
        LDA     (L0074),Y
        STA     L00B8
        CMP     #$04
        BCC     L4CAB

        INY
.L4C90
        LDA     (L0074),Y
        STA     L0031
        INY
        LDA     (L0074),Y
        STA     L0032
        INY
        LDA     (L0074),Y
        STA     L0033
        INY
        LDA     (L0074),Y
        STA     L0034
        JSR     L1621

        INY
        CPY     L00B8
        BCC     L4C90

.L4CAB
        RTS

.L4CAC
        LDA     L0032
        BPL     L4CC7

        STA     L00A2
        JSR     L4D26

        TXA
        CLC
        ADC     L0033
        STA     L0033
        TYA
        ADC     L0034
        STA     L0034
        LDA     #$00
        STA     L0031
        STA     L0032
        TAX
.L4CC7
        BEQ     L4CE2

        STA     L00A2
        DEC     L00A2
        JSR     L4D26

        TXA
        CLC
        ADC     L0033
        STA     L0033
        TYA
        ADC     L0034
        STA     L0034
        LDX     #$FF
        STX     L0031
        INX
        STX     L0032
.L4CE2
        LDA     L0034
        BPL     L4D00

        STA     L00A2
        LDA     L0033
        STA     L00A1
        JSR     L4D55

        TXA
        CLC
        ADC     L0031
        STA     L0031
        TYA
        ADC     L0032
        STA     L0032
        LDA     #$00
        STA     L0033
        STA     L0034
.L4D00
        LDA     L0033
        SEC
        SBC     #$C0
        STA     L00A1
        LDA     L0034
        SBC     #$00
        STA     L00A2
        BCC     L4D25

        JSR     L4D55

        TXA
        CLC
        ADC     L0031
        STA     L0031
        TYA
        ADC     L0032
        STA     L0032
        LDA     #$BF
        STA     L0033
        LDA     #$00
        STA     L0034
.L4D25
        RTS

.L4D26
        LDA     L0031
        STA     L00A1
        JSR     L4D91

        PHA
        LDX     L00D1
        BNE     L4D5D

.L4D32
        LDA     #$00
        TAX
        TAY
        LSR     L00A2
        ROR     L00A1
        ASL     L00A0
        BCC     L4D47

.L4D3E
        TXA
        CLC
        ADC     L00A1
        TAX
        TYA
        ADC     L00A2
        TAY
.L4D47
        LSR     L00A2
        ROR     L00A1
        ASL     L00A0
        BCS     L4D3E

        BNE     L4D47

        PLA
        BPL     L4D84

        RTS

.L4D55
        JSR     L4D91

        PHA
        LDX     L00D1
        BNE     L4D32

.L4D5D
        LDA     #$FF
        TAY
        ASL     A
        TAX
.L4D62
        ASL     L00A1
        ROL     L00A2
        LDA     L00A2
        BCS     L4D6E

        CMP     L00A0
        BCC     L4D79

.L4D6E
        SBC     L00A0
        STA     L00A2
        LDA     L00A1
        SBC     #$00
        STA     L00A1
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
        STX     L00A0
        LDA     L00A2
        BPL     L4DAA

        LDA     #$00
        SEC
        SBC     L00A1
        STA     L00A1
        LDA     L00A2
        PHA
        EOR     #$FF
        ADC     #$00
        STA     L00A2
        PLA
.L4DAA
        EOR     L003A
        RTS

.L4DAD
        LDA     #$00
        STA     L00B1
        LDA     L0036
.L4DB3
        LDX     #$BF
        ORA     L0038
        BNE     L4DBF

        CPX     L0037
        BCC     L4DBF

        LDX     #$00
.L4DBF
        STX     L00A8
        LDA     L0032
        ORA     L0034
        BNE     L4DE3

        LDA     #$BF
        CMP     L0033
        BCC     L4DE3

        LDA     L00A8
        BNE     L4DE1

.L4DD1
        LDA     L0033
        STA     L0032
        LDA     L0035
        STA     L0033
        LDA     L0037
        STA     L0034
        CLC
        RTS

.L4DDF
        SEC
        RTS

.L4DE1
        LSR     L00A8
.L4DE3
        LDA     L00A8
        BPL     L4E16

        LDA     L0032
        AND     L0036
        BMI     L4DDF

        LDA     L0034
        AND     L0038
        BMI     L4DDF

        LDX     L0032
        DEX
        TXA
        LDX     L0036
        DEX
        STX     L0039
        ORA     L0039
        BPL     L4DDF

        LDA     L0033
        CMP     #$C0
        LDA     L0034
        SBC     #$00
        STA     L0039
        LDA     L0037
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
        SBC     L0031
        STA     L0039
        LDA     L0036
        SBC     L0032
        STA     L003A
        LDA     L0037
        SEC
        SBC     L0033
        STA     L003B
        LDA     L0038
        SBC     L0034
        STA     L003C
        EOR     L003A
        STA     L00A2
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
        STX     L00D1
        LDA     L0039
        CMP     L003B
        BCC     L4E79

        STA     L00A0
        LDA     L003B
        JSR     L462C

        JMP     L4E84

.L4E79
        LDA     L003B
        STA     L00A0
        LDA     L0039
        JSR     L462C

        DEC     L00D1
.L4E84
        LDA     L00A1
        STA     L0039
        LDA     L00A2
        STA     L003A
        LDA     L00A8
        BEQ     L4E92

        BPL     L4EA5

.L4E92
        JSR     L4CAC

        LDA     L00A8
        BPL     L4ECA

        LDA     L0032
        ORA     L0034
        BNE     L4ECF

        LDA     L0033
        CMP     #$C0
        BCS     L4ECF

.L4EA5
        LDX     L0031
        LDA     L0035
        STA     L0031
        STX     L0035
        LDA     L0036
        LDX     L0032
        STX     L0036
        STA     L0032
        LDX     L0033
        LDA     L0037
        STA     L0033
        STX     L0037
        LDA     L0038
        LDX     L0034
        STX     L0038
        STA     L0034
        JSR     L4CAC

        DEC     L00B1
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
