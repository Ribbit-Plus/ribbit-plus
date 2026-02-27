import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let callsign: String
    let timestamp: Date
    let direction: Direction
    let signalStrength: Double
    let frequency: String

    enum Direction: String, Codable {
        case incoming
        case outgoing
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var byteCount: Int {
        text.utf8.count
    }

    static let maxBytes = 170

    static var preview: Message {
        Message(
            id: UUID(),
            text: "CQ CQ CQ de HB9BLA 🐸",
            callsign: "HB9BLA",
            timestamp: Date(),
            direction: .incoming,
            signalStrength: 0.85,
            frequency: "145.500 MHz"
        )
    }

    static var previewMessages: [Message] {
        [
            Message(id: UUID(), text: "CQ CQ CQ de HB9BLA 🐸", callsign: "HB9BLA",
                    timestamp: Date().addingTimeInterval(-300), direction: .incoming,
                    signalStrength: 0.85, frequency: "145.500 MHz"),
            Message(id: UUID(), text: "HB9BLA de DL1ABC, hello from Munich!", callsign: "DL1ABC",
                    timestamp: Date().addingTimeInterval(-240), direction: .outgoing,
                    signalStrength: 0.92, frequency: "145.500 MHz"),
            Message(id: UUID(), text: "DL1ABC de HB9BLA, great signal! 73", callsign: "HB9BLA",
                    timestamp: Date().addingTimeInterval(-180), direction: .incoming,
                    signalStrength: 0.78, frequency: "145.500 MHz"),
            Message(id: UUID(), text: "Emergency: Need assistance at grid JN47", callsign: "OE5ABC",
                    timestamp: Date().addingTimeInterval(-60), direction: .incoming,
                    signalStrength: 0.45, frequency: "145.500 MHz"),
            Message(id: UUID(), text: "Net check-in: DL1ABC QRV on 145.500", callsign: "DL1ABC",
                    timestamp: Date(), direction: .outgoing,
                    signalStrength: 0.95, frequency: "145.500 MHz"),
        ]
    }
}
