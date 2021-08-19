SOURCES=main.tex
PDF_OBJECTS=$(SOURCES:.tex=.pdf)

LATEXMK=pdflatex
LATEXMK_OPTIONS=-bibtex -pdf -pdflatex="pdflatex -interaction=nonstopmode"

all: render

pdf: $(PDF_OBJECTS)

%.pdf: %.tex
	@echo Input file: $<
	$(LATEXMK) $(LATEXMK_OPTIONS) $<

clean:
	- $(LATEXMK) -bibtex -C main

dist-clean: clean
	-rm $(FILENAME).tar.gz
