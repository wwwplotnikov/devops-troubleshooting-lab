FROM python:3.12-slim

# Рабочая директория. Из-за неё относительный путь "data.db" в приложении
# превращается в /app/data.db — мимо смонтированного тома /data.
WORKDIR /app
COPY app.py /app/app.py

# Держим контейнер живым, чтобы обращаться к приложению через docker exec
# (утилита add/list вызывается по требованию).
CMD ["sleep", "infinity"]
