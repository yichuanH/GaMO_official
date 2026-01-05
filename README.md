# GaMO: Geometry-aware Multi-view Diffusion Outpainting for Sparse View 3D Reconstruction

[**Project Page**](https://yichuanh.github.io/GaMO/) ｜ [**ArXiv**](https://arxiv.org/abs/2512.25073)

<p align="center">
  <img src="2x4.gif" width="100%" />
</p>
<p align="center">
  <img src="teaser.png" width="100%" />
</p>

Official implementation of GaMO (version 1)

## 🛠️ TODO
- ✅ Release multi-stage code and environment setups  
- ✅ Provide example dataset: `Replica_6/office_2`  
- ⬜ Merge multiple conda environments and resolve dependency incompatibilities  
- ⬜ Integrate a one-click bash script for end-to-end pipeline execution  
- ⬜ Add more evaluation datasets  


## Environment Setup
⚠️ Note: The project currently requires 3 separate conda environments because certain modules depend on incompatible library versions. A unified environment YAML will be released in the next update.

---

## Pretrained Models

Please download the following pretrained models and place them in the specified directories.

### PixelArt pretrained models

- **Pixel Art checkpoint** → place under: `PixelArt/`  
  (Download) → [Pixel Art checkpoint](https://drive.google.com/file/d/1VRYKQOsNlE1w1LXje3yTRU5THN2MGdMM/view?usp=sharing)

- **AliasNet checkpoint** → place under: `PixelArt/`  
  (Download) → [AliasNet checkpoint](https://drive.google.com/file/d/17f2rKnZOpnO9ATwRXgqLz5u5AZsyDvq_/view?usp=sharing)

---

### PixelArt auxiliary checkpoints

- **I2PNet checkpoint** → place under: `PixelArt/checkpoints/`  
  (Download) → [I2PNet checkpoint](https://drive.google.com/file/d/1i_8xL3stbLWNF4kdQJ50ZhnRFhSDh3Az/view?usp=sharing)

- **P2INet checkpoint** → place under: `PixelArt/checkpoints/`  
  (Download) → [P2INet checkpoint](https://drive.google.com/file/d/1z9SmQRPoIuBT_18mzclEd1adnFn2t78T/view?usp=sharing)

---

## Installation

### 1. Create conda environments

    # 1. 3DGS environment
    conda env create -f env/env_3dgs.yml

    # 2. GaMO environment
    conda env create -f env/env_GaMO.yml

    # 3. Mask / Init environment
    conda env create -f env/env_opamask.yml

---

### 2. Install editable modules

    # For 3dgs and opamask
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

### Step 0 — Initial DUSt3R pointcloud (opamask env)

    conda activate opamask
    bash Point.sh Replica_6 office_2
    mkdir -p 3dgs/data/Input/Duster/Replica_6/office_2/sparse/0
    cp dust3r_results/Replica_6/office_2/sparse/0/points3D.ply \
       3dgs/data/Input/Duster/Replica_6/office_2/sparse/0/

### Step 1 — Initial 3DGS Training (3dgs env)

    conda activate 3dgs
    bash Pipeline.sh --step 1 Replica_6 office_2

### Step 2 — Mask + GaMO Outpainting

    # masks
    conda activate opamask
    bash Pipeline.sh --step 1b Replica_6 office_2

    # GaMO Outpaint
    conda activate GaMO
    bash Pipeline.sh --step 2 Replica_6 office_2

### Step 3 — Alignment + Seed Init

    conda activate GaMO
    bash Pipeline.sh --step 3 Replica_6 office_2

    conda activate opamask
    bash Pipeline.sh --step 3.5 Replica_6 office_2

### Step 4 — Final Refinement + Rendering (3dgs)

    conda activate 3dgs
    bash Pipeline.sh --step 4 Replica_6 office_2
    bash Pipeline.sh --step 5 Replica_6 office_2

---

## Summary Table

Step | Environment | Command | Description
---- | ----------- | ------- | -----------
0 | opamask | Point.sh | Initial DUSt3R pointcloud
1 | 3dgs | --step 1 | Scale cameras, train GS
1b | opamask | --step 1b | Render masks
2 | GaMO | --step 2 | GaMO diffusion outpainting
3 | GaMO | --step 3 | Alignment / seed init
3.5 | opamask | --step 3.5 | DUSt3R refined pointcloud
4 | 3dgs | --step 4 | Final GS training
5 | 3dgs | --step 5 | Final GS rendering

---

## Contact

If you encounter issues, open a GitHub Issue.
"""
