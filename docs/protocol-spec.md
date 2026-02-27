# Ribbit Protocol Specification

> **Version:** 0.1 (Draft)
> **Status:** Reverse-engineered from C++ source code ([aicodix/rattlegram](https://github.com/aicodix/rattlegram))
> **Date:** 2026-02-27

## 1. Überblick

Ribbit ist ein digitales Text-Nachrichtenprotokoll für die Übertragung von UTF-8 Nachrichten über Audio-Kanäle (VHF/UHF FM, akustische Kopplung). Es verwendet OFDM (Orthogonal Frequency-Division Multiplexing) mit Polar-Code FEC und differentielle QPSK-Modulation.

### 1.1 Designziele

- Bis zu 170 Bytes UTF-8-Text pro Übertragung in ~1 Sekunde
- Keine zusätzliche Hardware – Smartphone-Lautsprecher/Mikrofon ↔ Handfunkgerät
- Robuste Synchronisation und Fehlerkorrektur
- Niedrige PAPR (Peak-to-Average Power Ratio) für FM-Übertragung

### 1.2 Systemparameter

| Parameter | Wert |
|-----------|------|
| Unterstützte Abtastraten | 8000, 16000, 32000, 44100, 48000 Hz |
| Standard-Trägerfrequenz | 2000 Hz (konfigurierbar) |
| Modulation | Differentielle QPSK (4-PSK) |
| FEC | CA-SCL Polar Code (Code-Ordnung 11, Länge 2048) |
| CRC (Preamble) | CRC-16 (Polynom 0xA8F4) |
| CRC (Payload) | CRC-32 (Polynom 0x8F6E37A0) |
| Max. Payload | 170 Bytes (1360 Bits) |

## 2. Frame-Struktur

Eine vollständige Ribbit-Übertragung besteht aus folgenden Symbolen in dieser Reihenfolge:

```
┌──────────────┬─────────────┬───────────┬─────────────────────────────────┬──────────────┐
│ Rausch-      │ Schmidl-Cox │ Preamble  │ Payload-Symbole (4 Symbole)     │ Fancy Header │
│ Symbole (opt)│ Korrelation │ (Header)  │ (nur wenn operation_mode > 0)   │ (optional)   │
└──────────────┴─────────────┴───────────┴─────────────────────────────────┴──────────────┘
```

### 2.1 Symbol-Parameter

Die Symbol-Länge skaliert mit der Abtastrate:

| Abtastrate | `symbol_length` | `guard_length` | `extended_length` |
|------------|-----------------|----------------|-------------------|
| 8000 Hz | 1280 | 160 | 1440 |
| 16000 Hz | 2560 | 320 | 2880 |
| 32000 Hz | 5120 | 640 | 5760 |
| 44100 Hz | 7056 | 882 | 7938 |
| 48000 Hz | 7680 | 960 | 8640 |

**Berechnung:**
```
symbol_length = (1280 × sample_rate) / 8000
guard_length = symbol_length / 8
extended_length = symbol_length + guard_length
```

### 2.2 Subcarrier-Layout

| Parameter | Wert |
|-----------|------|
| Payload-Carriers (`pay_car_cnt`) | 256 |
| Payload-Carrier-Offset (`pay_car_off`) | -128 |
| Korrelations-Sequenz-Länge (`cor_seq_len`) | 127 |
| Korrelations-Sequenz-Offset (`cor_seq_off`) | -126 |
| Preamble-Sequenz-Länge (`pre_seq_len`) | 255 |
| Preamble-Sequenz-Offset (`pre_seq_off`) | -127 |

### 2.3 Guard Interval

Jedes Symbol wird mit einem zyklischen Präfix (Guard Interval) übertragen. Die Länge beträgt `symbol_length / 8`. Am Übergang zwischen Symbolen wird eine Raised-Cosine-Fensterfunktion angewendet.

## 3. Synchronisation (Schmidl-Cox)

Das erste Symbol dient der Zeit- und Frequenzsynchronisation nach dem Schmidl-Cox-Algorithmus.

### 3.1 Korrelationssequenz

- Erzeugt durch eine **Maximum Length Sequence (MLS)** mit Polynom `0b10001001` (Länge 127)
- Nur gerade Subcarrier belegt (jeder zweite), ungerade sind Null
- Differentielle Kodierung: `freq[2i] *= freq[2(i-1)]`
- Skalierungsfaktor: `sqrt(2 × symbol_length / cor_seq_len)`

### 3.2 Frequenz- und Zeitsynchronisation

Der Empfänger verwendet:
1. **Autokorrelation** des halben Symbols für grobe Zeitsynchronisation
2. **Schmitt-Trigger** mit Schwellenwerten 0.17 und 0.19 × `match_len`
3. **CFO-Schätzung** (Carrier Frequency Offset) aus der Phase der Autokorrelation
4. **Theil-Sen-Estimator** für robuste Phasenschätzung über die Subcarrier

## 4. Preamble (Header)

Die Preamble enthält Metadaten über die Übertragung.

### 4.1 Metadaten-Format

Die Metadaten sind als 64-Bit-Wert (`meta_data`) kodiert:

```
Bit 0-7:   operation_mode (8 Bit)
Bit 8-62:  callsign_base37 (55 Bit)
```

**Zusammenbau:** `meta_data = (base37(call_sign) << 8) | operation_mode`

### 4.2 Callsign-Kodierung (Base37)

Callsigns werden in Base37 kodiert:

| Zeichen | Wert |
|---------|------|
| (Leerzeichen/Null) | 0 |
| `0` – `9` | 1 – 10 |
| `A` – `Z` (case-insensitive) | 11 – 36 |

- Maximale Callsign-Länge: 9 Zeichen
- Gültigkeitsbereich: `0 < base37_value < 129961739795077`
- Kodierung: `acc = 37 × acc + char_value` (für jedes Zeichen)

### 4.3 Betriebsmodi (`operation_mode`)

| Modus | Datenbits | Datenbytes | Frozen Bits | Code Rate | Beschreibung |
|-------|-----------|------------|-------------|-----------|-------------|
| 0 | – | – | – | – | **Ping** (nur Preamble, kein Payload) |
| 14 | 1360 | 170 | `frozen_2048_1392` | 1392/2048 ≈ 0.68 | Niedrigste Redundanz, max. Payload |
| 15 | 1024 | 128 | `frozen_2048_1056` | 1056/2048 ≈ 0.52 | Mittlere Redundanz |
| 16 | 680 | 85 | `frozen_2048_712` | 712/2048 ≈ 0.35 | Höchste Redundanz, min. Payload |

**Moduswahl automatisch basierend auf Nachrichtenlänge:**
- `len == 0` → Modus 0 (Ping)
- `len ≤ 85` → Modus 16 (höchste Redundanz)
- `len ≤ 128` → Modus 15 (mittlere Redundanz)
- `len ≤ 170` → Modus 14 (niedrigste Redundanz)

### 4.4 Preamble FEC

Die 71 Bits Metadaten (55 Bit Callsign + 16 Bit CRC-16) werden mit einem **BCH(255,71)** Code geschützt:

- CRC-16 Polynom: `0xA8F4`
- BCH-Encoder: `BoseChaudhuriHocquenghemEncoder<255, 71>`
- Dekodierung: **Ordered Statistics Decoder (OSD)** mit Ordnung 2
- 24 Generatorpolynome (siehe Quellcode)

### 4.5 Preamble-Modulation

1. 71 Datenbits + 184 Paritätsbits = 255 Bits
2. Differentielle BPSK-Modulation: `freq[i] *= freq[i-1]`
3. Verwürfelung mit MLS (Polynom `0b100101011`, Länge 255)
4. Skalierungsfaktor: `sqrt(symbol_length / pre_seq_len)`

## 5. Payload-Symbole

### 5.1 Polar-Code

Der Payload wird mit einem **CA-SCL (CRC-Aided Successive Cancellation List) Polar Code** geschützt:

| Parameter | Wert |
|-----------|------|
| Code-Ordnung | 11 |
| Code-Länge | 2048 Bits |
| CRC-32 Polynom | `0x8F6E37A0` |
| Dekodierung | List-Decoder (SIMD-optimiert) |

**Kodierung:**
1. Nachricht → NRZ-Kodierung (0 → +1, 1 → -1)
2. CRC-32 über Nachricht berechnen und anhängen
3. Systematic Polar Encoding mit frozen bit patterns

### 5.2 Scrambling

Vor der Polar-Kodierung wird die Nachricht mit einem **Xorshift32 PRNG** verwürfelt:

```
Xorshift32 scrambler;
for (i = 0; i < data_bytes; i++)
    payload[i] ^= scrambler();
```

### 5.3 Modulation

- **Differentielle QPSK (4-PSK)** über 256 Subcarrier × 4 Symbole
- Gesamt: 2048 Code-Bits (256 Carrier × 4 Symbole × 2 Bits/Symbol)
- Phase-Referenz aus dem Preamble-Symbol
- Theil-Sen-Estimator für Phasenkompensation

### 5.4 PAPR-Optimierung

Die Zeitdomänen-Signale werden mit einem PAPR-Reduktionsalgorithmus (Tone Reservation / Clipping) optimiert, um die Spitzenfaktoren für FM-Übertragung zu reduzieren.

## 6. Optionale Features

### 6.1 Rausch-Symbole (Noise Symbols)

- Konfigurierbare Anzahl von Rausch-Symbolen vor der eigentlichen Übertragung
- Verwenden 256 Subcarrier mit Pseudo-Rausch (MLS, Polynom `0b100101010001`)
- Zweck: AGC-Settling, Kanalschätzung

### 6.2 Fancy Header

- Optionale visuelle Callsign-Darstellung im Spektrogramm
- 9 Zeichen × 8 Pixel × 11 Zeilen = bis zu 11 zusätzliche Symbole
- Verwendet Base37-Bitmap-Font
- Zeichen werden als Subcarrier im Abstand von 3 Bins platziert

### 6.3 Ping-Modus

- `operation_mode = 0`: Nur Schmidl-Cox + Preamble, kein Payload
- Ermöglicht Präsenz-/Erreichbarkeitstest
- Empfänger meldet `STATUS_PING`

## 7. Empfänger-Status-Codes

| Code | Name | Bedeutung |
|------|------|-----------|
| 0 | `STATUS_OKAY` | Normaler Betrieb |
| 1 | `STATUS_FAIL` | Preamble-Dekodierung fehlgeschlagen |
| 2 | `STATUS_SYNC` | Synchronisation erfolgreich, Payload-Empfang beginnt |
| 3 | `STATUS_DONE` | Alle Payload-Symbole empfangen, Dekodierung starten |
| 4 | `STATUS_HEAP` | Speicherfehler |
| 5 | `STATUS_NOPE` | Ungültiger Modus oder Callsign |
| 6 | `STATUS_PING` | Ping empfangen (kein Payload) |

## 8. Audio-Schnittstelle

### 8.1 PCM-Format

- 16-Bit signed integer (PCM_16BIT)
- Mono oder Stereo
- Kanalauswahl (nur Links, nur Rechts, Mono-Mix, oder Komplex I/Q)

### 8.2 Kanalwahl

| Wert | Beschreibung |
|------|-------------|
| 0 | Mono (Standard) |
| 1 | Stereo, nur linker Kanal |
| 2 | Stereo, nur rechter Kanal |
| 3 | Stereo, Mono-Mix (L+R)/2 |
| 4 | Stereo, Komplex (I=L, Q=R) |

### 8.3 Trägerfrequenz

Der Carrier-Offset wird berechnet als:
```
carrier_offset = (carrier_frequency × symbol_length) / sample_rate
```

Standard: 2000 Hz

## 9. Repeater-Modus

Die Rattlegram-App unterstützt einen einfachen Repeater-Modus:
- Empfangene Nachrichten werden nach konfigurierbarer Verzögerung (`repeaterDelay`) erneut gesendet
- Duplikat-Erkennung über `repeaterDebounce`-Timeout
- Keine Modifikation der Nachricht (Callsign und Payload werden unverändert wiederholt)

## 10. Was dieses Protokoll NICHT definiert

Die folgenden Funktionen sind im aktuellen Protokoll **nicht enthalten** und stellen die Grundlage für zukünftige Erweiterungen dar:

| Feature | Beschreibung |
|---------|-------------|
| **Adressierung** | Keine Empfänger-Adresse – alle Nachrichten sind Broadcast |
| **ACK/NACK** | Keine Empfangsbestätigung |
| **Sequenznummern** | Keine Nachrichten-IDs oder Reihenfolge-Tracking |
| **Fragmentierung** | Keine Aufteilung von Nachrichten >170 Bytes |
| **Nachrichtentypen** | Kein Typ-Feld (alles ist UTF-8 Text) |
| **Routing** | Kein Multi-Hop oder Mesh-Routing |
| **Zeitstempel** | Kein Zeitstempel in der Übertragung |
| **Verschlüsselung** | Keine Verschlüsselung oder Signierung |
| **Kompression** | Keine Datenkompression |
| **QoS** | Keine Quality-of-Service Mechanismen |

## Anhang A: Referenzen

- Schmidl, T.M. & Cox, D.C. (1997): *Robust frequency and timing synchronization for OFDM*
- Minn, H., Zeng, M. & Bhargava, V.K. (2000): *On Timing Offset Estimation for OFDM Systems*
- Arikan, E. (2009): *Channel Polarization: A Method for Constructing Capacity-Achieving Codes for Symmetric Binary-Input Memoryless Channels*
- Tal, I. & Vardy, A. (2015): *List Decoding of Polar Codes*

## Anhang B: Konstanten-Zusammenfassung

```
Korrelationssequenz:
  Polynom:    0b10001001 (Länge 127)
  Offset:     1 - 127 = -126

Preamble-Sequenz:
  Polynom:    0b100101011 (Länge 255)
  Offset:     -127

Rausch-Sequenz:
  Polynom:    0b100101010001

Payload:
  Carrier:    256 (Offset -128)
  Symbole:    4
  Modulation: DQPSK (2 Bits/Symbol/Carrier)
  Codebits:   2048

CRC-16 (Preamble): 0xA8F4
CRC-32 (Payload):  0x8F6E37A0

BCH(255,71) Generator-Polynome:
  0b100011101, 0b101110111, 0b111110011, 0b101101001,
  0b110111101, 0b111100111, 0b100101011, 0b111010111,
  0b000010011, 0b101100101, 0b110001011, 0b101100011,
  0b100011011, 0b100111111, 0b110001101, 0b100101101,
  0b101011111, 0b111111001, 0b111000011, 0b100111001,
  0b110101001, 0b000011111, 0b110000111, 0b110110001

Polar Code Frozen Bit Patterns:
  frozen_2048_712  (Modus 16, 85 Bytes)
  frozen_2048_1056 (Modus 15, 128 Bytes)
  frozen_2048_1392 (Modus 14, 170 Bytes)
```
