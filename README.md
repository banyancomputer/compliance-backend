# compliance-backend

What is it?

Django app with surround AWS hosted infrastructure managed by terraform

What infrastructure does it create?
1. Lambdas for running django app
2. API Gateway for routing requests to lambdas
3. S3 bucket for storing static files 
4. S3 bucket for storing Lambdas (maybe just ecr with django docker images?)
5. RDS database for storing data
6. Cloudfront for serving static files
7. VPC for endpoints
8. Security Groups for resource access
9. IAM roles for resource access
10. Cloudwatch for logging
11. Route53 for DNS

What does the django app do?
1. Allow unauthenticated users to read data through Lambda endpoints
2. Allow authenticated users to read/write data through Lambda endpoints


**Documentation**

All configurations are done in `settings.py`

1. How do I run this?

To run this on your local machine, cd into `backend` and run `python3 manage.py runserver`

2. How do I format queries to the app?

Go into a python shell by running `python manage.py shell`. From there, you can start making queries, which you can find how to format [here](https://docs.djangoproject.com/en/4.1/topics/db/queries/)


3. How can I manage the server as an admin?

- run `python3 manage.py runserver`
- to create a login, run `python3 manage.py createsuperuser` and use those credentials to log into [http://127.0.0.1:8000/admin/](http://127.0.0.1:8000/admin)

you should see "Groups" and "Users" but we've created a database. We need to give the dashboard access to that database.

- You can add databases to your dashboard by going to `admin.py`, and using the `admin.site.register(YourNewModel)` format (NOTE: don't forget to add your import from models.py)

You can now manage your databases!

4. How do I set what db to pull from?

Go to the `settings.py` folder and configure the DATABASES (line 77) setting to point to any other database backends (MySWL, Oracle, PostgreSQL, etc.) 

Read more on how to configure other databases [here](https://docs.djangoproject.com/en/4.1/ref/settings/#databases)

5. How do I set where to read static files

[Learn how to configure them here](https://docs.djangoproject.com/en/4.0/howto/static-files/) and [deploy them here](https://docs.djangoproject.com/en/4.0/howto/static-files/#deployment)

6. How do I run tests? 

run `python3 manage.py test`

MIGRATIONS: 

Read about [migrations](https://docs.djangoproject.com/en/4.1/topics/migrations/#module-django.db.migrations)

- Models are shown in `models.py`, run `python3 manage.py makemigrations main` after changing your model to create new migrations


- `python3 manage.py migrate` updates the project after modifying the settings.py file

CREATE/ADDING OBJECTS:

You can create/add objects to your Model (i.e database object) by using the format:
variableName = databaseObject(databaseObjectAttribute="")

ex.

If my model was named ToDoList in `models.py` and has a name attribute, my object will look like:

t1 = ToDoList(name="First List")