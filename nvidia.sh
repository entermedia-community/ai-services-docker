#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Accept CUDA version from environment (e.g., 13-0 or 12.8).
CUDA_VERSION="${CUDA_VERSION:-13-0}"
CUDA_VERSION_APT="${CUDA_VERSION//./-}"


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
