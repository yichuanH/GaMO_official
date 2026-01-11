#!/usr/bin/env bash

# =================================================================
# Unified Environment Setup Script
# This script creates a single unified conda environment for the pipeline.
# =================================================================

set -e

# Color settings
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting installation of unified environment...${NC}"

# 1. Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo -e "${RED}❌ Error: conda command not found. Please install Anaconda or Miniconda first.${NC}"
    exit 1
fi

# 2. Create unified environment
echo -e "\n${GREEN}[1/2] Creating 'unified' environment...${NC}"
if conda env list | grep -q "unified"; then
    echo -e "${YELLOW}⚠️ Environment 'unified' already exists, skipping creation.${NC}"
else
    conda env create -f env/env_unified.yml
fi

# 3. Install editable modules
echo -e "\n${GREEN}[2/2] Installing editable modules into 'unified'...${NC}"

# Try to initialize conda for this script shell
eval "$(conda shell.bash hook)"

conda activate unified

# 3DGS submodules
echo -e "${GREEN}  -> Installing 3dgs submodules...${NC}"
if [ -d "3dgs/submodules/diff-gaussian-rasterization-confidence" ]; then
    pip install -e 3dgs/submodules/diff-gaussian-rasterization-confidence
elif [ -d "3dgs/submodules/diff-gaussian-rasterization" ]; then
    pip install -e 3dgs/submodules/diff-gaussian-rasterization
else
    echo -e "${YELLOW}⚠️ Warning: 3dgs/submodules/diff-gaussian-rasterization not found.${NC}"
fi

if [ -d "3dgs/submodules/simple-knn" ]; then
    pip install -e 3dgs/submodules/simple-knn
else
    echo -e "${YELLOW}⚠️ Warning: 3dgs/submodules/simple-knn not found.${NC}"
fi

# GaMO submodules
echo -e "${GREEN}  -> Installing GaMO submodules...${NC}"
if [ -d "gamo/submodules/MASt3R-SLAM" ]; then
    pip install -e gamo/submodules/MASt3R-SLAM
    pip install -e gamo/submodules/MASt3R-SLAM/thirdparty/mast3r
    pip install -e gamo/submodules/MASt3R-SLAM/thirdparty/in3d
else
    echo -e "${YELLOW}⚠️ Warning: gamo/submodules/MASt3R-SLAM not found. Make sure submodules are cloned.${NC}"
fi

echo -e "\n${GREEN}🎉 Unified environment installed successfully!${NC}"
echo "You can now run the pipeline using: bash Pipeline_unified.sh"
