clc, clear ;
% get access to model
curPath = pwd() ;
cd('..\\..\\model') ;
modelPath = pwd() ;
cd( curPath ) ;
addpath(modelPath) ;

% get default parameters
init_rand(1) ;
ifsmp = get_ifsmp() ;
ifsmp.snr_db = 5 ;
ifsmp.sats = [1] ;
ifsmp.vars = [1.0 1.0] ;
ifsmp.fs = [4092000 4092000 4093000  4092400] ;
ifsmp.fd = 16368000 ;
ifsmp.delays = [100,150,230,10] ;
ifsmp.sigLengthMsec = 12 ;

[~, x ,sats, delays, signoise] = get_gps_if_signal( ifsmp ) ;
code = get_gps_ca_code(ifsmp.sats(1),ifsmp.fd,length(x)+delays(1)) ;
y = x.*code(1+delays(1):length(x)+delays(1)) ;

rxx = get_rxx(y, 0:2 ) ;
b = ar_model([rxx(1); rxx(2); rxx(3)]) ;
[poles, omega0, Hjw0] = get_ar_pole(b) ;
omega = 0:0.02:pi ;
Hjw = 1.0./( -b(2)*exp(-2j*omega) - b(1)*exp(-1j*omega) + 1.0 ) ;

hold off, pwelch(x,4096) ;
hold on, pwelch(y,4096) ;
hold on, plot(omega/pi,10*log10(Hjw.*conj(Hjw)),'-.') ;

ylabel('Спектральная плотность dB/rad/отсчет') ;
xlabel('Нормализованная частота \pi/rad/отсчет') ;
title('')
legend('СПМ сигнала','СПМ сигнала после снятия ПСП','Частотный отклик АР-модели') ;
phd_figure_style(gcf) ;


% remove model path
rmpath(modelPath) ;
