# Contributing

Issues and pull requests are welcome. Changes should preserve the five public model grains, keep the mart intentionally curated, and place source cleanup and incremental mechanics in the staging layer.

## Parse compatibility

```shell
dbt parse --project-dir integration_tests --profiles-dir integration_tests/ci_profiles
```

CI runs the integration project under supported dbt Core versions and dbt Fusion.

## Snowflake integration tests

The integration project creates synthetic Account Usage fixtures in an isolated schema, builds the five staging and five mart models, and runs exact data tests. Pass the test database without committing account-specific configuration:

```shell
dbt run --project-dir integration_tests --profile <snowflake_profile> --select path:models/setup
dbt build --project-dir integration_tests --profile <snowflake_profile> \
  --exclude path:models/setup \
  --vars '{account_usage_database: "<development_database>"}'
```

Run the same build a second time to exercise incremental merges, then remove both isolated integration schemas.
