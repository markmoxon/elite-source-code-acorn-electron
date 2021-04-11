INCLUDE "sources/elite-header.h.asm"

CODE% = &4400
LOAD% = &4400


TRTB%   = $0004
L0005   = $0005
L0006   = $0006
ZP      = $0070
L0071   = $0071
P       = $0072
Q       = $0073
YY      = $0074
T       = $0075
SC      = $0076
SCH     = $0077
BLPTR   = $0078
L0079   = $0079
V219    = $007A
L007B   = $007B
L0081   = $0081
BLN     = $0083
L0084   = $0084
EXCN    = $0085
L0086   = $0086
L0087   = $0087
L0088   = $0088
L00F4   = $00F4
USERV   = $0200
L0201   = $0201
BRKV    = $0202
L0203   = $0203
IRQ1V   = $0204
L0205   = $0205
IRQ2V   = $0206
CLIV    = $0208
BYTEV   = $020A
WORDV   = $020C
WRCHV   = $020E
L020F   = $020F
RDCHV   = $0210
L0211   = $0211
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
L0229   = $0229
INSV    = $022A
REMV    = $022C
CNPV    = $022E
INDV1   = $0230
INDV2   = $0232
INDV3   = $0234
L0258   = $0258
L0B11   = $0B11
L0B3D   = $0B3D
L0BC2   = $0BC2
L0C24   = $0C24
L0D00   = $0D00
L0D02   = $0D02
L0D03   = $0D03
L0D04   = $0D04
L0D05   = $0D05
L0D08   = $0D08
L0D0A   = $0D0A
L0D0B   = $0D0B
L0D0C   = $0D0C
L0D0D   = $0D0D
L0D0E   = $0D0E
L0D0F   = $0D0F
VIA     = $FE00
LFE02   = $FE02
LFE03   = $FE03
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

        org     $4400
        EQUB    $DC,$00,$03,$60,$6B,$A9,$77,$00
        EQUB    $64,$6C,$B5,$71,$6D,$6E,$B1,$77
        EQUB    $00,$67,$B2,$62,$32,$20,$00,$AF
        EQUB    $B5,$6D,$77,$BA,$7A,$2E,$00,$70
        EQUB    $7A,$70,$BF,$6E,$00,$73,$BD,$A6
        EQUB    $00,$21,$03,$A8,$71,$68,$66,$77
        EQUB    $03,$85,$70,$00,$AF,$67,$AB,$77
        EQUB    $BD,$A3,$00,$62,$64,$BD,$60,$76
        EQUB    $6F,$77,$76,$B7,$6F,$00,$BD,$60
        EQUB    $6B,$03,$00,$62,$B5,$B7,$A0,$03
        EQUB    $00,$73,$6C,$BA,$03,$00,$A8,$AF
        EQUB    $6F,$7A,$03,$00,$76,$6D,$6A,$77
        EQUB    $00,$75,$6A,$66,$74,$03,$00,$B9
        EQUB    $B8,$B4,$77,$7A,$00,$B8,$A9,$60
        EQUB    $6B,$7A,$00,$65,$66,$76,$67,$A3
        EQUB    $00,$6E,$76,$6F,$B4,$0E,$81,$00
        EQUB    $AE,$60,$77,$B2,$BA,$9A,$00,$D8
        EQUB    $6E,$76,$6D,$BE,$77,$00,$60,$BC
        EQUB    $65,$BB,$B3,$62,$60,$7A,$00,$67
        EQUB    $66,$6E,$6C,$60,$B7,$60,$7A,$00
        EQUB    $60,$BA,$73,$BA,$B2,$66,$03,$E8
        EQUB    $B2,$66,$00,$70,$6B,$6A,$73,$00
        EQUB    $73,$71,$6C,$67,$76,$60,$77,$00
        EQUB    $03,$B6,$70,$B3,$00,$6B,$76,$6E
        EQUB    $B8,$03,$60,$6C,$6F,$BC,$6A,$A3
        EQUB    $00,$6B,$7A,$73,$B3,$70,$73,$62
        EQUB    $A6,$03,$00,$70,$6B,$BA,$77,$03
        EQUB    $E9,$82,$00,$AE,$E8,$B8,$A6,$00
        EQUB    $73,$6C,$73,$76,$6F,$B2,$6A,$BC
        EQUB    $00,$64,$71,$6C,$70,$70,$03,$99
        EQUB    $6A,$75,$6A,$77,$7A,$00,$66,$60
        EQUB    $BC,$6C,$6E,$7A,$00,$03,$6F,$6A
        EQUB    $64,$6B,$77,$03,$7A,$66,$A9,$70
        EQUB    $00,$BF,$60,$6B,$0D,$A2,$B5,$6F
        EQUB    $00,$60,$62,$70,$6B,$00,$03,$A5
        EQUB    $55,$6A,$BC,$00,$59,$82,$22,$00
        EQUB    $77,$A9,$A0,$77,$03,$6F,$6C,$E8
        EQUB    $00,$49,$03,$69,$62,$6E,$6E,$BB
        EQUB    $00,$71,$B8,$A0,$00,$70,$77,$00
        EQUB    $93,$03,$6C,$65,$03,$00,$70,$66
        EQUB    $55,$00,$03,$60,$A9,$64,$6C,$25
        EQUB    $00,$66,$B9,$6A,$73,$00,$65,$6C
        EQUB    $6C,$67,$00,$BF,$7B,$B4,$6F,$AA
        EQUB    $00,$B7,$AE,$6C,$62,$60,$B4,$B5
        EQUB    $70,$00,$70,$B6,$B5,$70,$00,$6F
        EQUB    $6A,$B9,$BA,$0C,$74,$AF,$AA,$00
        EQUB    $6F,$76,$7B,$76,$BD,$AA,$00,$6D
        EQUB    $A9,$60,$6C,$B4,$60,$70,$00,$D8
        EQUB    $73,$76,$77,$B3,$70,$00,$A8,$60
        EQUB    $6B,$AF,$B3,$7A,$00,$56,$6C,$7A
        EQUB    $70,$00,$65,$6A,$AD,$A9,$6E,$70
        EQUB    $00,$65,$76,$71,$70,$00,$6E,$AF
        EQUB    $B3,$A3,$70,$00,$64,$6C,$6F,$67
        EQUB    $00,$73,$6F,$B2,$AF,$76,$6E,$00
        EQUB    $A0,$6E,$0E,$E8,$BC,$AA,$00,$A3
        EQUB    $6A,$B1,$03,$5C,$70,$00,$0B,$7A
        EQUB    $0C,$6D,$0A,$1C,$00,$03,$60,$71
        EQUB    $00,$6F,$A9,$A0,$00,$65,$6A,$B3
        EQUB    $A6,$00,$70,$A8,$55,$00,$64,$AD
        EQUB    $B1,$00,$71,$BB,$00,$7A,$66,$55
        EQUB    $6C,$74,$00,$61,$6F,$76,$66,$00
        EQUB    $61,$B6,$60,$68,$00,$35,$00,$70
        EQUB    $6F,$6A,$6E,$7A,$00,$61,$76,$64
        EQUB    $0E,$66,$7A,$BB,$00,$6B,$BA,$6D
        EQUB    $BB,$00,$61,$BC,$7A,$00,$65,$B2
        EQUB    $00,$65,$76,$71,$71,$7A,$00,$71
        EQUB    $6C,$67,$B1,$77,$00,$65,$71,$6C
        EQUB    $64,$00,$6F,$6A,$A7,$71,$67,$00
        EQUB    $6F,$6C,$61,$E8,$B3,$00,$A5,$71
        EQUB    $67,$00,$6B,$76,$6E,$B8,$6C,$6A
        EQUB    $67,$00,$65,$66,$6F,$AF,$66,$00
        EQUB    $AF,$70,$66,$60,$77,$00,$88,$B7
        EQUB    $AE,$AB,$00,$60,$6C,$6E,$00,$D8
        EQUB    $6E,$B8,$67,$B3,$00,$03,$67,$AA
        EQUB    $77,$71,$6C,$7A,$BB,$00,$61,$7A
        EQUB    $03,$67,$0D,$61,$B7,$B0,$6D,$03
        EQUB    $05,$03,$6A,$0D,$B0,$55,$00,$8D
        EQUB    $03,$03,$93,$2E,$03,$99,$03,$03
        EQUB    $03,$8D,$03,$85,$03,$65,$BA,$03
        EQUB    $70,$62,$A2,$2E,$29,$00,$65,$71
        EQUB    $BC,$77,$00,$AD,$A9,$00,$A2,$65
        EQUB    $77,$00,$BD,$64,$6B,$77,$00,$5A
        EQUB    $6F,$6C,$74,$24,$00,$40,$32,$DF
        EQUB    $02,$00,$66,$7B,$77,$B7,$03,$00
        EQUB    $73,$76,$6F,$70,$66,$98,$00,$B0
        EQUB    $62,$6E,$98,$00,$65,$76,$66,$6F
        EQUB    $00,$6E,$BE,$70,$6A,$A2,$00,$C0
        EQUB    $ED,$03,$61,$62,$7A,$00,$66,$0D
        EQUB    $60,$0D,$6E,$0D,$86,$00,$45,$44
        EQUB    $70,$00,$45,$4B,$70,$00,$4A,$03
        EQUB    $70,$60,$6C,$6C,$73,$70,$00,$AA
        EQUB    $60,$62,$73,$66,$03,$60,$62,$73
        EQUB    $70,$76,$A2,$00,$5A,$61,$6C,$6E
        EQUB    $61,$00,$5A,$8D,$00,$5F,$AF,$64
        EQUB    $03,$F4,$00,$59,$03,$9E,$00,$62
        EQUB    $55,$00,$6F,$6F,$00,$E6,$19,$23
        EQUB    $00,$AF,$D8,$AF,$64,$03,$49,$00
        EQUB    $B1,$B3,$64,$7A,$03,$00,$64,$62
        EQUB    $B6,$60,$B4,$60,$00,$2E,$DF,$04
        EQUB    $70,$03,$6D,$62,$6E,$66,$1C,$03
        EQUB    $00,$67,$6C,$60,$68,$00,$26,$A2
        EQUB    $64,$A3,$03,$E8,$B2,$AB,$19,$00
        EQUB    $DF,$03,$27,$2E,$2E,$2E,$25,$3C
        EQUB    $03,$86,$2A,$21,$2E,$9E,$86,$2A
        EQUB    $20,$2E,$60,$BC,$AE,$B4,$BC,$2A
        EQUB    $00,$6A,$BF,$6E,$00,$03,$03,$6F
        EQUB    $6C,$62,$67,$03,$6D,$66,$74,$03
        EQUB    $DF,$03,$C2,$2E,$2E,$00,$25,$5F
        EQUB    $BB,$00,$B7,$B4,$6D,$64,$19,$00
        EQUB    $03,$BC,$03,$00,$2E,$2B,$EC,$6E
        EQUB    $B1,$77,$19,$25,$00,$60,$A2,$B8
        EQUB    $00,$6C,$65,$65,$B1,$67,$B3,$00
        EQUB    $65,$76,$64,$6A,$B4,$B5,$00,$6B
        EQUB    $A9,$6E,$A2,$70,$70,$00,$6E,$6C
        EQUB    $E8,$6F,$7A,$03,$35,$00,$8F,$00
        EQUB    $88,$00,$62,$61,$6C,$B5,$03,$88
        EQUB    $00,$D8,$73,$66,$77,$B1,$77,$00
        EQUB    $67,$B8,$A0,$71,$6C,$AB,$00,$67
        EQUB    $66,$62,$67,$6F,$7A,$00,$0E,$0E
        EQUB    $0E,$0E,$03,$66,$03,$6F,$03,$6A
        EQUB    $03,$77,$03,$66,$03,$0E,$0E,$0E
        EQUB    $0E,$00,$73,$AD,$70,$B1,$77,$00
        EQUB    $2B,$64,$62,$6E,$66,$03,$6C,$B5
        EQUB    $71,$00,$73,$71,$AA,$70,$03,$65
        EQUB    $6A,$AD,$03,$BA,$03,$70,$73,$62
        EQUB    $A6,$0F,$DF,$0D,$2E,$2E,$00,$0B
        EQUB    $60,$0A,$03,$62,$60,$BA,$6D,$A4
        EQUB    $65,$77,$03,$12,$1A,$1B,$17,$00

        EQUB    $FF,$C0,$DF,$D8,$DF,$D8,$D8,$C0
        EQUB    $FF,$00,$7C,$60,$7C,$0C,$7C,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $FF,$E3,$EC,$F0,$C0,$C0,$C0,$C0
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$00,$00,$00,$00,$00,$00,$00
        EQUB    $FF,$E3,$EC,$F0,$F0,$E0,$E0,$C0
        EQUB    $FF,$10,$00,$10,$00,$10,$00,$10
        EQUB    $FF,$E3,$3B,$3F,$0F,$0F,$07,$07
        EQUB    $FF,$00,$00,$00,$00,$00,$33,$FF
        EQUB    $FF,$00,$00,$00,$00,$00,$33,$FF
        EQUB    $FF,$00,$00,$00,$00,$00,$33,$FF
        EQUB    $FF,$00,$00,$00,$00,$00,$33,$FF
        EQUB    $FF,$00,$3E,$30,$3E,$06,$3E,$00
        EQUB    $FF,$03,$FB,$CB,$FB,$C3,$C3,$03
        EQUB    $C0,$C0,$DF,$DB,$DF,$DB,$DB,$C0
        EQUB    $00,$00,$7C,$60,$7C,$0C,$7C,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$01,$28
        EQUB    $00,$00,$00,$00,$00,$00,$28,$00
        EQUB    $00,$00,$00,$00,$02,$A0,$08,$00
        EQUB    $00,$00,$00,$00,$28,$C0,$00,$00
        EQUB    $00,$00,$00,$00,$8A,$00,$00,$00
        EQUB    $00,$00,$00,$00,$2A,$00,$08,$00
        EQUB    $00,$00,$00,$00,$88,$00,$00,$00
        EQUB    $00,$00,$00,$00,$A2,$00,$00,$00
        EQUB    $00,$00,$00,$00,$20,$C8,$08,$00
        EQUB    $00,$00,$00,$00,$00,$A0,$02,$00
        EQUB    $00,$00,$00,$00,$00,$00,$80,$0A
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $C0,$C0,$EA,$C0,$C0,$60,$60,$60
        EQUB    $00,$00,$82,$00,$00,$10,$00,$10
        EQUB    $03,$03,$AB,$03,$03,$03,$07,$07
        EQUB    $00,$00,$00,$00,$00,$00,$0C,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$CC,$FF
        EQUB    $C0,$C0,$00,$00,$00,$C0,$CC,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$CC,$FF
        EQUB    $00,$00,$3E,$32,$3E,$34,$36,$00
        EQUB    $03,$03,$C3,$C3,$C3,$C3,$FB,$03
        EQUB    $C0,$C0,$DF,$D8,$DF,$D8,$D8,$C0
        EQUB    $00,$00,$6C,$6C,$6C,$6C,$7C,$00
        EQUB    $00,$00,$00,$00,$00,$00,$C3,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$0C,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$30,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$C3,$FF
        EQUB    $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
        EQUB    $00,$00,$00,$00,$00,$00,$02,$08
        EQUB    $00,$00,$00,$0A,$20,$80,$00,$00
        EQUB    $02,$28,$80,$08,$00,$00,$00,$00
        EQUB    $00,$00,$00,$88,$00,$00,$00,$00
        EQUB    $00,$00,$00,$88,$02,$00,$08,$00
        EQUB    $20,$00,$80,$88,$00,$00,$00,$00
        EQUB    $0C,$00,$00,$88,$00,$00,$00,$00
        EQUB    $00,$00,$00,$C8,$00,$00,$0C,$00
        EQUB    $08,$00,$08,$80,$08,$00,$08,$00
        EQUB    $00,$00,$00,$88,$00,$00,$0C,$00
        EQUB    $0C,$00,$00,$C8,$00,$00,$00,$00
        EQUB    $02,$00,$00,$88,$00,$00,$00,$00
        EQUB    $00,$00,$80,$08,$20,$00,$08,$00
        EQUB    $00,$00,$00,$88,$00,$00,$00,$00
        EQUB    $40,$0A,$00,$88,$00,$00,$00,$00
        EQUB    $00,$00,$80,$28,$02,$00,$00,$00
        EQUB    $30,$30,$1C,$0C,$07,$81,$20,$08
        EQUB    $00,$10,$00,$10,$00,$FF,$00,$00
        EQUB    $0F,$0F,$3F,$3B,$E3,$FF,$03,$03
        EQUB    $00,$00,$00,$00,$00,$00,$0C,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$30,$FF
        EQUB    $C0,$C0,$00,$00,$00,$C0,$C3,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$0C,$FF
        EQUB    $00,$00,$3C,$36,$36,$36,$3C,$00
        EQUB    $03,$03,$FB,$C3,$C3,$C3,$FB,$03
        EQUB    $C0,$C0,$DF,$D8,$D8,$D8,$DF,$C0
        EQUB    $00,$00,$7E,$18,$18,$18,$18,$00
        EQUB    $00,$00,$00,$00,$00,$00,$C0,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$C0,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$C0,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$C0,$FF
        EQUB    $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
        EQUB    $00,$20,$20,$80,$88,$00,$80,$00
        EQUB    $00,$00,$00,$00,$88,$00,$00,$00
        EQUB    $00,$00,$00,$00,$88,$00,$00,$00
        EQUB    $00,$00,$00,$00,$88,$00,$08,$00
        EQUB    $20,$00,$80,$00,$88,$00,$00,$00
        EQUB    $00,$00,$00,$00,$88,$00,$00,$00
        EQUB    $00,$00,$00,$00,$88,$00,$00,$00
        EQUB    $00,$00,$00,$00,$88,$00,$00,$00
        EQUB    $08,$C0,$08,$08,$9C,$7F,$08,$00
        EQUB    $00,$C0,$00,$00,$88,$00,$00,$00
        EQUB    $00,$00,$00,$00,$88,$00,$00,$00
        EQUB    $00,$00,$00,$00,$88,$00,$00,$00
        EQUB    $02,$00,$00,$00,$88,$00,$00,$00
        EQUB    $00,$00,$80,$00,$88,$00,$08,$00
        EQUB    $00,$00,$00,$00,$88,$00,$00,$00
        EQUB    $00,$00,$00,$00,$88,$00,$00,$00
        EQUB    $08,$02,$02,$00,$88,$00,$00,$00
        EQUB    $00,$00,$00,$80,$00,$80,$00,$80
        EQUB    $03,$03,$03,$03,$03,$03,$03,$03
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$03,$0F,$03,$03,$0F,$00,$00
        EQUB    $03,$03,$03,$03,$03,$83,$03,$03
        EQUB    $C0,$C0,$D8,$D8,$D8,$D8,$DF,$C0
        EQUB    $00,$00,$7E,$18,$18,$18,$18,$00
        EQUB    $00,$00,$00,$00,$00,$00,$C3,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$0C,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$30,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$C0,$FF
        EQUB    $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
        EQUB    $80,$20,$20,$08,$08,$02,$00,$00
        EQUB    $00,$00,$00,$00,$00,$80,$88,$20
        EQUB    $00,$00,$00,$00,$02,$00,$88,$00
        EQUB    $20,$00,$80,$00,$00,$00,$88,$00
        EQUB    $00,$00,$00,$00,$00,$00,$88,$00
        EQUB    $00,$00,$00,$00,$00,$00,$88,$00
        EQUB    $00,$00,$00,$00,$00,$00,$88,$00
        EQUB    $00,$00,$00,$00,$00,$00,$88,$00
        EQUB    $08,$00,$08,$00,$08,$00,$88,$00
        EQUB    $00,$00,$00,$00,$00,$00,$88,$00
        EQUB    $00,$00,$00,$00,$00,$00,$88,$00
        EQUB    $00,$00,$00,$00,$00,$00,$88,$00
        EQUB    $00,$00,$00,$00,$00,$00,$88,$00
        EQUB    $02,$00,$00,$00,$00,$00,$88,$00
        EQUB    $00,$00,$80,$00,$20,$00,$88,$00
        EQUB    $00,$00,$00,$00,$00,$00,$88,$02
        EQUB    $00,$02,$02,$0A,$08,$20,$80,$00
        EQUB    $80,$00,$00,$00,$00,$00,$00,$00
        EQUB    $03,$03,$03,$03,$03,$03,$03,$03
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $0F,$01,$0F,$0C,$0F,$00,$00,$00
        EQUB    $83,$83,$83,$03,$83,$03,$03,$03
        EQUB    $C0,$C0,$DF,$DB,$DF,$DB,$DB,$C0
        EQUB    $00,$00,$60,$60,$60,$60,$7C,$00
        EQUB    $00,$00,$00,$00,$00,$00,$C3,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$03,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$03,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $08,$02,$00,$00,$00,$00,$00,$00
        EQUB    $20,$80,$20,$04,$00,$00,$00,$00
        EQUB    $00,$00,$00,$80,$28,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$A0,$02,$00
        EQUB    $00,$00,$00,$00,$00,$00,$88,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$A2
        EQUB    $00,$00,$00,$00,$00,$00,$00,$28
        EQUB    $08,$00,$08,$00,$08,$00,$08,$8A
        EQUB    $00,$00,$00,$00,$00,$00,$00,$22
        EQUB    $00,$00,$00,$00,$00,$00,$00,$88
        EQUB    $00,$00,$00,$00,$00,$00,$22,$80
        EQUB    $00,$00,$00,$00,$00,$0A,$80,$00
        EQUB    $00,$00,$00,$00,$28,$00,$00,$00
        EQUB    $02,$00,$0A,$A0,$00,$00,$00,$00
        EQUB    $10,$80,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $03,$03,$03,$03,$03,$03,$03,$03
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $0F,$01,$0F,$01,$0F,$00,$00,$0C
        EQUB    $83,$83,$83,$83,$83,$03,$03,$03
        EQUB    $C0,$DC,$DF,$C7,$DF,$DC,$C0,$FF
        EQUB    $00,$00,$F8,$DC,$F8,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $C0,$C0,$C0,$C0,$F0,$EC,$E3,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$0F,$0C,$0F,$0C,$0F,$00,$FF
        EQUB    $00,$CC,$0C,$0C,$0C,$CF,$00,$FF
        EQUB    $00,$1E,$0C,$0C,$0C,$DE,$00,$FF
        EQUB    $00,$FC,$30,$30,$30,$30,$00,$FF
        EQUB    $00,$FC,$C0,$F0,$C0,$FC,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $03,$03,$03,$03,$0F,$3B,$E3,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $0C,$0D,$0D,$0F,$01,$00,$00,$FF
        EQUB    $03,$83,$83,$83,$83,$03,$03,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$07,$3F
        EQUB    $00,$00,$00,$03,$1F,$FF,$FF,$FF
        EQUB    $00,$0F,$7F,$FF,$FF,$FF,$FF,$FF
        EQUB    $00,$FF,$FF,$FF,$FF,$E0,$80,$FF
        EQUB    $00,$FF,$E0,$00,$FF,$00,$00,$FF
        EQUB    $00,$FF,$00,$00,$FE,$00,$00,$FE
        EQUB    $00,$FF,$00,$00,$00,$00,$03,$0F
        EQUB    $00,$E1,$07,$0F,$3F,$FF,$FF,$FF
        EQUB    $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        EQUB    $00,$FF,$FE,$FC,$F0,$E0,$C0,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$83
        EQUB    $00,$3F,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$FF,$0F,$0F,$0F,$0F,$1F,$FF
        EQUB    $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        EQUB    $00,$FF,$FC,$FC,$FC,$FC,$FE,$FF
        EQUB    $00,$FF,$00,$00,$00,$00,$00,$FF
        EQUB    $00,$87,$00,$00,$00,$00,$00,$E0
        EQUB    $00,$FF,$00,$00,$00,$00,$00,$00
        EQUB    $00,$FF,$7F,$7F,$3F,$1F,$0F,$07
        EQUB    $00,$FF,$FF,$FF,$FF,$FF,$FF,$FF
        EQUB    $00,$FF,$C0,$E0,$F8,$FC,$FE,$FF
        EQUB    $00,$E0,$00,$00,$00,$00,$00,$80
        EQUB    $00,$FF,$3F,$1F,$07,$01,$00,$00
        EQUB    $00,$FF,$FF,$FF,$FF,$FF,$7F,$1F
        EQUB    $00,$FF,$E0,$F8,$FF,$FF,$FF,$FF
        EQUB    $00,$FF,$00,$00,$FF,$C0,$F0,$FF
        EQUB    $00,$FC,$00,$00,$FF,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$80,$00,$00,$FF
        EQUB    $00,$00,$00,$00,$00,$00,$00,$FE
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$07
        EQUB    $00,$00,$00,$00,$03,$1F,$F8,$C3
        EQUB    $00,$00,$0F,$7C,$FF,$0F,$7C,$F0
        EQUB    $00,$3F,$8F,$7C,$F1,$8F,$3F,$3F
        EQUB    $00,$C0,$8F,$7C,$F0,$C0,$1F,$F0
        EQUB    $00,$FF,$9F,$00,$00,$03,$8F,$07
        EQUB    $00,$01,$1F,$7C,$F8,$E1,$C7,$FE
        EQUB    $00,$FE,$1F,$7C,$F8,$F1,$E3,$07
        EQUB    $00,$1F,$3E,$7C,$FF,$FB,$F0,$E1
        EQUB    $00,$FC,$3E,$7C,$F0,$E0,$F8,$F8
        EQUB    $00,$3E,$3E,$7F,$7F,$7C,$7C,$FC
        EQUB    $00,$7C,$7C,$BE,$FE,$FE,$3E,$3F
        EQUB    $00,$3F,$7C,$3E,$0F,$00,$1F,$03
        EQUB    $00,$E0,$7C,$00,$F8,$1F,$0F,$FF
        EQUB    $00,$7F,$F8,$3E,$1F,$8F,$C7,$00
        EQUB    $00,$83,$F8,$3E,$1F,$87,$E3,$7F
        EQUB    $00,$FF,$F8,$3E,$0F,$C7,$F1,$E0
        EQUB    $00,$CF,$00,$00,$FE,$E0,$F8,$7E
        EQUB    $00,$FF,$1F,$03,$00,$00,$00,$00
        EQUB    $00,$00,$00,$E0,$7C,$1F,$03,$00
        EQUB    $00,$00,$00,$00,$00,$80,$F0,$7E
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$01,$03,$07
        EQUB    $00,$00,$01,$0E,$38,$E0,$C3,$87
        EQUB    $00,$38,$C3,$0E,$38,$E0,$9C,$E1
        EQUB    $00,$7C,$B8,$00,$03,$07,$38,$C0
        EQUB    $00,$70,$70,$E0,$C0,$00,$00,$00
        EQUB    $00,$00,$00,$01,$03,$0F,$1C,$39
        EQUB    $00,$3F,$E7,$DE,$FD,$73,$E7,$C7
        EQUB    $00,$00,$00,$7E,$CE,$81,$39,$E1
        EQUB    $00,$00,$00,$3F,$E7,$EE,$DE,$F8
        EQUB    $00,$00,$00,$3F,$7F,$70,$F0,$E0
        EQUB    $00,$00,$00,$9F,$9D,$3D,$3D,$39
        EQUB    $00,$00,$00,$C7,$EE,$E7,$C0,$CF
        EQUB    $00,$00,$00,$F3,$07,$E7,$73,$E1
        EQUB    $00,$00,$01,$F1,$B9,$BC,$BC,$F8
        EQUB    $00,$F1,$C0,$E1,$F8,$F0,$70,$78
        EQUB    $00,$C0,$E0,$FC,$70,$38,$3C,$0F
        EQUB    $00,$00,$00,$00,$00,$00,$00,$80
        EQUB    $00,$70,$7C,$0E,$07,$03,$01,$03
        EQUB    $00,$7C,$77,$3D,$07,$80,$E0,$FC
        EQUB    $00,$7E,$BB,$DE,$F3,$39,$3C,$7C
        EQUB    $00,$0E,$87,$E3,$F3,$DE,$F7,$1F
        EQUB    $00,$00,$80,$E0,$F8,$FF,$83,$80
        EQUB    $00,$00,$00,$00,$00,$00,$80,$E0
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00

.ENTRY
        JMP     ENTRY2

        EQUB    $16

        EQUB    $04,$1C,$08,$13,$17,$0A,$17,$01
        EQUB    $00,$00,$00,$00,$00,$00,$00,$00

        EQUB    $01,$01,$00,$6F,$F8,$04,$01,$08
        EQUB    $7E,$00,$00,$82,$7E,$7E,$02,$01
        EQUB    $0E,$EE,$FF,$2C,$20,$32,$06,$01
        EQUB    $00,$FE,$78,$7E,$03,$01,$01,$FF
        EQUB    $FD,$11,$20,$80,$01,$00,$00,$FF
        EQUB    $01,$01,$04,$01

        EQUB    $04,$F8,$2C,$04,$06,$08,$16


.L5247
        EQUB    $00,$00,$81,$7E,$00,$6C,$FC,$FF

.OSB
        LDY     #$00
        JMP     OSBYTE

        EQUS    "RUN ELITEcode"

        EQUB    $0D

        EQUS    "By D.Braben/I.Bell"

        EQUB    $0D

        EQUB    $B0,$F7,$FF

.L5278
        EQUB    $56,$54,$D8,$06,$00

.doPROT1
        LDY     #$DB
        STY     TRTB%
        LDY     #$EF
        STY     L0005
        LDY     #$02
        STY     L007B
        CMP     L5247,X
        LDY     #$18
        STY     L007B,X
        RTS

.L5291
        EQUB    $CA

.David7
        BCC     Ian1

.ENTRY2
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
        LDA     #$60
        STA     L0088
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
        LDA     #$20
        NOP
.Ian1
        NOP
        NOP
        NOP
        NOP
        NOP
        LSR     A
        LDX     #$03
        STX     L0079
        STX     L0084
        STX     L0086
        LDX     #$00
        LDY     #$00
        JSR     OSBYTE

        LDX     #$FF
        LDA     #$95
        JSR     doPROT1

        LDA     #$90
        JSR     OSB

        EQUB    $2C

.FRED1
        BNE     David7

        LDA     #$F7
        LDX     #$00
        JSR     OSB

        LDA     #$8F
        LDX     #$0C
        LDY     #$FF
        JSR     OSBYTE

        LDA     #$0D
.abrk
        LDX     #$00
L5313 = abrk+1
        JSR     OSB

        LDA     #$E1
        LDX     #$80
        JSR     OSB

        LDA     #$AC
        LDX     #$00
        LDY     #$FF
        JSR     OSBYTE

        STX     TRTB%
        STY     L0005
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
        LDA     #$0D
        LDX     #$02
        JSR     OSB

        LDX     #$FF
        TXS
        INX
        LDY     #$00
.David3
        LDA     crunchit,Y
.PROT1
        STA     L0006,X
        INX
        INY
        CPY     #$21
        BNE     David3

        LDA     #$03
        STA     ZP
        LDA     #$95
        BIT     PROT1
        LDA     #$52
        STA     L0071
        LDY     #$00
.LOOP
        LDA     (ZP),Y
        JSR     OSWRCH

        INY
        CPY     #$11
        BNE     LOOP

        LDA     #$01
        TAX
        TAY
        LDA     L5313
        CMP     (V219),Y
        LDA     #$04
        JSR     OSB

        LDA     #$09
        LDX     #$00
        JSR     OSB

        LDA     #$6C
        NOP
        NOP
        NOP
        BIT     L544F
        LDX     #$14
        LDY     #$52
        LDA     #$08
        JSR     OSWORD

        LDX     #$22
        LDY     #$52
        LDA     #$08
        JSR     OSWORD

        LDX     #$30
        LDY     #$52
        LDA     #$08
        JSR     OSWORD

        LDX     #$3E
        LDY     #$52
        LDA     #$08
        JSR     OSWORD

        LDX     #$04
        STX     Q
        LDA     #$44
        STA     L0071
        LDY     #$00
        LDA     #$18
        CMP     (SC,X)
        STY     ZP
        STY     P
        JSR     crunchit

        LDX     #$01
        LDA     #$4F
        STA     L0071
        LDA     #$5B
        STA     Q
        LDA     #$E0
        STA     P
        LDY     #$00
        JSR     crunchit

        LDX     #$01
        LDA     #$50
        STA     L0071
        LDA     #$59
        STA     Q
        LDA     #$60
        STA     P
        LDY     #$00
        JSR     crunchit

        LDX     #$01
        LDA     #$51
        STA     L0071
        LDA     #$73
        STA     Q
        LDA     #$A0
        STA     P
        LDY     #$00
        JSR     crunchit

        JSR     PLL1

        LDA     #$48
        STA     L0071
        LDA     #$76
        STA     Q
        LDY     #$00
        STY     ZP
        LDX     #$20
        STY     L0081
        STX     P
.L540B
        LDX     #$01
        JSR     crunchit

        CLC
        LDA     P
        ADC     #$40
        STA     P
        LDA     Q
        ADC     #$00
        STA     Q
        CMP     #$7E
        BCC     L540B

        LDX     #$01
        LDA     #$56
        STA     L0071
        LDA     #$15
        STA     ZP
        LDA     #$0B
        STA     Q
        LDY     #$00
        STY     P
        JSR     crunchit

        JMP     L0B11

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
.L5452
        EQUB    $49

.L5453
        EQUB    $53

.L5454
        EQUB    $78

.L5455
        EQUB    $6C

.L5456
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
        JSR     DORND

        JSR     SQUA2

        STA     L0071
        LDA     P
        STA     ZP
        JSR     DORND

        STA     YY
        JSR     SQUA2

        TAX
        LDA     P
        ADC     ZP
        STA     ZP
        TXA
        ADC     L0071
        BCS     PLC1

        STA     L0071
        LDA     #$01
        SBC     ZP
        STA     ZP
        LDA     #$40
        SBC     L0071
        STA     L0071
        BCC     PLC1

        JSR     ROOT

        LDA     ZP
        LSR     A
        TAX
        LDA     YY
        CMP     #$80
        ROR     A
        JSR     PIX

.PLC1
        DEC     CNT
        BNE     PLL1

        DEC     L55B8
        BNE     PLL1

        LDX     #$C2
        STX     EXCN
        LDX     #$60
        STX     L0087
.PLL2
        JSR     DORND

        TAX
        JSR     SQUA2

        STA     L0071
        JSR     DORND

        STA     YY
        JSR     SQUA2

        ADC     L0071
        CMP     #$11
        BCC     PLC2

        LDA     YY
        JSR     PIX

.PLC2
        DEC     CNT2
        BNE     PLL2

        DEC     L55BA
        BNE     PLL2

        LDX     #$CA
        NOP
        STX     BLPTR
        LDX     #$C6
        STX     BLN
.PLL3
        JSR     DORND

        STA     ZP
        JSR     SQUA2

        STA     L0071
        JSR     DORND

        STA     YY
        JSR     SQUA2

        STA     T
        ADC     L0071
        STA     L0071
        LDA     ZP
        CMP     #$80
        ROR     A
        CMP     #$80
        ROR     A
        ADC     YY
        TAX
        JSR     SQUA2

        TAY
        ADC     L0071
        BCS     PLC3

        CMP     #$50
        BCS     PLC3

        CMP     #$20
        BCC     PLC3

        TYA
        ADC     T
        CMP     #$10
        BCS     PL1

        LDA     ZP
        BPL     PLC3

.PL1
        LDA     YY
        JSR     PIX

.PLC3
        DEC     CNT3
        BNE     PLL3

        DEC     L55BC
        BNE     PLL3

.DORND
        LDA     L5453
        TAX
        ADC     L5455
        STA     L5453
        STX     L5455
        LDA     L5452
        TAX
        ADC     L5454
        STA     L5452
        STX     L5454
        RTS

.SQUA2
        BPL     SQUA

        EOR     #$FF
        CLC
        ADC     #$01
.SQUA
        STA     Q
        STA     P
        LDA     #$00
        LDY     #$08
        LSR     P
.SQL1
        BCC     SQ1

        CLC
        ADC     Q
.SQ1
        ROR     A
        ROR     P
        DEY
        BNE     SQL1

.L5575
        RTS

.PIX
        LDY     #$80
        STY     ZP
        TAY
        EOR     #$80
        CMP     #$F8
        BCS     L5575

        LSR     A
        LSR     A
        LSR     A
        STA     L0071
        LSR     A
        ROR     ZP
        LSR     A
        ROR     ZP
        ADC     L0071
        ADC     #$58
        STA     L0071
        TXA
        EOR     #$80
        AND     #$F8
        ADC     ZP
        STA     ZP
        BCC     L559F

        INC     L0071
.L559F
        TYA
        AND     #$07
        TAY
        TXA
        AND     #$07
        TAX
        LDA     L55AF,X
        ORA     (ZP),Y
        STA     (ZP),Y
        RTS

.L55AF
        EQUB    $80

        EQUB    $40,$20,$10,$08,$04,$02,$01

.CNT
        EQUB    $00

.L55B8
        EQUB    $05

.CNT2
        EQUB    $DD

.L55BA
        EQUB    $01

.CNT3
        EQUB    $00

.L55BC
        EQUB    $05

.ROOT
        LDY     L0071
        LDA     ZP
        STA     Q
        LDX     #$00
        STX     ZP
        LDA     #$08
.L55C9
        STA     P
.LL6
        CPX     ZP
        BCC     LL7

        BNE     LL8

        CPY     #$40
        BCC     LL7

.LL8
        TYA
        SBC     #$40
        TAY
        TXA
        SBC     ZP
        TAX
.LL7
        ROL     ZP
        ASL     Q
        TYA
        ROL     A
        TAY
        TXA
        ROL     A
        TAX
        ASL     Q
        TYA
        ROL     A
        TAY
        TXA
        ROL     A
        TAX
        DEC     P
        BNE     LL6

        RTS

.crunchit
        LDA     (ZP),Y
        NOP
        NOP
        NOP
        STA     (P),Y
        DEY
        BNE     crunchit

        INC     Q
        INC     L0071
        DEX
        BNE     crunchit

        RTS

        PLA
        PLA
        LDA     L0C24,Y
        PHA
        EOR     L0B3D,Y
        NOP
        NOP
        NOP
        JMP     (L5278)

        BPL     L5627

        BPL     L5629

        BPL     L562B

        BPL     L562D

        BPL     L562F

        BPL     L5631

        BPL     L5633

        BPL     L5635

        BPL     L55C9

.L5627
        INY
.L5628
        LDY     #$0B
L5629 = L5628+1
.L562A
        JSR     OSCLI

L562B = L562A+1
.L562D
        LDA     #$03
.L562F
        STA     L0258
L5631 = L562F+2
.L5632
        LDA     #$8C
L5633 = L5632+1
.L5634
        LDX     #$0C
L5635 = L5634+1
        LDY     #$00
        JSR     OSBYTE

        LDA     #$8F
        LDX     #$0C
        LDY     #$FF
        JSR     OSBYTE

        LDA     #$40
        STA     L0D00
        LDX     #$4A
        LDY     #$00
        STY     ZP
        STY     P
        LDA     #$20
        STA     L0071
        LDA     #$0D
        STA     Q
.L5659
        LDA     (ZP),Y
        STA     (P),Y
        LDA     #$00
        STA     (ZP),Y
        INY
        BNE     L5659

        INC     L0071
        INC     Q
        DEX
        BPL     L5659

        SEI
        TXS
        LDA     RDCHV
        STA     USERV
        LDA     L0211
        STA     L0201
        LDA     KEYV
        STA     L0D04
        LDA     L0229
        STA     L0D05
        LDA     #$10
        STA     KEYV
        LDA     #$0D
        STA     L0229
        LDA     L0D0E
        STA     BRKV
        LDA     L0D0F
        STA     L0203
        LDA     L0D0A
        STA     WRCHV
        LDA     L0D0B
        STA     L020F
        LDA     IRQ1V
        STA     L0D02
        LDA     L0205
        STA     L0D03
        LDA     L0D0C
        STA     IRQ1V
        LDA     L0D0D
        STA     L0205
        LDA     #$FC
        JSR     L0BC2

        LDA     #$08
        JSR     L0BC2

        LDA     #$60
        STA     LFE02
        LDA     #$3F
        STA     LFE03
        CLI
        JMP     (L0D08)

        STA     L00F4
        STA     LFE05
        RTS

        EQUS    "LOAD EliteCo FFFF2000"

        EQUB    $0D,$00,$00,$00,$00,$00,$00,$00
        EQUB    $00,$00,$00,$00,$00,$00

.BeebDisEndAddr





PRINT "S.ELITEDA ", ~CODE%, " ", ~P%, " ", ~LOAD%, " ", ~LOAD%
SAVE "output/ELITEDA.bin", CODE%, P%, LOAD%
