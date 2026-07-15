# MetaAgent

MetaAgent — это набор инструкций для AI-агента, который превращает хаотичное общение с агентом в структурированный, предсказуемый и самодостаточный процесс.

## Чем MetaAgent отличается от обычного общения с агентом?

| Обычный агент | MetaAgent |
|---------------|-----------|
| Вы даёте задачу — агент сразу пишет код | Агент сначала анализирует, проектирует, декомпозирует — только потом код |
| Контекст теряется при каждом новом разговоре | Вся сессия сохраняется в `.agent/` проекта — можно прервать и продолжить |
| Нет системы — агент действует ad-hoc | Чёткий жизненный цикл: INIT → ANALYSE → DESIGN → DECOMPOSITION → SETUP → HANDOFF |
| Нет места для ваших правил | `.agent/rules/` — ваши условия, которые агент читает перед каждой фазой |
| Архитектурные решения не фиксируются | ADR, Risk Register, Red Team Review — всё документируется |
| Контекст бесконтрольно растёт | Завершённые задачи архивируются — контекст остаётся lean |

## Ключевые фичи

- **Структурированный жизненный цикл** — каждая фаза имеет протокол и критерии завершения. Никаких пропущенных шагов.
- **Самодостаточность** — `install.sh` копирует весь MetaAgent в `.agent/src/` вашего проекта. Агенту не нужно выходить за пределы проекта.
- **Персистентность** — чекпоинты (`checkpoints.json`) позволяют возобновить сессию с любой фазы.
- **Ваши правила** — `.agent/rules/project-rules.md` — условия, которые агент соблюдает всегда.
- **Архивация** — выполненные задачи и устаревшие решения уходят в `.agent/archive/`. Контекст не раздувается, история сохраняется.
- **ADR и инварианты** — архитектурные решения документируются и проверяются тестами.
- **Разделение труда** — мета-агент анализирует и планирует, исполнительный агент реализует код.
- **Кроссплатформенная установка** — `install.sh` (Unix) и `install.ps1` (Windows).

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

| Plain agent | MetaAgent |
|-------------|-----------|
| You give a task — agent writes code immediately | Agent analyses, designs, decomposes — code comes last |
| Context lost with every new conversation | Full session persists in `.agent/` — pause and resume anytime |
| No system — agent acts ad-hoc | Clear lifecycle: INIT → ANALYSE → DESIGN → DECOMPOSITION → SETUP → HANDOFF |
| No place for your rules | `.agent/rules/` — your constraints, read before every phase |
| Architectural decisions lost | ADRs, Risk Register, Red Team Review — fully documented |
| Context grows unboundedly | Completed tasks are archived — context stays lean |

## Key features

- **Structured lifecycle** — every phase has a protocol and completion criteria. No skipped steps.
- **Self-contained** — `install.sh` copies MetaAgent into `.agent/src/` of your project. Agent never needs to leave the project directory.
- **Resumable** — checkpoints (`checkpoints.json`) let you resume a session from any phase.
- **Your rules** — `.agent/rules/project-rules.md` — constraints the agent follows always.
- **Archiving** — completed tasks and outdated decisions go to `.agent/archive/`. Context stays lean, history is preserved.
- **ADRs & invariants** — architectural decisions are documented and verified with tests.
- **Separation of concerns** — meta-agent analyses and plans, executive agent implements code.
- **Cross-platform setup** — `install.sh` (Unix) and `install.ps1` (Windows).

## Quick start

```bash
# Install MetaAgent into your project
./install.sh /path/to/your/project

# Or interactive:
./install.sh
```

After install, your project will have `.agent/src/` (MetaAgent sources), `.agent/rules/` (your rules), and `AGENTS.md` (agent instructions). Any AI agent working in the project automatically gets full context through `AGENTS.md`.
