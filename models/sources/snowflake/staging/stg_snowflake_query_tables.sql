
{{
  config(
    materialized = 'incremental'
    , unique_key = 'query_table_id'
  )
}}

with snowflake_access_history as (

  select * from {{ ref('bse_snowflake_access_history') }}

)

, renamed_recasted as (

  -- a query can reference the same object multiple times
  select distinct 
      snowflake_access_history.query_id
    , snowflake_access_history.start_at_utc
    , lower(snowflake_access_history.user_name) as user_name
    , lower(split_part(objects_accessed.value:objectName::text, '.', 1)) as database_name
    , lower(split_part(objects_accessed.value:objectName::text, '.', 2)) as schema_name
    , lower(split_part(objects_accessed.value:objectName::text, '.', 3)) as table_name
    , objects_accessed.value:columns as columns_array

  from snowflake_access_history
  , lateral flatten(snowflake_access_history.direct_objects_accessed) as objects_accessed

  where true 
  
    -- and database_name in ('') -- Databases of interest, uppercase, ex: PROD

  {% if is_incremental() %}
    and snowflake_access_history.start_at_utc > (select dateadd('day', -1, max(start_at_utc)) from {{ this }})
  {% endif %}

  {% if target.name == 'dev' or target.name == 'ci' %}
    and snowflake_access_history.start_at_utc >= dateadd('day', -28, current_timestamp)
  {% endif %}

)

, keyed as (
  
  select 
      *
    , md5(
        concat(
          query_id
          , '-', database_name
          , '.', schema_name
          , '.', table_name
        )
     ) as query_table_key
    , concat(
        database_name
        , '.', schema_name
        , '.', table_name
      ) as table_key

  from renamed_recasted

)

select * from keyed
