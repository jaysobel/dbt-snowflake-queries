{% test unique_recently(model, column_name, time_column, lookback_days=14) %}

    select 
        {{ column_name }}
        , count(*) as count_rows
    from {{ model }}
    where {{ time_column }} >= dateadd('day', -{{ lookback_days }}, current_timestamp)
    group by 1
    having count(*) >= 2

{% endtest %}