# DevOps Troubleshooting Lab

Набор воспроизводимых инфраструктурных инцидентов. Каждый контейнер
поднимается уже сломанным. Учебный полигон для отработки troubleshooting в Docker, Linux
и сетях.

## Как пользоваться

```bash
cd scenarios/01-container-refused
./start.sh   # поднимает контейнер сломанным и показывает симптом
./fix.sh     # разбор по шагам
```

`start.sh` показывает проблему. `fix.sh` чинит и в конце возвращает лабу
в исходное состояние. Все команды выполняются внутри контейнера через
`docker exec`, хост не затрагивается.

## Сценарии

| # | Инцидент | Область | Навык |
|---|----------|---------|-------|
| 01 | Connection refused на проброшенном порту | Docker, сеть | bind 127.0.0.1 vs 0.0.0.0, network namespace |
| 02 | Контейнер в цикле перезапусков | Docker | docker logs, exit codes, переменные окружения |
| 03 | Контейнер сразу завершается с exit 0 | Docker | PID 1, foreground vs background, exec |
| 04 | Контейнер убивает OOM killer (exit 137) | Linux, память | OOMKilled, exit 137, cgroup memory limit, dmesg |

## Требования

* Linux
* Docker Engine с плагином docker compose (v2)

## Структура

```
troubleshooting-lab/
├── lib.sh                  общие функции вывода
└── scenarios/
    └── NN-название/
        ├── Dockerfile
        ├── docker-compose.yml
        ├── start.sh        поднять сломанным, показать симптом
        └── fix.sh          разбор, починка, очистка
```
