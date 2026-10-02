"""Read customers in a city. Run: python python/query_customers.py Dublin"""
import argparse
import getpass
import os
import sys
import psycopg

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("city", nargs="?", default="Dublin")
    args = parser.parse_args()
    config = {
        "host": os.getenv("PGHOST", "localhost"),
        "port": os.getenv("PGPORT", "5432"),
        "dbname": os.getenv("PGDATABASE", "sql_practice"),
        "user": os.getenv("PGUSER", "postgres"),
        "password": getpass.getpass("PostgreSQL password: "),
        "connect_timeout": 10,
    }
    try:
        with psycopg.connect(**config) as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT customer_id, name, city FROM customers "
                    "WHERE city = %s ORDER BY customer_id",
                    (args.city,),
                )
                rows = cur.fetchall()
                for customer_id, name, city in rows:
                    print(f"{customer_id}: {name} ({city})")
                print(f"{len(rows)} customer(s)")
    except psycopg.Error:
        print("Database query failed. Check the server, credentials, database, "
              "and whether the schema/seed files were loaded.", file=sys.stderr)
        return 1
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
