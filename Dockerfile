FROM nvidia/cuda:12.8.1-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    CODEX_HOME=/root/.codex \
    OLLAMA_HOST=0.0.0.0:11434 \
    OLLAMA_MODELS=/root/.ollama \
    OLLAMA_BASE_MODEL=qwen3.6:35b \
    OLLAMA_MODEL=qwen3.6:35b-ctx65536 \
    OLLAMA_CONTEXT_LENGTH=65536

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       git \
       jq \
       python3 \
       python3-pip \
       tar \
       zstd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://chatgpt.com/codex/install.sh \
    | CODEX_NON_INTERACTIVE=1 sh \
    && mkdir -p /root/.codex \
    && cat > /root/.codex/config.toml <<'EOF'
oss_provider = "ollama"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
EOF

RUN cat > /root/.codex/oss.config.toml <<'EOF'
oss_provider = "ollama"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
EOF

RUN curl -fsSL https://ollama.com/download/ollama-linux-amd64.tar.zst \
    | tar --use-compress-program=unzstd -x -C /usr/local

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY codex-local.sh /usr/local/bin/codex-local
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/codex-local

EXPOSE 11434

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
