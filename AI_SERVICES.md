## 1. Deploy Additional AI Services

### 1.1 Embeddings Service

```bash
cd ~
git clone https://github.com/entermedia-community/ai-llama-index
cd ai-llama-index

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

chmod +x server.sh
./server.sh > ~/embeddings-server.log 2>&1 &
deactivate
```

### 1.2 Transcription Service

```bash
cd ~
git clone https://github.com/entermedia-community/audio-transcriber
cd audio-transcriber

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

chmod +x server.sh
./server.sh > ~/transcriber-server.log 2>&1 &
deactivate
```

### 1.3 Translation Service

```bash
cd ~
git clone https://github.com/entermedia-community/nllb-translation
cd nllb-translation

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

chmod +x translation.sh
./translation.sh > ~/translation-server.log 2>&1 &
deactivate
```
