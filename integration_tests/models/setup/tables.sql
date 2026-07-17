with base_table as (

  select
      1::number as table_id
    , 'ORDERS'::text as table_name
    , 'ANALYTICS'::text as table_schema
    , 'PROD'::text as table_catalog
    , 'TRANSFORMER'::text as table_owner
    , 'BASE TABLE'::text as table_type
    , 'NO'::text as is_transient
    , 'NO'::text as is_iceberg
    , 'NO'::text as is_dynamic
    , 'NO'::text as is_hybrid
    , null::text as clustering_key
    , 100::number as row_count
    , 1048576::number as bytes
    , 1::number as retention_time
    , dateadd('day', -30, current_timestamp)::timestamp_ltz as created
    , dateadd('day', -1, current_timestamp)::timestamp_ltz as last_altered
    , dateadd('day', -2, current_timestamp)::timestamp_ltz as last_ddl
    , 'ANALYST'::text as last_ddl_by
    , null::timestamp_ltz as deleted
    , 'NO'::text as auto_clustering_on
    , 'Orders fact'::text as comment
    , 'ROLE'::text as owner_role_type

)

select * from base_table

union all

select * replace (
    2::number as table_id
  , 'ORDER_SUMMARY'::text as table_name
  , 'VIEW'::text as table_type
  , 0::number as row_count
  , 0::number as bytes
  , 'Order summary view'::text as comment
)
from base_table

union all

select * replace (
    3::number as table_id
  , 'ORDERS'::text as table_name
  , 'RAW'::text as table_schema
  , 1000::number as row_count
  , 2097152::number as bytes
  , 'Raw orders'::text as comment
)
from base_table
