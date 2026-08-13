#!/usr/bin/env bash
#
# start.sh — поднимает сервис с хранилищем и АВТОМАТИЧЕСКИ демонстрирует
# потерю данных при пересоздании контейнера (данные пишутся мимо тома).
#
set -euo pipefail
cd "$(dirname "$0")"
source ../../lib.sh

CONTAINER="incident-05"

# Гарантируем "сломанное" исходное состояние: относительный путь к данным.
# (fix.sh меняет на абсолютный /data/data.db — возвращаем баг на место.)
sed -i 's|^DATA_FILE = "/data/data.db"|DATA_FILE = "data.db"|' app.py

banner "ИНЦИДЕНТ 05: Данные пропадают после пересоздания контейнера"

info "Поднимаю сервис с постоянным хранилищем (в compose есть volume)..."
docker compose up -d --build >/dev/null 2>&1
sleep 2

info "Записываем в хранилище пару записей:"
run_sh "docker exec ${CONTAINER} python3 /app/app.py add 'первая запись'"
run_sh "docker exec ${CONTAINER} python3 /app/app.py add 'вторая запись'"
echo ""
info "Проверяем, что данные на месте:"
run_sh "docker exec ${CONTAINER} python3 /app/app.py list"
echo ""
explain "Данные записались и читаются. Volume в compose есть, всё выглядит рабочим."

echo ""
info "Теперь ПЕРЕСОЗДАЁМ контейнер (как при обновлении/рестарте): down + up"
run_sh "docker compose down >/dev/null 2>&1 && docker compose up -d >/dev/null 2>&1 && echo 'контейнер пересоздан'"
sleep 2
echo ""
info "Смотрим, что осталось в хранилище после пересоздания:"
run_sh "docker exec ${CONTAINER} python3 /app/app.py list"
echo ""
symptom "СИМПТОМ: данные ПРОПАЛИ после пересоздания, хотя volume настроен."
echo ""
explain "Том вроде есть и смонтирован — почему данные не сохранились?"
echo ""
info "Попробуй разобраться сам — или запусти ./fix.sh для разбора."
echo ""
