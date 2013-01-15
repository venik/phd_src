TEX2DVI = texi2dvi

TEX_FLAGS = --dvipdf

THESIS_ALL = 	\
		sec1_2max.tex		\
		sec1_acq_algo.tex	\
		sec1_chaos.tex		\
		sec1_dma.tex		\
		sec1_fft.tex		\
		sec1_noise_est.tex	\
		sec1_serial.tex		\
		thesis_default.tex	\
		thesis.tex

SEC2 =	sec2_duffing.tex

thesis: ${THESIS_ALL}
	${TEX2DVI} ${TEX_FLAGS} thesis.tex

sec2: $(SEC2)
	${TEX2DVI} ${TEX_FLAGS} sec2.tex

thesis_ps: ${THESIS_ALL} 
	${TEX2DVI} thesis.tex

.PHONY: clean

clean:
	rm -f *.log *.aux *.toc *.pdf *.dvi *.bbl *.blg
