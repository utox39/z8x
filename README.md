# z8x

## Description

z8x checks if a given input string is valid UTF-8 and finds [Tags (Unicode block)](https://en.wikipedia.org/wiki/Tags_(Unicode_block))
to prevent [ASCII Smuggling](https://embracethered.com/blog/posts/2024/hiding-and-finding-text-with-unicode-tags/).

## Requirements

- [zig v0.14.0](https://ziglang.org/)

## Intallation

```console
# Clone the repo
$ git clone https://github.com/utox39/z8x.git

# cd to the path
$ cd path/to/z8x

# Build zigfetch
$ zig build -Doptimize=ReleaseSafe

# Then move it somewhere in your $PATH. Here is an example:
$ mv ./zig-out/z8x ~/bin
```

## Usage

### Command-line args

```console
$ z8x "some text"

```

### Stdin

```console
$ echo "some text" | z8x

```

## Contributing

If you would like to contribute to this project just create a pull request which I will try to review as soon as possible.
