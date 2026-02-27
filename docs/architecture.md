# Architecture Overview

## System Design

Ribbit is built on a layered architecture that transforms text messages into audio signals
suitable for transmission over amateur radio frequencies.

```
┌─────────────────────────────────────────────┐
│              User Application               │
│         (Rattlegram Android/iOS App)        │
├─────────────────────────────────────────────┤
│            Message Encoding                 │
│    UTF-8 text → FEC encoded payload         │
├─────────────────────────────────────────────┤
│            OFDM Modulation                  │
│    Payload → OFDM symbols → Audio signal    │
├─────────────────────────────────────────────┤
│          Audio Interface                    │
│    Smartphone speaker/mic ↔ Radio PTT       │
├─────────────────────────────────────────────┤
│           RF Transmission                   │
│    VHF/UHF Handy Talkie (any FM radio)      │
└─────────────────────────────────────────────┘
```

## Core Libraries

### DSP Library (`dsp`)
Low-level digital signal processing primitives:
- FFT/IFFT (Fast Fourier Transform)
- Filtering and windowing functions
- Resampling utilities
- Complex number operations

### Code Library (`code`)
Forward Error Correction (FEC) implementations:
- **BCH codes** — Bose–Chaudhuri–Hocquenghem error-correcting codes
- **LDPC codes** — Low-Density Parity-Check codes (including IRA variant)
- **Polar codes** — Capacity-achieving codes
- **Reed-Solomon** — Widely used erasure/error correction
- **Hadamard codes** — For synchronization and detection
- **Galois Field** arithmetic — Underlying math for FEC

### Modem (`modem`)
OFDM modem implementation:
- Orthogonal Frequency-Division Multiplexing
- Pilot tone insertion and channel estimation
- Timing and frequency synchronization
- Configurable bandwidth and symbol parameters

### Rattlegram (`rattlegram`)
The main application that ties everything together:
- Android/iOS smartphone application
- Acoustic coupling to radio (no cable needed)
- Up to 170 bytes per transmission (~1 second)
- Built-in message history and contact management

## Signal Flow

### Transmit Path
1. User types a UTF-8 text message
2. Message is encoded with FEC (error correction)
3. Encoded bits are mapped to OFDM subcarriers
4. IFFT generates the time-domain audio signal
5. Audio is played through the smartphone speaker
6. Radio transmits the audio signal over VHF/UHF

### Receive Path
1. Radio receives the VHF/UHF signal
2. Audio output is picked up by the smartphone microphone
3. FFT extracts OFDM subcarriers
4. Channel estimation corrects for distortion
5. FEC decoder recovers the original bits
6. UTF-8 text message is displayed to the user

## Image Transmission Extensions

The ecosystem also supports image transmission:

- **OFDMTV** — Sends color images with monochrome spectral waterfall display
- **Shredpix** — Sender-side COFDMTV image encoding
- **Assempix** — Receiver-side COFDMTV image decoding

## Testing & Simulation

- **Disorders** — Simulates real-world channel impairments (CFO, SFO, AWGN, multipath)
- **RIR** — Computes Room Impulse Response for acoustic channel simulation
