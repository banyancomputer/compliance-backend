#!/bin/sh



echo "Starting the application..."

# Wait for the database to be ready
while ! nc -z $SQL_HOST $SQL_PORT; do
  sleep 0.1
done

echo "PostgreSQL started"

chown -R app:app /home/app/web/staticfiles
# Start server
exec "$@"