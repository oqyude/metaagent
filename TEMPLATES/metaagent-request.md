# MetaAgent Request

Заполните перед запуском MetaAgent.

## Параметры сессии

| Функция | Вкл | Аргументы |
|---|---|---|
| ANALYSIS | ✓ | — |
| DESIGN | ✓ | adr=yes, alternative_arch=yes |
| RED_TEAM | ✗ | — |
| RISK_REGISTER | ✗ | — |
| DECOMPOSITION | ✓ | invariant_tests=yes |
| SETUP | ✓ | — |
| HANDOFF | ✓ | layer_structure=yes |

## Глубина проработки

**Значение:** 6 (1-10)

| Уровень | Название | Описание |
|---|---|---|
| 1-2 | Scaffold | Только структура проекта + пустые модули |
| 3-4 | Light | Быстрый анализ, минимальный дизайн, задачи без AC |
| 5-6 | Standard | (default) Полный ANALYSIS→DESIGN→DECOMP→SETUP→HANDOFF |
| 7-8 | Deep | Standard + ADR, Risk Register, Alternative Architecture |
| 9-10 | Maximum | Deep + Red Team Review, Executable Invariants, полный decision log |

## Цель

Сформулируйте задачу для MetaAgent.

## Дополнительно

- **Boundaries:** (опционально) ограничения, которые нельзя нарушать
- **Target:** путь к репозиторию или URL
