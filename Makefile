COMB_JOB = iant-solutions
COMB_PDF = $(COMB_JOB).pdf

all:
	make pdf
	make htmls

htmls:
	make html F=01
	make html F=05
	make html F=A

1 2 3 4 5 6 7 8 9:
	make 0$@

01 02 03 04 05 06 07 08 09 10 11 12 13 14 A:
	make html F=$@

pdf: static
	pdflatex -halt-on-error -jobname="$(COMB_JOB)" --output-directory=_site tex/book
	pdflatex -halt-on-error -jobname="$(COMB_JOB)" --output-directory=_site tex/book
	make clean

apref:
	grep applabel tex/A.tex | awk -F '{|}' '{print "\\def\\num" $$2 "{" NR "}"}' > A.ref

html: static apref
	make4ht -j "$(F)" -d _site tex/single mathjax '' '' '\\def\\htmlmode{}\\def\\F{$(F)}'
	make decorate F="$(F)"
	make clean

static:
	mkdir -p _site
	cp web/index.html web/main.css _site

decorate:
	> "_site/$(F).tmp.html"
	awk 'BEGIN{p=1} /<body>/{p=0} p' "_site/$(F).html" >> "_site/$(F).tmp.html"
	cat web/common.html >> "_site/$(F).tmp.html"
	awk 'BEGIN{p=0} p; /<body>/{p=1}' "_site/$(F).html" >> "_site/$(F).tmp.html"
	mv "_site/$(F).tmp.html" "_site/$(F).html"

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
	find . -name "*.lg" -exec rm {} +
	find . -name "*.aux" -exec rm {} +
	find . -name "*.log" -exec rm {} +
	find . -name "*.out" -exec rm {} +
	find . -name "*.idv" -exec rm {} +
	find . -name "*.4ct" -exec rm {} +
	find . -name "*.4tc" -exec rm {} +
	find . -name "*.dvi" -exec rm {} +
	find . -name "*.tmp" -exec rm {} +
	find . -name "*.xref" -exec rm {} +
	rm -f A.ref
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
