//
//  File.swift
//
//
//  Created by Daniel Jilg on 14.05.21.
//

import Foundation
public extension DTOv1 {
    struct RegistrationRequestBody: Codable {
        public init() {}

        public var registrationToken: String = ""
        public var organisationName: String = ""
        public var userFirstName: String = ""
        public var userLastName: String = ""
        public var userEmail: String = ""
        public var userPassword: String = ""
        public var userPasswordConfirm: String = ""
        public var receiveMarketingEmails: Bool = false
        public var countryCode: String? = ""
        public var referralCode: String?
        public var source: String?

        public var isValid: ValidationState {
            if organisationName.isEmpty || userFirstName.isEmpty || userEmail.isEmpty || userPassword.isEmpty {
                return .fieldsMissing
            }

            if userPassword != userPasswordConfirm {
                return .passwordsNotEqual
            }

            if userPassword.count < 8 {
                return .passwordTooShort
            }

            if userPassword.contains(":") {
                return .passwordContainsColon
            }

            if !userEmail.contains("@") {
                return .noAtInEmail
            }

            return .valid
        }
    }

    enum ValidationState {
        case valid
        case fieldsMissing
        case passwordsNotEqual
        case passwordTooShort
        case passwordContainsColon
        case noAtInEmail
    }
}
