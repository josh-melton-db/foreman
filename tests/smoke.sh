#!/usr/bin/env bash
# Cheap smoke test for the foreman agent (the parent directory of this script).
#
#   tests/smoke.sh          # Tier 0 only: deterministic spec checks. Free, instant.
#   tests/smoke.sh --live   # + Tier 1/2: boot the agent, then a routing dry-run.
#                           #   One LLM turn each; no sub-agents are actually spawned.
set -euo pipefail

AGENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OMNI="$(command -v omni)"
OMNI_PY="$(sed -n '1s/^#!//p' "$OMNI")"

LIVE=0
for arg in "$@"; do
  case "$arg" in
    --live) LIVE=1 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

echo "== Tier 0: deterministic spec checks =="
"$OMNI_PY" - "$AGENT_DIR" <<'PY'
import sys
from pathlib import Path
from omnigent.spec import load as load_spec
from omnigent.spec.validator import validate

root = Path(sys.argv[1])
ok = True

def check(label, got, want):
    global ok
    good = got == want
    ok = ok and good
    print(f"  {'PASS' if good else 'FAIL'}  {label}: {got!r}")

spec = load_spec(root)
res = validate(spec)
print(f"  {'PASS' if res.valid else 'FAIL'}  spec valid: {res.valid}")
ok = ok and res.valid

check("name", spec.name, "foreman")
check("tools.agents", list(spec.tools.agents), ["claude_code", "codex", "deepseek"])
check("brain model", spec.executor.model, "databricks-claude-opus-5-5")

guards = {g.name for g in (spec.guardrails.policies or [])}
check("guardrail present", "cross_vendor_review_guard" in guards, True)

# A pinned `databricks-` model needs the gateway transport enabled, which the
# spec's auth block provides. Without it the brain fails to launch.
auth = spec.executor.auth
check("brain auth type", type(auth).__name__, "DatabricksAuth")
check("brain auth profile", getattr(auth, "profile", None), "gtm-ai-agent")

for name, (harness, model) in {
    "claude_code": ("claude-native", "databricks-claude-opus-5-5"),
    "codex": ("codex-native", "databricks-gpt-6-1-sol"),
    "deepseek": ("codex-native", "system.ai.deepseek-v4-1-flash"),
}.items():
    w = load_spec(root / "agents" / name)
    check(f"{name} harness", w.executor.config.get("harness"), harness)
    check(f"{name} model", w.executor.model, model)

sys.exit(0 if ok else 1)
PY

echo
echo "== Tier 0b: CEL policy unit tests =="
"$OMNI_PY" "$AGENT_DIR/tests/test_cross_vendor_guard.py"

if [[ "$LIVE" -eq 0 ]]; then
  echo
  echo "Tier 0 passed. Add --live to also boot the agent and probe routing."
  exit 0
fi

echo
echo "== Tier 1: boot the agent (expect a foreman-ok style reply) =="
"$OMNI" run "$AGENT_DIR" --no-session -p "Reply with exactly: foreman-ok. Then stop."

echo
echo "== Tier 2: routing dry-run (expect deepseek for the fast task, codex for the complex one) =="
out="$("$OMNI" run "$AGENT_DIR" --no-session -p \
"Routing dry-run (no side effects). Do NOT dispatch any sub-agents, do NOT run shell commands, do NOT edit files. Output which single worker you would dispatch for each task, one line each:
1) fast task: add a one-line null guard to a function in utils.py
2) complex task: implement a concurrency-safe distributed rate limiter
Reply exactly:
TASK1 -> <worker>
TASK2 -> <worker>" | tr -d '\r')"
echo "$out"
echo "---"
if echo "$out" | grep -Eqi "TASK1 *-> *deepseek"; then echo "PASS fast-task->deepseek"; else echo "WARN fast-task->deepseek (model judgment; re-run or reword)"; fi
if echo "$out" | grep -Eqi "TASK2 *-> *codex"; then echo "PASS complex-task->codex"; else echo "WARN complex-task->codex (model judgment; re-run or reword)"; fi
