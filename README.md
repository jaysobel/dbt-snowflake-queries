## Snowflake Usage Data

Snowflake's [Query History](https://docs.snowflake.com/en/sql-reference/functions/query_history.html) and [Access History](https://docs.snowflake.com/en/sql-reference/account-usage/access_history.html) views (available to Enterprise accounts) provide detailed query-granular usage information. This information is useful to Analytics Engineers working in large dbt repositories with limited visibility into downstream usage. It's also useful to Data Observability start-ups developing point-and-click interfaces into data you already own.

The `query_history` provides query timing and context details, while `access_history` provides JSON blobs of each query's accessed `tables` (or views)* and the specific columns referenced from those tables. Queries include DDL and DML commands; there are over 30 `query_type` values.

This partial dbt repo unifies `query_history` and `access_history` to present a data model of queries, tables, and columns. In all cases, usage of the word "tables" includes views.

* `stg_snowflake_queries`
* `stg_snowflake_query_tables`
* `stg_snowflake_query_table_columns`
* `stg_snowflake_tables` (includes views)
* `stg_snowflake_table_columns`

## Steps to Use

1. In all models, uncomment and complete `database` and `schema` name filter lists (or delete them). It assumed that not all databases and schemas in your instance are of-interest.
2. In `stg_snowflake_queries` fill-in the definition of `is_tooling_user` (tools can add noise to usage). Or add your own fields!

## Column-level Lineage

In theory, these models can be used to derive column-level lineage within a dbt project. By filtering to DDL/DML commands issued by dbt users toward production schemas and further unpacking the `access_history.objects_modified` array, one could determine the tables and columns relevant to building each model.

## Disclaimer

I have not attempted to run this code since the last modifications were made.


#### Footnotes
\* In all cases, usage of the word "tables" includes views. 
