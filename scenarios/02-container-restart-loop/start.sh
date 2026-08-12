#!/usr/bin/env bash
#
# start.sh — поднимает контейнер, который падает в цикле рестартов,
# и наглядно показывает симптом.
#
set -euo pipefail
cd "$(dirname "$0")"
source ../../lib.sh

CONTAINER="incident-02"

# Гарантируем "сломанное" исходное состояние: переменной DB_HOST быть не должно.
# (fix.sh добавляет её в compose — возвращаем баг на место для воспроизводимости.)
sed -i 's/^    environment:/    # environment:/; s/^      - DB_HOST=db/    #   - DB_HOST=db/' docker-compose.yml

banner "ИНЦИДЕНТ 02: Контейнер в цикле перезапусков"

info "Собираю и поднимаю контейнер с приложением..."
docker compose up -d --build >/dev/null 2>&1

info "Ждём несколько секунд, чтобы контейнер успел попадать и порестартовать..."
sleep 6

info "Смотрим статус контейнера:"
run_sh "docker ps -a --filter name=${CONTAINER} --format 'table {{.Names}}\t{{.Status}}'"

echo ""
symptom "СИМПТОМ: контейнер не работает стабильно — он в статусе Restarting"
symptom "         (или Exited и постоянно перезапускается). Счётчик рестартов растёт."
echo ""
explain "Приложение стартует и тут же падает, restart-политика поднимает его снова,"
explain "и так по кругу. Нужно понять, ПОЧЕМУ оно падает при старте."
echo ""
info "Попробуй разобраться сам (подсказка: с чего всегда начинают — docker logs)"
info "— или запусти ./fix.sh для пошагового разбора."
echo ""
