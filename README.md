# Qdrant + AI Services Setup for eMedia

## Prerequisites

- Ubuntu 22.04 (x86_64)
- NVIDIA GPU with drivers installed
- Run as root (or with `sudo`)

## Usage

```bash
# Optional: override the default CUDA version (default: 13-0)
export CUDA_VERSION=12-8
```

### 1. System Dependencies

Installs the following packages via `apt`:

| Package                                  | Purpose                            |
| ---------------------------------------- | ---------------------------------- |
| `build-essential`, `cmake`               | C/C++ build toolchain              |
| `python3`, `python3-pip`, `python3-venv` | Python runtime                     |
| `curl`, `wget`, `git`                    | Download/version control utilities |
| `ffmpeg`                                 | Audio/video processing             |
| `pciutils`                               | GPU detection                      |
| `libcurl4-openssl-dev`                   | HTTP library headers               |
| `libcublas-12-0`                         | NVIDIA cuBLAS runtime              |

### 2. NVIDIA CUDA Toolkit

Adds the official NVIDIA CUDA APT repository and installs `cuda-toolkit-<CUDA_VERSION>`.

Persists the following environment variables to `/etc/profile.d/cuda.sh`:

```bash
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda
```

### 3. llama.cpp (CUDA Build)

Clones [llama.cpp](https://github.com/ggml-org/llama.cpp) to `/opt/llama.cpp` and builds the `llama-server` binary with CUDA support:

```
-DGGML_CUDA=ON
-DBUILD_SHARED_LIBS=OFF
-DCMAKE_BUILD_TYPE=Release
```

Binaries are copied to `/usr/local/bin/`.

### 4. Cloudflare Tunnel (`cloudflared`)

Installs `cloudflared` from the official Cloudflare APT repository, enabling secure tunneling without opening inbound firewall ports.

### 5. AI Services

Clones and installs the following services from `https://github.com/entermedia-community` into `~/ai-services/`. Each service gets its own Python virtual environment.

| Service        | Repository          | Description                      |
| -------------- | ------------------- | -------------------------------- |
| Embeddings     | `ai-llama-index`    | Vector embeddings via LlamaIndex |
| Transcription  | `audio-transcriber` | Audio-to-text transcription      |
| Translation    | `nllb-translation`  | NLLB multilingual translation    |
| Text-to-Speech | `chatterbox-tts`    | TTS synthesis                    |

## Environment Variables

| Variable       | Default | Description                                                 |
| -------------- | ------- | ----------------------------------------------------------- |
| `CUDA_VERSION` | `13-0`  | CUDA version to install (APT format, e.g. `13-0` or `12-8`) |

## Post-Setup

After running the script, start the AI services manually. Example:

```bash
cd ~/ai-services/ai-llama-index
./server.sh
```

See [AI_SERVICES.md](AI_SERVICES.md) for detailed instructions on starting each service.
