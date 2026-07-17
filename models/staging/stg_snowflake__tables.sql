{{ config(materialized='table') }}

with tables as (

  select *
  from {{ source('snowflake_account_usage', 'tables') }}
  where deleted is null

)

select
    lower(concat_ws('.', table_catalog, table_schema, table_name)) as table_sk
  , table_id::number as table_id
  , lower(table_catalog)::text as database_name
  , lower(table_schema)::text as schema_name
  , lower(table_name)::text as table_name
  , case
      when upper(table_type) = 'BASE TABLE' then 'table'
      else lower(table_type)
    end::text as table_type
  , lower(table_owner)::text as owner_name
  , lower(owner_role_type)::text as owner_role_type
  , is_transient = 'YES' as is_transient
  , is_iceberg = 'YES' as is_iceberg
  , is_dynamic = 'YES' as is_dynamic
  , is_hybrid = 'YES' as is_hybrid
  , auto_clustering_on = 'YES' as is_auto_clustering_on
  , clustering_key::text as clustering_key
  , row_count::number as row_count
  , bytes::number as storage_bytes
  , round(bytes / pow(1024, 2), 2) as storage_megabytes
  , retention_time::integer as retention_days
  , convert_timezone('UTC', created)::timestamp_ntz as created_at
  , convert_timezone('UTC', last_altered)::timestamp_ntz as last_altered_at
  , convert_timezone('UTC', last_ddl)::timestamp_ntz as last_ddl_at
  , lower(last_ddl_by)::text as last_ddl_by
  , comment::text as comment

from tables
where true
  {{ dbt_snowflake_queries__list_filter(
      'table_catalog',
      var('included_databases', []),
      var('excluded_databases', [])
  ) }}
  {{ dbt_snowflake_queries__list_filter(
      'table_schema',
      var('included_schemas', []),
      var('excluded_schemas', [])
  ) }}
