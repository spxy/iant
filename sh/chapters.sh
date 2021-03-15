#!/bin/sh

set -e

tex_chapter_entry()
{
    printf "%s" "
\setcounter{chapter}{$(( $num - 1 ))}
\chapter{$title}
\section*{Notes on Chapter ${num#0}}
\input{tex/$num-notes}
\section*{Solutions to Chapter ${num#0} Exercises}
\input{tex/$num-exercises}
"
}

html_chapter_entry()
{
    printf '%s' "
  <li>Chapter ${num##0}: $title</li>
  <ul>
    <li>Notes [<a href=\"$num-notes.html\">html</a>] [<a href=\"$num-notes.pdf\">pdf</a>]</li>
    <li>Exercises [<a href=\"$num-exercises.html\">html</a>] [<a href=\"$num-exercises.pdf\">pdf</a>]</li>
  </ul>
"
}

tex_chapter_defs()
{
    job="$1"
    maintitle="$2"
    booktitle="Introduction to Analytic Number Theory (Apostol, 1976)"
    chaptertitle="Chapter ${num#0}: $title"
    printf '%s' "
\def\maintitle{$maintitle}
\def\chaptertitle{$chaptertitle}
\def\booktitle{$booktitle}
\def\job{$job}
"
}

main()
{
    mkdir -p tmp
    
    > tmp/chapters.tex
    > tmp/chapters.html

    while read -r line
    do
        num=$(echo "$line" | cut -d: -f1)
        title=$(echo "$line" | cut -d: -f2)

        tex_chapter_entry >> tmp/chapters.tex
        html_chapter_entry >> tmp/chapters.html
        tex_chapter_defs "$num-notes" "Chapter ${num#0} Notes" \
                         > tmp/"$num-notes-defs.tex"
        tex_chapter_defs "$num-exercises" "Chapter ${num#0} Exercises" \
                         > tmp/"$num-exercises-defs.tex"
    done < sh/chapters.txt
}

main "$@"
