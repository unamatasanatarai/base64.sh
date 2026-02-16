#!/usr/bin/env bash

usage() {
    echo "Usage: ${0##*/} <base64_string>"
    echo "       echo -n <base64_string> | ${0##*/}"
    exit 1
}

if [[ $# -eq 0 && -t 0 ]]; then
    usage
fi

input="${1:-$(cat)}"
[[ -z "$input" ]] && usage

len=${#input}

# Base64 decode lookup table (ASCII indexed)
# Valid chars map to 0–63
# All other bytes map to 0
# '=' (61) maps to 0

declare -a T=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 62 0 0 0 63 52 53 54 55 56 57 58 59 60 61 0 0 0 0 0 0 0 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 0 0 0 0 0 0 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51)

for ((i = 0; i < len; i += 4)); do
    printf -v a '%d' "'${input:i:1}"
    printf -v b '%d' "'${input:i+1:1}"
    printf -v c '%d' "'${input:i+2:1}"
    printf -v d '%d' "'${input:i+3:1}"

    b1=${T[a]}
    b2=${T[b]}
    b3=${T[c]}
    b4=${T[d]}

    bits=$(((b1 << 18) | (b2 << 12) | (b3 << 6) | b4))

    printf "\\$(printf '%03o' $(((bits >> 16) & 255)))"

    [[ ${input:i+2:1} != "=" ]] && printf "\\$(printf '%03o' $(((bits >> 8) & 255)))"
    [[ ${input:i+3:1} != "=" ]] && printf "\\$(printf '%03o' $((bits & 255)))"
done
