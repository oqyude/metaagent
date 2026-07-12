# Протокол 04: Передача исполнительному агенту (HANDOFF)

## Цель

Подготовить и передать исполнительному агенту полный контекст для работы: задачи, окружение, правила.

## Вход

- `.agent/analysis-report.md`
- `.agent/task-manifest.json`
- `.agent/task-manifest.md`
- `.agent/baseline-test-report.log`
- `.agent/checkpoints.json` (все предыдущие фазы: completed)

## Шаги

### 4.1. Валидация

Перед передачей проверить:

- [ ] Все фазы (analysis, decomposition, environment) отмечены как `completed` в checkpoints.json
- [ ] `.agent/` содержит все обязательные файлы:
  - `checkpoints.json`
  - `analysis-report.md`
  - `task-manifest.json` + `task-manifest.md`
  - `baseline-test-report.log`
  - `setup-report.log`
- [ ] В task-manifest.json нет циклических зависимостей
- [ ] Все acceptance criteria сформулированы измеримо
- [ ] Для каждой задачи указаны affected files
- [ ] В репозитории нет незакоммиченных изменений (кроме `.agent/`)

### 4.2. Создать handoff-summary.md

Заполнить по шаблону `TEMPLATES/handoff-summary.md`:

- **Session Info** — ID, цель, дата
- **Repo Summary** — краткая выжимка из analysis-report
- **Environment Status** — результат сборки и тестов
- **Task Overview** — количество задач, типы, список
- **Next Steps** — с какой задачи начинать исполнительному агенту
- **Caveats** — известные проблемы, ограничения, неясные моменты
- **Checkpoints** — актуальное состояние чекпоинтов

### 4.3. Финализировать checkpoints

- Отметить `phases.handoff = "completed"`
- Записать финальный `last_updated`

### 4.4. Сигнал

Сообщить пользователю/оркестратору:

```
HANDOFF COMPLETE

Session: <session_id>
Target: <target_repo>
Tasks: <count> tasks ready

Исполнительный агент может начинать с задачи <T1>.
Контекст: .agent/handoff-summary.md
Манифест: .agent/task-manifest.json
```

## Что получает исполнительный агент

1. **Целевой репозиторий** — полностью настроенный, с установленными зависимостями
2. **`.agent/`** — директория со всеми артефактами
3. **`task-manifest.json`** — машиночитаемый список задач
4. **`task-manifest.md`** — человекочитаемый список задач
5. **`handoff-summary.md`** — итоговая сводка
6. **`checkpoints.json`** — актуальное состояние (исполнительный агент будет его обновлять)
7. **`analysis-report.md`** — полный анализ репозитория (справочно)
8. **`baseline-test-report.log`** — baseline тестов (чтобы не сломать существующее)

## Выход

- `.agent/handoff-summary.md`
- checkpoints.json (финальный)

## Критерии завершения

- [ ] Все артефакты на месте
- [ ] handoff-summary.md заполнен
- [ ] checkpoints.json финализирован
- [ ] Сигнал отправлен пользователю/оркестратору
