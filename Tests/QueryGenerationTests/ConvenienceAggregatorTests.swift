import DataTransferObjects
import XCTest

final class ConvenienceAggregatorTests: XCTestCase {
    func testUserCountQueryGetsPrecompiled() throws {
        let query = CustomQuery(queryType: .timeseries, aggregations: [.userCount(.init())])
        let precompiled = try query.precompile(organizationAppIDs: [UUID()], isSuperOrg: false)
        let expectedAggregations: [Aggregator] = [.thetaSketch(.init(name: "Users", fieldName: "clientUser"))]
        XCTAssertEqual(precompiled.aggregations, expectedAggregations)
    }

    func testEventCountQueryGetsPrecompiled() throws {
        let query = CustomQuery(queryType: .timeseries, aggregations: [.eventCount(.init())])
        let precompiled = try query.precompile(organizationAppIDs: [UUID()], isSuperOrg: false)
        let expectedAggregations: [Aggregator] = [.longSum(.init(type: .longSum, name: "Events", fieldName: "count"))]
        XCTAssertEqual(precompiled.aggregations, expectedAggregations)
    }

    func testHistogramQueryGetsPrecompiled() throws {
        let query = CustomQuery(queryType: .timeseries, aggregations: [.histogram(.init())])
        let precompiled = try query.precompile(organizationAppIDs: [UUID()], isSuperOrg: false)
        let expectedAggregations: [Aggregator] = [
            .quantilesDoublesSketch(.init(name: "_histogramSketch", fieldName: "floatValue", k: 1024, maxStreamLength: nil, shouldFinalize: nil)),
            .longMin(.init(type: .longMin, name: "_quantilesMinValue", fieldName: "floatValue")),
            .longMax(.init(type: .longMax, name: "_quantilesMaxValue", fieldName: "floatValue")),
        ]
        let expectedPostAggregations: [PostAggregator] = [.quantilesDoublesSketchToHistogram(
            .init(
                name: "Histogram",
                field: .fieldAccess(.init(type: .fieldAccess, name: nil, fieldName: "_histogramSketch")),
                splitPoints: nil,
                numBins: nil
            )
        )]
        XCTAssertEqual(precompiled.aggregations, expectedAggregations)
        XCTAssertEqual(precompiled.postAggregations, expectedPostAggregations)
    }
}
