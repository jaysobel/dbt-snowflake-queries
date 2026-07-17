with failures as (

  select 'query table count' as check_name
  where (select count(*) from {{ ref('fct_snowflake__query_tables') }}) <> 3

  union all

  select 'query column count'
  where (select count(*) from {{ ref('fct_snowflake__query_table_columns') }}) <> 4

  union all

  select 'direct and base collapse'
  where not coalesce((
    select is_direct_access and is_base_access
    from {{ ref('fct_snowflake__query_tables') }}
    where query_id = 'q1' and table_sk = 'prod.analytics.orders'
  ), false)

  union all

  select 'direct view access'
  where not coalesce((
    select is_direct_access and not is_base_access
    from {{ ref('fct_snowflake__query_tables') }}
    where query_id = 'q2' and table_sk = 'prod.analytics.order_summary'
  ), false)

  union all

  select 'base table access'
  where not coalesce((
    select is_base_access and not is_direct_access
    from {{ ref('fct_snowflake__query_tables') }}
    where query_id = 'q2' and table_sk = 'prod.raw.orders'
  ), false)

)

select * from failures
