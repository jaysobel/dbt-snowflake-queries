## Snowflake Usage Data

This repo provides a handful of models operating over Snowflake's [Query History](https://docs.snowflake.com/en/sql-reference/functions/query_history.html), [Access History](https://docs.snowflake.com/en/sql-reference/account-usage/access_history.html) views (available to Enterprise accounts). These views provide detailed query-granular usage data about your Snowflake instance.

The `query_history` view provides query timing and context details, while `access_history` provides JSON blobs of each query's accessed `tables` (or views)* and the specific columns referenced from those tables. The set of queries includes DDL and DML commands; there are over 30 `query_type` values.

This partial dbt repo produces a staging layer of models at and around the query grain, derived from the schema `snowflake.account_usage`.

* `stg_snowflake_queries`
* `stg_snowflake_query_tables`
* `stg_snowflake_query_table_columns`
* `stg_snowflake_tables` (includes views)
* `stg_snowflake_table_columns`

## Setup Steps

1. Copy-paste the contents of `/models/sources/snowflake/*` into a similar directory in your own Snowflake-based dbt project. Also grab the three generic tests from `/tests/generic/*.sql`.
2. In each model, uncomment and complete `database` and `schema` name filter lists (or delete them). The query dataset can be large, and some of the databases and schemas in your Snowflake instance may not be of-interest.
3. In `stg_snowflake_queries` fill-in the definition of `is_tooling_user`, or substitute your own means of filtering out noisy automated queries, like those run by Data Observability or Cataloging tools.

## Column-level Lineage

In theory, these models can be used to derive column-level lineage within a dbt project. By filtering to DDL/DML commands issued by dbt users toward production schemas and further unpacking the `access_history.objects_modified` array, one could determine the tables and columns relevant to building each model.

## Notes, Disclaimers, Considerations

This code has been minimally run/tested.

The `access_history` view can contain a small number of duplicate rows. These are tolerated, as de-duping can be prohibitively expensive during a full-refresh.

The `query_history` and access_history` have a truncated lookback of 365 days. If data beyond that range seems valuable, it may be worth maintaining an incremental base model with full refresh disabled and a simple selection of the native columns.

Querying the `information_schema` for tables and columns provides "real-time" results within a database, but it can be slow. The `snowflake.account_usage` schema has a latency of up to 90 minutes, but tends to be more performant, and includes results across databases.

#### Footnotes
\* In all cases, usage of the word "tables" includes views. 
