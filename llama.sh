#!/usr/bin/env bash

set -euo pipefail

# Resolve CUDA compiler path explicitly for CMake.
CUDA_COMPILER="${CUDACXX:-}"
if [ -z "$CUDA_COMPILER" ]; then
	if command -v nvcc >/dev/null 2>&1; then
		CUDA_COMPILER="$(command -v nvcc)"
	elif [ -x /usr/local/cuda/bin/nvcc ]; then
		CUDA_COMPILER=/usr/local/cuda/bin/nvcc
	fi
fi

if [ -z "$CUDA_COMPILER" ] || [ ! -x "$CUDA_COMPILER" ]; then
	echo "CUDA compiler not found (nvcc). Expected in PATH or /usr/local/cuda/bin/nvcc." >&2
	exit 1
fi


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
	-DCMAKE_CUDA_COMPILER="$CUDA_COMPILER" \
	-DCMAKE_BUILD_TYPE=Release
cmake --build /opt/llama.cpp/build --config Release -j --clean-first --target llama-server
cp /opt/llama.cpp/build/bin/llama-* /usr/local/bin/
