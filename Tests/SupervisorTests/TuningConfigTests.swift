@testable import DataTransferObjects
import XCTest

final class TuningConfigTests: XCTestCase {
    let tdValueString = """
    {
      "appendableIndexSpec": {
        "preserveExistingMetrics": false,
        "type": "onheap"
      },
      "chatRetries": 8,
      "handoffConditionTimeout": 900000,
      "httpTimeout": "PT10S",
      "indexSpec": {
        "bitmap": {
          "type": "roaring"
        },
        "dimensionCompression": "lz4",
        "longEncoding": "longs",
        "metricCompression": "lz4",
        "stringDictionaryEncoding": {
          "type": "utf8"
        }
      },
      "indexSpecForIntermediatePersists": {
        "bitmap": {
          "type": "roaring"
        },
        "dimensionCompression": "lz4",
        "longEncoding": "longs",
        "metricCompression": "lz4",
        "stringDictionaryEncoding": {
          "type": "utf8"
        }
      },
      "intermediateHandoffPeriod": "P2147483647D",
      "intermediatePersistPeriod": "PT10M",
      "logParseExceptions": false,
      "maxBytesInMemory": 0,
      "maxParseExceptions": 2147483647,
      "maxPendingPersists": 0,
      "maxRowsInMemory": 50000,
      "maxRowsPerSegment": 5000000,
      "maxSavedParseExceptions": 0,
      "numPersistThreads": 1,
      "offsetFetchPeriod": "PT30S",
      "recordBufferFullWait": 5000,
      "recordBufferOfferTimeout": 5000,
      "repartitionTransitionDuration": "PT120S",
      "reportParseExceptions": false,
      "resetOffsetAutomatically": false,
      "shutdownTimeout": "PT80S",
      "skipBytesInMemoryOverheadCheck": false,
      "skipSequenceNumberAvailabilityCheck": false,
      "type": "kinesis",
      "useListShards": true
    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = TuningConfig.kinesis(
        .init(
            skipSequenceNumberAvailabilityCheck: false,
            recordBufferSizeBytes: nil,
            recordBufferOfferTimeout: 5000,
            recordBufferFullWait: 5000,
            fetchThreads: nil,
            maxBytesPerPoll: nil,
            repartitionTransitionDuration: "PT120S",
            useListShards: true,
            maxRowsInMemory: 50000,
            maxBytesInMemory: 0,
            skipBytesInMemoryOverheadCheck: false,
            maxRowsPerSegment: 5000000,
            maxTotalRows: nil,
            intermediateHandoffPeriod: "P2147483647D",
            intermediatePersistPeriod: "PT10M",
            maxPendingPersists: 0,
            indexSpec: .init(
                bitmap: .init(type: .roaring),
                dimensionCompression: .lz4,
                stringDictionaryEncoding: .init(type: .utf8, bucketSize: nil, formatVersion: nil),
                metricCompression: .lz4,
                longEncoding: .longs,
                complexMetricCompression: nil,
                jsonCompression: nil
            ),
            indexSpecForIntermediatePersists: .init(
                bitmap: .init(type: .roaring),
                dimensionCompression: .lz4,
                stringDictionaryEncoding: .init(type: .utf8, bucketSize: nil, formatVersion: nil),
                metricCompression: .lz4,
                longEncoding: .longs,
                complexMetricCompression: nil,
                jsonCompression: nil
            ),
            reportParseExceptions: false,
            handoffConditionTimeout: 900000,
            resetOffsetAutomatically: false,
            workerThreads: nil,
            chatRetries: 8,
            httpTimeout: "PT10S",
            shutdownTimeout: "PT80S",
            offsetFetchPeriod: "PT30S",
            logParseExceptions: false,
            maxParseExceptions: 2147483647,
            maxSavedParseExceptions: 0,
            numPersistThreads: 1,
            appendableIndexSpec: .init(type: "onheap", preserveExistingMetrics: false)
        )
    )

    let testedType = TuningConfig.self

    func testDecodingTelemetryDeckExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: tdValueString.data(using: .utf8)!)
        XCTAssertEqual(tdValue, decodedValue)
    }

    func testEncodingTelemetryDeckExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(tdValue)
        XCTAssertEqual(tdValueString, String(data: encodedValue, encoding: .utf8)!)
    }
}
