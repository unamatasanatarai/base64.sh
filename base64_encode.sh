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

if [[ -z "$input" ]]; then
    usage
fi

readonly ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

base64=""
len=${#input}

for ((i = 0; i < len; i += 3)); do
    c1="${input:i:1}"
    c2="${input:i+1:1}"
    c3="${input:i+2:1}"

    printf -v b1 "%d" "'$c1"

    if [[ -n "$c2" ]]; then
        printf -v b2 "%d" "'$c2"
    else
        b2=0
    fi

    if [[ -n "$c3" ]]; then
        printf -v b3 "%d" "'$c3"
    else
        b3=0
    fi

    let "bits = (b1 << 16) | (b2 << 8) | b3"

    # 63 == 1111111
    let "s1 = (bits >> 18) & 63"
    let "s2 = (bits >> 12) & 63"
    let "s3 = (bits >> 6) & 63"
    let "s4 = bits & 63"

    base64+="${ALPHABET:s1:1}${ALPHABET:s2:1}"

    remaining=$((len - i))
    if ((remaining == 1)); then
        base64+="=="
    elif ((remaining == 2)); then
        base64+="${ALPHABET:s3:1}="
    else
        base64+="${ALPHABET:s3:1}${ALPHABET:s4:1}"
    fi
done

printf "%s" "$base64"
