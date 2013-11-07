% get access to model
clc, clear all%, clf ;
curPath = pwd() ;
cd('..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

load prob1e6 ;

figure(1) ,
    semilogy(SNR_dB, freq1_match, '-go', SNR_dB, freq2_match, '-b*', SNR_dB, freq3_match, '-r+') ,
    title('Probability') ,
    legend('1', '2', '3') ;
    xlabel('SNR, dB') ;
    ylabel('P(f\in[f_0-18Hz...f_0+18Hz])') ;
    phd_figure_style(gcf) ;


% remove model path
rmpath(modelPath) ;


