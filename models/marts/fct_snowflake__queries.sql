{{ config(materialized='view') }}

select *
from {{ ref('stg_snowflake__queries') }}
