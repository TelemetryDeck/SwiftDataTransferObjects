//
//  HavingTests.swift
//  DataTransferObjects
//
//  Created by Daniel Jilg on 09.01.25.
//

import DataTransferObjects
import XCTest

class ChartConfigurationTests: XCTestCase {
    func testChartConfiguration() throws {
        let chartConfiguration = ChartConfiguration(
            displayMode: .barChart,
            darkMode: false,
            options: .init(animation: false),
            aggregationConfiguration: .init(stack: "hello")
        )

        let encodedChartConfiguration = """
        {
            "aggregationConfiguration": {
                "stack": "hello"
            },
            "darkMode": false,
            "displayMode": "barChart",
            "options": {
                "animation": false
            }
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(chartConfiguration)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedChartConfiguration)

        let decoded = try JSONDecoder.telemetryDecoder.decode(ChartConfiguration.self, from: encoded)
        XCTAssertEqual(chartConfiguration, decoded)
    }
}
