#!/bin/sh
python manage.py migrate
gunicorn -w 3 -b :8000 filestore.wsgi:application
