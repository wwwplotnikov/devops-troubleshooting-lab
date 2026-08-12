#!/usr/bin/env python3
"""
Простое приложение, которому для старта нужен адрес БД из переменной
окружения DB_HOST (типичный паттерн 12-factor: конфиг через окружение).

Если DB_HOST не задан — приложение не может работать и падает с ошибкой
(exit 1). В связке с restart-политикой это даёт цикл перезапусков.
"""
import os
import sys
import time

def main():
    db_host = os.environ.get("DB_HOST")

    if not db_host:
        # Внятная ошибка в stderr — она попадёт в docker logs
        print(
            "FATAL: переменная окружения DB_HOST не задана. "
            "Приложение не может подключиться к базе и завершается.",
            file=sys.stderr,
            flush=True,
        )
        sys.exit(1)

    # "Нормальная" работа: если переменная есть — живём и пишем heartbeat
    print(f"OK: подключаюсь к базе по адресу DB_HOST={db_host}", flush=True)
    print("Приложение запущено и работает.", flush=True)
    while True:
        print("heartbeat: сервис жив", flush=True)
        time.sleep(10)


if __name__ == "__main__":
    main()
