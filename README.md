# MetaAgent

MetaAgent — это набор инструкций для AI-агента, который превращает хаотичное общение с агентом в структурированный, предсказуемый и самодостаточный процесс.

## Чем MetaAgent отличается от обычного общения с агентом?

| Обычный агент | MetaAgent v2.1 |
|---------------|----------------|
| Вы даёте задачу — агент сразу пишет код | Двухконтурный жизненный цикл: Project Loop (анализ → дизайн → задачи) + Work Loop (исполнение → requests → metastate) |
| Контекст теряется при каждом новом разговоре | `.agent/` — полный слепок проекта: состояний, решений, задач, результатов |
| Нет системы — агент действует ad-hoc | Чёткий жизненный цикл: INIT → ANALYSE → ROADMAP → DESIGN → DECOMPOSITION → EXECUTION → METASTATE → HANDOFF |
| Нет места для ваших правил | `.agent/rules/` — ваши условия, которые агент читает перед каждой фазой |
| Результаты теряются между сессиями | **Request** — документированный результат каждой задачи (diff-summary + коммиты + верификация) |
| Архитектурные решения не фиксируются | ADR, Risk Register, Red Team Review — всё документируется |
| Контекст бесконтрольно растёт | Завершённые задачи архивируются, `.agent/` остаётся lean |

## Ключевые фичи v2.1

- **Два контура** — Project Loop (однократная настройка) и Work Loop (циклическая работа с задачами)
- **Request как единица результата** — каждая задача завершается request-ом с diff-summary, коммитами и верификацией
- **METASTATE** — по команде «обнови метасостояние»: ревью requests, обновление слепка проекта, подготовка `.agent/` для следующего агента
- **ROADMAP** — фаза сбора источников задач: FUTURE-планы, ADR, user-запросы, анализ агента
- **Project State** — динамический слепок, который обновляется при METASTATE. Следующий агент читает `.agent/` и не лезет в исходники
- **Origin задач** — каждая задача знает, откуда пришла (roadmap, ADR, user, agent)
- **Персистентность** — чекпоинты (`checkpoints.json`) позволяют возобновить сессию с любой фазы
- **Ваши правила** — `.agent/rules/project-rules.md` — условия, которые агент соблюдает всегда
- **Кроссплатформенная установка** — `install.sh` (Unix), `install.ps1` (PowerShell), `install.bat` (cmd)

## Быстрый старт

```bash
# Установить MetaAgent в ваш проект
./install.sh /path/to/your/project

# Или интерактивно:
./install.sh
```

После установки в проекте появятся `.agent/src/` (исходники MetaAgent), `.agent/rules/` (ваши правила) и `AGENTS.md` (инструкция для агента). Любой AI-агент, работающий в проекте, автоматически получит полный контекст через `AGENTS.md`.

---

## MetaAgent

MetaAgent is an instruction set for an AI agent that transforms chaotic agent interactions into a structured, predictable, and self-contained process.

## Why MetaAgent over plain agent chat?

| Plain agent | MetaAgent v2.1 |
|-------------|----------------|
| You give a task — agent writes code immediately | Dual-loop lifecycle: Project Loop (analyze → design → tasks) + Work Loop (execute → requests → metastate) |
| Context lost with every new conversation | `.agent/` — full project snapshot: state, decisions, tasks, results |
| No system — agent acts ad-hoc | Clear lifecycle: INIT → ANALYSE → ROADMAP → DESIGN → DECOMPOSITION → EXECUTION → METASTATE → HANDOFF |
| No place for your rules | `.agent/rules/` — your constraints, read before every phase |
| Results lost between sessions | **Request** — documented result per task (diff-summary + commits + verification) |
| Architectural decisions lost | ADRs, Risk Register, Red Team Review — fully documented |
| Context grows unboundedly | Completed tasks are archived, `.agent/` stays lean |

## Key features v2.1

- **Dual loop** — Project Loop (one-time setup) and Work Loop (iterative task execution)
- **Request as result unit** — each task ends with a request containing diff-summary, commits, and verification
- **METASTATE** — on "update metastate" command: review requests, update project snapshot, prepare `.agent/` for next agent
- **ROADMAP** — source gathering phase: FUTURE plans, ADRs, user requests, agent analysis
- **Project State** — dynamic snapshot updated on METASTATE. Next agent reads `.agent/` without touching source code
- **Task origin** — every task knows its source (roadmap, ADR, user, agent)
- **Resumable** — checkpoints (`checkpoints.json`) allow resume from any phase
- **Your rules** — `.agent/rules/project-rules.md` — constraints the agent follows always
- **Cross-platform setup** — `install.sh` (Unix), `install.ps1` (PowerShell), `install.bat` (cmd)

## Quick start

```bash
# Install MetaAgent into your project
./install.sh /path/to/your/project

# Or interactive:
./install.sh
```

After install, your project will have `.agent/src/` (MetaAgent sources), `.agent/rules/` (your rules), and `AGENTS.md` (agent instructions). Any AI agent working in the project automatically gets full context through `AGENTS.md`.
