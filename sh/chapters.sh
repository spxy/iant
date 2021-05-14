#!/bin/sh

set -e

tex_chapter_entry()
{
    if printf '%s' "$num" | grep -q '^[0-9]*$'
    then
        printf "%s" "
\setcounter{chapter}{$(( $num - 1 ))}
\chapter{$title}
\input{tex/$num}
"
    else
        printf "%s" "
\appendix
\chapter{Appendix}
\input{tex/$num}
"
    fi
}

html_chapter_entry()
{
    printf '%s' "
  <li>Chapter ${num##0}: $title [<a href=\"$num.html\">html</a>] [<a href=\"$num.pdf\">pdf</a>]</li>
"
}

tex_chapter_defs()
{
    job="$1"
    booktitle="Introduction to Analytic Number Theory (Apostol, 1976)"
    chaptertitle="Chapter ${num#0}: $title"
    printf '%s' "
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
        tex_chapter_defs "$num" > tmp/"$num-defs.tex"
    done < sh/chapters.txt
}

main "$@"
