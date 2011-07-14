TEX = texi2dvi

TEX_FLAGS = --dvipdf

.PHONY: clean

thesis: thesis.tex thesis_default.tex
	${TEX} ${TEX_FLAGS} $< 

clean:
	rm -f *.log *.aux *.toc *.pdf *.dvi *.bbl *.blg
