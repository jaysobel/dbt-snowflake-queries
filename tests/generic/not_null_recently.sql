{% test not_null_recently(model, column_name, time_column, lookback_days=14) %}

    select {{ column_name }}
    from {{ model }}
    where {{ column_name }} is null
      and (
          {{ time_column }} >= dateadd('day', -{{ lookback_days }}, current_timestamp)
          -- in case test is applied to time column itself
          or {{ time_column }} is null
      )

{% endtest %}