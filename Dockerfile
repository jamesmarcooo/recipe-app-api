FROM python:3.9-alpine3.13

# tells python that you don't want to buffer the output
# output will be printed directly and immediately as running
ENV PYTHOHNNUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# argument used in docker-compose for dependencies only for dev mode
ARG DEV=false

# run command that installs the dependencies inside virtual env
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client jpeg-dev && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
        # adds a user since it is a best practice not to use the root user
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
        # changing the owner of the directory and subdir to django-user
    chmod -R 755 /vol
        # change mode or permissions of the directory so django-user can make changes

# run python from the environment
ENV PATH="/py/bin:$PATH"

# switch to user and everything being ran in the image is through the djang-user
USER django-user
