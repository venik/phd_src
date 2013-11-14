% get access to model
clc, clear all, clf ;
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

N = 16368 ;
Fs = 4 ;    
BT = N / Fs ;

SNR_dB = -30:1:10 ;
SNR = (10 .^ (SNR_dB./10)) ;

SNR3 = zeros(length(SNR), 1) ;

for kk=1:length(SNR)
    SNR1 = 2 * BT * SNR(kk) / (2 + 1/SNR(kk) ) ;
    SNR2 = 2 * BT * SNR1 / (2 + 1/SNR1 ) ;
    SNR3(kk) = 2 * BT * SNR2 / (2 + 1/SNR2 ) ;
end ;

plot(SNR_dB, 10*log10(SNR3), '-gx'),
    xlabel('Base SNR'),
    ylabel('SNR after ACF boost') ,
    xlim([SNR(1) SNR(end)]),
    phd_figure_style(gcf) ;


% remove model path
rmpath(modelPath) ;