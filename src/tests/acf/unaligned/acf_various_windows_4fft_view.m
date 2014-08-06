clc, clear, clf ;
% get access to model
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;          

load('acf_various_windows_4fft.mat');

figure(1), 
semilogy(SNR_dB, freq1(:,1), '-go', SNR_dB, freq1(:,2), '-b*', ...
    SNR_dB, freq1(:,3), '-r+', SNR_dB, freq1(:,4), '-y+') ;        
    title('1 FFT SKO') ,
    legend('1', '2', '3', '4') ;          % legend('PLL line', 'Rect', 'Hamming', 'Blackman', 'Hann') ;
    phd_figure_style(gcf) ;
    
figure(2),
semilogy(SNR_dB, freq2(:,1), '-go', SNR_dB, freq2(:,2), '-b*', ...
    SNR_dB, freq2(:,3), '-r+', SNR_dB, freq2(:,4), '-y+') ;        
    title('2 FFT SKO') ,
    legend('1', '2', '3', '4') ;          % legend('PLL line', 'Rect', 'Hamming', 'Blackman', 'Hann') ;
    phd_figure_style(gcf) ;
   
figure(3)
semilogy(SNR_dB, freq3(:,1), '-go', SNR_dB, freq3(:,2), '-b*', ...
    SNR_dB, freq3(:,3), '-r+', SNR_dB, freq3(:,4), '-y+') ;        
    title('3 FFT SKO') ,
    legend('1', '2', '3', '4') ;          % legend('PLL line', 'Rect', 'Hamming', 'Blackman', 'Hann') ;
    phd_figure_style(gcf) ;

figure(4)
semilogy(SNR_dB, freq1(:,1), '-go', SNR_dB, freq2(:,2), '-b*', ...
    SNR_dB, freq3(:,3), '-r+') ;        
    title('Rect for 1, 2, 3') ,
    legend('1', '2', '3') ;          % legend('PLL line', 'Rect', 'Hamming', 'Blackman', 'Hann') ;
    phd_figure_style(gcf) ;    
    
% remove model path
rmpath(modelPath) ;