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

        XCTAssertEqual(
            decodedAggregators,
            [
                .thetaSketchEstimate(.init(
                    name: "app_launched_and_data_entered_count",
                    field: .thetaSketchSetOp(.init(
                        name: "app_launched_and_data_entered_count",
                        func: .intersect,
                        fields: [
                            .fieldAccess(.init(type: .fieldAccess, fieldName: "appLaunchedByNotification_count")),
                            .fieldAccess(.init(type: .fieldAccess, fieldName: "dataEntered_count"))
                        ]
                    ))
                ))
            ]
        )
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
                .expression(.init(name: "part_percentage", expression: "100*(part/tot)"))
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
                name: "average",
                function: .division,
                fields: [
                    .fieldAccess(.init(type: .fieldAccess, name: "tot", fieldName: "tot")),
                    .fieldAccess(.init(type: .fieldAccess, name: "rows", fieldName: "rows"))
                ]
            ))
        ])
    }

    func testHyperUniqueDecoding() throws {
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

    func testZScore2SampleCodable() throws {
        let example = """
        [{
            "name": "zscore",
            "sample1Size": {
              "fieldName": "_cohort_0",
              "type": "finalizingFieldAccess"
            },
            "sample2Size": {
              "fieldName": "_cohort_1",
              "type": "finalizingFieldAccess"
            },
            "successCount1": {
              "fieldName": "_cohort_0_success_0",
              "type": "finalizingFieldAccess"
            },
            "successCount2": {
              "fieldName": "_cohort_1_success_0",
              "type": "finalizingFieldAccess"
            },
            "type": "zscore2sample"
          }]
        """
        .filter { !$0.isWhitespace }
        
        
        let postAggregators = [
            PostAggregator.zscore2sample(.init(
                name: "zscore",
                sample1Size: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "_cohort_0"
                )),
                successCount1: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "_cohort_0_success_0"
                )),
                sample2Size: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "_cohort_1"
                )),
                successCount2: .finalizingFieldAccess(.init(
                    type: .finalizingFieldAccess,
                    fieldName: "_cohort_1_success_0"
                ))
            ))
        ]

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([PostAggregator].self, from: example.data(using: .utf8)!)
        XCTAssertEqual(decodedAggregators, postAggregators)
        
        let encodedAggregators = try JSONEncoder.telemetryEncoder.encode(postAggregators)
        XCTAssertEqual(String(data: encodedAggregators, encoding: .utf8), example)
    }
    
    func testPValueCodable() throws {
        let example = """
        [{
            "name": "pvalue",
            "type": "pvalue2tailedZtest",
            "zScore": {
              "fieldName": "zscore",
              "type": "fieldAccess"
            }
          }]
        """
        .filter { !$0.isWhitespace }
        
        let postAggregators = [
            PostAggregator.pvalue2tailedZtest(.init(
                name: "pvalue",
                zScore: .fieldAccess(.init(type: .fieldAccess, fieldName: "zscore"))
            ))
        ]

        let decodedAggregators = try JSONDecoder.telemetryDecoder.decode([PostAggregator].self, from: example.data(using: .utf8)!)
        XCTAssertEqual(decodedAggregators, postAggregators)
        
        let encodedAggregators = try JSONEncoder.telemetryEncoder.encode(postAggregators)
        XCTAssertEqual(String(data: encodedAggregators, encoding: .utf8), example)
    }
}
