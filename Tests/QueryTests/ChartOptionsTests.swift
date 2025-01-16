//
//  HavingTests.swift
//  DataTransferObjects
//
//  Created by Daniel Jilg on 09.01.25.
//

import DataTransferObjects
import XCTest

class ChartOptionsTests: XCTestCase {
    func testAxiOptions() throws {
        let axisOptions = AxisOptions(show: false, position: .bottom, type: .time, name: "testAxis", inverse: false)

        let encodedAxisOptions = """
        {
            "inverse": false,
            "name": "testAxis",
            "position": "bottom",
            "show": false,
            "type": "time"
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(axisOptions)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedAxisOptions)

        let decoded = try JSONDecoder.telemetryDecoder.decode(AxisOptions.self, from: encoded)
        XCTAssertEqual(axisOptions, decoded)
    }

    func testGridConfiguration() throws {
        let gridConfiguration = GridConfiguration(top: 12, bottom: 13, left: 14, right: 15, containLabel: false)

        let encodedGridConfiguration = """
        {
            "bottom": 13,
            "containLabel": false,
            "left": 14,
            "right": 15,
            "top": 12
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(gridConfiguration)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedGridConfiguration)

        let decoded = try JSONDecoder.telemetryDecoder.decode(GridConfiguration.self, from: encoded)
        XCTAssertEqual(gridConfiguration, decoded)
    }

    func testTooltipConfiguration() throws {
        let tooltipConfiguration = ToolTipConfiguration(show: true)

        let encodedTooltipConfiguration = """
        {
            "show": true
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(tooltipConfiguration)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedTooltipConfiguration)

        let decoded = try JSONDecoder.telemetryDecoder.decode(ToolTipConfiguration.self, from: encoded)
        XCTAssertEqual(tooltipConfiguration, decoded)
    }

    func testChartConfigurationOptions() throws {
        let chartConfigurationOptions = ChartConfigurationOptions(
            animation: true,
            animationDuration: 2500,
            animationEasing: .cubicInOut,
            tooltip: .init(show: false),
            grid: .init(top: 12, bottom: 13, left: 14, right: 15, containLabel: true),
            xAxis: .init(show: true, position: .bottom, type: .category, name: "test", inverse: false),
            yAxis: nil
        )

        let encodedChartConfigurationOptions = """
        {
            "animation": true,
            "animationDuration": 2500,
            "animationEasing": "cubicInOut",
            "grid": {
                "bottom": 13,
                "containLabel": true,
                "left": 14,
                "right": 15,
                "top": 12
            },
            "tooltip": {
                "show": false
            },
            "xAxis": {
                "inverse": false,
                "name": "test",
                "position": "bottom",
                "show": true,
                "type": "category"
            }
        }
        """
        .filter { !$0.isWhitespace }

        let encoded = try JSONEncoder.telemetryEncoder.encode(chartConfigurationOptions)
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, encodedChartConfigurationOptions)

        let decoded = try JSONDecoder.telemetryDecoder.decode(ChartConfigurationOptions.self, from: encoded)
        XCTAssertEqual(chartConfigurationOptions, decoded)
    }
}
