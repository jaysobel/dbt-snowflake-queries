select
    'q1'::text as query_id
  , dateadd('hour', -2, current_timestamp)::timestamp_ltz as query_start_time
  , 'ANALYST'::text as user_name
  , parse_json($$[
      {"objectDomain":"Table","objectId":1,"objectName":"PROD.ANALYTICS.ORDERS","columns":[
        {"columnId":11,"columnName":"ID"},
        {"columnId":12,"columnName":"AMOUNT"}
      ]}
    ]$$)::array as direct_objects_accessed
  , parse_json($$[
      {"objectDomain":"Table","objectId":1,"objectName":"PROD.ANALYTICS.ORDERS","columns":[
        {"columnId":11,"columnName":"ID"},
        {"columnId":12,"columnName":"AMOUNT"}
      ]}
    ]$$)::array as base_objects_accessed
  , array_construct() as objects_modified
  , object_construct() as object_modified_by_ddl
  , array_construct() as policies_referenced
  , null::text as parent_query_id
  , null::text as root_query_id
  , 'QUERY'::text as event_source
  , null::variant as additional_properties
  , null::object as invoker_identity

union all

select
    'q2'::text as query_id
  , dateadd('hour', -1, current_timestamp)::timestamp_ltz as query_start_time
  , 'DBT_SERVICE'::text as user_name
  , parse_json($$[
      {"objectDomain":"View","objectId":2,"objectName":"PROD.ANALYTICS.ORDER_SUMMARY","columns":[
        {"columnId":21,"columnName":"CUSTOMER_ID"}
      ]}
    ]$$)::array as direct_objects_accessed
  , parse_json($$[
      {"objectDomain":"Table","objectId":3,"objectName":"PROD.RAW.ORDERS","columns":[
        {"columnId":31,"columnName":"CUSTOMER_ID"}
      ]}
    ]$$)::array as base_objects_accessed
  , array_construct() as objects_modified
  , object_construct() as object_modified_by_ddl
  , array_construct() as policies_referenced
  , 'parent-q'::text as parent_query_id
  , 'root-q'::text as root_query_id
  , 'QUERY'::text as event_source
  , null::variant as additional_properties
  , null::object as invoker_identity
