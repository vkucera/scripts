#!/usr/bin/env python

# Take a list of text files and show which lines occur in which files.
# 2017-06-16 Vit Kucera
# 2018-06-21 Vit Kucera

import sys

# Read list of files from the input file.
fileIn = ""
try:
    nameFileIn = sys.argv[1]
except IndexError:
    print("Please specify an input file.")
    sys.exit()
print("Input file:", nameFileIn)
listFiles = []
try:
    with open(nameFileIn, encoding="utf-8") as fileIn:
        for line in fileIn:
            line = line.strip()  # get rid of \n  # noqa: PLW2901
            if len(line):
                listFiles.append(line)
except OSError:
    print(f"Failed to open file: {nameFileIn:s}.")
    sys.exit()
nFilesTot = len(listFiles)
print("Files to process:", nFilesTot)

# Declare the dictionary
table = {}
indexFile = 0
listFilesOK = []

# For each file in the list
for path in listFiles:
    print(f"Processing file: {path:s} ({indexFile:d})")
    try:
        with open(path, encoding="utf-8") as fileListOfLines:
            # For each line in the file
            for line in fileListOfLines:
                line = line.strip()  # get rid of \n  # noqa: PLW2901
                # If the string is not a key in the dict, add it and create a new list for it.
                if line not in table:
                    table[line] = []
                # Append the file number to the value array for the corresponding key in the dict.
                table[line].append(indexFile)
        indexFile += 1
        listFilesOK.append(path)
    except OSError:
        print("Failed")
        continue

print("Processed files:", indexFile)

# Print out a table specifying occurence of each line (table row) in each file (table column).
header = ""
for i in listFilesOK:
    header += f"\t{i}"
print(header)
header = ""
for i in range(0, indexFile):
    header += f"\t{i}"
print(header)
for key in sorted(table.keys()):
    line = key
    for i in range(0, indexFile):
        line += f"\t{1 if i in table[key] else 0}"
    print(line)
