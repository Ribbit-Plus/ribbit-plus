# Ribbit-Plus 🐸

> A new digital text messaging mode for HF/VHF/UHF recreational and emergency communications

[![ARRL 2023 Technical Innovation Award Winner](https://img.shields.io/badge/ARRL%202023-Technical%20Innovation%20Award-gold)](https://www.ribbitradio.org)
[![License: 0BSD](https://img.shields.io/badge/License-0BSD-green.svg)](https://opensource.org/licenses/0BSD)

## What is Ribbit?

**Ribbit** is a novel digital text messaging mode for VHF/UHF communications designed for both recreational and emergency use. It radically increases the density of information transmitted per unit of spectrum used.

Ribbit is a project of the [Open Research Institute (ORI)](https://www.openresearch.institute/projects/).

🏆 **Winner of the ARRL 2023 Technical Innovation Award**

## Key Features

### 📡 Digital Messaging
Ribbit enables the transmission of UTF-8 text messages with up to 170 bytes over audio in about a second, using advanced OFDM (Orthogonal Frequency-Division Multiplexing) techniques.

### 📱 No Additional Hardware Required
Ribbit leverages the computing power of the modern smartphone to increase the capabilities of any Handy Talkie (HT) without requiring any additional hardware or cable.

### 🌐 Distributed Design
Its redundant distributed nature allows it to function even when internet connectivity is lost during emergencies — making it ideal for disaster communication scenarios.

### 🔓 Open Source
Ribbit is fully open source, licensed under the BSD Zero Clause License (0BSD), and actively developed by the community.

## Quick Links

| Resource | Link |
|----------|------|
| 🌐 Website | [ribbitradio.org](https://www.ribbitradio.org) |
| 🎮 Live Demo | [badkangaroo.github.io](http://badkangaroo.github.io) |
| 💻 Core App (Rattlegram) | [Ribbit-Plus/rattlegram](https://github.com/Ribbit-Plus/rattlegram) |
| 🏛️ Open Research Institute | [openresearch.institute](https://www.openresearch.institute/projects/) |

## Repository Overview

This organization hosts forks and extensions of the Ribbit ecosystem:

### Core Components

| Repository | Description |
|------------|-------------|
| [rattlegram](https://github.com/Ribbit-Plus/rattlegram) | Transceive UTF-8 text messages (up to 170 bytes) over audio in ~1 second |
| [modem](https://github.com/Ribbit-Plus/modem) | Simple OFDM modem for transceiving datagrams |
| [code](https://github.com/Ribbit-Plus/code) | Reusable C++ coding-related code library (FEC: BCH, LDPC, Polar, Reed-Solomon) |
| [dsp](https://github.com/Ribbit-Plus/dsp) | Reusable C++ DSP code library |

### Image Transmission

| Repository | Description |
|------------|-------------|
| [ofdmtv](https://github.com/Ribbit-Plus/ofdmtv) | Transfer color images using OFDM techniques over audio |
| [shredpix](https://github.com/Ribbit-Plus/shredpix) | Send images over COFDMTV encoded audio |
| [assempix](https://github.com/Ribbit-Plus/assempix) | Receive COFDMTV encoded audio images |

### Forward Error Correction (FEC)

| Repository | Description |
|------------|-------------|
| [crs](https://github.com/Ribbit-Plus/crs) | Cauchy Reed Solomon Erasure Coding |
| [cpf](https://github.com/Ribbit-Plus/cpf) | Cauchy Prime Field Erasure Coding |
| [ira](https://github.com/Ribbit-Plus/ira) | SISO vector decoder for IRA-LDPC codes in VHDL |
| [tables](https://github.com/Ribbit-Plus/tables) | FEC code tables |

### Tools & Utilities

| Repository | Description |
|------------|-------------|
| [disorders](https://github.com/Ribbit-Plus/disorders) | Artificial CFO, SFO, AWGN and multipath propagation simulation |
| [rir](https://github.com/Ribbit-Plus/rir) | Room impulse response computation using pseudo random noise |
| [examples](https://github.com/Ribbit-Plus/examples) | Examples of using the DSP code library |
| [markdown](https://github.com/Ribbit-Plus/markdown) | Markdown web server |
| [smr](https://github.com/Ribbit-Plus/smr) | SMR technology drive management torture test |
| [turtle](https://github.com/Ribbit-Plus/turtle) | Fun with Turtle graphics |

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture Overview](docs/architecture.md) | System design and signal flow |
| [Protocol Specification](docs/protocol-spec.md) | Detailed protocol spec (reverse-engineered from source) |
| [Getting Started](docs/getting-started.md) | Installation and usage guide |
| [Roadmap](plan.md) | Missing ecosystem components and development roadmap |

## Learn More

### Presentations & Talks

- **DEFCON August 2023** — [Poster (PDF)](https://www.ribbitradio.org/Ribbit%20DEFCON%20Algo%20Poster%20Aug%202023.pdf)
- **DEFCON August 2022** — [Poster (PDF)](https://www.ribbitradio.org/RibbitPoster-July2022.pdf)
- **QSOToday September 2022** — [YouTube](https://www.youtube.com/watch?v=_jN4IVccIEw)
- **RATPAC November 2022** — [YouTube](https://www.youtube.com/watch?v=TGzgIjEt9wA)
- **How It Works (with HB9BLA)** — [YouTube](https://www.youtube.com/watch?v=ubPP48ojJ3E)
- **Rattlegram Demo by Ahmet** — [YouTube](https://www.youtube.com/watch?v=0jtzA3alpuw)

## Get Involved

### Stay Informed
- Subscribe to the [Ribbit-Announcements](http://lists.openresearch.institute/listinfo.cgi/Ribbit-Announcements-openresearch.institute) mailing list for major feature releases and app updates.

### User Community
- Join the [Ribbit-Users](http://lists.openresearch.institute/listinfo.cgi/Ribbit-Users-openresearch.institute) discussion mailing list to discuss usage, report success, and help each other.

### Developers
- View the source on [GitHub](https://github.com/Ribbit-Plus/rattlegram)
- Subscribe to the [Ribbit-Developers](http://lists.openresearch.institute/listinfo.cgi/Ribbit-Developers-openresearch.institute) mailing list for code discussions.

## Support

- [Donate](https://www.openresearch.institute/about-open-research-institute/) to support iOS & Ribbit development
- View other [Open Research Institute projects](https://www.openresearch.institute/projects/)

## License

The upstream Ribbit/aicodix projects are licensed under the [BSD Zero Clause License (0BSD)](https://opensource.org/licenses/0BSD).
