# base64.sh

A pure Bash Base64 encoder implementation.

## Usage

```bash
# Encode a string directly
./base64_encode.sh "Hello World"

# Or pipe input
echo -n "Hello World" | ./base64_encode.sh
```

## Examples

```bash
$ ./base64_encode.sh "foo"
Zm9v

$ ./base64_encode.sh "foobar"
Zm9vYmFy

$ echo -n "The quick brown fox" | ./base64_encode.sh
VGhlIHF1aWNrIGJyb3duIGZveA==
```

## Testing

Run the test suite:

```bash
./test_base64_encode.sh
```

Stop on first failure:

```bash
./test_base64_encode.sh -x
```

## Formatting

Format scripts with the included formatter:

```bash
./format-sh.sh
```

## License

[MIT](LICENSE) ([TL;DR](https://tldrlegal.com/license/mit-license))

---

*Tests and README were vibecoded. The remaining scripts are handmade and formatted with the included formatting script.*
