clc, clear all ;

% get access to model
curPath = pwd() ;
cd('..\\..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ; 

PRN = [1; 21; 29; 30; 31] ;
lockTimeClassic = [40.26 41.39 36.02 34.77 36.11] ;
probDetectionClassic = [0.88 1.00 0.94 0.93 0.99] ;

lockTime8FFT = [36.65 44.43  36.06   35.16 36.90] ;
probDetection8FFT = [0.48  0.03  0.80 0.90  0.43] ;

lockTime4FFT = [36.81 43.95 36.06 35.19 36.75 ] ;
probDetection4FFT = [0.48 0.03 0.80 0.89 0.43 ] ;

lockTime2FFT = [45.09 46.22 42.31 42.84 36.27] ;
probDetection2FFT = [0.32 0.02 0.49 0.50 0.39] ;

x = 1:length(PRN) ;

figure(1) ,
plot(x, lockTimeClassic, '-+', x, lockTime8FFT, '-.', x, lockTime4FFT, ':',  x, lockTime2FFT, '--') ,
    set(gca, 'XTickLabel', PRN) ,
    set(gca, 'XTick', 1:length(PRN)) ,
    legend('1', '2', '3', '4') ,       % 1 - classic, 8 FFTm 4 FFT
    phd_figure_style(gcf) ;

    
figure(2) ,
plot(x, probDetectionClassic, '-+', x, probDetection8FFT, '-.',  x, probDetection4FFT, ':',  x, probDetection2FFT, '--') ,
    set(gca, 'XTickLabel', PRN) ,
    set(gca, 'XTick', 1:length(PRN)) ,
    legend('1', '2', '3', '4') ,       % 1 - classic, 2 - 8 FFT, 3 - 4 FFT, 4 - 2 FFT
    phd_figure_style(gcf) ;

    
% remove model path
rmpath(modelPath) ;