//
//  File.swift
//
//
//  Created by Daniel Jilg on 12.05.21.
//

import Foundation

public extension DTOv1 {
    struct IdentifiableSignal: Codable, Hashable, Identifiable {
        public var id = UUID()
        public var appID: UUID?
        public var count: Int
        public var receivedAt: Date
        public var clientUser: String
        public var sessionID: String
        public var type: String
        public var payload: [String: String]?
        public var isTestMode: Bool

        public var signal: Signal {
            Signal(appID: appID, count: count, receivedAt: receivedAt, clientUser: clientUser, sessionID: sessionID, type: type, payload: payload, isTestMode: isTestMode)
        }
    }

    struct Signal: Codable, Hashable {
        public init(appID: UUID? = nil, count: Int? = nil, receivedAt: Date, clientUser: String, sessionID: String? = nil, type: String, payload: [String: String]? = nil, isTestMode: Bool) {
            self.appID = appID
            self.count = count
            self.receivedAt = receivedAt
            self.clientUser = clientUser
            self.sessionID = sessionID
            self.type = type
            self.payload = payload
            self.isTestMode = isTestMode
        }

        public var appID: UUID?
        public var count: Int?
        public var receivedAt: Date
        public var clientUser: String
        public var sessionID: String?
        public var type: String
        public var payload: [String: String]?
        public var isTestMode: Bool

        public func toIdentifiableSignal() -> IdentifiableSignal {
            IdentifiableSignal(id: UUID(), appID: appID, count: count ?? 1, receivedAt: receivedAt, clientUser: clientUser,
                               sessionID: sessionID ?? "–", type: type, payload: payload, isTestMode: isTestMode)
        }
    }

    struct SignalDruidStructure: Codable, Hashable {
        public var appID: UUID?
        public var count: Int?
        public var receivedAt: Date
        public var clientUser: String
        public var sessionID: String?
        public var type: String
        public var payload: String
        public var isTestMode: String

        public func toSignal() -> Signal {
            let payloadJSON = payload.replacingOccurrences(of: "\\", with: "").data(using: .utf8)
            var actualPayload = [String: String]()

            if let payloadJSON = payloadJSON,
               let payloadArray = try? JSONDecoder().decode([String].self, from: payloadJSON)
            {
                for entry in payloadArray {
                    let subsequence = entry.split(separator: ":", maxSplits: 1)
                    if let key = subsequence.first, let value = subsequence.last {
                        actualPayload[String(key)] = String(value)
                    }
                }
            }

            return Signal(appID: appID, count: count, receivedAt: receivedAt, clientUser: clientUser, sessionID: sessionID, type: type, payload: actualPayload, isTestMode: isTestMode == "true")
        }
    }
}
