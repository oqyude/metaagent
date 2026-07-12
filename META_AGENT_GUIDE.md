# META_AGENT_GUIDE — Главная инструкция

## Жизненный цикл сессии

```
INIT → ANALYSE → PLAN → SETUP → CHECKPOINT → HANDOFF → EXIT
```

Фазы выполняются **строго последовательно**. Каждая фаза порождает артефакты в `.agent/` целевого репозитория.

---

## Фаза 0: INIT

**Вход:** целевой репозиторий (путь/URL) + цель от пользователя.

**Действия:**
- Склонировать/открыть целевой репозиторий
- Прочитать `PROTOCOLS/01_ANALYSIS.md`
- Создать директорию `.agent/` в корне целевого репозитория
- Инициализировать `.agent/checkpoints.json`

```json
{
  "session_id": "<uuid>",
  "target_repo": "<path>",
  "goal": "<цель от пользователя>",
  "phases": {
    "analysis": "pending",
    "decomposition": "pending",
    "environment": "pending",
    "handoff": "pending"
  },
  "tasks": [],
  "last_updated": "<timestamp>"
}
```

**Выход:** готовая `.agent/` + актуальный checkpoints.json.

---

## Фаза 1: ANALYSE

**Вход:** целевой репозиторий, checkpoints.json (analysis: pending).

**Протокол:** `PROTOCOLS/01_ANALYSIS.md`

**Действия:**
- Выполнить анализ репозитория по протоколу
- Записать результат в `.agent/analysis-report.md`
- Обновить checkpoints.json: `phases.analysis = "completed"`

**Выход:** `.agent/analysis-report.md`

---

## Фаза 2: PLAN

**Вход:** analysis-report.md, цель пользователя, checkpoints.json (analysis: completed).

**Протокол:** `PROTOCOLS/02_DECOMPOSITION.md`

**Действия:**
- Выполнить декомпозицию цели по протоколу
- Записать манифест в `.agent/task-manifest.json` и `.agent/task-manifest.md`
- Обновить checkpoints.json: `phases.decomposition = "completed"`, заполнить `tasks`

**Выход:** `.agent/task-manifest.json`, `.agent/task-manifest.md`

---

## Фаза 3: SETUP

**Вход:** analysis-report.md, task-manifest.json, checkpoints.json (decomposition: completed).

**Протокол:** `PROTOCOLS/03_ENVIRONMENT_SETUP.md`

**Действия:**
- Выполнить настройку окружения по протоколу
- Записать результат проверки в `.agent/baseline-test-report.log`
- Обновить checkpoints.json: `phases.environment = "completed"`

**Выход:** рабочее окружение + `.agent/baseline-test-report.log`

---

## Фаза 4: CHECKPOINT (сквозная)

**Вход:** любая фаза.

**Протокол:** обновлять checkpoints.json после каждого значимого шага.

**Формат:**

```json
{
  "session_id": "<uuid>",
  "target_repo": "<path>",
  "goal": "<цель>",
  "phases": {
    "analysis": "completed",
    "decomposition": "in_progress",
    "environment": "pending",
    "handoff": "pending"
  },
  "tasks": [
    { "id": "T1", "title": "...", "status": "completed",
      "depends_on": [], "acceptance_criteria": ["..."] },
    { "id": "T2", "title": "...", "status": "pending",
      "depends_on": ["T1"], "acceptance_criteria": ["..."] }
  ],
  "last_updated": "<timestamp>"
}
```

`status` может быть: `pending`, `in_progress`, `completed`, `failed`, `skipped`.

---

## Фаза 5: HANDOFF

**Вход:** все предыдущие фазы completed.

**Протокол:** `PROTOCOLS/04_HANDOFF.md`

**Действия:**
- Выполнить передачу по протоколу
- Записать `.agent/handoff-summary.md`
- Обновить checkpoints.json: `phases.handoff = "completed"`
- Сообщить пользователю/оркестратору: "Исполнительный агент готов к работе"

**Выход:** `.agent/handoff-summary.md` — итоговый документ для исполнительного агента.

---

## Фаза 6: EXIT

Мета-агент завершает работу. Управление переходит к исполнительному агенту.
