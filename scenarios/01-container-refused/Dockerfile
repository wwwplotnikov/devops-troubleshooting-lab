FROM python:3.12-slim

# ss (для диагностики внутри) и procps — стандартный инструментарий
RUN apt-get update \
    && apt-get install -y --no-install-recommends iproute2 procps curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY app.py /app/app.py

# Приложение слушает 8080 внутри (но на 127.0.0.1 — в этом и баг)
EXPOSE 8080

CMD ["python3", "/app/app.py"]
