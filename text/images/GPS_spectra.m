clc, clear ;
% get access to model
curPath = pwd() ;
cd('..\\..\\src\\tests\tsim\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

% get default parameters
init_rand(1) ;
ifsmp = get_ifsmp() ;
ifsmp.snr_db = 10 ;
ifsmp.sats = [1,2] ;
ifsmp.vars = [1.0 1.0] ;
ifsmp.fs = [4670000 4100000 4093000  4092400] ;
ifsmp.fd = 16368000 ;
ifsmp.delays = [100,150,230,10] ;
ifsmp.sigLengthMsec = 12 ;

[~, x ,sats, delays, signoise] = get_gps_if_signal( ifsmp ) ;
code = get_gps_ca_code(ifsmp.sats(1),ifsmp.fd,length(x)+delays(1)) ;
y = x.*code(1+delays(1):length(x)+delays(1)) ;

%hold off, pwelch(x,4096) ;
%hold on, pwelch(y,4096) ;
%legend('СПМ сигнала','СПМ сигнала после снятия ПСП') ;

pwelch(y,4096) ;
legend('СПМ сигнала после снятия ПСП') ;


ylabel('Спектральная плотность dB/rad/отсчет') ;
xlabel('Нормализованная частота \pi/rad/отсчет') ;
title('')
phd_figure_style(gcf) ;


% remove model path
rmpath(modelPath) ;
