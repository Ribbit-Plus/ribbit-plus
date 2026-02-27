# Getting Started with Ribbit

## Prerequisites

- An amateur radio license (for transmitting)
- A VHF/UHF Handy Talkie (HT) or any FM radio
- A smartphone (Android or iOS)

## Installation

### From Source (Rattlegram)

```bash
# Clone the main application
git clone https://github.com/Ribbit-Plus/rattlegram.git
cd rattlegram

# The project uses Android NDK / Xcode for building
# See the rattlegram repository for platform-specific build instructions
```

### Dependencies

Rattlegram depends on two core libraries that are included as submodules:

```bash
# Clone with submodules
git clone --recursive https://github.com/Ribbit-Plus/rattlegram.git
```

Or initialize submodules after cloning:

```bash
git submodule update --init --recursive
```

## How to Use

1. **Open the Rattlegram app** on your smartphone
2. **Type your message** (up to 170 bytes of UTF-8 text)
3. **Hold your phone near the radio's microphone**
4. **Key up the radio** (PTT) and tap Send
5. The message is transmitted as an audio burst (~1 second)

### Receiving

1. **Tune your radio** to the agreed-upon frequency
2. **Open the Rattlegram app** with the phone near the radio speaker
3. Messages are automatically decoded and displayed

## Live Demo

Try the web-based demo at [badkangaroo.github.io](http://badkangaroo.github.io) to see how Ribbit encodes and decodes messages using your browser's audio.

## Building the DSP / Code Libraries

If you want to work with the underlying libraries:

```bash
# Clone the DSP library
git clone https://github.com/Ribbit-Plus/dsp.git

# Clone the coding library
git clone https://github.com/Ribbit-Plus/code.git

# Clone the modem
git clone https://github.com/Ribbit-Plus/modem.git

# Build examples
git clone https://github.com/Ribbit-Plus/examples.git
cd examples
make
```

## Next Steps

- Read the [Architecture Overview](architecture.md) to understand the system design
- Watch the [introductory videos](../README.md#learn-more) for visual explanations
- Join the [developer mailing list](http://lists.openresearch.institute/listinfo.cgi/Ribbit-Developers-openresearch.institute) to contribute
