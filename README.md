This is the standard [pgbouncer](https://github.com/pgbouncer/pgbouncer) database connection pooler augmented with the [pgbouncer-rr](https://github.com/awslabs/pgbouncer-rr-patch) extension.

Because the config file must contain sensitive connection details for the database, it should be passed as a Docker secret with the name `pgbouncer_config`.
