ARG BASE_IMAGE=python:3.11-alpine

FROM --platform=$TARGETPLATFORM ${BASE_IMAGE} as base
ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    CARGO_NET_GIT_FETCH_WITH_CLI=true
    
RUN apk add --no-cache gcc g++ musl-dev libffi-dev cargo openssl-dev git libc6-compat openssl \
    && mkdir -p /thinq2-python

WORKDIR /thinq2-python
COPY pyproject.toml pytest.ini ./

RUN pip3 -v install --upgrade pip
RUN pip3 -v install python-dev-tools

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip3 -v install .
RUN pip3 -v install --upgrade setuptools pip

FROM --platform=$TARGETPLATFORM ${BASE_IMAGE} as thinq

ENV PIP_NO_CACHE_DIR=1
RUN apk update && apk upgrade --no-cache
RUN pip3 -v install --upgrade pip

RUN adduser -D thinq
USER thinq
COPY --from=base --chown=thinq:thinq /opt/venv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

COPY --chown=thinq:thinq thinq2_mqtt.py start.sh /thinq2-python/
COPY --chown=thinq:thinq thinq2 /thinq2-python/thinq2
COPY --chown=thinq:thinq tests /thinq2-python/tests

WORKDIR /thinq2-python

RUN mkdir -p /thinq2-python/state \
    && chmod +x start.sh

CMD ./start.sh
