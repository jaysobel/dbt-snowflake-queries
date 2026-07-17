{{ config(materialized='view') }}

select
    table_sk
  , database_name
  , schema_name
  , table_name
  , table_type
  , owner_name
  , owner_role_type
  , is_transient
  , is_iceberg
  , is_dynamic
  , is_hybrid
  , is_auto_clustering_on
  , clustering_key
  , row_count
  , storage_bytes
  , storage_megabytes
  , retention_days
  , created_at
  , last_altered_at
  , last_ddl_at
  , last_ddl_by
  , comment

from {{ ref('stg_snowflake__tables') }}
