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
ifsmp.snr_db = -20 ;
ifsmp.sats = [1,2] ;
ifsmp.vars = [1.0 1.0] ;
ifsmp.fs = [4670000 4100000 4093000  4092400] ;
ifsmp.fd = 16368000 ;
ifsmp.delays = [100,150,230,10] ;
ifsmp.sigLengthMsec = 12 ;

[~, x ,sats, delays, signoise] = get_gps_if_signal( ifsmp ) ;
code = get_gps_ca_code(ifsmp.sats(1),ifsmp.fd,length(x)+delays(1)) ;
y = x.*code(1+delays(1):length(x)+delays(1)) ;
%y = 40 * randn(length(x), 1) ;

Y = fft(y) ; 
YY = Y .* conj(Y) ;
%YYYY = YY .^ 4 ;
rss1 = ifft(YY) ;
rss2 = ifft(YY .^ 4) / 16368 ;
rss3 = ifft(YY .^ 8) / 16368 ;

rss3 = rss3 / max(rss3) ;

%subplot(3,1,1),
%    pwelch(x, 4096) ;
%ylabel('СПМ dB/rad/отсчет') ;
%xlabel('Нормализованная частота \pi/rad/отсчет') ;
%title('')
%legend('СПМ входного сигнала') ;
%phd_figure_style(gcf) ;

%subplot(3,1,2),
%    pwelch(y, 4096) ;
%ylabel('СПМ dB/rad/отсчет') ;
%xlabel('Нормализованная частота \pi/rad/отсчет') ;
%title('')
%legend('СПМ сигнала после повторной модуляции ПСП') ;
%phd_figure_style(gcf) ;

%subplot(3,1,3),
pwelch(rss3, 4096) ;
%semilogy(log10(sp ./ max(sp)))
%hold on, pwelch(rss2,4096) ;
ylabel('dB') ;
xlabel('Нормализованная частота \pi/rad/отсчет') ;
title('')
%legend('СПМ сигнала на 3 итерации') ;
phd_figure_style(gcf) ;


% remove model path
rmpath(modelPath) ;
