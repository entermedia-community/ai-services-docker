#!/usr/bin/env bash
# Script to run qdrant in docker container and handle contingencies, like OOM.
# The functioning logic is as follows:
# - If recovery mode is allowed, we check if qdrant was killed during initialization or not.
#   - If it was killed during initialization, we remove run qdrant in recovery mode
#   - If it was killed after initialization, do nothing and restart container
# - If recovery mode is not allowed, we just restart container

if [ -n "${CF_TUNNEL_TOKEN:-}" ]; then
  cloudflared tunnel run --token "$CF_TUNNEL_TOKEN" > /dev/null 2>&1 &
else
  echo "CF_TUNNEL_TOKEN is NOT set"
fi

_term () {
  kill -TERM "$QDRANT_PID" 2>/dev/null
}

trap _term SIGTERM

_interrupt () {
  kill -INT "$QDRANT_PID" 2>/dev/null
}

trap _interrupt SIGINT

./qdrant $@ &

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
else
  install -d /opt
  if [ ! -d /opt/llama.cpp ]; then
    git clone https://github.com/ggml-org/llama.cpp /opt/llama.cpp
  fi
  LLAMA_SERVER_BIN="/opt/llama.cpp/build/bin/llama-server"

  if [ -x "$LLAMA_SERVER_BIN" ]; then
    echo "llama.cpp already built at $LLAMA_SERVER_BIN; skipping build."
  else
    cmake /opt/llama.cpp \
      -B /opt/llama.cpp/build \
      -DBUILD_SHARED_LIBS=OFF \
      -DGGML_CUDA=ON \
      -DLLAMA_BUILD_BORINGSSL=ON \
      -DCMAKE_CUDA_COMPILER="$CUDA_COMPILER" \
      -DCMAKE_BUILD_TYPE=Release
    
    cmake --build /opt/llama.cpp/build --config Release -j --clean-first --target llama-server
    cp /opt/llama.cpp/build/bin/llama-* /usr/local/bin/
  fi

fi
