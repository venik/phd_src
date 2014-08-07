clc, clear, clf ;
% get access to model
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;          

load('acf_various_windows_2fft.mat');
fft2_3iter_rect = freq3(:,1) ;

load('acf_various_windows_4fft.mat');
fft4_3iter_rect = freq3(:,1) ;

figure(1)
semilogy(SNR_dB, fft2_3iter_rect, '-go', SNR_dB, fft4_3iter_rect, '-b*')
    title('FFT 2 and 4') ,
    legend('2', '4') ;          % legend('PLL line', 'Rect', 'Hamming', 'Blackman', 'Hann') ;
    phd_figure_style(gcf) ;    
    
% remove model path
rmpath(modelPath) ;