#!/usr/bin/env bash

set -euo pipefail


# Clone and install AI services.
AI_SERVICES_DIR="${HOME:-/root}/ai-services"
install -d "$AI_SERVICES_DIR"

clone_and_install() {
    local repo="$1"
    local dir="$AI_SERVICES_DIR/$(basename "$repo")"
    git clone "https://github.com/entermedia-community/${repo}" "$dir"
    python3 -m venv "$dir/.venv"
    "$dir/.venv/bin/pip" install --upgrade pip
    "$dir/.venv/bin/pip" install -r "$dir/requirements.txt"
}

clone_and_install ai-llama-index
clone_and_install audio-transcriber
clone_and_install nllb-translation
clone_and_install chatterbox-tts
