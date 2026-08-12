#!/usr/bin/env python3
"""
Простое веб-приложение для лабы.

БАГ (намеренный): приложение слушает на 127.0.0.1 — то есть только
на loopback-интерфейсе ВНУТРИ контейнера. Проброс порта -p доставляет
пакеты на eth0 контейнера, а не на его lo, поэтому снаружи будет
"connection refused", несмотря на корректный -p 8080:8080.

Правильно было бы слушать на 0.0.0.0 (все интерфейсы контейнера).
"""
from http.server import BaseHTTPRequestHandler, HTTPServer

# --- вот здесь баг: 127.0.0.1 вместо 0.0.0.0 ---
BIND_HOST = "127.0.0.1"
BIND_PORT = 8080


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status": "ok", "service": "demo-app"}\n')

    # приглушаем стандартный лог, чтобы не засорять вывод
    def log_message(self, fmt, *args):
        pass


if __name__ == "__main__":
    server = HTTPServer((BIND_HOST, BIND_PORT), Handler)
    print(f"demo-app слушает на {BIND_HOST}:{BIND_PORT}", flush=True)
    server.serve_forever()
