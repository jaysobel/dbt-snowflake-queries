with failures as (

  select 'query staging count' as check_name
  where (select count(*) from {{ ref('stg_snowflake__queries') }}) <> 3

  union all

  select 'query table staging count'
  where (select count(*) from {{ ref('stg_snowflake__query_tables') }}) <> 4

  union all

  select 'query column staging count'
  where (select count(*) from {{ ref('stg_snowflake__query_table_columns') }}) <> 6

  union all

  select 'direct and base remain separate in staging'
  where (
    select count(*)
    from {{ ref('stg_snowflake__query_tables') }}
    where query_id = 'q1'
      and table_sk = 'prod.analytics.orders'
      and access_type in ('direct', 'base')
  ) <> 2

  union all

  select 'typed and renamed in staging'
  where not exists (
    select 1
    from {{ ref('stg_snowflake__queries') }}
    where query_id = 'q1'
      and user_name = 'analyst'
      and duration_seconds = 2
      and start_at::timestamp_ntz = start_at
  )

)

select * from failures
