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

SEC2 = sec2_duffing.tex  sec2_lpc.tex  sec2_newton.tex  sec2.tex
SEC3 = sec3_lpc.tex  sec3_newton.tex  sec3.tex

thesis: ${THESIS_ALL}
	${TEX2DVI} ${TEX_FLAGS} thesis.tex

sec2: $(SEC2)
	${TEX2DVI} ${TEX_FLAGS} sec2.tex

sec3: $(SEC3)
	${TEX2DVI} ${TEX_FLAGS} sec3.tex

thesis_ps: ${THESIS_ALL} 
	${TEX2DVI} thesis.tex

.PHONY: clean

clean:
	rm -f *.log *.aux *.toc *.pdf *.dvi *.bbl *.blg
