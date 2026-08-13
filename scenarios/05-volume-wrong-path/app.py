#!/usr/bin/env python3
"""
Приложение хранит простое состояние: список записей в файле.
Поддерживает две команды:
  - add <текст>  : добавить запись в хранилище
  - list         : показать все записи

"""
import sys

DATA_FILE = "data.db"


def add(text):
    with open(DATA_FILE, "a") as f:
        f.write(text + "\n")
    print(f"добавлено: {text}", flush=True)


def list_entries():
    try:
        with open(DATA_FILE) as f:
            data = f.read().strip()
    except FileNotFoundError:
        data = ""
    if data:
        print("записи в хранилище:", flush=True)
        for line in data.splitlines():
            print(f"  - {line}", flush=True)
    else:
        print("хранилище пусто", flush=True)


if __name__ == "__main__":
    if len(sys.argv) >= 3 and sys.argv[1] == "add":
        add(" ".join(sys.argv[2:]))
    elif len(sys.argv) >= 2 and sys.argv[1] == "list":
        list_entries()
    else:
        print("использование: app.py add <текст> | list", flush=True)
        sys.exit(1)
