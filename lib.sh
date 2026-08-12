#!/usr/bin/env bash
# lib.sh — общие функции для оформления вывода в лабах.
# Подключается в start.sh / fix.sh через:  source ../../lib.sh

# --- Цвета (отключаются, если вывод не в терминал) ---
if [ -t 1 ]; then
    C_RESET='\033[0m'
    C_BOLD='\033[1m'
    C_RED='\033[0;31m'
    C_GREEN='\033[0;32m'
    C_YELLOW='\033[0;33m'
    C_BLUE='\033[0;34m'
    C_CYAN='\033[0;36m'
    C_GRAY='\033[0;90m'
else
    C_RESET=''; C_BOLD=''; C_RED=''; C_GREEN=''
    C_YELLOW=''; C_BLUE=''; C_CYAN=''; C_GRAY=''
fi

# Заголовок инцидента (рамка)
banner() {
    local title="$1"
    local width=60
    echo ""
    printf "${C_BOLD}${C_BLUE}┌%s┐${C_RESET}\n" "$(printf '─%.0s' $(seq 1 $((width-2))))"
    printf "${C_BOLD}${C_BLUE}│${C_RESET} ${C_BOLD}%-$((width-4))s${C_RESET} ${C_BOLD}${C_BLUE}│${C_RESET}\n" "$title"
    printf "${C_BOLD}${C_BLUE}└%s┘${C_RESET}\n" "$(printf '─%.0s' $(seq 1 $((width-2))))"
    echo ""
}

# Информационное сообщение
info() {
    printf "${C_CYAN}[*]${C_RESET} %s\n" "$1"
}

# Симптом / тревожное сообщение
symptom() {
    printf "${C_RED}[!]${C_RESET} ${C_BOLD}%s${C_RESET}\n" "$1"
}

# Успех
success() {
    printf "${C_GREEN}[✓]${C_RESET} %s\n" "$1"
}

# Заголовок шага в fix.sh:  step 1 "диагностика" "Смотрим, на каком адресе слушает приложение"
step() {
    local num="$1"; local kind="$2"; local desc="$3"
    echo ""
    printf "${C_BOLD}${C_YELLOW}━━━ ШАГ %s ${C_RESET}${C_GRAY}[%s]${C_RESET} ${C_BOLD}%s${C_RESET}\n" "$num" "$kind" "$desc"
}

# Пояснение (обычный текст с отступом)
explain() {
    printf "    ${C_GRAY}%s${C_RESET}\n" "$1"
}

# Показать команду перед выполнением, затем выполнить её.
# Использование:  run docker exec incident-05 ss -tlnp
run() {
    printf "    ${C_GREEN}\$ %s${C_RESET}\n" "$*"
    # выполняем и делаем отступ у вывода команды
    "$@" 2>&1 | sed 's/^/    /'
}

# То же, но команда с пайпами/редиректами — передаём строкой в bash.
# Использование:  run_sh 'docker exec incident-05 ss -tlnp | grep 8080'
run_sh() {
    printf "    ${C_GREEN}\$ %s${C_RESET}\n" "$1"
    bash -c "$1" 2>&1 | sed 's/^/    /'
}

# Пауза до нажатия клавиши
pause_key() {
    echo ""
    printf "${C_YELLOW}%s${C_RESET}" "${1:-Нажми любую клавишу, чтобы продолжить...}"
    read -n 1 -s -r
    echo ""
}
