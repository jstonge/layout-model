#!/bin/bash


# Check if exactly two arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <export_pk>"
    exit 1
fi

# Assign the first and second argument to id and export_pk respectively
export_pk=$1

# DOWNLOAD annotations for a given export from label-studio

base_url="https://app.heartex.com/api/projects"
auth_token=$LS_TOK
curl "${base_url}/58960/exports/${export_pk}/download?exportType=COCO" -H "Authorization: Token $auth_token" > tmp.zip


# Check if the downloaded file is a ZIP file
file_type=$(file tmp.zip)

# Check for ZIP file
if [[ $file_type == *"Zip archive data"* ]]; then
    echo "The file is a ZIP archive. Continuing with processing."
    
    # UNZIP downloaded file
    echo "UNZIP RESULTS"
    unzip tmp.zip
    mv result.json "${export_pk}_coco.json" && rm tmp.zip

    mkdir "${export_pk}" && mv "${export_pk}_coco.json" "${export_pk}"
    
    # DOWNLOAD the relevant images from mongoDB
    # echo "DOWNLOAD FROM MONGODB"
    cd images/
    python .get_png_kitty.py "${export_pk}"


    # UPDATE the image dimensions in the JSON file.
    # echo "UPDATING IMG DIMS"
    cd ..
    python .resize_images.py "${export_pk}/${export_pk}_coco.json"

elif [[ $file_type == *"JSON data"* ]]; then
    echo "The file is a JSON file. Printing contents and exiting."
    cat tmp.zip
    rm tmp.zip
    exit 0
else
    echo "The downloaded file is neither a ZIP archive nor a JSON file. Exiting."
    rm tmp.zip
    exit 1
fi

echo "Operation completed. The file is named ${id}_${export_pk}_coco.json"
