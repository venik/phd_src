clc, clear, clf ;
% get access to model
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;          

load('acf_various_windows_4fft.mat');

freq_plot = freq1 ;

semilogy(SNR_dB, freq_plot(:,1), '-go', SNR_dB, freq_plot(:,2), '-b*', ...
    SNR_dB, freq_plot(:,3), '-r+', SNR_dB, freq_plot(:,4), '-y+') ;        
    title('SKO') ,
    legend('1', '2', '3', '4', '5') ;          % legend('PLL line', 'Rect', 'Hamming', 'Blackman', 'Hann') ;
    phd_figure_style(gcf) ;
        
% remove model path
rmpath(modelPath) ;