#!/bin/bash
function usage {
    echo -e "\n Usage: ";
    echo " $0 --load path/to/directory";
    echo " $0 --save path/to/directory";
    exit 1;
}


if [ "$#" -ne 2 ]; then
    # Print usage if passed arguments are not 2
    usage;
elif [ "$1" = "--load" ]; then
    # Zip file to create
    ZIP_FILE=$2;
    # Temp folder where configuration will be extracted
    TEMP_FOLDER=$(echo $ZIP_FILE | sed 's/.zip/.d/g');
    
    echo " [+] Extracting zip file...";
    unzip $ZIP_FILE > /dev/null;

    # Moving to the temp directory    
    cd $TEMP_FOLDER;

    # Itering every file inside the temp directory
    # and apply the Settings Preferenes
    for filename in *; do
        DOMAIN=$(echo $filename | sed 's/.ei_config//g');
        echo " [+] Setting $DOMAIN ...";
        defaults import $DOMAIN $filename;
    done;

    echo " [ok] Settings applied!";
    # Going back to the last directory
    cd - > /dev/null;
    echo " [+] Cleaning temporary files...";
    # Removing temporary directory
    rm -rf $TEMP_FOLDER;

    echo " [ok] Done";
elif [ "$1" = "--save" ]; then
    # Temporary directory where to store Settings Preferences
    TEMP_FOLDER="$2.d";
    # Zip archive where to store Settings Preferences
    ZIP_FILE="$2.zip";

    # Creating temporary directory
    mkdir $TEMP_FOLDER;
    # Access to the temporary directory
    cd $TEMP_FOLDER;

    # Creating a list of Settings Preferences
    DOMAINS=$(defaults domains | tr -d " " | tr ", " "\n");
    # Iterating over the Settings Preferences
    while read -r line; do
        echo " [+] creating $line config ";
        # Saving the Preferences in file
        defaults export "$line" "$line.ei_config";
    done <<< "$DOMAINS";

    echo " [ok] Export completed!";
    # Going back to the last directory
    cd - > /dev/null;
    
    echo " [+] Creating zip file...";
    # Creating the zip file from the temporary directory
    zip -r $ZIP_FILE $TEMP_FOLDER > /dev/null;

    echo " [+] Cleaning temporary files...";
    # Removing temporary directory
    rm -rf $TEMP_FOLDER;

    echo " [ok] Done";
else
    echo "Invalid command. $1 $2";
    usage;
fi
