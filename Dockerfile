ARG QDRANT_PLATFORM=linux/amd64
FROM --platform=${QDRANT_PLATFORM} qdrant/qdrant:gpu-nvidia-latest

COPY config /qdrant/config

ARG CUDA_VERSION=13-0

RUN apt-get update && apt-get install -y --no-install-recommends \
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
	python-is-python3 \
	ffmpeg \
	pciutils \
	build-essential \
	cmake \
	libcurl4-openssl-dev

COPY nvidia.sh /tmp/nvidia.sh
COPY cf.sh /tmp/cf.sh
COPY llama.sh /tmp/llama.sh
COPY repo.sh /tmp/repo.sh

RUN chmod +x /tmp/nvidia.sh
RUN chmod +x /tmp/cf.sh
RUN chmod +x /tmp/llama.sh
RUN chmod +x /tmp/repo.sh

RUN CUDA_VERSION="$CUDA_VERSION" /tmp/nvidia.sh

RUN /tmp/cf.sh

RUN /tmp/llama.sh

RUN /tmp/repo.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/debconf/* /tmp/*

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