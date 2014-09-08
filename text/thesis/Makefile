TEX2DVI = texi2dvi

TEX_FLAGS = --dvipdf

THESIS_ALL = 	\
		thesis.tex		\
		sec1_new.tex

#		sec1_2max.tex		\
#		sec1_acq_algo.tex	\
#		sec1_chaos.tex		\
#		sec1_dma.tex		\
#		sec1_noise_est.tex	\
#		sec1_serial.tex		\

SEC1 = sec1_new.tex
SEC2 = sec2_lpc.tex  sec2_acf.tex  sec2.tex
SEC3 = sec3_lpc.tex sec3_lpc_dma.tex sec3_newton.tex  sec3.tex
SEC4 = sec4_model.tex

SEC34 = ${SEC3} ${SEC4}

DATE = `date +%d.%m.%y`
STR = "s/{..\...\...}/{$(DATE)}/"

thesis: ${THESIS_ALL}
	${TEX2DVI} ${TEX_FLAGS} thesis.tex -o Nikiforov_$(DATE).pdf

sec1: $(SEC1)
	${TEX2DVI} ${TEX_FLAGS} sec1.tex

sec2: $(SEC2)
	${TEX2DVI} ${TEX_FLAGS} sec2.tex

sec3: $(SEC3)
	${TEX2DVI} ${TEX_FLAGS} sec3.tex

sec34: $(SEC34)
	${TEX2DVI} ${TEX_FLAGS} sec34.tex

sec4: hw.tex 
	${TEX2DVI} ${TEX_FLAGS} sec4.tex

thesis_ps: ${THESIS_ALL} 
	${TEX2DVI} thesis.tex

.PHONY: clean

clean:
	rm -f *.log *.aux *.toc *.pdf *.dvi *.bbl *.blg *.out
