COMB_JOB = iant-notes-soln
COMB_PDF = $(COMB_JOB).pdf

all:
	make combined
	make pdfs
	make index
	make pages

combined: chapters
	mkdir -p out
	pdflatex -jobname="$(COMB_JOB)" --output-directory=out tex/combined
	make clean

index: chapters
	mkdir -p out
	cp web/main.css out
	> out/index.html
	awk '/DOCTYPE html/,/begin chapters/' web/index.html >> out/index.html
	cat tmp/chapters.html >> out/index.html
	awk '/end chapters/,/html>/' web/index.html >> out/index.html
	make clean

pdfs:
	mkdir -p out
	for n in $$(cut -d: -f1 sh/chapters.txt); do make pdf N="$$n"; done

pdf: chapters
	cat tmp/"$(N)-notes-defs.tex" tex/single.tex > tmp/"$(N)-notes.tex"
	cat tmp/"$(N)-exercises-defs.tex" tex/single.tex > tmp/"$(N)-exercises.tex"
	pdflatex -output-directory=out tmp/"$(N)-notes.tex"
	pdflatex -output-directory=out tmp/"$(N)-exercises.tex"
	make clean

pages:
	mkdir -p out
	for n in $$(cut -d: -f1 sh/chapters.txt); do make page N="$$n"; done

page: chapters
	cat tmp/"$(N)-notes-defs.tex" tex/single.tex > tmp/"$(N)-notes.tex"
	cat tmp/"$(N)-exercises-defs.tex" tex/single.tex > tmp/"$(N)-exercises.tex"
	make4ht -d out tmp/"$(N)-notes.tex" mathjax
	make4ht -d out tmp/"$(N)-exercises.tex" mathjax
	make decorate F="$(N)-notes.html"
	make decorate F="$(N)-exercises.html"
	make clean

decorate:
	sed 's|</head>|<link rel="stylesheet" href="main.css"></head>|' "out/$(F)" > "tmp/$(F)"
	mv "tmp/$(F)" "out/$(F)"

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
	rm -f *.aux out/*.aux
	rm -f *.log out/*.log
	rm -f *.out out/*.out
	rm -f *.idv out/*.idv
	rm -f *.lg out/*.lg
	rm -f *.4ct out/*.4ct
	rm -f *.4tc out/*.4tc
	rm -f *.dvi out/*.dvi
	rm -f *.xref out/*.xref
	rm -f *.css *.html *.tmp

live:
	git branch -D live || true
	git switch -f --orphan live
	mv out/* .
	git config user.name "live"
	git config user.email "live@localhost"
	git add .
	git commit -m "Publish live ($(date -u +"%Y-%m-%d %H:%M:%S"))"
	git log
	git push -f origin live
