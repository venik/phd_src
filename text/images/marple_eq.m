% get access to model
clc, clear all, clf ;
curPath = pwd() ;
cd('..\\..\\src\\tests\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

T = 10^-3 ;

%%%%%%%%%%%%%%%%%%
% without ACF
SNR_dB_without_acf = -10:15 ;
SNR_without_acf = 10.^(SNR_dB_without_acf ./ 10) ;
freq_without_acf = 1.03 ./ (2*T*(3*SNR_without_acf)) ;

%%%%%%%%%%%%%%%%%%
% Acf
SNR_dB_range = [-30, -25, -20, -15, -10] ;
SNR_range = 10.^(SNR_dB_range ./ 10) ;

freq = 1.03 ./ (2*T*(3*SNR_range)); 

Pll_line = repmat(16, 1, length(-30:15)) ;

SNR_iter1 = [0.004, 0.041, 0.405, 3.975, 37.732] ;
SNR_iter2 = [0.062, 32.027, 3753.829, 450816.278, 221435.798] ;
SNR_iter3 = [0.069, 1268.889, 7408.329, 123347.412, 55358.308] ;

freq1 = 1.03 ./ (2*T*(3*SNR_iter1)) ;
freq2 = 1.03 ./ (2*T*(3*SNR_iter2)) ;
freq3 = 1.03 ./ (2*T*(3*SNR_iter3)) ;

SNR_dB = 10*log10(SNR_range) ;

figure(1) ,
    hold off, plot(-30:15, Pll_line) ,
    hold on, plot(SNR_dB, freq3, '-go', SNR_dB, freq2, '-m*', SNR_dB, freq1, '-r+') ,
    plot(SNR_dB_without_acf, freq_without_acf) ,
    title('Точность оценки частоты по ф. Марпла') ,
    xlabel('ОСШ, дБ') ,
    ylabel('F, Гц') ,
    %xlim([floor(SNR_dB(1)) ceil(SNR_dB(end))]) ,
    ylim([0 500]) ,
    legend('Полоса ФАПЧ', 'Уточнение АКФ 3 итерация', ...
        'Уточнение АКФ 2 итерация', 'Уточнение АКФ 1 итерация', ...
        'Оценка ОСШ необходимого для ФАПЧ') ;
    %rectangle('Position',[7,3,10,12 ],'FaceColor',[.9 .7 .7],'EraseMode','xor') ;
    phd_figure_style(gcf) ;
   
% remove model path
rmpath(modelPath) ;
