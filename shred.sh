#!/bin/bash

# Shred files and directories.

for file in "$@"; do # loop over arguments
  if [ ! -f "${file}" ]; then # file does not exist
    if [ -d "${file}" ]; then # argument is a name of a directory
      "$(dirname "$(realpath "$0")")"/shreddir.sh "${file}"
    else
      echo "File ${file} does not exist."
      exit 1
    fi
  else
    Size=$(du -b "${file}" | cut -f1) # size of the file in bytes
    SizeH=$(du -bh "${file}" | cut -f1) # size of the file in human-readable form
    if (("$Size" < "1000000")); then # file has less than 1 MB
      echo "Shredding file: ${file} (small file, $SizeH)"
      shred -n 1 "${file}" # overwrite with random data
      sync # force a sync of the buffers to the disk (flush buffers), source: http://stackoverflow.com/questions/10377393/deleting-files-permanently-and-securely-on-centos
      shred -n 0 -z -u "${file}" # overwrite with zeroes and remove the file
    else
      echo "Shredding file: ${file} (big file, $SizeH)"
      shred -n 1 -z -u "${file}" # overwrite with random data, with zeroes and remove the file
    fi
  fi
done # end of loop over argument

exit 0
