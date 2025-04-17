# utf8validator

## Description

utf8validator checks whether a given input string is valid UTF-8

## Requirements

- [zig v0.14.0](https://ziglang.org/)

## Intallation

```console
# Clone the repo
$ git clone https://github.com/utox39/utf8validator.git

# cd to the path
$ cd path/to/utf8validator

# Build zigfetch
$ zig build -Doptimize=ReleaseSafe

# Then move it somewhere in your $PATH. Here is an example:
$ mv ./zig-out/utf8validator ~/bin
```

## Usage

### Command-line args

```console
$ utf8validator "some text"

```

### Stdin

```console
$ echo "some text" | utf8validator

```

## Contributing

If you would like to contribute to this project just create a pull request which I will try to review as soon as possible.
