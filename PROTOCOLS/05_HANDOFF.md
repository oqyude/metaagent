# Протокол 05: Передача исполнительному агенту (HANDOFF)

## Цель

Подготовить и передать исполнительному агенту полный контекст для работы: задачи, окружение, правила.

## Вход

- `.agent/context/analysis-report.md`
- `.agent/context/design-report.md` (опционально, для greenfield)
- `.agent/decisions/*.md` (опционально)
- `.agent/context/risk-register.md` (опционально)
- `.agent/context/red-team-report.md` (опционально)
- `.agent/tasks/manifest.json`
- `.agent/tasks/manifest.md`
- `.agent/context/baseline-test-report.log`
- `.agent/checkpoints.json` (все предыдущие фазы: completed)

## Шаги

### 5.1. Архивация завершённых артефактов

Перед валидацией и передачей выполнить архивирование.

**Архивировать завершённые задачи:**

Для каждой задачи в `.agent/tasks/manifest.json` со статусом `completed`:
1. Создать `.agent/archive/tasks/<id>.json` — перенести полное описание задачи (все поля)
2. В `.agent/tasks/manifest.json` заменить задачу на one-liner:
   ```json
   { "id": "<id>", "title": "<title>", "status": "archived" }
   ```

**Архивировать чекпоинты:**

Если `checkpoints.json` уже существует — сохранить предыдущую версию в `.agent/archive/checkpoints/<last_updated>.json`.

**Создать индекс архива:**

```json
{
  "version": "1.1.0",
  "archived_at": "<timestamp>",
  "tasks": [
    { "id": "T1", "title": "...", "archived_at": "<timestamp>" }
  ],
  "checkpoints": [
    { "file": "checkpoints/2026-07-15T10-00-00.json", "archived_at": "<timestamp>" }
  ]
}
```

### 5.2. Валидация

Перед передачей проверить:

- [ ] Все фазы отмечены как `completed` в checkpoints.json
- [ ] `.agent/` содержит все обязательные файлы:
  - `checkpoints.json`
  - `context/analysis-report.md`
  - `tasks/manifest.json` + `tasks/manifest.md`
  - `context/baseline-test-report.log`
  - `context/setup-report.log`
  - `src/META_AGENT_GUIDE.md`
  - `src/BOUNDARIES.md`
  - `src/VERSION`
  - `src/PROTOCOLS/`
  - `src/TEMPLATES/`
  - `rules/project-rules.md`
  - `archive/index.json`
- [ ] Для greenfield: `context/design-report.md` присутствует
- [ ] В `.agent/tasks/manifest.json` нет циклических зависимостей
- [ ] Все acceptance criteria сформулированы измеримо
- [ ] Для каждой задачи указаны affected files
- [ ] В репозитории нет незакоммиченных изменений (кроме `.agent/`)
- [ ] `.agent/src/` содержит актуальные исходники MetaAgent (META_AGENT_GUIDE.md, PROTOCOLS/, TEMPLATES/, BOUNDARIES.md, VERSION)
- [ ] `AGENTS.md` присутствует в корне репозитория
- [ ] `.agent/rules/` содержит `project-rules.md`

**Дополнительные проверки (если config включает):**
- [ ] ADR присутствуют (если adr=yes)
- [ ] Risk Register заполнен (если risk_register=yes)
- [ ] Red Team Report есть (если red_team=yes)
- [ ] Invariant-задачи в манифесте (если invariant_tests=yes)

### 5.3. Структура .agent/

Артефакты организуются по фиксированной семантической структуре (layer-структура больше не используется):

```
.agent/
  checkpoints.json              # состояние сессии (ядро)
  session-summary.md            # краткая сводка сессии
  decisions/                    # архитектурные решения (ADR)
    index.json                  # машинночитаемый индекс
    001-решение.md
  tasks/                        # задачи
    manifest.json               # машинночитаемый манифест
    manifest.md                 # человекочитаемый
    backlog/                    # задачи вне спринта
  context/                      # контекст проекта
    analysis-report.md
    design-report.md
    risk-register.md
    red-team-report.md          # (опционально)
    baseline-test-report.log
    setup-report.log
  rules/                        # правила проекта
    project-rules.md
  archive/                      # архив
    index.json
    tasks/
    decisions/
    checkpoints/
```

### 5.4. Создать handoff-summary.md

Заполнить по шаблону `TEMPLATES/handoff-summary.md`:

- **Session Info** — ID, цель, дата
- **Configuration** — какие функции были включены, глубина
- **Repo Summary** — краткая выжимка из analysis-report
- **Environment Status** — результат сборки и тестов
- **Design Summary** (если есть design-report) — ключевые архитектурные решения
- **ADR Summary** (если adr=yes) — какие решения задокументированы
- **Risk Register** (если risk_register=yes) — основные допущения
- **Task Overview** — количество задач, типы, список
- **Next Steps** — с какой задачи начинать исполнительному агенту
- **Project Rules** — ссылка на `.agent/rules/project-rules.md` (передаётся exec-агенту)
- **Archive** — ссылка на `.agent/archive/index.json` (история завершённых задач)
- **Caveats** — известные проблемы, ограничения, неясные моменты
- **Checkpoints** — актуальное состояние чекпоинтов

### 5.5. Финализировать checkpoints

- Отметить `phases.handoff = "completed"`
- Записать финальный `last_updated`

### 5.6. Сигнал

Сообщить пользователю/оркестратору:

```
HANDOFF COMPLETE

Session: <session_id>
Target: <target_repo>
Type: <existing | greenfield | scaffold>
Config: depth=<N>, adr=<yes|no>, red_team=<yes|no>, ...
Tasks: <count> tasks ready

Исполнительный агент может начинать с задачи <T1>.
Контекст: .agent/handoff-summary.md
Манифест: .agent/tasks/manifest.json
```

## Что получает исполнительный агент

1. **Целевой репозиторий** — полностью настроенный, с установленными зависимостями
2. **`.agent/`** — директория со всеми артефактами (семантическая структура)
3. **`.agent/tasks/manifest.json`** — машиночитаемый список задач
4. **`.agent/tasks/manifest.md`** — человекочитаемый список задач
5. **`.agent/handoff-summary.md`** — итоговая сводка
6. **`.agent/checkpoints.json`** — актуальное состояние (исполнительный агент будет его обновлять)
7. **`.agent/decisions/*.md`** (опционально) — ключевые решения (ADR)
8. **`.agent/context/risk-register.md`** (опционально) — допущения
9. **`.agent/context/analysis-report.md`** — полный анализ репозитория (справочно)
10. **`.agent/context/design-report.md`** (только для greenfield) — архитектурный план
11. **`.agent/context/baseline-test-report.log`** — baseline тестов (чтобы не сломать существующее)
12. **`.agent/src/`** — полные исходники MetaAgent (справочно, всегда присутствуют)
13. **`.agent/rules/`** — пользовательские правила проекта
14. **`AGENTS.md`** — инструкция для AI-агента в корне проекта (всегда присутствует)
15. **`.agent/archive/`** — архив завершённых задач, чекпоинтов и устаревших артефактов

## Выход

- `.agent/session-summary.md`
- `.agent/handoff-summary.md`
- `.agent/checkpoints.json` (финальный)
- `.agent/archive/index.json` (создаётся при архивации)

## Критерии завершения

- [ ] Все артефакты на месте (согласно структуре .agent/)
- [ ] `.agent/src/` содержит актуальные исходники MetaAgent
- [ ] `.agent/rules/` содержит `project-rules.md`
- [ ] `AGENTS.md` присутствует в корне репозитория
- [ ] `.agent/archive/index.json` создан, завершённые задачи архивированы
- [ ] handoff-summary.md заполнен (включая config, design summary, ADR summary, archive)
- [ ] checkpoints.json финализирован
- [ ] Сигнал отправлен пользователю/оркестратору
