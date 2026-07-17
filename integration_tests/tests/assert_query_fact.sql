with failures as (

  select 'query count' as check_name
  where (select count(*) from {{ ref('fct_snowflake__queries') }}) <> 3

  union all

  select 'parameterized pattern'
  where (
    select count(distinct query_parameterized_hash)
    from {{ ref('fct_snowflake__queries') }}
    where query_id in ('q1', 'q2')
  ) <> 1

  union all

  select 'tooling user'
  where not coalesce((
    select is_tooling_user
    from {{ ref('fct_snowflake__queries') }}
    where query_id = 'q2'
  ), false)

  union all

  select 'query timing aliases'
  where (
    select duration_seconds
    from {{ ref('fct_snowflake__queries') }}
    where query_id = 'q1'
  ) <> 2

  union all

  select 'parent and root query ids'
  where (
    select concat(parent_query_id, '|', root_query_id)
    from {{ ref('fct_snowflake__queries') }}
    where query_id = 'q2'
  ) <> 'parent-q|root-q'

)

select * from failures
