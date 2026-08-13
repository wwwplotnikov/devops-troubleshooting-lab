#!/usr/bin/env bash
#
# start.sh — поднимает контейнер со слишком маленьким лимитом памяти,
# из-за чего его убивает OOM killer. Показывает симптом.
#
set -euo pipefail
cd "$(dirname "$0")"
source ../../lib.sh

CONTAINER="incident-04"

# Гарантируем "сломанное" исходное состояние: лимит памяти 50m (мало).
# (fix.sh поднимает до 256m — возвращаем баг на место для воспроизводимости.)
sed -i 's/^    mem_limit: 256m/    mem_limit: 50m/' docker-compose.yml

banner "ИНЦИДЕНТ 04: Контейнер убивает OOM killer (exit 137)"

info "Собираю и поднимаю контейнер с приложением (лимит памяти 50 МБ)..."
docker compose up -d --build >/dev/null 2>&1

info "Ждём пару секунд, приложение пытается выделить рабочий набор памяти..."
sleep 4

echo ""
info "Смотрим статус контейнера:"
run_sh "docker ps -a --filter name=${CONTAINER} --format 'table {{.Names}}\t{{.Status}}'"
echo ""
symptom "СИМПТОМ: контейнер завершился с кодом 137 (Exited (137))."
echo ""
explain "137 = 128 + 9, где 9 это сигнал SIGKILL. То есть процесс не завершился"
explain "сам, его принудительно убили. В контексте лимита памяти это почти всегда"
explain "OOM killer: приложению не хватило памяти в рамках заданного лимита."
echo ""
info "Логи приложения (обрываются на попытке выделить память):"
run docker logs "$CONTAINER"
echo ""
info "Попробуй разобраться сам — или запусти ./fix.sh для разбора."
echo ""
