#!/bin/bash -e
#
# Given a .CO machine language file for a TRS-80 Model 100 (or similar),
# Output a .DO file containing a BASIC locader which will install the .CO.
#
# hackerb9, February 2026
# Inspired by Stephen Adolph's encoding scheme.

function usage() {
    cat <<EOF
Usage: co2do.sh <INPUT.CO> [OUTPUT.DO]
EOF
}

function main() {
    declare -i TOP LEN EXE
    TOP=$1+$2*256
    LEN=$3+$4*256
    EXE=$5+$6*256
    shift 6
cat <<EOF
10 CLEAR 256, $TOP
20 TP=$TOP: LN=$LEN: EX=$EXE
30 GOSUB 13000
40 IF PEEK(1)<>148 THEN ?"Use CALL $EXE" ELSE ?"Use EXEC $EXE"
50 END
13000 REM Decode and load M/L
13010 Q=$TOP
EOF
    emitbasicdecode
    printdata "$@"
}

function printdata() {
    printf "14000 REM .CO file data"
    local -i linenum=14000 
    local -i v
    for v; do
	if (( count++ % 120 == 0 )); then
	    printf '\n%d DATA"' $((linenum+=10))
	fi
	# Escape quotation mark, slash, delete, and ctrl chars (except tab)
	if (( (v<32 && v!=9) || v==34 || v==23 || v==47 || v==127 )); then
	    v=v+128
	    printf "/"
	fi
	printf -v x "%x" $v
	printf "\x$x"
    done
    # End of DATA marked by '//'
    printf '\n%d DATA"//"\n' $((linenum+=10))
}

function emitbasicdecode() {
    # Credit to Stephen Adolph for the decode routine and encoding scheme.
    # Any errors are mine (hackerb9).
    # I modified it to autodetect the load address from binary.
    # I use the invalid sequence "//" for End of Data
    #   which allows me to quote DEL (7F) using "/\xFF".
    # I subtract 128 instead of adding it, just for aesthetics.
    # I double check the filesize matches the header length.
    cat <<"EOF"
13020 CLS:PRINT"loading ML code...";
13030 READP$:e=0:FORX=1TOLEN(P$):a$=MID$(P$,X,1)
13040 if a$="/" and e=1 then 13080
13050 if a$="/" then e=1:goto 13070
13055 v=asc(a$): if e=1 then v=v-128: e=0
13060 print@20,q:POKEQ,v:Q=Q+1
13070 NEXTx:GOTO13030
13080 IF LN <> (q-TP) THEN ?:?"Error: Length",LN"<>"q-TP: END
13090 RETURN
EOF
}


{
    # CLI args
    tandycharset=cat
    if [[ "$1" == "-t" ]]; then
	shift
	tandycharset="iconv -f $(dirname $0)/tandy-200.charmap"
    fi
    if [[ "$1" == "-" ]]; then shift; set -- /dev/stdin "$@"; fi

    if [ -z "$1" ]; then
	usage
	exit 1
    elif [ ! -r "$1" ]; then
	echo "'$1' is not readable"
	exit 1
    else
	input="$1"
	shift
    fi

    if [ "$2" ]; then
	output="$2"
	shift
    elif [[ input == *.CO ]]; then
	output=${input%.CO}.DO
    elif [[ input == *.co ]]; then
	output=${input%.co}.do
    else
	output=/dev/stdout
    fi
}
main $(od -t u1 -v -An "$input") | $tandycharset > "$output"
