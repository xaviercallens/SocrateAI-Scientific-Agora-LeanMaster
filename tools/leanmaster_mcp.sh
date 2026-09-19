#!/usr/bin/env bash
# tools/leanmaster_mcp.sh — start the LeanMaster MCP server (stdio). Register it from any project with
#   claude mcp add leanmaster -- /mnt/disks/disk-socrateai-local-1/callensxavier_home_data/SocrateAI-Scientific-Agora-LeanMaster/tools/leanmaster_mcp.sh
# The server needs the `mcp` package, installed in a venv on the data disk (never the root disk):
#   python3 -m venv /mnt/disks/disk-socrateai-local-1/leanmaster/mcp-venv
#   /mnt/disks/disk-socrateai-local-1/leanmaster/mcp-venv/bin/pip install "mcp>=1.2,<2"
# Overrides: LEANMASTER_MCP_PYTHON (interpreter), LEANSTACK_HOME (LeanMemory store),
#            LEANMASTER_MCP_SCRATCH (snippet scratch directory). stdout is the JSON-RPC channel: log to stderr only.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
PY="${LEANMASTER_MCP_PYTHON:-/mnt/disks/disk-socrateai-local-1/leanmaster/mcp-venv/bin/python}"
if [ ! -x "$PY" ]; then
  echo "leanmaster_mcp.sh: $PY not found; create the venv (see the header of this script)" >&2
  exit 1
fi
# lake (for check_lean_snippet) lives in ~/.elan/bin; a client may start us with a minimal PATH.
export PATH="$HOME/.elan/bin:$PATH"
export PYTHONPATH="$REPO${PYTHONPATH:+:$PYTHONPATH}"
cd "$REPO"
exec "$PY" -m leanstack.mcp_server "$@"
