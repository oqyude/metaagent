# MetaAgent

MetaAgent — набор инструкций для AI-агента. Превращает хаотичное общение с агентом в структурированный процесс, в котором состояние проекта переживает любую сессию.

## Модель v3.0: цикл + команды

**Цикл** — последовательность фаз, которую агент проходит при работе с проектом:

```
INIT → ANALYSE → ROADMAP → [DESIGN] → DECOMPOSITION → EXECUTION → METASTATE → HANDOFF
```

DESIGN выполняется только для greenfield/scaffold-проектов. Для existing — пропускается.

**Команды** — on-demand инструкции, которые вызываются по явной просьбе пользователя:

| Команда | Что делает |
|---|---|
| `/adr` | Записать архитектурное решение в `.agent/decisions/` |
| `/red-team` | Попытаться сломать дизайн → `.agent/context/red-team-report.md` |
| `/risk-register` | Реестр допущений → `.agent/context/risk-register.md` |
| `/alt-arch` | Описать альтернативную архитектуру |
| `/invariant-tests` | Тесты-инварианты для ADR |

Команды **не обязательны**. Если не вызваны — не выполняются. Цикл работает без них.

## Что отличает MetaAgent от обычного общения с агентом

| Обычный агент | MetaAgent v3.0 |
|---|---|
| Контекст теряется при каждом новом разговоре | `.agent/` — полный слепок проекта: состояния, решения, задачи, результаты |
| Нет системы — агент действует ad-hoc | Чёткий жизненный цикл: INIT → … → HANDOFF |
| Нет места для ваших правил | `.agent/rules/project-rules.md` — читается перед каждой фазой |
| Результаты теряются между сессиями | **Request** — документированный результат каждой задачи (summary + коммиты + верификация) |
| Архитектурные решения не фиксируются | ADR, Risk Register, Red Team Review — по вызову пользователя |
| Контекст бесконтрольно растёт | Завершённые задачи архивируются, `.agent/` остаётся lean |
| Сложная конфигурация сессии (depth, фичи) | Никакой конфигурации. Цикл + команды — всё |

## Ключевые фичи v3.0

- **Цикл без конфигурации** — никакой шкалы depth, никаких интервью. Агент сам определяет тип проекта в ANALYSE.
- **Команды отдельно от цикла** — ADR, Red Team, Risk Register вызываются тогда, когда нужны.
- **Request как единица результата** — каждая задача завершается request-ом с diff-summary, коммитами и верификацией.
- **METASTATE** — по команде «обнови метасостояние»: ревью requests, обновление слепка проекта, подготовка `.agent/` для следующего агента.
- **Project State** — динамический слепок, обновляется при METASTATE. Следующий агент читает `.agent/` и не лезет в исходники.
- **Origin задач** — каждая задача знает, откуда пришла (roadmap, ADR, user, agent, decomposition).
- **Чекпоинты** (`checkpoints.json`) — позволяют возобновить сессию с любой фазы.
- **Ваши правила** — `.agent/rules/project-rules.md` — условия, которые агент соблюдает всегда.
- **Кроссплатформенная установка** — `install.sh` (Unix), `install.ps1` (PowerShell), `install.bat` (cmd).

## Быстрый старт

```bash
# Установить MetaAgent в ваш проект
./install.sh /path/to/your/project

# Или интерактивно:
./install.sh
```

После установки в проекте появятся `.agent/src/` (исходники MetaAgent), `.agent/rules/` (ваши правила) и `AGENTS.md` (инструкция для агента). Любой AI-агент, работающий в проекте, автоматически получит полный контекст через `AGENTS.md`.

## Версия

Текущая: **3.0.0** (см. `CHANGELOG.md`)

---

## MetaAgent (English)

MetaAgent is an instruction set for an AI agent that transforms chaotic agent interactions into a structured, predictable, and self-contained process.

### v3.0 model: loop + commands

**Loop** — the phases an agent goes through when working on a project:

```
INIT → ANALYSE → ROADMAP → [DESIGN] → DECOMPOSITION → EXECUTION → METASTATE → HANDOFF
```

DESIGN runs only for greenfield/scaffold projects. For existing — skipped.

**Commands** — on-demand instructions, invoked by the user explicitly:

| Command | What it does |
|---|---|
| `/adr` | Write an architecture decision to `.agent/decisions/` |
| `/red-team` | Try to break the design → `.agent/context/red-team-report.md` |
| `/risk-register` | Assumptions registry → `.agent/context/risk-register.md` |
| `/alt-arch` | Describe an alternative architecture |
| `/invariant-tests` | Invariant tests for an ADR |

Commands are **optional**. If not invoked — not executed. The loop works without them.

### Why MetaAgent over plain agent chat

| Plain agent | MetaAgent v3.0 |
|---|---|
| Context lost with every new conversation | `.agent/` — full project snapshot: state, decisions, tasks, results |
| No system — agent acts ad-hoc | Clear lifecycle: INIT → … → HANDOFF |
| No place for your rules | `.agent/rules/project-rules.md` — read before every phase |
| Results lost between sessions | **Request** — documented result per task (summary + commits + verification) |
| Architectural decisions lost | ADR, Risk Register, Red Team Review — invoked on demand |
| Context grows unboundedly | Completed tasks are archived, `.agent/` stays lean |
| Complex session configuration (depth, features) | No configuration. Loop + commands — that's it |

### Quick start

```bash
# Install MetaAgent into your project
./install.sh /path/to/your/project

# Or interactive:
./install.sh
```

After install, your project will have `.agent/src/` (MetaAgent sources), `.agent/rules/` (your rules), and `AGENTS.md` (agent instructions). Any AI agent working in the project automatically gets full context through `AGENTS.md`.
