FROM python:3.12-slim

# procps — чтобы внутри при желании смотреть процессы
RUN apt-get update \
    && apt-get install -y --no-install-recommends procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY app.py /app/app.py

CMD ["python3", "/app/app.py"]
