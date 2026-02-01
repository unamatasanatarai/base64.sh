#!/usr/bin/env bash

# Robust test framework for base64_encode.sh
# Features:
#   - Pass/Fail display
#   - Summary report
#   - Stop-on-first-fail flag (-x, --stop-on-fail)

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENCODER="$SCRIPT_DIR/base64_encode.sh"

STOP_ON_FAIL=0

# Counters
TOTAL=0
PASSED=0
FAILED=0

# ─────────────────────────────────────────────────────────────
# Parse arguments
# ─────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
        -x|--stop-on-fail)
            STOP_ON_FAIL=1
            shift
            ;;
        -h|--help)
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

test_encode() {
    local input="$1"
    local expected="$2"
    local description="${3:-}"

    ((TOTAL++)) || true

    local result
    result=$("$ENCODER" "$input" 2>&1) || true

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

# Compare against system base64
test_vs_system() {
    local input="$1"
    local description="${2:-$input}"
    local expected
    expected=$(printf "%s" "$input" | base64)
    test_encode "$input" "$expected" "$description"
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

printf "=== Base64 Encoder Tests ===\n\n"

# RFC 4648 test vectors
printf "── RFC 4648 Test Vectors ──\n"
test_encode "f"      "Zg=="     "Single char 'f'"
test_encode "fo"     "Zm8="     "Two chars 'fo'"
test_encode "foo"    "Zm9v"     "Three chars 'foo'"
test_encode "foob"   "Zm9vYg==" "Four chars 'foob'"
test_encode "fooba"  "Zm9vYmE=" "Five chars 'fooba'"
test_encode "foobar" "Zm9vYmFy" "Six chars 'foobar'"

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
test_vs_system "AB"     "2 chars"
test_vs_system "ABC"    "3 chars"
test_vs_system "ABCD"   "4 chars"
test_vs_system "ABCDE"  "5 chars"
test_vs_system "ABCDEF" "6 chars"
test_vs_system "ABCDEFG" "7 chars"
test_vs_system "ABCDEFGH" "8 chars"
test_vs_system "ABCDEFGHI" "9 chars"

# Special characters
printf "\n── Special Characters ──\n"
test_vs_system " "        "single space"
test_vs_system "  "       "two spaces"
test_vs_system "Hello World" "string with space"
test_vs_system "Hello\tWorld" "string with tab"
test_vs_system "!@#\$%^&*()" "punctuation marks"
test_vs_system "foo=bar"  "equals sign"
test_vs_system "a+b"      "plus sign"
test_vs_system "path/to/file" "forward slashes"

# Mixed content
printf "\n── Mixed Content ──\n"
test_vs_system "abc123XYZ" "alphanumeric mix"
test_vs_system "The quick brown fox" "sentence"
test_vs_system "user@example.com" "email format"
test_vs_system "https://example.com" "URL format"

# Long strings
printf "\n── Long Strings ──\n"
test_vs_system "$(printf 'A%.0s' {1..50})" "50 A's"
test_vs_system "$(printf 'AB%.0s' {1..50})" "100 chars (AB x 50)"
test_vs_system "The quick brown fox jumps over the lazy dog" "pangram"

# Binary-like characters
printf "\n── Binary-like Content ──\n"
test_vs_system $'\x01'     "SOH char (0x01)"
test_vs_system $'\x7F'     "DEL char (0x7F)"
test_vs_system $'\xFF'     "0xFF byte"
# Note: Bash cannot handle null bytes (\x00) in variables - this is a language limitation

# ─────────────────────────────────────────────────────────────
# Summary and exit
# ─────────────────────────────────────────────────────────────

print_summary

[[ $FAILED -eq 0 ]] && exit 0 || exit 1
