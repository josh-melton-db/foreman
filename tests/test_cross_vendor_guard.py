"""Tests for the cross_vendor_review_guard CEL policy declared in config.yaml.

Deterministic and offline (no LLM, no server): loads the shipped spec, pulls the
CEL expression straight out of the policy, and feeds it synthetic tool-call
events. Run directly or under pytest:

    <omnigent-python> tests/test_cross_vendor_guard.py
"""

from __future__ import annotations

from pathlib import Path

import celpy
from celpy.adapter import json_to_cel

from omnigent.policies.registry import function_policy_handler_allowed
from omnigent.spec import load as load_spec

AGENT_DIR = Path(__file__).resolve().parent.parent
POLICY_NAME = "cross_vendor_review_guard"


def _policy():
    spec = load_spec(AGENT_DIR)
    for policy in spec.guardrails.policies or []:
        if policy.name == POLICY_NAME:
            return policy
    raise AssertionError(f"policy {POLICY_NAME!r} not found in config.yaml")


def _program():
    env = celpy.Environment()
    return env.program(env.compile(_policy().function.arguments["expression"]))


def _verdict(program, event):
    result = program.evaluate({"event": json_to_cel(event)})
    if not result or "result" not in result:
        return None
    return str(result["result"]).upper()


def _session_send(args):
    return {"type": "tool_call", "data": {"name": "sys_session_send", "arguments": args}}


def _review(vendor, implemented_by):
    child = {"purpose": "review", "vendor": vendor}
    if implemented_by is not None:
        child["implemented_by"] = implemented_by
    return _session_send({"agent": "codex", "title": "review-x", "args": child})


def test_handler_is_registered():
    policy = _policy()
    assert policy.function.path == "omnigent.policies.builtins.cel.cel_policy"
    assert function_policy_handler_allowed(policy.function.path, policy.function.arguments)


def test_same_vendor_review_is_denied():
    assert _verdict(_program(), _review("gpt", "gpt")) == "DENY"


def test_different_vendor_review_is_allowed():
    assert _verdict(_program(), _review("deepseek", "gpt")) == "ALLOW"


def test_review_without_tag_is_denied():
    assert _verdict(_program(), _review("deepseek", None)) == "DENY"


def test_non_review_dispatch_is_allowed():
    evt = _session_send({"agent": "codex", "args": {"purpose": "implement"}})
    assert _verdict(_program(), evt) == "ALLOW"


def test_unrelated_tool_is_allowed():
    evt = {"type": "tool_call", "data": {"name": "sys_os_shell", "arguments": {"command": "ls"}}}
    assert _verdict(_program(), evt) == "ALLOW"


def main() -> int:
    checks = [
        (name, fn)
        for name, fn in sorted(globals().items())
        if name.startswith("test_") and callable(fn)
    ]
    failures = 0
    for name, fn in checks:
        try:
            fn()
            print(f"  PASS  {name}")
        except Exception as exc:  # noqa: BLE001
            failures += 1
            print(f"  FAIL  {name}: {exc}")
    print(f"{len(checks) - failures}/{len(checks)} CEL policy checks passed")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
