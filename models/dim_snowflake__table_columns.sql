{{ config(materialized='table') }}

with columns as (

  select *
  from {{ source('snowflake_account_usage', 'columns') }}
  where deleted is null

)

select
    lower(concat_ws('.', table_catalog, table_schema, table_name, column_name)) as table_column_sk
  , lower(concat_ws('.', table_catalog, table_schema, table_name)) as table_sk
  , column_id::number as column_id
  , table_id::number as table_id
  , lower(table_catalog)::text as database_name
  , lower(table_schema)::text as schema_name
  , lower(table_name)::text as table_name
  , lower(column_name)::text as column_name
  , ordinal_position::integer as ordinal_position
  , lower(data_type)::text as data_type
  , lower(data_type_alias)::text as data_type_alias
  , lower(kind)::text as column_kind
  , is_nullable = 'YES' as is_nullable
  , is_identity = 'YES' as is_identity
  , column_default::text as column_default
  , expression::text as column_expression
  , character_maximum_length::number as character_maximum_length
  , numeric_precision::number as numeric_precision
  , numeric_scale::number as numeric_scale
  , comment::text as comment

from columns
where true
  {{ dbt_snowflake_queries__list_filter(
      'table_catalog',
      var('included_databases', []),
      var('excluded_databases', [])
  ) }}
  {{ dbt_snowflake_queries__list_filter(
      'table_schema',
      var('included_schemas', []),
      var('excluded_schemas', [])
  ) }}
