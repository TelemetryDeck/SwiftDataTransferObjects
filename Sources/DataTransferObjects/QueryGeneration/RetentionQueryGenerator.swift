//
//  RetentionQueryGenerator.swift
//  
//
//  Created by Daniel Jilg on 28.11.22.
//

import Foundation

struct RetentionQueryGenerator {
    func generateRetentionQuery(appID: UUID, testMode: Bool, beginDate: Date, endDate: Date) -> CustomQuery {
        fatalError()
    }

    func numberOfMonthsBetween(beginDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: beginDate, to: endDate)
        return components.month ?? 0
    }
}
