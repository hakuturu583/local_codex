#!/usr/bin/env bash
set -euo pipefail

exec codex --oss --profile oss --model "${OLLAMA_MODEL:-qwen3.6:35b-ctx65536}" "$@"
