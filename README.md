# ComfyUI RunPod Template: Flux 2 Klein 9B & LTX-2

A RunPod template based on the official [runpod-workers/comfyui-base](https://github.com/runpod-workers/comfyui-base) that **automatically downloads Flux 2 Klein 9B and LTX-2 Distilled models** when the pod starts.

## 🎨 Included Models

### Flux 2 Klein 9B (Text-to-Image)
- **Model**: `flux-2-klein-9b-fp8.safetensors` (9.43 GB)
- **Text Encoder**: `qwen_3_8b_fp8mixed.safetensors` (8.66 GB)
- **VAE**: `flux2-vae.safetensors` (~300 MB)
- **Source**: [black-forest-labs/FLUX.2-klein-9b-fp8](https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-fp8)

### LTX-2 Distilled (Text-to-Video)
- **Model**: `ltx-2-19b-distilled-fp8.safetensors` (27.1 GB)
- **Text Encoder**: `gemma_3_12B_it_fp8_scaled.safetensors` (13.2 GB)
- **Source**: [Lightricks/LTX-2](https://huggingface.co/Lightricks/LTX-2)

> **Total disk space required**: ~60 GB

## 🚀 Quick Start

### Prerequisites

1. **HuggingFace Account**: Create one at [huggingface.co](https://huggingface.co/join)
2. **Accept License**: Go to [FLUX.2-klein-9b-fp8](https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-fp8) and accept the license agreement
3. **Create Token**: Generate a token at [HuggingFace Settings](https://huggingface.co/settings/tokens)

### Deploy on RunPod

1. **Build the Docker image** (or use pre-built):
   ```bash
   docker build -t comfyui-flux2-ltx2 .
   ```

2. **Push to Docker Hub** (optional):
   ```bash
   docker tag comfyui-flux2-ltx2 yourusername/comfyui-flux2-ltx2:latest
   docker push yourusername/comfyui-flux2-ltx2:latest
   ```

3. **Create RunPod Template**:
   - Go to RunPod → Templates → New Template
   - Set the Docker image
   - Add environment variables (see below)

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `HF_TOKEN` | **Yes** | Your HuggingFace token for downloading gated Flux 2 Klein 9B model |
| `PUBLIC_KEY` | No | Your SSH public key for secure access |
| `JUPYTER_PASSWORD` | No | Password for Jupyter Lab access |

## 🔌 Access Ports

| Port | Service | Credentials |
|------|---------|-------------|
| 8188 | ComfyUI Web UI | None |
| 8080 | FileBrowser | admin / adminadmin12 |
| 8888 | JupyterLab | Token via `JUPYTER_PASSWORD` |
| 22 | SSH | `PUBLIC_KEY` or check logs for random password |

## 📁 Directory Structure

```
/workspace/runpod-slim/
├── ComfyUI/                          # ComfyUI installation
│   ├── models/
│   │   ├── diffusion_models/         # Flux 2 Klein 9B model
│   │   ├── checkpoints/LTX-Video/    # LTX-2 Distilled model
│   │   ├── text_encoders/            # Qwen 3 8B & Gemma 3 12B
│   │   └── vae/                       # VAE models
│   └── custom_nodes/                  # Custom nodes
├── comfyui_args.txt                   # Custom ComfyUI arguments
├── comfyui.log                        # ComfyUI logs
└── filebrowser.db                     # FileBrowser database
```

## 🛠️ Custom ComfyUI Arguments

Edit `/workspace/runpod-slim/comfyui_args.txt` to add custom arguments (one per line):

```
--max-batch-size 8
--preview-method auto
--highvram
```

## 📦 Pre-installed Custom Nodes

- [ComfyUI-Manager](https://github.com/ltdrdata/ComfyUI-Manager) - Install additional nodes
- [ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes) - Utility nodes
- [Civicomfy](https://github.com/MoonGoblinDev/Civicomfy) - CivitAI integration
- [ComfyUI-LTXVideo](https://github.com/Lightricks/ComfyUI-LTXVideo) - LTX-2 video support
- [ComfyUI-RunpodDirect](https://github.com/MadiatorLabs/ComfyUI-RunpodDirect) - RunPod direct integration

## 💻 Hardware Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| GPU VRAM | 24 GB | 32 GB+ |
| System RAM | 32 GB | 64 GB |
| Disk Space | 100 GB | 150 GB |

**Recommended GPUs**: A100, H100, RTX 6000 Ada, RTX 4090 (24GB may be tight)

## 🔄 Re-downloading Models

Models are downloaded on first boot and cached. To force re-download:

```bash
rm /workspace/runpod-slim/.models_downloaded
# Then restart the pod
```

## 📝 Logs

Check the logs if you encounter issues:

```bash
# ComfyUI logs
tail -f /workspace/runpod-slim/comfyui.log

# Jupyter logs
tail -f /jupyter.log

# FileBrowser logs
tail -f /filebrowser.log
```

## 🔗 Resources

- [Flux 2 Klein 9B on HuggingFace](https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-fp8)
- [LTX-2 on HuggingFace](https://huggingface.co/Lightricks/LTX-2)
- [ComfyUI Documentation](https://docs.comfy.org/)
- [ComfyUI Flux 2 Examples](https://comfyanonymous.github.io/ComfyUI_examples/flux2/)
- [RunPod Documentation](https://docs.runpod.io/)

## 📄 License

This template is based on [runpod-workers/comfyui-base](https://github.com/runpod-workers/comfyui-base) (GPL-3.0).

The models have their own licenses:
- **Flux 2 Klein 9B**: [FLUX Non-Commercial License](https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-fp8/blob/main/LICENSE.md)
- **LTX-2**: [LTX-2 License](https://huggingface.co/Lightricks/LTX-2/blob/main/LICENSE)
