Here is the bare markdown version (no extra explanations, just the content):

```markdown
# base64.sh

A pure Bash Base64 encoder **and decoder** implementation – no external tools required.

## Included Scripts

- `base64_encode.sh` – Encode strings or data to Base64  
- `base64_decode.sh` – Decode Base64 strings back to original content

## Usage

### Encoding

```bash
# Encode a string directly
./base64_encode.sh "Hello World"

# Or pipe input
echo -n "Hello World" | ./base64_encode.sh
```

### Decoding

```bash
# Decode a Base64 string
./base64_decode.sh "SGVsbG8gV29ybGQ="

# Or pipe Base64 input
echo "SGVsbG8gV29ybGQ=" | ./base64_decode.sh

# With newline / multiline input
echo -e "SGVsbG8gV29ybGQ=\nZm9vYmFy" | ./base64_decode.sh
```

## Examples

### Encoding

```bash
$ ./base64_encode.sh "foo"
Zm9v

$ ./base64_encode.sh "foobar"
Zm9vYmFy

$ echo -n "The quick brown fox" | ./base64_encode.sh
VGhlIHF1aWNrIGJyb3duIGZveA==
```

### Decoding

```bash
$ ./base64_decode.sh "Zm9v"
foo

$ ./base64_decode.sh "Zm9vYmFy"
foobar

$ echo "VGhlIHF1aWNrIGJyb3duIGZveA==" | ./base64_decode.sh
The quick brown fox

$ ./base64_decode.sh "SGVsbG8gV29ybGQ="
Hello World
```

## Testing

Run the test suite (covers both encode and decode):

```bash
./test_base64_encode.sh
./test_base64_decode.sh
```

Stop on first failure:

```bash
./test_base64_encode.sh -x
./test_base64_decode.sh -x
```

## Formatting

Format all scripts consistently:

```bash
./format-sh.sh <file>
```

## Features

- Pure Bash (no `base64`, `openssl`, `xxd`, etc.)
- Supports standard Base64 alphabet
- Handles padding (`=`) correctly
- Works with binary data (when piped)
- Decent performance for small-to-medium inputs
- Very small code footprint

## License

[MIT](LICENSE) ([TL;DR](https://tldrlegal.com/license/mit-license))

---

*Tests and README were vibecoded.  
The encoder, decoder and formatting script are handmade and formatted with the included formatting script.*
```
