#!/usr/bin/env bash
set -euo pipefail

export OLLAMA_HOST="${OLLAMA_HOST:-0.0.0.0:11434}"
export OLLAMA_MODELS="${OLLAMA_MODELS:-/root/.ollama}"
export OLLAMA_BASE_MODEL="${OLLAMA_BASE_MODEL:-qwen3.6:35b}"
export OLLAMA_MODEL="${OLLAMA_MODEL:-${OLLAMA_BASE_MODEL}-ctx65536}"
export OLLAMA_CONTEXT_LENGTH="${OLLAMA_CONTEXT_LENGTH:-65536}"

mkdir -p "${OLLAMA_MODELS}"

if ! pgrep -x ollama >/dev/null 2>&1; then
  ollama serve >/tmp/ollama-serve.log 2>&1 &
fi

for _ in $(seq 1 60); do
  if curl -fsS "http://127.0.0.1:11434/api/tags" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! ollama list | awk 'NR > 1 {print $1}' | grep -Fxq "${OLLAMA_MODEL}"; then
  cat >/tmp/ollama-modelfile <<EOF
FROM ${OLLAMA_BASE_MODEL}
PARAMETER num_ctx ${OLLAMA_CONTEXT_LENGTH}
EOF
  ollama create "${OLLAMA_MODEL}" -f /tmp/ollama-modelfile
fi

if [[ "${OLLAMA_PULL_ON_START:-1}" == "1" ]]; then
  ollama pull "${OLLAMA_BASE_MODEL}" >/dev/null
fi

if [[ $# -eq 0 ]]; then
  exec bash
fi

exec "$@"
