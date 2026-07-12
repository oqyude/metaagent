# WORKFLOW — Сквозной пример сессии

## Сценарий

**Цель:** Добавить в существующий FastAPI-проект ручку GET /health с тестами.

**Целевой репозиторий:** `github.com/example/fastapi-app`

**Пользователь:** "Добавь health-check endpoint и тесты к нему"

---

## Фаза INIT

Мета-агент клонирует репозиторий, создаёт `.agent/`, пишет начальный чекпоинт:

```json
{
  "session_id": "ses_abc123",
  "target_repo": "/tmp/fastapi-app",
  "goal": "Добавить GET /health с тестами",
  "phases": {
    "analysis": "pending",
    "decomposition": "pending",
    "environment": "pending",
    "handoff": "pending"
  },
  "tasks": [],
  "last_updated": "2026-07-12T15:00:00Z"
}
```

---

## Фаза ANALYSE

Мета-агент выполняет `PROTOCOLS/01_ANALYSIS.md`.

Результат `.agent/analysis-report.md`:

```markdown
## 2. Стек технологий
| Язык | Python 3.12 |
| Фреймворк | FastAPI |
| Тестовый раннер | pytest + httpx |
| Пакетный менеджер | pip + requirements.txt |

## 3. Архитектура
├── app/
│   ├── main.py
│   ├── routers/
│   │   └── users.py
│   ├── models/
│   │   └── user.py
│   └── schemas/
│       └── user.py
├── tests/
│   └── test_users.py
```

Тесты запущены: **12 passed, 0 failed**.

Чекпоинт обновлён: `analysis = "completed"`.

---

## Фаза PLAN

Мета-агент выполняет `PROTOCOLS/02_DECOMPOSITION.md`.

Декомпозиция цели "Добавить GET /health с тестами":

| ID | Задача | Тип | Зависит от | AC |
|---|---|---|---|---|
| T1 | Создать health-check router | feature | — | Ручка возвращает 200 + {"status":"ok"} |
| T2 | Подключить router в main.py | config | T1 | Ручка доступна по /health |
| T3 | Написать тесты для /health | test | T2 | Тесты проверяют 200 и структуру ответа |

Создан `.agent/task-manifest.json` и `.agent/task-manifest.md`.

Чекпоинт обновлён: `decomposition = "completed"`. Tasks: T1-T3 со статусом `pending`.

---

## Фаза SETUP

Мета-агент выполняет `PROTOCOLS/03_ENVIRONMENT_SETUP.md`.

- `pip install -r requirements.txt` — OK
- Запуск pytest — OK, 12 passed (базовый тест)
- Результат в `.agent/baseline-test-report.log`

Чекпоинт обновлён: `environment = "completed"`.

---

## Фаза HANDOFF

Мета-агент выполняет `PROTOCOLS/04_HANDOFF.md`.

Создан `.agent/handoff-summary.md`:

```markdown
## Next Steps
Исполнительный агент начинает с задачи T1: "Создать health-check router".

## Caveats
- Придерживаться стиля существующего роутера users.py
- Не менять существующие тесты
- Убедиться, что response model соответствует JSON: {"status": "ok"}
```

Чекпоинт финализирован:

```json
{
  "session_id": "ses_abc123",
  "goal": "Добавить GET /health с тестами",
  "phases": {
    "analysis": "completed",
    "decomposition": "completed",
    "environment": "completed",
    "handoff": "completed"
  },
  "tasks": [
    { "id": "T1", "title": "Создать health-check router", "status": "pending" },
    { "id": "T2", "title": "Подключить router в main.py", "status": "pending" },
    { "id": "T3", "title": "Написать тесты для /health", "status": "pending" }
  ],
  "last_updated": "2026-07-12T15:15:00Z"
}
```

Сигнал пользователю:

```
HANDOFF COMPLETE
Session: ses_abc123
Target: /tmp/fastapi-app
Tasks: 3 tasks ready

Исполнительный агент может начинать с задачи T1.
```

---

## После HANDOFF: работа исполнительного агента

Исполнительный агент читает `.agent/handoff-summary.md`, `.agent/task-manifest.json`, выполняет задачи по порядку, обновляя checkpoints.json после каждой.

После завершения всех задач исполнительный агент сообщает пользователю:

```
ALL TASKS COMPLETE
Session: ses_abc123
Tasks: 3/3 completed

T1: Создать health-check router ✓
T2: Подключить router в main.py ✓
T3: Написать тесты для /health ✓

Все тесты проходят: 15/15 passed.
```
