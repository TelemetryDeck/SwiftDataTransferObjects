@testable import DataTransferObjects
import XCTest

final class VirtualColumnTests: XCTestCase {
    let tdValueString = """
    {
      "aggregations": [
        { "fieldName": "clientUser", "name": "count", "type": "thetaSketch" }
      ],
      "dimension": {
        "dimension": "calculatedSystemVersion",
        "outputName": "fooPage",
        "type": "default"
      },
      "granularity": "all",
      "metric": { "metric": "count", "type": "numeric" },
      "queryType": "topN",
      "threshold": 10,
       "virtualColumns": [
        {
          "expression": "nvl(majorMinorSystemVersion,concat('TelemetryDeck.Device.operatingSystem+'-'+nvl(OSVersion,'unknown')))",
          "name": "calculatedSystemVersion",
          "outputType": "STRING",
          "type": "expression"
        }
      ]
    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = CustomQuery(
        queryType: .topN,
        virtualColumns: [
            .expression(
                .init(
                    name: "calculatedSystemVersion",
                    expression: "nvl(majorMinorSystemVersion,concat('TelemetryDeck.Device.operatingSystem+'-'+nvl(OSVersion,'unknown')))",
                    outputType: "STRING"
                )
            )
        ],
        granularity: .all,
        aggregations: [
            .thetaSketch(.init(name: "count", fieldName: "clientUser"))
        ],
        threshold: 10,
        metric: .numeric(.init(metric: "count")),
        dimension: .default(.init(dimension: "calculatedSystemVersion", outputName: "fooPage"))
    )

    let testedType = CustomQuery.self

    func testDecodingDocsExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: tdValueString.data(using: .utf8)!)
        XCTAssertEqual(tdValue, decodedValue)
    }

    func testEncodingDocsExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(tdValue)
        XCTAssertEqual(tdValueString, String(data: encodedValue, encoding: .utf8)!)
    }
}

final class ExpressionVirtualColumnTests: XCTestCase {
    let docsValueString = """
    {
      "expression": "<rowexpression>",
      "name": "<nameofthevirtualcolumn>",
      "outputType": "FLOAT",
      "type": "expression"
    }
    """
    .filter { !$0.isWhitespace }

    let docsValue = VirtualColumn.expression(
        ExpressionVirtualColumn(name: "<nameofthevirtualcolumn>", expression: "<rowexpression>", outputType: "FLOAT")
    )

    let testedType = VirtualColumn.self

    func testDecodingDocsExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: docsValueString.data(using: .utf8)!)
        XCTAssertEqual(docsValue, decodedValue)
    }

    func testEncodingDocsExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(docsValue)
        XCTAssertEqual(docsValueString, String(data: encodedValue, encoding: .utf8)!)
    }
}

final class ListFilteredVirtualColumnTests: XCTestCase {
    let docsValueString = """
    {
      "delegate": "dim3",
      "isAllowList": true,
      "name": "filteredDim3",
      "type": "mv-filtered",
      "values": ["hello", "world"]
    }
    """
    .filter { !$0.isWhitespace }

    let docsValue = VirtualColumn.listFiltered(
        .init(
            name: "filteredDim3",
            delegate: "dim3",
            values: ["hello", "world"],
            isAllowList: true
        )
    )

    let testedType = VirtualColumn.self

    func testDecodingDocsExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: docsValueString.data(using: .utf8)!)
        XCTAssertEqual(docsValue, decodedValue)
    }

    func testEncodingDocsExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(docsValue)
        XCTAssertEqual(docsValueString, String(data: encodedValue, encoding: .utf8)!)
    }
}
