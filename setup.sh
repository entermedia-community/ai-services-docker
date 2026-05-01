#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Accept CUDA version from environment (e.g., 13-0 or 12.8).
CUDA_VERSION="${CUDA_VERSION:-13-0}"
CUDA_VERSION_APT="${CUDA_VERSION//./-}"

# Keep the script build-safe and runtime-safe: install dependencies/tools only.
apt-get update
apt-get install -y --no-install-recommends \
	ca-certificates \
	lsof \
	curl \
	wget \
	gnupg \
	git \
	python3 \
	python3-pip \
	python3-venv \
	python-is-python3 \
	pciutils \
	build-essential \
	cmake \
	libcurl4-openssl-dev \
	libcublas-12-0

# Install NVIDIA CUDA APT repository and CUDA toolkit.
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
wget -qO "$tmp_dir/cuda-keyring.deb" "https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb"
dpkg -i "$tmp_dir/cuda-keyring.deb"
apt-get update
apt-get install -y --no-install-recommends "cuda-toolkit-${CUDA_VERSION_APT}"

# Persist CUDA environment variables for shell sessions.
cat >/etc/profile.d/cuda.sh <<'EOF'
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda
EOF

# Build llama.cpp with CUDA support.
install -d /opt
if [ ! -d /opt/llama.cpp ]; then
	git clone https://github.com/ggml-org/llama.cpp /opt/llama.cpp
fi
cmake /opt/llama.cpp \
	-B /opt/llama.cpp/build \
	-DBUILD_SHARED_LIBS=OFF \
	-DGGML_CUDA=ON \
	-DLLAMA_BUILD_BORINGSSL=ON \
	-DCMAKE_BUILD_TYPE=Release
cmake --build /opt/llama.cpp/build --config Release -j --clean-first --target llama-server
cp /opt/llama.cpp/build/bin/llama-* /usr/local/bin/

# Install Cloudflare Tunnel (cloudflared).
mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
	| gpg --dearmor \
	> /usr/share/keyrings/cloudflare-main.gpg
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' \
	> /etc/apt/sources.list.d/cloudflared.list
apt-get update
apt-get install -y --no-install-recommends cloudflared

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

# Keep the image compact.
apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/debconf/* /tmp/*
