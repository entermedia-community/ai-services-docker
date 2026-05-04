#!/usr/bin/env bash

set -euo pipefail


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
