#!/bin/bash
# ============================================================================
# Model Download Script for ComfyUI
# Downloads Flux 2 Klein 9B and LTX-2 Distilled models
# ============================================================================

set -e

COMFYUI_DIR="${COMFYUI_DIR:-/workspace/runpod-slim/ComfyUI}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
echo_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
echo_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check for HuggingFace token
check_hf_token() {
    if [ -z "$HF_TOKEN" ]; then
        echo_error "HF_TOKEN environment variable is not set!"
        echo_warning "The Flux 2 Klein 9B model requires a HuggingFace token."
        echo_info "Please:"
        echo_info "  1. Go to https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-fp8"
        echo_info "  2. Accept the license agreement"
        echo_info "  3. Create a token at https://huggingface.co/settings/tokens"
        echo_info "  4. Set HF_TOKEN in your RunPod template environment variables"
        return 1
    fi
    
    # Login to HuggingFace
    echo_info "Logging into HuggingFace..."
    huggingface-cli login --token "$HF_TOKEN" --add-to-git-credential
    echo_success "HuggingFace login successful!"
    return 0
}

# Create model directories
create_directories() {
    echo_info "Creating model directories..."
    mkdir -p "$COMFYUI_DIR/models/diffusion_models"
    mkdir -p "$COMFYUI_DIR/models/text_encoders"
    mkdir -p "$COMFYUI_DIR/models/vae"
    mkdir -p "$COMFYUI_DIR/models/checkpoints/LTX-Video"
    echo_success "Directories created!"
}

# Download a file if it doesn't exist
download_file() {
    local repo="$1"
    local filename="$2"
    local dest_dir="$3"
    local dest_filename="${4:-$filename}"
    
    local dest_path="$dest_dir/$dest_filename"
    
    if [ -f "$dest_path" ]; then
        echo_info "✓ $dest_filename already exists, skipping..."
        return 0
    fi
    
    echo_info "Downloading $filename from $repo..."
    huggingface-cli download "$repo" "$filename" --local-dir "$dest_dir" --local-dir-use-symlinks False
    
    # Rename if needed
    if [ "$filename" != "$dest_filename" ] && [ -f "$dest_dir/$filename" ]; then
        mv "$dest_dir/$filename" "$dest_path"
    fi
    
    echo_success "Downloaded $dest_filename!"
}

# Download Flux 2 Klein 9B models
download_flux2_klein() {
    echo ""
    echo_info "=========================================="
    echo_info "Downloading Flux 2 Klein 9B Models (FP8)"
    echo_info "=========================================="
    
    # Diffusion model (gated - requires HF_TOKEN)
    echo_info "Downloading Flux 2 Klein 9B diffusion model (9.43 GB)..."
    download_file \
        "black-forest-labs/FLUX.2-klein-9b-fp8" \
        "flux-2-klein-9b-fp8.safetensors" \
        "$COMFYUI_DIR/models/diffusion_models"
    
    # Text encoder (Qwen 3 8B FP8)
    echo_info "Downloading Qwen 3 8B text encoder (8.66 GB)..."
    download_file \
        "Comfy-Org/flux2-klein-9B" \
        "split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors" \
        "$COMFYUI_DIR/models/text_encoders" \
        "qwen_3_8b_fp8mixed.safetensors"
    
    # VAE
    echo_info "Downloading Flux 2 VAE (~300 MB)..."
    download_file \
        "Comfy-Org/flux2-klein-9B" \
        "split_files/vae/flux2-vae.safetensors" \
        "$COMFYUI_DIR/models/vae" \
        "flux2-vae.safetensors"
    
    echo_success "Flux 2 Klein 9B models downloaded!"
}

# Download LTX-2 Distilled models
download_ltx2() {
    echo ""
    echo_info "=========================================="
    echo_info "Downloading LTX-2 Distilled Models (FP8)"
    echo_info "=========================================="
    
    # Main checkpoint (distilled FP8)
    echo_info "Downloading LTX-2 19B Distilled checkpoint (27.1 GB)..."
    download_file \
        "Lightricks/LTX-2" \
        "ltx-2-19b-distilled-fp8.safetensors" \
        "$COMFYUI_DIR/models/checkpoints/LTX-Video"
    
    # Text encoder (Gemma 3 12B IT FP8)
    echo_info "Downloading Gemma 3 12B IT text encoder (13.2 GB)..."
    download_file \
        "Comfy-Org/ltx-2" \
        "split_files/text_encoders/gemma_3_12B_it_fp8_scaled.safetensors" \
        "$COMFYUI_DIR/models/text_encoders" \
        "gemma_3_12B_it_fp8_scaled.safetensors"
    
    echo_success "LTX-2 Distilled models downloaded!"
}

# Main function
main() {
    echo ""
    echo_info "=============================================="
    echo_info "  ComfyUI Model Downloader"
    echo_info "  Flux 2 Klein 9B + LTX-2 Distilled"
    echo_info "=============================================="
    echo ""
    
    # Check HF token
    if ! check_hf_token; then
        echo_error "Cannot proceed without HuggingFace token."
        echo_warning "LTX-2 models (not gated) will still be downloaded."
        echo ""
        
        # Create directories
        create_directories
        
        # Download LTX-2 only (not gated)
        download_ltx2
        
        echo ""
        echo_warning "Flux 2 Klein 9B models were NOT downloaded."
        echo_warning "Set HF_TOKEN and restart the pod to download them."
        return 1
    fi
    
    # Create directories
    create_directories
    
    # Download all models
    download_flux2_klein
    download_ltx2
    
    echo ""
    echo_success "=============================================="
    echo_success "  All models downloaded successfully!"
    echo_success "=============================================="
    echo ""
    echo_info "Model locations:"
    echo_info "  Flux 2 Klein 9B: $COMFYUI_DIR/models/diffusion_models/"
    echo_info "  LTX-2 Distilled: $COMFYUI_DIR/models/checkpoints/LTX-Video/"
    echo_info "  Text Encoders:   $COMFYUI_DIR/models/text_encoders/"
    echo_info "  VAE:             $COMFYUI_DIR/models/vae/"
    echo ""
}

# Run main function
main "$@"
