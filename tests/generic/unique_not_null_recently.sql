{% test unique_not_null_recently(model, column_name, time_column, lookback_days=14) %}

    select 
      {{ column_name }} as unique_not_null_column
      , count({{ column_name }}) as count_values
    from {{ model }}
    where {{ time_column }} >= dateadd('day', -{{ lookback_days }}, current_timestamp)
    group by 1
    having count({{ column_name }}) <> 1

{% endtest %}
