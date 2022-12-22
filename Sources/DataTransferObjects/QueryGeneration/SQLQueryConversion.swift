import Foundation

/// A request, sent to `DRUID-URL/druid/v2/sql` to generate a Druid query from the supplied SQL query.
public struct SQLQueryConversionRequest: Codable {
    public init(query: String) {
        self.query = query
    }
    
    public let query: String
}

public struct SQLQueryConversionResponseItem: Codable, Equatable {
    struct PlanContainerItem: Codable, Equatable {
        let query: CustomQuery
    }

    public init(plan: String) {
        self.PLAN = plan
    }
    
    public let PLAN: String
    
    public func getQuery() throws -> CustomQuery {
        guard let planData = PLAN.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [],
                debugDescription: "Could not convert PLAN to data",
                underlyingError: nil
            ))
        }
        
        let planItems = try JSONDecoder.telemetryDecoder.decode([PlanContainerItem].self, from:planData )
        
        guard let firstPlanItem = planItems.first else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [],
                debugDescription: "PLAN did not contain at least one item",
                underlyingError: nil
            ))
        }
        
        var query = firstPlanItem.query
        
        query.dataSource = DataSource.init("telemetry-signals")
        query.context = nil
        query.intervals = nil
        
        return query
    }
}
