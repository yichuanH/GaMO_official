# GaMO: Geometry-aware Multi-view Diffusion Outpainting for Sparse View 3D Reconstruction

<p align="center">
  <img src="transition_result.gif" width="48%" />
  <img src="transition_result.gif" width="48%" />
</p>

<p align="center">
  <img src="teaser.png" width="60%" />
</p>

---

## 📦 Installation

### 1️⃣ Create Conda Environments
```bash
# 1. 3DGS environment
conda env create -f env/env_3dgs.yml

# 2. GaMO environment
conda env create -f env/env_GaMO.yml

# 3. Mask / Init environment
conda env create -f env/env_mask.yml
```

---

### 2️⃣ Install Local Editable Kernels
```bash
# For 3dgs & mask environments
conda activate 3dgs   # (repeat for 'mask' env)
pip install -e 3dgs/submodules/diff-gaussian-rasterization
pip install -e 3dgs/submodules/simple-knn

# For GaMO environment
conda activate GaMO
pip install -e gamo/submodules/MASt3R-SLAM
pip install -e gamo/submodules/MASt3R-SLAM/thirdparty/mast3r
pip install -e gamo/submodules/MASt3R-SLAM/thirdparty/in3d
```

---

## 📥 Data Preparation

Ensure your dataset follows this exact structure:

```
3dgs/data/Input/Duster/{ROOT}/{SCENE}/
├── images/            # Training images (.png)
├── images_test/       # Testing images (.png)
└── sparse/
    ├── 0/             # Training COLMAP files (cameras.txt, images.txt, ...)
    └── test/          # Testing COLMAP files
```

Example:
```
3dgs/data/Input/Duster/Replica_6/office_2/...
```

---

## 🚀 Pipeline Execution

### 🔰 Step 0 — Initial Pointcloud Generation (DUSt3R)
Environment: `mask`

```bash
conda activate mask

# 1. Run DUSt3R initialization
bash Point.sh Replica_6 office_2

# 2. Copy point cloud to COLMAP directory
mkdir -p 3dgs/data/Input/Duster/Replica_6/office_2/sparse/0
cp dust3r_results/Replica_6/office_2/sparse/0/points3D.ply \
   3dgs/data/Input/Duster/Replica_6/office_2/sparse/0/points3D.ply
```

---

### 🧱 Step 1 — Initial 3DGS Training
Automatically generates sparse/coarse with scaled $fx, fy × 0.6$ and re-indexed IDs.

Environment: `3dgs`
```bash
conda activate 3dgs
bash Pipeline.sh --step 1 Replica_6 office_2
```

---

### 🪄 Step 2 — Mask Generation & GaMO Outpainting
Part A: Render masks (mask env)  
Part B: Run GaMO diffusion outpainting (GaMO env)

```bash
# Part A — Masks
conda activate mask
bash Pipeline.sh --step 1b Replica_6 office_2

# Part B — GaMO Outpaint
conda activate GaMO
bash Pipeline.sh --step 2 Replica_6 office_2
```

---

### ⚙️ Step 3 — Alignment & Refinement Init
Part A: Alignment  
Part B: Refined pointcloud

```bash
# Part A — Align + Seed PLY w/ blended GT
conda activate GaMO
bash Pipeline.sh --step 3 Replica_6 office_2

# Part B — DUSt3R refined pointcloud
conda activate mask
bash Pipeline.sh --step 3.5 Replica_6 office_2
```

---

### 🎯 Step 4 — Final Refinement
Environment: `3dgs`

```bash
conda activate 3dgs

# Training
bash Pipeline.sh --step 4 Replica_6 office_2

# Rendering
bash Pipeline.sh --step 5 Replica_6 office_2
```

---

## 📊 Summary Table

| Step | Environment | Command | Description |
|------|-------------|---------|-------------|
| 0 | mask | `Point.sh` | Generate initial `points3D.ply` |
| 1 | 3dgs | `--step 1` | Scale cameras → train & render GS |
| 1b | mask | `--step 1b` | Render masks |
| 2 | GaMO | `--step 2` | GaMO diffusion outpainting |
| 3 | GaMO | `--step 3` | Align, blend GT, seed PLY |
| 3.5 | mask | `--step 3.5` | Refined pointcloud (DUSt3R) |
| 4 | 3dgs | `--step 4` | Final GS training |
| 5 | 3dgs | `--step 5` | Final GS rendering |

---

## 📮 Contact
If you experience issues, please open an Issue or reach out via GitHub.

```
