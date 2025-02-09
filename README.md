# Expense Manager

Expense Manager is an open-source expense tracking and visualization app developed using [Flutter](http://flutter.dev) and utilizes a self-hosted [PostgreSQL](https://www.postgresql.org) database instance for data management.

## Usage

### Hosting Database
Run a PostgreSQL container using the Docker compose provided at `db_helper/docker-compose.yml`. Edit credential & config for the database via environment variables in the compose file as needed. It is recommended to change the login credentials for better security.

```shell
docker compose up --build -f ./db_helper/docker-compose.yml
```

### App Configuration
Once the database is online, launch the Expense Manager application and you will automatically be redirected to the database config page. Use this page to enter the database connection config.

Once the connection config is submitted, the app with auto initialize required tables and enums.

## License

Expense Tracker is open-source software released under the [MIT License](https://opensource.org/licenses/MIT). You are free to modify and distribute the application under the terms of this license. See the [`LICENSE`](./LICENSE) file for more information.

Please note that this README file is subject to change as the application evolves. Refer to the latest version of this file in the repository for the most up-to-date information.
