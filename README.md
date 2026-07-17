# dbt Snowflake Queries

[![CI](https://github.com/jaysobel/dbt-snowflake-queries/actions/workflows/ci.yml/badge.svg)](https://github.com/jaysobel/dbt-snowflake-queries/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Snowflake-specific dbt package for modeling account-wide query activity, recurring workload patterns, and table- and column-level usage.

This is a usage mart, not a lineage parser. It answers questions such as:

- Which queries and parameterized query patterns run most often?
- Which users, roles, warehouses, databases, and schemas generate the workload?
- Which tables, views, and columns are directly or indirectly used?
- Where do execution time, queueing, spilling, retries, failures, and row changes concentrate?
- Which catalog objects appear active, stale, large, or unused?

## Models

The package exposes five public mart models:

| Model | Grain | Purpose |
| --- | --- | --- |
| `fct_snowflake__queries` | Query execution | Curated query context, hashes, timing, status, and workload measures. |
| `fct_snowflake__query_tables` | Query + table/view | Object usage with separate direct- and base-access flags. |
| `fct_snowflake__query_table_columns` | Query + table/view column | Column usage with separate direct- and base-access flags. |
| `dim_snowflake__tables` | Current table/view | Catalog identity, ownership, type, size, and lifecycle context. |
| `dim_snowflake__table_columns` | Current table/view column | Type, nullability, identity, virtual-expression, and documentation context. |

`table_sk` is the lowercased fully qualified `database.schema.table` name. `table_column_sk` appends the lowercased column name. These readable identifiers make the facts and dimensions straightforward to join and inspect.

The public marts use those readable keys instead of Snowflake's numeric table and column IDs. The fan-out facts remain narrow—query and object keys, `query_start_at`, and direct/base flags—while descriptive object attributes live in the dimensions and query-granular attributes live in `fct_snowflake__queries`. Database and schema context are omitted from the query fact because a single query can cross both boundaries.

Those marts are views over five supporting staging models:

| Model | Materialization | Responsibility |
| --- | --- | --- |
| `stg_snowflake__queries` | Incremental | Type, rename, filter, and incrementally capture Query History; attach parent/root query identifiers. |
| `stg_snowflake__query_tables` | Incremental | Flatten and normalize Access History objects while retaining separate direct/base observations. |
| `stg_snowflake__query_table_columns` | Incremental | Flatten and normalize Access History columns while retaining separate direct/base observations. |
| `stg_snowflake__tables` | Table | Type and normalize the current table/view catalog snapshot. |
| `stg_snowflake__table_columns` | Table | Type and normalize the current table/view column snapshot. |

The staging layer is the ingestion boundary: it owns source-specific cleanup, typing, filtering, UTC timestamp normalization, and incremental processing. The mart layer owns the stable analytical grains and direct/base usage semantics. Keeping the public marts as views makes that contract inexpensive to evolve and avoids storing the same data twice.

Snowflake's native `table_id` and `column_id` values remain in staging for source-level debugging, but are not part of the public mart contract.

## Requirements

- Snowflake
- dbt Core 1.10 or newer, or dbt Fusion
- imported privileges on the `SNOWFLAKE` database for the executing role
- Snowflake Enterprise Edition or higher for [`ACCESS_HISTORY`](https://docs.snowflake.com/en/sql-reference/account-usage/access_history)

Snowflake retains these [Account Usage](https://docs.snowflake.com/en/sql-reference/account-usage) histories for 365 days. `QUERY_HISTORY` can lag by up to 45 minutes, `ACCESS_HISTORY` by up to three hours, and table/column metadata by up to 90 minutes.

## Installation

Install the tagged release from Git:

```yaml
packages:
  - git: https://github.com/jaysobel/dbt-snowflake-queries.git
    revision: 1.0.0
```

Then run `dbt deps` and select the package:

```shell
dbt build --select package:dbt_snowflake_queries
```

Package Hub installation will also be available after the package's dbt Hub registration is accepted.

## Configuration

Override package variables in the consuming project's `dbt_project.yml`:

```yaml
vars:
  dbt_snowflake_queries:
    account_usage_database: snowflake
    account_usage_schema: account_usage
    query_history_lookback_days: 365
    access_history_lookback_days: 365
    incremental_lookback_days: 3
    include_query_text: true
    tooling_users: [dbt_prod, tableau_service]
    included_databases: []
    excluded_databases: [scratch]
    included_schemas: []
    excluded_schemas: [information_schema]
```

Empty inclusion lists mean "include everything." Values are compared case-insensitively. Database and schema filters apply to accessed objects and catalog dimensions during staging. They do not filter Query History by its session context because a query can access objects across database and schema boundaries.

The query and access staging models are incremental and reprocess a configurable overlap to capture delayed Account Usage records. Run them with `--full-refresh` when changing inclusion filters or history windows. The five public mart models are views over those persisted staging relations.

### Query text

Raw query text is useful and is included by default, but it can contain literals, personal data, or secrets accidentally embedded in SQL. Set `include_query_text: false` to materialize a stable null `query_text` column while retaining Snowflake's [query hashes](https://docs.snowflake.com/en/user-guide/query-hash) for pattern analysis.

## Direct and base access

Snowflake distinguishes objects explicitly named in a query from underlying base objects needed to execute it. The usage facts collapse both observations to one row per query/object or query/column while preserving:

- `is_direct_access`: the object or column was explicitly accessed;
- `is_base_access`: the object or column was part of the underlying execution footprint.

This avoids treating base access as lineage while retaining both useful definitions of usage.

## Scope and limitations

- Access History does not contain every Query History record; Snowflake decides whether a statement shape produces an access record.
- Failed queries are present in Query History but generally absent from Access History.
- Current dimensions exclude dropped objects, while historical usage facts can reference objects that have since been dropped.
- Access History can truncate very large object arrays using Snowflake sentinel values.
- Readable keys assume conventional fully qualified identifiers. Quoted identifiers containing literal periods can be ambiguous when split into database, schema, table, and column components.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the integration workflow and [CHANGELOG.md](CHANGELOG.md) for release history.
