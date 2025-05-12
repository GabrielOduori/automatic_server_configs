#!/bin/bash
set -euo pipefail

echo "Setting up PostgreSQL for Django..."

# Load environment variables from .env file
if [ ! -f .env ]; then
    echo ".env file not found. Please create one with the required variables."
    exit 1
fi

export $(grep -v '^#' .env | xargs)

# Check if required variables are set
: "${DB_NAME:?DB_NAME is not set in .env}"
: "${DB_USER:?DB_USER is not set in .env}"
: "${DB_PASSWORD:?DB_PASSWORD is not set in .env}"

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt install -y postgresql postgresql-contrib

# Create a PostgreSQL database and user
echo "Creating PostgreSQL database and user..."
sudo -u postgres psql <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
ALTER ROLE $DB_USER SET client_encoding TO 'utf8';
ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';
ALTER ROLE $DB_USER SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
GRANT ALL PRIVILEGES ON SCHEMA public TO $DB_USER;
ALTER DATABASE $DB_NAME OWNER TO $DB_USER;
GRANT CREATE ON SCHEMA public TO $DB_USER;


EOF

echo "PostgreSQL setup is complete. Database: $DB_NAME, User: $DB_USER."