import kitty
import json
from pathlib import Path
import sys

def main():
    export_pk = sys.argv[1]
    cat_db = kitty.catDB()
    with open(f"../{export_pk}/{export_pk}_coco.json") as f:
        dat=json.loads(f.read())
    png_ids = [Path(_['file_name']).stem for _ in dat['images']]
    [cat_db.find_one_gridfs(png_id, collection="cc_png", save_loc=True) for png_id in png_ids]

if __name__ == '__main__':
    main()