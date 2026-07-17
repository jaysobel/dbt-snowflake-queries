{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['query_id', 'table_column_sk'],
    on_schema_change='sync_all_columns'
  )
}}

with access_history as (

  select *
  from {{ source('snowflake_account_usage', 'access_history') }}
  where query_start_time >= dateadd('day', -{{ var('access_history_lookback_days', 365) }}, current_timestamp)

  {% if is_incremental() %}
    and convert_timezone('UTC', query_start_time)::timestamp_ntz >= (
      select dateadd(
        'day',
        -{{ var('incremental_lookback_days', 3) }},
        coalesce(max(start_at), '1970-01-01'::timestamp_ntz)
      )
      from {{ this }}
    )
  {% endif %}

)

, object_access as (

  select
      query_id::text as query_id
    , convert_timezone('UTC', query_start_time)::timestamp_ntz as start_at
    , lower(user_name)::text as user_name
    , 'direct'::text as access_type
    , objects.value as object_accessed
  from access_history
  , lateral flatten(direct_objects_accessed) as objects

  union all

  select
      query_id::text as query_id
    , convert_timezone('UTC', query_start_time)::timestamp_ntz as start_at
    , lower(user_name)::text as user_name
    , 'base'::text as access_type
    , objects.value as object_accessed
  from access_history
  , lateral flatten(base_objects_accessed) as objects

)

, column_access as (

  select
      query_id
    , start_at
    , user_name
    , access_type
    , object_accessed:objectId::number as table_id
    , columns.value:columnId::number as column_id
    , lower(object_accessed:objectDomain::text) as object_domain
    , lower(object_accessed:objectName::text) as table_sk
    , lower(split_part(object_accessed:objectName::text, '.', 1)) as database_name
    , lower(split_part(object_accessed:objectName::text, '.', 2)) as schema_name
    , lower(split_part(object_accessed:objectName::text, '.', 3)) as table_name
    , lower(columns.value:columnName::text) as column_name
    , concat(lower(object_accessed:objectName::text), '.', lower(columns.value:columnName::text)) as table_column_sk
  from object_access
  , lateral flatten(object_accessed:columns) as columns
  where lower(object_accessed:objectDomain::text) in (
    'table', 'view', 'materialized view', 'external table', 'event table', 'dynamic table', 'iceberg table', 'hybrid table'
  )
    and object_accessed:objectName::text is not null
    and columns.value:columnName::text is not null

)

select
    query_id
  , table_column_sk
  , table_sk
  , max(table_id) as table_id
  , max(column_id) as column_id
  , max(database_name) as database_name
  , max(schema_name) as schema_name
  , max(table_name) as table_name
  , max(column_name) as column_name
  , max(object_domain) as object_domain
  , max(start_at) as start_at
  , max(user_name) as user_name
  , count_if(access_type = 'direct') > 0 as is_direct_access
  , count_if(access_type = 'base') > 0 as is_base_access

from column_access
where true
  {{ dbt_snowflake_queries__list_filter(
      'database_name',
      var('included_databases', []),
      var('excluded_databases', [])
  ) }}
  {{ dbt_snowflake_queries__list_filter(
      'schema_name',
      var('included_schemas', []),
      var('excluded_schemas', [])
  ) }}
group by 1, 2, 3
