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

load('acf_various_windows_8fft.mat');
fft8_3iter_rect = freq3(:,1) ;

figure(1)
semilogy(SNR_dB, fft2_3iter_rect, '-go', SNR_dB, fft4_3iter_rect, '-b*', SNR_dB, fft8_3iter_rect, '-c+')
    title('FFT 2, 4, 8') ,
    legend('2', '4', '8') ;          % legend('PLL line', 'Rect', 'Hamming', 'Blackman', 'Hann') ;
    phd_figure_style(gcf) ;    
    
% remove model path
rmpath(modelPath) ;