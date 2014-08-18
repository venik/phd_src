clc, clear, clf ;
% get access to model
curPath = pwd() ;
cd('..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;          

load('acf_various_windows_4fft_awgn.mat') ;
est_awgn4 = freq3(:,1);

load('acf_various_windows_4fft.mat') ;
est_intf4 = freq3(:,1);

load('acf_various_windows_2fft_awgn.mat') ;
est_awgn2 = freq3(:,1);

load('acf_various_windows_2fft.mat') ;
est_intf2 = freq3(:,1);

figure(1)
semilogy(SNR_dB, est_awgn4, '-go', SNR_dB, est_intf4, '-gx', ...
    SNR_dB, est_awgn2, '-go', SNR_dB, est_intf2, '-gx') ;        
    title('') ,
    legend('awgn4', 'intf4', 'awgn2', 'intf2') ;
    phd_figure_style(gcf) ;    
    
% remove model path
rmpath(modelPath) ;