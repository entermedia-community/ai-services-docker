ARG QDRANT_PLATFORM=linux/amd64
FROM --platform=${QDRANT_PLATFORM} qdrant/qdrant:gpu-nvidia-latest

COPY config /qdrant/config

ARG CUDA_VERSION=12-8

RUN set -eux; \
	export DEBIAN_FRONTEND=noninteractive; \
	. /etc/os-release; \
	if ! grep -RhsE '^[[:space:]]*deb ' /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null | grep -q .; then \
		if [ "${ID:-}" = "ubuntu" ] && [ -n "${VERSION_CODENAME:-}" ]; then \
			printf 'deb http://archive.ubuntu.com/ubuntu %s main universe multiverse restricted\n' "$VERSION_CODENAME" > /etc/apt/sources.list; \
			printf 'deb http://archive.ubuntu.com/ubuntu %s-updates main universe multiverse restricted\n' "$VERSION_CODENAME" >> /etc/apt/sources.list; \
			printf 'deb http://security.ubuntu.com/ubuntu %s-security main universe multiverse restricted\n' "$VERSION_CODENAME" >> /etc/apt/sources.list; \
		elif [ "${ID:-}" = "debian" ] && [ -n "${VERSION_CODENAME:-}" ]; then \
			printf 'deb http://deb.debian.org/debian %s main contrib non-free non-free-firmware\n' "$VERSION_CODENAME" > /etc/apt/sources.list; \
			printf 'deb http://deb.debian.org/debian %s-updates main contrib non-free non-free-firmware\n' "$VERSION_CODENAME" >> /etc/apt/sources.list; \
			printf 'deb http://security.debian.org/debian-security %s-security main contrib non-free non-free-firmware\n' "$VERSION_CODENAME" >> /etc/apt/sources.list; \
		fi; \
	fi; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		lsof \
		nano \
		curl \
		wget \
		gnupg \
		git \
		python3 \
		python3-pip \
		python3-venv \
		ffmpeg \
		pciutils \
		cmake \
		make \
		gcc \
		g++ \
		libcurl4-openssl-dev; \
	if ! command -v python >/dev/null 2>&1; then ln -sf /usr/bin/python3 /usr/local/bin/python; fi

COPY nvidia.sh /tmp/nvidia.sh
COPY cf.sh /tmp/cf.sh

RUN chmod +x /tmp/nvidia.sh && chmod +x /tmp/cf.sh

RUN	CUDA_VERSION="$CUDA_VERSION" /tmp/nvidia.sh && \
	/tmp/cf.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/debconf/* /tmp/*

RUN pip install --no-cache-dir --upgrade pip && \
		pip install --no-cache-dir \
			accelerate \
			transformers \
			torch --index-url https://download.pytorch.org/whl/cu128 \
			torchaudio --index-url https://download.pytorch.org/whl/cu128 \
			torchvision --index-url https://download.pytorch.org/whl/cu128 \
			torchcodec --index-url https://download.pytorch.org/whl/cu128 && \
		pip install --no-cache-dir ninja && \
		pip install --no-cache-dir fastapi[standard] \
			uvicorn[standard] \
			cachetools \
			pydantic \
			pydantic-settings \
			python-multipart \
			faster-whisper \
			pyannote-audio \
			librosa \
			soundfile


ARG APP=/qdrant

ARG USER_ID=0

RUN if [ "$USER_ID" != 0 ]; then \
        groupadd --gid "$USER_ID" qdrant; \
        useradd --uid "$USER_ID" --gid "$USER_ID" -m qdrant; \
        mkdir -p "$APP"/storage "$APP"/snapshots; \
        chown -R "$USER_ID:$USER_ID" "$APP"; \
    fi

WORKDIR "$APP"

USER "$USER_ID:$USER_ID"

ENV TZ=Etc/UTC \
    RUN_MODE=production


EXPOSE 6333
EXPOSE 6334

CMD ["./entrypoint.sh"]