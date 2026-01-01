# GaMO: Geometry-aware Multi-view Diffusion Outpainting for Sparse View 3D Reconstruction
[Teaser Video](./transition_result.mp4)
Installation1. Create Conda EnvironmentsBash# 1. 3DGS environment
conda env create -f env/env_3dgs.yml
# 2. GaMO environment
conda env create -f env/env_GaMO.yml
# 3. Mask/Init environment
conda env create -f env/env_mask.yml
2. Install Local KernelsBash# For 3dgs & mask environments
conda activate 3dgs # Repeat for 'mask' env
pip install -e 3dgs/submodules/diff-gaussian-rasterization
pip install -e 3dgs/submodules/simple-knn

# For GaMO environment
conda activate GaMO
pip install -e gamo/submodules/MASt3R-SLAM
pip install -e gamo/submodules/MASt3R-SLAM/thirdparty/mast3r
pip install -e gamo/submodules/MASt3R-SLAM/thirdparty/in3d
📥 Data Preparation & StructureEnsure your data in 3dgs/data/Input/Duster/ follows this exact hierarchy:Plaintext{ROOT}/{SCENE}/
├── images/            # Training images (.png)
├── images_test/       # Testing images (.png)
└── sparse/
    ├── 0/             # Training COLMAP files (cameras.txt, images.txt, etc.)
    └── test/          # Testing COLMAP files
🚀 Pipeline Execution StepsStep 0: Initial Pointcloud Generation (DUSt3R)Generate the base point cloud and place it into the sparse/0 directory.Environment: maskBashconda activate mask

# 1. Run DUSt3R initialization
bash Point.sh Replica_6 office_2

# 2. Setup directory and copy point cloud
mkdir -p 3dgs/data/Input/Duster/Replica_6/office_2/sparse/0
cp dust3r_results/Replica_6/office_2/sparse/0/points3D.ply \
   3dgs/data/Input/Duster/Replica_6/office_2/sparse/0/points3D.ply
Step 1: Initial 3DGS TrainingThis step automatically creates sparse/coarse with scaled camera parameters ($fx, fy \times 0.6$) and re-indexed IDs.Environment: 3dgsBashconda activate 3dgs
bash Pipeline.sh --step 1 Replica_6 office_2
Step 2: Mask Generation & OutpaintingPart A (Masks): mask environmentPart B (Outpaint): GaMO environmentBash# Part A: Render Masks
conda activate mask
bash Pipeline.sh --step 1b Replica_6 office_2

# Part B: Run GaMO Outpainting
conda activate GaMO
bash Pipeline.sh --step 2 Replica_6 office_2
Step 3: Alignment & Refinement InitializationPart A (Align): GaMO environmentPart B (Init): mask environmentBash# Part A: Align & Seed PLY
conda activate GaMO
bash Pipeline.sh --step 3 Replica_6 office_2

# Part B: Refined Pointcloud Initialization (Dust3R)
conda activate mask
bash Pipeline.sh --step 3.5 Replica_6 office_2
Step 4: Final RefinementEnvironment: 3dgsBashconda activate 3dgs
# Training
bash Pipeline.sh --step 4 Replica_6 office_2
# Rendering
bash Pipeline.sh --step 5 Replica_6 office_2
📊 Summary TableStepEnvironmentCommandDescription0maskPoint.shGenerate initial points3D.ply for sparse/013dgs--step 1Scale cameras to coarse, Train & Render GS1bmask--step 1bRender masks for outpainting2GaMO--step 2Run GaMO Outpainting (Mast3R)3GaMO--step 3Align images, blend GT, and seed PLY3.5mask--step 3.5Refined Pointcloud Init (Dust3R)43dgs--step 4Final refined GS training53dgs--step 5Final GS rendering