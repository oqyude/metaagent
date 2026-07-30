# 002: Agent coordination — сервер, heavy/light режимы, standby

## Проблема

В multi-agent архитектуре (001) взаимодействие между orchestrator и executor-ами
идёт через файловую систему: `task-manifest.json`, `workers.json`, lock-файлы.

Это работает, но:
- Нет push-уведомлений — executor-ы должны polling-ить файлы
- Race conditions — lock-файлы решают, но добавляют сложность
- Keepalive — нельзя отличить упавшего worker от медленного
- Wake-up — executor не может ждать задачу «лёжа», не расходуя ресурсы
- Пользователь — привязка к чату для активации/освобождения

## Идея

Лёгкий внутренний сервер внутри `.agent/`, который координирует агентов
через локальный канал связи. Сервер — единственный источник правды
по состоянию задач, workers, блокировок.

Executor может встать в цикл ожидания в рамках одной сессии:
`REGISTER → loop { WAIT → CLAIM → EXECUTE → DONE } → RELEASE`.
Сессия жива, compute минимален (1 запрос / N сек в idle).

## Режимы coordination

### Light (режим по умолчанию)

```
orchestrator → ANALYSIS → DESIGN → DECOMPOSITION → DISTRIBUTION → HANDOFF
executor:     claim → execute → complete → exit (сессия завершается)
```

- Нет сервера
- Executor завершается после последней задачи
- orchestrator опционален — задачи можно взять вручную
- Для depth 1-6 (scaffold, light, standard)

### Heavy (режим с сервером)

```
orchestrator → ANALYSIS → DESIGN → DECOMPOSITION → DISTRIBUTION → запуск сервера → WAIT
executor:     REGISTER → loop { WAIT → CLAIM → EXECUTE → DONE } → RELEASE
сервер:       координирует, push-уведомления, keepalive
```

- Сервер стартует orchestrator-ом на DISTRIBUTION
- Executor живёт в одной сессии: получил задачу → выполнил → ждёт
- orchestrator шлёт команды через сервер (assign, release, stop)
- Сервер завершается на HANDOFF или когда все workers отключились
- Для depth 7+ (deep, maximum)

## Lifecycle executor в heavy режиме

```
сессия executor (одна, живёт весь lifecycle)
  │
  │  1. REGISTER
  ▼
  ┌─────────────────────────────┐
  │  loop:                      │
  │    → server: STATUS         │
  │    ← server: IDLE           │
  │    → SLEEP 30s              │  ← минимальный compute
  │    → loop                   │
  └─────────────────────────────┘
          │ server: CLAIM T1
          ▼
  ┌─────────────────────────────┐
  │  execute task               │  ← ресурсоёмко
  │    → server: DONE T1        │
  └─────────────────────────────┘
          │
          ▼ loop (ждёт следующую)

          │ server или user: RELEASE
          ▼
  ┌─────────────────────────────┐
  │  доводит задачу (если есть) │
  │  workers.json → released    │
  │  exit                       │
  └─────────────────────────────┘
```

### Что не расходуется в idle

- Контекст: в idle сессия делает один запрос `STATUS` раз в 30 секунд
- Compute: `SLEEP` — это tool call, который не требует генерации
- Модель: не думает, не генерирует код, не анализирует — просто ждёт

## Сервер

### Где живёт

В `.agent/src/server/`. Копируется при `install.sh` вместе с остальными
исходниками MetaAgent. Запускается orchestrator-ом.

### Запуск

```bash
# orchestrator после DISTRIBUTION:
.start_agent_server(port=9876)

# executor при старте:
.connect_agent_server("ws://localhost:9876")
```

### Протокол (минимальный, текстовый)

```
→ REGISTER worker-1
← OK status=idle

→ STATUS
← IDLE | TASK { "id": "T1", ... }

→ CLAIM
← GRANTED { "id": "T1", "files": [...] }
  | DENIED "reason"

→ DONE T1
← OK

→ RELEASE
← OK

→ HEARTBEAT
← OK
```

### Язык

Открытый вопрос (TBD). Варианты:

| Язык | Плюсы | Минусы |
|------|-------|--------|
| **Python** | Есть почти везде, asyncio, простой | Не везде pre-installed |
| **Node** | WebSocket нативно, event-driven | Нужен npm, node_modules |
| **Shell + nc** | Нет зависимостей | Примитивно, нет state |

## Standby / checkpoint

Если executor хочет уйти в ноль по cost, но не прерывать сессию целиком:

1. Сохранить состояние в `.agent/standby/<worker-id>/checkpoint.json`
2. Закрыть сессию (0 cost)
3. Когда orchestrator/сервер назначает задачу — пишет
   `.agent/standby/<worker-id>/wake.json`
4. Новая сессия executor читает `wake.json`, подхватывает checkpoint,
   продолжает

### checkpoint.json

```json
{
  "worker_id": "worker-1",
  "last_task_id": "T1",
  "last_status": "completed",
  "context_summary": "Выполнил модель User, ожидает задачу T2",
  "updated_at": "2026-07-16T12:00:00Z"
}
```

### wake.json

```json
{
  "task_id": "T2",
  "assigned_at": "2026-07-16T12:05:00Z",
  "from_orchestrator": true
}
```

## Связь с 001

`002-agent-coordination.md` является зависимостью 001 multi-agent workers.
Без канала связи multi-agent работает только в light режиме (каждый executor
отдельная сессия).

## Открытые вопросы

- **Язык сервера** — Python vs Node vs shell (TBD)
- **Защита порта** — два проекта на одной машине → конфликт портов?
- **Авто-стоп** — сервер завершается по таймауту если все workers disconnected?
- **Логи** — пишет ли сервер в `.agent/archive/server-logs/`?
- **Безопасность** — только localhost, но что если вредоносный процесс на машине?

## Зависимости

- Необходима реализация 001 (multi-agent workers)
- Новый протокол `PROTOCOLS/08_COORDINATION.md`
- Новый протокол `PROTOCOLS/09_SERVER.md`
- Изменение `metaagent-request.md` — поле `coordination.mode`
- Изменение `checkpoints.json` — статусы server
- `.agent/src/server/` — директория с сервером
