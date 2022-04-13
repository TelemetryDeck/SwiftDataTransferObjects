//
//  File.swift
//
//
//  Created by Daniel Jilg on 12.05.21.
//

import Foundation

public extension DTOv1 {
    struct LexiconSignalDTO: Codable, Hashable, Identifiable {
        public init(type: String, signalCount: Int, userCount: Int, sessionCount: Int) {
            self.type = type
            self.signalCount = signalCount
            self.userCount = userCount
            self.sessionCount = sessionCount
        }

        public var id: String { type }
        public var type: String
        public var signalCount: Int
        public var userCount: Int
        public var sessionCount: Int
    }
}
