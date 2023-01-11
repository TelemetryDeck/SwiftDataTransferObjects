//
//  Models.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 09.08.20.
//

import Foundation

/// Data Transfer Objects
public enum DTOv1 {
    public struct InsightGroup: Codable, Identifiable, Hashable {
        public var id: UUID
        public var title: String
        public var order: Double?
        public var insights: [InsightDTO] = []

        public func getDTO() -> Self {
            Self(id: id, title: title, order: order)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        public init(id: UUID, title: String, order: Double? = nil) {
            self.id = id
            self.title = title
            self.order = order
            insights = []
        }
    }

    public struct LexiconPayloadKey: Codable, Identifiable {
        public init(id: UUID, firstSeenAt: Date, isHidden: Bool, payloadKey: String) {
            self.id = id
            self.firstSeenAt = firstSeenAt
            self.isHidden = isHidden
            self.payloadKey = payloadKey
        }

        public let id: UUID
        public let firstSeenAt: Date

        /// If true, don't include this lexicon item in autocomplete lists
        public let isHidden: Bool
        public let payloadKey: String
    }

    /// Represents a standing invitation to join an organization
    public struct OrganizationJoinRequest: Codable, Identifiable, Equatable {
        public let id: UUID
        public let email: String
        public let registrationToken: String
        public let organization: [String: UUID]
    }
}

@available(*, deprecated, message: "Use DTOv2.App instead")
public struct TelemetryApp: Codable, Hashable, Identifiable {
    public init(id: UUID, name: String, organization: [String: String]) {
        self.id = id
        self.name = name
        self.organization = organization
    }

    public var id: UUID
    public var name: String
    public var organization: [String: String]
}

public struct InsightDefinitionRequestBody: Codable {
    public init(order: Double? = nil, title: String, signalType: String? = nil, uniqueUser: Bool,
                filters: [String: String], rollingWindowSize: TimeInterval, breakdownKey: String? = nil,
                groupBy: QueryGranularity? = nil, displayMode: InsightDisplayMode, groupID: UUID? = nil, id: UUID? = nil, isExpanded: Bool)
    {
        self.order = order
        self.title = title
        self.signalType = signalType
        self.uniqueUser = uniqueUser
        self.filters = filters
        self.rollingWindowSize = rollingWindowSize
        self.breakdownKey = breakdownKey
        self.groupBy = groupBy
        self.displayMode = displayMode
        self.groupID = groupID
        self.id = id
        self.isExpanded = isExpanded
    }

    public var order: Double?
    public var title: String

    /// Which signal types are we interested in? If nil, do not filter by signal type
    public var signalType: String?

    /// If true, only include at the newest signal from each user
    public var uniqueUser: Bool

    /// Only include signals that match all of these key-values in the payload
    public var filters: [String: String]

    /// How far to go back to aggregate signals
    public var rollingWindowSize: TimeInterval

    /// If set, break down the values in this key
    public var breakdownKey: String?

    /// If set, group and count found signals by this time interval. Incompatible with breakdownKey
    public var groupBy: QueryGranularity?

    /// How should this insight's data be displayed?
    public var displayMode: InsightDisplayMode

    /// Which group should the insight belong to? (Only use this in update mode)
    public var groupID: UUID?

    /// The ID of the insight. Not changeable, only set in update mode
    public var id: UUID?

    /// If true, the insight will be displayed bigger
    public var isExpanded: Bool

    public static func from(insight: DTOv1.InsightDTO) -> InsightDefinitionRequestBody {
        let requestBody = Self(
            order: insight.order,
            title: insight.title,
            signalType: insight.signalType,
            uniqueUser: insight.uniqueUser,
            filters: insight.filters,
            rollingWindowSize: insight.rollingWindowSize,
            breakdownKey: insight.breakdownKey,
            groupBy: insight.groupBy ?? .day,
            displayMode: insight.displayMode,
            groupID: insight.group["id"],
            id: insight.id,
            isExpanded: insight.isExpanded
        )

        return requestBody
    }
}

public enum RegistrationStatus: String, Codable {
    case closed
    case tokenOnly
    case open
}

public enum TransferError: Error {
    case transferFailed
    case decodeFailed
    case serverError(message: String)

    public var localizedDescription: String {
        switch self {
        case .transferFailed:
            return "There was a communication error with the server. Please check your internet connection and try again later."
        case .decodeFailed:
            return "The server returned a message that this version of the app could not decode. Please check if there is an update to the app, or contact the developer."
        case let .serverError(message: message):
            return "The server returned this error message: \(message)"
        }
    }
}

public struct ServerErrorDetailMessage: Codable {
    public let detail: String
}

public struct ServerErrorReasonMessage: Codable {
    public let reason: String
}

public struct PasswordChangeRequestBody: Codable {
    public init(oldPassword: String, newPassword: String, newPasswordConfirm: String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
        self.newPasswordConfirm = newPasswordConfirm
    }

    public var oldPassword: String
    public var newPassword: String
    public var newPasswordConfirm: String
}

public struct BetaRequestEmailDTO: Codable, Identifiable, Equatable {
    public let id: UUID
    public let email: String
    public let registrationToken: String
    public let requestedAt: Date
    public let sentAt: Date?
    public let isFulfilled: Bool
}

public struct LoginRequestBody {
    public init(userEmail: String = "", userPassword: String = "") {
        self.userEmail = userEmail
        self.userPassword = userPassword
    }

    public var userEmail: String = ""
    public var userPassword: String = ""

    public var basicHTMLAuthString: String? {
        let loginString = "\(userEmail):\(userPassword)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else { return nil }
        let base64LoginString = loginData.base64EncodedString()
        return "Basic \(base64LoginString)"
    }

    public var isValid: Bool {
        !userEmail.isEmpty && !userPassword.isEmpty
    }
}

public struct RequestPasswordResetRequestBody: Codable {
    public init(email: String = "", code: String = "", newPassword: String = "") {
        self.email = email
        self.code = code
        self.newPassword = newPassword
    }

    public var email: String = ""
    public var code: String = ""
    public var newPassword: String = ""

    public var isValidEmailAddress: Bool {
        !email.isEmpty
    }

    public var isValid: Bool {
        !email.isEmpty && !code.isEmpty && !newPassword.isEmpty
    }
}

public struct UserTokenDTO: Codable {
    public init(id: UUID? = nil, value: String, user: [String: String]) {
        self.id = id
        self.value = value
        self.user = user
    }

    public var id: UUID?
    public var value: String
    public var user: [String: String]

    public var bearerTokenAuthString: String {
        "Bearer \(value)"
    }
}

public struct BetaRequestUpdateBody: Codable {
    public init(sentAt: Date?, isFulfilled: Bool) {
        self.sentAt = sentAt
        self.isFulfilled = isFulfilled
    }

    public let sentAt: Date?
    public let isFulfilled: Bool
}

public struct OrganizationAdminListEntry: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let foundedAt: Date
    public let sumSignals: Int
    public let isSuperOrg: Bool
    public let firstName: String?
    public let lastName: String?
    public let email: String
}

public enum AppRootViewSelection: Hashable {
    case insightGroup(group: DTOv1.InsightGroup)
    case lexicon
    case rawSignals
    case noSelection
}

public enum LoadingState: Equatable {
    case idle
    case loading
    case finished(Date)
    case error(String, Date)
}

public struct QueryTaskStatusStruct: Equatable, Codable {
    public var status: QueryTaskStatus
}

public enum QueryTaskStatus: String, Equatable, Codable {
    public var id: String { rawValue }

    case running
    case successful
    case error
}

public enum RelativeDateDescription: Equatable {
    case end(of: CurrentOrPrevious)
    case beginning(of: CurrentOrPrevious)
    case goBack(days: Int)
    case absolute(date: Date)
}

public enum CurrentOrPrevious: Equatable {
    case current(_ value: Calendar.Component)
    case previous(_ value: Calendar.Component)
}

public enum ReportSendingRate: String, Codable {
    case daily
    case weekly
    case monthly
    case never
}
