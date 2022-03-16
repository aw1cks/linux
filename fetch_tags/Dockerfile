FROM docker.io/python:3.10

COPY ./entrypoint.py requirements.txt /
RUN pip install --no-cache-dir -r /requirements.txt
ENTRYPOINT ["/bin/sh", "-c", "python /entrypoint.py"]
