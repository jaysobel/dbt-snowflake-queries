{{ config(materialized='view') }}

select
    table_column_sk
  , table_sk
  , database_name
  , schema_name
  , table_name
  , column_name
  , ordinal_position
  , data_type
  , data_type_alias
  , column_kind
  , is_nullable
  , is_identity
  , column_default
  , column_expression
  , character_maximum_length
  , numeric_precision
  , numeric_scale
  , comment

from {{ ref('stg_snowflake__table_columns') }}
