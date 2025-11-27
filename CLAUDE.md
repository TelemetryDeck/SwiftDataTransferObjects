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

### Query System (`Query/`)
- **CustomQuery**: Main query builder for Apache Druid integration
  - Query types: `timeseries`, `groupBy`, `topN`, `scan`, `timeBoundary`, `funnel`, `experiment`, `retention`
  - Handles filters, aggregations, post-aggregations, and time intervals
- **Query Components**:
  - `Aggregator`: Aggregation functions (sum, count, etc.)
  - `Filter`: Query filtering logic
  - `DimensionSpec`: Dimension specifications for grouping
  - `QueryGranularity`: Time granularity (day, week, month)
  - `VirtualColumn`: Computed columns
  - `PostAggregator`: Post-aggregation calculations
  - `Datasource`: Data source configuration

### Query Generation (`QueryGeneration/`)
- **CustomQuery+Funnel**: Funnel analysis query generation
- **CustomQuery+Experiment**: A/B experiment queries
- **CustomQuery+Retention**: Retention analysis queries
- **Precompilable**: Query precompilation protocol
- **SQLQueryConversion**: SQL conversion utilities

### Query Results (`QueryResult/`)
- **QueryResult**: Polymorphic enum for different result types
- **TimeSeriesQueryResult**: Time-based query results
- **TopNQueryResult**: Top-N dimension results
- **GroupByQueryResult**: Grouped aggregation results
- **ScanQueryResult**: Raw data scanning results
- **TimeBoundaryResult**: Time boundary query results
- Helper types: `StringWrapper`, `DoubleWrapper`, `DoublePlusInfinity`

### Druid Configuration (`Druid/`)
- `configuration/`: TuningConfig, AutoCompactionConfig
- `data/input/`: Input formats and dimension specs
- `indexer/`: Granularity specs
- `indexing/`: Kinesis streaming, parallel batch indexing
- `ingestion/`: Task specs, native batch, ingestion specs
- `segment/`: Data schema and transform specs

### Supervisor (`Supervisor/`)
- Kafka/Kinesis streaming supervision DTOs

### Chart Configuration (`Chart Configuration/`)
- **ChartConfiguration**: Display settings for analytics charts
- **ChartAggregationConfiguration**: Aggregation configuration
- **ChartConfigurationOptions**: Chart options

## Key Dependencies

- **SwiftDateOperations**: Date manipulation utilities
- **Apple Swift Crypto**: Cryptographic hashing for query stability

## Development Notes

### Query Hashing
CustomQuery implements stable hashing using SHA256 for caching and query deduplication. The `stableHashValue` property provides consistent query identification.

### Test Structure
Tests are organized by functionality:
- **DataTransferObjectsTests**: Basic DTO serialization/deserialization
- **QueryTests**: Query building and validation
- **QueryResultTests**: Result parsing and handling
- **QueryGenerationTests**: Advanced query generation (funnels, experiments, retention)
- **SupervisorTests**: Druid supervisor configuration
- **DataSchemaTests**: Data ingestion schema validation

### Encoding/Decoding
The library uses custom JSON encoding/decoding with:
- `JSONEncoder.telemetryEncoder`: Consistent date formatting
- Custom wrappers (`StringWrapper`, `DoubleWrapper`) for flexible JSON parsing
- `DoublePlusInfinity`: Handles infinity values in query results
