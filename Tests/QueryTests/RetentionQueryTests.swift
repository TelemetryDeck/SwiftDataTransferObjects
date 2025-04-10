//
//  RetentionQueryTests.swift
//
//
//  Created by Daniel Jilg on 25.11.22.
//

import DataTransferObjects
import XCTest

class RetentionQueryTests: XCTestCase {
    static let aggregations: [Aggregator] = [
        .filtered(.init(
            filter: .interval(.init(
                dimension: "__time",
                intervals: [
                    .init(
                        beginningDate: Date(iso8601String: "2022-08-01T00:00:00.000Z")!,
                        endDate: Date(iso8601String: "2022-09-01T00:00:00.000Z")!
                    ),
                ]
            )),
            aggregator: .thetaSketch(
                .init(
                    name: "_august_clientUser_count",
                    fieldName: "clientUser"
                )
            )
        )),
        .filtered(.init(
            filter: .interval(.init(
                dimension: "__time",
                intervals: [
                    .init(
                        beginningDate: Date(iso8601String: "2022-09-01T00:00:00.000Z")!,
                        endDate: Date(iso8601String: "2022-10-01T00:00:00.000Z")!
                    ),
                ]
            )),
            aggregator: .thetaSketch(
                .init(
                    name: "_september_clientUser_count",
                    fieldName: "clientUser"
                )
            )
        )),
        .filtered(.init(
            filter: .interval(.init(
                dimension: "__time",
                intervals: [
                    .init(
                        beginningDate: Date(iso8601String: "2022-10-01T00:00:00.000Z")!,
                        endDate: Date(iso8601String: "2022-11-01T00:00:00.000Z")!
                    ),
                ]
            )),
            aggregator: .thetaSketch(
                .init(
                    name: "_october_clientUser_count",
                    fieldName: "clientUser"
                )
            )
        )),
        .filtered(.init(
            filter: .interval(.init(
                dimension: "__time",
                intervals: [
                    .init(
                        beginningDate: Date(iso8601String: "2022-11-01T00:00:00.000Z")!,
                        endDate: Date(iso8601String: "2022-12-01T00:00:00.000Z")!
                    ),
                ]
            )),
            aggregator: .thetaSketch(
                .init(
                    name: "_november_clientUser_count",
                    fieldName: "clientUser"
                )
            )
        )),
    ]

    let retentionQueryExample = CustomQuery(
        queryType: .groupBy,
        dataSource: "telemetry-signals",
        filter: .and(.init(fields: [
            .selector(.init(dimension: "appID", value: "79167A27-EBBF-4012-9974-160624E5D07B")),
            .selector(.init(dimension: "isTestMode", value: "false")),
        ])),
        granularity: .all,
        aggregations: aggregations,
        postAggregations: [
            .thetaSketchEstimate(.init(
                name: "september_retention",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_august_clientUser_count"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_september_clientUser_count"
                        )),
                    ]
                ))
            )
            ),

            .thetaSketchEstimate(.init(
                name: "october_retention",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_august_clientUser_count"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_october_clientUser_count"
                        )),
                    ]
                ))
            )
            ),

            .thetaSketchEstimate(.init(
                name: "november_retention",
                field: .thetaSketchSetOp(.init(
                    func: .intersect,
                    fields: [
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_august_clientUser_count"
                        )),
                        .fieldAccess(.init(
                            type: .fieldAccess,
                            fieldName: "_november_clientUser_count"
                        )),
                    ]
                ))
            )
            ),
        ]
    )

    let retentionQueryExampleString = """
    {
      "aggregations": [
        {
          "aggregator": {
            "fieldName": "clientUser",
            "name": "_august_clientUser_count",
            "type": "thetaSketch"
          },
          "filter": {
            "dimension": "__time",
            "intervals": ["2022-08-01T00:00:00.000Z/2022-09-01T00:00:00.000Z"],
            "type": "interval"
          },
          "type": "filtered"
        },
        {
          "aggregator": {
            "fieldName": "clientUser",
            "name": "_september_clientUser_count",
            "type": "thetaSketch"
          },
          "filter": {
            "dimension": "__time",
            "intervals": ["2022-09-01T00:00:00.000Z/2022-10-01T00:00:00.000Z"],
            "type": "interval"
          },
          "type": "filtered"
        },
        {
          "aggregator": {
            "fieldName": "clientUser",
            "name": "_october_clientUser_count",
            "type": "thetaSketch"
          },
          "filter": {
            "dimension": "__time",
            "intervals": ["2022-10-01T00:00:00.000Z/2022-11-01T00:00:00.000Z"],
            "type": "interval"
          },
          "type": "filtered"
        },
        {
          "aggregator": {
            "fieldName": "clientUser",
            "name": "_november_clientUser_count",
            "type": "thetaSketch"
          },
          "filter": {
            "dimension": "__time",
            "intervals": ["2022-11-01T00:00:00.000Z/2022-12-01T00:00:00.000Z"],
            "type": "interval"
          },
          "type": "filtered"
        }
      ],
      "dataSource": "telemetry-signals",
      "filter": {
        "fields": [
          {
            "dimension": "appID",
            "type": "selector",
            "value": "79167A27-EBBF-4012-9974-160624E5D07B"
          },
          {
            "dimension": "isTestMode",
            "type": "selector",
            "value": "false"
          }
        ],
        "type": "and"
      },
      "granularity": "all",
      "postAggregations": [
        {
          "field": {
            "fields": [
              {
                "fieldName": "_august_clientUser_count",
                "type": "fieldAccess"
              },
              {
                "fieldName": "_september_clientUser_count",
                "type": "fieldAccess"
              }
            ],
            "func": "INTERSECT",
            "type": "thetaSketchSetOp"
          },
          "name": "september_retention",
          "type": "thetaSketchEstimate"
        },
        {
          "field": {
            "fields": [
              {
                "fieldName": "_august_clientUser_count",
                "type": "fieldAccess"
              },
              {
                "fieldName": "_october_clientUser_count",
                "type": "fieldAccess"
              }
            ],
            "func": "INTERSECT",
            "type": "thetaSketchSetOp"
          },
          "name": "october_retention",
          "type": "thetaSketchEstimate"
        },        {
          "field": {
            "fields": [
              {
                "fieldName": "_august_clientUser_count",
                "type": "fieldAccess"
              },
              {
                "fieldName": "_november_clientUser_count",
                "type": "fieldAccess"
              }
            ],
            "func": "INTERSECT",
            "type": "thetaSketchSetOp"
          },
          "name": "november_retention",
          "type": "thetaSketchEstimate"
        }
      ],
      "queryType": "groupBy"
    }
    """

    func testDecoding() throws {
        let decodedQuery = try JSONDecoder.telemetryDecoder.decode(CustomQuery.self, from: retentionQueryExampleString.data(using: .utf8)!)
        XCTAssertEqual(decodedQuery, retentionQueryExample)
    }

    func testEncoding() throws {
        let queryData = retentionQueryExampleString
            .filter { !$0.isWhitespace }

        let encodedQuery = try JSONEncoder.telemetryEncoder.encode(retentionQueryExample)
        XCTAssertEqual(String(data: encodedQuery, encoding: .utf8), queryData)
    }
}
