TEX2DVI = texi2dvi

TEX_FLAGS = --dvipdf

AUTOREF_ALL = 	\
		general.tex		\
		autoref.tex

DATE = `date +%d.%m.%y`
STR = "s/{..\...\...}/{$(DATE)}/"

autoref: ${AUTOREF_ALL}
	@sed -i $(STR) general.tex
	${TEX2DVI} ${TEX_FLAGS} autoref.tex

.PHONY: clean

clean:
	rm -f *.log *.aux *.toc *.pdf *.dvi *.bbl *.blg *.out
