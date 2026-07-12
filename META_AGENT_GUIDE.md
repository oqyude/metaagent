# META_AGENT_GUIDE — Главная инструкция

## Жизненный цикл сессии

```
INIT → ANALYSE → [DESIGN] → DECOMPOSITION → SETUP → (CHECKPOINT)* → HANDOFF → EXIT
```

Фазы выполняются **строго последовательно**. Фаза DESIGN выполняется только если тип проекта — `greenfield` или `scaffold`. Каждая фаза порождает артефакты в `.agent/` целевого репозитория.

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
  "project_type": "pending",
  "phases": {
    "analysis": "pending",
    "design": "pending",
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
- Выполнить анализ репозитория по протоколу (определяет тип проекта)
- Записать результат в `.agent/analysis-report.md`
- Обновить checkpoints.json: `phases.analysis = "completed"`, `project_type = "existing" | "greenfield" | "scaffold"`

**Выход:** `.agent/analysis-report.md`

**Ветвление:** если `project_type = "greenfield"` или `"scaffold"` → далее фаза DESIGN. Если `"existing"` → DESIGN пропускается, сразу DECOMPOSITION.

---

## Фаза 2: DESIGN (условная)

**Вход:** analysis-report.md, checkpoints.json (analysis: completed, project_type: greenfield/scaffold).

**Протокол:** `PROTOCOLS/02_DESIGN.md`

**Действия:**
- Спроектировать архитектуру, модули, данные, интерфейсы
- Записать результат в `.agent/design-report.md`
- Обновить checkpoints.json: `phases.design = "completed"`

**Выход:** `.agent/design-report.md`

---

## Фаза 3: DECOMPOSITION

**Вход:** analysis-report.md + опционально design-report.md + checkpoints.json (design: completed либо analysis: completed для existing).

**Протокол:** `PROTOCOLS/03_DECOMPOSITION.md`

**Действия:**
- Выполнить декомпозицию цели (и дизайна, если есть) по протоколу
- Записать манифест в `.agent/task-manifest.json` и `.agent/task-manifest.md`
- Обновить checkpoints.json: `phases.decomposition = "completed"`, заполнить `tasks`

**Выход:** `.agent/task-manifest.json`, `.agent/task-manifest.md`

---

## Фаза 4: SETUP

**Вход:** analysis-report.md, design-report.md (опционально), task-manifest.json, checkpoints.json (decomposition: completed).

**Протокол:** `PROTOCOLS/04_ENVIRONMENT_SETUP.md`

**Действия:**
- Выполнить настройку окружения по протоколу (ветка A для existing, ветка B для greenfield)
- Записать результат проверки в `.agent/baseline-test-report.log` и `.agent/setup-report.log`
- Обновить checkpoints.json: `phases.environment = "completed"`

**Выход:** рабочее окружение + `.agent/baseline-test-report.log`

---

## Фаза 5: CHECKPOINT (сквозная)

**Вход:** любая фаза.

**Протокол:** обновлять checkpoints.json после каждого значимого шага.

**Формат:**

```json
{
  "session_id": "<uuid>",
  "target_repo": "<path>",
  "goal": "<цель>",
  "project_type": "existing | greenfield | scaffold",
  "phases": {
    "analysis": "completed",
    "design": "completed",
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

## Фаза 6: HANDOFF

**Вход:** все предыдущие фазы completed.

**Протокол:** `PROTOCOLS/05_HANDOFF.md`

**Действия:**
- Выполнить передачу по протоколу
- Записать `.agent/handoff-summary.md`
- Обновить checkpoints.json: `phases.handoff = "completed"`
- Сообщить пользователю/оркестратору: "Исполнительный агент готов к работе"

**Выход:** `.agent/handoff-summary.md` — итоговый документ для исполнительного агента.

---

## Фаза 7: EXIT

Мета-агент завершает работу. Управление переходит к исполнительному агенту.
