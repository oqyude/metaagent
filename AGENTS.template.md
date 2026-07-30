# MetaAgent

Этот проект использует [MetaAgent](.agent/src/META_AGENT_GUIDE.md) v{VERSION} —
набор инструкций для AI-агента.

## Контекст MetaAgent

| Ресурс | Путь |
|--------|------|
| Главная инструкция | `.agent/src/META_AGENT_GUIDE.md` |
| Протоколы фаз | `.agent/src/PROTOCOLS/` |
| Шаблоны артефактов | `.agent/src/TEMPLATES/` |
| Границы (что разрешено/запрещено) | `.agent/src/BOUNDARIES.md` |
| Правила проекта | `.agent/rules/project-rules.md` |
| Примеры работы | `.agent/src/WORKFLOW.md` |
| Версия | `.agent/src/VERSION` |

## Состояние проекта

| Артефакт | Путь |
|----------|------|
| Чекпоинты сессии | `.agent/checkpoints.json` |
| Манифест задач | `.agent/tasks/manifest.json` |
| Сводка для следующей сессии | `.agent/handoff-summary.md` |
| Слепок проекта | `.agent/context/project-state.md` |
| Анализ репозитория | `.agent/context/analysis-report.md` |
| Дорожная карта | `.agent/roadmap/sources.md` |
| Реестр запросов (pending) | `.agent/requests/active/` |
| Реестр запросов (archive) | `.agent/requests/archive/` |

## Для агента

Жизненный цикл MetaAgent v2.1:

```
INIT → ANALYSE → ROADMAP → DESIGN → DECOMPOSITION → EXECUTION → METASTATE → HANDOFF
```

1. **Прочитай** `.agent/src/META_AGENT_GUIDE.md` — пойми жизненный цикл MetaAgent.
2. **Прочитай** `.agent/src/BOUNDARIES.md` — соблюдай границы.
3. **Прочитай** `.agent/rules/project-rules.md` — выполни пользовательские правила.
4. **Проверь** `.agent/checkpoints.json` — если существует, используй как состояние сессии.
5. **Проверь** `.agent/tasks/manifest.json` — если существует, выполняй задачи по порядку.
6. **Проверь** `.agent/context/project-state.md` — получи актуальную картину проекта.
7. **Проверь** `.agent/requests/active/` — если есть незакрытые requests, начни с METASTATE.
8. Если `.agent/` не инициализирован или устарел — запусти `install.sh --update` (Unix) или `install.ps1 -Update` (Windows) для обновления исходников MetaAgent до актуальной версии.
