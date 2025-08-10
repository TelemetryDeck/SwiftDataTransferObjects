# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftDataTransferObjects is a Swift Package Manager library containing Data Transfer Objects (DTOs) used by the TelemetryDeck Server. The project started out as a way for various projects to share code, but now it is mainly used to develop Swift struct representations of Apache Druid data structures and query generation. Most other code is mostly unused. The main consumer of this library is a Swift Vapor server application that handles telemetry data processing and analytics.

## Development Commands

### Building and Testing
```bash
# Build the project
swift build

# Run all tests
swift test

# Run specific test target
swift test --filter DataTransferObjectsTests
swift test --filter QueryTests
swift test --filter QueryResultTests
swift test --filter QueryGenerationTests
swift test --filter SupervisorTests
swift test --filter DataSchemaTests

# Build in release mode
swift build -c release
```

### Package Management
```bash
# Clean build artifacts
swift package clean

# Update dependencies
swift package update

# Generate Xcode project (optional)
swift package generate-xcodeproj
```

## Architecture Overview

### Core Data Models
- **DTOv1/DTOv2**: Main data transfer objects with versioning
  - `DTOv1`: Legacy models (InsightGroup, LexiconPayloadKey, OrganizationJoinRequest)
  - `DTOv2`: Current models (Organization, User, App, Insight, Badge, etc.)
- **Models.swift**: Additional DTOs for API requests, authentication, and UI state

### Query System
- **CustomQuery**: Main query builder for Apache Druid integration
  - Supports multiple query types: timeseries, groupBy, topN, scan, timeBoundary, funnel, experiment
  - Handles filters, aggregations, post-aggregations, and time intervals
- **Query Components**:
  - `Aggregator`: Define aggregation functions (sum, count, etc.)
  - `Filter`: Query filtering logic
  - `DimensionSpec`: Dimension specifications for grouping
  - `QueryGranularity`: Time granularity (day, week, month)
  - `VirtualColumn`: Computed columns

### Druid Integration
- **Druid/**: Complete Apache Druid configuration DTOs
  - `configuration/`: Tuning configs, compaction configs
  - `data/input/`: Input formats, sources, and dimension specs
  - `indexing/`: Parallel indexing, batch processing
  - `ingestion/`: Native batch ingestion specs
  - `segment/`: Data schema and transformation specs
  - `Supervisor/`: Kafka streaming supervision

### Chart Configuration
- **ChartConfiguration**: Display settings for analytics charts
- **ChartDefinitionDTO**: Chart metadata and configuration
- **InsightDisplayMode**: Chart types (lineChart, barChart, pieChart, etc.)

### Query Results
- **QueryResult**: Polymorphic result handling for different query types
- **TimeSeriesQueryResult**: Time-based query results
- **TopNQueryResult**: Top-N dimension results
- **GroupByQueryResult**: Grouped aggregation results
- **ScanQueryResult**: Raw data scanning results

## Key Dependencies

- **SwiftDateOperations**: Date manipulation utilities
- **Apple Swift Crypto**: Cryptographic hashing for query stability

## Development Notes

### DTO Versioning
The library uses a versioning strategy with `DTOv1` and `DTOv2` namespaces. `DTOv2.Insight` is deprecated in favor of V3InsightsController patterns.

### Query Hashing
CustomQuery implements stable hashing using SHA256 for caching and query deduplication. The `stableHashValue` property provides consistent query identification.

### Test Structure
Tests are organized by functionality:
- **DataTransferObjectsTests**: Basic DTO serialization/deserialization
- **QueryTests**: Query building and validation
- **QueryResultTests**: Result parsing and handling
- **QueryGenerationTests**: Advanced query generation (funnels, experiments)
- **SupervisorTests**: Druid supervisor configuration
- **DataSchemaTests**: Data ingestion schema validation

### Encoding/Decoding
The library uses custom JSON encoding/decoding with:
- `JSONEncoder.telemetryEncoder`: Consistent date formatting
- Custom wrappers (`StringWrapper`, `DoubleWrapper`) for flexible JSON parsing
- `DoublePlusInfinity`: Handles infinity values in query results
