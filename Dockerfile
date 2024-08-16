FROM python:3.10-slim

WORKDIR /app

COPY app.py /app

RUN pip install flask prometheus_flask_exporter prometheus_client gunicorn

ENV MESSAGE="Hello world from Docker!"

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]