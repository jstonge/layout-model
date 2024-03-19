#!/bin/bash


# Check if exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <id> <export_pk>"
    exit 1
fi

# Assign the first and second argument to id and export_pk respectively
id=$1
export_pk=$2

# DOWNLOAD annotations for a given export from label-studio

base_url="https://app.heartex.com/api/projects"
auth_token=$LS_TOK
curl "${base_url}/${id}/exports/${export_pk}/download?exportType=COCO" -H "Authorization: Token $auth_token" > tmp.zip


# UNZIP downloaded file

unzip tmp.zip
mv result.json "${id}_${export_pk}_coco.json"
rm tmp.zip


# DOWNLOAD the relevant images from mongoDB

cd images/
python .get_png_kitty.py "${id}" "${export_pk}"


# UPDATE the image dimensions in the JSON file.

cd ..
python -c "
import json
from PIL import Image

# Load the JSON data
with open('${id}_${export_pk}_coco.json', 'r') as f:
    data = json.load(f)

# Update the image dimensions
for img_obj in data['images']:
    with Image.open(img_obj['file_name']) as img:
        width, height = img.size
        img_obj['width'] = width
        img_obj['height'] = height

# Save the updated data back to the JSON file
with open('${id}_${export_pk}_coco.json', 'w') as f:
    json.dump(data, f, indent=4)
"

echo "Operation completed. The file is named ${id}_${export_pk}_coco.json"
