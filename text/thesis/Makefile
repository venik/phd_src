TEX = texi2dvi

TEX_FLAGS = --dvipdf

.PHONY: clean

thesis: thesis.tex thesis_default.tex sec1_fft.tex sec1_dma.tex sec1_serial.tex
	${TEX} ${TEX_FLAGS} $< 

clean:
	rm -f *.log *.aux *.toc *.pdf *.dvi *.bbl *.blg
