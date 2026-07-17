{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='query_id',
    on_schema_change='sync_all_columns'
  )
}}

{% set include_query_text = var('include_query_text', true) %}
{% set tooling_users = var('tooling_users', []) %}

with query_history as (

  select *
  from {{ source('snowflake_account_usage', 'query_history') }}
  where start_time >= dateadd('day', -{{ var('query_history_lookback_days', 365) }}, current_timestamp)

  {% if is_incremental() %}
    and convert_timezone('UTC', start_time)::timestamp_ntz >= (
      select dateadd(
        'day',
        -{{ var('incremental_lookback_days', 3) }},
        coalesce(max(start_at), '1970-01-01'::timestamp_ntz)
      )
      from {{ this }}
    )
  {% endif %}

  {{ dbt_snowflake_queries__list_filter(
      'database_name',
      var('included_databases', []),
      var('excluded_databases', [])
  ) }}
  {{ dbt_snowflake_queries__list_filter(
      'schema_name',
      var('included_schemas', []),
      var('excluded_schemas', [])
  ) }}

)

, access_history as (

  select
      query_id::text as query_id
    , max(parent_query_id::text) as parent_query_id
    , max(root_query_id::text) as root_query_id
  from {{ source('snowflake_account_usage', 'access_history') }}
  where query_start_time >= dateadd('day', -{{ var('query_history_lookback_days', 365) }}, current_timestamp)

  {% if is_incremental() %}
    and convert_timezone('UTC', query_start_time)::timestamp_ntz >= (
      select dateadd(
        'day',
        -{{ var('incremental_lookback_days', 3) }},
        coalesce(max(start_at), '1970-01-01'::timestamp_ntz)
      )
      from {{ this }}
    )
  {% endif %}

  group by 1

)

select
    query_id::text as query_id
  {% if include_query_text %}
    , query_text::text as query_text
  {% else %}
    , null::text as query_text
  {% endif %}
  , lower(query_type)::text as query_type
  , query_hash::text as query_hash
  , query_hash_version::integer as query_hash_version
  , query_parameterized_hash::text as query_parameterized_hash
  , query_parameterized_hash_version::integer as query_parameterized_hash_version
  , query_tag::text as query_tag
  , session_id::number as session_id
  , access_history.parent_query_id
  , access_history.root_query_id
  , lower(user_name)::text as user_name
  , lower(user_type)::text as user_type
  , {{ dbt_snowflake_queries__is_in_list('user_name', tooling_users) }} as is_tooling_user
  , lower(role_name)::text as role_name
  , lower(role_type)::text as role_type
  , lower(warehouse_name)::text as warehouse_name
  , lower(warehouse_size)::text as warehouse_size
  , lower(warehouse_type)::text as warehouse_type
  , cluster_number::integer as cluster_number
  , lower(database_name)::text as database_name
  , lower(schema_name)::text as schema_name
  , lower(execution_status)::text as execution_status
  , error_code::text as error_code
  , error_message::text as error_message
  , convert_timezone('UTC', start_time)::timestamp_ntz as start_at
  , convert_timezone('UTC', end_time)::timestamp_ntz as end_at
  , total_elapsed_time / 1000.0 as duration_seconds
  , compilation_time / 1000.0 as compilation_seconds
  , execution_time / 1000.0 as execution_seconds
  , queued_provisioning_time / 1000.0 as queued_provisioning_seconds
  , queued_repair_time / 1000.0 as queued_repair_seconds
  , queued_overload_time / 1000.0 as queued_overload_seconds
  , (
      coalesce(queued_provisioning_time, 0)
      + coalesce(queued_repair_time, 0)
      + coalesce(queued_overload_time, 0)
    ) / 1000.0 as queued_seconds
  , transaction_blocked_time / 1000.0 as transaction_blocked_seconds
  , child_queries_wait_time / 1000.0 as child_queries_wait_seconds
  , query_retry_time / 1000.0 as query_retry_seconds
  , lower(query_retry_cause)::text as query_retry_cause
  , fault_handling_time / 1000.0 as fault_handling_seconds
  , bytes_scanned::number as bytes_scanned
  , percentage_scanned_from_cache::float as fraction_scanned_from_cache
  , partitions_scanned::number as partitions_scanned
  , partitions_total::number as partitions_total
  , bytes_spilled_to_local_storage::number as bytes_spilled_to_local_storage
  , bytes_spilled_to_remote_storage::number as bytes_spilled_to_remote_storage
  , bytes_sent_over_the_network::number as bytes_sent_over_the_network
  , bytes_written::number as bytes_written
  , bytes_written_to_result::number as bytes_written_to_result
  , bytes_read_from_result::number as bytes_read_from_result
  , rows_produced::number as rows_produced
  , rows_inserted::number as rows_inserted
  , rows_updated::number as rows_updated
  , rows_deleted::number as rows_deleted
  , rows_unloaded::number as rows_unloaded
  , rows_written_to_result::number as rows_written_to_result
  , coalesce(rows_inserted, 0) + coalesce(rows_updated, 0) + coalesce(rows_deleted, 0) as rows_modified
  , credits_used_cloud_services::float as cloud_services_credits
  , query_load_percent::float as query_load_percent
  , is_client_generated_statement::boolean as is_client_generated_statement

from query_history
left join access_history using (query_id)
