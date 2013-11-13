% get access to model
clc, clear all%, clf ;
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

load prob_lpc_5000 ;

figure(1) ,
    semilogy(SNR_dB, freq, '-go') ,
    title('Probability') ,
    xlabel('SNR, dB') ;
    ylabel('P(f\in[f_0-18Hz...f_0+18Hz])') ;
    phd_figure_style(gcf) ;


% remove model path
rmpath(modelPath) ;


