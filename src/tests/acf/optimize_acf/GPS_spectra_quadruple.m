clc, clear, clf ;
% get access to model
modelPath = '../../tsim/model/' ;
addpath(modelPath) ;

% get default parameters
% init_rand(1) ;
ifsmp = get_ifsmp() ;
ifsmp.snr_db = -20 ;
ifsmp.sats = [1 2] ;
ifsmp.vars = [1.0 0.0] ;
ifsmp.fs = [4.090333e6, 4.093303e6] ;
ifsmp.fd = 16.368e6 ;
ifsmp.delays = [100,150,230,10] ;
ifsmp.sigLengthMsec = 20 ;

N = 16368 ;

[~, x ,sats, delays, signoise] = get_gps_if_signal( ifsmp ) ;
code = get_gps_ca_code(ifsmp.sats(1),ifsmp.fd,length(x)+delays(1)) ;
y = x.*code(1+delays(1):length(x)+delays(1)) ;

% ms = 1 ;
% L = 1 ;
% NN = N / L ;
% y_new = zeros(NN, 1) ;
% for kk=1:L*ms
%     y_new = y_new + y(NN*(kk-1) + 1 : NN*kk) ;
% end
% 
% y_new = y_new / kk ;
y_new = y(1:N) ;

Y = fft(y_new - mean(y_new), 2^(nextpow2(length(y))+1)) ; 
YY = Y .* conj(Y) ;
%YY = YY ./ max(YY) ;
rss1 = ifft(YY) ;
rss2 = ifft(YY .^ 4) ;
rss3 = ifft(YY .^ 16) ;

% rss1 = rss1 ./ rss1(1) ;
% rss_a = autocorr(y_new, length(y_new) - 1) ;
% b_a = ar_model([rss_a(1) ; rss_a(2) ; rss_a(3)]) 

b = ar_model([rss3(1) ; rss3(2) ; rss3(3)]) 

[pole, omega0, Hjw0] = get_ar_pole(b) ;
fprintf('freq:%8.2f\n', omega0*ifsmp.fd/2/pi) ;
fprintf('delta freq:%8.2f\n', omega0*ifsmp.fd/2/pi - ifsmp.fs(1) ) ;

 hold on, pwelch(rss3, 4092) ; ylabel('дБ') ; xlabel('Нормализованная частота \pi/rad/отсчет') ; title('') ; phd_figure_style(gcf) ;

% remove model path
rmpath(modelPath) ;
