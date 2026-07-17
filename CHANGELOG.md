# Changelog

All notable changes to this project are documented here. The project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-17

### Added

- Five-model Snowflake usage mart covering queries, query-to-table usage, query-to-column usage, tables, and table columns.
- Five supporting staging models for typed source cleanup, incremental history capture, and normalized Access History observations.
- Query and parameterized hashes, current user and role types, parent/root query identifiers, retry and fault timings, and client-generated-query status.
- Current Snowflake table types, type aliases, virtual-column expressions, and column kinds.
- Configurable source locations, history windows, incremental overlap, query-text retention, tooling users, and database/schema filters.
- dbt Core and Fusion compatibility CI plus an isolated Snowflake integration project.

### Changed

- Reframed the original starter code as an installable dbt package for Snowflake usage analytics.
- Replaced opaque hashed relationship keys with readable lowercased fully qualified `table_sk` and `table_column_sk` values.
- Preserved direct and base object access as separate flags at a single analytical grain.
- Moved source typing, filtering, JSON flattening, and incremental processing into staging; public facts and dimensions are now thin views.
- Narrowed the public marts around readable `table_sk` and `table_column_sk` relationships; Snowflake numeric object IDs remain in staging only.
- Removed database/schema context from the query fact and query-granular user attributes from the fan-out facts.
- Scoped database/schema filters to accessed objects and catalog dimensions instead of Query History session context.
- Renamed fan-out timestamps to `query_start_at` and verified they match the query fact's `start_at` for each query.
- Curated Snowflake metadata fields around operational usage rather than mirroring every source column.

### Fixed

- Corrected incremental unique keys that referenced nonexistent columns.
- Replaced invalid recent-data tests on table dimensions.
- Updated generic-test argument syntax for current dbt Core and Fusion.
