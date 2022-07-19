
{{
  config(
    materialized = 'incremental'
    , unique_key = 'query_id'
  )
}}

with queries as (

  select * from {{ source('snowflake_internal', 'query_history') }}

)

, renamed_recasted as (

  select 
    query_id
    , lower(query_text) as query_text
    , database_id
    , lower(database_name) as database_name
    , schema_id
    , lower(schema_name) as schema_name
    , lower(query_type) as query_type
    , session_id
    , lower(user_name) as user_name
     -- queries by tooling user accounts are a popular filter for 'usage' analyses, ex; DBT_USER
    , user_name in ('') as is_tooling_user
    , lower(role_name) as role_name
    , warehouse_id
    , lower(warehouse_name) as warehouse_name
    , lower(warehouse_size) as warehouse_size
    , lower(warehouse_type) as warehouse_type
    , cluster_number
    , query_tag
    , lower(execution_status) as execution_status
    , error_code
    , error_message
    , start_time as start_at_utc
    , end_time as end_at_utc
    , total_elapsed_time / 1000 as duration_seconds
    , compilation_time / 1000 as compilation_seconds
    , execution_time / 1000 as execution_seconds
    , queued_provisioning_time / 1000 as queued_provisioning_seconds
    , queued_repair_time / 1000 as queued_repair_seconds
    , queued_overload_time / 1000 as queued_overload_seconds
    , transaction_blocked_time / 1000 as transaction_blocked_seconds
    -- many niche fields are excluded

  from queries

  where true 
    
    -- and database_name in ('') -- Databases of interest, uppercase, ex: PROD

    {% if is_incremental() %}
      and start_at_utc > (select dateadd('day', -1, max(t.start_at_utc)) from {{ this }} t)
    {% endif %}

    {% if target.name == 'dev' or target.name == 'ci' %}
      and start_at_utc >= dateadd('day', -28, current_timestamp)
    {% endif %}

)

select * from renamed_recasted
