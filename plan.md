# Ribbit Ökosystem – Roadmap & Fehlende Komponenten

## Überblick

Das Ribbit-Ökosystem bietet einen soliden Signal-Processing-Stack für digitale Textnachrichten über Audio/Funk. Diese Roadmap identifiziert fehlende Komponenten für ein vollständiges Ökosystem.

## IST-Zustand

| Schicht | Repos | Status |
|---------|-------|--------|
| **DSP/Signalverarbeitung** | `dsp`, `code` | ✅ Solide C++ Bibliotheken |
| **Modem** | `modem` | ✅ OFDM Modem (CLI encode/decode) |
| **App** | `rattlegram` | ✅ Android-App (nur Android!) |
| **Bildübertragung** | `ofdmtv`, `shredpix`, `assempix` | ✅ COFDMTV |
| **FEC** | `crs`, `cpf`, `ira`, `tables` | ✅ Diverse FEC-Implementierungen |
| **Simulation/Test** | `disorders`, `rir` | ✅ Kanalstörungssimulation |
| **Sonstiges** | `examples`, `markdown`, `turtle`, `smr` | ✅ Beispiele & Tools |

## Fehlende Komponenten

### Phase 1 – Fundament

| # | Komponente | Priorität | Beschreibung |
|---|-----------|-----------|-------------|
| 1 | [Protokoll-Spezifikation](docs/protocol-spec.md) | 🔴 HOCH | Formale Dokumentation des Ribbit-Protokolls. Aktuell nur implizit im C++ Code. |
| 2 | Nachrichten-Protokoll-Layer | 🔴 HOCH | ACK/NACK, Fragmentierung (>170 Bytes), Nachrichtentypen, Adressierung |
| 3 | Networking/Routing-Schicht | 🔴 HOCH | Mesh-Networking, Multi-Hop, Store-and-Forward (aktuell nur Single-Hop) |

### Phase 2 – Plattformen

| # | Komponente | Priorität | Beschreibung |
|---|-----------|-----------|-------------|
| 4 | iOS App (`rattlegram-ios`) | 🟡 MITTEL | Rattlegram existiert nur für Android. Swift/ObjC-Wrapper + iOS Audio. |
| 5 | Desktop-App | 🟡 MITTEL | GUI für Linux/macOS/Windows. CLI-Modem existiert, aber keine UI. |
| 6 | Web-App (WASM) | 🟡 MITTEL | Vollwertige Web-App. Demo existiert, aber nicht vollwertig. |
| 7 | Cross-Platform Bindings | 🟡 MITTEL | Python, JS/WASM, Swift, Rust Bindings für C++ Libraries |

### Phase 3 – Netzwerk

| # | Komponente | Priorität | Beschreibung |
|---|-----------|-----------|-------------|
| 8 | Internet-Gateway | 🟡 MITTEL | Gateway RF ↔ Internet (wie APRS-IS) |
| 9 | Digipeater/Relay | 🟡 MITTEL | Store-and-Forward, automatischer Relay-Betrieb |

### Phase 4 – Erweiterungen

| # | Komponente | Priorität | Beschreibung |
|---|-----------|-----------|-------------|
| 10 | Positionsberichterstattung | 🔵 NIEDRIG | GPS/APRS-ähnliche Beacons für Notfall/SAR |
| 11 | HF-Optimierung | 🔵 NIEDRIG | HF-Modem-Modus (Fading, Multipath, schmale Bandbreite) |
| 12 | CI/CD & Tests | 🔵 NIEDRIG | Automatisierte Tests, Regressionstests, Benchmarks |
| 13 | Digitale Signaturen | 🔵 NIEDRIG | Authentifizierung ohne Verschlüsselung (Amateurfunk-konform) |

## Abhängigkeiten

```
Protokoll-Spezifikation
├── Nachrichten-Protokoll-Layer
│   ├── Networking/Routing
│   │   ├── Digipeater/Relay
│   │   └── Internet-Gateway
│   └── Positionsberichterstattung
├── iOS App
├── Desktop-App
└── HF-Optimierung

Cross-Platform Bindings
└── Web-App (WASM)
```

## Nächster Schritt

→ [Protokoll-Spezifikation](docs/protocol-spec.md) – Reverse-Engineering und Dokumentation des bestehenden Protokolls aus dem C++ Quellcode.
