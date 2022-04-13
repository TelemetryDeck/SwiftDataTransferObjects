import Foundation

public extension DTOv1 {
    struct AppAdminEntry: Codable, Identifiable, Equatable {
        public init(id: UUID, appName: String?, organisationName: String?, organisationID: UUID?, signalCount: Int, userCount: Int) {
            self.id = id
            self.appName = appName
            self.organisationName = organisationName
            self.organisationID = organisationID
            self.signalCount = signalCount
            self.userCount = userCount
        }

        public let id: UUID
        public let appName: String?
        public let organisationName: String?
        public let organisationID: UUID?
        public let signalCount: Int
        public let userCount: Int

        func resolvedAppName() -> String {
            guard let appName = appName else { return "–" }

            if appName == "w", organisationName == "XAN Software GmbH & Co. KG" {
                return "DouWatch"
            }

            if appName == "WristW", organisationName == "XAN Software GmbH & Co. KG" {
                return "WristWeb"
            }

            if appName == "ww", organisationName == "XAN Software GmbH & Co. KG" {
                return "WristWeb"
            }

            return appName
        }
    }
}
