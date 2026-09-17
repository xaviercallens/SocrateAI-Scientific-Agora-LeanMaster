#!/usr/bin/env bash
# Usage: papers/book/compile_chapter.sh chapters/ch07_circle.tex
# Compiles ONE chapter standalone (two pdfLaTeX passes) in its own build directory, so that
# several chapters can be compiled in parallel. Prints errors, undefined references and page count.
set -u
cd "$(dirname "$0")"
f="$1"; b="$(basename "${f%.tex}")"; d="build/$b"; mkdir -p "$d"
cat > "$d/wrap.tex" <<TEX
\documentclass[11pt,twoside,openany]{book}
\input{preamble}
\begin{document}
\input{$f}
\end{document}
TEX
for i in 1 2; do pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" "$d/wrap.tex" >/dev/null 2>&1; done
echo "== errors:";            grep -n -A3 "^! " "$d/wrap.log" | head -30
echo "== undefined:";         grep -n "undefined" "$d/wrap.log" | grep -v "^.*Font shape" | head -10
echo "== missing glyphs:";    grep -c "Missing character\|not set up for use with LaTeX" "$d/wrap.log"
grep -A2 "not set up for use with LaTeX" "$d/wrap.log" | head -6
echo "== overfull >15pt:";    grep -E "Overfull \\\\hbox \(([0-9]{3,}|1[5-9]|[2-9][0-9])\." "$d/wrap.log" | wc -l
echo "== pages:";             [ -f "$d/wrap.pdf" ] && pdfinfo "$d/wrap.pdf" | grep Pages || echo "NO PDF"
