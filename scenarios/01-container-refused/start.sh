#!/usr/bin/env bash
#
# start.sh — поднимает контейнер (уже "сломанным") и показывает симптом.
#
set -euo pipefail
cd "$(dirname "$0")"
source ../../lib.sh

CONTAINER="incident-01"

# Гарантируем "сломанное" исходное состояние: бинд должен быть 127.0.0.1.
# (fix.sh правит app.py на 0.0.0.0 при пересборке — возвращаем баг на место,
#  чтобы сценарий был воспроизводим при повторных запусках.)
sed -i 's/BIND_HOST = "0.0.0.0"/BIND_HOST = "127.0.0.1"/' app.py


banner "ИНЦИДЕНТ 01: Connection Refused на проброшенном порту"

info "Собираю и поднимаю контейнер с веб-приложением..."
docker compose up -d --build >/dev/null 2>&1

# ждём, пока приложение внутри поднимется
sleep 2

info "Контейнер запущен. Проверим, что он живой и порт проброшен:"
run_sh "docker ps --filter name=${CONTAINER} --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

echo ""
info "Порт проброшен корректно: 0.0.0.0:8080 -> 8080 контейнера."
info "Приложение внутри, по идее, слушает 8080. Пробуем достучаться снаружи:"
echo ""

# Показываем симптом. curl вернёт ненулевой код — не роняем скрипт из-за set -e.
printf "    ${C_GREEN}\$ curl -sS --max-time 5 http://localhost:8080${C_RESET}\n"
if curl -sS --max-time 5 http://localhost:8080 2>&1 | sed 's/^/    /'; then
    :
else
    true
fi

echo ""
symptom "СИМПТОМ: порт проброшен (-p 8080:8080), контейнер работает,"
symptom "         но снаружи — Connection refused."
echo ""
explain "Странно: -p настроен, контейнер жив, приложение 'слушает 8080'."
explain "Почему же refused? (напомним: refused = пакет дошёл, но на порту никто не слушает)"
echo ""
info "Попробуй разобраться сам — или запусти ./fix.sh для пошагового разбора."
echo ""
