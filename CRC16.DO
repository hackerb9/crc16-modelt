10 MAXFILES=0: CLEAR 10, 59595
20 DEFINT A-Z
30 TP=-5941: LN=1437: EX=-5941
40 GOSUB 13000
50 IF PEEK(1)<>148 THEN CALL EX ELSE EXEC EX
60 END
13000 'Decode ML
13010 CLS:Q=0:H$=CHR$(13)
13020 ?"     / 1436 CRC16.CO at 59595";
13030 READP$:FORX=1TOLEN(P$):a$=MID$(P$,X,1)
13040 if a$="/" then if e=1 then 13080: else e=1: goto 13070
13050 v=asc(a$): if e=1 then v=v-128: e=0
13060 ?H$q;:POKEQ+TP,v:Q=Q+1
13070 NEXT:GOTO13030
13090 RETURN
14000 'CRC16.CO
14010 DATA"!OëÍÖé!//€^!nSVëÍÿéë!ÒëÍEêÍÏé/‘//€/šş«Ê/‹é!ŸêÍÖé/‘nS/šşëÊ]é/‘/€/€//€€ÍúíÃ}é!{êÍÖé!ŸêÍÖé/‘/€/€//€€Í,ê!‡êÍÖé!ŸêÍÖé/‘/€€//€ Í,ê!“êÍÖé!ŸêÍÖéóÛ
14020 DATA"Øæ/Œö/ÓØ/‘/€/€//€€ÍúíÛØæ/ŒÓØûÃ}éó!/€/€/–/€Õ/‘/€/€//€€ÍıíÑÛ£æü/”²Ó£zş/„ÂcéûÍ/¯ê!©êÍÖé/‘//€/šş«Êºéş3ÊÁéş§ÊÁéş”ÊÈéÍeê!ÌêÍÖé///€!ÿÿ+}´Â­é/‹y°ÂªéÉÍ
14030 DATA"÷/’ÍeêÉÍË/’ÍeêÉÍM/—ÍeêÉ>/ç>/ŠçÉ~§Êåéş/ÿòæéç#ÃÖéÉåÕ!×êÖ€_/–/€/™/™^#VëÍÖéÑá#ÃÖé|Í/‹ê}Í/‹ê> çÉÕWæğ/Ÿ/Ÿ/Ÿ/ŸÍ/œêzÍ/œêÑÉÅåæ//†/€O!kê	~çáÁÉÍúíÍÿéÍ
14040 DATA"9êÍÏéÉåÕë!/†ìÍEêÑáÉN#F#x±Ê]êxºÂXêy»Ê]ê##ÃEê^#VëÍÖéÉ&ÈÍÖéÉ0123456789ABCDEF Main 32K †/€ Main  8K †/€Multiplan †/€CRC-16 = /€  
14050 DATA"      <Hit any key to exit.>/€//›K/€Pausing.../€ëêóêıê/„ë/’ë/šë/¯ë4ë/€/€7ëTRS-80 /€Model 100/€Tandy /€Olivetti M10 /€NEC PC-/€Kyocera K
14060 DATA"yotronic 85/€ROM /€/€/€/€Error in mkcrctable.awk/€QuickID: /€…/€‚200/€€/€‚102 (US)/€‚102 (UK)/€ƒ(EU)/€ƒ(NA)/€„8201/€„8300/€„8300 Beckma
14070 DATA"n E3.2/€‚600 BASIC/€€Televerket Modell 100/€Unknown model/€##wë3S`ëHÑë}Í}ëş¢ë”eƒë”ë‰ë§Scë§`më«	[ëáÂYë§{­ë/€/€ÄëğÃì¨dÄì¤Ûì÷
14080 DATA"‡Ñì Œİì/ˆ/…ãìõŸòì©ãóìÒ]÷ì/“/›øìŸ]/…íD^/†í/‡=íğ\NíÄOío/œSí[ŞTí/š=`ío·XíŒ•dí—|„í5•íÃ%híÿ>xí«g”íaÀ¥í4•¨íd*¯íğ`/Šíõ4'í•¯/–íwz(í/ ,í$
14090 DATA"b0íÁö9í/œç²ìMU/í×}Eí/€>œíÇ‘ÈìºÔéìS·üì/€/€°íVirT 1.7, no Y2K/€/€y2k/€VirT 1.7/€A.REX.y2k/€A/€A.y2k/€Japan/€VirT 1.7/€/€y2k/€/€y2k/€VirT 1.
14100 DATA"7/€/€y2k/€LibROM-1.1a/€REX.y2k/€VirT 1.7/€/€skl/€y2k/€26-3802B/€y2k/€REX.y2k/€VirT 1.7/€/€y2k/€/€y2k/€M13.REX/€M13/€M14/€M15.REX.corrupt/€M15
14110 DATA".REX.y2k/€M15.corrupt/€M15/€M15.y2k/€VirT 1.7/€us/€us.y2k/€/€Unknown!//Š! Please file an issue at//Š! github.com/¯hackerb9/¯crc16-mo
14120 DATA"delt//Š/€!/€/€/š¬g)Ò/Œî|î/g}î!o)Ò/˜î|î/g}î!o)Ò$î|î/g}î!o)Ò0î|î/g}î!o)Ò<î|î/g}î!o)ÒHî|î/g}î!o)ÒTî|î/g}î!o)Ò`î|î/g}î!o/“/‹x±ÂıíÉ
14130 DATA"//"
