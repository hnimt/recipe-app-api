FROM python:3.9-alpine3.13
LABEL maintainer="minhdeveloper.com"

ENV PYTHONUNBUFFRED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
# install dependency if dev environemt or no && add new user
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    # install postgresql-client to install psycopg
    apk add --update --no-cache postgresql-client && \
    # group packages installed into this name called tmp-build-deps like line 26
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user