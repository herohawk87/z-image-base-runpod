# Use specific version of nvidia cuda image
FROM wlsdml1114/multitalk-base:1.4 as runtime

# wget 설치 (URL 다운로드를 위해)
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN pip install -U "huggingface_hub[hf_transfer]"
RUN pip install runpod websocket-client boto3

WORKDIR /


RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd /ComfyUI && \
    pip install -r requirements.txt

RUN cd /ComfyUI/custom_nodes && \
    git clone https://github.com/Comfy-Org/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && \
    pip install -r requirements.txt

# wget을 사용하여 모델 다운로드 (인증 불필요)
# === Z-Image BASE (노멀, 비증류) 단일 파일 ===
RUN wget https://huggingface.co/dci05049/z-image-base/resolve/main/z_image_bf16.safetensors -O /ComfyUI/models/unet/z_image_base_bf16.safetensors
RUN wget https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors -O /ComfyUI/models/clip/qwen_3_4b.safetensors
RUN wget https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors -O /ComfyUI/models/vae/ae.safetensors


COPY . .
RUN mkdir -p /ComfyUI/user/default/ComfyUI-Manager
COPY config.ini /ComfyUI/user/default/ComfyUI-Manager/config.ini
COPY extra_model_paths.yaml /ComfyUI/extra_model_paths.yaml
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
