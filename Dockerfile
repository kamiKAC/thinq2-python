FROM --platform=$TARGETPLATFORM python:3.9-alpine3.18 as base
ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    CARGO_NET_GIT_FETCH_WITH_CLI=true
    
RUN apk add --no-cache gcc musl-dev libffi-dev cargo openssl-dev git libc6-compat openssl openssl1.1-compat \
    && mkdir -p /thinq2-python

WORKDIR /thinq2-python
COPY pyproject.toml poetry.lock pytest.ini ./
COPY thinq2 /thinq2-python/thinq2
COPY tests /thinq2-python/tests

RUN pip3 -v install python-dev-tools
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip3 -v install .
RUN pip3 uninstall poetry

FROM --platform=$TARGETPLATFORM python:3.9-alpine3.17 as thinq

RUN adduser -D thinq
USER thinq
COPY --from=base --chown=thinq:thinq /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /thinq2-python
COPY --chown=thinq:thinq thinq2_mqtt.py start.sh ./

RUN mkdir -p /thinq2-python/state \
    && chmod +x start.sh

CMD ./start.sh
