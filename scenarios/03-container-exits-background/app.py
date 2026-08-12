#!/usr/bin/env python3
"""
Нормальный долгоживущий сервис: работает бесконечно, пишет heartbeat.
Само приложение исправно — проблема не в нём, а в том, КАК его запускают
(см. entrypoint.sh: его стартуют в фоне, из-за чего PID 1 завершается).
"""
import time
import sys

def main():
    print("demo-service: запущен, начинаю работу", flush=True)
    while True:
        print("heartbeat: сервис жив", flush=True)
        time.sleep(5)

if __name__ == "__main__":
    main()
