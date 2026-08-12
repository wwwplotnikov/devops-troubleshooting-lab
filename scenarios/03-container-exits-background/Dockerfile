FROM python:3.12-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY app.py /app/app.py
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Контейнер запускается через entrypoint-скрипт (он станет PID 1).
CMD ["/app/entrypoint.sh"]
