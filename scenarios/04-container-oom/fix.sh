#!/usr/bin/env bash
#
# fix.sh — разбор инцидента 04: диагностика -> причина -> решение -> проверка.
# В конце ждёт клавишу, удаляет контейнер и возвращает лабу в исходное состояние.
#
set -euo pipefail
cd "$(dirname "$0")"
source ../../lib.sh

CONTAINER="incident-04"

banner "РАЗБОР ИНЦИДЕНТА 04"

# ─────────────────────────────────────────────────────────────
step 1 "диагностика" "Статус и код выхода контейнера"
explain "Контейнер не работает. Смотрим статус и код выхода:"
echo ""
run_sh "docker ps -a --filter name=${CONTAINER} --format 'table {{.Names}}\t{{.Status}}'"
echo ""
explain "Exited (137). Код 137 = 128 + 9 -> процесс убит сигналом 9 (SIGKILL)."
explain "Сам процесс так не завершается: его кто-то принудительно убил."

# ─────────────────────────────────────────────────────────────
step 2 "диагностика" "Подтверждаем OOM через docker inspect"
explain "Docker хранит флаг, был ли контейнер убит из-за нехватки памяти:"
echo ""
run_sh "docker inspect ${CONTAINER} --format 'OOMKilled={{.State.OOMKilled}} ExitCode={{.State.ExitCode}}'"
echo ""
explain "OOMKilled=true -> прямое подтверждение: контейнер убил OOM killer ядра,"
explain "потому что процесс превысил лимит памяти контейнера."
echo ""
info "Дополнительно это видно в логах ядра хоста (dmesg):"
run_sh "sudo dmesg -T 2>/dev/null | grep -iE 'oom|killed process' | tail -3 || echo '(нужен sudo, либо записи уже вытеснены; для лабы достаточно OOMKilled=true)'"

# ─────────────────────────────────────────────────────────────
step 3 "причина" "Лимит памяти меньше, чем нужно приложению"
explain "Приложению для работы нужно ~120 МБ (держит рабочий набор в памяти)."
explain "Смотрим, какой лимит задан контейнеру в docker-compose.yml:"
echo ""
run_sh "grep -nE 'mem_limit' docker-compose.yml"
echo ""
explain "Лимит 50 МБ. Приложение пытается выделить 120 МБ, упирается в лимит,"
explain "и ядро (cgroup OOM killer) убивает процесс. Приложение здоровое, оно не"
explain "течёт — просто лимит задан меньше реальной потребности."

# ─────────────────────────────────────────────────────────────
step 4 "решение" "Поднимаем лимит до реальной потребности приложения"
explain "Правильный фикс — задать лимит с запасом над тем, что нужно приложению."
explain "Нужно ~120 МБ, поставим 256 МБ (потребность + запас). Правим compose и"
explain "пересоздаём контейнер."
echo ""
info "Меняем mem_limit 50m -> 256m в docker-compose.yml:"
run sed -i 's/^    mem_limit: 50m/    mem_limit: 256m/' docker-compose.yml
echo ""
info "Новый лимит в compose:"
run_sh "grep -nE 'mem_limit' docker-compose.yml"
echo ""
info "Пересоздаём контейнер с новым лимитом:"
run_sh "docker compose up -d >/dev/null 2>&1 && echo 'контейнер пересоздан'"
sleep 5

# ─────────────────────────────────────────────────────────────
step 5 "проверка" "Контейнер должен работать стабильно (Up)"
echo ""
run_sh "docker ps --filter name=${CONTAINER} --format 'table {{.Names}}\t{{.Status}}'"
echo ""
info "И подтверждаем, что OOM больше нет:"
run_sh "docker inspect ${CONTAINER} --format 'OOMKilled={{.State.OOMKilled}} Status={{.State.Status}}'"
echo ""
info "Логи: приложение выделило память и работает:"
run docker logs --tail 4 "$CONTAINER"
echo ""
success "Контейнер работает стабильно, OOM больше нет — инцидент решён!"
echo ""
explain "Вывод: exit 137 = процесс убит SIGKILL; OOMKilled=true указывает на нехватку"
explain "памяти. Причина была не в приложении, а в слишком жёстком лимите. Фикс —"
explain "задать лимит по реальной потребности приложения (с запасом)."

# ─────────────────────────────────────────────────────────────
pause_key "Нажми любую клавишу, чтобы удалить контейнер и вернуть лабу в исходное состояние..."
echo ""
info "Убираю за собой..."
docker compose down >/dev/null 2>&1
success "Контейнер удалён."

info "Возвращаю docker-compose.yml в исходное 'сломанное' состояние (256m -> 50m)..."
sed -i 's/^    mem_limit: 256m/    mem_limit: 50m/' docker-compose.yml
success "Лаба сброшена — готова к повторному запуску. Чисто."
echo ""
