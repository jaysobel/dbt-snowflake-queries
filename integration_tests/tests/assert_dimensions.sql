with failures as (

  select 'table count' as check_name
  where (select count(*) from {{ ref('dim_snowflake__tables') }}) <> 3

  union all

  select 'column count'
  where (select count(*) from {{ ref('dim_snowflake__table_columns') }}) <> 4

  union all

  select 'readable table key'
  where not exists (
    select 1 from {{ ref('dim_snowflake__tables') }}
    where table_sk = 'prod.analytics.orders'
  )

  union all

  select 'readable column key'
  where not exists (
    select 1 from {{ ref('dim_snowflake__table_columns') }}
    where table_column_sk = 'prod.analytics.orders.amount'
  )

  union all

  select 'curated modern metadata'
  where not exists (
    select 1 from {{ ref('dim_snowflake__table_columns') }}
    where table_column_sk = 'prod.analytics.orders.id'
      and data_type_alias = 'integer'
      and column_kind = 'column'
  )

)

select * from failures
