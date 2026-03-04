set -euo pipefail

if [ "${1:-}" != "--" ]; then
  echo "usage: dev-with-tail.sh -- <command> [args...]" >&2
  exit 2
fi
shift

if [ "$#" -eq 0 ]; then
  echo "dev-with-tail.sh: missing command after --" >&2
  exit 2
fi

tailer_script="/opt/app/.sandstorm/grain-log-tailer.sh"
if [ ! -f "$tailer_script" ]; then
  echo "dev-with-tail.sh: missing $tailer_script" >&2
  exit 1
fi

cleanup() {
  if [ -n "${grain_tail_pid:-}" ]; then
    kill "$grain_tail_pid" 2>/dev/null || true
    wait "$grain_tail_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

sudo -u sandstorm bash "$tailer_script" &
grain_tail_pid=$!

"$@"
