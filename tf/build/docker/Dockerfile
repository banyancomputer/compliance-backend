# syntax=docker/dockerfile:1

# Very simple Dockerfile to test Lambda

# Use the public lambda python image as a base
FROM public.ecr.aws/jg/hello:latest

# Copy the file to the working directory
COPY . ${LAMBDA_TASK_ROOT}

# Install dependencies
RUN yum install -y gcc python27 python27-devel postgresql-devel
RUN pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

CMD [ "test.handler" ]

