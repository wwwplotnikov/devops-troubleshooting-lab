#!/usr/bin/env bash
#
# start.sh — поднимает контейнер, который сразу завершается с кодом 0,
# и наглядно показывает коварный симптом (код успешный, а контейнер мёртв).
#
set -euo pipefail
cd "$(dirname "$0")"
source ../../lib.sh

CONTAINER="incident-03"

# Гарантируем "сломанное" исходное состояние: запуск в фоне через "&".
# (fix.sh меняет на exec ... на переднем плане — возвращаем баг на место.)
sed -i 's|^exec python3 /app/app.py|python3 /app/app.py \&|' entrypoint.sh

banner "ИНЦИДЕНТ 03: Контейнер сразу завершается (exit 0)"

info "Собираю и поднимаю контейнер с сервисом..."
docker compose up -d --build >/dev/null 2>&1

info "Ждём пару секунд и смотрим, работает ли контейнер:"
sleep 3

echo ""
info "Список РАБОТАЮЩИХ контейнеров (docker ps):"
run_sh "docker ps --filter name=${CONTAINER} --format 'table {{.Names}}\t{{.Status}}'"
echo ""
explain "Пусто — среди работающих нашего контейнера нет. Он уже не запущен."
echo ""
info "Смотрим ВСЕ контейнеры, включая остановленные (docker ps -a):"
run_sh "docker ps -a --filter name=${CONTAINER} --format 'table {{.Names}}\t{{.Status}}'"
echo ""
symptom "СИМПТОМ: контейнер в статусе Exited (0) — завершился с кодом 0 (успех!),"
symptom "         но при этом не работает. И в логах, скорее всего, нет ошибки."
echo ""
info "Проверим логи — есть ли там хоть какая-то ошибка:"
run docker logs "$CONTAINER"
echo ""
explain "Обрати внимание: код выхода 0 (успех), в логах ошибки нет, а контейнер"
explain "не работает. Почему 'успешный' контейнер мёртв? В этом вся загадка."
echo ""
info "Попробуй разобраться сам — или запусти ./fix.sh для разбора."
echo ""
