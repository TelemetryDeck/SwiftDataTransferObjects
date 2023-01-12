import Foundation

public enum FunnelQueryGenerator {
    public enum FunnelQueryGeneratorErrors: Error {
        // case errors here
    }
    
    public static func generateFunnelQuery(steps: [Filter], filter: Filter?, appID: String, testMode: Bool) throws -> CustomQuery {

        
        // Combine query 
        return CustomQuery(
            queryType: .groupBy,
            dataSource: "telemetry-signals",
            filter: .and(.init(fields: [
                .selector(.init(dimension: "appID", value: appID)),
                .selector(.init(dimension: "isTestMode", value: testMode ? "true": "false"))
            ])),
            granularity: .all
        )
    }
    
}
