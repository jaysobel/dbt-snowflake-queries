
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

  -- a query can reference the same table and-or columns multiple times
  select distinct 
      queries.query_id
    , queries.start_at_utc
    , lower(queries.user_name) as user_name
    , lower(split_part(tables.value:objectName::text, '.', 1)) as database_name
    , lower(split_part(tables.value:objectName::text, '.', 2)) as schema_name
    , lower(split_part(tables.value:objectName::text, '.', 3)) as table_name
    , lower(table_columns.value:columnName) as column_name

  from snowflake_access_history as queries
  , lateral flatten(queries.direct_objects_accessed) as tables
  , lateral flatten(tables.value:columns) as table_columns

  where true 
    -- and database_name in ('') -- Databases of interest, uppercase, ex: PROD

    {% if is_incremental() %}
      and queries.start_at_utc > (select dateadd('day', -1, max(t.start_at_utc)) from {{ this }} t)
    {% endif %}

    {% if target.name == 'dev' or target.name == 'ci' %}
      and queries.start_at_utc >= dateadd('day', -28, current_timestamp)
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
          , '.', column_name
        )
     ) as query_table_column_key
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
        , '.', column_name
      ) as table_column_key
    , concat(
        database_name
        , '.', schema_name
        , '.', table_name
      ) as table_key

  from renamed_recasted

)

select * from keyed
