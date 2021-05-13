COMB_JOB = iant-solutions
COMB_PDF = $(COMB_JOB).pdf

all:
	make combined
	make pdfs
	make index
	make pages

01 02 03 04 05 06 07 08 09 10 11 12 13 14:
	make pdf N=$@
	make page N=$@

combined: chapters
	mkdir -p _site
	pdflatex -halt-on-error -jobname="$(COMB_JOB)" --output-directory=_site tex/combined
	make clean

index: chapters
	mkdir -p _site
	cp web/main.css _site
	> _site/index.html
	awk '/DOCTYPE html/,/begin chapters/' web/index.html >> _site/index.html
	cat tmp/chapters.html >> _site/index.html
	awk '/end chapters/,/html>/' web/index.html >> _site/index.html
	make clean

pdfs:
	for n in $$(cut -d: -f1 sh/chapters.txt); do make pdf N="$$n"; done

pdf: chapters
	mkdir -p _site
	cat tmp/"$(N)-defs.tex" tex/single.tex > tmp/"$(N).tex"
	pdflatex -halt-on-error -output-directory=_site tmp/"$(N).tex"
	make clean

pages:
	for n in $$(cut -d: -f1 sh/chapters.txt); do make page N="$$n"; done

page: chapters
	mkdir -p _site
	cat tmp/"$(N)-defs.tex" tex/single.tex > tmp/"$(N).tex"
	make4ht -d _site tmp/"$(N).tex" mathjax
	make decorate F="$(N).html"
	make clean

decorate:
	sed 's|</head>|<link rel="stylesheet" href="main.css"></head>|' "_site/$(F)" > "tmp/$(F)"
	mv "tmp/$(F)" "_site/$(F)"

chapters:
	sh sh/chapters.sh

mac-setup:
	# Need to update all, so that latex-bin is compatible with make4ht.
	sudo tlmgr update --self --all
	sudo tlmgr install make4ht luaxml tex4ht environ

deb-setup:
	sudo apt-get install texlive-latex-extra texlive-extra-utils texlive-luatex

view:
	if command -v xdg-open; then xdg-open "$(FILE)"; \
	elif command -v open; then open "$(FILE)"; fi

clean:
	rm -f *.lg _site/*.lg
	rm -f *.aux _site/*.aux
	rm -f *.log _site/*.log
	rm -f *.out _site/*.out
	rm -f *.idv _site/*.idv
	rm -f *.4ct _site/*.4ct
	rm -f *.4tc _site/*.4tc
	rm -f *.dvi _site/*.dvi
	rm -f *.tmp site/*.tmp
	rm -f *.xref _site/*.xref
	rm -f *.html
	rm -f *.css

live:
	git branch -D live || true
	git switch -f --orphan live
	git add _site/*
	git mv _site/* .
	git config user.name "live"
	git config user.email "live@localhost"
	git commit -m "Publish live ($$(date -u +"%Y-%m-%d %H:%M:%S"))"
	git log
	git push -f origin live
