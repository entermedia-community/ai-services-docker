export CUDA_VISIBLE_DEVICES=0
llama-server \
    -hf unsloth/Qwen3.5-35B-A3B-GGUF:UD-Q4_K_XL \
    --ctx-size 16384 \
    --temp 0.7 \
    --top-p 0.8 \
    --top-k 20 \
    --min-p 0.00 \
    --port 7600 \
    --host 0.0.0.0 \
    --gpu-layers 999 \
    --reasoning off \
    > /dev/null 2>&1 &

