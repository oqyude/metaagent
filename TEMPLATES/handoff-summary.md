# Handoff Summary

## Session Info

- **Session ID:** `{{ session_id }}`
- **Target Repo:** `{{ target_repo }}`
- **Goal:** {{ goal }}
- **Date:** {{ date }}
- **Duration:** {{ duration }}

## Repo Summary

{{ repo_summary }}

## Environment Status

- **Build:** {{ build_status }}
- **Tests:** {{ tests_passed }}/{{ tests_total }} passed
- **Baseline log:** `.agent/baseline-test-report.log`
- **Dependencies:** {{ deps_status }}

## Task Overview

| Status | Count |
|---|---|
| Total | {{ total }} |
| Pending | {{ pending }} |
| In Progress | {{ in_progress }} |
| Completed | {{ completed }} |
| Failed/Skipped | {{ failed }} |

**Task by type:**
{% for type, count in tasks_by_type %}
- {{ type }}: {{ count }}
{% endfor %}

## Tasks (ordered)

{% for task in tasks %}
### {{ task.id }}: {{ task.title }}
- Type: {{ task.type }}
- Depends on: {{ task.depends_on | default("—") }}
- Files: {{ task.files | join(", ") }}
- Status: {{ task.status }}

{% endfor %}

## Next Steps

Исполнительный агент начинает с задачи **{{ first_task }}**.

## Caveats

{% for caveat in caveats %}
- {{ caveat }}
{% endfor %}

## Checkpoints

Файл: `.agent/checkpoints.json`
Актуальное состояние чекпоинтов прилагается.
