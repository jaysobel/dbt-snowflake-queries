
{{
  config(
    materialized = 'table'
  )
}}

with columns as (

  select * from {{ source('snowflake_internal', 'columns') }}

)

, renamed_recasted as (

  select
      lower(column_name) as column_name
    , lower(table_name) as table_name
    , lower(table_schema) as schema_name
    , lower(table_catalog) as database_name
    , ordinal_position
    , column_default
    , lower(data_type) as data_type
  
  from columns
  
  where true
    -- and table_catalog in ('') -- Databases of interest, uppercase, ex: PROD
    -- and table_schema in ('') -- Schemas of interest (across above databases, uppercase)
    and deleted is null -- exclude deleted columns (deleted is a timestamp field)

)

, keyed as (

  select
      *
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
