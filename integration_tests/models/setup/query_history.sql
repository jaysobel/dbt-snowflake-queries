with base_query as (

  select
      'q1'::text as query_id
    , 'select id, amount from prod.analytics.orders where id = 1'::text as query_text
    , 'SELECT'::text as query_type
    , 'hash_q1'::text as query_hash
    , 1::integer as query_hash_version
    , 'pattern_orders_by_id'::text as query_parameterized_hash
    , 1::integer as query_parameterized_hash_version
    , 'analytics'::text as query_tag
    , 101::number as session_id
    , 'ANALYST'::text as user_name
    , 'PERSON'::text as user_type
    , 'TRANSFORMER'::text as role_name
    , 'ROLE'::text as role_type
    , 'TRANSFORMING'::text as warehouse_name
    , 'X-SMALL'::text as warehouse_size
    , 'STANDARD'::text as warehouse_type
    , 1::integer as cluster_number
    , 'PROD'::text as database_name
    , 'ANALYTICS'::text as schema_name
    , 'SUCCESS'::text as execution_status
    , null::text as error_code
    , null::text as error_message
    , dateadd('hour', -2, date_trunc('hour', current_timestamp))::timestamp_ltz as start_time
    , dateadd('second', 2, dateadd('hour', -2, date_trunc('hour', current_timestamp)))::timestamp_ltz as end_time
    , 2000::number as total_elapsed_time
    , 100::number as compilation_time
    , 1750::number as execution_time
    , 50::number as queued_provisioning_time
    , 0::number as queued_repair_time
    , 100::number as queued_overload_time
    , 0::number as transaction_blocked_time
    , 0::number as child_queries_wait_time
    , 0::number as query_retry_time
    , null::text as query_retry_cause
    , 0::number as fault_handling_time
    , 1048576::number as bytes_scanned
    , 0.75::float as percentage_scanned_from_cache
    , 2::number as partitions_scanned
    , 10::number as partitions_total
    , 0::number as bytes_spilled_to_local_storage
    , 0::number as bytes_spilled_to_remote_storage
    , 0::number as bytes_sent_over_the_network
    , 0::number as bytes_written
    , 1024::number as bytes_written_to_result
    , 0::number as bytes_read_from_result
    , 1::number as rows_produced
    , 0::number as rows_inserted
    , 0::number as rows_updated
    , 0::number as rows_deleted
    , 0::number as rows_unloaded
    , 1::number as rows_written_to_result
    , 0.001::float as credits_used_cloud_services
    , 10::float as query_load_percent
    , true::boolean as is_client_generated_statement

)

, queries as (

  select * from base_query

  union all

  select * replace (
      'q2'::text as query_id
    , 'select customer_id from prod.analytics.order_summary where customer_id = 2'::text as query_text
    , 'hash_q2'::text as query_hash
    , 'pattern_orders_by_id'::text as query_parameterized_hash
    , 102::number as session_id
    , 'DBT_SERVICE'::text as user_name
    , dateadd('hour', -1, date_trunc('hour', current_timestamp))::timestamp_ltz as start_time
    , dateadd('second', 3, dateadd('hour', -1, date_trunc('hour', current_timestamp)))::timestamp_ltz as end_time
    , 3000::number as total_elapsed_time
    , 2::number as rows_produced
  )
  from base_query

  union all

  select * replace (
      'q3'::text as query_id
    , 'update prod.analytics.orders set amount = amount + 1'::text as query_text
    , 'UPDATE'::text as query_type
    , 'hash_q3'::text as query_hash
    , 'pattern_update_orders'::text as query_parameterized_hash
    , 103::number as session_id
    , 'FAILED'::text as execution_status
    , '1003'::text as error_code
    , 'Synthetic failure'::text as error_message
    , dateadd('minute', -30, current_timestamp)::timestamp_ltz as start_time
    , dateadd('second', 1, dateadd('minute', -30, current_timestamp))::timestamp_ltz as end_time
    , 1000::number as total_elapsed_time
    , 0::number as rows_produced
    , 0.2::float as query_load_percent
  )
  from base_query

)

select * from queries
