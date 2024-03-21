#!/bin/bash
#SBATCH --partition=dggpu
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --gpus=1
#SBATCH --mem=16G
#SBATCH --time=12:00:00
#SBATCH --job-name=fastRCNN
source ~/myconda.sh
conda activate catDB
module load gcc-9.3.0-gcc-7.3.0-fjzqkyt
python train_net.py \
    --dataset_name          cc \
    --json_annotation_train ../data/train_$1.json \
    --image_path_train      ../data/ \
    --json_annotation_val   ../data/test_$1.json \
    --image_path_val        ../data/ \
    --config-file           ../configs/fast_rcnn_R_50_FPN_3x.yaml \
    --config-file           ../configs/fast_rcnn_R_50_FPN_3x.yaml \
    OUTPUT_DIR  ../outputs-$1/ \
    SOLVER.IMS_PER_BATCH 2 
