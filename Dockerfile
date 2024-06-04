ARG PYTHON_VERSION=3.11

FROM python:${PYTHON_VERSION}-slim

RUN python -m pip install RangeHTTPServer

WORKDIR /tmp

ENV PORT 8082
CMD python -m RangeHTTPServer ${PORT}
