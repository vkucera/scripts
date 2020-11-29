#!/bin/bash

# Identify file type and remove the file if it is an unwanted file.
# 2018-02-18

# https://stackoverflow.com/questions/14366390/check-if-an-element-is-present-in-a-bash-array
function array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

declare -a blacklist=( \
"application/octet-stream" \
"application/xml" \
"application/x-desktop" \
"application/x-executable" \
"application/x-dvi" \
"application/x-ms-dos-executable" \
"application/x-mswinurl" \
"application/x-object" \
"application/x-ole-storage" \
"application/x-sharedlib" \
"application/x-sqlite3" \
"text/html" \
#"text/plain" \
"text/x-zim-wiki" \
"image/x-tga" \
)

declare -a whitelist=( \
# documents
"text/plain" \
"text/x-tex" \
"application/pdf" \
"application/postscript" \
"application/rtf" \
"application/vnd.oasis.opendocument.spreadsheet" \ # .ods
"application/vnd.oasis.opendocument.text" \ # .odt
# graphics
"image/gif" \
"image/jpeg" \
"image/png" \
"image/svg+xml" \
"image/tiff" \
"image/x-eps" \
# audio
"audio/mpeg" \ # .mp3
"audio/ogg" \
"audio/x-wav" \
# video
"application/x-matroska" \ # .mkv
"video/mp4" \
"video/x-flv" \
"video/x-msvideo" \ # .avi
"video/ogg" \
# archives
"application/gzip" \
"application/x-rar" \
"application/x-tar" \
"application/zip" \
# code
"text/x-csrc" \
"text/x-c++hdr" \
"text/x-c++src" \
"application/x-shellscript" \
"text/x-python" \
)

file="$1"
[ -f "$file" ] || { echo "File $file does not exist."; exit 1; }

type="$(mimetype -biM "$file")"
#type="$(file -b --mime-type "$file")"

if array_contains blacklist "$type"; # Files of blacklisted types will be deleted.
#if ! array_contains whitelist "$type"; # Files of types other than whitelisted will be deleted.
then
  echo "Deleting $file $type."
  gio trash -f "$file" # throw the file into the trash bin
#else
#  echo "File $file is $type."
fi

exit 0

