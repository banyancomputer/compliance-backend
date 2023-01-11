# Run migrations and collect static files
echo "Running Flush.."
python manage.py flush --no-input
echo "Running Make Migrations.."
python manage.py makemigrations
echo "Running Migrate.."
python manage.py migrate
echo "Running Collect Static.."
python manage.py collectstatic --no-input --clear
echo "Creating Super User.."
python manage.py createsuperuser --no-input

# Start server
echo "Starting server.."
gunicorn hello_django.wsgi:application --bind 0.0.0.0:8000