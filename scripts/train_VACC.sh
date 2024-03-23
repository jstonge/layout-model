#!/bin/bash
#SBATCH --partition=dggpu
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --gpus=1
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --job-name=fastRCNN
#SBATCH --output=slurms/%x_%j.out
source ~/myconda.sh
conda activate catDB
module load gcc-9.3.0-gcc-7.3.0-fjzqkyt

export_pk=$1

# Check if two arguments were provided
if [ "$#" -eq 2 ]; then
    export_pk_old=$1
    export_pk_new=$2
    python train_net.py \
        --dataset_name          cc \
        --json_annotation_train "../data/${export_pk_new}/train_${export_pk_new}.json" \
        --image_path_train      ../data/ \
        --json_annotation_val   "../data/${export_pk_new}/test_${export_pk_new}.json" \
        --image_path_val        ../data/ \
        --config-file           ../configs/fast_rcnn_R_50_FPN_3x.yaml \
        OUTPUT_DIR  "../outputs/${export_pk_old}/" \
        SOLVER.IMS_PER_BATCH 2 
else
    python train_net.py \
        --dataset_name          cc \
        --json_annotation_train "../data/${export_pk}/train_${export_pk}.json" \
        --image_path_train      ../data/ \
        --json_annotation_val   "../data/${export_pk}/test_${export_pk}.json" \
        --image_path_val        ../data/ \
        --config-file           ../configs/fast_rcnn_R_50_FPN_3x.yaml \
        OUTPUT_DIR  "../outputs/${export_pk}/" \
        SOLVER.IMS_PER_BATCH 2 
fi
