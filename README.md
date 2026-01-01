# GaMO: Geometry-aware Multi-view Diffusion Outpainting for Sparse View 3D Reconstruction

[**Project Page**](https://yichuanh.github.io/GaMO/) ｜ [**ArXiv**](https://arxiv.org/abs/2512.25073)

<p align="center">
  <img src="2x4.gif" width="100%" />
</p>
<p align="center">
  <img src="teaser.png" width="100%" />
</p>

Official implementation of GaMO (version 1)


## Environment Setup
⚠️ Note: The project currently requires 3 separate conda environments because certain modules depend on incompatible library versions. A unified environment YAML will be released in the next update.

---

## Pretrained Models (Required)

Before running GaMO, make sure the pretrained weights exist under:

gamo/check_points/

Required:
- GaMO pretrained model  
  (Download) → [pretrained_model.zip](https://huggingface.co/ewrfcas/MVGenMaster/resolve/main/check_points/pretrained_model.zip)  
  Save to: `gamo/check_points/` (unzipped)
- DUSt3R ViTLarge checkpoint  
  (Download) → [DUSt3R_ViTLarge_BaseDecoder_512_dpt.pth](https://huggingface.co/ewrfcas/MVGenMaster/resolve/main/check_points/DUSt3R_ViTLarge_BaseDecoder_512_dpt.pth)  
  Save to: `gamo/check_points/`

---

Additional optional downloads (depending on your environment):
- Stable-Diffusion-2-1-base  
  → place under: `gamo/models/stable-diffusion-2-1-base/`  
  (Download) → [Stable-Diffusion-2-1-base](https://huggingface.co/Manojb/stable-diffusion-2-1-base)

- MASt3R model weights  
  → place under: `gamo/submodules/MASt3R-SLAM/thirdparty/mast3r/weights/`  
  (Download) → [MASt3R GitHub](https://github.com/naver/mast3r)


---

## Installation

### 1. Create conda environments

    # 1. 3DGS environment
    conda env create -f env/env_3dgs.yml

    # 2. GaMO environment
    conda env create -f env/env_GaMO.yml

    # 3. Mask / Init environment
    conda env create -f env/env_mask.yml

---

### 2. Install editable modules

    # For 3dgs and mask
    conda activate 3dgs
    pip install -e 3dgs/submodules/diff-gaussian-rasterization
    pip install -e 3dgs/submodules/simple-knn

    # For GaMO
    conda activate GaMO
    pip install -e gamo/submodules/MASt3R-SLAM
    pip install -e gamo/submodules/MASt3R-SLAM/thirdparty/mast3r
    pip install -e gamo/submodules/MASt3R-SLAM/thirdparty/in3d

---

## Data Preparation

Dataset must follow:

    3dgs/data/Input/Duster/{ROOT}/{SCENE}/
    ├── images/
    ├── images_test/
    └── sparse/
        ├── 0/
        └── test/

Example:

3dgs/data/Input/Duster/Replica_6/office_2/

---

## Pipeline Execution

### Step 0 — Initial DUSt3R pointcloud (mask env)

    conda activate mask
    bash Point.sh Replica_6 office_2
    mkdir -p 3dgs/data/Input/Duster/Replica_6/office_2/sparse/0
    cp dust3r_results/Replica_6/office_2/sparse/0/points3D.ply \
       3dgs/data/Input/Duster/Replica_6/office_2/sparse/0/

### Step 1 — Initial 3DGS Training (3dgs env)

    conda activate 3dgs
    bash Pipeline.sh --step 1 Replica_6 office_2

### Step 2 — Mask + GaMO Outpainting

    # masks
    conda activate mask
    bash Pipeline.sh --step 1b Replica_6 office_2

    # GaMO Outpaint
    conda activate GaMO
    bash Pipeline.sh --step 2 Replica_6 office_2

### Step 3 — Alignment + Seed Init

    conda activate GaMO
    bash Pipeline.sh --step 3 Replica_6 office_2

    conda activate mask
    bash Pipeline.sh --step 3.5 Replica_6 office_2

### Step 4 — Final Refinement + Rendering (3dgs)

    conda activate 3dgs
    bash Pipeline.sh --step 4 Replica_6 office_2
    bash Pipeline.sh --step 5 Replica_6 office_2

---

## Summary Table

Step | Environment | Command | Description
---- | ----------- | ------- | -----------
0 | mask | Point.sh | Initial DUSt3R pointcloud
1 | 3dgs | --step 1 | Scale cameras, train GS
1b | mask | --step 1b | Render masks
2 | GaMO | --step 2 | GaMO diffusion outpainting
3 | GaMO | --step 3 | Alignment / seed init
3.5 | mask | --step 3.5 | DUSt3R refined pointcloud
4 | 3dgs | --step 4 | Final GS training
5 | 3dgs | --step 5 | Final GS rendering

---

## Contact

If you encounter issues, open a GitHub Issue.
"""
