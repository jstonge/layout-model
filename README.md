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
│   ├── {export_pk}_cocos.json  
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
# {export_pk}_coco.json is a COCO formatted file, as exported from label-studio
{
    "images": [{..., "id": int, "file_name": PATH_IMAGE}],
    "categories": [{"id": int}],
    "annotations": [{..., image_id: int, category_id: int, "bbox": [x,y,w,h]}]
}
```

You can get this coco file from by first finding the proj `id`:

```
curl -H "Authorization: Token $LS_TOK" https://app.heartex.com/api/projects/
```

and then you can find `export_pk` by calling 

```
curl -H "Authorization: Token $LS_TOK" https://app.heartex.com/api/projects/{id}/exports/ 
```

then calling the following script located in `data/`:

```
sh .get_annotations.sh {export_pk}
```

### How to train the models? 

 - first do train-test split using `scripts/cocosplit.py`:

```
# if coco output from label-studio, it'll be something like
python cocosplit.py --annotation-path ../data/{export_pk}_coco.json --train ../data/train_{export_pk}.json --test ../data/test_{export_pk}.json --split-ratio 0.85
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
    --json_annotation_train ../data/train_{export_pk}.json \
    --image_path_train      ../data/images \
    --json_annotation_val   ../data/test_{export_pk}.json \
    --image_path_val        ../data/images \
    --config-file           ../configs/fast_rcnn_R_50_FPN_3x.yaml \
    OUTPUT_DIR  ../outputs-{export_pk}/ \
    SOLVER.IMS_PER_BATCH 2 
```

## Tips & Tricks when working with Detectron2

- Don't forget you can keep training from the last training checkpoint when new data. You'll need to adjust `MAX_ITER` if the previous run exhausted all the steps.
- If error about divergence, reducing the `LR_RATE` looks like it is helping.
- We can keep pages without annotations by changing the flag `FILTER_EMPTY_ANNOTATIONS: true`. 

## How to improve the output

- `BBOX -> text`: Make sure the bounding boxes really bound the text like you think. Sometimes this is finicky because token locations are imperfect. We export extracted text with pre-annotations to check for that in label-studio.
   - Doing another batch of pre-annotated annotation tasks is a good way to have a sense of what the predictions look like.
- `Balanced Dataset`: Make sure everything is balance in terms of _institutions_ and _epochs_, as well as in terms of _positive_ and _negative samples_ (aka pages with and without annotations).
- `Catalogs quality`: Check which institutions/years have the worst performance, trying to guess the pattersn (Is it about layout? Is it about PDF quality? Is it about the course object configuration?). One day, we will have `active learning` set up in label-studio so we don't have to do that manually (see [OLALA](https://aclanthology.org/2022.nlpcss-1.19.pdf)).

## Reference 

- **[cocosplit](https://github.com/akarazniewicz/cocosplit)**  A script that splits the coco annotations into train and test sets.
- **[Detectron2](https://github.com/facebookresearch/detectron2)** Detectron2 is Facebook AI Research's next generation software system that implements state-of-the-art object detection algorithms. 
