
{{
  config(
    materialized = 'incremental'
    , unique_key = 'query_id'
  )
}}

with access_history as (

  select * from {{ source('snowflake_internal', 'access_history') }}

)

-- Small scale duplication is possible, and may be expensive to de-dupe 
, renamed_recasted as (

  select
      query_id::text as query_id
    , query_start_time::timestamp_ntz as start_at_utc
    , user_name::text as user_name
    , direct_objects_accessed::array as direct_objects_accessed
    , base_objects_accessed::array as base_objects_accessed
    , objects_modified::array as objects_modified
  
  from access_history
  
  where true
  
  {% if is_incremental() %}
    and start_at_utc > (select dateadd('day', -1, max(start_at_utc)) from {{ this }})
  {% endif %}

  {% if target.name == 'dev' or target.name == 'ci' %}
    and start_at_utc >= dateadd('day', -28, current_timestamp)
  {% endif %}

)

select * from renamed_recasted
