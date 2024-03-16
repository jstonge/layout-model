# Scripts for training Layout Detection Models using Detectron2

Borrowed from on [Layout-Parser](https://github.com/Layout-Parser/layout-model-training/tree/master).

### Directory Structure

Something like:

```
layout-model  
├── configs
│   └── fast_rcnn_R_50_FPN_3x.yaml  
├── data    
│   ├── images
│   │   └── *.jpg 
│   ├── results.json  
│   ├── train.json  
│   └── test.json  
├── outputs     
└── scripts
    ├── cocosplit.py
    ├── train_net.py
    └── train_VACC.ipynb   
```

where

```
# result.json is a COCO formatted file, as exported from label-studio
{
    "images": [{..., "id": int, "file_name": PATH_IMAGE}],
    "categories": [{"id": int}],
    "annotations": [{..., image_id: int, category_id: int, "bbox": [x,y,w,h]}]
}
```

### How to train the models? 

 - first do train-test split using `scripts/cocosplit.py`:

```
# if coco output from label-studio, it'll be something like
python cocosplit.py --annotation-path ../data/result.json \
                    --train ../data/train.json 
                    --test ../data/test.json --split-ratio 0.85
```

 - then run `train_prima.sh`, which might look like for people running on the VACC:

```
#!/bin/bash
#SBATCH --partition=dggpu
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --gpus=1
#SBATCH --mem=30G
#SBATCH --time=12:00:00

python train_net.py \
    --dataset_name          cc \
    --json_annotation_train ../data/train.json \
    --image_path_train      ../data/images \
    --json_annotation_val   ../data/test.json \
    --image_path_val        ../data/images \
    --config-file           ../configs/fast_rcnn_R_50_FPN_3x.yaml \
    OUTPUT_DIR  ../outputs/ \
    SOLVER.IMS_PER_BATCH 2 
```

## Reference 

- **[cocosplit](https://github.com/akarazniewicz/cocosplit)**  A script that splits the coco annotations into train and test sets.
- **[Detectron2](https://github.com/facebookresearch/detectron2)** Detectron2 is Facebook AI Research's next generation software system that implements state-of-the-art object detection algorithms. 