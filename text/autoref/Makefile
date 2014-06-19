TEX2DVI = texi2dvi

TEX_FLAGS = --dvipdf

AUTOREF_ALL = 	\
		general.tex		\
		autoref.tex

DATE = `date +%d.%m.%y`
STR = "s/{..\...\...}/{$(DATE)}/"

autoref: ${AUTOREF_ALL}
	${TEX2DVI} ${TEX_FLAGS} autoref.tex -o Nikiforov_autoref_$(DATE).pdf
#@sed -i $(STR) general.tex

.PHONY: clean

clean:
	rm -f *.log *.aux *.toc *.pdf *.dvi *.bbl *.blg *.out
