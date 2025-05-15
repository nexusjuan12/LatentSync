#!/bin/bash

echo "🚀 Setting up LatentSync..."

# Check if system dependencies are installed
if command -v apt-get &> /dev/null; then
    echo "📦 Installing system dependencies..."
    apt-get update
    apt-get install -y libgl1-mesa-glx libglib2.0-0 libsm6 libxrender1 libxext6 ffmpeg build-essential
elif command -v yum &> /dev/null; then
    echo "📦 Installing system dependencies..."
    yum install -y mesa-libGL libXext libSM libXrender ffmpeg gcc-c++ make
elif command -v pacman &> /dev/null; then
    echo "📦 Installing system dependencies..."
    pacman -S --noconfirm mesa libxext libsm libxrender ffmpeg base-devel
else
    echo "⚠️ Unable to automatically install system dependencies."
    echo "Please install the equivalent of libgl1-mesa-glx, ffmpeg, and build-essential manually."
fi

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo "🔍 Conda not found. Installing Miniconda..."
    
    # Download Miniconda installer
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    
    # Install Miniconda
    bash miniconda.sh -b -p $HOME/miniconda
    
    # Add conda to path for current session
    export PATH="$HOME/miniconda/bin:$PATH"
    
    # Add conda to path permanently
    echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.bashrc
    
    # Initialize conda
    $HOME/miniconda/bin/conda init bash
    
    echo "✅ Conda installed successfully!"
else
    echo "✅ Conda is already installed."
fi

# Source bashrc to ensure conda commands work
source ~/.bashrc

# Clone your fork of the repository
echo "📥 Cloning LatentSync repository from your fork..."
git clone https://github.com/nexusjuan12/LatentSync.git
cd LatentSync

# Create and activate conda environment
echo "🔧 Creating conda environment..."
conda create -y -n latentsync python=3.10
eval "$(conda shell.bash hook)"
conda activate latentsync

# Install PyTorch and torchvision with correct versions
echo "📦 Installing PyTorch and torchvision..."
conda install -y pytorch==2.0.1 torchvision==0.15.2 torchaudio==2.0.2 pytorch-cuda=11.7 -c pytorch -c nvidia

# Create modified requirements.txt without the problematic packages
echo "📝 Creating modified requirements.txt..."
grep -v "torch\|torchvision\|torchaudio" requirements.txt > requirements_modified.txt

# Install dependencies 
echo "📦 Installing dependencies..."
pip install -r requirements_modified.txt
pip install huggingface_hub

# Now install insightface separately with specific version known to work
echo "📦 Installing insightface..."
pip install insightface==0.7.3

# Download model checkpoints
echo "🔽 Downloading model checkpoints..."
mkdir -p checkpoints/whisper

# Download models using Python
python -c "
from huggingface_hub import hf_hub_download
import os

# Create directories
os.makedirs('checkpoints/whisper', exist_ok=True)

# Download latentsync_unet.pt
print('Downloading latentsync_unet.pt...')
try:
    hf_hub_download(repo_id='ByteDance/LatentSync-1.5', 
                    filename='latentsync_unet.pt', 
                    local_dir='checkpoints',
                    local_dir_use_symlinks=False)
    print('✅ Successfully downloaded latentsync_unet.pt')
except Exception as e:
    print(f'❌ Error downloading latentsync_unet.pt: {e}')

# Download whisper tiny.pt
print('Downloading whisper/tiny.pt...')
try:
    hf_hub_download(repo_id='ByteDance/LatentSync-1.5', 
                    filename='whisper/tiny.pt', 
                    local_dir='checkpoints',
                    local_dir_use_symlinks=False)
    print('✅ Successfully downloaded whisper/tiny.pt')
except Exception as e:
    print(f'❌ Error downloading whisper/tiny.pt: {e}')

# Download syncnet (optional)
try:
    print('Downloading stable_syncnet.pt...')
    hf_hub_download(repo_id='ByteDance/LatentSync-1.5', 
                    filename='stable_syncnet.pt', 
                    local_dir='checkpoints',
                    local_dir_use_symlinks=False)
    print('✅ Successfully downloaded stable_syncnet.pt')
except Exception as e:
    print(f'⚠️ Warning: Could not download SyncNet: {e}')
"

echo "
✨ LatentSync setup completed! ✨

To use LatentSync:
1. Activate the environment: conda activate latentsync
2. Run the Gradio app: python gradio_app.py

Enjoy using LatentSync! 🎬
"
