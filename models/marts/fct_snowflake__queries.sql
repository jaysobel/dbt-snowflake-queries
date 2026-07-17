{{ config(materialized='view') }}

select
    query_id
  , query_text
  , query_type
  , query_hash
  , query_hash_version
  , query_parameterized_hash
  , query_parameterized_hash_version
  , query_tag
  , session_id
  , parent_query_id
  , root_query_id
  , user_name
  , user_type
  , is_tooling_user
  , role_name
  , role_type
  , warehouse_name
  , warehouse_size
  , warehouse_type
  , cluster_number
  , execution_status
  , error_code
  , error_message
  , start_at
  , end_at
  , duration_seconds
  , compilation_seconds
  , execution_seconds
  , queued_provisioning_seconds
  , queued_repair_seconds
  , queued_overload_seconds
  , queued_seconds
  , transaction_blocked_seconds
  , child_queries_wait_seconds
  , query_retry_seconds
  , query_retry_cause
  , fault_handling_seconds
  , bytes_scanned
  , fraction_scanned_from_cache
  , partitions_scanned
  , partitions_total
  , bytes_spilled_to_local_storage
  , bytes_spilled_to_remote_storage
  , bytes_sent_over_the_network
  , bytes_written
  , bytes_written_to_result
  , bytes_read_from_result
  , rows_produced
  , rows_inserted
  , rows_updated
  , rows_deleted
  , rows_unloaded
  , rows_written_to_result
  , rows_modified
  , cloud_services_credits
  , query_load_percent
  , is_client_generated_statement

from {{ ref('stg_snowflake__queries') }}
