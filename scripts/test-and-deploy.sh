#!/usr/bin/env bash
# Test, then deploy the foreman agent.
#
#   scripts/test-and-deploy.sh          # Tier 0 spec checks, then install/update on the server
#   scripts/test-and-deploy.sh --live   # also run the boot + routing live checks first
#
# Deploy = `omni agent add <dir>`, which installs the agent under your account
# on the server so it shows up beside the built-ins in the new-session picker
# on every host. Re-running replaces the existing copy in place.
set -euo pipefail

AGENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LIVE=0
for arg in "$@"; do
  case "$arg" in
    --live) LIVE=1 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

echo "== 1/3  Validate (smoke tests) =="
if [[ "$LIVE" -eq 1 ]]; then
  bash "$AGENT_DIR/tests/smoke.sh" --live
else
  bash "$AGENT_DIR/tests/smoke.sh"
fi

echo
echo "== 2/3  Deploy to your agents =="
omni agent add "$AGENT_DIR"

echo
echo "== 3/3  Confirm =="
omni agent list
