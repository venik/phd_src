load('precision_vs_fft_length_mt.mat')

[X,Y]=meshgrid(SNR_dB, FFT_lengths./ 16368) ;
surfc(X, Y, log10(freq)), grid on,
    %xlim([SNR_dB(1) SNR_dB(end)])
    %ylim([1 FFT_length])
    xlabel('SNR','FontSize',14,'Color',[0 0 0.8]),
    ylabel('FFT length','FontSize',14,'Color',[0 0 0.8]),
    zlabel('Freq error, log10(Hz)','FontSize',14,'Color',[0 0 0.8]) ;
set(gca,'FontSize',14) ;