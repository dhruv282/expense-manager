import argparse
import csv
import psycopg2
import sys
import logging
from datetime import datetime
from tqdm import tqdm
from typing import List
from pathlib import Path

logger = logging.getLogger(__name__)

class Transaction:
    date: str
    owner: str
    description: str
    category: str
    cost: float

class DBConfig:
    user: str = "postgres"
    password: str = "postgres"
    name: str = "expenses_db"
    host: str = "localhost"
    port: str = "5432"
    table: str = "expenses"

def initialize_db(cursor: psycopg2._psycopg.cursor) -> bool:
    logger.info("Initializing DB table...")
    try:
        cursor.execute('''
            DO $$ BEGIN
              CREATE TYPE OWNER_OPTIONS AS ENUM('Shared');
            EXCEPTION
              WHEN duplicate_object THEN null;
            END $$;        
        ''')
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS expenses (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            cost DECIMAL(12,2) NOT NULL,
            description TEXT NOT NULL,
            date DATE NOT NULL,
            category TEXT NOT NULL,
            person OWNER_OPTIONS
        )
        ''')
    except Exception as e:
        logger.error(e)
        return False
    return True


def add_owner_if_not_exists(owner: str, cursor: psycopg2._psycopg.cursor) -> bool:
    try:
        # Check if owner val currently exists in enum
        cursor.execute("SELECT unnest(enum_range(NULL::OWNER_OPTIONS))")
        vals = cursor.fetchall()
        owners = [o[0] for o in vals]
        if owner not in owners:
            # Alter enum to add value
            cursor.execute(f"ALTER TYPE OWNER_OPTIONS ADD VALUE '{owner}'")
    except Exception as e:
        logger.error(e)
        return False
    return True

def is_valid_date(date_str, date_format="%m/%d/%Y") -> bool:
    try:
        datetime.strptime(date_str, date_format)
        return True
    except ValueError:
        return False

def get_transactions_from_csv(csv_file_path: Path) -> List[Transaction]:
    transactions: List[Transaction] = []
    with open(csv_file_path) as f:
        csv_reader = csv.reader(f)
        next(csv_reader)  # Skip the header row

        for row in csv_reader:
            transaction = Transaction()
            transaction.cost = float(str(row[4]).replace('$','').replace(',',''))
            transaction.description = row[1]
            transaction.date = row[0]
            transaction.category = row[2]
            if row[6] == "Yes":
                transaction.owner = "Shared"
            else:
                transaction.owner = row[3]

            if not is_valid_date(transaction.date):
                logger.error(f"Invalid date format: {transaction.date}")
                sys.exit(1)

            transactions.append(transaction)
    return transactions

def main(db_config: DBConfig, transactions: List[Transaction]):
    postgres_client = psycopg2.connect(
        database = db_config.name,
        user = db_config.user,
        password = db_config.password,
        host = db_config.host,
        port = db_config.port)

    cur = postgres_client.cursor()

    init_status = initialize_db(cur)
    if not init_status:
        sys.exit(1)
    
    for t in tqdm(transactions, desc="Adding entries to DB"):
        status_ok = add_owner_if_not_exists(t.owner, cur)
        if not status_ok:
            logger.error(f"Error adding owner: {t.owner}")
            sys.exit(1)
        postgres_client.commit()
        cur.execute("INSERT INTO expenses (cost, description, date, category, person) VALUES (%s, %s, %s, %s, %s)", (
            t.cost,
            t.description,
            t.date,
            t.category,
            t.owner,
        ))
    logger.info("DB entries added successfully!")
    postgres_client.commit()
    postgres_client.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="CSV to PostgreSQL migration tool",
        description='''This tool inserts transactions from the specified CSV file to a PostgreSQL DB.
        The DB config can be configured in the a config.json.
        This script also initializes the DB table and enums needed.
        ''',
        add_help=True
    )
    parser.add_argument("-f", "--file_path", required=True, type=Path, help="CSV file path")

    db_config = DBConfig()
    db_config_parser = parser.add_argument_group(
        title="DB config overrides",
        description="Use this set of arguments to override default DB config")
    db_config_parser.add_argument("--db_user", default=db_config.user, type=str, help="DB user (default: %(default)s)")
    db_config_parser.add_argument("--db_password", default=db_config.password, type=str, help="DB password (default: %(default)s)")
    db_config_parser.add_argument("--db_name", default=db_config.name, type=str, help="DB name (default: %(default)s)")
    db_config_parser.add_argument("--db_host", default=db_config.host, type=str, help="DB host (default: %(default)s)")
    db_config_parser.add_argument("--db_port", default=db_config.port, type=str, help="DB port (default: %(default)s)")
    db_config_parser.add_argument("--db_table", default=db_config.table, type=str, help="DB table (default: %(default)s)")

    args = parser.parse_args()
    file_path: Path = args.file_path

    # Check if the file exists
    if not file_path.is_file():
        logger.error(f"File not found: {file_path}")
        sys.exit(1)

    # Update DB config
    db_config.user = args.db_user
    db_config.password = args.db_password
    db_config.name = args.db_name
    db_config.host = args.db_host
    db_config.port = args.db_port
    db_config.table = args.db_table

    transactions = get_transactions_from_csv(file_path)

    main(db_config, transactions)
