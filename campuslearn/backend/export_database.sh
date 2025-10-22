#!/bin/bash

# Database Export Script for CampusLearn
# This script exports your local PostgreSQL database to a file
# that can be imported into Railway or other hosting platforms

echo "==================================="
echo "CampusLearn Database Export Script"
echo "==================================="
echo ""

# Database connection details (from appsettings.json)
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="campuslearn"
DB_USER="postgres"
DB_PASSWORD="@sp3l1nG"

# Output file
OUTPUT_FILE="campuslearn_export_$(date +%Y%m%d_%H%M%S).sql"

echo "Exporting database: $DB_NAME"
echo "Output file: $OUTPUT_FILE"
echo ""

# Set password environment variable to avoid prompt
export PGPASSWORD=$DB_PASSWORD

# Export database using pg_dump
pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME --clean --if-exists --no-owner --no-acl -f $OUTPUT_FILE

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database exported successfully!"
    echo "📄 File: $OUTPUT_FILE"
    echo ""
    echo "Next steps:"
    echo "1. Upload this file to Railway PostgreSQL"
    echo "2. Run: psql <your-railway-connection-string> < $OUTPUT_FILE"
else
    echo ""
    echo "❌ Export failed. Make sure PostgreSQL is running and credentials are correct."
    exit 1
fi

# Clear password variable
unset PGPASSWORD
