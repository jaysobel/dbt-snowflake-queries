{{ config(materialized='view') }}

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

from {{ ref('stg_snowflake__query_table_columns') }}
group by 1, 2, 3
