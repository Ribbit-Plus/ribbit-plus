import Foundation
import SwiftUI

@MainActor
class MessageStore: ObservableObject {
    @Published var messages: [Message] = []
    @Published var callsign: String = ""
    @Published var frequency: String = "145.500 MHz"

    private let storageKey = "ribbit_messages"
    private let callsignKey = "ribbit_callsign"

    init() {
        loadMessages()
        callsign = UserDefaults.standard.string(forKey: callsignKey) ?? ""
    }

    func addMessage(_ message: Message) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            messages.insert(message, at: 0)
        }
        saveMessages()
    }

    func sendMessage(text: String) -> Message {
        let message = Message(
            id: UUID(),
            text: text,
            callsign: callsign.isEmpty ? "N0CALL" : callsign,
            timestamp: Date(),
            direction: .outgoing,
            signalStrength: 1.0,
            frequency: frequency
        )
        addMessage(message)
        return message
    }

    func clearMessages() {
        withAnimation {
            messages.removeAll()
        }
        saveMessages()
    }

    func setCallsign(_ newCallsign: String) {
        callsign = newCallsign.uppercased()
        UserDefaults.standard.set(callsign, forKey: callsignKey)
    }

    private func loadMessages() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Message].self, from: data) else {
            messages = Message.previewMessages
            return
        }
        messages = decoded
    }

    private func saveMessages() {
        if let data = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
