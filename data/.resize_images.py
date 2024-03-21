import json
from PIL import Image
import sys
import re

# export_pk = "453620"
export_pk = sys.argv[1]

def main():
    # Load the JSON data
    with open(f'{export_pk}_coco.json', 'r') as f:
        data = json.load(f)
    
    # Update the image dimensions
    for img_obj in data['images']:
        # UVM COMES FROM OLDER ANNOTATIONS
        if bool(re.match("0155zta11", img_obj['file_name'])) == False:
            with Image.open(img_obj['file_name']) as img:
                width, height = img.size
                img_obj['width'] = width
                img_obj['height'] = height

    # Save the updated data back to the JSON file
    with open(f'{export_pk}_coco.json', 'w') as f:
        json.dump(data, f, indent=4)

if __name__ == '__main__':
    main()