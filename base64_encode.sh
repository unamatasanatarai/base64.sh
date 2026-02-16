#!/usr/bin/env bash

usage() {
    echo "Usage: ${0##*/} <string>"
    echo "       echo -n <string> | ${0##*/}"
    exit 1
}

if [[ $# -eq 0 && -t 0 ]]; then
    usage
fi

input="${1:-$(cat)}"
[[ -z "$input" ]] && exit 0

ALPHABET='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
len=${#input}

for ((i = 0; i < len; i += 3)); do
    printf -v b1 '%d' "'${input:i:1}"
    printf -v b2 '%d' "'${input:i+1:1}"
    printf -v b3 '%d' "'${input:i+2:1}"

    b2=${b2:-0}
    b3=${b3:-0}

    bits=$(((b1 << 16) | (b2 << 8) | b3))

    c1=$(((bits >> 18) & 63))
    c2=$(((bits >> 12) & 63))
    c3=$(((bits >> 6) & 63))
    c4=$((bits & 63))

    remaining=$((len - i))

    case $remaining in
    1) printf "%s%s==" "${ALPHABET:c1:1}" "${ALPHABET:c2:1}" ;;
    2) printf "%s%s%s=" "${ALPHABET:c1:1}" "${ALPHABET:c2:1}" "${ALPHABET:c3:1}" ;;
    *) printf "%s%s%s%s" "${ALPHABET:c1:1}" "${ALPHABET:c2:1}" "${ALPHABET:c3:1}" "${ALPHABET:c4:1}" ;;
    esac

done
