//
//  File.swift
//  
//
//  Created by Daniel Jilg on 25.11.22.
//

import DataTransferObjects
import XCTest

class RetentionQueryTests: XCTestCase {
    let retentionQueryExampleString = """
    {
      "queryType": "groupBy",
      "dataSource": "telemetry-signals",
      "granularity": "all",
      "dimensions": [],
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
      "aggregations": [
        {
          "type": "filtered",
          "filter": {
            "type": "interval",
            "dimension": "__time",
            "intervals": ["2022-08-01/2022-09-01"]
          },
          "aggregator": {
            "type": "thetaSketch",
            "name": "_august_clientUser_count",
            "fieldName": "clientUser"
          }
        },
        {
          "type": "filtered",
          "filter": {
            "type": "interval",
            "dimension": "__time",
            "intervals": ["2022-09-01/2022-10-01"]
          },
          "aggregator": {
            "type": "thetaSketch",
            "name": "_september_clientUser_count",
            "fieldName": "clientUser"
          }
        },
        {
          "type": "filtered",
          "filter": {
            "type": "interval",
            "dimension": "__time",
            "intervals": ["2022-10-01/2022-11-01"]
          },
          "aggregator": {
            "type": "thetaSketch",
            "name": "_october_clientUser_count",
            "fieldName": "clientUser"
          }
        },
        {
          "type": "filtered",
          "filter": {
            "type": "interval",
            "dimension": "__time",
            "intervals": ["2022-11-01/2022-12-01"]
          },
          "aggregator": {
            "type": "thetaSketch",
            "name": "_november_clientUser_count",
            "fieldName": "clientUser"
          }
        }
      ],
      "postAggregations": [
        {
          "type": "thetaSketchEstimate",
          "name": "september_retention",
          "field": {
            "type": "thetaSketchSetOp",
            "func": "INTERSECT",
            "fields": [
              {
                "type": "fieldAccess",
                "fieldName": "_august_clientUser_count"
              },
              {
                "type": "fieldAccess",
                "fieldName": "_september_clientUser_count"
              }
            ]
          }
        },
        {
          "type": "thetaSketchEstimate",
          "name": "october_retention",
          "field": {
            "type": "thetaSketchSetOp",
            "func": "INTERSECT",
            "fields": [
              {
                "type": "fieldAccess",
                "fieldName": "_august_clientUser_count"
              },
              {
                "type": "fieldAccess",
                "fieldName": "_october_clientUser_count"
              }
            ]
          }
        },
        {
          "type": "thetaSketchEstimate",
          "name": "november_retention",
          "field": {
            "type": "thetaSketchSetOp",
            "func": "INTERSECT",
            "fields": [
              {
                "type": "fieldAccess",
                "fieldName": "_august_clientUser_count"
              },
              {
                "type": "fieldAccess",
                "fieldName": "_november_clientUser_count"
              }
            ]
          }
        }
      ]
    }
    """
    
    func testSaving() throws {
        let decodedQuery = try JSONDecoder.telemetryDecoder.decode(CustomQuery.self, from: retentionQueryExampleString.data(using: .utf8)!)
    }
    

    
}
