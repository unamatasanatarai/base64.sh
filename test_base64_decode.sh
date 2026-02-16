#!/usr/bin/env bash

# Robust test framework for base64_decode.sh
# Features:
#   - Pass/Fail display
#   - Summary report
#   - Stop-on-first-fail flag (-x, --stop-on-fail)

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DECODER="$SCRIPT_DIR/base64_decode.sh"

STOP_ON_FAIL=0

TOTAL=0
PASSED=0
FAILED=0

# ─────────────────────────────────────────────────────────────
# Parse arguments
# ─────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
    -x | --stop-on-fail)
        STOP_ON_FAIL=1
        shift
        ;;
    -h | --help)
        echo "Usage: ${0##*/} [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -x, --stop-on-fail  Stop on first test failure"
        echo "  -h, --help          Show this help message"
        exit 0
        ;;
    *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
done

# ─────────────────────────────────────────────────────────────
# Test function
# ─────────────────────────────────────────────────────────────

test_decode() {
    local input="$1"
    local expected="$2"
    local description="${3:-}"

    ((TOTAL++)) || true

    local result
    result=$("$DECODER" "$input" 2>&1) || true

    local display_input="$input"
    [[ ${#display_input} -gt 30 ]] && display_input="${display_input:0:27}..."

    if [[ "$result" == "$expected" ]]; then
        ((PASSED++)) || true
        printf "✓ PASS Test %d: %s\n" "$TOTAL" "$description"
    else
        ((FAILED++)) || true
        printf "✗ FAIL Test %d: %s\n" "$TOTAL" "$description"
        printf "     Input:    <%s>\n" "$display_input"
        printf "     Expected: <%s>\n" "$expected"
        printf "     Got:      <%s>\n" "$result"

        if [[ $STOP_ON_FAIL -eq 1 ]]; then
            printf "\nStopped on first failure (-x flag)\n"
            print_summary
            exit 1
        fi
    fi
}

# Compare against system base64 decoder
test_vs_system() {
    local raw="$1"
    local description="${2:-$raw}"

    local encoded
    encoded=$(printf "%s" "$raw" | base64 -w 0)

    test_decode "$encoded" "$raw" "$description"
}

# ─────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────

print_summary() {
    local pct=0
    [[ $TOTAL -gt 0 ]] && pct=$((PASSED * 100 / TOTAL))

    printf "\n=======================================\n"
    printf "SUMMARY: %d/%d tests passed (%d%%)\n" "$PASSED" "$TOTAL" "$pct"
    if [[ $FAILED -gt 0 ]]; then
        printf "         %d tests failed\n" "$FAILED"
    fi
    printf "=======================================\n"
}

# ─────────────────────────────────────────────────────────────
# Test Cases
# ─────────────────────────────────────────────────────────────

printf "=== Base64 Decoder Tests ===\n\n"

# RFC 4648 test vectors
printf "── RFC 4648 Test Vectors ──\n"
test_decode "Zg==" "f" "Single char 'f'"
test_decode "Zm8=" "fo" "Two chars 'fo'"
test_decode "Zm9v" "foo" "Three chars 'foo'"
test_decode "Zm9vYg==" "foob" "Four chars 'foob'"
test_decode "Zm9vYmE=" "fooba" "Five chars 'fooba'"
test_decode "Zm9vYmFy" "foobar" "Six chars 'foobar'"

# Single characters
printf "\n── Single Characters ──\n"
test_vs_system "A" "uppercase A"
test_vs_system "a" "lowercase a"
test_vs_system "Z" "uppercase Z"
test_vs_system "z" "lowercase z"
test_vs_system "0" "digit 0"
test_vs_system "9" "digit 9"

# Length variations
printf "\n── Length Variations ──\n"
test_vs_system "AB"
test_vs_system "ABC"
test_vs_system "ABCD"
test_vs_system "ABCDE"
test_vs_system "ABCDEF"
test_vs_system "ABCDEFG"
test_vs_system "ABCDEFGH"
test_vs_system "ABCDEFGHI"

# Special characters
printf "\n── Special Characters ──\n"
test_vs_system " "
test_vs_system "  "
test_vs_system "Hello World"
test_vs_system $'Hello\tWorld'
test_vs_system "!@#\$%^&*()"
test_vs_system "foo=bar"
test_vs_system "a+b"
test_vs_system "path/to/file"

# Mixed content
printf "\n── Mixed Content ──\n"
test_vs_system "abc123XYZ"
test_vs_system "The quick brown fox"
test_vs_system "user@example.com"
test_vs_system "https://example.com"

# Long strings
printf "\n── Long Strings ──\n"
test_vs_system "$(printf 'A%.0s' {1..50})" "50 A's"
test_vs_system "$(printf 'AB%.0s' {1..50})" "100 chars (AB x 50)"
test_vs_system "The quick brown fox jumps over the lazy dog"

# Binary-like characters
printf "\n── Binary-like Content ──\n"
test_vs_system $'\x01'
test_vs_system $'\x7F'
test_vs_system $'\xFF'
# Note: Bash cannot store null bytes (\x00)

# ─────────────────────────────────────────────────────────────
# Summary and exit
# ─────────────────────────────────────────────────────────────

print_summary

[[ $FAILED -eq 0 ]] && exit 0 || exit 1
