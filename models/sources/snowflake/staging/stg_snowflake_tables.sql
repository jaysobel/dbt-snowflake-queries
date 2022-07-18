
{{
  config(
    materialized = 'table'
  )
}}

with tables as (

  select * from {{ source('snowflake_internal', 'tables') }}

)

, renamed_recasted as (

  select
      lower(table_name) as table_name
    , lower(table_schema) as schema_name
    , lower(table_catalog) as database_name
    , lower(table_catalog) as table_catalog
    , lower(table_owner) as table_owner
    , case
        when table_type = 'BASE TABLE' then 'table'
        else lower(table_type) -- ex: view
      end as table_type
    , created as created_at_utc
    , last_altered as last_altered_at_utc
    , clustering_key
    , row_count
    , bytes
    , round(bytes / 1000000, 2) as megabytes
    , is_transient = 'YES' as is_transient
    , auto_clustering_on = 'YES' as is_auto_clustering_on
  
  from tables

  where true
    -- and table_catalog in ('') -- Databases of interest, uppercase, ex: PROD
    -- and table_schema in ('') -- Schemas of interest (across above databases, uppercase)
    and deleted is null -- exclude deleted tables/views (deleted is a timestamp field)

)

, keyed as (

  select 
      *
    , concat(
        database_name
        , '.', schema_name
        , '.', table_name
      ) as table_key

  from renamed_recasted

)

select * from keyed
