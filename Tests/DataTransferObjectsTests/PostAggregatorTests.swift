//
//  File.swift
//
//
//  Created by Daniel Jilg on 22.09.22.
//

@testable import DataTransferObjects
import XCTest

final class PostAggregatorTests: XCTestCase {
    func testThetaSketchAggregatorDecoding() throws {
        let examplePostAggregatorThetaSketchEstimate = """
        [
          {
            "type": "thetaSketchEstimate",
            "name": "app_launched_and_data_entered_count",
            "field": {
              "type": "thetaSketchSetOp",
              "name": "app_launched_and_data_entered_count",
              "func": "INTERSECT",
              "fields": [
                {
                  "type": "fieldAccess",
                  "fieldName": "appLaunchedByNotification_count"
                },
                {
                  "type": "fieldAccess",
                  "fieldName": "dataEntered_count"
                }
              ]
            }
          }
        ]
        """
        .filter { !$0.isWhitespace }
        .data(using: .utf8)!

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([PostAggregator].self, from: examplePostAggregatorThetaSketchEstimate)

        XCTAssertEqual(decodedAggregators, [PostAggregator.arithmetic(ArithmetricPostAggregator(name: "part_percentage", function: .multiplication, fields: []))])
    }

    func testPercentageArithmeticDecoding() throws {
        let examplePostAggregatorPercentage = """
        [{
            "type"   : "arithmetic",
            "name"   : "part_percentage",
            "fn"     : "*",
            "fields" : [
               { "type"   : "arithmetic",
                 "name"   : "ratio",
                 "fn"     : "/",
                 "fields" : [
                   { "type" : "fieldAccess", "name" : "part", "fieldName" : "part" },
                   { "type" : "fieldAccess", "name" : "tot", "fieldName" : "tot" }
                 ]
               },
               { "type" : "constant", "name": "const", "value" : 100 }
            ]
          }]
        """
        .filter { !$0.isWhitespace }
        .data(using: .utf8)!

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([PostAggregator].self, from: examplePostAggregatorPercentage)

        XCTAssertEqual(
            decodedAggregators,
            [
                PostAggregator.arithmetic(.init(
                    name: "part_percentage",
                    function: .multiplication,
                    fields: [
                        .arithmetic(.init(
                            name: "ratio",
                            function: .division, fields: [
                                .fieldAccess(.init(type: .fieldAccess, name: "part", fieldName: "part")),
                                .fieldAccess(.init(type: .fieldAccess, name: "tot", fieldName: "tot"))
                            ]
                        )),
                        PostAggregator.constant(.init(name: "const", value: 100))
                    ]
                ))
            ]
        )
    }

    func testPostAggregatorExpressionDecoding() throws {
        let examplePostAggregatorExpression = """
        [{
            "type"       : "expression",
            "name"       : "part_percentage",
            "expression" : "100 * (part / tot)"
          }]
        """
        .filter { !$0.isWhitespace }
        .data(using: .utf8)!

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([PostAggregator].self, from: examplePostAggregatorExpression)

        XCTAssertEqual(
            decodedAggregators,
            [
                PostAggregator.arithmetic(.init(
                    name: "part_percentage",
                    function: .multiplication,
                    fields: [
                        .arithmetic(.init(
                            name: "ratio",
                            function: .division, fields: [
                                .fieldAccess(.init(type: .fieldAccess, name: "part", fieldName: "part")),
                                .fieldAccess(.init(type: .fieldAccess, name: "tot", fieldName: "tot"))
                            ]
                        )),
                        PostAggregator.constant(.init(name: "const", value: 100))
                    ]
                ))
            ]
        )
    }

    func testPostAggregatorArithmeticDecoding() throws {
        let examplePostAggregatorArithmetic = """
        [{
            "type"   : "arithmetic",
            "name"   : "average",
            "fn"     : "/",
            "fields" : [
                   { "type" : "fieldAccess", "name" : "tot", "fieldName" : "tot" },
                   { "type" : "fieldAccess", "name" : "rows", "fieldName" : "rows" }
                 ]
          }]
        """
        .filter { !$0.isWhitespace }
        .data(using: .utf8)!

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([PostAggregator].self, from: examplePostAggregatorArithmetic)

        XCTAssertEqual(decodedAggregators, [
            PostAggregator.arithmetic(.init(
                name: "part_percentage",
                function: .multiplication,
                fields: [
                ]
            ))
        ])
    }

    let exampleHyperUnique = """
    [{
        "type"   : "arithmetic",
        "name"   : "average_users_per_row",
        "fn"     : "/",
        "fields" : [
          { "type" : "hyperUniqueCardinality", "fieldName" : "unique_users" },
          { "type" : "fieldAccess", "name" : "rows", "fieldName" : "rows" }
        ]
      }]
    """
    .filter { !$0.isWhitespace }
    .data(using: .utf8)!

    func testHyperUniqueDecoding() throws {
        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([PostAggregator].self, from: exampleHyperUnique)

        XCTAssertEqual(decodedAggregators, [
            PostAggregator.arithmetic(.init(
                name: "average_users_per_row",
                function: .division,
                fields: [
                    .hyperUniqueCardinality(.init(fieldName: "unique_users")),
                    .fieldAccess(.init(type: .fieldAccess, name: "rows", fieldName: "rows"))
                ]
            ))
        ])
    }
}
