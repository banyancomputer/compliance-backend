# syntax=docker/dockerfile:1

# Very simple Dockerfile to test Lambda

# Use the public lambda python image as a base
FROM public.ecr.aws/lambda/python:3.8-x86_64

# Copy the file to the working directory
COPY test.py ${LAMBDA_TASK_ROOT}

CMD [ "test.handler" ]

