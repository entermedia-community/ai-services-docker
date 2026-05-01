#!/usr/bin/env bash

if ! command -v hf &> /dev/null
then
    echo "hf could not be found, installing..."
    curl -LsSf https://hf.co/cli/install.sh | bash
else
    echo "hf is already installed"
fi

if [ -f .env ]; then
    export $(cat .env | xargs)
fi

hf download unsloth/Qwen3.5-35B-A3B-GGUF --include "*UD-Q4_K_XL"
hf download unsloth/Qwen3.5-35B-A3B-GGUF --include "*mmproj-F16.gguf"

hf download BAAI/bge-m3

hf download facebook/nllb-200-1.3B

hf download Systran/faster-whisper-large-v3

hf download pyannote/speaker-diarization-3.1
hf download pyannote/speaker-diarization-community-1
hf download pyannote/segmentation-3.0

hf download ResembleAI/chatterbox
