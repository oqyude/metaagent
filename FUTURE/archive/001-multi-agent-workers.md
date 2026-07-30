# 001: Multi-agent workers — роли сессий и параллельное исполнение

## Проблема

Сейчас MetaAgent — это single-agent pipeline: одна сессия = один агент, который
последовательно анализирует, проектирует, декомпозирует и реализует.

- Нельзя параллелить независимые задачи
- Контекст одного агента переполняется при большом числе задач
- Нет разграничения: кто планирует, тот и пишет код — смешение ролей

## Решение

Две роли сессии — **orchestrator** (только план) и **executor** (только код).

Пользователь при запуске сессии объявляет роль:
- `role: orchestrator` — полный цикл MetaAgent, но без написания кода.
  Анализ → дизайн → декомпозиция → распределение → handoff.
- `role: executor` — занимает свободный слот в `workers.json`,
  читает `task-manifest.json`, берёт задачу, выполняет, отмечает завершённой.

## Сценарий

```
Session 1: "я orchestrator"      → orchestrator (plan + distribute)
Session 2: "я executor"           → executor (авто-ID: worker-1)
Session 3: "я executor"           → executor (авто-ID: worker-2)
...
User: "освободи рабочего"         → executor доводит задачу → released
```

## Ключевые компоненты

### 1. Новая фаза DISTRIBUTION (только для orchestrator)

После DECOMPOSITION, перед HANDOFF.

1. Проанализировать `task-manifest.json`: какие задачи независимы,
   какие имеют пересечения по `files`
2. Разложить задачи по пулам:
   - Независимые (без пересечения `files`) → параллельные
   - Конфликтующие по `files` → последовательные (одна за другой)
3. Создать `.agent/workers.json` — пустой реестр, N idle слотов
4. Установить `claimable: true` на задачах, готовых к взятию

### 2. Task ownership с lock-файлами

```json
{
  "id": "T1",
  "title": "Добавить модель User",
  "status": "pending",
  "type": "feature",
  "files": ["app/models/user.py"],
  "depends_on": [],
  "acceptance_criteria": ["..."],
  "claimed_by": null,
  "claimed_at": null
}
```

Executor при старте:
1. Регистрируется в `.agent/workers.json` (первый idle слот → active)
2. Ищет в `task-manifest.json`:
   - `status: pending`
   - `claimed_by: null`
   - все `depends_on` выполнены (status: completed или archived)
3. Создаёт `.agent/locks/<task_id>.lock` со своим `worker_id`
   - Если файл уже существует → задача занята → ищет другую
4. Пишет: `claimed_by: "worker-1"`, `claimed_at: "<timestamp>"`,
   `status: "in_progress"`
5. Re-read: если `claimed_by` не его — lock проигран, отпускает,
   ищет другую задачу
6. Исполняет
7. По завершению: `status: "completed"`, удаляет lock-файл

### 3. Реестр workers (`.agent/workers.json`)

```json
{
  "workers": [
    {
      "id": "worker-1",
      "status": "active",
      "task_id": "T1",
      "started_at": "2026-07-16T12:00:00Z"
    },
    {
      "id": "worker-2",
      "status": "idle",
      "task_id": null,
      "started_at": null
    }
  ]
}
```

Статусы worker: `idle` → `active` → `completed` | `released` | `failed`

### 4. Зависимости задач

Executor берёт только задачи, у которых все `depends_on` выполнены.
Если таких нет — `workers.json` → `completed`. Orchestrator видит,
что executor-ы завершились, инициирует HANDOFF.

### 5. Файловые конфликты

**На уровне DISTRIBUTION** — orchestrator изолирует задачи:
- Проверяет `files` у каждой задачи
- Если два `files` пересекаются — задачи не могут быть параллельными
- Конфликтующие задачи получают `depends_on` друг на друга

**На уровне executor** — если конфликт всё же возник:
- Worker замечает, что его `files` пересекаются с `files` другой
  active-задачи
- Отмечает конфликт в отчёте
- Orchestrator при HANDOFF анализирует и разрешает

### 6. Failure handling

Executor не может завершить задачу:
- Пишет `status: "failed"`, `reason: "..."` в `task-manifest.json`
- Ставит себе `status: "failed"` в `workers.json`
- Orchestrator на HANDOFF видит failed задачи и решает:
  перераспределить, запросить пользователя, откатить

### 7. User control (interrupt / release)

Пользователь говорит агенту «освободи тебя»:
1. Executor видит команду
2. Меняет `status: "stopping"` в `workers.json`
3. Доводит текущую задачу до логического прерывания
   (сохраняет прогресс, ставит задаче `status: "paused"`)
4. Ставит себе `status: "released"`
5. Завершает сессию

### 8. Изоляция сессий

- Executor читает только: `task-manifest.json`, `workers.json`,
  `BOUNDARIES.md`, `.agent/rules/`, `.agent/src/` (справочно)
- Executor пишет только: `claimed_by`, `claimed_at`, `status` в задачах,
  свой статус в `workers.json`, lock-файлы
- Все артефакты сессии (ADR, reports, design) — read-only для executor
- Два executor не могут взять одну задачу — lock-файл исключает

## Открытые вопросы (отложены)

- **Keepalive / heartbeat** — как отличать упавшего worker от медленного
- **Notification** — как executor оповещает orchestrator о завершении
- **Приоритеты** — если задач больше чем workers, кто выбирает порядок
- **Глубина** — при depth 1-2 (scaffold) workers не нужны, только orchestrator
- **Archive при параллельной работе** — кто и когда архивирует

## Зависимости

- Новый протокол `PROTOCOLS/06_DISTRIBUTION.md`
- Новый протокол `PROTOCOLS/07_WORKER.md`
- Изменение `metaagent-request.md` — поле `role: orchestrator | executor`
- Изменение `checkpoints.json` — поддержка worker-статусов
- Изменение `task-manifest.json` — поля `claimed_by`, `claimed_at`
- Новый `.agent/locks/` — директория для lock-файлов задач
- `.agent/workers.json` — реестр workers (создаётся orchestrator-ом)
