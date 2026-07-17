with base_column as (

  select
      11::number as column_id
    , 'ID'::text as column_name
    , 1::number as table_id
    , 'ORDERS'::text as table_name
    , 'ANALYTICS'::text as table_schema
    , 'PROD'::text as table_catalog
    , 1::number as ordinal_position
    , null::text as column_default
    , 'NO'::text as is_nullable
    , 'NUMBER'::text as data_type
    , null::number as character_maximum_length
    , 38::number as numeric_precision
    , 0::number as numeric_scale
    , 'NO'::text as is_identity
    , 'Order identifier'::text as comment
    , null::timestamp_ltz as deleted
    , 'INTEGER'::text as data_type_alias
    , null::text as expression
    , 'COLUMN'::text as kind

)

select * from base_column

union all

select * replace (
    12::number as column_id
  , 'AMOUNT'::text as column_name
  , 2::number as ordinal_position
  , 2::number as numeric_scale
  , 'Order amount'::text as comment
  , 'NUMBER'::text as data_type_alias
)
from base_column

union all

select * replace (
    21::number as column_id
  , 'CUSTOMER_ID'::text as column_name
  , 2::number as table_id
  , 'ORDER_SUMMARY'::text as table_name
  , 'Customer identifier'::text as comment
)
from base_column

union all

select * replace (
    31::number as column_id
  , 'CUSTOMER_ID'::text as column_name
  , 3::number as table_id
  , 'RAW'::text as table_schema
  , 'Customer identifier'::text as comment
)
from base_column
