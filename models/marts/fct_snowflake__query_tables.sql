{{ config(materialized='view') }}

select
    query_id
  , table_sk
  , max(start_at) as query_start_at
  , count_if(access_type = 'direct') > 0 as is_direct_access
  , count_if(access_type = 'base') > 0 as is_base_access

from {{ ref('stg_snowflake__query_tables') }}
group by 1, 2
