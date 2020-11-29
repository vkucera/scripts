#!/bin/bash

# Delete temporary files created by LaTeX compilation in the current directory.

Dir="$PWD"
[ "$1" ] && Dir="$1"

find "$Dir" -maxdepth 1 -type f \( \
-name "*~" \
-o -name "*.acn" \
-o -name "*.acr" \
-o -name "*.alg" \
-o -name "*.aux" \
-o -name "*.bak" \
-o -name "*.bbl" \
-o -name "*.blg" \
-o -name "*.cpt" \
-o -name "*.dvi" \
-o -name "*.ent" \
-o -name "*.fdb_latexmk" \
-o -name "*.fls" \
-o -name "*.glg" \
-o -name "*.glo" \
-o -name "*.gls" \
-o -name "*.idx" \
-o -name "*.ilg" \
-o -name "*.ind" \
-o -name "*.ist" \
-o -name "*.lof" \
-o -name "*.log" \
-o -name "*.lot" \
-o -name "*.mtc" \
-o -name "*.nav" \
-o -name "*.nlo" \
-o -name "*.nls" \
-o -name "*.out" \
-o -name "*.ps" \
-o -name "*.ptc" \
-o -name "*.snm" \
-o -name "*.spl" \
-o -name "stdouterr*" \
-o -name "*.synctex.gz" \
-o -name "*.toc" \
-o -name "*.vrb" \
-o -name "*.xdy" \
\) -delete

exit 0
