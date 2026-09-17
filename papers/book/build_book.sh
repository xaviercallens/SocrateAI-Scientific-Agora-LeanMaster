#!/usr/bin/env bash
# Build the whole book: papers/book/build_book.sh   → papers/book/The_Dual_Scale_String.pdf
set -u
cd "$(dirname "$0")"
python3 ../../tools/book_assemble.py
mkdir -p build/full/chapters
run() { pdflatex -interaction=nonstopmode -output-directory=build/full book.tex >/dev/null 2>&1; }
run; (cd build/full && makeindex -q book.idx 2>/dev/null); run; run
echo "== errors:";     grep -n -A3 "^! " build/full/book.log | head -40
echo "== undefined:";  grep -n "undefined" build/full/book.log | grep -v "Font shape" | sort -u | head -40
echo "== overfull >15pt:"; grep -cE "Overfull \\\\hbox \(([0-9]{3,}|1[5-9]|[2-9][0-9])\." build/full/book.log
[ -f build/full/book.pdf ] && cp build/full/book.pdf The_Dual_Scale_String.pdf && pdfinfo The_Dual_Scale_String.pdf | grep Pages
