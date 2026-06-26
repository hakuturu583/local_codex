# Codex OSS + Ollama Docker Image

RTX 6000 Pro Blackwell 向けに、Codex CLI と Ollama を同居させた開発用イメージです。

既定値は次の通りです。

- Codex のローカル OSS プロファイル: `qwen3.6:35b-ctx65536`
- Ollama のベースモデル: `qwen3.6:35b`
- Ollama の既定ローカルモデル: `qwen3.6:35b-ctx65536`
- Ollama の既定コンテキスト長: `65536`

Ollama 側は、ローカルの coding 用として扱いやすい `qwen3.6:35b` を既定にしています。

## 含まれるもの

- `codex`
- `codex-local`
- `ollama`
- GPU 有効化済みの起動スクリプト
- Codex の既定設定 `~/.codex/config.toml`
- Codex の OSS プロファイル `~/.codex/oss.config.toml`
- Docker Compose 定義

## ビルド

```bash
docker build -t codex-ollama-blackwell .
```

## 起動

```bash
docker run --rm -it \
  --gpus all \
  -p 11434:11434 \
  -v ollama-models:/root/.ollama \
  -v "$PWD":/workspace \
  -w /workspace \
  codex-ollama-blackwell
```

起動時に Ollama が立ち上がり、必要なら `qwen3.6:35b` から `qwen3.6:35b-ctx65536` を自動生成します。

## 使い方

### Ollama を直接使う

```bash
ollama run qwen3.6:35b-ctx65536
```

### Codex を Ollama 経由で使う

`--oss` を付けると、Codex はローカルの Ollama を使います。

```bash
codex --oss
```

このイメージでは `codex-local` というショートカットも入っています。

```bash
codex-local
```

## Compose

```bash
docker compose up --build
```

## 起動ラッパー

リポジトリ直下の `local_codex` を PATH に置くか alias を貼ると、指定したディレクトリを `/workspace` にマウントして起動できます。

```bash
alias local_codex='/path/to/local_codex/local_codex'
local_codex .
```

`local_codex ~/src/my-project` のように別ディレクトリも指定できます。引数を続ければ `codex` 側へそのまま渡ります。

## 調整ポイント

- `OLLAMA_MODEL`
  - 既定は `qwen3.6:35b-ctx65536`
  - 別の Ollama モデルに差し替え可能
- `OLLAMA_BASE_MODEL`
  - 既定は `qwen3.6:35b`
  - `OLLAMA_MODEL` の元になるベースモデル
- `OLLAMA_CONTEXT_LENGTH`
  - 既定は `65536`
  - 大きなリポジトリならさらに増やす
- `OLLAMA_PULL_ON_START`
  - `1` で起動時に自動 pull
  - `0` で無効化

## 参考

- [Ollama Linux install](https://docs.ollama.com/linux)
- [Ollama context length](https://docs.ollama.com/context-length)
- [Ollama Docker](https://docs.ollama.com/docker)
