clc, clear all ;

% get access to model
curPath = pwd() ;
cd('..\\..\\..\\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ; 

PRN = [1; 21; 29; 30; 31] ;
lockTimeClassic = [40.26, 41.39, 36.02, 34.77, 36.11] ;
probDetection = [0.88, 1.00, 0.94, 0.93, 0.99] ;

figure(1) ,
plot(lockTimeClassic, '-+') ,
    set(gca, 'XTickLabel', PRN) ,
    set(gca, 'XTick', 1:length(PRN)) ,
    legend('1') ,       % 1 - classic
    phd_figure_style(gcf) ;

    
figure(2) ,
plot(probDetection, '-+') ,
    set(gca, 'XTickLabel', PRN) ,
    set(gca, 'XTick', 1:length(PRN)) ,
    legend('1') ,       % 1 - classic
    phd_figure_style(gcf) ;

    
% remove model path
rmpath(modelPath) ;