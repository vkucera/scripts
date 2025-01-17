#!/bin/bash

# Compile a LaTeX document and report warning and errors.

FileName=$(echo $1 | cut -f 1 -d .) # this should work on Linux and Mac OS X

echo "Cleaning"
"$(dirname $(realpath $0))"/latex-clean.sh

[ "${FileName}" ] || { echo "Please provide path to your LaTeX source file."; exit 1; }

[ -f "${FileName}.tex" ] || { echo "There is no file ${FileName}.tex"; exit 1; }

echo "Processing file ${FileName}.tex"

# run pdflatex, $1 = file.tex, $2 = pass_number
function run_pdflatex {
  command="pdflatex -interaction=nonstopmode --shell-escape"
  string="pdflatex pass $2"
  logfile="stdouterr-pdflatex$2.txt"
  if $command $1 > $logfile 2>&1; then
    echo "$string OK"
  else
    echo "$string failed"
    echo "LaTeX Errors:"
    grep "! " $logfile
    exit 1
  fi
  return 0
}

# run bibtex, $1 = file.aux
function run_bibtex {
  command="bibtex"
  string="bibtex"
  logfile="stdouterr-bibtex.txt"
  if $command $1 > $logfile 2>&1; then
    echo "$string OK"
  else
    echo "$string failed"
    echo "BibTeX Errors:"
    grep "error" $logfile
    exit 1
  fi
  echo "BibTeX warnings:"
  grep "Warning" $logfile
  echo ""
  return 0
}

run_pdflatex $FileName.tex 1
[ "$2" == "b" ] && echo "Skipping bibtex" || run_bibtex $FileName.aux
run_pdflatex $FileName.tex 2
run_pdflatex $FileName.tex 3
run_pdflatex $FileName.tex 4

echo "LaTeX warnings:"
grep "LaTeX Warning" $logfile
grep "bad" $logfile
echo ""
echo "Overfull warnings:"
grep -A 1 "too wide" $logfile
echo ""

echo "Package warnings:"
grep "Warning" $logfile | grep "Package"
echo ""

echo "Font warnings:"
grep -A 1 "LaTeX Font Warning:" $logfile
echo ""

echo "Cleaning"
"$(dirname $(realpath $0))"/latex-clean.sh
echo "Done!"

exit 0
