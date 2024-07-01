# expense_manager

## Local Testing

### Database

Run a local PostgreSQL container using the Docker compose provided at `db_helper/docker-compose.yml`.

```
docker compose up --build
```

Establish the connection in your app by using the following details:

```
var dbManager = DatabaseManager();
dbManager.connect("10.0.2.2", "test_db", "postgres", "postgres",const ConnectionSettings(sslMode: SslMode.disable));
```
