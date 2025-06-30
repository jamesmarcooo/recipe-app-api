FROM python:3.9-alpine3.13

# tells python that you don't want to buffer the output
# output will be printed directly and immediately as running
ENV PYTHOHNNUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# run command that installs the dependencies inside virtual env
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user
    # adds a user since it is a best practice not to use the root user

# run python from the environment
ENV PATH="py/bin:$PATH"

# switch to user and everything being ran in the image is through the djang-user
USER django-user
