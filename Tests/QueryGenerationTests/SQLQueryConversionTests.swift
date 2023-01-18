//
//  SQLQueryConversionTests.swift
//
//
//  Created by Daniel Jilg on 21.12.22.
//

import DataTransferObjects
import XCTest

final class SQLQueryConversionTests: XCTestCase {
    let sqlQuery = """
    SELECT majorSystemVersion, SUM("count") "Count" FROM "telemetry-signals" GROUP BY 1 ORDER BY 2 ASC
    """

    let planJSON = """
    [
      {
        "PLAN": "[{\\\"query\\\":{\\\"queryType\\\":\\\"groupBy\\\",\\\"dataSource\\\":{\\\"type\\\":\\\"table\\\",\\\"name\\\":\\\"telemetry-signals\\\"},\\\"intervals\\\":{\\\"type\\\":\\\"intervals\\\",\\\"intervals\\\":[\\\"-146136543-09-08T08:23:32.096Z/146140482-04-24T15:36:27.903Z\\\"]},\\\"granularity\\\":{\\\"type\\\":\\\"all\\\"},\\\"dimensions\\\":[{\\\"type\\\":\\\"default\\\",\\\"dimension\\\":\\\"majorSystemVersion\\\",\\\"outputName\\\":\\\"d0\\\",\\\"outputType\\\":\\\"STRING\\\"}],\\\"aggregations\\\":[{\\\"type\\\":\\\"longSum\\\",\\\"name\\\":\\\"a0\\\",\\\"fieldName\\\":\\\"count\\\"}],\\\"limitSpec\\\":{\\\"type\\\":\\\"default\\\",\\\"columns\\\":[{\\\"dimension\\\":\\\"a0\\\",\\\"direction\\\":\\\"ascending\\\",\\\"dimensionOrder\\\":{\\\"type\\\":\\\"numeric\\\"}}]},\\\"context\\\":{\\\"sqlQueryId\\\":\\\"5c233022-b521-4e6b-b390-ca161188f17e\\\"}},\\\"signature\\\":[{\\\"name\\\":\\\"d0\\\",\\\"type\\\":\\\"STRING\\\"},{\\\"name\\\":\\\"a0\\\",\\\"type\\\":\\\"LONG\\\"}]}]",
        "RESOURCES": "[{\\\"name\\\":\\\"telemetry-signals\\\",\\\"type\\\":\\\"DATASOURCE\\\"}]"
      }
    ]
    """
        .data(using: .utf8)!

    func testEncodingConversionRequest() throws {
        let input = SQLQueryConversionRequest(query: sqlQuery)
        let expectedOutput = "{\"query\":\"SELECT majorSystemVersion, SUM(\\\"count\\\") \\\"Count\\\" FROM \\\"telemetry-signals\\\" GROUP BY 1 ORDER BY 2 ASC\"}"
        let output = try JSONEncoder.telemetryEncoder.encode(input)
        let outputString = String(data: output, encoding: .utf8)

        XCTAssertEqual(expectedOutput, outputString)
    }

    func testDecodingConversionResponse() throws {
        let expectedOutput = [SQLQueryConversionResponseItem(plan: "[{\"query\":{\"queryType\":\"groupBy\",\"dataSource\":{\"type\":\"table\",\"name\":\"telemetry-signals\"},\"intervals\":{\"type\":\"intervals\",\"intervals\":[\"-146136543-09-08T08:23:32.096Z/146140482-04-24T15:36:27.903Z\"]},\"granularity\":{\"type\":\"all\"},\"dimensions\":[{\"type\":\"default\",\"dimension\":\"majorSystemVersion\",\"outputName\":\"d0\",\"outputType\":\"STRING\"}],\"aggregations\":[{\"type\":\"longSum\",\"name\":\"a0\",\"fieldName\":\"count\"}],\"limitSpec\":{\"type\":\"default\",\"columns\":[{\"dimension\":\"a0\",\"direction\":\"ascending\",\"dimensionOrder\":{\"type\":\"numeric\"}}]},\"context\":{\"sqlQueryId\":\"5c233022-b521-4e6b-b390-ca161188f17e\"}},\"signature\":[{\"name\":\"d0\",\"type\":\"STRING\"},{\"name\":\"a0\",\"type\":\"LONG\"}]}]")]

        let output = try JSONDecoder.telemetryDecoder.decode([SQLQueryConversionResponseItem].self, from: planJSON)

        XCTAssertEqual(expectedOutput, output)
        XCTAssertEqual(output.count, 1)
    }

    func testSQLQueryConversionResponseItemGetPlan() throws {
        let responseItems = try JSONDecoder.telemetryDecoder.decode([SQLQueryConversionResponseItem].self, from: planJSON)
        let responseItem = responseItems.first!

        _ = try responseItem.getQuery()
    }
}
