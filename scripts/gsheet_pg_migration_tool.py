import psycopg2._psycopg
import psycopg2.sql
import toml
import logging
import psycopg2
import sys
from gspread import service_account_from_dict
from gspread.spreadsheet import Spreadsheet
from pathlib import Path

CONFIG_FILE_PATH="./config.toml"

def get_spreadsheet_client() -> Spreadsheet | None:
    """
    Get spreadsheet client using service account
    """
    try:
        secrets_config: list[dict[str, str]] = toml.loads(
            Path(CONFIG_FILE_PATH).read_text(encoding="utf-8")
        )
        if 'connections' in secrets_config and \
            'gsheets' in secrets_config['connections'] and \
            'type' in secrets_config['connections']['gsheets'] and \
            secrets_config['connections']['gsheets']['type'] == 'service_account':
            config = secrets_config['connections']['gsheets']
            client = service_account_from_dict(config)
            spreadsheet = client.open_by_url(config['spreadsheet'])
            return spreadsheet
        else:
            return None
    except (FileNotFoundError, toml.decoder.TomlDecodeError, KeyError):
        logging.error("No config file found")
    return None

def get_worksheet() -> str | None:
    """
    Gets worksheet value from secrets config file.
    This is needed to specify a worksheet for service accounts.
    """
    try:
        secrets_config: list[dict[str, str]] = toml.loads(
            Path(CONFIG_FILE_PATH).read_text(encoding="utf-8")
        )
        if 'connections' in secrets_config and \
            'gsheets' in secrets_config['connections'] and \
            'worksheet' in secrets_config['connections']['gsheets'] and \
            'type' in secrets_config['connections']['gsheets'] and \
            secrets_config['connections']['gsheets']['type'] == 'service_account':
            return secrets_config['connections']['gsheets']['worksheet']
        else:
            return None
    except (FileNotFoundError, toml.decoder.TomlDecodeError, KeyError):
        logging.error("No config file found, continuing without owner color map")
    return None

def get_postgres_client() -> psycopg2._psycopg.connection | None:
    try:
        secrets_config: list[dict[str, str]] = toml.loads(
                Path(CONFIG_FILE_PATH).read_text(encoding="utf-8")
            )
        if 'postgres' in secrets_config and \
            'user' in secrets_config['postgres'] and \
            'password' in secrets_config['postgres'] and \
            'db' in secrets_config['postgres'] and \
            'host' in secrets_config['postgres'] and \
            'port' in secrets_config['postgres']:
            postgres_config = secrets_config['postgres']
            return psycopg2.connect(database = postgres_config['db'],
                                    user = postgres_config['user'],
                                    password = postgres_config['password'],
                                    host = postgres_config['host'],
                                    port = postgres_config['port'])
        else:
            logging.error("Postgres config missing")
    except (FileNotFoundError, toml.decoder.TomlDecodeError, KeyError):
        logging.error("No config file found, continuing without owner color map")
    return None

def get_postgres_table() -> str | None:
    try:
        secrets_config: list[dict[str, str]] = toml.loads(
            Path(CONFIG_FILE_PATH).read_text(encoding="utf-8")
        )
        if 'postgres' in secrets_config and \
            'table' in secrets_config['postgres']:
            return secrets_config['postgres']['table']
        else:
            return None
    except (FileNotFoundError, toml.decoder.TomlDecodeError, KeyError):
        logging.error("No config file found")
    return None

if __name__ == "__main__":
    gsheet_client = get_spreadsheet_client()
    worksheet = get_worksheet()
    postgres_client = get_postgres_client()
    pg_table = get_postgres_table()

    if (not (gsheet_client and worksheet and postgres_client and pg_table)):
        sys.exit(1)

    cur = postgres_client.cursor()
    w = gsheet_client.worksheet(worksheet)
    for r in w.get_values()[2:]:
        cur.execute("INSERT INTO expenses (cost, description, date, category, person) VALUES (%s, %s, %s, %s, %s)", (
            float(str(r[4]).replace('$','').replace(',','')),
            r[1],
            r[0],
            r[2],
            r[3],
        ))
    postgres_client.commit()
    postgres_client.close()