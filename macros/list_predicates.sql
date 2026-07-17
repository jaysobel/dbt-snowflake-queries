{% macro dbt_snowflake_queries__quoted_list(values) -%}
  {%- for value in values -%}
    '{{ value | string | replace("'", "''") | lower }}'{% if not loop.last %}, {% endif %}
  {%- endfor -%}
{%- endmacro %}

{% macro dbt_snowflake_queries__list_filter(column_name, included_values=[], excluded_values=[]) -%}
  {%- if included_values | length > 0 %}
    and lower({{ column_name }}) in ({{ dbt_snowflake_queries__quoted_list(included_values) }})
  {%- endif %}
  {%- if excluded_values | length > 0 %}
    and (
      {{ column_name }} is null
      or lower({{ column_name }}) not in ({{ dbt_snowflake_queries__quoted_list(excluded_values) }})
    )
  {%- endif %}
{%- endmacro %}

{% macro dbt_snowflake_queries__is_in_list(column_name, values=[]) -%}
  {%- if values | length > 0 -%}
    coalesce(lower({{ column_name }}) in ({{ dbt_snowflake_queries__quoted_list(values) }}), false)
  {%- else -%}
    false
  {%- endif -%}
{%- endmacro %}
