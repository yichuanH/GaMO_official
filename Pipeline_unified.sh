#!/usr/bin/env bash
# File: Pipeline_unified.sh
set -euo pipefail

# Load common configurations and functions
source "$(dirname "${BASH_SOURCE[0]}")/pipeline_common.sh"

show_usage() {
    echo "Usage: bash Pipeline_unified.sh --step [1|1b|2|3|3.5|4|5] [ROOT_NAME] [SCENE_NAME]"
    echo ""
    echo "Example: bash Pipeline_unified.sh --step 1 Replica_6 office_2"
    echo ""
    echo "This script runs all steps in the 'unified' environment."
    echo ""
    echo "Step Description:"
    echo "  1  : Initial 3DGS Training/Rendering"
    echo "  1b : Mask Generation"
    echo "  2  : GaMO Outpainting"
    echo "  3  : Alignment & Pointcloud Init"
    echo "  3.5: Pointcloud Init (Dust3R)"
    echo "  4  : Refine Training"
    echo "  5  : Refine Rendering"
}

check_env() {
    local expected="$1"
    if [[ "${CONDA_DEFAULT_ENV:-}" != "$expected" ]]; then
        echo "❌ Environment Mismatch!"
        echo "Current environment: ${CONDA_DEFAULT_ENV:-None}"
        echo "Expected environment: $expected"
        echo "Please run: conda activate $expected"
        exit 1
    fi
}

# Always expect unified environment
check_env "unified"

STEP=""
ROOT_NAME=""
SCENE_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --step)
            STEP="$2"
            shift 2
            if [[ $# -gt 0 && ! $1 == --* ]]; then
                ROOT_NAME="$1"; shift
            fi
            if [[ $# -gt 0 && ! $1 == --* ]]; then
                SCENE_NAME="$1"; shift
            fi
            ;;
        --root)
            ROOT_NAME="$2"
            shift 2
            ;;
        *)
            show_usage; exit 1
            ;;
    esac
done

if [[ -z "$STEP" || -z "$ROOT_NAME" ]]; then
    echo "❌ Error: Missing Step or Root Name."
    show_usage; exit 1;
fi

echo "📍 Target: Root=${ROOT_NAME}, Scene=${SCENE_NAME:-ALL_IN_CONFIG} (Env: unified)"

case "$STEP" in
    1)
        run_with_timer "Step 1: Initial 3DGS" step_initial_3dgs "$ROOT_NAME" "$SCENE_NAME"
        ;;
    1b)
        run_with_timer "Step 1b: Render Masks" step_render_masks "$ROOT_NAME" "$SCENE_NAME"
        ;;
    2)
        run_with_timer "Step 2: Outpaint" step_outpaint "$ROOT_NAME" "$SCENE_NAME"
        ;;
    3)
        # Note: Step 3 includes a call to step_refine_align and step_seed_pointcloud_from_3dgs
        run_with_timer "Step 3a: Refine Align & Seed" \
            bash -c "source $(dirname "${BASH_SOURCE[0]}")/pipeline_common.sh && step_refine_align $ROOT_NAME $SCENE_NAME && step_seed_pointcloud_from_3dgs $ROOT_NAME $SCENE_NAME"

        if should_run_pointcloud_init; then
             echo "-------------------------------------------------------"
             echo "👉 Part A (Alignment) finished."
             echo "👉 Part B (Pointcloud Init) continues in unified environment."
             echo "-------------------------------------------------------"
             # Since we are unified, we can just run it.
             # However, the original script asked user to switch env.
             # We can chain it here or ask user to run 3.5.
             # Ideally, we chain it if unified.
             # But let's follow the convention of separate steps if desired,
             # or we can print message.
             # The original code printed instructions.
             # Here we can just say "Run step 3.5 next".
             echo "Please run: bash Pipeline_unified.sh --step 3.5 $ROOT_NAME $SCENE_NAME"
        fi
        ;;
    3.5)
        run_with_timer "Step 3.5: Pointcloud Init (Dust3R)" step_pointcloud_init "$ROOT_NAME" "$SCENE_NAME"
        ;;
    4)
        run_with_timer "Step 4: Refine Train" step_refine_train "$ROOT_NAME" "$SCENE_NAME"
        ;;
    5)
        run_with_timer "Step 5: Refine Render" step_refine_render "$ROOT_NAME" "$SCENE_NAME"
        ;;
    *)
        echo "Invalid step: $STEP"
        show_usage
        exit 1
        ;;
esac
