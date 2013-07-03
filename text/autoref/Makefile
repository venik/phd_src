TEX2DVI = texi2dvi

TEX_FLAGS = --dvipdf

THESIS_ALL = 	\
		general.tex		\
		autoref.tex

thesis: ${THESIS_ALL}
	${TEX2DVI} ${TEX_FLAGS} autoref.tex

.PHONY: clean

clean:
	rm -f *.log *.aux *.toc *.pdf *.dvi *.bbl *.blg
