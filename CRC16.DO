10 MAXFILES=0: CLEAR 10, 59595
20 DEFINT A-Z
30 TP=-5941: LN=1451: EX=-5941
40 GOSUB 13000
50 IF PEEK(1)<>148 THEN CALL EX ELSE EXEC EX
60 END
13000 'Decode ML
13010 CLS:Q=0:H$=CHR$(13)
13020 ?"     / 1450 CRC16.CO at 59595";
13030 READP$:FORX=1TOLEN(P$):a$=MID$(P$,X,1)
13040 if a$="/" then if e=1 then 13080: else e=1: goto 13070
13050 v=asc(a$): if e=1 then v=v-128: e=0
13060 ?H$q;:POKEQ+TP,v:Q=Q+1
13070 NEXT:GOTO13030
13090 RETURN
14000 'CRC16.CO
14010 DATA"!OëÍÖé!//€^!nSVëÍÿéë!ÒëÍEêÍÏé/‘//€/šþ«Ê/‹é!ŸêÍÖé/‘nS/šþëÊ]é/‘/€/€//€€Í/ˆîÃ}é!{êÍÖé!ŸêÍÖé/‘/€/€//€€Í,ê!‡êÍÖé!ŸêÍÖé/‘/€€//€ Í,ê!“êÍÖé!ŸêÍÖéóÛ
14020 DATA"Øæ/Œö/ÓØ/‘/€/€//€€Í/ˆîÛØæ/ŒÓØûÃ}éó!/€/€/–/€Õ/‘/€/€//€€Í/‹îÑÛ£æü/”²Ó£zþ/„ÂcéûÍ/¯ê!©êÍÖé/‘//€/šþ«Êºéþ3ÊÁéþ§ÊÁéþ”ÊÈéÍeê!ÌêÍÖé///€!ÿÿ+}´Â­é/‹y°ÂªéÉÍ
14030 DATA"÷/’ÍeêÉÍË/’ÍeêÉÍM/—ÍeêÉ>/ç>/ŠçÉ~§Êåéþ/ÿòæéç#ÃÖéÉåÕ!×êÖ€_/–/€/™/™^#VëÍÖéÑá#ÃÖé|Í/‹ê}Í/‹ê> çÉÕWæð/Ÿ/Ÿ/Ÿ/ŸÍ/œêzÍ/œêÑÉÅåæ//†/€O!kê	~çáÁÉÍ/ˆîÍÿéÍ
14040 DATA"9êÍÏéÉåÕë!/†ìÍEêÑáÉN#F#x±Ê]êxºÂXêy»Ê]ê##ÃEê^#VëÍÖéÉ&ÈÍÖéÉ0123456789ABCDEF Main 32K †/€ Main  8K †/€Multiplan †/€CRC-16 = /€  
14050 DATA"      <Hit any key to exit.>/€//›K/€Pausing.../€ëêóêýê/„ë/’ë/šë/¯ë4ë/€/€7ëTRS-80 /€Model 100/€Tandy /€Olivetti M10 /€NEC PC-/€Kyocera K
14060 DATA"yotronic 85/€ROM /€/€/€/€Error in mkcrctable.awk/€QuickID: /€…/€‚200/€€/€‚102 (US)/€‚102 (UK)/€ƒ(EU)/€ƒ(NA)/€„8201/€„8300/€„8300 Beckma
14070 DATA"n E3.2/€‚600 BASIC/€€Televerket Modell 100/€Unknown model/€##wë3S`ëHÑë}Í}ëþ¢ë”eƒë”ë‰ë§Scë§`më«	[ëáÂYë§{­ë/€/€ÄëðÃì¨dÄì¤Ûì÷
14080 DATA"‡Ñì ŒÝì/ˆ/…ãìõŸòì©ãóìÒ]÷ì/“/›øìŸ]/…íD^/†í/‡=íð\NíÄžOío/œSí[ÞTí/š=`ío·XíŒ•dí—|œíaÀhí4•rí5•¨íÃ%€íÿ>í«g¬íd*½íð`/Šíõ4'í•¯/–íwz(í/ ,í$
14090 DATA"b0íÁö9í/œç²ìMU/ží×}Eí/€>´íÇ‘ÈìºÔéìS·üì/€/€¾íVirT 1.7, no Y2K/€/€y2k/€VirT 1.7/€A REX y2k/€A/€A y2k/€Japan/€VirT 1.7/€/€y2k/€/€y2k/€VirT 1.
14100 DATA"7/€/€y2k/€LibROM-1.1a/€REX y2k/€VirT 1.7/€/€skl/€y2k/€26-3802B/€y2k/€REX y2k/€VirT 1.7/€/€y2k/€/€y2k/€M13 REX/€M13/€M14/€M15M13M14/€M15M13M14
14110 DATA" y2k/€M15 REX corrupt/€M15 REX y2k/€M15 corrupt/€M15/€M15 y2k/€VirT 1.7/€/€Unknown!//Š! Please file an issue at//Š! github.com/¯hac
14120 DATA"kerb9/¯crc16-modelt//Š/€!/€/€/š¬g)Ò/šî|î/g}î!o)Ò&î|î/g}î!o)Ò2î|î/g}î!o)Ò>î|î/g}î!o)ÒJî|î/g}î!o)ÒVî|î/g}î!o)Òbî|î/g}î!o)Ònî|î/g}
14130 DATA"î!o/“/‹x±Â/‹îÉ
14140 DATA"//"
