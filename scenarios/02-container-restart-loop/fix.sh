#!/usr/bin/env bash
#
# fix.sh — разбор инцидента 02: диагностика -> причина -> решение -> проверка.
# В конце ждёт клавишу, удаляет контейнер и возвращает лабу в исходное состояние.
#
set -euo pipefail
cd "$(dirname "$0")"
source ../../lib.sh

CONTAINER="incident-02"

banner "РАЗБОР ИНЦИДЕНТА 02"

# ─────────────────────────────────────────────────────────────
step 1 "диагностика" "Смотрим статус контейнера — что с ним происходит"
explain "Контейнер не работает стабильно. Первым делом — его статус:"
echo ""
run_sh "docker ps -a --filter name=${CONTAINER} --format 'table {{.Names}}\t{{.Status}}'"
echo ""
explain "Статус Restarting / постоянные перезапуски = приложение падает при старте,"
explain "а restart-политика поднимает его снова. Надо понять причину падения."

# ─────────────────────────────────────────────────────────────
step 2 "диагностика" "Читаем логи — почему приложение падает (docker logs!)"
explain "Главный инструмент при падении контейнера — его логи."
echo ""
run docker logs "$CONTAINER"
echo ""
explain "В логах — внятная ошибка: приложение сообщает, что не задана"
explain "переменная окружения DB_HOST, и поэтому завершается."

# ─────────────────────────────────────────────────────────────
step 3 "причина" "Почему переменной нет и почему это цикл"
explain "Приложению нужен DB_HOST (адрес БД) — типичный паттерн конфигурации"
explain "через переменные окружения. В docker-compose.yml эта переменная НЕ задана."
echo ""
info "Смотрим текущий docker-compose.yml:"
run_sh "grep -nE 'environment|DB_HOST|restart' docker-compose.yml || true"
echo ""
explain "Видно: блок environment закомментирован — переменной нет."
explain "При каждом старте приложение падает (exit 1), restart: on-failure"
explain "поднимает его заново -> бесконечный цикл перезапусков."

# ─────────────────────────────────────────────────────────────
step 4 "решение" "Добавляем переменную в compose и пересоздаём контейнер"
explain "Конфигурация контейнера задаётся в docker-compose.yml, поэтому правим его"
explain "(а не лезем внутрь контейнера) и пересоздаём сервис."
echo ""
info "1) Добавляем DB_HOST в docker-compose.yml (раскомментируем блок environment):"
run sed -i 's/^    # environment:/    environment:/; s/^    #   - DB_HOST=db/      - DB_HOST=db/' docker-compose.yml
echo ""
info "   Теперь блок environment в compose выглядит так:"
run_sh "grep -nE 'environment|DB_HOST' docker-compose.yml"
echo ""
info "2) Пересоздаём контейнер, чтобы подхватить новую переменную:"
run_sh "docker compose up -d >/dev/null 2>&1 && echo 'контейнер пересоздан'"
sleep 4

# ─────────────────────────────────────────────────────────────
step 5 "проверка" "Убеждаемся, что контейнер стабилен, а не рестартует"
echo ""
run_sh "docker ps --filter name=${CONTAINER} --format 'table {{.Names}}\t{{.Status}}'"
echo ""
info "И смотрим логи — приложение должно работать, а не падать:"
run docker logs --tail 5 "$CONTAINER"
echo ""
success "Контейнер работает стабильно (Up, без рестартов) — инцидент решён!"
echo ""
explain "Вывод: цикл рестартов = приложение падает при старте + restart-политика."
explain "docker logs сразу показал причину (нет DB_HOST). Фикс — передать"
explain "переменную через docker-compose.yml и пересоздать контейнер."

# ─────────────────────────────────────────────────────────────
pause_key "Нажми любую клавишу, чтобы удалить контейнер и вернуть лабу в исходное состояние..."
echo ""
info "Убираю за собой..."
docker compose down >/dev/null 2>&1
success "Контейнер удалён."

info "Возвращаю docker-compose.yml в исходное 'сломанное' состояние (убираю DB_HOST)..."
sed -i 's/^    environment:/    # environment:/; s/^      - DB_HOST=db/    #   - DB_HOST=db/' docker-compose.yml
success "Лаба сброшена — готова к повторному запуску. Чисто."
echo ""
