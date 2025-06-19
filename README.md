# Expense Manager

<p align="center">
   <img src="./assets/icon/expense_manager.png" width="150"/>
</p>

Expense Manager is an open-source expense tracking and visualization app developed using [Flutter](http://flutter.dev) and utilizes a self-hosted [PostgreSQL](https://www.postgresql.org) database instance for data management.

## Features

📊 **Dashboard Overview** — Visualize your financial data with interactive widgets like pie charts and income vs. expense trends.

✍️ **Track Transactions** — Add, edit, and delete income and expense entries with support for categories, descriptions, dates, and amounts.

🔍 **Advanced Filtering** — Search and filter transactions by category, date range, cost, and more with interactive controls.

📅 **Flexible Recurring Transactions** — Set up recurring entries with [RRULE](https://pub.dev/packages/rrule) support for complex scheduling (e.g., "every 3 weeks on Friday").

🎨 **Customizable Themes** — Automatically adapts to system light/dark mode, with user override support for manual theme and base color selection.

<p align="center">
  <img src="https://github.com/user-attachments/assets/253f5cb3-56c5-46a4-aeac-fdbb11845507" width="200">
  <img src="https://github.com/user-attachments/assets/62042ce3-8021-46ec-80ee-2e6fd7bcf793" width="200">
  <img src="https://github.com/user-attachments/assets/e950d640-422a-49c3-88a6-750f5bf04a3e" width="200">
  <img src="https://github.com/user-attachments/assets/bd1349c9-663e-4955-bd7f-a43fda9d2d26" width="200">
</p>

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
