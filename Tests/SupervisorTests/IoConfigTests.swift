@testable import DataTransferObjects
import XCTest

final class IoConfigTests: XCTestCase {
    let tdValueString = """
    {
      "completionTimeout": "PT7200S",
      "endpoint": "kinesis.eu-central-1.amazonaws.com",
      "idleConfig": {
        "enabled": false
      },
      "inputFormat": {
        "keepNullColumns": false,
        "type": "json"
      },
      "period": "PT30S",
      "replicas": 1,
      "startDelay": "PT5S",
      "stream": "td-ingest-1-KinesisStream-abcdef",
      "taskCount": 1,
      "taskDuration": "PT600S",
      "type": "kinesis",
      "useEarliestSequenceNumber": true
    }
    """
    .filter { !$0.isWhitespace }

    let tdValue = IoConfig.kinesis(
        .init(
            stream: "td-ingest-1-KinesisStream-abcdef",
            inputFormat: .init(type: .json, keepNullColumns: false),
            endpoint: "kinesis.eu-central-1.amazonaws.com",
            taskCount: 1,
            replicas: 1,
            taskDuration: "PT600S",
            startDelay: "PT5S",
            period: "PT30S",
            useEarliestSequenceNumber: true,
            completionTimeout: "PT7200S",
            lateMessageRejectionPeriod: nil,
            earlyMessageRejectionPeriod: nil,
            lateMessageRejectionStartDateTime: nil,
            idleConfig: .init(enabled: false, inactiveAfterMillis: nil),
            stopTaskCount: nil,
            fetchDelayMillis: nil,
            awsAssumedRoleArn: nil,
            awsExternalId: nil
        )
    )

    let testedType = IoConfig.self

    func testDecodingTelemetryDeckExample() throws {
        let decodedValue = try JSONDecoder.telemetryDecoder.decode(testedType, from: tdValueString.data(using: .utf8)!)
        XCTAssertEqual(tdValue, decodedValue)
    }

    func testEncodingTelemetryDeckExample() throws {
        let encodedValue = try JSONEncoder.telemetryEncoder.encode(tdValue)
        XCTAssertEqual(tdValueString, String(data: encodedValue, encoding: .utf8)!)
    }
}
